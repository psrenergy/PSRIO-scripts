---
title: Examples
nav_order: 9
---

# Examples

## Circuit Loading (usecir)

``` lua
circuit = require("collection/circuit");
cirflw = circuit:load("cirflw");
    
usecir = (cirflw:abs() / circuit.capacity):convert("%");
usecir:save("usecir");
```

## Deficit Risk per Year

``` lua
system = require("collection/system");
deficit = system:load("defcit");

deficit = deficit:aggregate_blocks(BY_SUM());
deficit = deficit:aggregate_stages(BY_SUM(), Profile.PER_YEAR);
    
deficit_risk = ifelse(deficit:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%");
deficit_risk:save("deficit_risk");
```

