---
title: Saving
nav_order: 7
---

# Saving

After processing the data, it is convenient to save it to a file to store it and pass it around. 

| Method                                                                      | Syntax                                              |
|:----------------------------------------------------------------------------|:----------------------------------------------------|
| Save with filename                                                          | `exp1:save("filename")`                             |
| Save with filename and [options][saving-options]                            | `exp1:save("filename", {options})`                  |
| Save with filename and return the expression                                | `exp = exp1:save_and_load("filename")`              |
| Save with filename and [options][saving-options], and return the expression | `exp = exp1:save_and_load("filename", {optionals})` |


## Saving Options

Saving options specify how PSRIO will save the data in a file. By default, when no option is provided for the method, the file format will be binary, yielding `.hdr` and `.bin` files.

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
thermal = Hydro();
gerter = thermal:load("gerter")

agg_gerter = gerter:aggregate_stages(BY_AVERAGE())
agg_gerter:save("AggregatedGerter", { csv = true });
```

#### Example 2
{: .no_toc }

``` lua
hydro = Hydro();
hydro.qmax:save("mnsout", { horizon = true });
```

[saving-options]: https://psrenergy.github.io/psrio-scripts/saving.html#saving-options

