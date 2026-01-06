# 📊 LemFi — Product Analytics Case Study

## Objective

The goal of this analysis is to evaluate LemFi’s customer lifecycle performance across **acquisition, activation, retention, monetization, and unit economics**, using transactional and user-level data.

Given time constraints, the focus is on:
- Identifying **key drivers of growth and efficiency**
- Assessing whether **customer acquisition costs are recovered**
- Highlighting **opportunities and risks** to inform future product and growth decisions

This analysis is intended as an **exploratory, decision-oriented exercise**, not as a final production-grade financial model.

---

## Data Coverage & Scope

- The dataset includes **transactions from customers acquired between January and June 2021**.
- Transaction activity is observed beyond the acquisition window to analyze **retention and monetization over time**.
- All analyses are cohort-based, anchored on **user registration date**.

---

## Data Cleaning & Assumptions

### Key Definitions

- **Active user**: A user with at least one successful transaction.
- **Activation rate**: Share of registered users who completed at least one successful transaction.
- **Retention**:
  - *Bounded retention*: Activity within defined time brackets since registration.
  - *Unbounded retention*: Share of users remaining active at least once up to a given day since registration.

### Data Treatment & Limitations

- **Transaction status normalization**  
  Multiple successful status labels (e.g. `SUCCESSFUL`, `TRANSFER-SUCCESSFUL`) were grouped into a single `SUCCESS` category to ensure consistent activation and revenue definitions. A deeper investigation of edge cases was considered out of scope.

- **Duplicate transactions**  
  Potential duplicates were detected (identical values across all columns except `transaction_id`). These records were retained but flagged as a data-quality risk.

- **Acquisition costs**  
  Acquisition cost values appear to be stored in absolute units rather than millions. Calculations assume costs are correctly scaled.

- **User status fields**  
  `is_verified` and `is_blocked` fields were not used, as they represent the latest user state only and lack historical timestamps, making longitudinal analysis unreliable.

- **Missing values**  
  Users with null values in the `Default Transfer` field were excluded from aggregation metrics where relevant.

- **Out-of-scope records**  
  One isolated transaction with origin country = United States was excluded, as it does not align with LemFi’s core corridors and is likely a test record.

---

## Methodology Overview

### Acquisition & Activation
- New registrations tracked over time, segmented by **country** and **acquisition channel**
- CAC analyzed both per registered user and per transacting user
- Activation rates evaluated across channels and markets

### Engagement & Retention
- Monthly Active Customers (MAC)
- Retention curves using both bounded and unbounded definitions
- Retention segmented by origin country

### Monetization
- Transaction volume and count over time
- Revenue estimated assuming a **transaction fee model**
- Corridor-level analysis (e.g. CAD–NGN, NGN–CAD)

### Unit Economics & Payback
- Cumulative acquisition cost vs. cumulative revenue
- ROI and payback period estimated over a **180-day horizon**
- Sensitivity analysis across **three fee scenarios**:
  - 0.10%
  - 0.25%
  - 0.50%

> These estimates are designed to assess **order of magnitude and sensitivity**, not to produce precise financial forecasts.

---

## Key Insights

### Acquisition & Activation
- **55% of users originate from Canada**, followed by Nigeria (31%) and the United Kingdom (15%).
- **Organic acquisition accounts for ~53%** of users and is consistent across countries.
- **Facebook shows higher CAC** compared to other channels.
- A spike in CAC coincides with a drop in conversion rate across all channels in the same period, suggesting a **potential measurement issue or temporary bug** rather than a structural demand change.
- Activation rates are high for Canada and Nigeria (~80%).

---

### Engagement & Retention
- Retention levels are **consistently high** across both bounded and unbounded definitions.
- Canada represents the majority of active users over time.
- While strong retention may indicate product–market fit, results should be interpreted cautiously given the **broad definition of “active user”** (at least one successful transaction).

---

### Monetization
- Total processed volume exceeds **$747M USD**, across ~954K transactions.
- Estimated revenue (assuming a 0.25% fee) is **~$1.87M USD**.
- **Transaction count is highest for CAD–NGN and GBP–NGN corridors**, while **NGN–CAD contributes disproportionately to volume** due to higher average transaction sizes.
- Revenue per active customer shows volatility, suggesting heterogeneity in user behavior and transaction frequency.

---

### Unit Economics & Payback
- Under all fee scenarios, **acquisition costs are recovered once users activate and begin transacting**.
- Payback periods shorten significantly when focusing on **new transacting users**, rather than all registered users.
- Even under conservative assumptions (0.10% fee), payback occurs within a reasonable time window.

---

## Business Implications

- Acquisition appears economically sustainable, particularly once users activate.
- Channel efficiency varies, indicating opportunities for **budget reallocation or optimization**.
- High-volume corridors may justify **corridor-specific pricing or incentive strategies**.
- Retention strength suggests the product delivers ongoing value, but definitions should be validated with product and operations teams.

---

## Limitations & Next Steps

- Validate unusually high retention metrics with Product and Operations teams.
- Investigate potential seasonality effects (monthly or weekly).
- Align country-level acquisition trends with marketing strategy and expansion plans.
- Conduct deeper monetization cuts (ARPU, LTV, cohort-level revenue).
- Refine unit economics with more granular cost and fee data.

---

## Final Notes

This analysis prioritizes **clarity, transparency, and decision relevance** over model complexity.  
All assumptions and limitations are explicitly stated to support informed discussion rather than definitive conclusions.