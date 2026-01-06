# 📊 LemFi — Product Analytics Case Study


## Objective

- Evaluate LemFi’s customer lifecycle performance across acquisition, activation, retention, monetization, and unit economics.
- Build a customer journey map and propose a hypothesis and experiment to increase conversion from registered to new transacting users.


# Product & Business Performance Analysis

Given time constraints, the focus is on:
- Identifying **key drivers of growth and efficiency**
- Assessing whether **customer acquisition costs are recovered**
- Highlighting **opportunities and risks** to inform future product and growth decisions

This analysis is intended as an **exploratory, decision-oriented exercise**, not as a final production-grade financial model.


👉 **Interactive dashboard:**  
https://lookerstudio.google.com/reporting/ee3aadaa-c059-4481-b54b-d36427ce4304

---

## Data Coverage & Scope

- The dataset includes **transactions from customers acquired between January and June 2021**.
- Transaction activity is observed beyond the acquisition window to analyze **retention and monetization over time**.
- All analyses are cohort-based anchored on **user registration date**, except for ROI and payback calculations.

---

## Data Cleaning & Assumptions

### Data Treatment & Limitations

- **Transaction status normalization**  
  Multiple successful status labels (e.g. `SUCCESSFUL`, `TRANSFER-SUCCESSFUL`) were grouped into a single `SUCCESS` category to ensure consistent activation and revenue definitions. A deeper investigation of edge cases was considered out of scope.

- **Duplicate transactions**  
  Potential duplicates were detected (identical values across all columns except `transaction_id`). These records were retained but flagged as a data-quality risk.

- **Acquisition costs**  
  Acquisition cost values appear to be stored in absolute units rather than millions. 

- **User status fields**  
  `is_verified` and `is_blocked` fields were not used, as they represent the latest user state only and lack historical timestamps, making longitudinal analysis unreliable.

- **Missing values**  
 `Default Transfer` field was excluded from aggregation metrics for simplicity. 

- **Out-of-scope records**  
  One isolated transaction with origin country = United States was identified, is likely a test record.

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


# Customer Journey & Experiment Design


This journey is intentionally conceptual. Given current data limitations, it focuses on observable outcomes and known user actions rather than assuming unobserved drop-offs.

---

## Journey Overview

### High-Level Journey Stages

| Stage | User Goal | Description | Observability |
|------|----------|-------------|---------------|
| 1. Registration | “I want to try LemFi” | User completes sign-up | Observable |
| 2. Exploration / Setup | “How does this work?” | User explores app, may configure settings | Partially observable |
| 3. Optional Configuration | “I plan to send money to X” | User may select a default transfer country | Optional, not required |
| 4. Transfer Initiation | “Let me try a transfer” | User enters the transfer flow | Observable |
| 5. First Transaction | “Money sent” | First successful transfer | Observable |
| 6. Retention | “I’ll use this again” | Repeat transactions | Observable |

---

## Core Insight

> Regardless of the path taken, the most impactful opportunity lies in improving
the transition from registration to first successful transaction.

Once users successfully transact, retention remains strong, suggesting that
product value is delivered post-activation.

---

## Data Maturity & Limitations

In the current dataset:
- Registration and first successful transaction are clearly observable.
- Intermediate steps in the funnel (e.g. intent formation, hesitation, aborted
  flows) are only partially captured.
- Some user behaviors (e.g. optional configuration actions) are observed but
  cannot be assumed to represent intent for all users.

As a result, precise identification of friction points is constrained.

## Experiment Setup — Increase Conversion from Registered → New Transacting User

### 1) Objective
Increase conversion from **registered users to new transacting users** by reducing early-funnel decision friction immediately after registration.

**Business goal:** Improve activation (first successful transaction) while maintaining transaction quality and early retention.

---

### 2) Hypothesis
Because intermediate funnel steps between registration and first transaction are only partially observable, we will start with a lightweight, high-leverage intervention at a clearly defined moment in the journey (post-registration).

**Hypothesis:**  
Changing the primary post-registration CTA from a generic action (e.g., “Explore”) to a goal-oriented CTA (e.g., **“Send your first transfer”**) will increase the share of users who complete a first successful transaction within a defined time window.

---

### 3) Test Design

#### 3.1 Experiment type
- **A/B test**, randomized at **user level**. 
- 50/50 split.

#### 3.2 Population / Eligibility
Include:
- Newly registered users during the test period
- Exclude:
  - Users already transacted before exposure (if any edge cases)
  - Internal/test accounts (if identifiable)

Optional segmentation for analysis (not for randomization):
- Country (Canada, Nigeria, UK)
- Channel (organic, google, facebook)
- Users who selected default transfer country vs. not (note: not required for activation)

#### 3.3 Variants
- **Control:** Current post-registration CTA and default landing experience.
- **Treatment:** Replace primary CTA with **“Send your first transfer”** (or equivalent), routing users directly to the transfer initiation flow (or the most relevant first-step screen).

**Important:** Keep everything else identical (layout, copy length, number of CTAs) as much as possible to isolate the CTA effect.

---

### 4) Sample Size, MDE, Power

Because exact daily new registrations are unknown in this prompt, sample size will be determined using:
- Baseline activation rate from the dashboard (e.g., ~57% overall)
- Chosen **MDE** (minimum detectable effect)
- Desired **power** and **alpha**

**Recommended parameters (standard):**
- Significance level (α): **0.05**
- Power (1-β): **0.80**
- Primary outcome: activation (binary)

**MDE choice (practical):**
- Relative uplift: **+3% to +5%** relative (e.g., 57% → ~58.7%–59.9%)  
  This is realistic for a CTA-only change.

**Execution note:**  
Run a standard two-proportion power calculation using:
- Baseline p₀ = current activation rate
- Target p₁ = p₀ + MDE
- α = 0.05, power = 0.80

If traffic is high, use a smaller MDE; if traffic is limited, accept a larger MDE or extend duration.

---

### 5) Primary Success Metric
**Activation Rate (Primary):**  
% of registered users who complete **their first successful transaction** within **X days** of registration.

Recommended windows:
- **7-day activation** as primary (faster feedback loop)
- Optionally report 30-day activation as a supporting read

**Why 7 days:** CTA change should impact near-term behavior; waiting 30 days may dilute signal and slow iteration.

---

### 6) Secondary Metrics (Diagnostic)
These help interpret *why* the primary moved.

**Behavioral:**
- CTA click-through rate (CTR)
- Share of users who reach the transfer initiation screen (if trackable)
- Time to first transaction (median/percentiles)

**Business:**
- Avg. number of transactions per activated user (early)
- Early revenue proxy (e.g., fee * volume) within 7/30 days (if available)

**Segment cuts (reporting only):**
- By country
- By acquisition channel
- By users with/without default transfer country selected (as a behavior marker, not intent proxy)

---

### 7) Guardrail Metrics (Do No Harm)
We want higher activation without degrading quality or increasing operational risk.

- Failed transaction rate (or non-success statuses) among new users
- Customer support contact rate (if available)
- Early retention (7d/30d) among activated users (ensure we’re not driving low-quality activation)

---

### 8) Test Duration
Set duration based on:
1) reaching required sample size for the chosen MDE  
2) covering at least one full weekly cycle (weekday/weekend effects)

**Recommendation:**
- Minimum: **2 full weeks**
- Preferred: **3–4 weeks** if volume is lower or if seasonality is suspected

---

### 9) Monitoring Plan (During the Test)

**Daily checks (health):**
- Sample ratio mismatch (SRM) — confirm assignment is ~50/50
- Data pipeline completeness (events firing, transaction statuses)
- Outliers or sudden metric shifts caused by logging issues

**Weekly checks (performance):**
- Segment sanity checks (ensure treatment is not breaking flows for a country/channel)

**Debug triggers:**
- CTR drops sharply
- Failed transaction rate increases materially
- SRM detected
- Country-specific anomalies (e.g., Nigeria suddenly collapses)

---

### 10) Analysis & Validation

**Decision criteria:**
- Ship if:
  - Activation increases (statistically significant and practically meaningful)
  - Guardrails are neutral or improved
- Iterate if:
  - CTR improves but activation doesn’t (suggest downstream friction)
  - Activation improves but guardrails worsen (quality tradeoff)

---

