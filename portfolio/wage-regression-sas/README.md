# Education & Earned Income — A Regression Analysis Using CPS Data

**Tools:** SAS (SAS Studio, ODA)
**Data:** Annual Social and Economic Supplement to the March Current Population
Survey (CPS), U.S. Census Bureau — 17,292 person-level observations

## Problem

Does educational attainment predict earned income, and how much of that
relationship survives once demographic, health, marital status, and
geographic controls are added? A secondary question the project design
forces you to confront: CPS imputes a meaningful share of its earnings and
demographic fields — does that imputation distort the education-earnings
relationship, or can it be trusted?

## Approach

**Data construction (SAS).** Started from 38 raw CPS fields and built out
to 92 analysis variables. Key constructed variables: six mutually
exclusive education dummies from `A_HGA` (less than high school through
professional/doctoral degree), an ordinal education category, earned
income and derived hourly wage, citizenship, marital status, race/
ethnicity (with Hispanic identification taking precedence over race
categories), poor health status, and two imputation flags (`miss_earn`,
`miss_demo`) marking whether earnings or demographic fields were
allocated by the Census Bureau rather than directly reported.

**Data merging.** Three CPS files were merged to build the final analysis
dataset: the person-level sample, a household-level file (for geographic
region), and a supplemental file merged on unique person ID. State-level
median income was calculated via `PROC MEANS` grouped by FIPS code and
merged back onto the person-level file.

**Three regression models, run to test robustness to imputation:**
1. **Simple OLS** — earned income on years of education alone (centered
   at 12 years).
2. **Multiple regression, non-allocated sample** (`miss_demo = 0`,
   n = 11,441) — adds education dummies, age, sex, citizenship, health,
   race/ethnicity, marital status, and region.
3. **Multiple regression, allocated sample** (`miss_demo = 1`,
   n = 5,851) — identical specification, run on the subsample where
   demographic data was imputed, to check whether the relationship holds
   up in imputed records.

## Key Findings

- **Earnings rise monotonically with education**, both descriptively and
  in the regression: from a mean of $31,126 (less than high school) to
  $111,457 (professional/doctoral degree).
- **Simple regression: R² = 0.164.** Years of education alone (centered at
  12) explains 16.4% of the variance in earned income, with each
  additional year beyond high school associated with $6,607 in additional
  annual earnings (p < 0.0001).
- **Full model: R² = 0.312** (F = 259.11, p < 0.0001) in the non-allocated
  sample — controls for demographics, health, marital status, and region
  nearly double the explained variance. A joint F-test on the five
  education dummies is highly significant (F = 454.25, p < 0.0001).
- **Education coefficients are stable across the allocated and
  non-allocated samples** — consistent sign, magnitude, and significance
  in both, suggesting CPS imputation doesn't meaningfully distort the
  core education-earnings relationship.
- **Other coefficients are not as stable.** Regional effects that are
  significant in the non-allocated sample (northeast +$4,968, west
  +$4,813 vs. south, both p < 0.0001) lose significance entirely in the
  allocated sample, and the gender earnings gap shrinks from $25,215 to
  $20,067. This instability outside of education — not the education
  estimates themselves — is why Model 2 (non-allocated) is the preferred
  specification.
- **Notable control coefficients (Model 2):** female workers earn $25,215
  less than male workers holding everything else constant (p < 0.0001);
  poor health is associated with $10,274 less in earnings (p < 0.0001);
  citizens earn $4,599 more than non-citizens (p = 0.002); married
  individuals earn $7,087 more than single individuals (p < 0.0001).

## Tools Used

- **SAS** — `PROC MEANS`, `PROC FREQ`, `PROC SGPLOT`/`PROC SGPANEL`
  (distribution and descriptive visualization), `PROC REG` (all three
  regression models), `PROC FORMAT` (education category labeling), data
  step variable construction and multi-file merging

## Known Limitations

- **Cross-sectional data, not causal.** The models don't account for
  unobserved individual characteristics — ability, family background,
  field of study — that plausibly confound the education-earnings
  relationship. The education coefficients should be read as conditional
  associations, not causal effects.
- **Earned income is top-coded in the CPS.** The observed maximum is
  $296,000, which caps the model's ability to capture earnings at the
  top of the distribution — a meaningful constraint given how much of the
  labor-earnings variance concentrates there.
- **Hourly wage relies on self-reported hours.** It's derived from
  self-reported weekly hours and weeks worked, both subject to
  measurement error that isn't corrected for.
- **23% of the sample had both earnings and demographic data allocated**,
  and while the education coefficients proved robust to this, other
  coefficients (region, gender gap) were sensitive to whether a record
  was directly reported or imputed — a reason to prefer Model 2, not a
  problem this analysis fully resolves.
- **No selection correction.** The model doesn't account for selection
  into education or into the labor market itself (people who choose not
  to work aren't in the earned-income sample at all), which limits how
  far the coefficients can be pushed as a description of the returns to
  education broadly.

## Repo Contents

- `code/data_preparation.sas` — variable construction and multi-file
  merging (person, household, supplemental CPS files) into the final
  17,292-observation, 92-variable analysis dataset
- `code/analysis_and_regression.sas` — descriptive statistics,
  distribution visualizations, and all three regression models
