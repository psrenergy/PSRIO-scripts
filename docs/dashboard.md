---
title: Dashboard
nav_order: 8
---

# Dashboard
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

| Method                          |  Syntax                                                           |
|:----------------------------------|:----------------------------------------------------------------|
| Create Dashboard with title       | `dashboard = Dashboard(string)`                                 |
| Push Chart object to Dashboard    | `dashboard:push(chart)`                                         |
| Push Markdown line to Dashboard   | `dashboard:push(string)`                                        |
| Push Markdown object to Dashboard | `dashboard:push(md)`                                            |
| Save Dashbaord with filename      | `dashboard:save(string)`                                        |

## Charts

| Method                         | Syntax                                                          |
|:-------------------------------|:----------------------------------------------------------------|
| Create Chart without title     | `chart = Chart()`                                               |
| Create Chart with title        | `chart = Chart(string)`                                         |

| Method                         | Syntax                                                          |
|:-------------------------------|:----------------------------------------------------------------|
| Add Line                       | `chart:add_line(exp1)`                                          |
| Add Line Stacking              | `chart:add_line_stacking(exp1)`                                 |
| Add Line Percent               | `chart:add_line_percent(exp1)`                                  |
| Add Column                     | `chart:add_column(exp1)`                                        |
| Add Column Stacking            | `chart:add_column_stacking(exp1)`                               |
| Add Column Percent             | `chart:add_column_percent(exp1)`                                |
| Add Area                       | `chart:add_area(exp1)`                                          |
| Add Area Stacking              | `chart:add_area_stacking(exp1)`                                 |
| Add Area Percent               | `chart:add_area_percent(exp1)`                                  |
| Add Area Range                 | `chart:add_area_range(exp1, exp2)`                              |
| Add Pie                        | `chart:add_pie(exp1)`                                           |

#### Example 1
{: .no_toc }

``` lua
local hydro = Hydro();
local gerhid = hydro:load("gerhid"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE());

local chart = Chart("Hydro Generation");
chart:add_line(gerhid);

local dashboard = Dashboard("SDDP");
dashboard:push(chart);
dashboard:save("sddp-dashboard");
```

<!-- ## Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/). -->
