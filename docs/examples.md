---
title: Examples
nav_order: 9
---

# Examples

## Circuit Loading (usecir)

``` lua
circuit = require("collection/circuit"); -- load circuit collection
cirflw = circuit:load("cirflw"); -- load cirflw output
    
usecir = (cirflw:abs() / circuit.capacity):convert("%");
usecir:save("usecir");
```

## Deficit risk per year

``` lua
system = require("collection/system"); -- load system collection
deficit = system:load("defcit"); -- load deficit output

deficit = deficit:aggregate_blocks(BY_SUM()); -- aggregate deficit blocks
deficit = deficit:aggregate_stages(BY_SUM(), Profile.PER_YEAR); -- aggregate deficit stages per year
    
deficit_risk = ifelse(deficit:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%");
deficit_risk:save("deficit_risk");
```

