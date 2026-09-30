import ccxt from 'ccxt';
import { createClient } from '@supabase/supabase-js';
import { ASSETS, EXCHANGES, TIMEFRAMES } from './market-config.mjs';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required');
const db = createClient(url, key, { auth: { persistSession: false } });

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function verifiedAssets() {
  const { data, error } = await db.from('assets').select('id,symbol,name,identity_status,role').eq('active', true);
  if (error) throw error;
  return new Map(data.map(a => [a.symbol, a]));
}

function marketCandidates(exchange, asset) {
  const matches = [];
  for (const quote of asset.quotes) {
    const direct = `${asset.symbol}/${quote}`;
    if (exchange.markets[direct]) matches.push(exchange.markets[direct]);
  }
  return matches.filter(m => m.active !== false && m.spot !== false);
}

async function ingestOHLCV(exchange, dbAsset, market, timeframe) {
  if (!exchange.has.fetchOHLCV) return 0;
  const rows = await exchange.fetchOHLCV(market.symbol, timeframe, undefined, 500);
  if (!rows?.length) return 0;
  const payload = rows.map(([ts,o,h,l,c,v]) => ({
    asset_id: dbAsset.id,
    observed_at: new Date(ts).toISOString(),
    timeframe,
    source: `${exchange.id}:${market.symbol}`,
    open:o, high:h, low:l, close:c, volume:v,
    quote_currency: market.quote,
    data_quality: 'RAW_EXCHANGE',
    raw: { exchange: exchange.id, market_id: market.id, symbol: market.symbol }
  }));
  const { error } = await db.from('market_observations').upsert(payload, {
    onConflict: 'asset_id,observed_at,timeframe,source', ignoreDuplicates: false
  });
  if (error) throw error;
  return payload.length;
}

async function main() {
  const registry = await verifiedAssets();
  const report = [];
  for (const exchangeId of EXCHANGES) {
    const Exchange = ccxt[exchangeId];
    if (!Exchange) continue;
    const ex = new Exchange({ enableRateLimit: true });
    try {
      await ex.loadMarkets();
      for (const config of ASSETS) {
        const dbAsset = registry.get(config.symbol);
        if (!dbAsset) continue;
        // Portfolio assets are hard-blocked until exact identity has been verified.
        if (!config.benchmark && dbAsset.identity_status !== 'VERIFIED') {
          report.push({ asset: config.symbol, exchange: exchangeId, status: 'IDENTITY_BLOCKED' });
          continue;
        }
        const markets = marketCandidates(ex, config);
        if (!markets.length) continue;
        // Initially use the first viable quote route. Venue-quality selection comes next.
        const market = markets[0];
        for (const timeframe of TIMEFRAMES) {
          try {
            const count = await ingestOHLCV(ex, dbAsset, market, timeframe);
            report.push({ asset: config.symbol, exchange: exchangeId, market: market.symbol, timeframe, count, status:'OK' });
          } catch (err) {
            report.push({ asset: config.symbol, exchange: exchangeId, market: market.symbol, timeframe, status:'ERROR', error:String(err.message || err) });
          }
          await sleep(ex.rateLimit || 250);
        }
      }
    } catch (err) {
      report.push({ exchange: exchangeId, status:'EXCHANGE_ERROR', error:String(err.message || err) });
    } finally {
      if (typeof ex.close === 'function') await ex.close().catch(()=>{});
    }
  }
  console.log(JSON.stringify({ finished_at:new Date().toISOString(), report }, null, 2));
}

main().catch(err => { console.error(err); process.exit(1); });
