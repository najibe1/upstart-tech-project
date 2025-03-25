


##bucket to store all the files provided by s3
resource "google_storage_bucket" "s3_files_bucket" {
    name          = "s3-external-files-bucket"
    location      = "US"
}

resource "google_bigquery_dataset" "EXT_S3_FILES" {
  project       = var.gcp_project
  dataset_id    = "EXT_S3_FILES"
  friendly_name = "EXT_S3_FILES"
  description   = "dataset to store the external tables created using the files from gcs"
  location      = "US"
}


resource "google_bigquery_table" "external_products_table" {
  dataset_id = google_bigquery_dataset.EXT_S3_FILES.dataset_id
  table_id   = "src_products"
  project    = var.gcp_project

  external_data_configuration {
    autodetect    = false  
    source_format = "CSV"
    source_uris   = ["gs://${google_storage_bucket.s3_files_bucket.name}/external_data/products-1-.csv"]

    csv_options {
      quote                 = "\""
      skip_leading_rows     = 1
      allow_jagged_rows     = false
      allow_quoted_newlines = false
      encoding             = "UTF-8"
    }

    schema = <<EOF
[
  {
    "name": "ProductID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ProductDesc",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ProductNumber",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "MakeFlag",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "Color",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "SafetyStockLevel",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ReorderPoint",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "StandardCost",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ListPrice",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "Size",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "SizeUnitMeasureCode",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "Weight",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "WeightUnitMeasureCode",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ProductCategoryName",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ProductSubCategoryName",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF
  }
}

resource "google_bigquery_table" "external_sales_order_header_table" {
  dataset_id = google_bigquery_dataset.EXT_S3_FILES.dataset_id
  table_id   = "src_sales_order_header"
  project    = var.gcp_project

  external_data_configuration {
    autodetect    = false  
    source_format = "CSV"
    source_uris   = ["gs://${google_storage_bucket.s3_files_bucket.name}/external_data/sales-order-header-1-.csv"]

    csv_options {
      quote                 = "\""
      skip_leading_rows     = 1
      allow_jagged_rows     = false
      allow_quoted_newlines = false
      encoding             = "UTF-8"
    }

    schema = <<EOF
[
  {
    "name": "SalesOrderID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "OrderDate",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ShipDate",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "OnlineOrderFlag",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "AccountNumber",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "CustomerID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "SalesPersonID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "Freight",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF
  }
}


resource "google_bigquery_table" "external_sales_order_detail_table" {
  dataset_id = google_bigquery_dataset.EXT_S3_FILES.dataset_id
  table_id   = "src_sales_order_detail"
  project    = var.gcp_project

  external_data_configuration {
    source_format = "CSV"
    autodetect    = false  

    csv_options {
      skip_leading_rows     = 1
      quote                 = "\""
      allow_jagged_rows     = false 
      allow_quoted_newlines = false
      encoding              = "UTF-8"
    }

    source_uris = [
      "gs://${google_storage_bucket.s3_files_bucket.name}/external_data/sales-order-detail-1-.csv",
    ] 

    schema = <<EOF
[
  {
    "name": "SalesOrderID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "SalesOrderDetailID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "OrderQty",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "ProductID",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "UnitPrice",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "UnitPriceDiscount",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF
  }
}