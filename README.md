# Alpha Command prototype — inactive

**Do not deploy, migrate or schedule this repository.** The active Lovable-synced Velox Insights application is [PawSketch/conviction-dashboard](https://github.com/PawSketch/conviction-dashboard). Its existing Supabase asset registry and tables are the source of truth. Michelle has chosen not to use this separate implementation.

This repository is retained as an historical prototype so its research and code can be reviewed, but its schema is incompatible with the existing Velox database. Do not apply either migration to the Velox Supabase project, set a service-role key here, or run its CCXT ingestion script. [Issue #1](https://github.com/PawSketch/Alpha-Command/issues/1) records the conflicts. Future early-warning work belongs in the active Velox repository after reconciliation.

## Prototype contents

- Separate Supabase/Postgres schema and asset identity registry
- CCXT discovery/ingestion sketch
- SQL feature and candidate radar views
- State, evidence, signal outcome and portfolio table designs

These files are **not** a live feed, a validated pre-move model or a production integration. VELO always means Velo Protocol in the active Velox app; this prototype intentionally excluded it.
