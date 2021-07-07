------------------------------------------------- INPUT -------------------------------------------------
local is_sddp = false;
local is_debug = false;

local bool_dead_storage_input = true;

local bool_termica_extra = false;
local input_termica_extra = 6.5 -- GW

local bool_oferta_extra = false;

local bool_int_extra = false;
local input_int_extra = 0.2; -- %

local bool_demanda_reduzida = false;
local input_demanda_reduzida = -0.086; -- % -- adicionar opção de GW, além do aumento percentual
-- 6%2020  = 2.7% 0.027
-- 9%2020 = 5.6% 0.056
-- 12%2020 = 8.6% 0.086

local bool_demanda_substituta = false; -- GWh

local bool_demand_per_block = false
------------------------------------------------- INPUT -------------------------------------------------

local generic = require("collection/generic");
local hydro = require("collection/hydro");
local renewable = require("collection/renewable");
local system = require("collection/system");
local thermal = require("collection/thermal");
local interconnection = require("collection/interconnection");
local interconnection_sum = require("collection/interconnectionsum");

-- LOAD FATOR ENERGIA ARMAZENADA
local fator_energia_armazenada = hydro:load("fatorEnergiaArmazenada", true);

-- LOAD DURACI
local duraci = system.duraci;
if bool_demand_per_block then
    duraci = duraci:select_agents({1}):select_stages(1,5);
else
    duraci = duraci:select_agents({1}):select_stages(1,5):aggregate_blocks(BY_SUM());
end

-- LOAD HYDRO GENERATION
local gerhid = nil;
if bool_demand_per_block then
    gerhid = hydro:load(is_sddp and "gerhid" or "gerhid_KTT", true):convert("GWh"):select_stages(1,5);
    gerhid = gerhid:aggregate_blocks(BY_SUM()):convert("GW") * duraci;
    gerhid = gerhid:convert("GWh");
else
    gerhid = hydro:load(is_sddp and "gerhid" or "gerhid_KTT", true):convert("GWh"):aggregate_blocks(BY_SUM()):select_stages(1,5);
end
local hydro_generation = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- LOAD RENEWABLE GENERATION
local gergnd = nil;
if bool_demand_per_block then
    gergnd = renewable:load("gergnd", true):select_stages(1,5);
else
    gergnd = renewable:load("gergnd", true):aggregate_blocks(BY_SUM()):select_stages(1,5);
end
local renewable_generation = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- LOAD THERMAL GENERATION
local potter = nil;
if bool_demand_per_block then
    potter = thermal:load("potter", true):convert("GW"):select_stages(1,5) * duraci;
    potter = potter:convert("GWh");
else
    potter = thermal:load("potter", true):convert("GWh"):aggregate_blocks(BY_SUM()):select_stages(1,5);
end
local thermal_generation = potter:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

-- LOAD INTERCONNECTION
local capint2 = nil;
if bool_demand_per_block then
    capint2 = interconnection:load("capint2", true):convert("GWh");
else
    capint2 = interconnection:load("capint2", true):convert("GWh"):aggregate_blocks(BY_SUM());
end
local capint2_SE = capint2:select_agents({"SE -> NI", "SE -> NE", "SE -> NO"}):aggregate_agents(BY_SUM(), "SE");

-- LOAD INTERCONNECTION SUM
local interc_sum = nil;
if bool_demand_per_block then
    interc_sum = interconnection_sum.ub:select_agents({"Soma   14"}):convert("GWh");
else
    interc_sum = interconnection_sum.ub:select_agents({"Soma   14"}):aggregate_blocks(BY_AVERAGE()):convert("GWh");
end

-- DEBUG
if is_debug then 
    duraci:save("duraci_risk");
    hydro_generation:save("gerhid_risk");
    renewable_generation:save("gergnd_risk");
    thermal_generation:save("potter_risk");
    capint2_SE:save("capin2_se");
    interc_sum:save("interc_sum_risk");
    fator_energia_armazenada:save("fator_energia_armazenada_debug");
end

capint2_SE = min(capint2_SE, interc_sum):select_stages(1,5);
local capint2_SE_extra = capint2_SE * input_int_extra;

-- DEBUG
if is_debug then 
    capint2_SE:save("capin2_se_min_risk");
    capint2_SE_extra:save("capint2_SE_extra");
end

-- local enearm = system:load(is_sddp and "enearm" or "storageenergy_aggregated"):convert("GWh");
-- enearm = is_sddp and enearm or enearm:select_stages(2, enearm:stages()):reset_stages();

-- LOAD RHO
local rho = hydro:load("rho", true):select_stages(1,1):reset_stages();

-- LOAD RHO MAX
local rhomax = hydro:load("rhomax", true):select_stages(1,1):reset_stages();

-- LOAD ENEARM
local volfin = nil;
if is_sddp then
    volfin = hydro:load("volfin", true):select_stages(1,5):reset_stages();
else
    volfin = hydro:load("volini_ktt", true):select_stages(2,6):reset_stages();
end
local enearm = (max(0, volfin - hydro.vmin) *  rho):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):convert("GWh");

-- LOAD EARMZM
local earmzm = nil;
if is_sddp then
    earmzm = ((hydro.vmax - hydro.vmin):select_stages(5,5):reset_stages() *  rho):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
else
    earmzm = ((hydro.vmax - hydro.vmin) * rhomax):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
    earmzm = earmzm:select_stages(1,1):reset_stages():convert("GWh");
end

-- LOAD DEMAND
local demand = nil;
if bool_demanda_substituta then
    demand = generic:load("demanda_substituta", true);
else
    if bool_demand_per_block then
        demand = system:load("demand", true):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU"):select_stages(1,5);
    else
        demand = system:load("demand", true):aggregate_blocks(BY_SUM()):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU"):select_stages(1,5);
    end
    if bool_demanda_reduzida then
        demand = (1 - input_demanda_reduzida) * demand;
    end
end
demand = demand:select_stages(1,5);

-- MAX GENERATION
local generation = hydro_generation + renewable_generation + thermal_generation + capint2_SE;
if bool_int_extra then
    generation = generation + capint2_SE_extra;
end
if bool_termica_extra then
    generation = generation + (input_termica_extra * duraci):force_unit("GWh");
end
if bool_oferta_extra then
    local oferta_extra = generic:load("oferta_extra");
    generation = generation + oferta_extra;
end
generation = generation:select_stages(1,5);

-- MISMATCH
local deficit = ifelse((demand - generation):gt(0), demand - generation, 0);
local demanda_residual = (demand - generation):select_stages(1, 5):convert("GW");

-- DEFICIT SOMA DE MAIO A NOVEMBRO
local mismatch_stages = deficit:select_stages(1, 5):rename_agents({"Mismatch - balanço hídrico"}):convert("GW"):save_and_load("mismatch_stages");
local deficit_sum = deficit:select_stages(1, 5):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM());
local mismatch = deficit_sum:save_and_load("mismatch");

ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Mismatch - balanço hídrico"}):save("mismatch_risk");

local enearm_SU_ini_stage = enearm:select_agents({"SUL"});
local enearm_SE_ini_stage = enearm:select_agents({"SUDESTE"});

-- ENERGIA ARMAZENADA DO SUL E SUDESTE
local enearm_SU = enearm:select_agents({"SUL"}):select_stages(5);
local enearm_SE = enearm:select_agents({"SUDESTE"}):select_stages(5);

local earmzm_max_SU = earmzm:select_agents({"SUL"});
local earmzm_max_SE = earmzm:select_agents({"SUDESTE"});

if is_debug then
    generation:save("max_generation");
    duraci:save("duraci_ktt");
    demand:save("demand_agg");
    enearm_SE:save("enearm_SE");
    enearm_SU:save("enearm_SU");
    deficit_sum:save("deficit_sum");
    enearm_SU_ini_stage:save("enearm_SU_ini_stage");
    enearm_SE_ini_stage:save("enearm_SE_ini_stage");
    demanda_residual:save("demanda_residual");
end

-- local volumemorto = max(hydro.vmin, max(hydro.alert_storage, hydro.vmin_chronological)) - hydro.vmin;

-- LOAD ENERGIA MORTA
local energiamorta = hydro:load("dead_energy"):select_stages(5,5):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):convert("GWh");
if is_debug then energiamorta:save("energiamorta_sistema"); end

local energiamorta_SE = nil;
local energiamorta_SU = nil;
if bool_dead_storage_input then
    energiamorta_SE = energiamorta:select_agents({"SUDESTE"}); -- energiamorta:select_agents({"SUDESTE"});
    energiamorta_SU = energiamorta:select_agents({"SUL"}); --  energiamorta:select_agents({"SUL"});
else
    -- ignorando volume morto e aplicando meta 2 para achar energia morta
    energiamorta_SE = earmzm_max_SE * 0.06;
    energiamorta_SU = earmzm_max_SU * 0.06;
end

local earmzm_SE_level0 = earmzm_max_SE * 0.15;

local earmzm_SU_level1 = earmzm_max_SU * 0.3;
local earmzm_SE_level1 = earmzm_max_SE * 0.1;

local earmzm_SU_level2 = earmzm_max_SU * 0.06;
local earmzm_SE_level2 = earmzm_max_SE * 0.06;

-- acima de 0.06 -> susto
-- abaixo de 0.06 -> desespero

-- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A PRIORI
local has_SE_level0_violation = enearm_SE:le(earmzm_SE_level0); -- only SE has level 0
local has_SU_level1_violation = enearm_SU:le(earmzm_SU_level1);
local has_SE_level1_violation = enearm_SE:le(earmzm_SE_level1);
local has_SU_level2_violation = enearm_SU:le(earmzm_SU_level2);
local has_SE_level2_violation = enearm_SE:le(earmzm_SE_level2);

ifelse(has_SE_level0_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 0 (15%)"}):save("enearm_risk_level0_SE");
ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 1 (30%)"}):save("enearm_risk_level1_SU");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 1 (10%)"}):save("enearm_risk_level1_SE");
ifelse(has_SU_level1_violation | has_SE_level0_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 0"}):save("enearm_risk_level0_SE_or_SU");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 1"}):save("enearm_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - level 2 (6%)"}):save("enearm_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - level 2 (6%)"}):save("enearm_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_risk_level2_SE_or_SU");

local function get_target(current_energy_se, max_energy_se, current_energy_su, max_energy_su, min_level_su, min_level_se)
	local meta_su_1 = max(max_energy_su * 0.06, min_level_su);
	local meta_su_2 = max(max_energy_su * 0.30, min_level_su);
    local meta_se_1 = max(max_energy_se * 0.06, min_level_se);
	local meta_se_2 = max(max_energy_se * 0.10, min_level_se);
    local meta_su = ifelse(current_energy_se:gt(meta_se_2) & current_energy_su:gt(meta_su_2), meta_su_2, ifelse(current_energy_se:gt(meta_se_1) & current_energy_su:gt(meta_su_1), meta_su_1, min_level_su));
    local meta_se = ifelse(current_energy_se:gt(meta_se_2) & current_energy_su:gt(meta_su_2), meta_se_2, ifelse(current_energy_se:gt(meta_se_1) & current_energy_su:gt(meta_su_1), meta_se_1, min_level_se));
    return meta_su, meta_se
end

local function get_current_energy(deficit, target_S1, current_energy_S1, max_energy_S1, target_S2, current_energy_S2, max_energy_S2, ite, agent)
    local current_energy_S1_useful_storage = (current_energy_S1 - target_S1) / (max_energy_S1 - target_S1);
    local current_energy_S2_useful_storage = (current_energy_S2 - target_S2) / (max_energy_S2 - target_S2);

    local has_deficit = deficit:gt(1);
    local hit_target = current_energy_S1:gt(target_S1) & current_energy_S2:gt(target_S2);
    
    if is_debug then
        has_deficit:save("has_deficit" .. agent .. tostring(ite));
        hit_target:save(("hit_target" .. agent .. tostring(ite)));
        current_energy_S2:save("current_energy_S2" .. agent .. tostring(ite));
        (current_energy_S2 - deficit):save("first_value" .. agent .. tostring(ite));
        (target_S2 + current_energy_S1_useful_storage * (max_energy_S2-target_S2)):save("second_value" .. agent .. tostring(ite));
    end
    
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
    );
end

for i = 1,3,1 do 
    print("iteration: " .. tostring(i) .. ": ")

    local target_SU, target_SE = get_target(enearm_SE, earmzm_max_SE, enearm_SU, earmzm_max_SU, energiamorta_SU, energiamorta_SE);
    target_SE = target_SE:save_and_load("target_SE_it" .. tostring(i));
    target_SU = target_SU:save_and_load("target_SU_it" .. tostring(i));
    local current_energy_SE_useful_storage = (enearm_SE - target_SE) / (earmzm_max_SE - target_SE);
    local current_energy_SU_useful_storage = (enearm_SU - target_SU) / (earmzm_max_SU - target_SU);
    
    if is_debug then
        (enearm_SE - target_SE):save("numerador" .. tostring(i));
        (earmzm_max_SE - target_SE):save("denominador" .. tostring(i));
        current_energy_SE_useful_storage:save("percent_1_SE_it" .. tostring(i));
        current_energy_SU_useful_storage:save("percent_1_SU_it" .. tostring(i));
    end

    local energy_SE = get_current_energy(deficit_sum, target_SU, enearm_SU, earmzm_max_SU, target_SE, enearm_SE, earmzm_max_SE, i, "SE");
    local energy_SU = get_current_energy(deficit_sum, target_SE, enearm_SE, earmzm_max_SE, target_SU, enearm_SU, earmzm_max_SU, i, "SU");
    
    if is_debug then
        energy_SE:save("enearm_SE1_it" .. tostring(i));
        energy_SU:save("enearm_SU1_it" .. tostring(i));
    end
    energy_SE = energy_SE:save_and_load("enearm_SE1_it" .. tostring(i));
    energy_SU = energy_SU:save_and_load("enearm_SU1_it" .. tostring(i));

    local current_energy_SE_useful_storage = (energy_SE - target_SE) / (earmzm_max_SE - target_SE);
    local current_energy_SU_useful_storage = (energy_SU - target_SU) / (earmzm_max_SU - target_SU);
    
    if is_debug then
        current_energy_SE_useful_storage:save("percent_2_SE_it" .. tostring(i));
        current_energy_SU_useful_storage:save("percent_2_SU_it" .. tostring(i));
    end

    deficit_sum = deficit_sum - (enearm_SE - energy_SE) - (enearm_SU - energy_SU);
    enearm_SE = energy_SE;
    enearm_SU = energy_SU;
    local pode_esvaziar = enearm_SE - target_SE + enearm_SU - target_SU;
    
    if is_debug then
        deficit_sum:save("deficit_sum1_it" .. tostring(i));
        pode_esvaziar:save("pode_esvaziar_it" .. tostring(i));
    end

    local nao_pode_atender = deficit_sum:gt(pode_esvaziar:convert("GWh"));
    enearm_SE = ifelse(nao_pode_atender, target_SE, enearm_SE - deficit_sum * (enearm_SE - target_SE)/pode_esvaziar):save_and_load("enearm_SE_it" .. tostring(i));
    enearm_SU = ifelse(nao_pode_atender, target_SU, enearm_SU - deficit_sum * (enearm_SU - target_SU)/pode_esvaziar):save_and_load("enearm_SU_it" .. tostring(i));
    deficit_sum = ifelse(nao_pode_atender, deficit_sum - pode_esvaziar, 0):save_and_load("deficit_sum_it" .. tostring(i));
end

if is_debug then
    earmzm_SE_level1:save("earmzm_SE_level1");
    earmzm_SE_level2:save("earmzm_SE_level2");
    earmzm_SU_level1:save("earmzm_SU_level1");
    earmzm_SU_level2:save("earmzm_SU_level2");
   
    deficit_sum:rename_agents({"Deficit"}):reset_stages():save("deficit_sum_final");

    local enearm_SE_final = enearm_SE:rename_agents({"SUDESTE"}):save_and_load("enearm_SE_final");
    local enearm_SU_final = enearm_SU:rename_agents({"SUL"}):save_and_load("enearm_SU_final");
    (enearm_SE - enearm_SE_final):save("geracao_hidro_extra_SE");
    (enearm_SU - enearm_SU_final):save("geracao_hidro_extra_SU");
end

 -- RISCO DE VIOLAÇÃO DOS NÍVEIS ONS A POSTEIORIE
local has_SE_level0_violation = enearm_SE:le(earmzm_SE_level0); -- only SE has level 0
local has_SU_level1_violation = enearm_SU:le(earmzm_SU_level1);
local has_SE_level1_violation = enearm_SE:le(earmzm_SE_level1);
local has_SU_level2_violation = enearm_SU:le(earmzm_SU_level2);
local has_SE_level2_violation = enearm_SE:le(earmzm_SE_level2);

ifelse(has_SU_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - nível 1 (30%)"}):save("enearm_final_risk_level1_SU");
ifelse(has_SE_level0_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - nível 0 (15%)"}):save("enearm_final_risk_level0_SE");
ifelse(has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - nível 1 (10%)"}):save("enearm_final_risk_level1_SE");

ifelse(has_SU_level1_violation | has_SE_level0_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - nível 0"}):save("enearm_final_risk_level0_SE_or_SU");
ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - nível 1"}):save("enearm_final_risk_level1_SE_or_SU");

ifelse(has_SU_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL - nível 2 (6%)"}):save("enearm_final_risk_level2_SU");
ifelse(has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUDESTE - nível 2 (6%)"}):save("enearm_final_risk_level2_SE");
ifelse(has_SU_level2_violation | has_SE_level2_violation, 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"SUL or SUDESTE - level 2"}):save("enearm_final_risk_level2_SE_or_SU");

local deficit_final_risk = ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Deficit risk"}):reset_stages():save_and_load("deficit_final_risk");

local deficit_stages = ifelse(mismatch:ne(0), mismatch_stages * (deficit_sum / mismatch), 0.0):convert("GW");

local deficit_percentual = (deficit_sum/(demand:aggregate_blocks(BY_SUM()):select_stages(demand:stages()-2,demand:stages()):reset_stages():aggregate_stages(BY_SUM()))):convert("%"):save_and_load("deficit_percentual");

if is_debug then
    local has_deficit = ifelse(deficit_sum:gt(1), 1, 0);
    (1 - ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0)):save("cenarios_normal");
    (ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0) - has_deficit):save("cenarios_atencao");
    has_deficit:save("cenarios_racionamento");

    deficit_stages:save("deficit_stages");
end

--------------------------------------
---------- violacao usinas -----------
--------------------------------------

-- min outflow
local minimum_outflow_violation = hydro:load("minimum_outflow_violation");
local minimum_outflow = hydro.min_total_outflow;
local minimum_outflow_cronologico = hydro.min_total_outflow_modification;
local minimum_outflow_valido = max(minimum_outflow, minimum_outflow_cronologico):select_stages(1,5);

-- irrigation
local irrigation_violation = hydro:load("irrigation_violation");
local irrigation = hydro.irrigation:select_stages(1,5);

-- turbinamento
local minimum_turbining_violation = hydro:load("minimum_turbining_violation");
local minimum_turbining = hydro.qmin:select_stages(1,5);

local obrigacao_total = max(minimum_turbining, minimum_outflow_valido) + irrigation;
local violacao_total = max(irrigation_violation, minimum_outflow_violation) + irrigation_violation;
local total_violation_percentual = (violacao_total:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/obrigacao_total:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save_and_load("total_violation_percentual");

if is_debug then
    -- conferir se agregacao em estágios deve ser antes ou depois da divisão
    (minimum_outflow_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/minimum_outflow_valido:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save("minimum_outflow_violation_percentual");
    (irrigation_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/irrigation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save("irrigation_violation_percentual");
    (minimum_turbining_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/minimum_turbining:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save("minimum_turbining_violation_percentual");
end

--------------------------------------
---------- dashboard -----------------
--------------------------------------

local function add_percentile_layers(chart, output, force_unit)    
    local p_min = output:aggregate_scenarios(BY_PERCENTILE(5)):rename_agents({"Intervalo de confiança de 95%"});
    local p_max = output:aggregate_scenarios(BY_PERCENTILE(95)):rename_agents({""});
    local avg = output:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Média"});

    if force_unit then
        chart:add_area_range(p_min, p_max, {color="#77a1e5", yUnit=force_unit});
        chart:add_line(avg, {color="#000000", yUnit=force_unit});
    else
        chart:add_area_range(p_min, p_max, {color="#77a1e5"});
        chart:add_line(avg, {color="#000000"});
    end

    return chart
end

-- charts de deficit
local dashboard2 = Dashboard("Energia");

local chart2_1 = Chart("Oferta x Demanda – Sul e Sudeste (valores médios)");
if bool_termica_extra then
    chart2_1:add_column_stacking(
        ((input_termica_extra * duraci):force_unit("GWh")):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Oferta extra"}):convert("GW"), 
    {color="red", yUnit="GWm"}); -- to do: checar cor
end

if bool_int_extra then
    chart2_1:add_column_stacking(
        generic:load("capint2_SE_extra"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Capacidade de interconexão extra"}):convert("GW"), 
        {color="#808080", yUnit="GWm"}
    ); -- to do: checar cor
end

local oferta_termica = thermal_generation:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Oferta térmica disponível"}):convert("GW");
chart2_1:add_column_stacking(oferta_termica, {color="red", yUnit="GWm"});

local importacao_NO_NE = generic:load("capin2_se_min_risk"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Importação do Norte-Nordeste"}):convert("GW");
chart2_1:add_column_stacking(importacao_NO_NE, {color="#e9e9e9", yUnit="GWm"});

local geracao_renovavel_media = renewable_generation:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Geração renovável (média) + biomassa"}):convert("GW");
chart2_1:add_column_stacking(geracao_renovavel_media, {color="#ADD8E6", yUnit="GWm"});

local geracao_hidrica_obrigatoria = hydro_generation:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Geração hídrica obrigatória"}):convert("GW");
chart2_1:add_column_stacking(geracao_hidrica_obrigatoria, {color="#4c4cff", yUnit="GWm"}); -- #0000ff

-- CUIDADO MUDAR NOME - demand e demanda!
local demanda = demand:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Demanda"}):convert("GW");
chart2_1:add_line(demanda, {color="#000000", yUnit="GWm"});
dashboard2:push(chart2_1);

concatenate(
    oferta_termica,
    importacao_NO_NE,
    geracao_renovavel_media,
    geracao_hidrica_obrigatoria,
    demanda
):save("oferta_parcelas");

local enearm_final_risk_level0_SE_or_SU = generic:load("enearm_final_risk_level0_SE_or_SU"):rename_agents({"SE+SU"});
local enearm_final_risk_level1_SE_or_SU = generic:load("enearm_final_risk_level1_SE_or_SU"):rename_agents({"SE+SU"});

local enearm_final_risk_level0_SE_or_SU_pie = 100 - enearm_final_risk_level1_SE_or_SU;
local enearm_final_risk_level1_SE_or_SU_pie = enearm_final_risk_level1_SE_or_SU - deficit_final_risk;
local enearm_final_risk_level2_SE_or_SU_pie = deficit_final_risk;

local chart2_3 = Chart("Análise de suprimento: probabilidade por categoria");
chart2_3:add_pie(enearm_final_risk_level0_SE_or_SU_pie:rename_agents({"Normal"}), {color="green"});
chart2_3:add_pie(enearm_final_risk_level1_SE_or_SU_pie:rename_agents({"Atenção"}), {color="yellow"});
chart2_3:add_pie(enearm_final_risk_level2_SE_or_SU_pie:rename_agents({"Racionamento"}), {color="red"});
dashboard2:push(chart2_3);

dashboard2:push("**Normal**: SE acima de 10% e SU acima de 30%");
dashboard2:push("**Atenção**: SE abaixo de 10% ou SU abaixo de 30%. Sem deficit.");
dashboard2:push("**Racionamento**: Deficit.");

dashboard2:push("**RISCO DO SE ficar entre 10% e 15%: " .. string.format("%.1f", (enearm_final_risk_level0_SE_or_SU-enearm_final_risk_level1_SE_or_SU):to_list()[1]));

local chart2_4 = Chart("Deficit - histograma");
local violation_minimum_value = 0.1;
local number_violations = ifelse(deficit_percentual:gt(violation_minimum_value), 1, 0):aggregate_scenarios(BY_SUM()):to_list()[1];
local deficit_percentual = ifelse(deficit_percentual:gt(violation_minimum_value), deficit_percentual, 0);
local media_violacoes = deficit_percentual:aggregate_scenarios(BY_SUM()) / number_violations;
local maxima_violacao = deficit_percentual:aggregate_scenarios(BY_MAX());

if is_debug then
    deficit_percentual:save("Deficit - histograma");
    media_violacoes:save("media_deficit");
    maxima_violacao:save("maximo_deficit");
end

dashboard2:push("Violação média: **" .. string.format("%.1f", media_violacoes:to_list()[1]) .. "%** da demanda");
dashboard2:push("Violação máxima: **" .. string.format("%.1f", maxima_violacao:to_list()[1]) .. "%** da demanda"); 
chart2_4:add_histogram(deficit_percentual, {color="#d3d3d3", xtickPositions="[0, 20, 40, 60, 80, 100]"}); -- grey
dashboard2:push(chart2_4);

local chart2_5 = Chart("Demanda residual");
chart2_5 = add_percentile_layers(chart2_5, demanda_residual, "GWm");
dashboard2:push(chart2_5);

local chart = Chart("Demanda residual - histograma");
chart:add_histogram(demanda_residual:aggregate_stages(BY_SUM()), {yUnit="GWm", color="#d3d3d3", xtickPositions="[0, 20, 40, 60, 80, 100]"});
dashboard2:push(chart);

local chart2_6 = Chart("Deficit");
chart2_6 = add_percentile_layers(chart2_6, deficit_stages, "GWm");
dashboard2:push(chart2_6);

local chart2_7 = Chart("Enegergia Armazenada - Sudeste");
chart2_7 = add_percentile_layers(chart2_7, enearm_SE_ini_stage, false);

local chart2_8 = Chart("Enegergia Armazenada - Sul");
chart2_8 = add_percentile_layers(chart2_8, enearm_SU_ini_stage, false);
dashboard2:push({chart2_7, chart2_8});

if is_debug then
    demanda_residual:aggregate_stages(BY_SUM()):save("demanda_residual_histogram_data");
end

-- inflows
local dashboard7 = Dashboard("Hidrologia (ENA)");

Inflow_energia_historico_2020 = generic:load("enaflu2020"):convert("GW"):rename_agents({"Histórico 2020 - SU", "Histórico 2020 - SE"});
Inflow_energia_historico_2021 = generic:load("enaflu2021"):convert("GW"):rename_agents({"Histórico 2021 - SU", "Histórico 2021 - SE"});
Inflow_energia_mlt = generic:load("enafluMLT"):convert("GW");

Inflow_energia = system:load("enaf65"):select_stages(1,6):convert("GW"):aggregate_blocks(BY_SUM()); -- rho fixo, 65% do máximo
local chart7_2 = Chart("Energia afluente - Sudeste");

local inflow_energia_se_historico_2020_09 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SE"}):rename_agents({"Histórico 2020 - SE x 90%"}) * 0.9; -- 2020 * 0.9
chart7_2:add_line(inflow_energia_se_historico_2020_09, {yUnit="GWm"});

local inflow_energia_se_historico_2021 = Inflow_energia_historico_2021:select_agents({"Histórico 2021 - SE"});
chart7_2:add_line(inflow_energia_se_historico_2021, {yUnit="GWm"});

local inflow_energia_mlt_se = Inflow_energia_mlt:select_agents({"SE-MLT"});
chart7_2:add_line(inflow_energia_mlt_se, {yUnit="GWm"});

local inflow_energia_se = Inflow_energia:select_agents({"SUDESTE"});
chart7_2 = add_percentile_layers(chart7_2, inflow_energia_se, "GWm");
dashboard7:push(chart7_2);

if is_debug then
    inflow_energia_se:save("inflow_energia_se");
    inflow_energia_mlt_se:save("inflow_energia_mlt_se");
    inflow_energia_se_historico_2021:save("Inflow_energia_se_historico_2021");
    inflow_energia_se_historico_2020_09:save("Inflow_energia_se_historico_2020_09");
end

local chart7_3 = Chart("Energia afluente - Sul");
local inflow_energia_su_historico_2020_09 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SU"}):rename_agents({"Histórico 2020 - SU x 90%"}) * 0.9; -- 2020 * 0.9
chart7_3:add_line(inflow_energia_su_historico_2020_09, {yUnit="GWm"});

local inflow_energia_su_historico_2021 = Inflow_energia_historico_2021:select_agents({"Histórico 2021 - SU"});
chart7_3:add_line(inflow_energia_su_historico_2021, {yUnit="GWm"});

local inflow_energia_mlt_su = Inflow_energia_mlt:select_agents({"SU-MLT"});
chart7_3:add_line(inflow_energia_mlt_su, {yUnit="GWm"})

local inflow_energia_su = Inflow_energia:select_agents({"SUL"});
chart7_3 = add_percentile_layers(chart7_3, inflow_energia_su, "GWm");
dashboard7:push(chart7_3);

if is_debug then
    inflow_energia_su_historico_2020_09:save("inflow_energia_su_historico_2020_09");
    inflow_energia_su_historico_2021:save("inflow_energia_su_historico_2021");
    inflow_energia_mlt_su:save("inflow_energia_mlt_su");
    inflow_energia_su:save("inflow_energia_su");
end

local media_mlt_horizonte = Inflow_energia_mlt:convert("GW"):select_stages(7,11):aggregate_stages(BY_AVERAGE()):reset_stages():aggregate_agents(BY_SUM(), "SE+SU");
-- media_mlt_horizonte = 35.29 GWm

local chart7_4 = Chart("Energia afluente - histograma");
-- xLine = ena media de 2020 entre julho e novembro em GWm
chart7_4:add_histogram((Inflow_energia:select_stages(1,5):convert("GW"):aggregate_stages(BY_AVERAGE()):select_agents({"SUDESTE", "SUL"}):aggregate_agents(BY_SUM(), "SE+SU")/media_mlt_horizonte):convert("%"), {xLine="65.4"});
dashboard7:push(chart7_4);
(Inflow_energia:select_stages(1,5):convert("GW"):aggregate_stages(BY_AVERAGE()):select_agents({"SUDESTE", "SUL"}):aggregate_agents(BY_SUM(), "SE+SU")/media_mlt_horizonte):convert("%"):save("ena_historgram_data");

local ena_media_horizonte_2020_relativo_mlt = 23.07 / media_mlt_horizonte:to_list()[1] * 100; -- %.
local Inflow_energia_2021 = (Inflow_energia:select_stages(1,5):convert("GW"):aggregate_stages(BY_AVERAGE()):select_agents({"SUDESTE", "SUL"}):aggregate_agents(BY_SUM(), "SE+SU")/media_mlt_horizonte):convert("%");
local inflows_acima_ena_2020 = ifelse(Inflow_energia_2021:gt(ena_media_horizonte_2020_relativo_mlt), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%");
dashboard7:push("Probabilidade de ena ser maior que média de 2020 para horizonte: **" .. string.format("%.1f", inflows_acima_ena_2020:to_list()[1]) .. "%**");
dashboard7:push("Ena mlt media: **" .. string.format("%.1f", media_mlt_horizonte:to_list()[1]) .. "**GWm");

local dashboard8 = Dashboard("Hidrologia (usinas)");
--inflow_min_selected
--inflow_2021janjun_selected.csv

local minimum_outflow = hydro.min_total_outflow;
local minimum_outflow_cronologico = hydro.min_total_outflow_modification;
local minimum_outflow_valido = max(minimum_outflow, minimum_outflow_cronologico):select_stages(1,5);
local minimum_turbining = hydro.qmin:select_stages(1,5);
local minimum_outflow_valido = max(minimum_outflow_valido, minimum_turbining);

local irrigation = hydro.irrigation:select_stages(1,5);
local agua_outros_usos = minimum_outflow_valido + irrigation;

-- tem que usar generic neste graf para não assumir que temos dados para todas as hidros
-- dados são para um subconjunto das hidros
local inflow_min_selected = generic:load("inflow_min_selected");
local inflow_2021janjun_selected = generic:load("inflow_2021janjun_selected");
local inflow_agua = generic:load("vazao_natural"):select_stages(1,5)

dashboard8:push("## Resumo");

local md = Markdown()
md:add("|table>");
md:add("Usina|Mínimo Histórico |Uso múltimo da água|probabilidade violação| violação média | violação máxima");
md:add(" | (m3/s)              |(m3/s)             | (%)                  | (%)            | (%)");
md:add("-|-|-|-|-|-");

local inflow_min_selected_agents = {};
for i = 1,inflow_min_selected:agents_size(),1 do
    table.insert(inflow_min_selected_agents, inflow_min_selected:agent(i));
end
table.sort(inflow_min_selected_agents)

for _,agent in ipairs(inflow_min_selected_agents) do
    local label =  "total_violation_percentual_" .. agent
    local total_violation_percentual_agent = total_violation_percentual:select_agents({agent});
    total_violation_percentual_agent:save(label);
    dashboard8:push("### Violações de defluência mínima: " .. agent);

    local violation_minimum_value = 0.1; -- em %
    local violations = ifelse(total_violation_percentual_agent:gt(violation_minimum_value), 1, 0);
    local violations_values = ifelse(total_violation_percentual_agent:gt(violation_minimum_value), total_violation_percentual_agent, 0.0);
    number_violations = violations:aggregate_scenarios(BY_SUM()):to_list()[1];
    dashboard8:push("Probabilidade de violar: **" .. string.format("%.1f", tostring((number_violations/1200) * 100)) .. "%**");
    if number_violations > 0 then
        media_violacoes = violations_values:aggregate_scenarios(BY_SUM()) / number_violations;
        maxima_violacao = violations_values:aggregate_scenarios(BY_MAX());
        
        if is_debug then media_violacoes:save("media_" .. agent); maxima_violacao:save("maximo_" .. agent); end

        dashboard8:push("Violação média: **" .. string.format("%.1f", media_violacoes:to_list()[1]) .. "%** da defluência mínima");
        dashboard8:push("Violação máxima: **" .. string.format("%.1f", maxima_violacao:to_list()[1]) .. "%** da defluência mínima"); 
    else
        dashboard8:push("Violação média: **0.0%** da defluência mínima");
        dashboard8:push("Violação máxima: **0.0%** da defluência mínima");
    end
    -- chart
    local inflow_min_selected_agent = inflow_min_selected:select_agents({agent}):rename_agents({"Vazão mínima"});
    local sum_min_inflow_horizon = inflow_min_selected_agent:select_stages(7,11):aggregate_stages(BY_SUM()):to_list()[1] / 5;
    local inflow_2021janjun_selected_agent = inflow_2021janjun_selected:select_agents({agent}):rename_agents({"2021"});
    local agua_outros_usos_agent = agua_outros_usos:select_agents({agent}):rename_agents({"Defluência mínima"});
    local sum_agua_outros_usos = agua_outros_usos_agent:aggregate_stages(BY_SUM()):to_list()[1] / 5;
    local p_min = inflow_agua:select_agents({agent}):aggregate_scenarios(BY_PERCENTILE(5)):rename_agents({"Intervalo de 95% das vazões naturais"});
    local p_max = inflow_agua:select_agents({agent}):aggregate_scenarios(BY_PERCENTILE(95)):rename_agents({""});   
    local avg = inflow_agua:select_agents({agent}):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Vazão média"});
    
    local chart8_i = Chart("");
    chart8_i:add_line(inflow_min_selected_agent);
    chart8_i:add_line(inflow_2021janjun_selected_agent);
    chart8_i:add_line(agua_outros_usos_agent);
    chart8_i:add_area_range(p_min, p_max, {color="#77a1e5"});
    chart8_i:add_line(avg, {color="#000000"});
    dashboard8:push(chart8_i);
    
    -- historgrama
    local chart8_i2 = Chart("Histograma de violações de defluência mínima");
    chart8_i2:add_histogram(label, {color="#d3d3d3", yUnit="% da defluência mínima não atendida", xtickPositions="[0, 20, 40, 60, 80, 100]"}); -- grey
    dashboard8:push(chart8_i2);

    if number_violations > 0 then
        md:add(agent .. " | " .. string.format("%.1f", tostring(sum_min_inflow_horizon)) .. " | " .. string.format("%.1f", tostring(sum_agua_outros_usos)) .. " | " .. string.format("%.1f", tostring((number_violations/1200) * 100)) .. " | " .. string.format("%.1f", tostring(media_violacoes:to_list()[1]))  .. " | " .. string.format("%.1f", tostring(maxima_violacao:to_list()[1])));
    else
        md:add(agent .. " | " .. string.format("%.1f", tostring(sum_min_inflow_horizon)) .. " | " .. string.format("%.1f", tostring(sum_agua_outros_usos)) .. " | " .. string.format("%.1f", tostring((number_violations/1200) * 100)) .. " | " .. string.format("%.1f", 0.0)  .. " | " .. string.format("%.1f", 0.0));
    end
end

md:add("- | - | - | - | - | -");
md:add("|<table");

dashboard8:push(md);

dashboard8:push("Obs: Aimores tem bastante violação mesmo com o uso múltiplo da água ser abaixo do mínimo histórico." ..
    "Isso pode ser explicado porque a usina a jusante dela - Mascarenhas - tem um aumento de 120m3/s na defluência mínima." ..
    " Isto obriga Aimores turbinar ou verter mais.");

local hydro_selected_agents = hydro.vmax:select_agents(hydro.vmax:gt(hydro.vmin):select_stages(5,5)):agents();
table.sort(inflow_min_selected_agents);

local md = Markdown();
md:add("|table>");
md:add("Usina | Volume morto (%) | volume  útil (Hm3)");
md:add("-|-|-");
for _,agent in ipairs(hydro_selected_agents) do
    local vol_util = (hydro.vmax-hydro.vmin):select_agents({agent});
    local dead_storage = (max(0.0, (max(hydro.alert_storage,hydro.vmin_chronological) - hydro.vmin)):select_agents({agent})/vol_util):convert("%");
    md:add(agent .. " | " .. string.format("%.1f", dead_storage:to_list()[1]) .. " | " .. string.format("%.1f", vol_util:to_list()[1]));
end
md:add("-|-|-");
md:add("|<table");
dashboard8:push(md);

(dashboard7 + dashboard8 + dashboard2):save("risk");