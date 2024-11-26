# ESQLConstructor

## Description

This repository is for a project for CS 562 at Stevens Institute of Technology.

This package aims to implement the Phi Operator, an extended version of the SQL/Relational Algebra Group-By Operator.

This package produces another Swift package, `ESQLEvaluator`, which produces the result of the Phi operator for a given set of parameters.

## Sales Schema
For simplicity, the package only recognizes the `sales` table, defined with the following schema:
* `cust`: `varchar(20)`
* `prod`: `varchar(20)`
* `day`: `integer`
* `month`: `integer`
* `year`:` integer`
* `state`: `character(2)`
* `quant`: `integer`
* `date`: `date`

## The Phi Operator

### Description
Suppose we want to get the number of sales in NY, the sum of sale quantities in NJ, and the max sale quantity in CT, all per customer.

One could write a query like this:
```sql
with t1 as (
    SELECT cust, count(quant) as nyCount
    FROM sales
    WHERE state = 'NY'
    GROUP BY cust
),
t2 as (
    SELECT cust, sum(quant) as njSum
    FROM sales
    WHERE state = 'NJ'
    GROUP BY cust
),
t3 as (
    SELECT cust, max(quant) as ctMax
    FROM sales
    WHERE state = 'CT'
    GROUP BY cust
)
SELECT t1.cust, nyCount, njSum, ctMax
FROM t1 natural join t2 natural join t3
```

This same query can be expressed a lot more succiently using ESQL and Phi.
```sql
SELECT cust, count(NY.quant), sum(NJ.quant), max(CT.quant)
FROM sales
GROUP BY cust; NY, NJ, CT
SUCH THAT NY.state = 'NY'
          NJ.state = 'NJ'
          CT.state = 'CT'
```

### Parameters
The Phi operator, in its relational algebra form, has 6 parameters, which `ESQLConstructor` takes in.

They are as follows:
1. Projected Values
2. Number of Grouping Variables
3. The Group-By Attributes
4. The Aggregate Functions
5. Grouping Predicates
6. Having Predicate (Optional)

For the above example, it would look like this:
1. `cust`, `count(NY.quant)`, `sum(NJ.quant)`, `max(CT.quant)`
2. `3`
3. `cust`
4. `count(NY.quant)`, `sum(NJ.quant)`, `max(CT.quant)`
5. `NY.state = 'NY'`, `NJ.state = 'NJ'`, `CT.state = 'CT'`
6. Nothing

### Further Reading
For more details you can read the following papers (recommended in this order):
* [Querying Multiple Features of Groups in Relational Databases](https://www.researchgate.net/publication/2446539_Querying_Multiple_Features_of_Groups_in_Relational_Databases)
* [Evaluation of Ad Hoc OLAP: In-Place Computation](https://www.researchgate.net/publication/3815003_Evaluation_of_ad_hoc_OLAP_in-place_computation)

## Using the Constructor

While `ESQLConstructor` could, in theory, be used as a dependency, it is intended to be used as a Command-Line Executable, via the `ESQLConstructorCLI` target.

You will also need a PostgreSQL database to use this package.

`ESQLConstructorCLI` has three comands:
- `db-setup`
- `constructor-file`
- `constructor-args`

### `db-setup`

This command stores and verifies passed in database credentials for use in the other commands.

The command is used like this:
```bash
$ ./evaluator db-setup --host "myHost" --port 5432 --username "myUsername" --password "myPassword" --database "myDatabase"
```

Both `password` and `database` are optional, depending on your database configuration.

This command is required to be used before using the other two commands.

### `constructor-file`

This command reads a file for the parameters of Phi and creates `ESQLEvaluator` baws on it.

The command is used like this:
```bash
$ ./evaluator constructor-file --input /my/input/file --output /my/output/path/
```

The input file itself will look like this:
```
cust, count_1_quant, sum_2_quant, max_3_quant
3
cust
count_1_quant, sum_2_quant, max_3_quant
1.state = 'NY'; 2.state = 'NJ'; 3.state = 'CT'
```

If there is a having predicate, it would be placed on a 6th line.

It can be inputed just as it is written in SQL.

### `constructor-args`
This command reads the command line arguments for the parameters of Phi and creates `ESQLEvaluator` based on it.

This command is used like this:
```bash
$ ./evaluator constructor-args -S "cust" -n 3 -V "count_1_quant, sum_2_quant, max_3_quant" -F "count_1_quant, sum_2_quant, max_3_quant" -s "1.state = 'NY'; 2.state = 'NJ'; 3.state = 'CT' --output "/my/file/path"
```

If there is a having predicate, it would be added before `--output` with `-G`. Otherwise, it can be ommitted.

It can be inputed just as it is written in SQL.
