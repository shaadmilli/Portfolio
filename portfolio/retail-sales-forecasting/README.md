# Retail Sales Forecasting — STL Decomposition & ETS Modeling

**Tools:** R (fpp2, forecast, readxl, dplyr, zoo, urca, seasonal)
**Data:** 48 months of point-of-sale data (Jan 2020–Dec 2023), furniture/antique
retailer, Atlanta, GA

## Problem

Forecast 12 months of sales (Jan–Dec 2024) for a small furniture and antique
retailer using historical POS data, in a series short enough (48 months) and
disrupted enough (COVID-affected 2020) that model selection has to earn its
way past a naive benchmark rather than being assumed.

## Approach

**Data prep.** The raw series had missing observations recorded as zeros.
Interpolation (`na.approx()`) was tried first but rejected — many missing
values were clustered consecutively, which would have anchored imputed
values near zero and distorted the series level. Mean imputation was used
instead (see Limitations for why median would likely have been better).
The series was partitioned into training (Jan 2020–Dec 2022) and a held-out
test set (Jan 2023–Dec 2023, roughly the final 25% of the sample) sized to
match the 12-month forecast horizon.

**Model evaluation.** Rather than picking a model family up front, 60+
specifications were evaluated across six families, with test-set MAPE as
the primary selection criterion and forecast plausibility as a hard filter:

| Model Family | Specifications Tested | Outcome |
|---|---|---|
| Benchmark | 4 (mean, naïve, seasonal naïve, drift) | Mean method had the best benchmark MAPE |
| Exponential Smoothing | 4 (auto ETS, SES, Holt Linear, Holt-Winters) | Auto ETS near-identical to the mean forecast |
| ARIMA | 15 manual + auto.arima | Top 3 reported; mixed test-set performance |
| Time Series Regression | 2 (trend+season, trend only) | Competitive but not selected |
| STL Decomposition | 4 methods + 34-model grid search | STLF-ETS most promising |
| Neural Networks (NNAR) | 5 specifications | Eliminated — implausible forecasts |
| Combination forecasts | 3 combinations | Plausibility concerns carried through |
| **STL-ETS (selected)** | t.window=1, s.window=7, lambda=0, biasadj=TRUE | **Best accuracy + plausible forecast** |

The interesting result at the benchmark stage: the flat-line mean method beat
seasonal naïve on the test set, even though seasonal naïve fit the *training*
set best — a reminder that in-sample fit and out-of-sample accuracy aren't the
same thing, which framed how the rest of the model comparison was read.

**Why NNAR was cut despite good numbers.** Several neural network
specifications posted competitive test-set MAPE — in some cases better than
the eventual winner. They were eliminated anyway: every NNAR forecast curved
sharply toward zero over the 12-month horizon, which isn't a plausible
outcome for an operating business. Accuracy on a backward-looking test
window doesn't guarantee a sane forward-looking shape, and a model that fails
the sanity check on its output isn't one you hand to a business owner,
regardless of its MAPE.

## Selected Model

**STL decomposition + ETS(M,N,N)**, estimated on the full series:
- `t.window = 1` — rapid trend-cycle window, tracks short-term directional shifts
- `s.window = 7` — 7-month cycle window for the seasonal component
- `lambda = 0` — log transformation, enforcing non-negative forecasts
- `biasadj = TRUE` — corrects the systematic downward bias introduced by
  back-transforming from the log scale
- ETS(M,N,N) applied to the seasonally-adjusted remainder (multiplicative
  error, no trend, no seasonality in the remainder itself — the trend and
  seasonality are already handled by STL)

## Key Findings

- The selected STL-ETS specification beat every benchmark on test-set
  accuracy while producing a forecast shape consistent with the store's
  actual seasonal pattern — sales concentrated later in the year, in line
  with historical behavior outside the COVID-disrupted 2020 window.
- Prediction intervals are wide. That's an honest reflection of the
  uncertainty in a short, disrupted series, not a modeling flaw to paper
  over.
- Fitted values smoothed out outliers in the historical series, which was
  one of the explicit goals of the decomposition approach.
- Forecast risk factors identified for monitoring: unexpected economic
  downturns, another disruption affecting foot traffic/travel patterns, or
  competitors entering/exiting the local market. If new observations start
  showing large negative forecast errors, the model should be re-evaluated
  against the alternatives rather than assumed to still be correct.

## Tools Used

- **R** — `fpp2`, `forecast` (STL, ETS, ARIMA, NNAR, accuracy metrics),
  `readxl` (data import), `dplyr`, `zoo` (`na.approx` for the imputation
  approach that was tried and rejected), `urca` (KPSS stationarity testing
  for ARIMA identification), `seasonal`

## Known Limitations

- **Small sample.** 48 months of data, further reduced in effective signal
  by COVID disruption in 2020, limits how much statistical power is
  available to pin down stable seasonal and trend parameters.
- **Mean imputation was likely the wrong choice.** Missing values were
  filled with the series mean rather than the median. Given the outliers
  present in the series, median imputation would probably have produced
  better-calibrated estimates — flagging this rather than hiding it.
- **NNAR exclusion is a judgment call, not a proof.** The neural network
  models were eliminated on forecast-plausibility grounds despite
  competitive accuracy scores. With more data, they may warrant
  re-evaluation — the exclusion reflects a reasonable prior about business
  sales not trending to zero, not a definitive finding that NNAR is wrong
  for this series.
- **No explanatory variables.** The model is univariate — it uses only the
  sales series itself. Local foot traffic, marketing spend, or
  macroeconomic indicators could plausibly improve accuracy but weren't
  incorporated.
- **External validity.** The forecast assumes no structural change in local
  competitive conditions, the macro environment, or consumer behavior over
  the forecast horizon. It's a projection of the recent past, not a
  scenario analysis.

## Repo Contents

- `code/forecast_model_selection.R` — full model-selection script covering
  all six model families and 60+ specifications, ending with the final
  fitted STL-ETS model
