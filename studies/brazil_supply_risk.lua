local is_sddp = false;
local is_debug = false;

local bool_dead_storage_input = true;
local bool_decrease_dead_storage = true;
local decrease_dead_storage = 0.06;

local bool_termica_extra = false;
local input_termica_extra = 6.5 -- GW

local bool_oferta_extra = true;

local bool_int_extra = false;
local input_int_extra = 0.2; -- %

local bool_demanda_reduzida = false;
local input_demanda_reduzida = -0.03; -- % -- adicionar opção de GW, além do aumento percentual

local bool_demand_per_block = false

local function get_scenarios_violations(data, threshold)
    local violations = ifelse(data:gt(threshold), 1, 0);
    return violations:aggregate_scenarios(BY_SUM()):to_list()[1];
end

local generic = require("collection/generic");
local hydro = require("collection/hydro");
local system = require("collection/system");

local duraci = system.duraci;
if bool_demand_per_block then
    duraci = duraci:select_agents({1}):select_stages(1,5);
else
    duraci = duraci:select_agents({1}):select_stages(1,5):aggregate_blocks(BY_SUM());
end
duraci:save("duraci_risk");

if bool_demand_per_block then
    gerhid = hydro:load(is_sddp and "gerhid" or "gerhid_KTT"):convert("GWh"):select_stages(1,5);
    gerhid = gerhid:aggregate_blocks(BY_SUM()):convert("GW") * duraci;
    gerhid = gerhid:convert("GWh");
else
    gerhid = hydro:load(is_sddp and "gerhid" or "gerhid_KTT"):convert("GWh"):aggregate_blocks(BY_SUM()):select_stages(1,5);
end

local renewable = require("collection/renewable");
if bool_demand_per_block then
    gergnd = renewable:load("gergnd"):select_stages(1,5);
else
    gergnd = renewable:load("gergnd"):aggregate_blocks(BY_SUM()):select_stages(1,5);
end

local thermal = require("collection/thermal");
if bool_demand_per_block then
    potter = thermal:load("potter"):convert("GW"):select_stages(1,5) * duraci;
    potter = potter:convert("GWh");
else
    potter = thermal:load("potter"):convert("GWh"):aggregate_blocks(BY_SUM()):select_stages(1,5);
end

local interconnection = require("collection/interconnection");
if bool_demand_per_block then
    capint2 = interconnection:load("capint2"):convert("GWh");
else
    capint2 = interconnection:load("capint2"):convert("GWh"):aggregate_blocks(BY_SUM());
end
capint2_SE = capint2:select_agents({"SE -> NI", "SE -> NE", "SE -> NO"}):aggregate_agents(BY_SUM(), "SE");
capint2_SE:save("capin2_se");

local interconnection_sum = require("collection/interconnectionsum");
if bool_demand_per_block then
    interc_sum = interconnection_sum.ub:select_agents({"Soma   14"}):convert("GWh");
else
    interc_sum = interconnection_sum.ub:select_agents({"Soma   14"}):aggregate_blocks(BY_AVERAGE()):convert("GWh");
end
interc_sum:save("interc_sum_risk");

capint2_SE = min(capint2_SE, interc_sum):select_stages(1,5);
capint2_SE:save("capin2_se_min_risk");

local capint2_SE_extra = capint2_SE * input_int_extra;
capint2_SE_extra:save("capint2_SE_extra");

prodac65 = hydro:load("prodac65"); -- prodac65 (ftp acumulado 65% - sddp)
prod65 = hydro:load("prod65"); -- prod65 (ftp  65% - sddp)
fatorEnergiaArmazenada = hydro:load("fatorEnergiaArmazenada");
fatorEnergiaArmazenada:save("fatorEnergiaArmazenada_debug")

-- local enearm = system:load(is_sddp and "enearm" or "storageenergy_aggregated"):convert("GWh");
-- enearm = is_sddp and enearm or enearm:select_stages(2, enearm:stages()):reset_stages();
if is_sddp then
    volfin_sddp = hydro:load("volfin"):select_stages(1,5):reset_stages();
    rho = hydro:load("rho"):select_stages(1,1):reset_stages();
    enearm = (max(0, volfin_sddp - hydro.vmin) *  rho):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
    enearm = enearm:convert("GWh");
    -- enearm = system:load("enearm"):convert("GWh"):select_stages(1,5);
else
    volfin_ktt = hydro:load("volini_ktt"):select_stages(2,6):reset_stages();
    -- rho = hydro:load("rho"):select_stages(2,6):reset_stages();
    rho = hydro:load("rho"):select_stages(1,1):reset_stages();
    enearm = (max(0, volfin_ktt - hydro.vmin) *  rho):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
    enearm = enearm:convert("GWh");
end

if is_sddp then
    rhomax = hydro:load("rhomax"):select_stages(1,1):reset_stages();
    earmzm = ((hydro.vmax - hydro.vmin):select_stages(5,5):reset_stages() *  rho):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
    -- earmzm = system:load("earmzm"):convert("GWh"):select_stages(5,5);
else
    rhomax = hydro:load("rhomax"):select_stages(1,1):reset_stages();
    earmzm = ((hydro.vmax - hydro.vmin) * rhomax):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"});
    earmzm = earmzm:select_stages(1,1):reset_stages():convert("GWh");
end

if bool_demand_per_block then
    demand = system:load("demand"):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU"):select_stages(1,5);
else
    demand = system:load("demand"):aggregate_blocks(BY_SUM()):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU"):select_stages(1,5);
end
if bool_demanda_reduzida then
    demand = (1 - input_demanda_reduzida) * demand;
end
demand = demand:select_stages(1,5):save_and_load("demand_agg");

local hydro_generation = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local renewable_generation = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");
local thermal_generation = potter:aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_agents(BY_SUM(), "SE + SU");

hydro_generation:save("gerhid_risk")
renewable_generation:save("gergnd_risk")
thermal_generation:save("potter_risk")

-- MAX GENERATION
local generation = hydro_generation + renewable_generation + thermal_generation + capint2_SE;

if bool_int_extra then
    generation = generation + capint2_SE_extra;
end

if bool_termica_extra then
    duraci:save("duraci_ktt");
    generation = generation + (input_termica_extra * duraci):force_unit("GWh");
end
if bool_oferta_extra then
    oferta_extra = generic:load("oferta_extra");
    oferta_extra:save("oferta_extra_debug")
    generation = generation + oferta_extra;
end

generation = generation:select_stages(1,5):save_and_load("max_generation");

-- DEFICIT SEM ENERGIA ARMAZENADA -- TODO CHAMAR DE missmatch
local deficit = ifelse((demand - generation):gt(0), demand - generation, 0);
local demanda_residual = (demand - generation):select_stages(1, 5);
demanda_residual:convert("GW"):save("demanda_residual");

-- DEFICIT SOMA DE MAIO A NOVEMBRO
mismatch_stages = deficit:select_stages(1, 5):rename_agents({"Mismatch - balanço hídrico"}):convert("GW"):save_and_load("mismatch_stages");
local deficit_sum = deficit:select_stages(1, 5):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM());
mismatch = deficit_sum:save_and_load("mismatch");

ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Mismatch - balanço hídrico"}):save("mismatch_risk");

-- DEFICIT RISCO A PRIORI
-- ifelse(deficit_sum:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"risk"}):save("deficit_risk");

enearm_SU_ini_stage = enearm:select_agents({"SUL"}):save_and_load("enearm_SU_ini_stage");
enearm_SE_ini_stage = enearm:select_agents({"SUDESTE"}):save_and_load("enearm_SE_ini_stage");

-- ENERGIA ARMAZENADA DO SUL E SUDESTE
local enearm_SU = enearm:select_agents({"SUL"}):select_stages(5);
local enearm_SE = enearm:select_agents({"SUDESTE"}):select_stages(5);

local enearm_SU_ini = enearm_SU:save_and_load("enearm_SU_ini");
local enearm_SE_ini = enearm_SE:save_and_load("enearm_SE_ini");

local earmzm_max_SU = earmzm:select_agents({"SUL"});
local earmzm_max_SE = earmzm:select_agents({"SUDESTE"});

-- local volumemorto = max(hydro.vmin, max(hydro.alert_storage, hydro.vmin_chronological)) - hydro.vmin;
local rho_dead = hydro:load("rho_dead");
    
if bool_decrease_dead_storage then
    min_vol = decrease_dead_storage * (hydro.vmax - hydro.vmin) + hydro.vmin;
    energiamorta = ((min(min_vol, max(hydro.alert_storage,hydro.vmin_chronological)) - hydro.vmin) * rho_dead);
else
    energiamorta = ((max(hydro.alert_storage,hydro.vmin_chronological) - hydro.vmin) * rho_dead);
end
-- energiamorta = energiamorta:select_stages(5):save_and_load("deadenergy");
energiamorta = hydro:load("dead_energy"):select_stages(5,5):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):convert("GWh");;
energiamorta:save("energiamorta_sistema");
if bool_dead_storage_input then
    energiamorta_SE = energiamorta:select_agents({"SUDESTE"}); -- energiamorta:select_agents({"SUDESTE"});
    energiamorta_SU = energiamorta:select_agents({"SUL"}); --  energiamorta:select_agents({"SUL"});
else
    -- ignorando volume morto e aplicando meta 2 para achar energia morta
    energiamorta_SE = earmzm_max_SE * 0.06;
    energiamorta_SU = earmzm_max_SU * 0.06;
end

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
    )
end

enearm_SE:save("enearm_SE");
enearm_SU:save("enearm_SU");
deficit_sum:save("deficit_sum");

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


local enearm_SE_final = enearm_SE:rename_agents({"SUDESTE"}):save_and_load("enearm_SE_final");
local enearm_SU_final = enearm_SU:rename_agents({"SUL"}):save_and_load("enearm_SU_final");
deficit_sum:rename_agents({"Deficit"}):reset_stages():save("deficit_sum_final");

(enearm_SE_ini - enearm_SE_final):save("geracao_hidro_extra_SE");
(enearm_SU_ini - enearm_SU_final):save("geracao_hidro_extra_SU");

deficit = deficit_sum;

if is_debug then
    earmzm_SE_level1:save("earmzm_SE_level1");
    earmzm_SE_level2:save("earmzm_SE_level2");
    earmzm_SU_level1:save("earmzm_SU_level1");
    earmzm_SU_level2:save("earmzm_SU_level2");
end

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

local has_deficit = ifelse(deficit_sum:gt(1), 1, 0);
(1 - ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0)):save("cenarios_normal");
(ifelse(has_SU_level1_violation | has_SE_level1_violation, 1, 0) - has_deficit):save("cenarios_atencao");
has_deficit:save("cenarios_racionamento");

deficit_final_risk = ifelse(deficit_sum:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):rename_agents({"Deficit risk"}):reset_stages():save_and_load("deficit_final_risk");

local deficit_stages = ifelse(mismatch:ne(0), mismatch_stages * (deficit_sum / mismatch), 0.0):convert("GW"):save_and_load("Deficit_stages");

local deficit_percentual = (deficit_sum/(demand:aggregate_blocks(BY_SUM()):select_stages(demand:stages()-3,demand:stages()-1):reset_stages():aggregate_stages(BY_SUM()))):convert("%"):save_and_load("deficit_percentual");

--------------------------------------
---------- violacao usinas -----------
--------------------------------------

-- min outflow
minimum_outflow_violation = hydro:load("minimum_outflow_violation") ;
minimum_outflow = hydro.min_total_outflow;
minimum_outflow_cronologico = hydro.min_total_outflow_modification;
minimum_outflow_valido = max(minimum_outflow, minimum_outflow_cronologico):select_stages(1,5);
-- conferir se agregacao em estágios deve ser antes ou depois da divisão
minimum_outflow_violation_percentual = (minimum_outflow_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/minimum_outflow_valido:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save_and_load("minimum_outflow_violation_percentual");

-- irrigation
irrigation_violation = hydro:load("irrigation_violation") ;
irrigation = hydro.irrigation:select_stages(1,5);
irrigation_violation_percentual =  (irrigation_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/irrigation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save_and_load("irrigation_violation_percentual");

-- turbinamento
minimum_turbining_violation = hydro:load("minimum_turbining_violation") ;
minimum_turbining = hydro.qmin:select_stages(1,5);
minimum_turbining_violation_percentual =  (minimum_turbining_violation:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/minimum_turbining:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save_and_load("minimum_turbining_violation_percentual");

local obrigacao_total = max(minimum_turbining, minimum_outflow_valido) + irrigation;
local violacao_total = max(irrigation_violation, minimum_outflow_violation) + irrigation_violation;
total_violation_percentual =  (violacao_total:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())/obrigacao_total:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_SUM())):convert("%"):save_and_load("total_violation_percentual");

--------------------------------------
---------- dashboard -----------------
--------------------------------------

local function add_percentile_layers(chart, filename, force_unit)    
    local generic = require("collection/generic");
    local output = generic:load(filename);
    
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

local dashboard1 = Dashboard("Energia armazenada");

-- charts de energia armazenada
-- local chart1_1 = Chart("Violação de energia mínima - balanço hídrico");
-- chart1_1:add_column("enearm_risk_level1_SU");
-- chart1_1:add_column("enearm_risk_level1_SE");
-- chart1_1:add_column("enearm_risk_level1_SE_or_SU");
-- chart1_1:add_column("enearm_risk_level2_SU");
-- chart1_1:add_column("enearm_risk_level2_SE");
-- chart1_1:add_column("enearm_risk_level2_SE_or_SU");
-- dashboard1:push(chart1_1);

-- local chart1_2 = Chart("Violação de energia mínima");
-- chart1_2:add_column("enearm_final_risk_level1_SU");
-- chart1_2:add_column("enearm_final_risk_level1_SE");
-- chart1_2:add_column("enearm_final_risk_level1_SE_or_SU");
-- chart1_2:add_column("enearm_final_risk_level2_SU");
-- chart1_2:add_column("enearm_final_risk_level2_SE");
-- chart1_2:add_column("enearm_final_risk_level2_SE_or_SU");
-- dashboard1:push(chart1_2);

enearm_risk_level1_SU = generic:load("enearm_risk_level1_SU"):rename_agents({"SUL"});
enearm_risk_level2_SU = generic:load("enearm_risk_level2_SU"):rename_agents({"SUL"});
enearm_risk_level0_SU_pie = 100 - enearm_risk_level1_SU;
enearm_risk_level1_SU_pie = enearm_risk_level1_SU - enearm_risk_level2_SU;
enearm_risk_level2_SU_pie = enearm_risk_level2_SU;
enearm_risk_level0_SU_pie:save("enearm_risk_level0_SU_pie");
enearm_risk_level2_SU_pie:save("enearm_risk_level1_SU_pie");
enearm_risk_level1_SU_pie:save("enearm_risk_level2_SU_pie");
local chart1_3 = Chart("Violação de energia mínima - balanço hídrico - SUL");
-- chart1_3:add_pie(
--     concatenate(
--         enearm_risk_level0_SU_pie:rename_agents({"Nível 0 (acima de 30%)"}),
--         enearm_risk_level1_SU_pie:rename_agents({"Nível 1 (entre 30% e 6%)"}),
--         enearm_risk_level2_SU_pie:rename_agents({"Nível 2 (abaixo de 6%)"})
--     )
-- )
chart1_3:add_pie(enearm_risk_level0_SU_pie:rename_agents({"Nível 0 (acima de 30%)"}), {color="green"});
chart1_3:add_pie(enearm_risk_level1_SU_pie:rename_agents({"Nível 1 (entre 30% e 6%)"}), {color="yellow"});
chart1_3:add_pie(enearm_risk_level2_SU_pie:rename_agents({"Nível 2 (abaixo de 6%)"}), {color="red"});

-- dashboard1:push(chart1_3);
enearm_risk_level1_SE = generic:load("enearm_risk_level1_SE"):rename_agents({"SE"});
enearm_risk_level2_SE = generic:load("enearm_risk_level2_SE"):rename_agents({"SE"});

enearm_risk_level0_SE_pie = 100 - enearm_risk_level1_SE;
enearm_risk_level1_SE_pie = enearm_risk_level1_SE - enearm_risk_level2_SE;
enearm_risk_level2_SE_pie = enearm_risk_level2_SE;
enearm_risk_level0_SE_pie:save("enearm_risk_level0_SE_pie");
enearm_risk_level2_SE_pie:save("enearm_risk_level1_SE_pie");
enearm_risk_level1_SE_pie:save("enearm_risk_level2_SE_pie");
local chart1_4 = Chart("Violação de energia mínima - balanço hídrico - SUDESTE");
chart1_4:add_pie(enearm_risk_level0_SE_pie:rename_agents({"Nível 0 (acima de 10%)"}), {color="green"});
chart1_4:add_pie(enearm_risk_level1_SE_pie:rename_agents({"Nível 1 (entre 10% e 6%)"}), {color="yellow"});
chart1_4:add_pie(enearm_risk_level2_SE_pie:rename_agents({"Nível 2 (abaixo de 6%)"}), {color="red"});
dashboard1:push({chart1_3, chart1_4});

enearm_final_risk_level1_SU = generic:load("enearm_final_risk_level1_SU"):rename_agents({"SUL"});
enearm_final_risk_level2_SU = generic:load("enearm_final_risk_level2_SU"):rename_agents({"SUL"});

enearm_final_risk_level0_SU_pie = 100 - enearm_final_risk_level1_SU;
enearm_final_risk_level1_SU_pie = enearm_final_risk_level1_SU - enearm_final_risk_level2_SU;
enearm_final_risk_level2_SU_pie = enearm_final_risk_level2_SU;
enearm_final_risk_level0_SU_pie:save("enearm_final_risk_level0_SU_pie");
enearm_final_risk_level1_SU_pie:save("enearm_final_risk_level1_SU_pie");
enearm_final_risk_level2_SU_pie:save("enearm_final_risk_level2_SU_pie");
local chart1_5 = Chart("Violação de energia mínima - SUL");
chart1_5:add_pie(enearm_final_risk_level0_SU_pie:rename_agents({"Nível 0 (acima de 30%)"}), {color="green"});
chart1_5:add_pie(enearm_final_risk_level1_SU_pie:rename_agents({"Nível 1 (entre 30% e 6%)"}), {color="yellow"});
chart1_5:add_pie(enearm_final_risk_level2_SU_pie:rename_agents({"Nível 2 (abaixo de 6%)"}), {color="red"});

enearm_final_risk_level1_SE = generic:load("enearm_final_risk_level1_SE"):rename_agents({"SE"});
enearm_final_risk_level2_SE = generic:load("enearm_final_risk_level2_SE"):rename_agents({"SE"});

enearm_final_risk_level0_SE_pie = 100 - enearm_final_risk_level1_SE;
enearm_final_risk_level1_SE_pie = enearm_final_risk_level1_SE - enearm_final_risk_level2_SE;
enearm_final_risk_level2_SE_pie = enearm_final_risk_level2_SE;

-- enearm_final_risk_level0_SE_pie:save("enearm_final_risk_level0_SE_pie");
-- enearm_final_risk_level1_SE_pie:save("enearm_final_risk_level1_SE_pie");
-- enearm_final_risk_level2_SE_pie:save("enearm_final_risk_level2_SE_pie");

local chart1_6 = Chart("Violação de energia mínima - SUDESTE");
chart1_6:add_pie(enearm_final_risk_level0_SE_pie:rename_agents({"Nível 0 (acima de 10%)"}), {color="green"});
chart1_6:add_pie(enearm_final_risk_level1_SE_pie:rename_agents({"Nível 1 (entre 10% e 6%)"}), {color="yellow"});
chart1_6:add_pie(enearm_final_risk_level2_SE_pie:rename_agents({"Nível 2 (abaixo de 6%)"}), {color="red"});
dashboard1:push({chart1_5, chart1_6});

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

local oferta_termica = generic:load("potter_risk"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Oferta térmica disponível"}):convert("GW");
chart2_1:add_column_stacking(oferta_termica, {color="red", yUnit="GWm"});

local importacao_NO_NE = generic:load("capin2_se_min_risk"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Importação do Norte-Nordeste"}):convert("GW");
chart2_1:add_column_stacking(importacao_NO_NE, {color="#e9e9e9", yUnit="GWm"});

local geracao_renovavel_media = generic:load("gergnd_risk"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Geração renovável (média) + biomassa"}):convert("GW");
chart2_1:add_column_stacking(geracao_renovavel_media, {color="#ADD8E6", yUnit="GWm"});

local geracao_hidrica_obrigatoria = generic:load("gerhid_risk"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Geração hídrica obrigatória"}):convert("GW");
chart2_1:add_column_stacking(geracao_hidrica_obrigatoria, {color="#4c4cff", yUnit="GWm"}); -- #0000ff

local demanda = generic:load("demand_agg"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Demanda"}):convert("GW");
chart2_1:add_line(demanda, {color="#000000", yUnit="GWm"});
dashboard2:push(chart2_1);

concatenate(
    oferta_termica,
    importacao_NO_NE,
    geracao_renovavel_media,
    geracao_hidrica_obrigatoria,
    demanda
):save("oferta_parcelas");

local enearm_final_risk_level1_SE_or_SU = generic:load("enearm_final_risk_level1_SE_or_SU"):rename_agents({"SE+SU"});
-- local enearm_final_risk_level2_SE_or_SU = generic:load("enearm_final_risk_level2_SE_or_SU"):rename_agents({"SE"});

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

-- local chart2_2 = Chart("Risco de déficit de energia");
-- chart2_2:add_column("mismatch_risk", {color="#CD5C5C"}); -- indian red
-- chart2_2:add_column("deficit_final_risk", {color="#D30000"}); -- red
-- dashboard2:push(chart2_2);

local chart2_4 = Chart("Deficit - histograma");
violation_minimum_value = 0.1;
local number_violations = get_scenarios_violations(deficit_percentual, violation_minimum_value);
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
chart2_5 = add_percentile_layers(chart2_5, "demanda_residual", "GWm");
dashboard2:push(chart2_5);

local chart = Chart("Demanda residual - histograma");
chart:add_histogram(demanda_residual:aggregate_stages(BY_SUM()), {color="#d3d3d3", xtickPositions="[0, 20, 40, 60, 80, 100]"});
dashboard2:push(chart);

local chart2_6 = Chart("Deficit");
chart2_6 = add_percentile_layers(chart2_6, "Deficit_stages", "GWm");
dashboard2:push(chart2_6);

local char2_7 = Chart("Enegergia Armazenada - Sudeste");
-- enearm_se = enearm:select_agents({"SE"}):save_and_load("enearm_se");
chart2_7 = add_percentile_layers(char2_7, "enearm_SE_ini_stage", false)

local char2_8 = Chart("Enegergia Armazenada - Sul");
-- enearm_su = enearm:select_agents({"SU"}):save_and_load("enearm_su");
chart2_8 = add_percentile_layers(char2_8, "enearm_SU_ini_stage", false)
dashboard2:push({char2_7, char2_8});


----- debug -------
-- local dashboard3 = Dashboard("Debug");

-- enearm_SU_ini_stage = enearm:select_agents({"SUL"}):save_and_load("enearm_SU_ini_stage");
-- enearm_SE_ini_stage = enearm:select_agents({"SUDESTE"}):save_and_load("enearm_SE_ini_stage");


-- local chart6 = Chart("Debug");
-- mismatch_stages:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"Mismatch"}):save("Mismatch - first");
-- chart6:add_line("Mismatch - first");
-- deficit_stages:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"Deficit"}):save("Deficit - first");
-- chart6:add_line("Deficit - first");
-- enearm_SE_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"enearm_SE_ini"}):save("enearm_SE_ini - first");
-- chart6:add_line("enearm_SE_ini - first");
-- enearm_SU_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):rename_agents({"enearm_SU_ini"}):save("enearm_SU_ini - first");
-- chart6:add_line("enearm_SU_ini - first");
-- dashboard3:push(chart6);


-- local chart7 = Chart("Debug - 2");
-- hydro_generation = gerhid:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL", "SUDESTE"}):aggregate_stages(BY_SUM()):save("gethid_debug");
-- chart7:add_column("gethid_debug");
-- enearm_SE_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_stages(BY_LAST_VALUE()):rename_agents({"enearm_SE_ini"}):save("enearm_SE_ini_laststage");
-- chart7:add_column("enearm_SE_ini_laststage");
-- enearm_SU_ini_stage:select_stages(1, 5):aggregate_scenarios(BY_FIRST_VALUE()):aggregate_stages(BY_LAST_VALUE()):rename_agents({"enearm_SU_ini"}):save("enearm_SU_ini_laststage");
-- chart7:add_column("enearm_SU_ini_laststage");
-- dashboard:push(chart7);



-- charts de violações de retrições de usinas
local dashboard4 = Dashboard("Violações - Defluência mínima");

local usinas_relevantes_min_outflow = {
    "JIRAU",
    "P. PRIMAVERA",
    "JUPIA",
    "PEIXE ANGIC",
    "SERRA MESA",
    "TRES MARIAS",
    "MARIMBONDO",
    "CAPIVARA",
    "BAIXO IGUACU",
    "FOZ CHAPECO",
    "ITA",
    "MACHADINHO",
    "FUNIL-GRANDE", 
    "D. FRANCISCA"
};
table.sort(usinas_relevantes_min_outflow);

for _, p in ipairs(usinas_relevantes_min_outflow) do 
    local label =  "minimum_outflow_violation_" .. p;
    print(label);
    local chart = Chart(label);
    chart:add_histogram(minimum_outflow_violation_percentual:select_agents({p}), {color="#d3d3d3"}); -- grey
    dashboard4:push(chart);
end

local dashboard5 = Dashboard("Violações - Irrigação");
local usinas_relevantes_irrigacao = {  
    "JIRAU",
    "MARIMBONDO",
    "FOZ CHAPECO",
    "SAO SIMAO",
    "SERRA MESA",
    "MAUA",
    "P. PRIMAVERA",
    "SINOP",
    "AIMORES",
    "ITUMBIARA",
    "EMBORCACAO",
    "ITAIPU",
    "A. VERMELHA",
    "P. COLOMBIA",
    "TELES PIRES",
    "FURNAS"
}
table.sort(usinas_relevantes_irrigacao);

for _, p in ipairs(usinas_relevantes_irrigacao) do 
    local label =  "irrigation_violation_" .. p;
    print(label);

    local chart = Chart(label);
    local agents = irrigation_violation_percentual:select_agents({p}):scenarios_to_agents();
    agents:select_agents(agents:gt(0.1)):save(label);
    chart:add_histogram(label, {color="#d3d3d3"}); -- grey
    dashboard5:push(chart);
end


-- local dashboard6 = Dashboard("Violações - Turbinamento mínimo");
-- -- to do: atualizar lista
-- usinas_relevantes_turbinamento = {"JIRAU",
--                                 "P. PRIMAVERA",
--                                 "JUPIA",
--                                 "PEIXE ANGIC",
--                                 "SERRA MESA",
--                                 "TRES MARIAS",
--                                 "MARIMBONDO",
--                                 "CAPIVARA",
--                                 "BAIXO IGUACU",
--                                 "FOZ CHAPECO",
--                                 "ITA",
--                                 "MACHADINHO",
--                                 "FUNIL-GRANDE", 
--                                 "D. FRANCISCA"
--                                 }
-- for _, p in ipairs(usinas_relevantes_turbinamento) do 
--     local label =  "minimum_turbining_violation_" .. p;
--     local chart = Chart(label);
--     local agents = minimum_turbining_violation_percentual:select_agents({p}):scenarios_to_agents();
--     agents:select_agents(agents:gt(0.1)):save(label);
--     chart:add_histogram(label);
--     dashboard6:push(chart);
-- end

-- inflows
local dashboard7 = Dashboard("Hidrologia (ENA)");

--add_percentile_layers(chart, filename, name_agent)   
-- local chart7_1 = Chart("Água afluente");
-- Inflow_agua = hydro:load("inflow")
-- Inflow_agua_su = Inflow_agua:select_stages(1,5):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL"}):aggregate_agents(BY_SUM(), "SU");
-- Inflow_agua_su:save("inflow_agua+su");
-- Inflow_agua_se = Inflow_agua:select_stages(1,5):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUL"}):aggregate_agents(BY_SUM(), "SU");
-- Inflow_agua_se:save("inflow_agua_se");
-- chart7_1 = add_percentile_layers(chart7_1, "inflow_agua", "Inflow - água");
-- dashboard7:push(chart7_1);
Inflow_energia_historico_2020 = generic:load("enaflu2020"):rename_agents({"Histórico 2020 - SU", "Histórico 2020 - SE"});
Inflow_energia_historico_2021 = generic:load("enaflu2021"):rename_agents({"Histórico 2021 - SU", "Histórico 2021 - SE"});
Inflow_energia_mlt = generic:load("enafluMLT")
-- Inflow_energia = hydro:load("energia_afluente_ktt") * 10^6 / (3600); -- to do: remoer esta conversao
-- Inflow_energia_se = Inflow_energia:convert("MW"):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agents({"SUDESTE"}):aggregate_agents(BY_SUM(), "SE");
-- Inflow_energia = system:load("enaflu"):select_stages(1,6):aggregate_blocks(BY_SUM()); -- rho variado, a conferir
Inflow_energia = system:load("enaf65"):select_stages(1,6):aggregate_blocks(BY_SUM()); -- rho fixo, 65% do máximo
local chart7_2 = Chart("Energia afluente - Sudeste");

-- Inflow_energia_se_historico_2020 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SE"});
-- Inflow_energia_se_historico_2020:save("Inflow_energia_se_historico_2020");
-- chart7_2:add_line("Inflow_energia_se_historico_2020")

Inflow_energia_se_historico_2020_09 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SE"}):rename_agents({"Histórico 2020 - SE x 90%"}) * 0.9; -- 2020 * 0.9
Inflow_energia_se_historico_2020_09:save("Inflow_energia_se_historico_2020_09");
chart7_2:add_line("Inflow_energia_se_historico_2020_09", {yUnit="MWm"});

Inflow_energia_se_historico_2021 = Inflow_energia_historico_2021:select_agents({"Histórico 2021 - SE"});
Inflow_energia_se_historico_2021:save("Inflow_energia_se_historico_2021");
chart7_2:add_line("Inflow_energia_se_historico_2021", {yUnit="MWm"});

Inflow_energia_mlt_se = Inflow_energia_mlt:select_agents({"SE-MLT"});
Inflow_energia_mlt_se:save("Inflow_energia_mlt_se");
chart7_2:add_line("Inflow_energia_mlt_se", {yUnit="MWm"});

Inflow_energia_se = Inflow_energia:convert("MW"):select_agents({"SUDESTE"});
Inflow_energia_se:save("inflow_energia_se");
chart7_2 = add_percentile_layers(chart7_2, "inflow_energia_se", "MWm");

dashboard7:push(chart7_2);


local chart7_3 = Chart("Energia afluente - Sul");
-- Inflow_energia_su_historico_2020 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SU"});
-- Inflow_energia_su_historico_2020:save("Inflow_energia_su_historico_2020");
-- chart7_3:add_line("Inflow_energia_su_historico_2020")
Inflow_energia_su_historico_2020_09 = Inflow_energia_historico_2020:select_agents({"Histórico 2020 - SU"}):rename_agents({"Histórico 2020 - SU x 90%"}) * 0.9; -- 2020 * 0.9
Inflow_energia_su_historico_2020_09:save("Inflow_energia_su_historico_2020_09");
chart7_3:add_line("Inflow_energia_su_historico_2020_09", {yUnit="MWm"});

Inflow_energia_su_historico_2021 = Inflow_energia_historico_2021:select_agents({"Histórico 2021 - SU"});
Inflow_energia_su_historico_2021:save("Inflow_energia_su_historico_2021");
chart7_3:add_line("Inflow_energia_su_historico_2021", {yUnit="MWm"});

Inflow_energia_mlt_su = Inflow_energia_mlt:select_agents({"SU-MLT"});
Inflow_energia_mlt_su:save("Inflow_energia_mlt_su");
chart7_3:add_line("Inflow_energia_mlt_su", {yUnit="MWm"})

Inflow_energia_su = Inflow_energia:convert("MW"):select_agents({"SUL"});
Inflow_energia_su:save("inflow_energia_su");
chart7_3 = add_percentile_layers(chart7_3, "inflow_energia_su", "MWm");

dashboard7:push(chart7_3);

local dashboard8 = Dashboard("Hidrologia (usinas)");
--inflow_min_selected
--inflow_2021janjun_selected.csv

local minimum_outflow = hydro.min_total_outflow;
local minimum_outflow_cronologico = hydro.min_total_outflow_modification;
local minimum_outflow_valido = max(minimum_outflow, minimum_outflow_cronologico):select_stages(1,5);
local minimum_turbining_violation = hydro:load("minimum_turbining_violation");
local minimum_turbining = hydro.qmin:select_stages(1,5);
local minimum_outflow_valido = max(minimum_outflow_valido, minimum_turbining);
local irrigation_violation = hydro:load("irrigation_violation");
local irrigation = hydro.irrigation:select_stages(1,5);
local agua_outros_usos = minimum_outflow_valido + irrigation;

-- tem que usar generic neste graf para não assumir que temos dados para todas as hidros
-- dados são para um subconjunto das hidros
local inflow_min_selected = generic:load("inflow_min_selected");
inflow_2021janjun_selected = generic:load("inflow_2021janjun_selected");
inflow_agua = generic:load("vazao_natural"):select_stages(1,5)


local md = Markdown()
md:add("|table>");
md:add("Usina|Mínimo Histórico |Uso múltimo da água|probabilidade violação| violação média | violação máxima");
md:add(" | (m3/s)              |(m3/s)             | (%)                  | (%)            | (%)");
md:add("-|-|-|-|-|-");
-- md:add("cell 1|cell 2|cell 3|cell 4|cell 5|cell 6");
-- md:add("cell 4|cell 5|cell 6");

local inflow_min_selected_agents = {};
for i = 1,inflow_min_selected:agents_size(),1 do
    table.insert(inflow_min_selected_agents, inflow_min_selected:agent(i));
end
table.sort(inflow_min_selected_agents)

-- inflow_min_selected:agents_size()
for _,agent in ipairs(inflow_min_selected_agents) do
    -- tabela
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

    -- md = Markdown()
    -- md:add("|table>");
    -- md:add("Cenários violados | Média de violacões (%)");
    -- md:add("- | -");
    -- md:add( tostring(number_violations) " | " .. tostring(media_violacoes));
    -- md:add("|<table");
    -- dashboard8:push(md);
end

md:add("- | - | - | - | - | -");
-- md:add("foot a|foot b|foot c");
md:add("|<table");
dashboard8:push("## Resumo");
dashboard8:push(md);

dashboard8:push("Obs: Aimores tem bastante violação mesmo com o uso múltiplo da água ser abaixo do mínimo histórico." ..
    "Isso pode ser explicado porque a usina a jusante dela - Mascarenhas - tem um aumento de 120m3/s na defluência mínima." ..
    " Isto obriga Aimores turbinar ou verter mais.");




(dashboard7 + dashboard8 + dashboard2):save("risk");