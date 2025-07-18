## 📊 **Catalog Competitiveness Analysis Dashboard**

This repository contains the SQL queries and documentation for a dashboard that analyzes the competitiveness of a trading catalog across different categories. The dashboard provides insights into how well the selected catalog performs compared to other catalogs or suppliers in terms of pricing and model availability. This tool helps the Trading Director track key metrics and make strategic decisions to improve the catalog's performance.

---

### **Overview**

The dashboard is designed to provide comprehensive analytics on catalog performance, focusing on:
- **ABC Analysis**: Prioritization of models based on frequency and GMV (Gross Merchandise Value).
- **Category Performance**: Detailed breakdown by category, showing which categories are most competitive.
- **Price Comparison**: Identification of models where the selected catalog/supplier is not the lowest-priced option.

The dashboard is interactive, allowing users to filter data by catalog, top category, and other parameters. It also provides detailed reports with model details, prices, and rankings, enabling deeper analysis.

---

### 🛠️ **Features**

1. **Interactive Filters**
   - Users can filter data by:
     - Catalog
     - Top category
     - Other relevant parameters

2. **Detailed Reports**
   - Comprehensive tables with model details, including:
     - Model ID and name
     - Category and top category
     - Price and price with delivery
     - GMV (Gross Merchandise Value)
     - Counts (frequency of orders)
     - Rating (based on price competitiveness)

3. **Competitive Insights**
   - Identifies models where the selected catalog/supplier is not the lowest-priced option.
   - Provides actionable insights for improving pricing strategy and model selection.

4. **ABC Analysis**
   - Models are categorized into A, B, and C groups based on their importance:
     - **A**: High-priority models (most frequent and high GMV).
     - **B**: Medium-priority models.
     - **C**: Low-priority models.

5. **Category-Specific Analysis**
   - Breakdown of ABC analysis by category, showing performance at both the top-category and sub-category levels.

6. **Price Comparison Table**
   - Lists models where the selected catalog/supplier is not the lowest-priced option, sorted by rating (price competitiveness).

---

### **Technologies Used**

- **SQL**: Complex queries for data analysis and filtering.
- **Clickhouse**: Database used for storing and querying large datasets.
- **Metabase**: Business Intelligence (BI) tool used to build the interactive dashboard.
- **Data Visualization**: Interactive tables and filters for better user experience.

---

#### **SQL_code**

| File | Description |
|------|-------------|
| `1_catalog_analysis.sql` | Core analysis: delivery cost, pricing, ABC analysis by GMV and order frequency |
| `2_non_optimal_pricing.sql` | Filters for models where the selected catalog is not the lowest-priced option |

---

### 🖥️ **Sample Output**

Below are screenshots of the dashboard showcasing its key features:

#### 1. **ABC Analysis**
<img width="1860" height="387" alt="image" src="https://github.com/user-attachments/assets/a02ff408-1f00-4179-b7f4-0db8855f56dd" />

- Shows prioritization of models based on frequency and GMV.
- Includes total counts and percentages for each ABC group.

#### 2. **Category Performance**
<img width="1775" height="463" alt="image" src="https://github.com/user-attachments/assets/0b1a06c0-740f-49a5-863e-c7875ca7fd58" />

- Breaks down ABC analysis by category.
- Highlights performance at both top-category and sub-category levels.

#### 3. **Price Comparison**
<img width="1822" height="392" alt="image" src="https://github.com/user-attachments/assets/9a3b4a98-57eb-4b59-b3f3-9146add92a18" />

- Lists models where the selected catalog/supplier is not the lowest-priced option.
- Includes detailed information such as model ID, name, category, price, GMV, etc.

---
