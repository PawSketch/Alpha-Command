-- First server-side feature layer: returns, volatility, moving averages, volume expansion.
-- Deliberately transparent SQL; more advanced indicators can be added without overwriting raw data.

create or replace view public.market_features_basic as
with x as (
 select mo.*,
   lag(close,1) over w as close_1,
   lag(close,3) over w as close_3,
   lag(close,7) over w as close_7,
   avg(close) over (partition by asset_id,timeframe order by observed_at rows between 19 preceding and current row) as sma20,
   avg(close) over (partition by asset_id,timeframe order by observed_at rows between 49 preceding and current row) as sma50,
   avg(volume) over (partition by asset_id,timeframe order by observed_at rows between 19 preceding and current row) as vol_sma20,
   stddev_samp(ln(nullif(close,0))) over (partition by asset_id,timeframe order by observed_at rows between 19 preceding and current row) as log_price_sd20,
   max(high) over (partition by asset_id,timeframe order by observed_at rows between 19 preceding and 1 preceding) as prior_high20,
   min(low) over (partition by asset_id,timeframe order by observed_at rows between 19 preceding and 1 preceding) as prior_low20
 from public.market_observations mo
 window w as (partition by asset_id,timeframe order by observed_at)
)
select x.*,
  case when close_1 is null or close_1=0 then null else (close/close_1-1)*100 end as ret_1bar_pct,
  case when close_3 is null or close_3=0 then null else (close/close_3-1)*100 end as ret_3bar_pct,
  case when close_7 is null or close_7=0 then null else (close/close_7-1)*100 end as ret_7bar_pct,
  case when vol_sma20 is null or vol_sma20=0 then null else volume/vol_sma20 end as volume_ratio20,
  case when prior_high20 is null or prior_low20 is null or close=0 then null else (prior_high20-prior_low20)/close end as range20_norm,
  case when prior_high20 is not null and close > prior_high20 then true else false end as breakout20
from x;

create or replace view public.latest_market_features_basic as
select distinct on (asset_id,timeframe,source) *
from public.market_features_basic
order by asset_id,timeframe,source,observed_at desc;

-- Candidate radar, not a trade instruction. The learning layer must validate these features.
create or replace view public.pre_move_radar_candidates as
select a.symbol, f.asset_id, f.observed_at, f.timeframe, f.source, f.close,
  case
    when f.breakout20 and coalesce(f.volume_ratio20,0) >= 1.5 then 'BREAKOUT_CONFIRMATION'
    when f.sma20 is not null and f.sma50 is not null and f.close > f.sma20 and f.sma20 > f.sma50 and coalesce(f.volume_ratio20,0) >= 1.15 then 'TRIGGER_ARMING'
    when f.sma20 is not null and f.sma50 is not null and f.close >= f.sma20 and coalesce(f.range20_norm,1) <= 0.15 then 'PRE_MOVE'
    else 'WATCH'
  end as radar_stage,
  jsonb_build_object(
    'close',f.close,'sma20',f.sma20,'sma50',f.sma50,'volume_ratio20',f.volume_ratio20,
    'range20_norm',f.range20_norm,'breakout20',f.breakout20,'ret_1bar_pct',f.ret_1bar_pct,
    'ret_3bar_pct',f.ret_3bar_pct,'ret_7bar_pct',f.ret_7bar_pct
  ) as evidence
from public.latest_market_features_basic f
join public.assets a on a.id=f.asset_id;
