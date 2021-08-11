---
title: Dimensions
nav_order: 6
---

# Dimensions
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Aggregate Functions

| Aggregate Functions        |
|:--------------------------:|
| `BY_SUM()`                 |
| `BY_AVERAGE()`             |
| `BY_MAX()`                 |
| `BY_MIN()`                 |
| `BY_CVAR_L(number)`        |
| `BY_CVAR_R(number)`        |
| `BY_PERCENTILE(number)`    |
| `BY_NTH_ELEMENT(number)`   |
| `BY_STDDEV()`              |
| `BY_FIRST_VALUE()`         |
| `BY_LAST_VALUE()`          |

<br/>

## Aggregate Scenarios

| Method                                                                       | Syntax                                               |
|:-----------------------------------------------------------------------------|:-----------------------------------------------------|
| Aggregate scenarios by an [aggregate function][aggregate-functions]          | `exp = exp1:aggregate_scenarios(f)`                  |
| Aggregate selected scenarios by an [aggregate function][aggregate-functions] | `exp = exp1:aggregate_scenarios(f, {int, int, ...})` |

<br/>

#### Example 1
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_average = cmgdem:aggregate_scenarios(BY_AVERAGE());
```

#### Example 2
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_p90 = cmgdem:aggregate_scenarios(BY_PERCENTILE(90));
```

#### Example 3
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_max = cmgdem:aggregate_scenarios(BY_MAX(), {1, 2, 3, 4, 5});
```

## Select Scenarios

| Method                    | Syntax                                               |
|:--------------------------|:-----------------------------------------------------|
| Select one scenario       | `exp = exp1:select_scenario(int)`                    |
| Select multiple scenarios | `exp = exp1:select_scenarios({int, int, int, ...})`  |

<br/>

#### Example 1
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_scenario32 = cmgdem:select_scenario(32);
```

<br/>

## Aggregate Blocks/Hours

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Aggregate blocks/hours by an [aggregate function][aggregate-functions] | `exp = exp1:aggregate_blocks(f)` |

<br/>

#### Example 1
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE());
```

#### Example 2
{: .no_toc }

``` lua
renewable = require("collection/renewable");
gergnd = renewable:load("gergnd");

gergnd_agg = gergnd:aggregate_blocks(BY_SUM());
```

## Select Block/Hour

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Select one block                                                       | `exp = exp1:select_block(int)`   |

<br/>

#### Example 1
{: .no_toc }

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");

cmgdem_block21 = cmgdem:select_block(21);
```

## Map Blocks/Hours

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Map blocks into hours (`BY_AVERAGE()` or `BY_REPEATING()`)             | `exp = exp1:to_hour(type)`       |
| Map hour into blocks (`BY_AVERAGE()` or `BY_SUM()`)                    | `exp = exp1:to_block(type)`      |

<br/>

#### Example 1
{: .no_toc }

TODO to_hour e to_block exemplo
``` lua

```

<br/>

## Aggregate Stages

### Profiles
{: .no_toc }

| Profiles                 |
|:------------------------:|
| `PROFILE.STAGE`          |
| `PROFILE.WEEK`           | 
| `PROFILE.MONTH`          | 
| `PROFILE.YEAR`           | 
| `PROFILE.PER_WEEK`       | 
| `PROFILE.PER_MONTH`      |
| `PROFILE.PER_YEAR`       | 

<br/>

| Method                                                                                             | Syntax                                    |
|:---------------------------------------------------------------------------------------------------|:------------------------------------------|
| Aggregate stages by an [aggregate function][aggregate-functions]                                   | `exp = exp1:aggregate_stages(f)`          |
| Aggregate stages by an [aggregate function][aggregate-functions] and a [profile][profiles]         | `exp = exp1:aggregate_stages(f, profile)` |

<br/>

### Profile: STAGE
{: .no_toc }

| exp1          | exp (profile = STAGE) |
|:-------------:|:---------------------:|
| `n` (daily)   | `1` (daily)           |
| `n` (weekly)  | `1` (weekly)          |
| `n` (monthly) | `1` (monthly)         |
| `n` (yearly)  | `1` (yearly)          |

### Profile: WEEK and PER_WEEK
{: .no_toc }

| exp1          | exp (profile = WEEK) | exp (profile = PER_WEEK) |
|:-------------:|:--------------------:|:------------------------:|
| `n` (daily)   | `7` (daily)          | `n/7` (weekly)           |
| `n` (weekly)  | `1` (weekly)         | `n` (weekly)             |
| `n` (monthly) | ❌                  |  ❌                      |
| `n` (yearly)  | ❌                  |  ❌                      |

### Profile: MONTH and PER_MONTH
{: .no_toc }

| exp1          | exp (profile = MONTH) | exp (profile = PER_MONTH) |
|:-------------:|:---------------------:|:-------------------------:|
| `n` (daily)   | `31` (daily)          | `n/~30` (monthly)         |
| `n` (weekly)  | ❌                   | ❌                        |
| `n` (monthly) | `1` (monthly)         | `n` (monthly)             |
| `n` (yearly)  | ❌                   | ❌                        |

### Profile: YEAR and PER_YEAR
{: .no_toc }

| exp1          | exp (profile = YEAR) | exp (profile = PER_YEAR) |
|:-------------:|:--------------------:|:------------------------:|
| `n` (daily)   | `365` (daily)        | `n/365` (yearly)         |
| `n` (weekly)  | ❌                  |  `n/52` (yearly)         |
| `n` (monthly) | ❌                  |  `n/12` (yearly)        |
| `n` (yearly)  | `1` (yearly)         | `1` (yearly)             |


#### Example 1
{: .no_toc }

``` lua
exp = defcit:aggregate_stages(BY_SUM(), Profile.PER_YEAR);
```

<br/>

## Select Stages

<br/>

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Select stages within case horizon                                      | `exp = exp1:select_stages()`                 |
| Select stage by only one stage                                         | `exp = exp1:select_stages(int)`              |
| Select stages by first_stage and last_stage                            | `exp = exp1:select_stages(int, int)`         |
| Select stages by initial_year and final_year                           | `exp = exp1:select_stages_by_year(int, int)` |
| Select stages by only one year                                         | `exp = exp1:select_stages_by_year(int)`      |

<br/>

#### Example 1
{: .no_toc }

``` lua
generic = require("collection/generic");
objcop = generic:load("objcop");

exp1 = objcop:select_stages();
exp2 = objcop:select_stages(1);
exp3 = objcop:select_stages(13, 24);
exp4 = objcop:select_stages_by_year(2026, 2050);
exp5 = objcop:select_stages_by_year(2032);
```

## Reshape Stages

<br/>

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Reshape stages frequency to daily (only works with hourly input)       | `exp = exp1:reshape_stages(PROFILE.DAILY)`   |

<br/>

| exp1            | exp             |
|:---------------:|:---------------:|
| `n` (daily)     | `n` (daily)     |
| `n` (weekly)    | `7n` (daily)    |
| `n` (monthly)   | `~30n` (daily)  |
| `n` (yearly)    | `365n` (daily)  |

<br/>

#### Example
{: .no_toc }

``` lua
```

## Agents

### Collections

|           Collection          | Syntax                                     |
|:-----------------------------:|:------------------------------------------:|
| Area                          | `Collection.AREA`                          |
| Balancing Area                | `Collection.BALANCINGAREA`                 |
| Balancing Area Hydro          | `Collection.BALANCINGAREA_HYDRO`           |
| Balancing Area Thermal        | `Collection.BALANCINGAREA_THERMAL`         |
| Battery                       | `Collection.BATTERY`                       |
| Bus                           | `Collection.BUS`                           |
| Circuit                       | `Collection.CIRCUIT`                       |
| Circuits Sum                  | `Collection.CIRCUITS_SUM`                  |
| DC Link                       | `Collection.DCLINK`                        |
| Demand                        | `Collection.DEMAND`                        |
| Demand Segment                | `Collection.DEMAND_SEGMENT`                |
| Expansion Project             | `Collection.EXPANSION_PROJECT`             |
| Fuel                          | `Collection.FUEL`                          |
| Fuel Consumption              | `Collection.FUEL_CONSUMPTION`              |
| Fuel Contract                 | `Collection.FUEL_CONTRACT`                 |
| Fuel Reservoir                | `Collection.FUEL_RESERVOIR`                |
| Generator                     | `Collection.GENERATOR`                     |
| Generation Constraint         | `Collection.GENERATION_CONSTRAINT`         |
| Hydro                         | `Collection.HYDRO`                         |
| Interconnection               | `Collection.INTERCONNECTION`               |
| Power Injection               | `Collection.POWERINJECTION`                |
| Renewable                     | `Collection.RENEWABLE`                     |
| Renewable Gauging Station     | `Collection.RENEWABLE_GAUGING_STATION`     |
| Reserve Generation Constraint | `Collection.RESERVE_GENERATION_CONSTRAINT` |
| System                        | `Collection.SYSTEM`                        |
| Thermal                       | `Collection.THERMAL`                       |

<br/>

### Aggregate Agents

<br/>

| Method                                                                                            | Syntax                                         |
|:--------------------------------------------------------------------------------------------------|:-----------------------------------------------|
| Aggregate all agents by an [aggregate function][aggregate-functions]                              | `exp = exp1:aggregate_agents(f, label)`        |
| Aggregate agents by an [aggregate function][aggregate-functions] into a [collection][collections] | `exp = exp1:aggregate_agents(f, collection)`   |

#### Example 1
{: .no_toc }

``` lua
hydro = require("collection/hydro");
gerhid = hydro:load("gerhid");

gerhid_sum = gerhid:aggregate_agents(BY_SUM(), "Total Hydro");
```

#### Example 2
{: .no_toc }

``` lua
hydro = require("collection/hydro");
gerhid = hydro:load("gerhid");

gerhid_systems = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM);
```

#### Example 3
{: .no_toc }

``` lua
hydro = require("collection/hydro");
gerhid = hydro:load("gerhid");

gerhid_buses = gerhid:aggregate_agents(BY_SUM(), Collection.BUSES);
```

### Select Agents

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Select agents by a list of agents names or indices                         | `exp = exp1:select_agents({string or int, int or string, ...})` |
| Select agents by a [collection][collections]                               | `exp = exp1:select_agents(collection)`                          |
| Select agents by a query                                                   | `exp = exp1:select_agents(query)`                               |
| Remove agents by a list of agents names or indices                         | `exp = exp1:remove_agents({string or int, int or string, ...})` |

#### Example 1
{: .no_toc }

``` lua
thermal = require("collection/thermal");
gerter = thermal:load("gerter");

gerter_t1_and_t2 = gerter:select_agents({"Thermal 1", "Thermal 2"});
```

### Remove Agents

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Remove agents by a list of agents names or indices                         | `exp = exp1:remove_agents({string or int, int or string, ...})` |

### Rename Agents

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Rename the agents based on the input vector                                | `exp = exp1:rename_agents({string, string, ...})`               |
| Rename all the agents names                                                | `exp = exp1:rename_agents(string)`                              |
| Add a suffix to all agents names                                           | `exp = exp1:rename_agents_with_suffix(string)`                  |

#### Example 1
{: .no_toc }

``` lua
thermal = require("collection/thermal");
gerter = thermal:load("gerter");

gerter_renamed = gerter:rename_agents({"T1", "T2", "T3"});
```

### Concatenate Agents

| Method      | Syntax                                                          |
|:------------|:----------------------------------------------------------------|
| Concatenate | `exp = concatenate(exp1, exp2, exp3, ...)`                      |

#### Example 1
{: .no_toc }

``` lua
hydro = require("collection/hydro");
gerhid = hydro:load("gerhid");

thermal = require("collection/thermal");
gerter = thermal:load("gerter");
    
renewable = require("collection/renewable");
gergnd = renewable:load("gergnd");
    
generation = concatenate(gerhid, gerter, gergnd);
```

[aggregate-functions]: https://psrenergy.github.io/psrio-scripts/dimensions.html#aggregate-functions
[aggregate-stages]: https://psrenergy.github.io/psrio-scripts/dimensions.html#aggregate-stages
[collections]: https://psrenergy.github.io/psrio-scripts/dimensions.html#collections
[profiles]: https://psrenergy.github.io/psrio-scripts/dimensions.html#profiles