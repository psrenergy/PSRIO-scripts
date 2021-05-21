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

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
| Circuit capacity | MW   | `exp = circuit.capacity`                |
|     bla          | ---  | `exp = circuit.monitored`               |
|     bla          | ---  | `exp = circuit.monitored_contingencies` |
|     bla          | ---  | `exp = circuit.status`                  |

``` lua
circuit = require("collection/circuit");
exp = circuit.capacity;
```

### Circuits Sum

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
| Circuit Sum LB   | MW   | `exp = circuitssum.lb`                  |
| Circuit Sum UB   | MW   | `exp = circuitssum.ub`                  |

``` lua
```

### DC Link

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
|                  | MW   | `exp = dclink.capacity_right`           |
|                  | MW   | `exp = dclink.capacity_left`            |

``` lua
```

### Demand

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
|                  | ---  | `exp = demand.is_elastic`               |
|                  | MW   | `exp = demand.inelastic_hour`           |
|                  | GWh  | `exp = demand.inelastic_block`          |

``` lua
```

### Demand Segment

| Data             | Unit | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
|                  | MW   | `exp = demandsegment.hour`              |
|                  | GWh  | `exp = demandsegment.block`             |

``` lua
```

<!-- ### Expansion Project -->

### Fuel

| Data             | Unit  | Syntax                                  |
|:-----------------|:----:|:----------------------------------------|
|                  | $/gal | `exp = fuel.cost`                       |

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

| Data                | Unit  | Syntax                                       |
|:--------------------|:-----:|:---------------------------------------------|
| Hydro Existing Flag | ---   | `exp = hydro.existing`                       |
| Hydro Capacity      | MW    | `exp = hydro.capacity`                       |
| PotInst             | MW    | `exp = hydro.capacity_maintenance`           |
| ICP                 | %     | `exp = hydro.icp`                            |
| IH                  | %     | `exp = hydro.ih`                             |
| Vmax                | hm3   | `exp = hydro.vmax`                           |
| Vmin                | hm3   | `exp = hydro.vmin`                           |
| Qmax_orig           | m3/s  | `exp = hydro.qmax`                           |
| Qmin_orig           | m3/s  | `exp = hydro.qmin`                           |
| O&MCost             | $/MWh | `exp = hydro.omcost`                         |
| Rieg                | m3/s  | `exp = hydro.irrigation`                     |
| DfTotMin            | m3/s  | `exp = hydro.min_total_outflow_modification` |
| TargetStorageTol    | %     | `exp = hydro.target_storage_tolerance`       |

``` lua
```

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
| MinTO               | ---   | `exp = hydro.min_total_outflow_historical_scenarios_nodata`  |
| MinTO               | m3/s  | `exp = hydro.min_total_outflow_historical_scenarios`         |
| MinTO               | m3/s  | `exp = hydro.min_total_outflow`                              |
| MaxTO               | ---   | `exp = hydro.max_total_outflow_historical_scenarios_nodata`  |
| MaxTO               | m3/s  | `exp = hydro.max_total_outflow_historical_scenarios`         |
| MaxTO               | m3/s  | `exp = hydro.max_total_outflow`                              |
| VolumeMinimum       | ---   | `exp = hydro.vmin_chronological_historical_scenarios_nodata` |
| VolumeMinimum       | hm3   | `exp = hydro.vmin_chronological_historical_scenarios`        |
| VolumeMinimum       | hm3   | `exp = hydro.vmin_chronological`                             |
| VolumeMaximum       | ---   | `exp = hydro.vmax_chronological_historical_scenarios_nodata` |
| VolumeMaximum       | hm3   | `exp = hydro.vmax_chronological_historical_scenarios`        |
| VolumeMaximum       | hm3   | `exp = hydro.vmax_chronological`                             |
| FloodControlStorage | ---   | `exp = hydro.flood_volume_historical_scenarios_nodata`       |
| FloodControlStorage | hm3   | `exp = hydro.flood_volume_historical_scenarios`              |
| FloodControlStorage | hm3   | `exp = hydro.flood_volume`                                   |
| AlertStorage        | ---   | `exp = hydro.alert_storage_historical_scenarios_nodata`      |
| AlertStorage        | hm3   | `exp = hydro.alert_storage_historical_scenarios`             |
| AlertStorage        | hm3   | `exp = hydro.alert_storage`                                  |
| MinSpillage         | ---   | `exp = hydro.min_spillage_historical_scenarios_nodata`       |
| MinSpillage         | m3/s  | `exp = hydro.min_spillage_historical_scenarios`              |
| MinSpillage         | m3/s  | `exp = hydro.min_spillage`                                   |
| MaxSpillage         | ---   | `exp = hydro.max_spillage_historical_scenarios_nodata`       |
| MaxSpillage         | m3/s  | `exp = hydro.max_spillage_historical_scenarios`              |
| MaxSpillage         | m3/s  | `exp = hydro.max_spillage`                                   |
| MinBioSpillage      | ---   | `exp = hydro.min_bio_spillage_historical_scenarios_nodata`   |
| MinBioSpillage      | %     | `exp = hydro.min_bio_spillage_historical_scenarios`          |
| MinBioSpillage      | %     | `exp = hydro.min_bio_spillage`                               |
| TargetStorage       | ---   | `exp = hydro.target_storage_historical_scenarios_nodata`     |
| TargetStorage       | hm3   | `exp = hydro.target_storage_historical_scenarios`            |
| TargetStorage       | hm3   | `exp = hydro.target_storage`                                 |

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

<!-- ### Power Injection -->

### Renewable

| Data                | Unit  | Syntax                                                       |
|:--------------------|:-----:|:-------------------------------------------------------------|
|                     | MW   | `exp = renewable.existing`                                    |
|                     | MW   | `exp = renewable.tech_type`                                   |
|                     | MW   | `exp = renewable.capacity`                                    |
|                     | MW   | `exp = renewable.omcost`                                      |

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

| Data                | Unit    | Syntax                                                       |
|:--------------------|:-------:|:-------------------------------------------------------------|
| Existing            | ---     | `exp = thermal.existing`                                     |
| PotInst_orig        | MW      | `exp = thermal.capacity`                                     |
| ICP                 | %       | `exp = thermal.icp`                                          |
| IH                  | %       | `exp = thermal.ih`                                           |
| GerMax_orig         | MW      | `exp = thermal.germax`                                       |
| GerMax              | MW      | `exp = thermal.germax_maintenance`                           |
| GerMin_orig         | MW      | `exp = thermal.germin`                                       |
| GerMin              | MW      | `exp = thermal.germin_maintenance`                           |
| StartUp             | k$      | `exp = thermal.startup_cost`                                 |
| O&MCost             | $/MWh   | `exp = thermal.omcost`                                       |
| CEsp segment 1      | gal/MWh | `exp = thermal.cesp1`                                        |
| CEsp segment 2      | gal/MWh | `exp = thermal.cesp2`                                        |
| CEsp segment 3      | gal/MWh | `exp = thermal.cesp3`                                        |
| CTransp             | $/gal   | `exp = thermal.transport_cost`                               |

``` lua
```