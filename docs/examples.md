---
title: Examples
nav_order: 10
---

# Examples

## Circuit Loading (usecir)

``` lua
circuit = Circuit();
cirflw = circuit:load("cirflw");
    
usecir = (cirflw:abs() / circuit.capacity):convert("%");
usecir:save("usecir");
```

``` lua
usecir = require("sddp/usecir");
usecir():save("usecir");
```

## Deficit Risk per Year

``` lua
system = System();
deficit = system:load("defcit");

deficit = deficit:aggregate_blocks(BY_SUM());
deficit = deficit:aggregate_stages(BY_SUM(), Profile.PER_YEAR);
    
deficit_risk = ifelse(deficit:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%");
deficit_risk:save("deficit_risk");
```

