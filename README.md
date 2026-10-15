















# BozorBoz Marketplace Analytics

End-to-end data analytics project for a marketplace business using **SQL Server** and **Power BI**.

The project analyzes marketplace performance across sales, profitability, categories, delivery operations, customers, marketing, and regional economics.

---

## 📌 Project Overview

BozorBoz is a marketplace where sellers list products, customers place orders, and couriers deliver them.

The analysis covers the period:

**January 2023 – June 2026**

The project uses SQL Server for data validation and business analysis, and Power BI for interactive dashboard development.

---

## 🎯 Business Questions

The analysis focuses on questions such as:

- Which product categories generate the most GMV?
- Which categories are actually profitable?
- How much contribution does each category generate?
- Which payment methods have the highest refusal rate?
- Which regions create the highest delivery losses?
- Which courier has the weakest delivery performance?
- How much delivery cost is wasted on incomplete orders?
- Which sellers have high GMV but poor quality?
- Which acquisition channels bring valuable customers?
- What is the CAC and repeat rate by acquisition source?
- Which marketing campaigns generate the strongest results?

---

## 🗂️ Dataset

The dataset contains **14 tables** covering:

- Orders
- Order items
- Products
- Sellers
- Customers
- Couriers
- Deliveries
- Returns
- Reviews
- Marketing spend
- Sessions
- Campaigns
- Seller payouts
- Date dimension

Key dataset statistics:

| Metric | Value |
|---|---:|
| Sellers | 460 |
| Products | 2,558 |
| Customers | 13,000 |
| Orders | 45,404 |
| Order Items | 62,611 |
| GMV | ~204.9B UZS |
| Marketing Spend | ~11.8B UZS |
| Return Rate | ~9.34% |
| Realised Take Rate | ~7.15% |

---

## 🛠️ Tools & Technologies

- **SQL Server / SSMS**
- **Power BI**
- **DAX**
- **Excel**
- Data Quality Checks
- Business Analysis
- Data Visualization

---

## 📊 Key KPIs

The dashboard tracks:

- GMV
- Orders
- AOV
- Take Rate
- Contribution
- Contribution per Order
- Active Buyers
- Return Rate
- Refusal Rate
- On-Time Delivery %
- Delivery Cost
- CAC
- Repeat Rate
- Conversion Rate

---

## 📈 Power BI Dashboard

The dashboard contains 6 pages:

### 1. Platforma Holati
Overall marketplace performance including:

- GMV
- Orders
- AOV
- Take Rate
- Contribution
- Active Buyers
- Monthly GMV
- New vs Returning Buyers
- Order Status

### 2. Kategoriya Iqtisodi

Category-level economics including:

- GMV
- GMV Share
- Realised Take Rate
- Return Rate
- Average Order Weight
- Delivery Cost
- Contribution
- Contribution %
- Free Shipping
- Return Reasons

Delivery costs are allocated to categories using an **item-count allocation method**.

### 3. To'lov va Bekor Qilish

Analysis of:

- Refusal Rate by Payment Method
- Regional Refusal Rate
- COD Share
- Wasted Delivery Cost
- Refusal by Order Value
- Refused COD GMV

### 4. Yetkazib Berish va Sifat

Courier and seller quality analysis:

- On-Time %
- SLA Target
- SLA Gap
- Delivery Cost / Order
- Delivery Attempts
- Damage Return Rate
- Seller Rating
- Seller Return Rate

### 5. Mijoz va Marketing

Customer acquisition and marketing analysis:

- Marketing Funnel
- Conversion Rate
- CAC
- Orders per Buyer
- GMV per Buyer
- Repeat Rate
- Cohort Retention
- Campaign Performance
- Device Analysis
- Regional Customer Analysis

### 6. Geografik Iqtisod

Regional business economics:

- Regional GMV
- Contribution
- Contribution per Order
- Wasted Delivery Cost
- GMV vs Contribution

---

## 🔎 Key Findings

### 1. Electronics generates the majority of GMV but destroys contribution

Electronics accounts for approximately **55.2% of total GMV**, but its contribution is approximately **-4.81B UZS**.

This indicates that high sales volume does not necessarily translate into healthy marketplace economics.

### 2. Cash-on-delivery has a significantly higher refusal rate

The refusal rate for cash payment at delivery is approximately **24.1%**, compared with around 3–4% for other payment methods.

This creates additional delivery costs and operational inefficiency.

### 3. Tezkor has the weakest delivery performance

Tezkor has approximately:

- **47.4% On-Time Delivery**
- **58% SLA Target**
- **-10.6 percentage-point SLA gap**
- **5.22% Damage Return Rate**

This makes it the weakest courier from a delivery-quality perspective in the analyzed data.

### 4. MegaTexno combines very high GMV with weak quality metrics

MegaTexno generates approximately **38.15B UZS GMV**, while having:

- Rating: **2.99**
- Return Rate: **21%**

Because of its large GMV contribution, improving this seller's quality could have a significant business impact.

---

## 💡 Recommendations

### Electronics

Review the economics of the electronics category, especially commission levels and free-shipping policy.

**Current contribution impact: approximately -4.81B UZS.**

### Cash-on-Delivery

Test stronger order confirmation or prepayment incentives for high-risk COD orders.

Incomplete orders generated approximately **256.7M UZS** in wasted delivery costs.

### Tezkor

Review courier allocation and SLA performance.

Tezkor has the lowest on-time delivery rate among the analyzed couriers.

### MegaTexno

Introduce seller-quality monitoring focused on:

- Returns
- Customer ratings
- Product quality
- Operational performance

The seller's large GMV means quality improvements could have a meaningful marketplace impact.

---

## 🧠 Analytical Approach

The project includes:

1. Data quality validation
2. Dimension key checks
3. Orphan record checks
4. Order and order-item reconciliation
5. Business metric calculations
6. Category profitability analysis
7. Delivery cost allocation
8. Customer acquisition analysis
9. Marketing funnel analysis
10. Cohort retention analysis
11. Courier performance analysis
12. Regional economics
13. Executive recommendations

---

## ⚠️ Important Data Modeling Consideration

The dataset contains both **order-level** and **order-line-level** metrics.

For example:

- Delivery cost → order level
- Shipping revenue → order level
- GMV → order-line level
- Commission → order-line level

Directly joining these levels can create **fan-out inflation**.

To avoid this, delivery costs are allocated to categories using an **item-count allocation method**.

This methodology is explicitly considered when calculating category contribution.

---

## 📁 Repository Structure

```text
bozorboz-marketplace-analysis/
│
├── README.md
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_business_analysis.sql
│   └── 03_ceo_scenario.sql
│
├── powerbi/
│   └── BozorBoz_Marketplace.pbit
│
├── screenshots/
│   ├── page_01_platforma_holati.png
│   ├── page_02_kategoriya_iqtisodi.png
│   ├── page_03_tolov_bekor_qilish.png
│   ├── page_04_yetkazib_berish.png
│   ├── page_05_mijoz_marketing.png
│   └── page_06_geografik_iqtisod.png
│
└── presentation/
    └── findings_recommendations.md




