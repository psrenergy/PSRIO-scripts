-- COLLECTIONS
local generic = require("collection/generic")
local hydro = require("collection/hydro");
local interconnection = require("collection/interconnection");
local renewable = require("collection/renewable");
local system = require("collection/system");
local thermal = require("collection/thermal");

-- GERHID
local gerhid = hydro:load("gerhid"):aggregate_blocks(BY_SUM());

-- GERGND
local gergnd = renewable:load("gergnd"):aggregate_blocks(BY_SUM());

-- POTTER
local potter = thermal:load("potter"):convert("GWh"):aggregate_blocks(BY_SUM());

-- CAPINT
local capint2 = interconnection:load("capint2"):convert("GWh"):aggregate_blocks(BY_SUM());
local capint2_SE = capint2:select_agents({"SE -> NI", "SE -> NE", "SE -> NO"}):aggregate_agents(BY_SUM(), "SE");

-- ENEARM
local enearm = system:load("enearm");

-- EARMZM
local earmzm = system:load("earmzm");

-- DEMAND
local demand = system:load("demand"):aggregate_blocks(BY_SUM()):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- HYDRO GENERATION
local hydro_generation = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- RENEWABLE GENERATION
local renewable_generation = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- THERMAL GENERATION
local thermal_generation = potter:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- MAX GENERATION
local generation = hydro_generation + renewable_generation + thermal_generation + capint2_SE;

-- DEFICIT SEM ENERGIA ARMAZENADA -- TODO CHAMAR DE missmatch
local deficit = ifelse((demand - generation):gt(0), demand - generation, 0);

-- DEFICIT SOMA DE MAIO A NOVEMBRO
local deficit_sum = deficit:select_stages(1, 7):aggregate_stages(BY_SUM());

-- DEFICIT RISCO A PRIORI
-- ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"risk"}):save("deficit_risk");

-- ENERGIA ARMAZENADA DO SUL E SUDESTE
local enearm_SU = enearm:select_agents({"SUL"}):select_stages(7);
local enearm_SE = enearm:select_agents({"SUDESTE"}):select_stages(7);

local earmzm_max_SU = earmzm:select_agents({"SUL"}):select_stages(7);
local earmzm_max_SE = earmzm:select_agents({"SUDESTE"}):select_stages(7);

local earmzm_SU_level1 = earmzm_max_SU * 0.3;
local earmzm_SE_level1 = earmzm_max_SE * 0.1;

local earmzm_SU_level2 = earmzm_max_SU * 0.06;
local earmzm_SE_level2 = earmzm_max_SE * 0.06;

-- acima de 0.06 -> susto
-- abaixo de 0.06 -> desespero

-- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A PRIORI
local has_SU_level1_violation = enearm_SU:lt(earmzm_SU_level1);
local has_SE_level1_violation = enearm_SE:lt(earmzm_SE_level1);

-- ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):save("enearm_risk_SU");
-- ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):save("enearm_risk_SE");
-- ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE"}):save("enearm_risk_SE_or_SU");

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

local function get_current_energy(deficit, target_S1, current_energy_S1, max_energy_S1, target_S2, current_energy_S2, max_energy_S2)
    local current_energy_S1_useful_storage = (current_energy_S1 - target_S1) / (max_energy_S1 - target_S1);
    local current_energy_S2_useful_storage = (current_energy_S2 - target_S2) / (max_energy_S2 - target_S2);

    local has_deficit = deficit:gt(0);
    local hit_target = current_energy_S1:gt(target_S1) & current_energy_S2:gt(target_S2);

    return 
    ifelse(has_deficit, 
        ifelse(hit_target,
            ifelse(current_energy_S2_useful_storage:gt(current_energy_S1_useful_storage),
                min(current_energy_S2 - deficit, target_S2 + current_energy_S1_useful_storage * max_energy_S2),
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
    print("iteration: " .. tostring(i) .. ": ");

    local target_SU = get_target_SU(enearm_SU, earmzm_max_SU);
    local target_SE = get_target_SE(enearm_SE, earmzm_max_SE);

    local energy_SU = get_current_energy(deficit_sum, target_SU, enearm_SU, earmzm_max_SU, target_SE, enearm_SE, earmzm_max_SE);
    local energy_SE = get_current_energy(deficit_sum, target_SE, enearm_SE, earmzm_max_SE, target_SU, enearm_SU, earmzm_max_SU);

    deficit_sum = deficit_sum - (enearm_SE - energy_SE) - (enearm_SU - energy_SU);
    local pode_esvaziar = enearm_SE - target_SE + enearm_SU - target_SU;

    enearm_SE = ifelse(deficit_sum:gt(pode_esvaziar), target_SE, target_SE + (pode_esvaziar - deficit_sum) * (enearm_SE - target_SE)/pode_esvaziar):save_and_load("enearm_SE_it" .. tostring(i));
    enearm_SU = ifelse(deficit_sum:gt(pode_esvaziar), target_SU, target_SU + (pode_esvaziar - deficit_sum) * (enearm_SU - target_SU)/pode_esvaziar):save_and_load("enearm_SU_it" .. tostring(i));
    deficit_sum = ifelse(deficit_sum:gt(pode_esvaziar), deficit_sum - pode_esvaziar, 0):save_and_load("deficit_sum_it" .. tostring(i));
end

enearm_SE:save("enearm_SE_final");
enearm_SU:save("enearm_SU_final");
deficit_sum:save("deficit_sum_final");



-- fazer um teste com 1 cenario
-- fazer comparação da geracao hidrica sddp vs ktt

-- canarios de vazoes
-- cenarios de renovaveis

-- hiposteses:
-- capacidade de intercambio do norte-nordeste tá no maixmo
-- termicas tao no maximo]
-- gnd no maximo


-- modelod e balanco hidrico

-- balanco com relaao a demanda
-- se o balanco ta folgado

-- se o lbalanco tievr faltando


-- trocar a capacidade de interconxeao



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
--  -- deficit = deficit_sum



-- -- local dashboard = Dashboard();

-- -- local chart1 = Chart("enearm risk");
-- -- chart1:push("enearm_risk_SU", "column");
-- -- chart1:push("enearm_risk_SE", "column");
-- -- chart1:push("enearm_risk_SE_or_SU", "column");
-- -- dashboard:push(chart1);

-- -- local chart2 = Chart("enearm final risk");
-- -- chart2:push("enearm_final_risk_SU", "column");
-- -- chart2:push("enearm_final_risk_SE", "column");
-- -- chart2:push("enearm_final_risk_SE_or_SU", "column");
-- -- dashboard:push(chart2);

-- -- local chart3 = Chart("Deficit");
-- -- chart3:push("deficit_risk", "column");
-- -- chart3:push("deficit_final_risk", "column");
-- -- dashboard:push(chart3);

-- -- dashboard:save_style2("bla");



-- -- ifelse((earmzm_sul + earmzm_sudeste):lt(tmp), , )