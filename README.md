<!--Christopher Engelbart-->
<!--CWID: 10467610-->
# ESQLConstructor

## Table of Contents
* [Description](#description)
* [Sales Schema](#sales-schema)
* [The Phi Operator](#phi-operator)
    * [Motivation](#phi-motivation)
    * [Parameters](#phi-parameters)
    * [Further Reading](#phi-reading)
* [Building & Running](#build-and-run)
    * [Xcode](#br-xcode)
    * [Command Line](#br-cmdline)
    * [Steps to Run](#br-run-steps)
* [Using the Constructor](#constructor)
    * [Subcommands](#constructor-subcommands)
    * [`db-setup`](#db-setup)
    * [`constructor-file`](#constructor-file)
    * [`constructor-args`](#constructor-args)
* [Using the Evaluator](#evaluator)

## Description <a name="description">

This repository is for a project for CS 562 at Stevens Institute of Technology.

This package aims to implement the Phi Operator, an extended version of the SQL/Relational Algebra Group-By Operator.

`ESQLConstructor` is intended to be used on the command line via `ESQLConstructorCLI` executable target. Both targets together write another Swift package, `ESQLEvaluator`, which produces the result of the Phi operator for a given set of parameters.

To run `ESQLConstructor` and `ESQLEvaluator` and PostgreSQL database is required.

## Sales Schema <a name="sales-schema">
For simplicity, the package only recognizes the `sales` table, defined with the following schema:
* `cust`: `varchar(20)`
* `prod`: `varchar(20)`
* `day`: `integer`
* `month`: `integer`
* `year`:` integer`
* `state`: `character(2)`
* `quant`: `integer`
* `date`: `date`

## The Phi Operator <a name="phi-operator">

### Motivation <a name="phi-motivation">
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

This same query can be expressed a lot more succiently using ESQL and Phi and get us the exact same result.
```sql
SELECT cust, count(NY.quant), sum(NJ.quant), max(CT.quant)
FROM sales
GROUP BY cust; NY, NJ, CT
SUCH THAT NY.state = 'NY'
          NJ.state = 'NJ'
          CT.state = 'CT'
```

### Parameters <a name="phi-parameters">
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

This package aims to run the algorithm behind the Phi operator based on these parameters.

### Further Reading <a name="phi-reading">
For more details you can read the following papers (recommended in this order):
* [Querying Multiple Features of Groups in Relational Databases](https://www.researchgate.net/publication/2446539_Querying_Multiple_Features_of_Groups_in_Relational_Databases)
* [Evaluation of Ad Hoc OLAP: In-Place Computation](https://www.researchgate.net/publication/3815003_Evaluation_of_ad_hoc_OLAP_in-place_computation)

## Building & Running <a name="build-and-run">

This package has two targets, `ESQLConstructor` and `ESQLConstructorCLI`. The latter is an executable target and the main interface for the package operations. Although, ESQLConstructor could, in theory, be used as a normal dependency.

Regardless, an PostgreSQL database is required to use the functionality of `ESQLConstructorCLI` and `ESQLEvaluator`.

Some code from `ESQLConstructor` could be used without, but wouldn't be fully functional without a Postgres Database.

### Xcode <a name="br-xcode">

To run `ESQLConstructorCLI` select the scheme of the same name.

Depending on the command you want to run, you'll have to edit the scheme and change "Arguments Passed on Launch" under Run > Arguments.

As soon as the package is opened dependencies will be downloaded. 

### Command Line <a name="br-cmdline">

This can be run on Xcode or via the command line:

```bash
$ swift run ESQLConstructorCLI [cmd] [arguments]
```

For instance, if I wanted to run the `db-setup` command (see more below), I would do something like this:
```bash
$ swift run ESQLConstructorCLI db-setup --host "myHost" --port 5432 --username "myUsername" --password "myPassword" --database "myDatabase"
```

On the first innovcation of `swift run`, the package will resolve dependencies and compile before running.

### Steps To Run <a name="br-run-steps">

Once built the following commands will need to be run, in this order.

1. `swift run ESQLConstructorCLI db-setup [args]`
2. `swift run ESQLConstructorCLI constructor-file [args]` **OR** `swift run ESQLConstructorCLI constructor-args [args]`
3. `swift run ESQLEvaluator` (produced by `ESQLConstructorCLI`)

`db-setup` only needs to be run once, if the credentials don't change. Afterwards your credentials are stored for use in the other commands.

Each command of `ESQLConstructorCLI` is detailed below.

## Using the Constructor <a name="constructor">

### Subcommands <a name="constructor-subcommands">

`ESQLConstructorCLI` supports three comands:
- `db-setup`: Store & verify database credentials **(Run first!)**
- `constructor-file`: Create output package by reading a file
- `constructor-args`: Create output package by reading from the command line

### `db-setup` <a name="db-setup">

This command stores and verifies passed in database credentials for use in the other commands.

The command is used like this:
```bash
$ ./evaluator db-setup --host "myHost" --port 5432 --username "myUsername" --password "myPassword" --database "myDatabase"
```

These are the arguments for the command (used in this order):
* `--host`: The hostname of the database
* `--port`: The port the database is hosted on **(defaults to 5432)**
* `--username`: Database username
* `--password`: Database password **(optional)**
* `--database`: Database name **(optional)**

**`--port` is the only argument that must be a number!**

**Note:** This command is required to be used before using the other two commands. `ESQLEvaluator` will not be produced otherwise.

### `constructor-file` <a name="constructor-file">

This command reads a file for the parameters of Phi and creates `ESQLEvaluator` baws on it.

The command is used like this:
```bash
$ swift run ESQLConstructorCLI constructor-file --input "/my/input/file" --output "/my/output/path/"
```

These are the arguments for the command (used in this order)
* `-i` or `--input`: Path to read parameters from
* `-o` or `--output`: Path to write produced package to

The input file itself will look like this:
```
cust, count_1_quant, sum_2_quant, max_3_quant
3
cust
count_1_quant, sum_2_quant, max_3_quant
1.state = 'NY'; 2.state = 'NJ'; 3.state = 'CT'
```

If there is a having predicate, it would be placed on a 6th line, otherwise it can be omitted.

Having Predicates can be inputed just as it is in SQL.

### `constructor-args` <a name="constructor-args">
This command reads the command line arguments for the parameters of Phi and creates `ESQLEvaluator` based on it.

This command is used like this:
```bash
$ swift run ESQLConstructorCLI constructor-args -S "cust, count_1_quant, sum_2_quant, max_3_quant" -n 3 -V "cust" -F "count_1_quant, sum_2_quant, max_3_quant" -s "1.state = 'NY'; 2.state = 'NJ'; 3.state = 'CT'" --output "/my/file/path"
```

These are the arguments for the command (used in this order)
* `-S`: Projected Values
* `-n`: Number of Group-By Variables
* `-V`: Group-By Attributes
* `-F`: Aggregate Functions
* `-s`: Grouping Predicates
* `-G`: Having Predicate *(optional)*
* `-o` or `--output`: Path to write produced package to

Format for each argument is the same they are in the input file for the [`constructor-file`](#constructor-file) command. However, they may have to be wrapped in quotation marks.

## Using the Evaluator <a name="evaluator">

`ESQLEvaluator` is an executable target and can simply be run once it is produced by `ESQLConstructor`. Necessary information from the `ESQLConstructorCLI`'s commands are passed along in the production process.

Unlike `ESQLConstructorCLI`, it doesn't take any arguments, so it can be run simply from Xcode or by using:
```bash
$ swift run ESQLEvaluator
```

The result of the evaluation will be printed in the console.
