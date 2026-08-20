# Grocery Store Chain — Profitability Analytics (Power BI)

**Tools:** Microsoft Power BI (dashboard, treemap, and bar-chart visuals; DAX
measures for profit/margin calculations)
**Data:** Transaction-level grocery chain sales data — $781,404 in total
sales, $96,601 in profit (~12% margin), 414K+ customers

## Problem

The company is profitable overall, but a flat 12% margin doesn't say where
that profit is actually coming from — or where it's being left on the
table. This is a descriptive analytics project: rather than predicting an
outcome, the goal is to break down profitability across product category,
promotions, brand, store, and day of week to find concentration and
inefficiency that a single top-line number hides.

## Approach

Built a Power BI dashboard using treemap and bar-chart visuals to
decompose total profit ($96,601) across five dimensions:

1. **Product category** — profit contribution by category (Food/Supplies/
   Drinks), to see whether category mix drives profitability more than
   volume does.
2. **Promotions** — total sales vs. total profit by named promotion, to
   separate promotions that move volume from promotions that also protect
   margin.
3. **Store** — profit margin by individual store location, to see how
   much of the margin spread is explainable by store-level operational
   differences rather than product mix alone.
4. **Brand** — profit margin by brand, distinct from total profit
   dollars, since a brand can carry a high margin on relatively low
   volume or vice versa.
5. **Day of week** — total profit by day, to check whether demand (and
   therefore profit) is evenly distributed across the week.

## Key Findings

- **Food drives the majority of profit.** Food products generated ~$60K
  in profit versus $19K from Supplies and $17K from Drinks — food alone
  accounts for roughly 63% of total company profit despite being one of
  three categories. Product mix, not just sales volume, is doing most of
  the work here.
- **Promotional effectiveness varies enormously — and some promotions
  actively lose money.** POS Grabbers (~$9,717 profit) and Shelf Talkers
  (~$9,689 profit) were the top-performing promotions. At the other end,
  Red Carpet Closeout lost about $6,014 and Big Promo lost about $2,758 —
  meaning some promotions rely on discounting deep enough to increase
  sales volume while destroying margin on every unit sold.
- **Store-level profit varies by about 34%.** The most profitable store
  generated $5,726 in profit versus $4,276 at the lowest-performing
  store. Since this is the same chain running the same core product mix,
  that spread points to operational differences (layout, execution,
  promotion discipline) rather than anything structural about a specific
  location.
- **Brand profitability separates by margin, not just volume.** By
  margin, Chewy Industries and Squeezable Inc lead the brand ranking. By
  absolute profit dollars, Squeezable Inc ($19.5K), Frozen Bird ($15K),
  Cold Gourmet ($13.8K), and Western Vegetable ($13.7K) are the top
  contributors — together the top brands account for a large share of
  total company profit. The two rankings (margin vs. dollar contribution)
  don't fully overlap, which matters for deciding whether to push shelf
  space toward high-margin brands or high-volume ones.
- **Demand is heavily weekend-weighted.** Saturday generates roughly
  double the profit of any weekday, while Tuesday is the weakest day by a
  wide margin. Customer demand — and therefore profit opportunity — isn't
  evenly distributed across the week.

## Recommendations (from the analysis)

1. Increase promotional emphasis and shelf visibility for food products,
   the category already driving the majority of profit.
2. Prioritize promotions that grow both sales and margin; redesign or cut
   promotions (like Red Carpet Closeout and Big Promo) that consistently
   post losses.
3. Study the operating practices at top-performing stores and standardize
   them across lower-performing locations.
4. Give high-margin brands more shelf space and dedicated promotional
   support, without leaning on price cuts that erode the margin advantage
   those brands already have.
5. Schedule targeted promotions on low-profit days (Tuesday in
   particular) to smooth demand across the week rather than concentrating
   it on weekends.

## Tools Used

- **Power BI** — treemap (profit by category), bar charts (promotion
  sales vs. profit, profit margin by store, profit margin by brand,
  profit by day), DAX measures for total profit and profit margin

## Known Limitations

- **Descriptive, not predictive.** This project identifies where profit
  concentrates today; it doesn't forecast future performance or test
  whether the recommended changes (more food promotion, reallocated shelf
  space) would actually produce the profit gains implied. That would
  require a follow-on experiment or model, not just the dashboard.
- **Correlation, not causation, on store and promotion differences.** The
  34% store-to-store profit spread and the promotion win/loss pattern are
  observed associations. Neither analysis controls for confounding
  factors — a promotion's poor performance could reflect what it was
  paired with or when it ran, not the promotion mechanic itself; a
  store's underperformance could reflect its local market rather than its
  operations. The recommendations (standardize best practices, redesign
  losing promotions) are reasonable next steps to test, not conclusions
  already proven by this data.
- **No statistical testing.** Comparisons (which promotions "work," which
  stores outperform) are based on raw totals and margins, not confidence
  intervals or significance tests. With promotion-level and store-level
  sample sizes potentially fairly different in size, some of the smaller
  gaps shown here may not be reliably distinguishable from noise.
- **Brand margin vs. dollar-profit ranking isn't fully reconciled in the
  dashboard.** The brand chart ranks by profit margin, while the
  narrative also cites brands by absolute profit dollars — worth being
  explicit that these are two different orderings when presenting this
  project, since they don't produce identical top brands.

## Repo Contents

- `gsc_dashboard.pbix` — the Power BI dashboard file (treemap, bar
  charts, and underlying data model). Open in Power BI Desktop to
  interact with the visuals directly.
