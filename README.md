# Revenue & User Dynamics Analysis

This project analyzes the revenue performance and user behavior of a gaming platform using SQL and Tableau.

The main goal is to understand not only how revenue changes over time, but also what drives those changes, including user acquisition, retention and monetization.

---

## Key Questions

- What factors drive changes in Monthly Recurring Revenue (MRR)?
- Is the observed growth sustainable over time?
- How do user acquisition and churn impact overall performance?
- How does customer lifetime value (LTV) evolve?

---

## Tools & Technologies

- SQL (PostgreSQL / BigQuery concepts)
- Tableau (Data Visualization)
- Data Analysis & Aggregation Techniques
- Window Functions (LAG, LEAD)

---

## Dataset

The analysis is based on two main tables:

### `games_payments`
- user_id
- game_name
- payment_date
- revenue_amount_usd

### `games_paid_users`
- user_id
- language
- age

---

## Methodology

- Monthly revenue aggregation per user
- User segmentation:
  - New
  - Expansion
  - Contraction
  - Churned
  - Back from churn
- Calculation of key metrics:
  - MRR
  - Paid Users
  - ARPPU
  - Churn Rate
  - Revenue Churn Rate
  - LTV & LT

---

## Dashboard

The Tableau dashboard includes:

- KPI overview (MRR, Paid Users, ARPPU, Churn Rate, LTV, LT)
- Revenue decomposition (Revenue Factors)
- User dynamics (User Change)
- Monetization vs Churn analysis
- LTV trend

---

## Key Insights

- Revenue growth is strong at the beginning but slows over time
- Churn increases significantly and becomes the dominant negative factor
- Paid user growth becomes unstable
- ARPPU increases, but retention worsens
- LTV declines due to shorter customer lifetime

---

## Business Implications

- Growth is not sustainable in the current structure
- Increasing churn reduces long-term revenue potential
- Customer lifetime is too short to maximize value
- Acquisition alone is not sufficient

---

## Recommendations

- Focus on improving user retention
- Reduce churn through engagement strategies
- Re-engage churned users
- Target high-value user segments
- Balance acquisition and retention strategies

---

## Project Assets

- SQL Query → `/sql`
- Dashboard Screenshots → `/images`
- Presentation → `/presentation`

---

## Author

Aleyna Rapata  
Data Analyst Project
