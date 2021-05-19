---
title: Loading Outputs
parent: Collections
nav_order: 2
---

# Loading Outputs

|   Operator  |                Syntax               |
|:-----------:|:-----------------------------------:|
| Load method | `exp = collection:load("filename")` |

``` lua
hydro = require("collection/hydro");
gerhid = hydro:load("gerhid");
fprodt = hydro:load("fprodt");
```

``` lua
system = require("collection/system");
cmgdem = system:load("cmgdem");
demand = system:load("demand");
```

``` lua
thermal = require("collection/thermal");
gerter = thermal:load("gerter");
coster = thermal:load("coster");
```

``` lua
generic = require("collection/generic");
objcop = generic:load("objcop");
outdfact = generic:load("outdfact");
outdbtot = generic:load("outdbtot");
```

<!-- ``` lua
```

``` lua
``` -->