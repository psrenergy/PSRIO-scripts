---
title: Input Data
parent: Collections
nav_order: 1
---

# Input Data
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---


<!-- ### Area -->

<!-- ### Balancing Area -->

<!-- ### Balancing Area Hydro -->

<!-- ### Balancing Area Thermal -->

<!-- ### Battery -->

<!-- ### Bus -->

### Circuit

| Data                                                                | Unit | Syntax                                  |
|:--------------------------------------------------------------------|:----:|:----------------------------------------|
| Resistance                                                          | %    | TODO                                    |
| Reactance                                                           | %    | TODO                                    |
| Nominal Flow Limit                                                  | MW   | `exp = circuit.capacity`                |
| Emergency Flow Limit                                                | MW   | TODO                                    |
| Circuit Type (existing = 0 or future = 1)                           | ---  | TODO                                    |
| Selected for monitoring                                             | ---  | `exp = circuit.monitored`               |
| Selected for monitoring (contingencies)                             | ---  | `exp = circuit.monitored_contingencies` |
| Circuit Operative Condition (connected = 0 or disconnected = 1)     | ---  | `exp = circuit.status`                  |

``` lua
circuit = require("collection/circuit");
exp = circuit.capacity;
```

### Circuits Sum

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
|                  | MW   | `exp = circuitssum.lb`                  |
|                  | MW   | `exp = circuitssum.ub`                  |

``` lua
```

### DC Link

| Data                                            | Unit | Syntax                                  |
|:------------------------------------------------|:----:|:----------------------------------------|
| DC Link Type (existing = 0 or future = 1)       | ---  | TODO                                    |
| Nominal Flow Limit in the FROM -> TO direction  | MW   | `exp = dclink.capacity_right`           |
| Nominal Flow Limit in the FROM <- TO direction  | MW   | `exp = dclink.capacity_left`            |

``` lua
```

### Demand

| Data                                                   | Unit | Syntax                                  |
|:-------------------------------------------------------|:----:|:----------------------------------------|
| Type of The First Level (inelastic = 0 or elastic = 1) | ---  | `exp = demand.is_elastic`               |
| Energy to be consumed by inelastic demand (hourly)     | MW   | `exp = demand.inelastic_hour`           |
| Energy to be consumed by inelastic demand (block)      | GWh  | `exp = demand.inelastic_block`          |

``` lua
```

### Demand Segment

| Data                                             | Unit | Syntax                                  |
|:-------------------------------------------------|:----:|:----------------------------------------|
| Energy to be consumed by demand segment (hourly) | MW   | `exp = demandsegment.hour`              |
| Energy to be consumed by demand segment (block)  | GWh  | `exp = demandsegment.block`             |

``` lua
```

<!-- ### Expansion Project -->

### Fuel

| Data             | Unit  | Syntax                                 |
|:-----------------|:-----:|:---------------------------------------|
|                  | $/gal | `exp = fuel.cost`                      |

``` lua
```

<!-- ### Fuel Consumption -->

### Fuel Contract

| Data             | Unit  | Syntax                                  |
|:-----------------|:-----:|:----------------------------------------|
|                  | ---   | `exp = fuelcontract.amount`             |
|                  | ---   | `exp = fuelcontract.take_or_pay`        |
|                  | ---   | `exp = fuelcontract.max_offtake`        |

``` lua
```

### Fuel Reservoir

| Data             | Unit  | Syntax                                           |
|:-----------------|:-----:|:-------------------------------------------------|
|                  | ---   | `exp = fuelreservoir.maxinjection`               |
|                  | ---   | `exp = fuelreservoir.maxinjection_chronological` |

``` lua
```

<!-- ### Generator -->

### Generation Constraint

| Data             | Unit  | Syntax                                           |
|:-----------------|:-----:|:-------------------------------------------------|
|                  | MW    | `exp = generationconstraint.capacity`            |

``` lua
```

<!-- ### Generic -->

### Hydro

| Data                                             | Unit  | Syntax                                       |
|:-------------------------------------------------|:-----:|:---------------------------------------------|
| Construction Status (existing = 0 or future = 1) | ---   | `exp = hydro.status`                         |
| Number of Generating Units                       | ---   | `exp = hydro.units`                          |



| Installed Capacity      | MW    | `exp = hydro.capacity`                       |
| PotInst             | MW    | `exp = hydro.capacity_maintenance`           |
| ICP                 | %     | `exp = hydro.icp`                            |
| IH                  | %     | `exp = hydro.ih`                             |
| Vmin                | hm3   | `exp = hydro.vmin`                           |
| Vmax                | hm3   | `exp = hydro.vmax`                           |
| Minimum Turbining           | m3/s  | `exp = hydro.qmin`                           |
| Maximum Turbining          | m3/s  | `exp = hydro.qmax`                           |
| O&M Cost            | $/MWh | `exp = hydro.omcost`                         |
| Rieg                | m3/s  | `exp = hydro.irrigation`                     |
| TargetStorageTol    | %     | `exp = hydro.target_storage_tolerance`       |


Num		INTEGER	1	4
Nome		STRING	6	17
Unidades	INTEGER	34	37	AUTOSET
Existing	INTEGER 39	42	AUTOSET
PotInst		REAL	44	50	AUTOSET
FPMed		REAL	51	58	AUTOSET
Qmin		REAL	60	66	AUTOSET
Qmax		REAL	68	74	AUTOSET
Vmin		REAL	76	82	AUTOSET
Vmax		REAL	84	90	AUTOSET
DfTotMin	REAL	100	106	AUTOSET
ICP		REAL	116	122	AUTOSET
IH		REAL	124	130	AUTOSET
Indicador	INTEGER	625	625	AUTOSET
TurIn($(P))	REAL	611+(16*$(P)),617+(16*$(P))	AUTOSET
TotIn($(P))	REAL	619+(16*$(P)),626+(16*$(P))	AUTOSET
OxT_Tail($(P))        REAL          695+(16*$(P))  701+(16*$(P))  AUTOSET
OxT_Outflow($(P))     REAL          703+(16*$(P))  709+(16*$(P))  AUTOSET
Eaflu		INTEGER	791	791	AUTOSET


``` lua
```

| Data                                                        | Unit  | Syntax                                                       |
|:------------------------------------------------------------|:-----:|:-------------------------------------------------------------|
| Minimum Total Outflow                                       | m3/s  | `exp = hydro.min_total_outflow`                              |
| Minimum Total Outflow (modifications)                       | m3/s  | `exp = hydro.min_total_outflow_modification`                 |
| Minimum Total Outflow Historical Scenarios                  | m3/s  | `exp = hydro.min_total_outflow_historical_scenarios`         |
| Minimum Total Outflow Historical Scenarios (no data)        | ---   | `exp = hydro.min_total_outflow_historical_scenarios_nodata`  |
| Maximum Total Outflow                                       | m3/s  | `exp = hydro.max_total_outflow`                              |
| Maximum Total Outflow Historical Scenarios                  | m3/s  | `exp = hydro.max_total_outflow_historical_scenarios`         |
| Maximum Total Outflow Historical Scenarios (no data)        | ---   | `exp = hydro.max_total_outflow_historical_scenarios_nodata`  |
| VolumeMinimum                                               | hm3   | `exp = hydro.vmin_chronological`                             |
| VolumeMinimum                                               | hm3   | `exp = hydro.vmin_chronological_historical_scenarios`        |
| VolumeMinimum                                               | ---   | `exp = hydro.vmin_chronological_historical_scenarios_nodata` |
| VolumeMaximum                                               | hm3   | `exp = hydro.vmax_chronological`                             |
| VolumeMaximum                                               | hm3   | `exp = hydro.vmax_chronological_historical_scenarios`        |
| VolumeMaximum                                               | ---   | `exp = hydro.vmax_chronological_historical_scenarios_nodata` |
| Flood Control Storage                                       | hm3   | `exp = hydro.flood_control`                                   |
| Flood Control Storage  Historical Scenarios                 | hm3   | `exp = hydro.flood_control_historical_scenarios`              |
| Flood Control Storage  Historical Scenarios (no data)       | ---   | `exp = hydro.flood_control_historical_scenarios_nodata`       |
| AlertStorage                                                | hm3   | `exp = hydro.alert_storage`                                  |
| AlertStorage                                                | hm3   | `exp = hydro.alert_storage_historical_scenarios`             |
| AlertStorage                                                | ---   | `exp = hydro.alert_storage_historical_scenarios_nodata`      |
| MinSpillage                                                 | m3/s  | `exp = hydro.min_spillage`                                   |
| MinSpillage                                                 | m3/s  | `exp = hydro.min_spillage_historical_scenarios`              |
| MinSpillage                                                 | ---   | `exp = hydro.min_spillage_historical_scenarios_nodata`       |
| MaxSpillage                                                 | m3/s  | `exp = hydro.max_spillage`                                   |
| MaxSpillage                                                 | m3/s  | `exp = hydro.max_spillage_historical_scenarios`              |
| MaxSpillage                                                 | ---   | `exp = hydro.max_spillage_historical_scenarios_nodata`       |
| MinBioSpillage                                              | %     | `exp = hydro.min_bio_spillage`                               |
| MinBioSpillage                                              | %     | `exp = hydro.min_bio_spillage_historical_scenarios`          |
| MinBioSpillage                                              | ---   | `exp = hydro.min_bio_spillage_historical_scenarios_nodata`   |
| TargetStorage                                               | hm3   | `exp = hydro.target_storage`                                 |
| TargetStorage                                               | hm3   | `exp = hydro.target_storage_historical_scenarios`            |
| TargetStorage                                               | ---   | `exp = hydro.target_storage_historical_scenarios_nodata`     |

``` lua
```

### Interconnection

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | MW   | `exp = interconnection.capacity_right`                        |
|                     | MW   | `exp = interconnection.capacity_left`                         |
|                     | MW   | `exp = interconnection.cost_right`                            |
|                     | MW   | `exp = interconnection.cost_left`                             |

``` lua
```

### Power Injection

| Data                | Unit  | Syntax                                                        |
|:--------------------|:-----:|:--------------------------------------------------------------|
| Hourly Capacity     | MW    | `exp = powerinjection.hour_capacity`                          |
| Hourly Price        | $/MWh | `exp = powerinjection.hour_price`                             |

``` lua
```

### Renewable

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | MW    | `exp = renewable.existing`                                   |
|                     | MW    | `exp = renewable.tech_type`                                  |
|                     | MW    | `exp = renewable.capacity`                                   |
|                     | MW    | `exp = renewable.omcost`                                     |

``` lua
```

### Renewable Gauging Station

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | MW   | `exp = renewablegaugingstation.hourgeneration`                |

``` lua
```

<!-- ### Reserve Generation Constraint -->

### Study

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | %     | `exp = study.discount_rate`                                  |
|                     | ---   | `exp = study.stage`                                          |
|                     | ---   | `exp = study.stage_in_year`                                  |
|                     | ---   | `exp = study.scenario`                                       |
|                     | ---   | `exp = study.block`                                          |
|                     | ---   | `exp = study.blocks`                                         |
|                     | ---   | `exp = study.hour`                                           |
|                     | ---   | `exp = study.hours`                                          |
|                     | ---   | `exp = study.stages`                                         |
|                     | ---   | `exp = study.stages_per_year`                                |
|                     | ---   | `exp = study.scenarios`                                      |

``` lua
```

### System

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | ---   | `exp = system.duraci`                                        |
|                     | ---   | `exp = system.hblock`                                        |
|                     | ---   | `exp = system.sensitivity`                                   |

``` lua
system = require("collection/system");
duraci = system.duraci;
```

### Thermal

| Data                                             | Unit    | Syntax                                                       |
|:-------------------------------------------------|:-------:|:-------------------------------------------------------------|
| Construction Status (existing = 0 or future = 1) | ---     | `exp = thermal.status`                                       |
| Plant Type                                       | ---     | `exp = thermal.type`                                         |
| Number of Units                                  | ---     | `exp = thermal.units`                                        |
| Minimum Generation                               | MW      | `exp = thermal.germin`                                       |
| Minimum Generation (maintenance)                 | MW      | `exp = thermal.germin_maintenance`                           |
| Maximum Generation                               | MW      | `exp = thermal.germax`                                       |
| Maximum Generation (maintenance)                 | MW      | `exp = thermal.germax_maintenance`                           |
| Forced Outage Rate                               | %       | `exp = thermal.for`                                          |
| Composite Outage Rate                            | %       | `exp = thermal.cor`                                          |
| Startup Cost                                     | k$      | `exp = thermal.startup_cost`                                 |
| O&M Variable Cost                                | $/MWh   | `exp = thermal.omcost`                                       |
| Transportation Cost                              | $/gal   | `exp = thermal.transport_cost`                               |
| Specific Fuel Consumption (segment 1)            | gal/MWh | `exp = thermal.cesp1`                                        |
| Specific Fuel Consumption (segment 2)            | gal/MWh | `exp = thermal.cesp2`                                        |
| Specific Fuel Consumption (segment 3)            | gal/MWh | `exp = thermal.cesp3`                                        |

``` lua
```