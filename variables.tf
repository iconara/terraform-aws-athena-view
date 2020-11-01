variable "database_name" {
  type = string
}

variable "name" {
  type = string
}

variable "sql" {
  type = string
}

variable "columns" {
  type = list(object({name = string, hive_type = string, presto_type = string}))
}
