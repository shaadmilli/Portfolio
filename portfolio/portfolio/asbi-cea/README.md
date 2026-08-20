# Cost-Effectiveness Analysis of Alcohol Screening & Brief Intervention (ASBI)

**Tools:** Cost-effectiveness analysis framework (ICER/QALY costing);
literature-sourced parameter estimates
**Data:** Cost and outcome parameters synthesized from published ASBI cost
studies and clinical literature (Cochrane Collaboration, Fleming et al.,
Gentilello et al., Solberg et al., and others — see References)

## Problem

Excessive alcohol use drives over 140,000 deaths a year in the U.S. and
roughly $249B in healthcare, productivity, and other costs. Alcohol
Screening and Brief Intervention (ASBI) — a short primary-care screening
followed by a motivational conversation — is a well-evidenced way to
reduce it. The open question for a health system deciding how to
implement it: **should ASBI be delivered by primary care providers (PCPs)
already in the room, or by dedicated specialist interventionist staff?**
Specialists may deliver marginally better outcomes, but at meaningfully
higher cost — this analysis quantifies whether that trade-off is worth
it, from a healthcare-system cost perspective.

## Approach

**Cost analysis.** Built a per-patient cost estimate for ASBI delivery by
summing every resource component: screening tool cost, nurse time for
both the screening (~5 min) and brief intervention (~15 min) steps,
counseling materials, training costs (amortized over an estimated 50
patients), and administrative/monitoring overhead. Cost inputs were
drawn from standard wage data and published ASBI cost studies rather than
site-specific data collection.

**Health outcomes.** Used a mix of short- and long-term outcome measures:
weekly alcohol consumption (drinks/week) and alcohol-related ER visits
per 1,000 patients at 12-month follow-up as short-term, directly-observed
effects; QALYs gained as the primary long-term outcome, with legal
incidents avoided and productive workdays gained tracked as additional
long-term outcomes capturing broader social benefit.

**Incremental Cost-Effectiveness Ratio (ICER).** Compared three
treatment arms — no ASBI, PCP-delivered ASBI, and specialist-delivered
ASBI — using a healthcare system perspective (program cost only;
productivity savings are not monetized into the ICER numerator — see
Limitations). ICER was calculated separately for the short-term outcome
(cost per additional drink/week reduced) and the long-term outcome (cost
per QALY gained), with each comparison checked for dominance — whether
one option delivers equal or worse outcomes at higher cost, which rules
it out regardless of willingness to pay.

**Sensitivity analysis.** Ran a one-way deterministic sensitivity
analysis lowering the specialist arm's labor cost to match the (lower)
PCP wage, holding every other input constant, to isolate how much of the
specialist model's cost disadvantage comes from labor cost specifically
versus other inputs.

## Key Findings

### Cost per patient: PCP $29 vs. Specialist $52

Staff time is the largest single cost component — screening (~5 min)
plus brief intervention (~15 min) at $30/hour works out to $10/patient
in nurse time alone. Training, amortized across an estimated 50 patients,
adds another $10/patient; the remaining $9/patient covers screening
tools, counseling materials, admin setup, and monitoring/evaluation.

| Resource | Amount Used | Unit Cost | Cost Per Patient |
|---|---|---|---|
| Screening tools | 1 per patient | $1.00 | $1.00 |
| Nurse time — screening | 5 min/patient | $30/hr | $2.50 |
| Nurse time — intervention | 15 min/patient | $30/hr | $7.50 |
| Counseling materials | 1 per patient | $1.00 | $1.00 |
| Training (amortized) | spread over 50 patients | — | $10.00 |
| Admin & setup | spread over patients | — | $5.00 |
| Monitoring & evaluation | spread over patients | — | $2.00 |
| **Total cost per patient** | | | **$29.00** |

### Short-term CEA (cost per drink/week reduced)

| Option | Cost | Weekly Drinks | ER Visits/1,000 | Incr. Cost | Incr. Drinks Reduced | ICER |
|---|---|---|---|---|---|---|
| No ASBI (control) | $0 | 14.7 | 65 | — | — | — |
| ASBI by PCP | $29 | 10.2 | 45 | $29 | 4.5 | **$6.44** |
| ASBI by Specialist | $52 | 10.0 | 43 | $23 | 0.2 | **$115** |

The specialist model isn't strictly dominated here — it does deliver a
slightly larger reduction (0.2 more drinks/week, plus 2 more ER visits
avoided per 1,000) — but at $115 per incremental drink reduced versus
$6.44 for PCP, that extra benefit comes at a steep premium.

### Long-term CEA (cost per QALY gained)

| Option | Cost | QALYs | Legal Incidents Avoided/1,000 | Prod. Days | Incr. Cost | Incr. QALYs | ICER ($/QALY) |
|---|---|---|---|---|---|---|---|
| No ASBI | $0 | 0 | 0 | 0 | — | — | — |
| ASBI by PCP | $29 | 0.13 | 12 | 3.5 | $29 | 0.13 | **$223.08** |
| ASBI by Specialist | $52 | 0.13 | 12 | 3.5 | $23 | 0 | **∞ (dominated)** |

This is the decisive result. On the long-term QALY outcome, the
specialist model produces **zero incremental QALY gain over PCP** while
costing $23 more per patient — strictly dominated. PCP-delivered ASBI,
at $223.08 per QALY gained, sits far below the conventional U.S.
cost-effectiveness threshold of $50,000/QALY — and is even below the
$8,700/QALY benchmark reported for ASBI generally in Solberg et al.
(2008) — making it a clearly cost-effective intervention on its own
terms.

### Sensitivity analysis

When the specialist wage is lowered to match the PCP wage (isolating
labor cost as the driver of the cost gap), the specialist arm's
incremental cost narrows substantially while health outcomes stay
unchanged. The specialist model's ICER improves enough that it's no
longer dominated and becomes competitive at higher willingness-to-pay
thresholds. This says the specialist model's disadvantage is largely a
*labor cost* problem, not an *effectiveness* problem — which points
toward a practical recommendation (mid-level providers, reduced training
cost) rather than ruling out specialist delivery outright.

### Bottom line

PCP-delivered ASBI is the preferred model in both the short- and
long-term analysis: cheaper, dominates the specialist model on QALYs,
and clears the standard cost-effectiveness bar by a wide margin. The
specialist model has some merit (marginally better ER-visit and
drink-reduction outcomes) but doesn't justify its added cost under
either analysis as currently priced.

## Tools Used

- Cost-effectiveness analysis framework: per-patient micro-costing,
  ICER calculation, dominance testing, one-way deterministic sensitivity
  analysis
- Literature synthesis for outcome parameters (Cochrane Collaboration
  systematic review; Fleming et al. 2000/2002; Gentilello et al. 1999,
  2005; Solberg et al. 2008; Estee et al. 2010; Jonas et al. 2012;
  Moyer et al. 2002 — full list in the write-up)

## Known Limitations

Being upfront about what this analysis doesn't do — as stated directly
in the original write-up:

- **Outcome estimates are derived from published literature rather than
  site-specific data.** Cost and outcome inputs (wage rates, screening
  time, effect sizes) come from prior studies and industry norms rather
  than data collected at a specific clinic, which may affect
  generalizability to any particular real-world implementation.
- **QALYs are treated as static values.** The 0.13 QALY gain used for
  both PCP and specialist arms doesn't capture patient-level variation in
  health status or treatment response.
- **Assumes full protocol adherence.** The model assumes ASBI is
  delivered consistently per guidelines, which may not be consistently
  achieved in practice.
- **Productivity savings are not monetized into the ICER.** The analysis
  uses a healthcare-system perspective and doesn't include productivity
  offsets in the cost numerator. Including them — the literature review
  cites $3.80–$5.60 in downstream savings per $1 spent on ASBI broadly —
  would likely improve the economic case for both delivery models, and
  could shift the PCP-vs-specialist comparison once priced in and
  attributed correctly by arm.
- **No probabilistic sensitivity analysis.** The sensitivity check here
  is a single one-way deterministic test on labor cost. A full
  probabilistic sensitivity analysis — varying all key parameters
  simultaneously across plausible ranges — would give a more complete
  picture of how robust the PCP-preferred conclusion is to joint
  parameter uncertainty.
- **Effect-size estimates come from disparate source studies, not one
  consistent trial.** Individual effect sizes (weekly drinks, ER visit
  reduction, QALY gain, legal incidents) are drawn from different
  studies with different populations, settings, and follow-up windows.
  Treating them as if they describe one cohort is standard practice in
  this kind of evidence synthesis, but the numbers aren't all internally
  validated against each other.

## Repo Contents

This project is a written cost-effectiveness analysis rather than a
coded model — there's no accompanying code or spreadsheet file, only the
write-up itself. If a spreadsheet version of the cost/ICER calculations
gets built out later, it would be added here alongside the README.
