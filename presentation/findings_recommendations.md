# BozorBoz Marketplace — Key Findings & Recommendations

## Executive Summary

BozorBoz Marketplace dataset analysis covered the period from January 2023 to June 2026.

The analysis focused on marketplace revenue, contribution economics, delivery quality, customer behavior, payment/refusal risk, seller quality, and marketing performance.

### Overall Business Snapshot

- GMV: 204.89B UZS
- Orders: 45,404
- Realised Take Rate: 7.15%
- Contribution: ~1.23B UZS
- Contribution per Order: ~27.14K UZS
- AOV: ~4.54M UZS
- Return Rate: 9.34%

---

# 1. Electronics Drives GMV but Destroys Contribution

## Finding

Electronics represents **55.2% of total GMV**, making it by far the largest category.

However, its contribution is approximately **-4.81B UZS**.

This creates a major gap between sales volume and economic value.

### Key numbers

| Metric | Electronics |
|---|---:|
| GMV | 113.04B UZS |
| GMV Share | 55.2% |
| Realised Take Rate | 3.40% |
| Return Rate | 13.62% |
| Contribution | -4.81B UZS |
| Free Shipping Share | 100% |

## Recommendation

Review the economics of Electronics orders by testing:

- higher or differentiated commission rates;
- tighter free-shipping eligibility;
- seller-specific commercial terms;
- category-level delivery pricing;
- targeted discount limits.

The objective should not be simply to reduce Electronics sales, but to improve **contribution per order while protecting strategically important GMV**.

## Business Impact

Electronics is the largest opportunity for contribution improvement because even a small improvement in its unit economics can have a significant effect on total platform profitability.

---

# 2. Cash-on-Delivery Creates a Major Refusal Risk

## Finding

Cash-on-delivery (`Naqd (yetkazishda)`) has a refusal rate of approximately **24.1%**, significantly higher than other payment methods.

| Payment Method | Refusal Rate |
|---|---:|
| Naqd (yetkazishda) | 24.1% |
| Karta yetkazishda | 3.8% |
| Bo‘lib to‘lash | 3.8% |
| Karta online | 3.6% |

Refused COD orders represent approximately **21.16B UZS of GMV**.

Incomplete orders also generated approximately **256.7M UZS of wasted delivery cost**:

- Refused: 217.0M UZS
- Cancelled: 39.7M UZS

## Recommendation

Test interventions for high-risk COD orders:

- order confirmation before dispatch;
- small prepayment/deposit;
- customer confirmation through SMS or call;
- stricter COD rules for customers/orders with historically high refusal risk.

The first step should be a controlled test rather than an immediate full-scale change.

## Business Impact

Reducing COD refusal can simultaneously:

- reduce wasted delivery cost;
- improve courier utilisation;
- reduce operational waste;
- protect GMV from failed fulfilment.

---

# 3. Tezkor Has the Weakest Delivery Quality

## Finding

`Tezkor` has the weakest on-time delivery performance among the analysed couriers.

| Metric | Tezkor |
|---|---:|
| On-time Delivery | 47.4% |
| SLA Target | 58.0% |
| SLA Gap | -10.6 pp |
| Delivery Cost / Order | ~31.6K UZS |
| Damage Return Rate | 5.22% |

Tezkor therefore combines weak delivery performance with the highest observed damage-return rate.

## Recommendation

Prioritise Tezkor for:

- SLA monitoring;
- root-cause analysis by region;
- shipment quality checks;
- volume reallocation where alternative couriers have better quality;
- corrective action plans with measurable SLA targets.

Courier selection should consider both **cost and service quality**, rather than cost alone.

## Business Impact

Improving Tezkor's delivery performance can reduce customer dissatisfaction, failed/returned orders, and operational quality risks.

---

# 4. MegaTexno Is a High-Impact Seller Quality Risk

## Finding

`MegaTexno` is the largest seller by GMV, generating approximately **38.15B UZS**.

However, its quality indicators are weak:

- Average rating: **2.99 / 5**
- Return rate: **21.0%**

This creates a particularly important business risk because the seller combines **very high volume with poor customer outcomes**.

## Recommendation

Introduce a seller quality improvement plan:

- monitor return reasons;
- investigate product-level return concentration;
- review damaged/incorrect product incidents;
- establish seller quality thresholds;
- combine GMV ranking with rating and return metrics.

The seller should not be evaluated on GMV alone.

## Business Impact

Because MegaTexno contributes significant GMV, improving its quality can have a larger customer and platform impact than improving a low-volume seller.

---

# Additional Business Observations

## Seller Tier Commission Discounts

During the latest 12 months, Platina and Oltin sellers received approximately:

- Platina discount: **352.8M UZS**
- Oltin discount: **247.4M UZS**
- Total top-tier commission discount: **~600.2M UZS**

These discounts should be evaluated against seller retention, GMV contribution, and incremental platform value.

---

## Marketing Acquisition

The acquisition analysis shows meaningful differences between channels.

### Stronger customer value indicators

Organic and Direct channels show:

- high orders per buyer;
- high GMV per buyer;
- no recorded paid marketing spend.

Among paid channels, Email and Referral show comparatively strong customer economics.

### Important observation

Banner has:

- CAC: ~796.8K UZS
- Orders per buyer: ~1.39
- GMV per buyer: ~617.8K UZS
- Repeat rate: ~41.5%

This makes Banner an important channel for optimisation and further investigation.

---

# Recommended Management Priorities

Based on the analysis, the recommended priority order is:

### Priority 1 — Improve Electronics Economics

Focus on commission, shipping, and discount economics.

**Reason:** Electronics generates 55.2% of GMV but approximately -4.81B UZS contribution.

### Priority 2 — Reduce COD Refusals

Test confirmation/prepayment mechanisms.

**Reason:** COD refusal rate is 24.1% and incomplete orders generated 256.7M UZS of wasted delivery cost.

### Priority 3 — Fix Tezkor Delivery Quality

Create a courier improvement plan and monitor SLA performance.

**Reason:** 47.4% on-time delivery and -10.6 pp SLA gap.

### Priority 4 — Improve MegaTexno Seller Quality

Investigate return drivers and low ratings.

**Reason:** 38.15B UZS GMV combined with 2.99 rating and 21% return rate.

---

# Conclusion

The analysis shows that BozorBoz's biggest opportunities are not necessarily areas with the highest sales volume.

The key business lesson is:

> **GMV alone does not equal business value.**

Electronics demonstrates this most clearly: it is the largest category by GMV but has negative contribution.

Similarly, payment method, courier quality, and seller quality can materially affect the economics and customer experience of the marketplace.

The recommended approach is therefore to manage the marketplace using a combination of:

- GMV;
- contribution;
- contribution per order;
- delivery cost;
- refusal and return rates;
- customer retention;
- seller quality;
- marketing acquisition economics.

This creates a more complete view of marketplace performance and supports data-driven operational decisions.
