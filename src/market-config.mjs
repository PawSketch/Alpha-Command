// Candidate market routes only. Identity must be VERIFIED before ingestion.
// The discovery worker checks actual exchange markets instead of assuming a ticker route exists.
export const ASSETS = [
  { symbol: 'XRP', name: 'XRP', quotes: ['USDT','USD','USDC'] },
  { symbol: 'JASMY', name: 'JasmyCoin', quotes: ['USDT','USD','USDC'] },
  { symbol: 'XCN', name: 'Onyxcoin', quotes: ['USDT','USD','USDC'] },
  { symbol: 'VERI', name: 'Veritaseum', quotes: ['USDT','USD','USDC','BTC'] },
  { symbol: 'DRGN', name: 'Dragonchain', quotes: ['USDT','USD','USDC','BTC'] },
  { symbol: 'SUPRA', name: 'Supra', quotes: ['USDT','USD','USDC'] },
  { symbol: 'BSV', name: 'Bitcoin SV', quotes: ['USDT','USD','USDC'] },
  { symbol: 'ZBCN', name: 'Zebec Network', quotes: ['USDT','USD','USDC'] },
  { symbol: 'SHX', name: 'Stronghold Token', quotes: ['USDT','USD','USDC'] },
  { symbol: 'BTC', name: 'Bitcoin', quotes: ['USDT','USD','USDC'], benchmark: true },
  { symbol: 'ETH', name: 'Ethereum', quotes: ['USDT','USD','USDC'], benchmark: true }
];

// Start broad enough to discover coverage; selection is scored by capability/liquidity later.
export const EXCHANGES = [
  'kraken','coinbase','bitstamp','kucoin','gateio','mexc','bitget','okx','bybit','binance','cryptocom','coinex','htx'
];

export const TIMEFRAMES = ['15m','1h','4h','1d','1w'];
