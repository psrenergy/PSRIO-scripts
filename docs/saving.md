---
title: Saving
nav_order: 7
---

# Saving

| Method                                                                      | Syntax                                              |
|:----------------------------------------------------------------------------|:----------------------------------------------------|
| Save with filename                                                          | `exp1:save("filename")`                             |
| Save with filename and [options][saving-options]                            | `exp1:save("filename", {options})`                  |
| Save with filename and return the expression                                | `exp = exp1:save_and_load("filename")`              |
| Save with filename and [options][saving-options], and return the expression | `exp = exp1:save_and_load("filename", {optionals})` |


## Saving Options

| Description                                                     | Syntax                                     |
|:----------------------------------------------------------------|:-------------------------------------------|
| Save output as CSV                                              | `csv = true`                               |
| Save file even if not selected in index.dat (require `--index`) | `force = true`                             |
| Crop values within the case horizon                             | `horizon = boolean`                        |
| Remove agents that have all data equal to 0                     | `remove_zeros = true`                      |
| Delete file at the end of execution                             | `tmp = true`                               |

#### Example 1
{: .no_toc }

``` lua
hydro = Hydro();
hydro.qmax:save("mnsout", { horizon = true });
```

[saving-options]: https://psrenergy.github.io/psrio-scripts/saving.html#saving-options

