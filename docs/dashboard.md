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

### Chart attributes

Some methods accept arguments to customize your chart, i.e., change its color, define the limits on the y axis, etc.

The arguments are declared in tables inside the methods as shown in the following example.
`chart:add_line(exp, {yMin= 0})`. The user an also define multiple arguments as follows ``chart:add_line(exp, {yMin= 0, color = "#8583ff"})``

The following table describe the available chart arguments

| Argument | Default Value | Description|
|:---------|:------------------------------------|:------------------------------------------------------------|
| color    | automatically calculated            | The color of the chart (e.g. `#ff0000` or `red`)            |
| yMin     | automatically calculated            | The minimum value of the y axis                             |
| yMax     | automatically calculated            | The maximum value of the y axis                             |
| yLine    | ---                                 | Draw a horizontal line on the y axis at the provided value  |
| xMin     | automatically calculated            | The minimum value of the x axis                             |
| xMax     | automatically calculated            | The maximum value of the x axis                             |
| xLine    | ---                                 | Draw a vertical line on the x axis at the provided value    |

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

#### Example 2
{: .no_toc }

``` lua
local hydro = Hydro();
local gerhid = hydro:load("gerhid"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE());

local light_blue = "#8583ff";

local chart = Chart("Hydro Generation");
chart:add_line(gerhid, {yMin = 0, color = light_blue});

local dashboard = Dashboard("SDDP");
dashboard:push(chart);
dashboard:save("sddp-dashboard");
```

## Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

#### Example 1

```lua
local dashboard = Dashboard("Hydro Generation"); 
dashboard:push("# Hydro Generation Dashboard");
dashboard:push("#### This dashboard shows the hydro generation of the main hydropower plants in Brazil.");
dashboard:save("dashboard_hydros");
```
<!-- ```markdown
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
``` -->