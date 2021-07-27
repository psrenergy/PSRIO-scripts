system = require("collection/system");
defcit = system:load("defcit");
demand = system:load("demand");

max_deficit = defcit
    :convert("MW")
    :select_block(1)
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_MAX(), Profile.PER_YEAR);

max_demand = demand
    :convert("MW")
    :select_block(1)
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_MAX(), Profile.PER_YEAR)

sum_deficit = defcit
    :select_block(1)
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR);

sum_demand = demand
    :select_block(1)
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)

dashboard = Dashboard();

-- DEMANDA DE POTENCIA
max_demand:rename_agents({"Máxima demanda de potencia"}):save("max_demand");
max_deficit:rename_agents({"Máximo déficit de potencia"}):save("max_deficit");
(max_deficit / max_demand):convert("%"):rename_agents({"Déficit/Demanda"}):save("max_deficit_per_max_deficit");

chart = Chart("Demanda de potencia");
chart:push("max_demand", "column");
chart:push("max_deficit", "column");
chart:push("max_deficit_per_max_deficit", "line");
dashboard:push(chart);

-- DEMANDA DE ENERGÍA
sum_demand:rename_agents({"Demanda de energía anual"}):save("sum_demand");
sum_deficit:rename_agents({"Déficit de energía anual"}):save("sum_deficit");
(sum_deficit / sum_demand):convert("%"):rename_agents({"Déficit/Demanda"}):save("sum_deficit_per_sum_deficit");

chart = Chart("Demanda de energía");
chart:push("sum_demand", "column");
chart:push("sum_deficit", "column");
chart:push("sum_deficit_per_sum_deficit", "line");
dashboard:push(chart);

dashboard:save_style2("deficit de energia y potencia");