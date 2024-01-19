variable "database_name" {
  type = string
  description = "The name of the database where the view will be created"
}

variable "name" {
  type = string
  description = "The name of the view"
}

variable "sql" {
  type = string
  description = "The SQL of the view (not including CREATE VIEW …)"
}

variable "columns" {
  type = list(object({name = string, hive_type = string, presto_type = string, comment = optional(string)}))
  description = <<EOT
A list of the names and types of the columns of the view, using both Hive and Presto types.
Views are complex structures in Athena, and the column names are repeated in multiple places in the metadata.
Column types are stored once in the Glue Data Catalog table structure using Hive types (this is what is used
for DDL in Athena), and again in an encoded structure using Presto types (this is what is used for DML in Athena).
See the readme for this module for how to translate between Hive and Presto types. If there is a mismatch
between the columns specified here and the actual columns produced by the view SQL you will get an error
saying that the view is "stale".
EOT
}
