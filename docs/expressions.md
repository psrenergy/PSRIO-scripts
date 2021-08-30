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

PSRIO provides four unary operators that only receive one expression and does not modify any dimension (stages, blocks, scenarios, or agents). The unary minus maps the data values to their additive inverses; the absolute value is the non-negative value of the data without regard to its sign; the round method rounds the data to the specified number of digits after the decimal separator; the convert method determines the unit of the data. 

<br/>

|     Operator    |            Syntax            |
|:----------------|:-----------------------------|
| Unary Minus     | `exp = -exp1`                |
| Absolute Value  | `exp = exp1:abs()`           |
| Round           | `exp = exp1:round(int)`      |
| Convert         | `exp = exp1:convert(string)`   |

<br/>

#### Example 1
{: .no_toc }

The example below takes the power flow in a circuit and calculates its absolute values.

``` lua
circuit = Circuit();
cirflw = circuit:load("cirflw");

abs_cirflw = cirflw:abs();
```

#### Example 2
{: .no_toc}

Here, we use the convert method to act over the generation data of a set of thermal plants given in GWh and convert it to MW.

``` lua
thermal = Thermal();
thermal_gen = circuit:load("gerter");

converted_thermal_gen = thermal_gen:convert("MW");
```

## Binary Expressions

PSRIO provides binary operators which can change attributes (stages, blocks, scenarios, and agents) depending on inputs. The first table presents the supported arithmetic operators.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|          Addition         |   `exp = exp1 + exp2`   |
|        Subtraction        |   `exp = exp1 - exp2`   |
|       Multiplication      |   `exp = exp1 * exp2`   |
|       Right Division      |   `exp = exp1 / exp2`   |
|           Power           |   `exp = exp1 ^ exp2`   |

The second table defines the logical and comparison operators.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|          Equal to         |  `exp = exp1:eq(exp2)`  |
|        Not Equal to       |  `exp = exp1:ne(exp2)`  |
|         Less-than         |  `exp = exp1:lt(exp2)`  |
|   Less-than-or-equals to  |  `exp = exp1:le(exp2)`  |
|        Greater-than       |  `exp = exp1:gt(exp2)`  |
| Greater-than-or-equals to |  `exp = exp1:ge(exp2)`  |
|            And            |   `exp = exp1 & exp2`   |
|             Or            |   `exp = exp1 | exp2`   |

The third table defines two element-wise max and min methods between the two data arguments.

|          Operator         |          Syntax         |
|:--------------------------|:------------------------|
|          Maximum          | `exp = max(exp1, exp2)` |
|          Minimum          | `exp = min(exp1, exp2)` |

Here are some examples of binary expressions.

#### Example 1
{: .no_toc }

Calculating the useful storage of a hydro plant:
``` lua
hydro = Hydro();
useful_storage = hydro.vmax - hydro.vmin;
```

#### Example 2
{: .no_toc }

Comparing the generation of a thermal plant with its maximum capacity:
``` lua
thermal = Thermal();

thermal_gen = thermal:load("gerter");
thermal_cap = thermal:load("potter");

gen_gt_cap = (thermal_gen:convert("MW")):gt(thermal_cap);
```

Note that, since the generation data is in GWh and the capacity in MW, a unit conversion is needed to compare them. 

#### Example 3
{: .no_toc}

Getting the highest total generated energy per type of plant: 
```lua
thermal = Thermal();
hydro = Hydro();

gerter = thermal:load("gerter");
gerhid = hydro:load("gerhid");

total_gerter = gerter:aggregate_agents(BY_SUM(), "Total Thermal Gen");
total_gerhid = gerhid:aggregate_agents(BY_SUM(), "Total Hydro Gen");

max_generation =  max(total_gerter, total_gerhid);
```

Thermal and hydro generation are not directly compared. To compare them, we first need to aggregate the agents to obtain only one representative agent containing generation per block, scenario, and stage in each data set. Then, we can compare them.

<br/>

All the above-mentioned binary expressions follow the same rules to define the resulting output's stages, scenarios, blocks, and agents.

### Stages and Scenarios

If one expression has n stages, and the other has only `1`, the result will have `n` stages. If the `exp1` has `n1` stages and `exp2` has `n2`, the resulting expression will have `n3` as the minimum number of stages between the two. In other words, `n3 = min{n1, n2}`. If both expressions have `1` stage, the result will naturally have also `1`. The same rule is applied to the scenarios. The table below summarizes the explanation:

| exp1     | exp2     | exp         |
|:--------:|:--------:|:-----------:|
| `1`      | `1`      | `1`         |
| `n1`     | `1`      | `n1`        |
| `1`      | `n2`     | `n2`        |
| `n1`     | `n2`     | `min{n1,n2}`|

<br/>

### Block and Hours

The following table describes the blocks and hours rules. The only operation that is not allowed is mixing expressions that vary per block and hour. 

| exp1 or exp2     | exp     |
|:----------------:|:-------:|
| none / none      | none    |
| block / none     | block   |
| block / block    | block   |
| hour / none      | hour    |
| hour / hour      | hour    |
| block / hour     | ❌      |

<br/>

<!-- ### Agents (when order matters)

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
| `n1` (generic a) / `n2` (generic b)    | ❌                  | -->

## Ternary Expressions

The table below presents the `ifelse`. Likewise, the above-defined operators, the `ifelse` follow dataframe rules, doing element-wise operations. If the element of `exp1` is true, `exp2` is the result, otherwise, it is exp3.

| Operator    | Syntax                           |
|:------------|:---------------------------------|
| Conditional | `exp = ifelse(exp1, exp2, exp3)` |

#### Example 1
{: .no_toc }

In the example below, if the thermal generation is greater than zero, 1 is returned; otherwise, 0 is returned.

```lua
thermal = Thermal();

gerter = thermal:load("gerter");

gerter_gt_zero = ifelse(gerter:gt(0.0), 1, 0);
```

<br/>

## Unit Conversion

<div style="text-align:center">
    <img src="images/si.svg" width="200"/>
</div>

The units conversion follows the International System of Units (SI), based on the [2019 redefinition](https://www.nist.gov/si-redefinition). The PSRIO will perform a multi-step process with all the expressions inputs, producing a conversion factor with the desired unit.

|     Operator    |            Syntax            |
|:----------------|:-----------------------------|
| Unit Conversion | `exp = exp1:convert("unit")` |


#### Example 1
{: .no_toc }

``` lua
hydro = Hydro();
fprodt = hydro:load("fprodt");
    
pothid = min(hydro.qmax * fprodt, hydro.capacity_maintenance);
```

In this example we have two inputs with different units: `hydro.qmax` `[m3/s]` and `fprodt` `[MW/(m3/s)]`. The pothid output will be the multiplication: `[m3/s] × [MW/(m3/s)] = 1.0 × [MW]`.

#### Example 2
{: .no_toc }

```lua
renewable = Renewable();
gergnd = renewable:load("gergnd");
vergnd = renewable:load("vergnd");
    
captured_prices = (gergnd * vergnd) / (gergnd + vergnd);
```

The unit conversion output of Example 2 is `([GWh] × [GWh]) / ([GWh] + [GWh]) = 1.0 × [GWh]`

#### Example 3
{: .no_toc }

``` lua
thermal = Thermal();
fuel = Fuel();
    
cinte1 = (thermal.cesp1 * (thermal.transport_cost + fuel.cost) + thermal.omcost);
```

The unit conversion output of Example 3 is `[gal/MWh] × ([$/gal] + [$/gal]) + [$/MWh] = 1.0 × [$/MWh]`

#### Example 4
{: .no_toc }

``` lua
hydro = Hydro();
volfin = hydro:load("volfin");
fprodtac = hydro:load("fprodtac");
    
eneemb = ((volfin - hydro.vmin) * fprodtac):convert("GWh");
```

The unit conversion output of Example 4 is `([hm3] - [hm3]) × [MW/(m3/s)] = 0.27 × [GWh]`
