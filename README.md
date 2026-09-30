# Alpha Command

Backend intelligence and research architecture for Velox Insights Portfolio Alpha Command.

## Current build
- Supabase/Postgres schema for persistent market intelligence
- asset identity registry
- market observations and feature snapshots
- 9-state cycle history
- Pre-Move Radar signals
- multi-horizon signal outcome scoring
- historical precursor event library
- research/evidence and tokenomics snapshots
- portfolio/trade/alert records
- per-asset/regime model performance

See `docs/PORTFOLIO_ALPHA_COMMAND_ARCHITECTURE.md` and `supabase/migrations/20260930_portfolio_alpha_command.sql`.

## Safety/data rule
Asset rows begin as NEEDS_PRIMARY_VERIFICATION. Do not ingest ambiguous ticker data until exact project/network/contract identity is verified. PRE and VELO are intentionally outside this command universe.
