# Lending Club Consumer Loan Pricing & Credit Risk Model

**Tools:** MySQL · SAS · Microsoft Excel
**Data:** 1,306,081 closed Lending Club loans (2007–2018)

## Problem

Lending Club, like any consumer lender, prices loans by risk grade rather than by
individual borrower risk. The question this project asks: **does grade-level pricing
actually cover expected loss, and where does it break down?** The answer matters
differently depending on who's holding the loan — Lending Club transfers default risk
to investors at origination and earns fees regardless of loan performance, but a
balance-sheet lender (a bank like Santander, a credit union, an auto finance company)
keeps the loss and needs rates that cover it. This project builds the pricing
framework a balance-sheet lender would need and uses it to test whether Lending
Club's own rates would hold up under that standard.

## Approach

1. **Data extraction & cleaning (MySQL).** Pulled loan-level records for closed loans
   only (`Fully Paid`, `Charged Off`, `Default`, and their "does not meet credit
   policy" variants), excluding loans still `Current` since they have no resolved
   outcome yet. Resolved three data quality issues before modeling: 476 outlier DTI
   values above 100 (replaced with the median, 17.6), invalid income records under
   $5,000 (replaced with median), and revolving utilization above 100% (replaced with
   median).
2. **Default prediction (SAS).** Built a logistic regression predicting `default_flag`
   from credit risk signals (grade, DTI, delinquencies, inquiries, public records,
   revolving utilization), customer behavior (employment length, income, verification
   status), and loan purpose — deliberately built without FICO score, which isn't in
   the public dataset (see Limitations).
3. **Loss estimation.** Calculated grade-level Loss Given Default empirically from
   actual recovery data (principal recovered + post-charge-off recoveries against
   funded amount), rather than assuming a flat LGD across grades. LGD ranges from
   53.3% (Grade A) to 76.5% (Grade G) — riskier grades don't just default more often,
   they also recover less when they do.
4. **Pricing framework (Excel).** Combined predicted default probability, grade-level
   LGD, a 0.719 empirically-derived EAD ratio, a 5% cost of funds assumption, and a 2%
   target profit margin into a breakeven and fair-rate calculation per grade. Compared
   fair rate to Lending Club's actual average rate per grade to flag over/underpricing,
   then applied the same logic loan-by-loan to flag individually mispriced loans
   (5-percentage-point threshold).

## Key Findings

- **Model concordance: 70.1%** (c-statistic = 0.701) across 1,306,081 loans, without
  FICO score — using grade, DTI, employment history, purpose, home ownership, and
  behavioral variables.
- **Grade B is the only tier priced above breakeven** (+0.14%). Every other grade
  falls below breakeven on a risk-adjusted basis, and the gap widens sharply in
  subprime tiers — Grade G sits 4.81 percentage points below breakeven despite a
  49.8% predicted default probability.
- **Lending Club's underpricing is structurally sustainable for Lending Club, not for
  a balance-sheet lender.** LC earns origination and servicing fees regardless of loan
  performance because default risk passes to investors at origination. A lender
  holding the loan directly doesn't get that pass-through and needs rates that
  actually cover expected loss.
- **43,168 loans (4.1% of the portfolio) are individually mispriced** relative to
  model-predicted risk, concentrated in subprime grades: 12.8% of Grade E, 16.6% of
  Grade F, and 18.7% of Grade G loans miss by more than 5 percentage points.
- **Loan purpose predicts default independently of grade, income, and DTI.**
  Educational loans default at 2.59x and small business loans at 2.39x the rate of
  wedding loans — purpose-adjusted pricing would likely improve portfolio performance.
- **Employment history matters more than tenure.** Having any employment history
  reduces default odds 39–44% regardless of length — the presence of a job history is
  the signal, not years on the job.
- **Mortgage holders default 29% less than renters**, controlling for other variables
  — likely some mix of collateral discipline and the selection effect of mortgage
  approval itself.
- **DTI is the second-strongest predictor** (Chi-Square 4,243) after grade (Chi-Square
  6,882). Each 1-point increase in DTI raises default odds by 1.8%.

### Grade-Level Pricing Framework

Assumptions: cost of funds 5.0%, profit margin 2.0%, EAD ratio 0.719 (empirically
derived). LGD calculated by grade from actual recovery data.

| Grade | Pred. Default Prob. | LGD | LC Avg Rate | Breakeven Rate | Fair Rate | Breakeven Gap | Status |
|---|---|---|---|---|---|---|---|
| A | 6.09% | 53.3% | 7.12% | 9.26% | 11.26% | -2.14% | Below Breakeven |
| B | 13.45% | 57.2% | 10.69% | 10.55% | 12.55% | +0.14% | Above Breakeven |
| C | 22.51% | 63.1% | 14.02% | 15.16% | 17.16% | -1.14% | Below Breakeven |
| D | 30.44% | 65.9% | 17.69% | 19.12% | 21.12% | -1.43% | Below Breakeven |
| E | 38.57% | 69.4% | 21.07% | 24.32% | 26.32% | -3.25% | Below Breakeven |
| F | 45.25% | 73.1% | 24.84% | 28.76% | 30.76% | -3.92% | Below Breakeven |
| G | 49.79% | 76.5% | 27.50% | 32.31% | 34.31% | -4.81% | Below Breakeven |

**Borrower risk archetypes** (from the model, illustrative of the predicted range):
- **Lowest risk (~1.5% predicted default probability):** Grade A1, mortgage holder,
  wedding or debt consolidation purpose, DTI under 2, zero delinquencies, credit
  history predating 2000, not income-verified, 36-month term.
- **Highest risk (~92% predicted default probability):** Grade F/G, renter, debt
  consolidation purpose, DTI above 70, no employment history on file, income under
  $25K, income verified, 60-month term.

## Tools Used

- **MySQL** — data extraction, default-flag construction, outlier cleaning
- **SAS** (`PROC LOGISTIC`, `PROC MEANS`, `PROC FREQ`) — default prediction model,
  grade-level summary statistics, LGD calculation
- **Microsoft Excel** — breakeven/fair-rate pricing framework, sensitivity analysis,
  grade overlay and mispricing flag

## Known Limitations

Being direct about what this model doesn't do, rather than burying it:

- **No train/test split.** The model was fit and evaluated on the same 1.3M loans.
  Concordance of 70.1% is an in-sample number; out-of-sample performance would likely
  be somewhat lower. In production this needs a held-out test set at minimum, ideally
  time-based (train on earlier vintages, test on later ones) given how default
  behavior can shift across the economic cycle.
- **No VIF / multicollinearity check.** Several predictors (DTI, revolving
  utilization, total accounts) are plausibly correlated with each other and with
  grade. I haven't formally checked variance inflation factors, so some coefficient
  estimates may be less stable than they look.
- **No calibration plots.** Concordance measures rank-ordering (does the model put
  higher-risk loans at higher predicted probability?) but says nothing about whether
  the predicted probabilities themselves are well-calibrated (does a 20% predicted
  default rate actually default 20% of the time?). That's a real gap for a pricing
  application specifically, since the pricing framework uses the predicted
  probabilities directly, not just their rank order.
- **Reject inference bias.** The model is trained only on approved borrowers, so it
  underrepresents the true risk distribution of the full applicant pool — anyone
  Lending Club rejected outright isn't in this data. Standard practitioner fixes
  (parceling, fuzzy augmentation) weren't applied here.
- **Constant EAD assumption.** Exposure at Default is proxied with a single
  portfolio-level ratio (0.719), not varied by loan term, grade, or time to default.
  The full expected-loss formula is PD × LGD × EAD, and only PD and LGD vary by grade
  in this version.
- **Overhead costs excluded.** Origination, servicing, and compliance costs
  typically add 1–2% to the true breakeven rate. They're excluded here because
  Lending Club's cost structure data isn't public, so the "fair rate" in this
  framework is a pre-overhead floor, not a fully loaded rate.
- **Cost of funds held flat at 5%**, regardless of loan term (36 vs. 60 months) or
  when in the 2007–2018 window the loan originated. A more realistic model would
  vary this by term and by prevailing market rates at origination.
- **No FICO score.** FICO is the industry-standard credit signal and isn't in the
  public Lending Club dataset. Grade partially proxies for it, but individual
  score-level variation within a grade is invisible to this model. Including FICO
  would likely push concordance above 70.1%.
- **Historical dataset.** Reflects the 2007–2018 lending environment, including the
  2008 financial crisis. Default rates and borrower behavior in the current
  environment may differ materially.
- **Mispricing threshold is a judgment call.** The 43,168-loan (4.1%) mispricing
  count uses a 5-percentage-point gap threshold between model-predicted fair rate and
  grade-implied rate. A 3-point threshold would flag meaningfully more loans as
  mispriced — the finding is directionally robust but the exact count is sensitive to
  where you draw that line.

## Repo Contents

- `code/data_extraction_cleaning.sql` — MySQL extraction, default-flag construction,
  outlier cleaning
- `code/loan_default_model.sas` — logistic regression, grade-level summary stats,
  LGD calculation
- `code/scored_loans_sample.csv` — 2,000-row sample of the loan-level scored output
  (predicted probability, fair rate, mispricing flag per loan). The full scored
  output covers all 1,306,081 loans; only a sample is included here to keep the repo
  a reasonable size.
- `pricing_framework.xlsx` — the breakeven/fair-rate pricing model (grade-level
  summary, cost-of-funds sensitivity table, and grade overlay/mispricing flag), with
  live formulas intact
