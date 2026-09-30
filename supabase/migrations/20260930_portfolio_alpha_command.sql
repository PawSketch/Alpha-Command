-- Portfolio Alpha Command / Velox Insights persistent intelligence layer
-- Designed for Supabase/Postgres. Apply through Supabase migrations after review.

create extension if not exists pgcrypto;

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  symbol text not null unique,
  name text not null,
  network text,
  contract_address text,
  identity_status text not null default 'UNVERIFIED',
  identity_evidence jsonb not null default '[]'::jsonb,
  role text not null default 'PORTFOLIO',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.market_observations (
  id bigint generated always as identity primary key,
  asset_id uuid not null references public.assets(id) on delete cascade,
  observed_at timestamptz not null,
  timeframe text not null,
  source text not null,
  open numeric, high numeric, low numeric, close numeric, volume numeric,
  quote_currency text not null default 'USD',
  data_quality text not null default 'UNKNOWN',
  raw jsonb not null default '{}'::jsonb,
  unique(asset_id, observed_at, timeframe, source)
);
create index if not exists market_obs_asset_time_idx on public.market_observations(asset_id, observed_at desc);

create table if not exists public.feature_snapshots (
  id bigint generated always as identity primary key,
  asset_id uuid not null references public.assets(id) on delete cascade,
  observed_at timestamptz not null,
  timeframe text not null,
  features jsonb not null,
  freshness jsonb not null default '{}'::jsonb,
  data_limitations jsonb not null default '[]'::jsonb,
  feature_version text not null default 'v1',
  unique(asset_id, observed_at, timeframe, feature_version)
);

create table if not exists public.cycle_state_history (
  id bigint generated always as identity primary key,
  asset_id uuid not null references public.assets(id) on delete cascade,
  observed_at timestamptz not null default now(),
  previous_state text,
  state text not null check (state in ('ACCUMULATION_BASE','EARLY_BULL_CONFIRMATION','EXPANSION_TREND_RIDE','EUPHORIA_DISTRIBUTION_WATCH','DISTRIBUTION_CYCLE_EXIT','EARLY_BEAR_CAPITAL_PRESERVATION','CAPITULATION','BEAR_BASE_REACCUMULATION','THESIS_FAILURE')),
  evidence_for jsonb not null default '[]'::jsonb,
  evidence_against jsonb not null default '[]'::jsonb,
  confidence numeric check (confidence between 0 and 1),
  limitations jsonb not null default '[]'::jsonb
);

create table if not exists public.signals (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id) on delete cascade,
  generated_at timestamptz not null default now(),
  signal_stage text not null check (signal_stage in ('WATCH','PRE_MOVE','TRIGGER_ARMING','BREAKOUT_CONFIRMATION','EXPANSION','EXHAUSTION_DISTRIBUTION')),
  action_state text,
  timeframe text,
  score numeric,
  confidence numeric check (confidence between 0 and 1),
  thesis text,
  confirmation jsonb not null default '[]'::jsonb,
  invalidation jsonb not null default '[]'::jsonb,
  contrary_evidence jsonb not null default '[]'::jsonb,
  component_scores jsonb not null default '{}'::jsonb,
  source_snapshot_ids jsonb not null default '[]'::jsonb,
  data_limitations jsonb not null default '[]'::jsonb,
  model_version text not null default 'v1'
);
create index if not exists signals_asset_time_idx on public.signals(asset_id, generated_at desc);

create table if not exists public.signal_outcomes (
  id bigint generated always as identity primary key,
  signal_id uuid not null references public.signals(id) on delete cascade,
  horizon text not null check (horizon in ('1h','6h','24h','3d','7d','14d','30d')),
  evaluated_at timestamptz not null default now(),
  return_pct numeric,
  mfe_pct numeric,
  mae_pct numeric,
  realised_volatility numeric,
  confirmation_occurred boolean,
  invalidation_occurred boolean,
  outcome_label text,
  notes text,
  unique(signal_id, horizon)
);

create table if not exists public.precursor_events (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id) on delete cascade,
  event_at timestamptz not null,
  event_type text not null,
  threshold_pct numeric,
  lookback_snapshots jsonb not null default '{}'::jsonb,
  controls jsonb not null default '{}'::jsonb,
  outcome jsonb not null default '{}'::jsonb,
  false_positive boolean not null default false,
  false_negative boolean not null default false,
  evidence_quality text not null default 'INSUFFICIENT_EVIDENCE',
  notes text
);

create table if not exists public.research_evidence (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references public.assets(id) on delete cascade,
  observed_at timestamptz not null default now(),
  category text not null,
  claim text not null,
  evidence_label text not null,
  source_url text,
  source_name text,
  reciprocal_confirmation_url text,
  valid_from timestamptz,
  valid_to timestamptz,
  payload jsonb not null default '{}'::jsonb
);

create table if not exists public.tokenomics_snapshots (
  id bigint generated always as identity primary key,
  asset_id uuid not null references public.assets(id) on delete cascade,
  observed_at timestamptz not null,
  circulating_supply numeric,
  total_supply numeric,
  max_supply numeric,
  market_cap numeric,
  fdv numeric,
  unlocks jsonb not null default '[]'::jsonb,
  emissions jsonb not null default '{}'::jsonb,
  burns_buybacks jsonb not null default '{}'::jsonb,
  holder_concentration jsonb not null default '{}'::jsonb,
  source text,
  unique(asset_id, observed_at)
);

create table if not exists public.portfolio_positions (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id),
  quantity numeric not null default 0,
  average_cost numeric,
  core_quantity numeric not null default 0,
  tactical_quantity numeric not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.trades (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id),
  executed_at timestamptz not null,
  side text not null check (side in ('BUY','SELL')),
  quantity numeric not null,
  price numeric not null,
  fees numeric not null default 0,
  strategy_bucket text check (strategy_bucket in ('CORE','TACTICAL')),
  signal_id uuid references public.signals(id),
  notes text
);

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references public.assets(id),
  signal_id uuid references public.signals(id),
  created_at timestamptz not null default now(),
  severity text not null,
  alert_type text not null,
  message text not null,
  material boolean not null default false,
  delivered_at timestamptz,
  acted_on boolean,
  outcome jsonb not null default '{}'::jsonb
);

create table if not exists public.model_performance (
  id bigint generated always as identity primary key,
  asset_id uuid references public.assets(id),
  regime text,
  signal_family text not null,
  as_of timestamptz not null,
  sample_size integer not null default 0,
  precision_estimate numeric,
  mean_return numeric,
  mean_mfe numeric,
  mean_mae numeric,
  weight numeric not null default 0,
  out_of_sample boolean not null default false,
  statistics jsonb not null default '{}'::jsonb,
  unique(asset_id, regime, signal_family, as_of)
);

insert into public.assets(symbol,name,network,identity_status,role) values
('XRP','XRP','XRPL','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('JASMY','JasmyCoin','Ethereum','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('XCN','Onyxcoin',null,'NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('VERI','Veritaseum','Ethereum','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('DRGN','Dragonchain','Dragonchain','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('SUPRA','Supra','Supra L1','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('BSV','Bitcoin SV','Bitcoin SV','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('ZBCN','Zebec Network',null,'NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('SHX','Stronghold Token','Stellar','NEEDS_PRIMARY_VERIFICATION','PORTFOLIO'),
('BTC','Bitcoin','Bitcoin','BENCHMARK','BENCHMARK'),
('ETH','Ethereum','Ethereum','BENCHMARK','BENCHMARK'),
('USDC','USD Coin',null,'BENCHMARK','BENCHMARK')
on conflict(symbol) do nothing;

-- PRE and VELO intentionally excluded from this command universe.
