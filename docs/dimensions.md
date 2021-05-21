---
title: Dimensions
nav_order: 5
---

# Dimensions
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Aggregate Functions

| Description |          Syntax          |
|:-----------:|:------------------------:|
|             | `BY_SUM()`               |
|             | `BY_AVERAGE()`           |
|             | `BY_MAX()`               |
|             | `BY_MIN()`               |
|             | `BY_CVAR_L(number)`      |
|             | `BY_CVAR_R(number)`      |
|             | `BY_PERCENTILE(number)`  |
|             | `BY_NTH_ELEMENT(number)` |
|             | `BY_STDDEV`              |
|             | `BY_FIRST_VALUE()`       |
|             | `BY_LAST_VALUE()`        |

<br/>

## Scenarios

| Method                                        | Syntax                                       |
|:----------------------------------------------|:---------------------------------------------|
| Aggregate scenarios by agg (table 4)          | `exp = exp1:aggregate_scenarios(agg)`        |
| Aggregate selected scenarios by agg (table 4) | `exp = exp1:aggregate_scenarios(agg, {int})` |

<br/>

``` lua
exp = cmgdem:aggregate_scenarios(BY_AVERAGE());

exp = cmgdem:aggregate_scenarios(BY_PERCENTILE(50));

exp = cmgdem:aggregate_scenarios(BY_MAX(), {1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
```

<br/>

## Blocks and Hours

| Method                                        | Syntax                                       |
|:----------------------------------------------|:---------------------------------------------|
| Aggregate blocks/hours by agg (table 4)       | `exp = exp1:aggregate_blocks(agg)`           |

<br/>

``` lua
exp = cmgdem:aggregate_blocks(BY_AVERAGE())

exp = gergnd:aggregate_blocks(BY_SUM())
```

<br/>

| Method                                                     | Syntax                                       |
|:-----------------------------------------------------------|:---------------------------------------------|
| Map blocks into hours (`BY_AVERAGE()` or `BY_REPEATING()`) | `exp = exp1:to_hour(type)`                   |
| Map hour into blocks (`BY_AVERAGE()` or `BY_SUM()`)        | `exp = exp1:to_block(type)`                  |

<br/>

## Stages

<br/>

### Aggregate Stages

| Description |          Syntax          |
|:-----------:|:------------------------:|
|             | `PROFILE.STAGE`          |
|             | `PROFILE.WEEK`           | 
|             | `PROFILE.MONTH`          | 
|             | `PROFILE.YEAR`           | 
|             | `PROFILE.PER_WEEK`       | 
|             | `PROFILE.PER_MONTH`      |
|             | `PROFILE.PER_YEAR`       | 

<br/>

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Aggregate stages by aggregate function (table 4)                       | `exp = exp1:aggregate_stages(agg)`           |
| Aggregate stages by aggregate function (table 4) and profile (table 5) | `exp = exp1:aggregate_stages(agg, profile)`  |

<br/>

<!-- \begin{table}[H]
\centering
\begin{tabular}{@{}cccccc@{}}
\multicolumn{6}{c}{\textbf{Stages}} \\ \toprule
\multicolumn{2}{c|}{\textbf{exp1}}                                        & $n$ (daily)                  & $n$ (weekly)                          & $n$ (monthly)                         & $n$ (yearly)                          \\ \midrule
                               & \multicolumn{1}{c|}{\textbf{STAGE}}      & $1$ (daily)                  & $1$ (weekly)                          & $1$ (monthly)                         & $1$ (yearly)                          \\
                               & \multicolumn{1}{c|}{\textbf{WEEK}}       & $7$ (daily)                  & $1$ (weekly)                          & {\color[HTML]{FE0000} \textbf{error}} & {\color[HTML]{FE0000} \textbf{error}} \\
							   & \multicolumn{1}{c|}{\textbf{MONTH}}      & $31$ (daily)                 & {\color[HTML]{FE0000} \textbf{error}} & $1$ (monthly)                         & {\color[HTML]{FE0000} \textbf{error}} \\
                               & \multicolumn{1}{c|}{\textbf{YEAR}}       & $365$ (daily)                & $52$ (weekly)                         & $12$ (monthly)                        & $1$ (yearly)                          \\
                               & \multicolumn{1}{c|}{\textbf{PER\_WEEK}}  & $\frac{n}{7}$ (weekly)       & $n$ (weekly)                          & {\color[HTML]{FE0000} \textbf{error}} & {\color[HTML]{FE0000} \textbf{error}} \\
                               & \multicolumn{1}{c|}{\textbf{PER\_MONTH}} & $\frac{n}{\sim30}$ (monthly) & {\color[HTML]{FE0000} \textbf{error}} & $n$ (monthly)                         & {\color[HTML]{FE0000} \textbf{error}} \\
\multirow{-7}{*}{\textbf{exp}} & \multicolumn{1}{c|}{\textbf{PER\_YEAR}}  & $\frac{n}{365}$ (yearly)     & $\frac{n}{52}$ (yearly)               & $\frac{n}{12}$ (yearly)               & $\frac{n}{1}$ (yearly)                \\ \bottomrule
\end{tabular}
\caption{Aggregate stages rules.}
\end{table} -->

``` lua
exp = defcit:aggregate_stages(BY_SUM(), Profile.PER_YEAR);
```

<br/>

### Select Stages

<br/>

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Select stages within case horizon                                      | `exp = exp1:select_stages()`                 |
| Select stages                                                          | `exp = exp1:select_stages(int, int)`         |
| Select stages by year                                                  | `exp = exp1:select_stages_by_year(int, int)` |

<br/>

### Reshape Stages

<br/>

| Method                                                                 | Syntax                                       |
|:-----------------------------------------------------------------------|:---------------------------------------------|
| Reshape stages frequency to daily (only works with hourly input)       | `exp = exp1:reshape_stages(PROFILE.DAILY)`   |

<br/>

| exp1            | exp             |
|:---------------:|:---------------:|
| `n` (daily)     | `n` (daily)     |
| `n` (weekly)    | `7⋅n` (daily)    |
| `n` (monthly)   | `~30⋅n` (daily)  |
| `n` (yearly)    | `365⋅n` (daily) |

<br/>

## Agents

|           Collection          | Syntax                                     |
|:-----------------------------:|:------------------------------------------:|
|              Area             | `Collection.AREA`                          |
|         Balancing Area        | `Collection.BALANCINGAREA`                 |
|      Balancing Area Hydro     | `Collection.BALANCINGAREA_HYDRO`           |
|     Balancing Area Thermal    | `Collection.BALANCINGAREA_THERMAL`         |
|            Battery            | `Collection.BATTERY`                       |
|              Bus              | `Collection.BUS`                           |
|            Circuit            | `Collection.CIRCUIT`                       |
|          Circuits Sum         | `Collection.CIRCUITS_SUM`                  |
|            DC Link            | `Collection.DCLINK`                        |
|             Demand            | `Collection.DEMAND`                        |
|         DemandSegment         | `Collection.DEMAND_SEGMENT`                |
|       Expansion Project       | `Collection.EXPANSION_PROJECT`             |
|              Fuel             | `Collection.FUEL`                          |
|        Fuel Consumption       | `Collection.FUEL_CONSUMPTION`              |
|         Fuel Contract         | `Collection.FUEL_CONTRACT`                 |
|         Fuel Reservoir        | `Collection.FUEL_RESERVOIR`                |
|           Generator           | `Collection.GENERATOR`                     |
|     Generation Constraint     | `Collection.GENERATION_CONSTRAINT`         |
|            Generic            | `Collection.GENERIC`                       | 
|             Hydro             | `Collection.HYDRO`                         |
|        Interconnection        | `Collection.INTERCONNECTION`               |
|        Power Injection        | `Collection.POWERINJECTION`                |
|           Renewable           | `Collection.RENEWABLE`                     |
|   Renewable Gauging Station   | `Collection.RENEWABLE_GAUGING_STATION`     |
| Reserve Generation Constraint | `Collection.RESERVE_GENERATION_CONSTRAINT` |
|             Study             | `Collection.STUDY`                         |
|             System            | `Collection.SYSTEM`                        |
|            Thermal            | `Collection.THERMAL`                       |

<br/>

### Aggregate Agents

<br/>

| Method                                                                     | Syntax                                         |
|:---------------------------------------------------------------------------|:-----------------------------------------------|
| Aggregate agents by aggregate function (table 4)                           | `exp = exp1:aggregate_agents(agg, label)`      |
| Aggregate agents by aggregate function (table 4) into collection (table 5) | `exp = exp1:aggregate_agents(agg, collection)` |

``` lua
exp = gerhid:aggregate_agents(BY_SUM(), "Total Hydro");

exp = defbus:aggregate_agents(BY_SUM(), Collection.SYSTEMS);

exp = gergnd:aggregate_agents(BY_SUM(), Collection.BUSES);

exp = system.sensitivity * demxba:aggregate_agents(BY_SUM(), Collection.SYSTEMS);
```

<br/>

### Generic Agents

<br/>

| Method                                                                     | Syntax                                         |
|:---------------------------------------------------------------------------|:-----------------------------------------------|
| Select agents by a list of string and/or int                               | `exp = exp1:select_agents({string or int})`    |
| Remove agents by a list of string and/or int                               | `exp = exp1:remove_agents({string or int})`    |
| Rename agents                                                              | `exp = exp1:rename_agents({string})`           |
| Concatenate                                                                | `exp = concatenate(exp1, exp2, ...)`           |

<br/>

``` lua
exp = gerter:select_agents({"Thermal 1", "Thermal 2"});
```
