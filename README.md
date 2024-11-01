# ESQLConstructor

## Description

This repository is for a project for CS 562 at Stevens Institute of Technology.

This package aims to implement the Phi Operator, an enhanced version of the PostgreSQL/Relational Algebra Group-By Operator.

For simplicity, the package only recognizes the `sales` table, defined with the following schema:
* `cust`: `varchar(20)`
* `prod`: `varchar(20)`
* `day`: `integer`
* `month`: `integer`
* `year`:` integer`
* `state`: `character(2)`
* `quant`: `integer`
* `date`: `date`

This package produces another Swift package, `ESQLEvaluator`, which produces the result of the Phi operator for a given set of parameters.
