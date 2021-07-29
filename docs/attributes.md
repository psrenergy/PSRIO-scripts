---
title: Attributes
nav_order: 4
---

# Attributes
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

TODO - mostrar que cada atributo tem um estagio inicial, cenarios, blocos...

## Stage

| Operator        | Type            |            Syntax                 |
|:----------------|:---------------:|:----------------------------------|
| Stages          | number          | `attribute = exp:stages()`        |
| Stage           | number          | `attribute = exp:stage(index)`    |
| Stage Type      | number          | `attribute = exp:stage_type()`    |
| Initial Stage   | number          | `attribute = exp:initial_stage()` |
| Initial Year    | number          | `attribute = exp:initial_year()`  |
| Final Year      | number          | `attribute = exp:final_year()`    |
| Week            | number          | `attribute = exp:week(stage)`     |
| Month           | number          | `attribute = exp:month(stage)`    |
| Year            | number          | `attribute = exp:year(stage)`     |

## Blocks

| Operator        | Type            |            Syntax                 |
|:----------------|:---------------:|:----------------------------------|
| Blocks          | number          | `attribute = exp:blocks(stage)`   |
| Has blocks      | boolean         | `attribute = exp:has_blocks()`    |
| Is hourly       | boolean         | `attribute = exp:is_hourly()`     |

## Scenarios

| Operator        | Type            |            Syntax                 |
|:----------------|:---------------:|:----------------------------------|
| Scenarios       | number          | `attribute = exp:scenarios()`     |

## Agents

| Operator        | Type              |            Syntax                 |
|:----------------|:-----------------:|:----------------------------------|
| Agents          | vector of strings | `attribute = exp:agents()`        |
| Agents Size     | number            | `attribute = exp:agents_size()`   |
| Agent           | string            | `attribute = exp:agent(index)`    |

## Unit

| Operator        | Type            |            Syntax                 |
|:----------------|:---------------:|:----------------------------------|
| Unit            | string          | `attribute = exp:unit()`          |