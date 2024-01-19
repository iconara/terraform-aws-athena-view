# terraform-aws-athena-view

This Terraform module can be used to create Athena views.

Programmatically creating a view that will be compatible with Athena without running DDL statements is undocumented, but possible. This module uses the [`aws_glue_catalog_table`][1] resource from the [`aws`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) provider to create a table in Glue Data Catalog that will appear as a view in Athena, in the same way that Athena would if you ran a `CREATE VIEW` statement in Athena.

## Usage

```hcl
module "stats_view" {
  source = "github.com/iconara/terraform-aws-athena-view"
  database_name = "analytics"
  name = "stats"
  sql = "SELECT name, COUNT(*) AS count FROM data GROUP BY 1 ORDER BY 2 DESC"
  columns = [
    {
      name = "name",
      hive_type = "string",
      presto_type = "varchar",
      comment = "This is the name"
    },
    {
      name = "count",
      hive_type = "bigint",
      presto_type = "bigint",
    }
  ]
}
```

The required variables, besides `source`, are the database name, the name of the view, the SQL (which should not include `CREATE VIEW` it should be just a `SELECT` statement), and metadata about the columns.

### Column metadata

When you create views using DDL statements in Athena, you don't have to specify column metadata because Athena analyzes your view and figures this out for you. Since this module creates the view directly in the Glue Data Catalog you have to provide this information, just like you have to when you create tables with the [`aws_glue_catalog_table`][1] resource.

Because of internal details about how Athena stores views, you unfortunately need to specify the types of the columns twice, once using Hive names and once using Presto names. Exactly why it works this way is only known to the Athena service team.

### Hive to Presto type conversion

Since complex types can be arbitrarily nested you need a proper parser to safely convert between Hive and Presto type names, [regular expressions aren't sufficient](https://stackoverflow.com/questions/546433/regular-expression-to-match-balanced-parentheses). Instead, here's a table you can use to convert between the two:

Hive type | Presto type
---|---
`string` | `varchar`
`array<E>` | `array(E)`
`map<K, V>` | `map(K, V)`
`struct<F1:T1, F2:T2>` | `row(F1 T1, F2 T2)`

All other types have the same name in Hive and Presto (if you find an exception please open a PR with a correction).

## License

© Theo Tolv, see [LICENSE (BSD 3-Clause)](LICENSE).

  [1]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table
