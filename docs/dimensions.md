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

When analyzing simulation outputs, we are often interested in finding one single value that represents a set. PSRIO provides a set of methods to accomplish this kind of task with a high level of abstraction, the [aggregate functions][aggregate-functions]. One can choose many forms of how the output values will be aggregated. The table below shows the options offered by PSRIO:

| Aggregate Functions        | Description  |
|:-------------------------- |:-----------------------------------------------------------------------------------------------|
| `BY_SUM()`                 | Sums the elements of a set                                                                     |                     
| `BY_AVERAGE()`             | Takes the average of the elements of a set                                                     |   
| `BY_MAX()`                 | Selects the maximum value of a set                                                             |   
| `BY_MIN()`                 | Selects the minimum value of a set                                                             |   
| `BY_CVAR_L(number)`        | Calculates the expected shortfall for the left-tail case with the specified probability in %   |   
| `BY_CVAR_R(number)`        | Calculates the expected shortfall for the right-tail case with the specified probability in %  |   
| `BY_PERCENTILE(number)`    | Returns the score associated with the specified percentile                                     |   
| `BY_NTH_ELEMENT(number)`   | Takes the specified n<sup>th</sup> value of a set                                              |   
| `BY_STDDEV()`              | Calculates standard deviation of a set                                                         |   
| `BY_FIRST_VALUE()`         | Takes the first value of a set                                                                 |   
| `BY_LAST_VALUE()`          | Takes the last value of a set                                                                  |   

The methods above are only specifying how the methods will execute the aggregations. The aggregation itself is carried out by other methods, which are described in the sections below.

## Scenarios

### Aggregate Scenarios

To aggregate scenarios of an specific output, the following methods should be used:

| Method                                                                       | Syntax                                               |
|:-----------------------------------------------------------------------------|:-----------------------------------------------------|
| Aggregate scenarios by an [aggregate function][aggregate-functions]          | `exp = exp1:aggregate_scenarios(f)`                  |
| Aggregate selected scenarios by an [aggregate function][aggregate-functions] | `exp = exp1:aggregate_scenarios(f, {int, int, ...})` |

#### Example 1
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_average = cmgdem:aggregate_scenarios(BY_AVERAGE());
```

#### Example 2
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_p90 = cmgdem:aggregate_scenarios(BY_PERCENTILE(90));
```

#### Example 3
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_max = cmgdem:aggregate_scenarios(BY_MAX(), {1, 2, 3, 4, 5});
```

### Select Scenarios

To aggregate scenarios of a specific output, we use the following methods:

| Method                    | Syntax                                               |
|:--------------------------|:-----------------------------------------------------|
| Select one scenario       | `exp = exp1:select_scenario(int)`                    |
| Select multiple scenarios | `exp = exp1:select_scenarios({int, int, ...})`       |

#### Example 1
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_scenario32 = cmgdem:select_scenario(32);
```

## Blocks/Hours

### Aggregate Blocks/Hours

To aggregate blocks or hours of an output, we can use the functions below:

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Aggregate blocks/hours by an [aggregate function][aggregate-functions] | `exp = exp1:aggregate_blocks(f)` |

#### Example 1
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE());
```

#### Example 2
{: .no_toc }

``` lua
renewable = Renewable();
gergnd = renewable:load("gergnd");

gergnd_agg = gergnd:aggregate_blocks(BY_SUM());
```

### Select Blocks/Hours

In order to select a specific block or hour, use:

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Select one block/hour                                                  | `exp = exp1:select_block(int)`   |

#### Example 1
{: .no_toc }

``` lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_block21 = cmgdem:select_block(21);
```

### Map Blocks/Hours

PSRIO can explore the relationship between blocks and hours with the methods in the table below.

| Method                                                                 | Syntax                           |
|:-----------------------------------------------------------------------|:---------------------------------|
| Map blocks into hours (`BY_AVERAGE()` or `BY_REPEATING()`)             | `exp = exp1:to_hour(type)`       |
| Map hour into blocks (`BY_AVERAGE()` or `BY_SUM()`)                    | `exp = exp1:to_block(type)`      |

#### Example 1
{: .no_toc }

``` lua
system = System();
cmgdem_block = thermal:load("cmgdem");

cmgdem_hourly = cmgdem_block:to_hour(BY_REPEATING());
```

#### Example 2
{: .no_toc }

``` lua
thermal = Thermal();
gerter_hourly = thermal:load("gerter");

gerter_block = gerter_hourly:to_block(BY_SUM());
```

## Stages

### Aggregate Stages

Stages can be aggregated with the functions below. For example, it is possible to cluster the stages in weeks, months, or years and aggregate them regarding their respective groups, as explained in the section [profiles][profiles].

| Method                                                                                             | Syntax                                    |
|:---------------------------------------------------------------------------------------------------|:------------------------------------------|
| Aggregate stages by an [aggregate function][aggregate-functions]                                   | `exp = exp1:aggregate_stages(f)`          |
| Aggregate stages by an [aggregate function][aggregate-functions] and a [profile][profiles]         | `exp = exp1:aggregate_stages(f, profile)` |

### Profiles
{: .no_toc }

| Profiles                 |
|:------------------------:|
| `Profile.STAGE`          | 
| `Profile.WEEK`           | 
| `Profile.MONTH`          | 
| `Profile.YEAR`           | 
| `Profile.PER_WEEK`       | 
| `Profile.PER_MONTH`      |
| `Profile.PER_YEAR`       | 

### Profile.STAGE
{: .no_toc }

The `Profile.STAGE` is the default value to characterize the aggregation if the user does not inform any profile. The data associated with each stage of the study horizon is aggregated.

| exp1          | exp (`Profile.STAGE`) |
|:-------------:|:-------------------:|
| `n` (daily)   | `1` (daily)         |
| `n` (weekly)  | `1` (weekly)        |
| `n` (monthly) | `1` (monthly)       |
| `n` (yearly)  | `1` (yearly)        |

#### Example 1
{: .no_toc }

### Profile.WEEK and Profile.PER_WEEK
{: .no_toc }

When the data has a daily resolution and the aggregation profile is `Profile.WEEK`, PSRIO will aggregate the data for each day of the weeks in the study period, i.e., that data regarding all Mondays in the data set will be aggregated into one value and the same for Tuesday, Wednesday, and so on. With a daily resolution and the aggregation `Profile.PER_WEEK`, PSRIO will aggregate the data related to each week of the study. 

When the data is weekly and we request is `Profile.WEEK`, the data associated with each week is aggregated in one week. If the request is the aggregation `Profile.PER_WEEK`, PSRIO will do nothing and the data will remains the same.

**These aggregation profiles are not defined for monthly and yearly resolution data**.  

| exp1          | exp (`Profile.WEEK`) | exp (`Profile.PER_WEEK`) |
|:-------------:|:------------------:|:----------------------:|
| `n` (daily)   | `7` (daily)        | `n/7` (weekly)         |
| `n` (weekly)  | `1` (weekly)       | `n` (weekly)           |
| `n` (monthly) | ❌                |  ❌                    |
| `n` (yearly)  | ❌                |  ❌                    |

#### Example 1
{: .no_toc }

```lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE(), profile.WEEK);
```

#### Example 2
{: .no_toc }

```lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE(), profile.PER_WEEK);
```

### Profile.MONTH and Profile.PER_MONTH
{: .no_toc }

Similar to `Profile.WEEK` and `Profile.PER_WEEK`, when the data has daily discretization and we request `Profile.MONTH`, PSRIO will aggregate the data for each day of the months in the study period. For example, PSRIO will aggregate all 1<sup>st</sup> days of each month and the same for the others months. If we request the `Profile.PER_MONTH`, PSRIO will aggregate the data related to each month.

When the data has month-level discretization and we request `Profile.MONTH`, PSRIO will aggregate the data associated with each month. If we request `Profile.PER_MONTH`, nothing is done to the data. 

**These aggregation profiles are not defined for weekly and yearly resolution data**.  

| exp1          | exp (`Profile.MONTH`) | exp (`Profile.PER_MONTH`) |
|:-------------:|:---------------------:|:-------------------------:|
| `n` (daily)   | `31` (daily)          | `n/~30` (monthly)         |
| `n` (weekly)  | ❌                   | ❌                        |
| `n` (monthly) | `1` (monthly)         | `n` (monthly)             |
| `n` (yearly)  | ❌                   | ❌                        |

#### Example 1
{: .no_toc }

```lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE(), profile.MONTH);
```

#### Example 2
{: .no_toc }

```lua
system = System();
cmgdem = system:load("cmgdem");

cmgdem_agg = cmgdem:aggregate_blocks(BY_AVERAGE(), profile.PER_MONTH);
```

### Profile.YEAR and Profile.PER_YEAR
{: .no_toc }

When the data has a daily resolution and we request a `Profile.YEAR`, the data related to each day of years is aggregated. For example, PSRIO will aggregate all January 1<sup>st</sup> days in the study period, which is done for the other days of the year. If we request a` Profile.PER_YEAR`, the data associated with each year is aggregated. The same happens when the data has week, month, or year-level resolution if `Profile.PER_YEAR` is selected.

If the data has a year resolution and `profile.YEAR` is selected. the data related to the same year is aggregated.

**The `profile.YEAR` profile is not defined for weekly and monthly resolution data**.  

| exp1          | exp (`Profile.YEAR`) | exp (`Profile.PER_YEAR`) |
|:-------------:|:--------------------:|:------------------------:|
| `n` (daily)   | `365` (daily)        | `n/365` (yearly)         |
| `n` (weekly)  | `52` (weekly)        | `n/52` (yearly)          |
| `n` (monthly) | `12` (monthly)       | `n/12` (yearly)          |
| `n` (yearly)  | `1` (yearly)         | `1` (yearly)             |

#### Example 1
{: .no_toc }

``` lua
system = System();
defcit = system:load("defcit");

defcit_per_year = defcit:aggregate_stages(BY_SUM(), Profile.YEAR);
```

#### Example 2
{: .no_toc }

``` lua
system = System()
defcit = system:load("defcit")

defcit_per_year = defcit:aggregate_stages(BY_SUM(), Profile.PER_YEAR);
```

### Select Stages

The stages of a study period can be select by its indexes or by their associated years. PSRIO can select a single or contiguous interval of stages with the methods shown in the table below:

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Select stages within case horizon                                      | `exp = exp1:select_stages()`                 |
| Select a **stage**                                                     | `exp = exp1:select_stages(int)`              |
| Select stages by **first** and **last stage**                          | `exp = exp1:select_stages(int, int)`         |
| Select stages by **initial** and **final year**                        | `exp = exp1:select_stages_by_year(int, int)` |
| Select stages by a **year**                                            | `exp = exp1:select_stages_by_year(int)`      |

#### Example 1
{: .no_toc }

``` lua
generic = Generic();
objcop = generic:load("objcop");

exp1 = objcop:select_stages();
exp2 = objcop:select_stages(1);
exp3 = objcop:select_stages(13, 24);
exp4 = objcop:select_stages_by_year(2026, 2050);
exp5 = objcop:select_stages_by_year(2032);
```

### Reshape Stages

For an hourly represented data, the stage resolution can changed from a week, month or year level to a daily one using the method below:

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Reshape stages frequency to daily (only works with hourly input)       | `exp = exp1:reshape_stages(Profile.DAILY)`   |


| exp1                   | exp                    |
|:----------------------:|:----------------------:|
| `n` (daily-hourly)     | `n` (daily-hourly)     |
| `n` (weekly-hourly)    | `7n` (daily-hourly)    |
| `n` (monthly-hourly)   | `~30n` (daily-hourly)  |
| `n` (yearly-hourly)    | `365n` (daily-hourly)  |


#### Example 1
{: .no_toc }

``` lua
thermal = Thermal();
gerter = thermal:load("gerter");

gerter_daily = gerter:reshape_stages(Profile.DAILY)
```

## Agents

Agents are the entities associated with the output results. For example, Hydro Generation is a variable that applies to hydro plants, which are agents. Analogously, Fuel Consumption is variable that applies to fuels, which are agents. The table below lists all agent collections available in PSRIO:

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

### Aggregate Agents

Just like the stages, the agents of a study can be aggregated with the following methods:

| Method                                                                                            | Syntax                                         |
|:--------------------------------------------------------------------------------------------------|:-----------------------------------------------|
| Aggregate all agents by an [aggregate function][aggregate-functions]                              | `exp = exp1:aggregate_agents(f, label)`        |
| Aggregate agents by an [aggregate function][aggregate-functions] into a [collection][collections] | `exp = exp1:aggregate_agents(f, collection)`   |

#### Example 1
{: .no_toc }

``` lua
hydro = Hydro();
gerhid = hydro:load("gerhid");

gerhid_sum = gerhid:aggregate_agents(BY_SUM(), "Total Hydro");
```

#### Example 2
{: .no_toc }

``` lua
hydro = Hydro();
gerhid = hydro:load("gerhid");

gerhid_systems = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM);
```

#### Example 3
{: .no_toc }

``` lua
hydro = Hydro();
gerhid = hydro:load("gerhid");

gerhid_buses = gerhid:aggregate_agents(BY_SUM(), Collection.BUSES);
```

### Select Agents

We can use the selection methods to filter the agents that contain some desired information. The names or indexes can filter data, collections of the agents, and logical expressions when selecting agents by queries.

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Select agents by a list of agents names or indices                         | `exp = exp1:select_agents({string or int, int or string, ...})` |
| Select agents by a [collection][collections]                               | `exp = exp1:select_agents(collection)`                          |
| Select agents by a query                                                   | `exp = exp1:select_agents(query)`                               |

#### Example 1
{: .no_toc }

``` lua
thermal = Thermal();
gerter = thermal:load("gerter");

gerter_t1_and_t2 = gerter:select_agents({"Thermal 1", "Thermal 2"});
```

#### Example 2
{: .no_toc }

``` lua
expansion_project = ExpansionProject()
outidec = expansion_project:load("outidec");

outidec_dclinks = outidec:select_agents(Collection.DCLINK);
```

#### Example 3
{: .no_toc }

``` lua
thermal = Thermal();
gerter = thermal:load("gerter");

non_zero_gerter = gerter:select_agents(gerter:ne(0));
```

### Remove Agents

We should use the following methods to remove the agents from a data set:

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Remove agents by a list of agents names or indices                         | `exp = exp1:remove_agents({string or int, int or string, ...})` |

### Rename Agents

We should use the following methods to rename the agents from a data set:

| Method                                                                     | Syntax                                                          |
|:---------------------------------------------------------------------------|:----------------------------------------------------------------|
| Rename the agents based on the input vector                                | `exp = exp1:rename_agents({string, string, ...})`               |
| Rename all the agents names                                                | `exp = exp1:rename_agents(string)`                              |
| Add a suffix to all agents names                                           | `exp = exp1:rename_agents_with_suffix(string)`                  |

#### Example 1
{: .no_toc }

``` lua
thermal = Thermal();
gerter = thermal:load("gerter");

gerter_renamed = gerter:rename_agents({"T1", "T2", "T3"});
```

### Concatenate Agents

The concanation method allows the unification of data from different files. To concatenate data, use the method below:

| Method      | Syntax                                                          |
|:------------|:----------------------------------------------------------------|
| Concatenate | `exp = concatenate(exp1, exp2, exp3, ...)`                      |

#### Example 1
{: .no_toc }

``` lua
hydro = Hydro();
gerhid = hydro:load("gerhid");

thermal = Thermal();
gerter = thermal:load("gerter");
    
renewable = Renewable();
gergnd = renewable:load("gergnd");
    
generation = concatenate(gerhid, gerter, gergnd);
```

[aggregate-functions]: https://psrenergy.github.io/psrio-scripts/dimensions.html#aggregate-functions
[aggregate-stages]: https://psrenergy.github.io/psrio-scripts/dimensions.html#aggregate-stages
[collections]: https://psrenergy.github.io/psrio-scripts/dimensions.html#collections
[profiles]: https://psrenergy.github.io/psrio-scripts/dimensions.html#profiles