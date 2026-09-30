# Velox Insights / Portfolio Alpha Command

## Mission
Persistent, evidence-led quantamental intelligence for XRP, JASMY, XCN (Onyxcoin), VERI, original Dragonchain DRGN, SUPRA, BSV, ZBCN and SHX. BTC, ETH and USDC are benchmarks/opportunity-cost alternatives. PRE is excluded. VELO Protocol is handled by the separate VELO Bull-Run Command.

## System architecture
Data sources -> identity gate -> ingestion -> Supabase raw observations -> feature engine -> Pre-Move Radar -> per-asset 9-state cycle engine -> signal/action engine -> cross-asset opportunity engine -> alerts -> Lovable UI.

GitHub owns versioned analytics/migrations. Supabase is persistent memory. Lovable is presentation/control, not the source of truth.

## Identity gate
No market/on-chain/fundamental datum enters an asset model until identity is verified using primary evidence. Store network/contract/project identifiers and evidence. Reject ticker collisions and migrations until resolved.

## Pre-Move Radar
Permanent stages:
WATCH -> PRE_MOVE -> TRIGGER_ARMING -> BREAKOUT_CONFIRMATION -> EXPANSION -> EXHAUSTION_DISTRIBUTION.

The radar must detect conditions before obvious price expansion rather than merely describe a move after it occurs. Candidate independent signal families include:
- structure/compression and volatility regime
- volume/participation and OBV/CMF/MFI
- relative strength vs BTC/ETH
- spot/order-flow/microstructure when reliable
- derivatives positioning when reliable
- on-chain/capital flows
- catalyst/attention acceleration
- macro/liquidity regime
- supply/tokenomics/value capture

Correlated indicators are clustered so repeated variants of the same information do not create false confirmation.

## Nine-state market-cycle engine
ACCUMULATION_BASE; EARLY_BULL_CONFIRMATION; EXPANSION_TREND_RIDE; EUPHORIA_DISTRIBUTION_WATCH; DISTRIBUTION_CYCLE_EXIT; EARLY_BEAR_CAPITAL_PRESERVATION; CAPITULATION; BEAR_BASE_REACCUMULATION; THESIS_FAILURE.

Transitions require multi-factor evidence. Every transition stores evidence for, evidence against, confidence and limitations.

## Learning loop
Every meaningful signal is immutable/timestamped. Outcomes are scored at 1h, 6h, 24h, 3d, 7d, 14d and 30d with return, MFE, MAE, volatility, confirmation and invalidation. False positives, false negatives and missed moves remain in the dataset.

For major +20/+30/+50/+100% rallies, failed breakouts, tops, crashes and capitulations, freeze the preceding 30d/14d/7d/3d/24h/6h/1h feature snapshots. Compare them with failed/non-event controls. Recalibrate weights only with sufficient evidence and walk-forward/out-of-sample validation.

## Composite signal families
Technical Structure; Momentum; Volume/Order Flow; Derivatives; Relative Strength/Breadth; On-chain/Capital Flow; Fundamentals/Value Capture; Macro/Liquidity; Sentiment/Catalysts; Supply/Tokenomics; Liquidity/Execution Risk; Thesis Risk; Experimental Astro/Lunar.

Experimental astro/lunar/calendar features remain separately visible and carry zero/near-zero decision weight unless robust incremental predictive value survives controls, multiple-testing correction and out-of-sample validation.

## Action states
ACCUMULATE; HOLD CORE; ADD ON RETEST; BREAKOUT CONFIRMED; LET WINNER RUN; TACTICAL SELL; REBUY WINDOW; TAKE 5-10% PROFIT; DISTRIBUTION WARNING; CAPITAL PRESERVATION; BEAR REACCUMULATE; EXIT THESIS.

Every action must carry timeframe, levels/conditions, portion implicated, confirmation, invalidation, liquidity/slippage assessment, strongest contrary evidence, confidence and limitations.

## Tactical pool
Never risk the full strategic core on tactical sell/rebuy. Thresholds are asset-specific and volatility/ATR-aware. Track whether tactical trading increases or decreases token count and realised wealth after fees/slippage.

## Evidence taxonomy
VERIFIED FACT; INFERENCE; ESTIMATE; SPECULATION; INSUFFICIENT EVIDENCE; CONFLICTING SOURCES; IDENTITY UNRESOLVED; LIQUIDITY TOO POOR; EXPERIMENTAL.

## Initial labelled cases
SHX: preserve the exhaustion-warning/retest sequence as an early/false-warning learning case rather than deleting the warning after price strength returns.

ZBCN: preserve the observed base/compression -> initial expansion -> acceleration -> pullback sequence as a precursor case, together with controls and subsequent outcomes. Historical observations from chat are hypotheses until independently sourced and timestamped in the database; do not insert them as verified market data merely from conversation text.

## Build order
1. Apply Supabase migration.
2. Verify all asset identities/contracts/networks from primary sources.
3. Add market-data ingestion (CCXT where supported plus asset-specific fallbacks).
4. Build canonical OHLCV and data-quality layer.
5. Calculate technical/RS/volatility features.
6. Implement state machine and Pre-Move Radar.
7. Add immutable signals and automatic horizon outcome scoring.
8. Add fundamentals/on-chain/tokenomics/evidence collectors.
9. Add order flow/derivatives only where source quality supports it.
10. Build cross-asset opportunity engine including BTC/ETH/USDC.
11. Connect Lovable to read the resulting Supabase views/API.
12. Add material-change alerts.

## Non-negotiable design rule
Do not optimize for explaining yesterday. Optimize for timestamped, testable information available before a move, and preserve every failure so apparent edge cannot be manufactured by hindsight.
