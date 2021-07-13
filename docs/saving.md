---
title: Saving
nav_order: 7
---

# Saving

| Method                                                           | Syntax                                     |
|:-----------------------------------------------------------------|:-------------------------------------------|
| Save expression with the filename                                | `exp1:save("filename")`                    |
| Save expression with the filename and optionals                  | `exp1:save("filename", {optionals})`       |
| Aggregate stages by an [aggregate function][aggregate-functions] | `exp = exp1:save_and_load("filename")`              |
| Aggregate stages by an [aggregate function][aggregate-functions] | `exp = exp1:save_and_load("filename", {optionals})` |


## Saving Options

| Description                                                     | Syntax                                     |
|:---------------------------------------------------------------:|:------------------------------------------:|
| Save output as CSV                                              | `csv = true`                               |
| Save file even if not selected in index.dat (require `--index`) | `force = true`                             |
| Crop values within the case horizon                             | `horizon = boolean`                        |
| Remove agents that have all data equal to 0                     | `remove_zeros = true`                      |
| Delete file at the end of execution                             | `tmp = true`                               |