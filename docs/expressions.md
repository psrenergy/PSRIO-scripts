---
title: Expressions
nav_order: 5
---

# Expressions
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Unary Expressions

PSRIO provides four unary operators that only receive one expression and do not modifies any dimension (stages, blocks, scenarios, and agents). The unary minus maps the data values to their additive inverses; the absolute value is the non-negative value of the data without regard to its sign; the round method rounds the data to the specified number of digits after the decimal place; the convert method determines the unit of the data. 

<br/>

|     Operator    |            Syntax            |
|:----------------|:-----------------------------|
| Unary Minus     | `exp = -exp1`                |
| Absolute Value  | `exp = exp1:abs()`           |
| Round           | `exp = exp1:round(int)`      |
| Unit Conversion | `exp = exp1:convert("unit")` |

<br/>

``` lua
circuit = require("collection/circuit");
cirflw = circuit:load("cirflw");

abs_cirflw = cirflw:abs();
```

### Unit Conversion

<div style="text-align:center">
    <img src="images/si.svg" width="200"/>
</div>

The units conversion follows the International System of Units units and syntax, based on the [2019 redefinition](https://www.nist.gov/si-redefinition). The PSRIO will perform a multi-step process with all the expressions inputs, producing a conversion factor with the desired unit.

#### Example 1
{: .no_toc }

``` lua
hydro = require("collection/hydro");
fprodt = hydro:load("fprodt");
    
pothid = min(hydro.qmax * fprodt, hydro.capacity_maintenance);
```

In this example we have two inputs with different units: `hydro.qmax` `[m3/s]` and `fprodt` `[MW/(m3/s)]`. The pothid output will be the multiplication: `[m3/s] × [MW/(m3/s)] = 1.0 × [MW]`.

#### Example 2
{: .no_toc }

``` lua
renewable = require("collection/renewable");
gergnd = renewable:load("gergnd");
vergnd = renewable:load("vergnd");
    
captured_prices = (gergnd * vergnd) / (gergnd + vergnd);
```

The unit conversion output of Example 2 is the expression: `([GWh] × [GWh]) / ([GWh] + [GWh]) = 1.0 × [GWh]`

#### Example 3
{: .no_toc }

``` lua
thermal = require("collection/thermal");
fuel = require("collection/fuel");
    
cinte1 = (thermal.cesp1 * (thermal.transport_cost + fuel.cost) + thermal.omcost);
```

The unit conversion output of Example 3 is the expression: `[gal/MWh] × ([$/gal] + [$/gal]) + [$/MWh] = 1.0 × [$/MWh]`

#### Example 4
{: .no_toc }

``` lua
hydro = require("collection/hydro");
volfin = hydro:load("volfin");
fprodtac = hydro:load("fprodtac");
    
eneemb = ((volfin - hydro.vmin) * fprodtac):convert("GWh");
```

The unit conversion output of Example 4 is the expression: `([hm3] - [hm3]) × [MW/(m3/s)] = 0.27 × [GWh]`

<br/>

## Binary Expressions

PSRIO provides binary operators which can change attributes (stages, blocks, scenarios, and agents) depending on inputs. The first table presents the addition, subtraction, multiplication, division, and power arithmetic operators.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|          Addition         |   `exp = exp1 + exp2`   |
|        Subtraction        |   `exp = exp1 - exp2`   |
|       Multiplication      |   `exp = exp1 * exp2`   |
|       Right Division      |   `exp = exp1 / exp2`   |
|           Power           |   `exp = exp1 ^ exp2`   |

The second table defines the logic/comparison operators: and, or, equality, inequality, less than, less than or equal to, greater than, and greater than or equal to.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|            And            |   `exp = exp1 & exp2`   |
|             Or            |   `exp = exp1 \| exp2`  |
|          Equal to         |  `exp = exp1:eq(exp2)`  |
|        Not Equal to       |  `exp = exp1:ne(exp2)`  |
|         Less-than         |  `exp = exp1:lt(exp2)`  |
|   Less-than-or-equals to  |  `exp = exp1:le(exp2)`  |
|        Greater-than       |  `exp = exp1:gt(exp2)`  |
| Greater-than-or-equals to |  `exp = exp1:ge(exp2)`  |

The third table defines two element-wise max and min methods between the two data arguments.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|          Maximum          | `exp = max(exp1, exp2)` |
|          Minimum          | `exp = min(exp1, exp2)` |

<br/>

All the above-mentioned binary expressions follow the same rules to define the stages, scenarios, blocks, and agents of the resulting output.

### Stages and Scenarios

| exp1     | exp2     | exp         |
|:--------:|:--------:|:-----------:|
| `1`      | `1`      | `1`         |
| `n1`     | `1`      | `n1`        |
| `1`      | `n2`     | `n2`        |
| `n1`     | `n2`     | `min{n1,n2}`|

<br/>

### Block and Hours

| exp1 or exp2     | exp     |
|:----------------:|:-------:|
| none / none      | none    |
| block / none     | block   |
| block / block    | block   |
| hour / none      | hour    |
| hour / hour      | hour    |
| block / hour     | ❌      |

<br/>

### Agents (when order matters)

| exp1                | exp2                | exp                 |
|:-------------------:|:-------------------:|:-------------------:|
| `n1` (collection a) | `n2` (collection b) | `n1` (collection a) |
| `n1` (generic a)    | `n2` (generic b)    | `n1` (generic a)    |

<br/>

### Agents (when the order does not matter)

| exp1 or exp2                           | exp                 |
|:--------------------------------------:|:-------------------:|
| `1` (collection a) / `n` (generic b)   | `n` (generic b)     |
| `n1` (collection a) / `1` (generic b)  | `n1` (collection a) |
| `n` (collection a) / `n` (generic b)   | `n` (collection b)  |
| `n1` (collection a) / `n2` (generic b) | ❌                  |
| `n` (generic a) / `1` (generic b)      | `n` (generic a)     |
| `n1` (generic a) / `n2` (generic b)    | ❌                  |

<br/>

## Ternary Expressions

| Operator    | Syntax                           |
|:------------|:---------------------------------|
| Conditional | `exp = ifelse(exp1, exp2, exp3)` |