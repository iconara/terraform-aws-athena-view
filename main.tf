locals {
  presto_view = jsonencode({
    originalSql = var.sql,
    catalog = "awsdatacatalog",
    schema = var.database_name,
    columns = [for c in var.columns : {name = c.name, type = c.presto_type}],
  })
}

resource "aws_glue_catalog_table" "view" {
  name = var.name
  database_name = var.database_name
  table_type = "VIRTUAL_VIEW"
  parameters = {
    presto_view = "true"
  }
  view_original_text = "/* Presto View: ${base64encode(local.presto_view)} */"
  storage_descriptor {
    ser_de_info {
      name = "-"
      serialization_library = "-"
    }
    dynamic "columns" {
      for_each = var.columns
      content {
        name = columns.value.name
        type = columns.value.hive_type
      }
    }
  }
}
