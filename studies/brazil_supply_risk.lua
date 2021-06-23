local generic = require("collection/generic")

local hydro = require("collection/hydro");
-- local gerhid = hydro:load("gerhid"):aggregate_blocks(BY_SUM());
local gerhid = hydro:load("gerhid_KTT"):aggregate_blocks(BY_SUM());

local renewable = require("collection/renewable");
local gergnd = renewable:load("gergnd"):aggregate_blocks(BY_SUM());

local thermal = require("collection/thermal");
local potter = thermal:load("potter"):convert("GWh"):aggregate_blocks(BY_SUM());

local interconnection = require("collection/interconnection");
local capint2 = interconnection:load("capint2"):convert("GWh"):aggregate_blocks(BY_SUM());
local capint2_SE = capint2:select_agents({"SE -> NI", "SE -> NE", "SE -> NO"}):aggregate_agents(BY_SUM(), "SE");

local system = require("collection/system");
-- local enearm = system:load("enearm");
local enearm = system:load("storageenergy_aggregated");
enearm = enearm:select_stages(2, enearm:stages()):reset_stages();
-- local earmzm = system:load("earmzm");
local earmzm = system:load("energystoragemax_aggregated");;
local demand = system:load("demand"):aggregate_blocks(BY_SUM()):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
demand:save("demand_agg")

local hydro_generation = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local renewable_generation = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local thermal_generation = potter:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- MAX GENERATION
local generation = hydro_generation + renewable_generation + thermal_generation + capint2_SE;
generation:save("max_generation")

-- DEFICIT SEM ENERGIA ARMAZENADA -- TODO CHAMAR DE missmatch
local deficit = ifelse((demand - generation):gt(0), demand - generation, 0);

-- DEFICIT SOMA DE MAIO A NOVEMBRO
local deficit_sum = deficit:select_stages(1, 7):aggregate_stages(BY_SUM());
deficit_sum:save("mismatch")

ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"mismatch risk"}):save("mismatch_risk");

-- DEFICIT RISCO A PRIORI
-- ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"risk"}):save("deficit_risk");

-- ENERGIA ARMAZENADA DO SUL E SUDESTE
local enearm_SU = enearm:select_agents({"SUL"}):select_stages(7);
local enearm_SE = enearm:select_agents({"SUDESTE"}):select_stages(7);

enearm_SU:save("enearm_SU_ini")
enearm_SE:save("enearm_SE_ini")

local earmzm_max_SU = earmzm:select_agents({"SUL"}):select_stages(7);
local earmzm_max_SE = earmzm:select_agents({"SUDESTE"}):select_stages(7);

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

ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 1"}):save("enearm_risk_level1_SU");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 1"}):save("enearm_risk_level1_SE");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 1"}):save("enearm_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 2"}):save("enearm_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 2"}):save("enearm_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_risk_level2_SE_or_SU");

local enearm2 = enearm:select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE and SU"):select_stages(7) - deficit_sum;
-- ifelse(enearm2:lt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"final risk"}):save("deficit_final_risk");

local p_prop_SU = earmzm_SU_level1 / (earmzm_SU_level1 + earmzm_SE_level1);
local p_prop_SE = earmzm_SE_level1 / (earmzm_SU_level1 + earmzm_SE_level1);

local enearm3 = max(enearm2, 0);

local enearm_final_SU = enearm3 * p_prop_SU;
local enearm_final_SE = enearm3 * p_prop_SE;

-- enearm_final_SU:save("enearm_final_SU");
-- enearm_final_SE:save("enearm_final_SE");

-- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A POSTERIORI
-- ifelse(enearm_final_SU:lt(earmzm_SU_level1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL"}):save("enearm_final_risk_SU");
-- ifelse(enearm_final_SE:lt(earmzm_SE_level1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE"}):save("enearm_final_risk_SE");
-- ifelse(enearm_final_SU:lt(earmzm_SU_level1) | enearm_final_SE:lt(earmzm_SE_level1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE"}):save("enearm_final_risk_SE_or_SU");

local function get_target_SU(current_energy, max_energy)
	local meta_1 = max_energy * 0.06;
	local meta_2 = max_energy * 0.30;
	return ifelse(current_energy:gt(meta_2), meta_2, ifelse(current_energy:gt(meta_1), meta_1, 0.0))
end

local function get_target_SE(current_energy, max_energy)
	local meta_1 = max_energy * 0.06;
	local meta_2 = max_energy * 0.10;
	return ifelse(current_energy:gt(meta_2), meta_2, ifelse(current_energy:gt(meta_1), meta_1, 0.0))
end

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

    -- local target_SE = get_target_SE(enearm_SE, earmzm_max_SE):save_and_load("target_SE_it" .. tostring(i));
    -- local target_SU = get_target_SU(enearm_SU, earmzm_max_SU):save_and_load("target_SU_it" .. tostring(i));

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

    -- enearm_SE = ifelse(deficit_sum:gt(pode_esvaziar), target_SE, target_SE + (pode_esvaziar - deficit_sum) * (enearm_SE - target_SE)/pode_esvaziar):save_and_load("enearm_SE_it" .. tostring(i));
    -- enearm_SU = ifelse(deficit_sum:gt(pode_esvaziar), target_SU, target_SU + (pode_esvaziar - deficit_sum) * (enearm_SU - target_SU)/pode_esvaziar):save_and_load("enearm_SU_it" .. tostring(i));
    local nao_pode_atender = deficit_sum:gt(pode_esvaziar:convert("GWh"));
    nao_pode_atender:save("nao_pode_atender_it" .. tostring(i));
    enearm_SE = ifelse(nao_pode_atender, target_SE, enearm_SE - deficit_sum * (enearm_SE - target_SE)/pode_esvaziar):save_and_load("enearm_SE_it" .. tostring(i));
    enearm_SU = ifelse(nao_pode_atender, target_SU, enearm_SU - deficit_sum * (enearm_SU - target_SU)/pode_esvaziar):save_and_load("enearm_SU_it" .. tostring(i));
    deficit_sum = ifelse(nao_pode_atender, deficit_sum - pode_esvaziar, 0):save_and_load("deficit_sum_it" .. tostring(i));
end

enearm_SE:rename_agents({"SUDESTE"}):save("enearm_SE_final");
enearm_SU:rename_agents({"SUL"}):save("enearm_SU_final");
deficit_sum:save("deficit_sum_final");






-- -- local p_prop_SU = earmzm_min_SU / (earmzm_min_SU + earmzm_min_SE);
-- -- local p_prop_SE = earmzm_min_SE / (earmzm_min_SU + earmzm_min_SE);
-- -- local enearm3 = max(enearm2, 0);
-- -- local enearm_final_SU = enearm3 * p_prop_SU;
-- -- local enearm_final_SE = enearm3 * p_prop_SE;
-- -- chama suprimento2.lua
--  -- (meta_SU, meta_SE, energia_atual_SU, energia_atual_SE, energia_max_SU,  energia_max_SE, deficit)
--  -- meta_SU e meta_SE vem da "descobre_metas"
--  -- energia_atual_SU e energia_atual_SE = enearm_SU e enearm_SE
--  -- energia_max_SU e  energia_max_SE = earmzm_max_SU e earmzm_max_SE
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

ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 1"}):save("enearm_final_risk_level1_SU");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 1"}):save("enearm_final_risk_level1_SE");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 1"}):save("enearm_final_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 2"}):save("enearm_final_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 2"}):save("enearm_final_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_final_risk_level2_SE_or_SU");


ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"deficit risk"}):save("deficit_final_risk");


local dashboard = Dashboard();

local chart1 = Chart("enearm risk");
chart1:push("enearm_risk_level1_SU", "column");
chart1:push("enearm_risk_level1_SE", "column");
chart1:push("enearm_risk_level1_SE_or_SU", "column");
chart1:push("enearm_risk_level2_SU", "column");
chart1:push("enearm_risk_level2_SE", "column");
chart1:push("enearm_risk_level2_SE_or_SU", "column");
dashboard:push(chart1);

local chart2 = Chart("enearm final risk");
chart2:push("enearm_final_risk_level1_SU", "column");
chart2:push("enearm_final_risk_level1_SE", "column");
chart2:push("enearm_final_risk_level1_SE_or_SU", "column");
chart2:push("enearm_final_risk_level2_SU", "column");
chart2:push("enearm_final_risk_level2_SE", "column");
chart2:push("enearm_final_risk_level2_SE_or_SU", "column");
dashboard:push(chart2);

local chart3 = Chart("Deficit");
chart3:push("mismatch_risk", "column");
chart3:push("deficit_final_risk", "column");
dashboard:push(chart3);

dashboard:save_style2("risk");



-- -- ifelse((earmzm_sul + earmzm_sudeste):lt(tmp), , )