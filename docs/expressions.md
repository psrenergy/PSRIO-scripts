---
title: Expressions
nav_order: 4
---

# Expressions
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Unary Expressions

<br/>

|     Operator    |            Syntax            |
|:---------------:|:----------------------------:|
|      Minus      |         `exp = -exp1`        |
|  Absolute Value |      `exp = exp1:abs()`      |
| Unit Conversion | `exp = exp1:convert("unit")` |

<br/>

### Stages and Scenarios

| exp1 | exp |
|:----:|:---:|
| `1`  | `1` |
| `n`  | `n` |

<br/>

### Block and Hours

| exp1     | exp     |
|:--------:|:-------:|
| none     | none    |
| block    | block   |
| hour     | hour    |

<br/>

### Agents

| exp1               | exp                |
|:------------------:|:------------------:|
| `n` (collection 1) | `n` (collection 1) |
| `n` (generic 1)    | `n` (generic 1)    |

<br/>

### Unit Conversion

<br/>

## Binary Expressions

|          Operator         |          Syntax         |
|:-------------------------:|:-----------------------:|
|          Addition         |   `exp = exp1 + exp2`   |
|        Subtraction        |   `exp = exp1 - exp2`   |
|       Multiplication      |   `exp = exp1 * exp2`   |
|       Right Division      |   `exp = exp1 / exp2`   |
|           Power           |   `exp = exp1 ^ exp2`   |
|          Maximum          | `exp = max(exp1, exp2)` |
|          Minimum          | `exp = min(exp1, exp2)` |
|          Equal to         |  `exp = exp1:eq(exp2)`  |
|        Not Equal to       |  `exp = exp1:ne(exp2)`  |
|         Less-than         |  `exp = exp1:lt(exp2)`  |
|   Less-than-or-equals to  |  `exp = exp1:le(exp2)`  |
|        Greater-than       |  `exp = exp1:gt(exp2)`  |
| Greater-than-or-equals to |  `exp = exp1:ge(exp2)`  |
|            And            |   `exp = exp1 & exp2`   |
|             Or            |   `exp = exp1 | exp2`   |

<br/>

### Stages and Scenarios

| exp1     | exp2     | exp         |
|:--------:|:--------:|:-----------:|
| `1`      | `1`      | `1`         |
| `n1`     | `1`      | `n1`        |
| `1`      | `n2`     | `n2`        |
| `n1`     | `n2`     | `min{n1,n2}`|

<br/>

### Block and Hours

| exp1 or exp2     | exp     |
|:----------------:|:-------:|
| none / none      | none    |
| block / none     | block   |
| block / block    | block   |
| hour / none      | hour    |
| hour / hour      | hour    |
| block / hour     | ❌      |

<br/>

### Agents (when order matters)

| exp1                | exp2                | exp                 |
|:-------------------:|:-------------------:|:-------------------:|
| `n1` (collection a) | `n2` (collection b) | `n1` (collection a) |
| `n1` (generic a)    | `n2` (generic b)    | `n1` (generic a)    |

<br/>

### Agents (when the order does not matter)

| exp1 or exp2                           | exp                 |
|:--------------------------------------:|:-------------------:|
| `1` (collection a) / `n` (generic b)   | `n` (generic b)     |
| `n1` (collection a) / `1` (generic b)  | `n1` (collection a) |
| `n` (collection a) / `n` (generic b)   | `n` (collection b)  |
| `n1` (collection a) / `n2` (generic b) | ❌                  |
| `n` (generic a) / `1` (generic b)      | `n` (generic a)     |
| `n1` (generic a) / `n2` (generic b)    | ❌                  |

<br/>

## Ternary Expressions

| Operator    | Syntax                           |
|:-----------:|:--------------------------------:|
| Conditional | `exp = ifelse(exp1, exp2, exp3)` |