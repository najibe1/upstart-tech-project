# Upstart Client Technical Project Documentation

## Project Overview
This project implements a complete data pipeline that extracts raw data from AWS S3, transforms it through a medallion architecture in Google Cloud Platform, and delivers analytical insights via BigQuery. The solution leverages Terraform for infrastructure, Airflow for orchestration, and DBT for transformation.

## Technical Implementation

### 1. Data Ingestion Process
- **Source Data**: Manually loaded CSV files into AWS S3 bucket to simulate external data sources
- **Transfer Mechanism**: 
  - Custom-built Airflow operator handles S3-to-GCS transfers
  - Configured service accounts and permissions via Terraform

### 2.1 Local Infrastructure
- Docker container to local Airflow and dbt.

### 2.2 GCP Infrastructure
- **Storage**: 
  - GCS buckets provisioned with Terraform
- **Data Catalog**: 
  - BigQuery external tables pointing to GCS files
- **Security**:
  - Fine-grained IAM roles for service accounts
  - Network access restrictions

### 3. Data Transformation Pipeline
**Medallion Architecture Implementation**:

| Layer       | Naming Prefix | Description                                                                 |
|-------------|---------------|-----------------------------------------------------------------------------|
| **Bronze**  | `raw_`        | Preserves source data exactly as received                                   |
| **Silver**  | `store_`      | Cleaned data with:<br>- Standardized formats<br>- Null handling<br>- FK/PK relations |
| **Gold**    | `publish_`    | Business-ready aggregates and derived metrics                               |
| **Datamart**|               | Analytical views answering specific business questions                      |

### 4. Key Business Logic Implementations

**Product Data Enhancements**:
- Standardized empty color values to 'N/A'
- Created product category hierarchy based on subcategory names
- Implemented data quality checks for mandatory fields, like non_null and unique

**Sales Order Transformations**:
- Calculated accurate business days between order and shipment
- Computed line item totals with proper discount application
- Joined header and detail tables with referential integrity checks

### 5. Orchestration
- **Airflow DAG** schedules daily pipeline runs with:
  1. File transfer from S3 to GCS
  2. DBT model execution (bronze → silver → gold)
  3. Data quality validation in DBT inside the layers for every single model
  4. Alerting for failures (warn)

- **Dependency Management**:
  - Ensures tables are loaded in correct sequence
  - Handles upstream/downstream relationships

### 6. Data Quality Framework
- **DBT Tests** for:
  - Primary/foreign key relationships
  - Non-null constraints on critical fields
  - Value validation (positive quantities, valid values)
  - Custom tests with business logic

### 7. Analytical Deliverables
**Solved Business Questions**:
1. Annual revenue by product color
2. Average processing time by product category

**Implementation Approach**:
- Created dedicated datamart views
- Optimized queries for performance
- Documented calculation methodologies

## Future Enhancement Opportunities

1. **Incremental Processing**
   - Requires adding ingestion timestamps to source files to create incremental strategies to dbt models
   - If a date field was present in the dimension table (products), it would be possible to implement a SCD2 logic for slowly changing dimensions using the dbt snapshot

2. **Advanced Monitoring**
   - Column-level lineage tracking
   - Automated anomaly detection (using dbt.elementary, for example)
   - Data freshness dashboards

3. **Expanded Validation**
   - Unit tests for transformation logic
   - Cross-system consistency checks
   - Historical trend analysis

## Technical Requirements
- **Cloud Services**: GCP (GCS, BigQuery), AWS S3
- **Tools**: Terraform ≥1.5, Airflow 2.6+, DBT Core 1.5+
- **Data Formats**: CSV
- **Access Controls**: IAM-based permission model

## Implementation Notes
- **Design Choice**: External tables were preferred over direct loading to preserve raw data
- **Challenge Addressed**: Initially attempted Spark but i was facing some problems with Hadoop custom jars do connect with GCS and Airflow so pivoted to pure SQL due to dependency conflicts
- **Tradeoff**: Current implementation requires full refreshes due to missing timestamps in source data

## Value Delivered
- **Reliable Data Pipeline**: Daily automated processing
- **Trusted Data Foundation**: Rigorous quality checks
- **Actionable Insights**: Ready-to-use analytical views
- **Extensible Framework**: Designed for future growth
