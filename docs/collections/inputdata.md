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


### Area

### Balancing Area

### Balancing Area Hydro

### Balancing Area Thermal

### Battery

### Bus

### Circuit

| Data             | Unit | Syntax                                  |
|:----------------:|:----:|:---------------------------------------:|
| Circuit capacity | MW   | `exp = circuit.capacity`                |
|     bla          | ---  | `exp = circuit.monitored`               |
|     bla          | ---  | `exp = circuit.monitored_contingencies` |
|     bla          | ---  | `exp = circuit.status`                  |

``` lua
circuit = require("collection/circuit");
exp = circuit.capacity;
```

### Circuits Sum

### DC Link

### Demand

### Demand Segment

### Expansion Project

### Fuel

### Fuel Consumption

### Fuel Contract

### Fuel Reservoir

### Generator

### Generation Constraint

### Generic

### Hydro

### Interconnection

### Power Injection

### Renewable

### Renewable Gauging Station

### Reserve Generation Constraint

### Study

### System

``` lua
system = require("collection/system");
duraci = system.duraci;
```

### Thermal



