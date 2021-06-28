local is_sddp = false;

local generic = require("collection/generic");
local hydro = require("collection/hydro");

local gerhid = hydro:load(is_sddp and "gerhid" or "gerhid_KTT"):convert("GWh"):aggregate_blocks(BY_SUM());


local renewable = require("collection/renewable");
local gergnd = renewable:load("gergnd"):aggregate_blocks(BY_SUM());

local thermal = require("collection/thermal");
local potter = thermal:load("potter"):convert("GWh"):aggregate_blocks(BY_SUM());


local interconnection = require("collection/interconnection");
local capint2 = interconnection:load("capint2"):convert("GWh"):aggregate_blocks(BY_SUM());
local capint2_SE = capint2:select_agents({"SE -> NI", "SE -> NE", "SE -> NO"}):aggregate_agents(BY_SUM(), "SE");
capint2_SE:save("capin2_se")

local interconnection_sum = require("collection/interconnectionsum");
local interc_sum = interconnection_sum.ub:select_agents({"Soma   14"}):aggregate_blocks(BY_AVERAGE()):convert("GWh");
interc_sum:save("interc_sum_risk")

capint2_SE = min(capint2_SE, interc_sum);

local system = require("collection/system");
local enearm = system:load(is_sddp and "enearm" or "storageenergy_aggregated"):convert("GWh");
enearm = is_sddp and enearm or enearm:select_stages(2, enearm:stages()):reset_stages();

local earmzm = system:load(is_sddp and "earmzm" or "energystoragemax_aggregated"):convert("GWh");

local demand = system:load("demand"):aggregate_blocks(BY_SUM()):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
demand:save("demand_agg");

local hydro_generation = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local renewable_generation = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local thermal_generation = potter:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

hydro_generation:save("gerhid_risk")
renewable_generation:save("gergnd_risk")
thermal_generation:save("potter_risk")

-- MAX GENERATION
local generation = hydro_generation + renewable_generation + thermal_generation + capint2_SE;
generation:save("max_generation")

-- DEFICIT SEM ENERGIA ARMAZENADA -- TODO CHAMAR DE missmatch
local deficit = ifelse((demand - generation):gt(0), demand - generation, 0);

-- DEFICIT SOMA DE MAIO A NOVEMBRO
mismatch_stages = deficit:select_stages(1, 5):rename_agents({"Mismatch - balanço hídrico"}):save_and_load("mismatch_stages");
local deficit_sum = deficit:select_stages(1, 5):aggregate_stages(BY_SUM());
mismatch = deficit_sum:save_and_load("mismatch");

ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Mismatch - balanço hídrico"}):save("mismatch_risk");

-- DEFICIT RISCO A PRIORI
-- ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"risk"}):save("deficit_risk");

enearm_SU_ini_stage = enearm:select_agents({"SUL"}):save_and_load("enearm_SU_ini_stage");
enearm_SE_ini_stage = enearm:select_agents({"SUDESTE"}):save_and_load("enearm_SE_ini_stage");

-- ENERGIA ARMAZENADA DO SUL E SUDESTE
local enearm_SU = enearm:select_agents({"SUL"}):select_stages(5);
local enearm_SE = enearm:select_agents({"SUDESTE"}):select_stages(5);

enearm_SU_ini = enearm_SU:save_and_load("enearm_SU_ini");
enearm_SE_ini = enearm_SE:save_and_load("enearm_SE_ini");

local earmzm_max_SU = earmzm:select_agents({"SUL"}):select_stages(5);
local earmzm_max_SE = earmzm:select_agents({"SUDESTE"}):select_stages(5);

local earmzm_SU_level1 = earmzm_max_SU * 0.3;
local earmzm_SE_level1 = earmzm_max_SE * 0.1;

local earmzm_SU_level2 = earmzm_max_SU * 0.06;
local earmzm_SE_level2 = earmzm_max_SE * 0.06;

-- acima de 0.06 -> susto
-- abaixo de 0.06 -> desespero

-- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A PRIORI
local has_SU_level1_violation = enearm_SU:le(earmzm_SU_level1);
local has_SE_level1_violation = enearm_SE:le(earmzm_SE_level1);
local has_SU_level2_violation = enearm_SU:le(earmzm_SU_level2);
local has_SE_level2_violation = enearm_SE:le(earmzm_SE_level2);

ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 1 (30%)"}):save("enearm_risk_level1_SU");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 1 (10%)"}):save("enearm_risk_level1_SE");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 1"}):save("enearm_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 2 (6%)"}):save("enearm_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 2 (6%)"}):save("enearm_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_risk_level2_SE_or_SU");

local enearm2 = enearm:select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE and SU"):select_stages(5) - deficit_sum;
-- ifelse(enearm2:lt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"final risk"}):save("deficit_final_risk");

local p_prop_SU = earmzm_SU_level1 / (earmzm_SU_level1 + earmzm_SE_level1);
local p_prop_SE = earmzm_SE_level1 / (earmzm_SU_level1 + earmzm_SE_level1);

local enearm3 = max(enearm2, 0);

local enearm_final_SU = enearm3 * p_prop_SU;
local enearm_final_SE = enearm3 * p_prop_SE;

local function get_target(current_energy_se, max_energy_se, current_energy_su, max_energy_su)
	local meta_su_1 = max_energy_su * 0.06;
	local meta_su_2 = max_energy_su * 0.30;
    local meta_se_1 = max_energy_se * 0.06;
	local meta_se_2 = max_energy_se * 0.10;
    local meta_su = ifelse(current_energy_se:gt(meta_se_2) & current_energy_su:gt(meta_su_2), meta_su_2, ifelse(current_energy_se:gt(meta_se_1) & current_energy_su:gt(meta_su_1), meta_su_1, 0.0));
    local meta_se = ifelse(current_energy_se:gt(meta_se_2) & current_energy_su:gt(meta_su_2), meta_se_2, ifelse(current_energy_se:gt(meta_se_1) & current_energy_su:gt(meta_su_1), meta_se_1, 0.0));
    return meta_su, meta_se
end

local function get_current_energy(deficit, target_S1, current_energy_S1, max_energy_S1, target_S2, current_energy_S2, max_energy_S2, ite, agent)
    local current_energy_S1_useful_storage = (current_energy_S1 - target_S1) / (max_energy_S1 - target_S1);
    local current_energy_S2_useful_storage = (current_energy_S2 - target_S2) / (max_energy_S2 - target_S2);

    local has_deficit = deficit:gt(0):save_and_load("has_deficit" .. agent .. tostring(ite));
    local hit_target = current_energy_S1:gt(target_S1) & current_energy_S2:gt(target_S2):save_and_load("hit_target" .. agent .. tostring(ite));
    current_energy_S2:save("current_energy_S2" .. agent .. tostring(ite));
    (current_energy_S2 - deficit):save("first_value" .. agent .. tostring(ite));
    (target_S2 + current_energy_S1_useful_storage * (max_energy_S2-target_S2)):save("second_value" .. agent .. tostring(ite));

    return 
    ifelse(has_deficit, 
        ifelse(hit_target,
            ifelse(current_energy_S2_useful_storage:gt(current_energy_S1_useful_storage),
                max(current_energy_S2 - deficit, target_S2 + current_energy_S1_useful_storage * (max_energy_S2-target_S2)),
                current_energy_S2                                                                                   
            ),
            current_energy_S2
        ),
        current_energy_S2
    )
end

enearm_SE:save("enearm_SE");
enearm_SU:save("enearm_SU");
deficit_sum:save("deficit_sum");

for i = 1,3,1 do 
    print("iteration: " .. tostring(i) .. ": ")

    local target_SU, target_SE = get_target(enearm_SE, earmzm_max_SE, enearm_SU, earmzm_max_SU);
    print(target_SE);
    print(target_SU);
    target_SE:save_and_load("target_SE_it" .. tostring(i));
    target_SU:save_and_load("target_SU_it" .. tostring(i));
    (enearm_SE - target_SE):save("numerador" .. tostring(i));
    (earmzm_max_SE - target_SE):save("denominador" .. tostring(i));
    local current_energy_SE_useful_storage = (enearm_SE - target_SE) / (earmzm_max_SE - target_SE);
    local current_energy_SU_useful_storage = (enearm_SU - target_SU) / (earmzm_max_SU - target_SU);
    current_energy_SE_useful_storage:save("percent_1_SE_it" .. tostring(i));
    current_energy_SU_useful_storage:save("percent_1_SU_it" .. tostring(i));

    local energy_SE = get_current_energy(deficit_sum, target_SU, enearm_SU, earmzm_max_SU, target_SE, enearm_SE, earmzm_max_SE, i, "SE"):save_and_load("enearm_SE1_it" .. tostring(i));
    local energy_SU = get_current_energy(deficit_sum, target_SE, enearm_SE, earmzm_max_SE, target_SU, enearm_SU, earmzm_max_SU, i, "SU"):save_and_load("enearm_SU1_it" .. tostring(i));

    local current_energy_SE_useful_storage = (energy_SE - target_SE) / (earmzm_max_SE - target_SE);
    local current_energy_SU_useful_storage = (energy_SU - target_SU) / (earmzm_max_SU - target_SU);
    current_energy_SE_useful_storage:save("percent_2_SE_it" .. tostring(i));
    current_energy_SU_useful_storage:save("percent_2_SU_it" .. tostring(i));

    deficit_sum = deficit_sum - (enearm_SE - energy_SE) - (enearm_SU - energy_SU);
    deficit_sum:save("deficit_sum1_it" .. tostring(i));
    enearm_SE = energy_SE;
    enearm_SU = energy_SU;
    local pode_esvaziar = enearm_SE - target_SE + enearm_SU - target_SU;
    pode_esvaziar:save_and_load("pode_esvaziar_it" .. tostring(i));

    local nao_pode_atender = deficit_sum:gt(pode_esvaziar:convert("GWh"));
    nao_pode_atender:save("nao_pode_atender_it" .. tostring(i));
    enearm_SE = ifelse(nao_pode_atender, target_SE, enearm_SE - deficit_sum * (enearm_SE - target_SE)/pode_esvaziar):save_and_load("enearm_SE_it" .. tostring(i));
    enearm_SU = ifelse(nao_pode_atender, target_SU, enearm_SU - deficit_sum * (enearm_SU - target_SU)/pode_esvaziar):save_and_load("enearm_SU_it" .. tostring(i));
    deficit_sum = ifelse(nao_pode_atender, deficit_sum - pode_esvaziar, 0):save_and_load("deficit_sum_it" .. tostring(i));
end

enearm_SE:rename_agents({"SUDESTE"}):save("enearm_SE_final");
enearm_SU:rename_agents({"SUL"}):save("enearm_SU_final");
deficit_sum:rename_agents({"Deficit"}):reset_stages():save("deficit_sum_final");

deficit = deficit_sum

earmzm_SE_level1:save("earmzm_SE_level1");
earmzm_SE_level2:save("earmzm_SE_level2");
earmzm_SU_level1:save("earmzm_SU_level1");
earmzm_SU_level2:save("earmzm_SU_level2");

 -- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A PRIORI
local has_SU_level1_violation = enearm_SU:le(earmzm_SU_level1);
local has_SE_level1_violation = enearm_SE:le(earmzm_SE_level1);
local has_SU_level2_violation = enearm_SU:le(earmzm_SU_level2);
local has_SE_level2_violation = enearm_SE:le(earmzm_SE_level2);

has_SE_level1_violation:save("has_SE_level1_violation");

ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - nível 1 (30%)"}):save("enearm_final_risk_level1_SU");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - nível 1 (10%)"}):save("enearm_final_risk_level1_SE");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - nível 1"}):save("enearm_final_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - nível 2 (6%)"}):save("enearm_final_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - nível 2 (6%)"}):save("enearm_final_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_final_risk_level2_SE_or_SU");


ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Deficit risk"}):reset_stages():save("deficit_final_risk");

deficit_stages = (mismatch_stages * (deficit_sum / mismatch)):save_and_load("Deficit_stages");

(deficit_sum/(demand:select_stages(demand:stages()-3,demand:stages()-1):reset_stages():aggregate_stages(BY_SUM()))):convert("%"):save("deficit_percentual");

local function get_percentile_chart(chart, filename, name_agent)    
    local generic = require("collection/generic");
    local output = generic:load(filename);

    local selected = output;

    local P = {1, 5, 10, 25, 50, 75, 90, 95, 99};

    local label = filename .. "_"  .. "_avg";
    selected:aggregate_scenarios(BY_AVERAGE()):rename_agents({name_agent .. " avg"}):save(label);
    chart:add_line(label);

    local label = filename .. "_" .. "_min";
    selected:aggregate_scenarios(BY_MIN()):rename_agents({name_agent .." min"}):save(label);
    chart:add_line(label);
    
    for _, p in ipairs(P) do 
        local label = filename .. "_" .. "_p" .. tostring(p);
        selected:aggregate_scenarios(BY_PERCENTILE(p)):rename_agents({name_agent .. " p" .. tostring(p)}):save(label);
        chart:add_line(label);
    end

    local label = filename .. "_" .. "_max";
    selected:aggregate_scenarios(BY_MAX()):rename_agents({name_agent .. " max"}):save(label);
    chart:add_line(label);

    return chart
end

local dashboard = Dashboard("Home");

local chart1 = Chart("Violação de volume mínimo - balanço hídrico");
chart1:add_column("enearm_risk_level1_SU");
chart1:add_column("enearm_risk_level1_SE");
chart1:add_column("enearm_risk_level1_SE_or_SU");
chart1:add_column("enearm_risk_level2_SU");
chart1:add_column("enearm_risk_level2_SE");
chart1:add_column("enearm_risk_level2_SE_or_SU");
dashboard:push(chart1);

local chart2 = Chart("Violação de volume mínimo");
chart2:add_column("enearm_final_risk_level1_SU");
chart2:add_column("enearm_final_risk_level1_SE");
chart2:add_column("enearm_final_risk_level1_SE_or_SU");
chart2:add_column("enearm_final_risk_level2_SU");
chart2:add_column("enearm_final_risk_level2_SE");
chart2:add_column("enearm_final_risk_level2_SE_or_SU");
dashboard:push(chart2);

local chart3 = Chart("Deficit risk");
chart3:add_column("mismatch_risk");
chart3:add_column("deficit_final_risk");
dashboard:push(chart3);

local chart4 = Chart("Mismatch - balanço hídrico");
chart4 = get_percentile_chart(chart4, "mismatch_stages", "Mismatch - balanço hídrico");
dashboard:push(chart4);

local chart5 = Chart("Deficit");
chart5 = get_percentile_chart(chart5, "Deficit_stages", "Deficit");
dashboard:push(chart5);


----- debug -------

enearm_SU_ini_stage = enearm:select_agents({"SUL"}):save_and_load("enearm_SU_ini_stage");
enearm_SE_ini_stage = enearm:select_agents({"SUDESTE"}):save_and_load("enearm_SE_ini_stage");


local chart6 = Chart("Debug");
mismatch_stages:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"Mismatch"}):save("Mismatch - first");
chart6:add_line("Mismatch - first");
deficit_stages:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"Deficit"}):save("Deficit - first");
chart6:add_line("Deficit - first");
enearm_SE_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"enearm_SE_ini"}):save("enearm_SE_ini - first");
chart6:add_line("enearm_SE_ini - first");
enearm_SU_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"enearm_SU_ini"}):save("enearm_SU_ini - first");
chart6:add_line("enearm_SU_ini - first");
dashboard:push(chart6);


local chart7 = Chart("Debug - 2");
hydro_generation = gerhid:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_stages(BY_SUM()):save("gethid_debug");
chart7:add_column("gethid_debug");
enearm_SE_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_stages(BY_LAST_VALUE()):rename_agents({"enearm_SE_ini"}):save("enearm_SE_ini_laststage");
chart7:add_column("enearm_SE_ini_laststage");
enearm_SU_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_stages(BY_LAST_VALUE()):rename_agents({"enearm_SU_ini"}):save("enearm_SU_ini_laststage");
chart7:add_column("enearm_SU_ini_laststage");
dashboard:push(chart7);

dashboard:save("risk");