-- C:\PSR\GraphModule\Oper\psrplot\psrio\psrio.exe --model OPTGEN -r "D:\SDDP_1\sddp\psrio-scripts\sddp\sddp-dashlib.lua,D:\PSRIO-scripts\optgen\optgen-dashboard.lua" "C:\PSR\Optgen8.1\Example\Typical_Day\3_typday"
--=================================================--
-- Create Vectors of collections
--=================================================--
local battery<const> = {};
local bus<const>  = {};
local circuit<const> = {};
local dclink<const>  = {};
local expansioncapacity<const> = {};
local expansionconstraint<const> = {};
local expansiondecision<const> = {};
local expansionproject<const> = {};
local generic<const> = {};
local hydro<const> = {};
local powerinjection<const> = {};
local renewable<const> = {};
local system<const> = {};
local study<const> = {};
local thermal<const> = {};

local cases<const> = PSR.studies();
for i = 1, cases do
    table.insert(battery, Battery(i));
    table.insert(bus, Bus(i));
    table.insert(circuit, Circuit(i));
    table.insert(dclink, DCLink(i));
    table.insert(expansioncapacity, ExpansionCapacity(i));
    table.insert(expansionconstraint, ExpansionConstraint(i));
    table.insert(expansiondecision, ExpansionDecision(i));
    table.insert(expansionproject, ExpansionProject(i));
    table.insert(generic, Generic(i));
    table.insert(hydro, Hydro(i));
    table.insert(powerinjection, PowerInjection(i));
    table.insert(renewable, Renewable(i));
    table.insert(system, System(i));
    table.insert(study, Study(i));
    table.insert(thermal, Thermal(i));
end

--=================================================--
-- Dictionary of Colors
--=================================================--

local colors<const> = {
    total_generation = {
        thermal = "#F28E2B",
        hydro = "#4E79A7",
        solar = "#F1CE63",
        wind = "#8CD17D",
        renewable = "#8a8881",
        csp = "#b0ada4",
        battery = "#FF9DA7",
        defict = "#000000",
        bio = "#B900FF",
        pch = "#33FFF3"
    },
    total_circuit = {
        ac = "#e3554b",
        dc = "#9a4be3",
    },
    total_costs = {
        operational = "#8CD17D",
        investiment  = "#F1CE63",
        thermal = "#F28E2B",
        hydro = "#4E79A7",
        renewable = "#8a8881",
        solar = "#F1CE63",
        wind = "#8CD17D",
        csp = "#b0ada4",
        battery = "#FF9DA7",
        ac = "#e3554b",
        dc = "#9a4be3",
        bio = "#B900FF",
        pch = "#33FFF3"
    },
    cost = {
        marginal_cost = "#8CD17D"
    },
    generic = {
        "#F28E2B",
        "#4E79A7",
        "#8CD17D",
        "#8a8881",
        "#b0ada4",
        "#FF9DA7",
        "#000000",
        "#FF9DA7",
        "#8a8881",
        "#B07AA1",
        "#59A14F",
        "#F1CE63",
        "#A0CBE8"
    },
    techs = {
        "#F28E2B",
        "#4E79A7",
        "#8CD17D",
        "#8a8881",
        "#b0ada4",
        "#FF9DA7",
        "#000000"
    },
    obj_function = {
        operative_cost = "#D3D3D3",
        investment_cost = "#2F4F4F",
        deficit_cost = "#4682B4",
        gas_tranport = "#8B4513",
        min_storage_penalty = "#B22222",
        outflow_penalty = "#4B0082",
        min_turbinament_penalty = "#BC8F8F",
        irrigation_penalty = "#696969",
        reserve_penalty = "#008080",
        generation_ctr_penalty = "#8B4513",
        delta_reserve_penalty = "#D2691E",
        spillage_penalty = "#F4A460",
        emition_penalty = "#A9A9A9",
        gas_deficti_cost = "#2E8B57"
    },
    risk = {
        deficit = "#FF0000"
    }
};

--=================================================--
-- Dictionaries of Names
--=================================================--
local dictionary<const> = {
    investment_report = {
        en = "Investment report",
        es = "Informe de inversiones",
        pt = "Relatório de investimentos"
    },
    optgen_2_reports = {
        en = "OptGen 2 reports",
        es = "Informes OptGen 2",
        pt = "Relatórios OptGen 2"
    },
    optgen_risk = {
        en = "Risk reports",
        es = "Informes de riesgo",
        pt = "Relatórios de risco"
    },
    risk_expected = {
        en = "Total expected cost",
        es = "Costo total esperado",
        pt = "Custo total esperado"
    },
    risk_var = {
        en = "[CVaR (K$) - Expected cost (K$)] / Expected cost (K$)",
        es = "[CVaR (K$) - Costo esperado (K$)] / Costo esperado (K$)",
        pt = "[CVaR (K$) - Custo esperado (K$)] / Custo esperado (K$)"
    },
    expansion_results = {
        en = "Expansion results",
        es = "Resultados de expansión",
        pt = "Resultados de expansão"
    },
    sddp = {
        en = "SDDP reports",
        es = "Informes SDDP",
        pt = "Relatórios SDDP"
    },
    accumulated_capacity = {
        en = "Cumulative capacity added to the system",
        es = "Capacidad acumulada añadida al sistema",
        pt = "Capacidade acumulada adicionada ao sistema"
    },
    circuit_accumulated_capacity = {
        en = "Cumulative capacity of lines added to the system",
        es = "Capacidad acumulada de líneas añadidas al sistema",
        pt = "Capacidade acumulada de linhas adicionadas ao sistema"
    },
    annualized_investment_cost = {
        en = "Annualized investment cost",
        es = "Costo anualizado de inversiones",
        pt = "Custo anualizado de investimentos"
    },
    total_costs = {
        en = "Total costs",
        es = "Costos totales",
        pt = "Custos totais"
    },
    total_operational_costs = {
        en = "Total operational costs",
        es = "Costos totales operacionais",
        pt = "Custos totais operacionais"
    },
    total_investment_cost = {
        en = "Investment costs",
        es = "Costos de inversiones",
        pt = "Custos de investimento"
    },
    total_thermal = {
        en = "Thermal",
        es = "Térmica",
        pt = "Térmica"
    },
    total_hydro = {
        en = "Hydro",
        es = "Hidráulica",
        pt = "Hidráulica"
    },
    total_renewable = {
        en = "Other renewables",
        es = "Otras renovables",
        pt = "Outras renováveis"
    },
    total_solar = {
        en = "Solar",
        es = "Solar",
        pt = "Solar"
    },
    total_wind = {
        en = "Wind",
        es = "Eólica",
        pt = "Eólica"
    },
    total_csp = {
        en = "CSP",
        es = "CSP",
        pt = "CSP"
    },
    total_bio = {
        en = "Biomass",
        es = "Biomasa",
        pt = "Biomassa"
    },
    total_pch = {
        en = "Small Hydro",
        es = "PCH",
        pt = "PCH"
    },
    total_battery = {
        en = "Battery",
        es = "Batería",
        pt = "Bateria"
    },
    total_injection = {
        en = "Injection",
        es = "Inyección",
        pt = "Injeção"
    },
    total_ac_circuit = {
        en = "AC circuit",
        es = "Circuito AC",
        pt = "Circuito AC"
    },
    total_dc_circuit = {
        en = "DC circuit",
        es = "Circuito DC",
        pt = "Circuito DC"
    },
    deficit = {
        en = "Deficit",
        es = "Déficit",
        pt = "Déficit"
    },
    total_installed_capacity = {
        en = "Total installed capacity",
        es = "Capacidad total instalada",
        pt = "Capacidade total instalada"
    },
    total_installed_capacity_mix = {
        en = "Total installed capacity Mix",
        es = "Mix de capacidad total instalada",
        pt = "Mix de capacidade total instalada"
    },
    firm_capacity = {
        en = "Firm capacity",
        es = "Capacidad firme",
        pt = "Capacidade firme"
    },
    firm_capacity_mix = {
        en = "Firm capacity mix",
        es = "Mix de capacidad firme",
        pt = "Mix de Capacidade firme"
    },
    firm_energy = {
        en = "Firm energy",
        es = "Energía firme",
        pt = "Energia firme"
    },
    firm_energy_mix = {
        en = "Firm energy mix",
        es = "Mix de energía firme",
        pt = "Mix de energia firme"
    },
    marginal_cost = {
        en = "Marginal cost",
        es = "Marginal anual",
        pt = "Marginal anual"
    },
    annual_marginal_cost = {
        en = "Annual marginal cost",
        es = "Costo marginal anual",
        pt = "Custo marginal anual"
    },
    monthly_marginal_cost = {
        en = "Monthly marginal cost",
        es = "Costo marginal mensual",
        pt = "Custo marginal mensal"
    },
    hourly_marginal_cost_typical = {
        en = "Hourly marginal cost per typical day",
        es = "Costo marginal horario por día típico",
        pt = "Custo marginal horário por dia típico"
    },
    omc = {
        en = "OMC",
        es = "CMO",
        pt = "CMO"
    },
    stage = {
        en = "Stage",
        es = "Etapa",
        pt = "Etapa"
    },
    month = {
        en = "Month",
        es = "Mes",
        pt = "Mês"
    },
    week = {
        en = "Week",
        es = "Semana",
        pt = "Semana"
    },
    deficit_risk = {
        en = "Deficit risk",
        es = "Riesgo de déficit",
        pt = "Risco de déficit"
    },
    total_generation = {
        -- en = "Generation in each season of the year",
        -- es = "Generación en cada estación del año",
        -- pt = "Geração em cada estação do ano"
        en = "Total generation",
        es = "Generación total",
        pt = "Geração total"
    },
    generation_per_typical_day = {
        en = "Hourly generation per typical day",
        es = "Generación horaria por día típico",
        pt = "Geração horária por dia típico"
    },
    season = {
        en = "Season",
        es = "Estación",
        pt = "Estação"
    },
    year = {
        en = "Year",
        es = "Año",
        pt = "Ano"
    },
    typical_day = {
        en = "Typical day",
        es = "Día típico",
        pt = "Dia típico"
    },
    objective_functions = {
        en = "Objective function",
        es = "Función objetivo",
        pt = "Função objetivo"
    },
    convergence_report = {
        en = "Objective function",
        es = "Función objetivo",
        pt = "Função objetivo"
    },
    data_not_exist = {
        en = "None data to graph",
        es = "Ningún dato para graficar",
        pt = "Nenhum dado para graficar"
    },
    GAP = {
        en = "GAP",
        es = "GAP",
        pt = "GAP"
    },
    convergence = {
        en = "Convergence",
        es = "Convergencia",
        pt = "Convergência"
    },
    gap_convergence = {
        en = "GAP Convergence",
        es = "GAP de convergencia ",
        pt = "GAP de convergência"
    }
};

--=================================================--
-- Dictionaries of Charts plots
--=================================================--
local plot<const> = {
    accumulated_capacity         = true,
    circuit_accumulated_capacity = true,
    annualized_investment_cost   = false,
    total_cost                   = true,
    total_installed_capacity     = true,
    total_installed_capacity_mix = true,
    firm_capacity                = true,
    firm_capacity_mix            = true,
    firm_energy                  = true,
    firm_energy_mix              = true,
    annual_marginal_cost         = true,
    monthly_marginal_cost        = true,
    hourly_marginal_cost_typical = true,
    deficit_risk                 = true,
    generation_in_each_season    = true,
    hourly_generation_typical    = true,
    objective_function           = true,
    risk_curve                   = true,
    convergence                  = true
};
--=================================================--
-- Get parameters Functions
--=================================================--
-- Get language
local function load_language()
    local language = study[1]:get_parameter("Idioma", 0);

    if language == 1 then
        return "es";
    elseif language == 2 then
        return "pt";
    else -- language == 0
        return "en";
    end
end

local function identify_if_opt2()
    for case = 1, cases do
        if study[case]:get_parameter("OPTG", -1) == 2 and not
          (study[case]:get_parameter("ReadExpansionPlan", -1) == 2 and 
           study[case]:get_parameter("DecisionType", -1) == 1 and
           study[case]:get_parameter("FOPT", -1) == 2) then
            return true;
        end
    end
    return false;
end

local function identify_if_has_network()
    local network = {};
    for case = 1, cases do
        if study[case]:get_parameter("Rede", -1) == 1 then
            table.insert(network, true);
        else
            table.insert(network, false);
        end
    end
    return network;
end

--=================================================--
-- Parameters
--=================================================--
local language<const> = load_language();

local is_opt2<const> = identify_if_opt2();
local risk_results = true;
local has_network<const> = identify_if_has_network();

--=================================================--
-- Utils
--=================================================--
function Expression.convert_MW_to_GWh(self)
    if self:loaded() then
        local duraci = Generic(self:study_index()):load("duraci");
        if duraci:loaded() then
            if is_opt2 then
                duraci = Generic(self:study_index()):load("opt2_duraci");
            end

            if self:unit() == "MW" then
                return ((self * duraci)/1000):force_unit("GWh");
            elseif self:unit() == "GWh" then
                return
            end
            warn("Conversion MW to GWh failed. The expression is not in MW units.");
            return duraci
        end
    end
    return self;
end

function Expression.aggregate_blocks_by_average(self)
    if self:loaded() then
        local unit = self:unit();
        local duraci_pu = Generic(self:study_index()):load("opt2_duracipu");
        if duraci_pu:loaded() then
            local self_pond = duraci_pu * self;
            return self_pond:aggregate_blocks(BY_SUM()):force_unit(unit);
        end
    end
    return self;
end
--=================================================--
-- Create Base Functions
--=================================================--
local function create_tab(label, icon)
    local tab<const> = TabVue(label);
    tab:set_icon(icon);
    tab:push("# " .. label);
    return tab;
end

local function create_chart(label, case)
    if cases == 1 then
        return ChartVue(label);
    else
        return ChartVue(label .. " (case " .. case .. ")");
    end
end

--=================================================--
-- Create Charts Functions
--=================================================--


local function chart_accumulated_capacity(case)
    local outidec = generic[case]:load("outidec"); -- tem erro no expansionproject (agentes fora da collection)

    local thermal_cap   = outidec:select_agents(Collection.THERMAL)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local hydro_cap     = outidec:select_agents(Collection.HYDRO)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local renewable_cap = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(0))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local solar_cap     = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(2))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local wind_cap      = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(1))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local csp_cap       = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(5))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local bio_cap       = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(3))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local pch_cap       = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(4))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local battery_cap   = outidec:select_agents(Collection.BATTERY)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_column_stacking(thermal_cap:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_column_stacking(hydro_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_column_stacking(renewable_cap:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_column_stacking(solar_cap:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_column_stacking(wind_cap:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_column_stacking(csp_cap:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_column_stacking(battery_cap:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_column_stacking(bio_cap:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_column_stacking(pch_cap:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_circuit_accumulated_capacity(case)
    local outidec = generic[case]:load("outidec"); -- tem erro no expansionproject (agentes fora da collection)

    local ac_cap   = outidec:select_agents(Collection.CIRCUIT)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR);
    local dc_cap   = outidec:select_agents(Collection.DCLINK)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_column_stacking(ac_cap:aggregate_agents(BY_SUM(), dictionary.total_ac_circuit[language]):remove_zeros():round(0), { color = colors.total_circuit.ac });
    chart:add_column_stacking(dc_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]):remove_zeros():round(0), { color = colors.total_circuit.dc });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_annualized_investment_cost(case)
    local outdfact = generic[case]:load("outdfact");
    local outdisbu = generic[case]:load("outdisbu"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()) * outdfact;

    local interest = (1 + study[case].discount_rate:aggregate_stages(BY_FIRST_VALUE(),Profile.PER_YEAR)) ^ (study[case].stage_in_year:aggregate_stages(BY_FIRST_VALUE(),Profile.PER_YEAR):cumsum_stages() - 1);
    local anual_outdisbu = outdisbu:aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR) * interest;

    local anual_inv_therm = anual_outdisbu:select_agents(Collection.THERMAL):aggregate_agents(BY_SUM(), dictionary.total_thermal[language]):remove_zeros():round(0);
    local anual_inv_hydro = anual_outdisbu:select_agents(Collection.HYDRO  ):aggregate_agents(BY_SUM(), dictionary.total_hydro[language]):remove_zeros():round(0);
    local anual_inv_batte = anual_outdisbu:select_agents(Collection.BATTERY):aggregate_agents(BY_SUM(), dictionary.total_battery[language]):remove_zeros():round(0);
    local anual_inv_solar = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(2) )
                              :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local anual_inv_wind  = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(1) )
                              :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local anual_inv_csp   = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(5) )
                              :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local anual_inv_other = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(0) )
                              :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);
    local anual_inv_ac    = anual_outdisbu:select_agents(Collection.CIRCUIT):aggregate_agents(BY_SUM(), dictionary.total_ac_circuit[language]):remove_zeros():round(0);
    local anual_inv_dc    = anual_outdisbu:select_agents(Collection.DCLINK ):aggregate_agents(BY_SUM(), dictionary.total_dc_circuit[language]):remove_zeros():round(0);
    local anual_inv_bio  = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(3) )
                              :aggregate_agents(BY_SUM(), dictionary.total_bio[language]):remove_zeros():round(0);
    local anual_inv_pch  = anual_outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(4) )
                              :aggregate_agents(BY_SUM(), dictionary.total_pch[language]):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    local concatenated_inv_cost = {
        anual_inv_therm,
        anual_inv_hydro,
        anual_inv_batte,
        anual_inv_solar,
        anual_inv_wind,
        anual_inv_csp,
        anual_inv_other,
        anual_inv_ac,
        anual_inv_dc,
        anual_inv_bio,
        anual_inv_pch
    };

    local years_names = {};
    local initial_year = study[case]:initial_year();
    for year = 1, anual_outdisbu:stages() do
        table.insert(years_names, tostring(initial_year+year-1));
    end

    local colors_vec = {
        colors.total_costs.thermal,
        colors.total_costs.hydro,
        colors.total_costs.battery,
        colors.total_costs.solar,
        colors.total_costs.wind,
        colors.total_costs.csp,
        colors.total_costs.renewable,
        colors.total_costs.ac,
        colors.total_costs.dc,
        colors.total_costs.bio,
        colors.total_costs.pch
    };
    
    for i, inv_cost in ipairs(concatenated_inv_cost) do
        local agent_name = inv_cost:agents()[1];
        local stages = inv_cost:stages();
        local stage_inv_cost = inv_cost:stages_to_agents():rename_agents(years_names);
        if stage_inv_cost:loaded() then
            chart:add_column_stacking_categories(stage_inv_cost, agent_name, { color = colors_vec[i] });
        end
    end

    return chart;
end

local function chart_total_cost(case)

    local objcop =    generic[case]:load("objcop");
    local outdbtot =  generic[case]:load("outdbtot");
    local outdfact =  generic[case]:load("outdfact");
    local outdisbu =  generic[case]:load("outdisbu"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()) * outdfact;

    local costs;
    if study[case]:is_hourly() then
        costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM());
    else
        costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM());
        costs = costs:remove_agents({-1});
    end

    local study_outdbtot = outdbtot:aggregate_agents(BY_SUM(), "Inv. Cost.");
    local study_outdfact = outdfact:aggregate_agents(BY_SUM(), "PSRStudy");

    local ope_total = (costs:aggregate_agents(BY_SUM(), dictionary.total_operational_costs[language]):aggregate_scenarios(BY_AVERAGE()) * study_outdfact):aggregate_stages(BY_SUM()):convert("M$"):round(0);
    local inv_total = (study_outdbtot * study_outdfact):aggregate_stages(BY_SUM()):convert("M$"):round(0):rename_agents({dictionary.total_investment_cost[language]});

    if not ope_total:loaded() then
        ope_total = generic[case]:create(dictionary.total_operational_costs[language], "M$", {0});
    end

    if not inv_total:loaded() then
        inv_total = generic[case]:create(dictionary.total_investment_cost[language], "M$", {0});
    end

    local inv_therm = outdisbu:select_agents(Collection.THERMAL):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_hydro = outdisbu:select_agents(Collection.HYDRO  ):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_batte = outdisbu:select_agents(Collection.BATTERY):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_solar = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(2) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_wind  = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(1) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_csp   = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(5) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_other = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(0) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_ac    = outdisbu:select_agents(Collection.CIRCUIT):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_dc    = outdisbu:select_agents(Collection.DCLINK ):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_bio  = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(3) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_pch  = outdisbu:select_agents(Collection.RENEWABLE)
                              :select_agents(renewable[case].tech_type:eq(4) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);

    local chart_a = create_chart("", case);
    chart_a:horizontal_legend();
    chart_a:add_pie(ope_total, { color = colors.total_costs.operational });
    chart_a:add_pie(inv_total, { color = colors.total_costs.investiment });

    local chart_b = create_chart("", case);
    chart_b:horizontal_legend();
    chart_b:add_pie(inv_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_costs.thermal });
    chart_b:add_pie(inv_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_costs.hydro });
    chart_b:add_pie(inv_other:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_costs.renewable });
    chart_b:add_pie(inv_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_costs.solar });
    chart_b:add_pie(inv_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_costs.wind });
    chart_b:add_pie(inv_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_costs.csp });
    chart_b:add_pie(inv_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_costs.battery });
    chart_b:add_pie(inv_ac:aggregate_agents(BY_SUM(), dictionary.total_ac_circuit[language]), { color = colors.total_costs.ac });
    chart_b:add_pie(inv_dc:aggregate_agents(BY_SUM(), dictionary.total_dc_circuit[language]), { color = colors.total_costs.dc });
	chart_b:add_pie(inv_bio:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_costs.bio });
	chart_b:add_pie(inv_pch:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_costs.pch });

    if #chart_a == 0 or #chart_b == 0 then
        return
    end
    
    return { chart_a, chart_b };
end

local function chart_total_installed_capacity(case)
    local renewable_cap_ind = renewable[case]:load("pnomnd");

    local thermal_cap   = thermal[case]:load("pnomtr"):remove_zeros():round(0);
    local hydro_cap     = hydro[case]:load("pnomhd"):remove_zeros():round(0);
    local batte_cap     = battery[case]:load("pnombat"):remove_zeros():round(0);

    local renewable_cap = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(0) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local solar_cap     = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(2) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local wind_cap      = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(1) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bio_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(3) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local pch_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(4) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local csp_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bat_cap       = batte_cap:aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_spline_stacking(thermal_cap:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(hydro_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(renewable_cap:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(solar_cap:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(wind_cap:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(csp_cap:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(bat_cap:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
	chart:add_area_spline_stacking(bio_cap:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
	chart:add_area_spline_stacking(pch_cap:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_total_installed_capacity_mix(case)
    local renewable_cap_ind = renewable[case]:load("pnomnd"):round(0);

    local thermal_cap   = thermal[case]:load("pnomtr"):remove_zeros():round(0);
    local hydro_cap     = hydro[case]:load("pnomhd"):remove_zeros():round(0);
    local batte_cap     = battery[case]:load("pnombat"):remove_zeros():round(0);


    local renewable_cap = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(0) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local solar_cap     = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(2) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local wind_cap      = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(1) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bio_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(3) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local pch_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(4) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local csp_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bat_cap       = batte_cap:aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_percent(thermal_cap:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_percent(hydro_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_percent(renewable_cap:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_percent(solar_cap:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_percent(wind_cap:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_percent(csp_cap:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_percent(bat_cap:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_percent(bio_cap:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_area_percent(pch_cap:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return
    end
    return chart;
end

local function chart_firm_capacity(case)
    local firm_capacity_renew = renewable[case]:load("outrpa"):round(0);

    local firm_capacity_hydro = hydro[case]:load("outhpa"):remove_zeros():round(0);
    local firm_capacity_therm = thermal[case]:load("outtpa"):remove_zeros():round(0);
    local firm_capacity_batte = battery[case]:load("outbpa"):remove_zeros():round(0);

    local firm_capacity_gener = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(0) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);
    local firm_capacity_wind  = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_capacity_solar = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_capacity_bio   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(3) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_bio[language]):remove_zeros():round(0);
    local firm_capacity_pch   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(4) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_pch[language]):remove_zeros():round(0);
    local firm_capacity_csp   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_spline_stacking(firm_capacity_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(firm_capacity_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(firm_capacity_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(firm_capacity_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(firm_capacity_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(firm_capacity_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
	chart:add_area_spline_stacking(firm_capacity_bio:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
	chart:add_area_spline_stacking(firm_capacity_pch:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });
    chart:add_area_spline_stacking(firm_capacity_gener:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_firm_capacity_mix(case)
    local firm_capacity_renew = renewable[case]:load("outrpa"):round(0);
    local firm_capacity_hydro = hydro[case]:load("outhpa"):remove_zeros():round(0);
    local firm_capacity_therm = thermal[case]:load("outtpa"):remove_zeros():round(0);
    local firm_capacity_batte = battery[case]:load("outbpa"):remove_zeros():round(0);
    local firm_capacity_solar = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_capacity_wind  = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_capacity_csp   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_capacity_bio   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(3) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_bio[language]):remove_zeros():round(0);
    local firm_capacity_pch   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(4) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_pch[language]):remove_zeros():round(0);
    local firm_capacity_gene  = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(0) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_percent(firm_capacity_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_percent(firm_capacity_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_percent(firm_capacity_gene:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_percent(firm_capacity_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_percent(firm_capacity_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_percent(firm_capacity_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_percent(firm_capacity_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_percent(firm_capacity_bio:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_area_percent(firm_capacity_pch:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return
    end
    return chart;
end

local function chart_firm_energy(case)
    local firm_energy_renew = renewable[case]:load("outrea"):round(0);
    local firm_energy_hydro = hydro[case]:load("outhea"):remove_zeros():round(0);
    local firm_energy_therm = thermal[case]:load("outtea"):remove_zeros():round(0);
    local firm_energy_batte = battery[case]:load("outbea"):remove_zeros():round(0);
    local firm_energy_solar   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_energy_wind    = firm_energy_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_energy_bio     = firm_energy_renew:select_agents(renewable[case].tech_type:eq(3) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_bio[language]):remove_zeros():round(0);
    local firm_energy_pch     = firm_energy_renew:select_agents(renewable[case].tech_type:eq(4) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_pch[language]):remove_zeros():round(0);
    local firm_energy_csp     = firm_energy_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_energy_renew   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(0) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_spline_stacking(firm_energy_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(firm_energy_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(firm_energy_renew:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(firm_energy_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(firm_energy_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(firm_energy_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(firm_energy_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_spline_stacking(firm_energy_bio:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_area_spline_stacking(firm_energy_pch:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_firm_energy_mix(case)
    local firm_energy_renew = renewable[case]:load("outrea"):round(0);
    local firm_energy_hydro = hydro[case]:load("outhea"):remove_zeros():round(0);
    local firm_energy_therm = thermal[case]:load("outtea"):remove_zeros():round(0);
    local firm_energy_batte = battery[case]:load("outbea"):remove_zeros():round(0);
    local firm_energy_solar = firm_energy_renew:select_agents(renewable[case].tech_type:eq(2) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_energy_wind  = firm_energy_renew:select_agents(renewable[case].tech_type:eq(1) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_energy_bio   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(3))
                                               :aggregate_agents(BY_SUM(), dictionary.total_bio[language]):remove_zeros():round(0);
    local firm_energy_pch   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(4) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_pch[language]):remove_zeros():round(0);
    local firm_energy_csp   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(5) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_energy_renew = firm_energy_renew:select_agents(renewable[case].tech_type:eq(0) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local chart = create_chart("", case)
    chart:horizontal_legend();
    chart:add_area_percent(firm_energy_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_percent(firm_energy_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_percent(firm_energy_renew:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_percent(firm_energy_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_percent(firm_energy_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_percent(firm_energy_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_percent(firm_energy_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_percent(firm_energy_bio:aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_area_percent(firm_energy_pch:aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return;
    end

    return chart;
end

local function chart_annual_marginal_cost(case)
    local cmgdem;
    if has_network[case] then
        cmgdem = bus[case]:load("opt2_cmgdem2");
    else
        cmgdem = system[case]:load("opt2_cmgdem2");
    end

    cmgdem = cmgdem:aggregate_agents(BY_AVERAGE(),Collection.SYSTEM)
                   :aggregate_blocks_by_average()
                   :aggregate_stages(BY_AVERAGE(),Profile.PER_YEAR)
                   :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_column(cmgdem, { color = colors.generic, showInLegend = false });

    if #chart <= 0 then
        return
    end

    return chart;
end

local function chart_monthly_marginal_cost(case)
    local cmgdem;
    if has_network[case] then
        cmgdem = bus[case]:load("opt2_cmgdem2");
    else
        cmgdem = system[case]:load("opt2_cmgdem2");
    end

    cmgdem = cmgdem:aggregate_agents(BY_AVERAGE(),Collection.SYSTEM)
                   :aggregate_blocks_by_average()
                   :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_line(cmgdem, { color = colors.generic, showInLegend = false });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_hourly_marginal_cost_per_typical_day(case)
    local cmgdem;
    if has_network[case] then
        cmgdem = bus[case]:load("opt2_cmgdem2");
    else
        cmgdem = system[case]:load("opt2_cmgdem2");
    end

    if cmgdem:loaded() then
        local cmgdem2 = cmgdem:aggregate_agents(BY_AVERAGE(),Collection.SYSTEM)
                            :aggregate_scenarios(BY_AVERAGE())
                            :aggregate_agents(BY_AVERAGE(),dictionary.omc[language]):remove_zeros():round(0);

        local chart = create_chart("", case);
        chart:enable_controls();
        chart:horizontal_legend();
        
        local stages = cmgdem2:stages();
        local stage_type = cmgdem2:stage_type();


        local count = 1;
        for stg = 1, stages do
            local monthly_marginal_cost = cmgdem2:select_stage(stg);
            local number_of_tdays = monthly_marginal_cost:blocks(stg)/24;

            local stage_type_name = dictionary.month[language];
            local week_month = cmgdem2:month(stg);
            if stage_type == 1 then
                stage_type_name = dictionary.week[language];
                week_month = cmgdem2:week(stg);
            end

            for day = 1, number_of_tdays do
                local initial_block = 1 + 24 * (day - 1);
                local final_block = 24 * day;
                chart:add_line(monthly_marginal_cost:select_blocks(initial_block, final_block)
                                    :force_hourly()
                                    :rename_agents(dictionary.typical_day[language] .. " " .. day)
                , { color = colors.generic[day], sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. cmgdem2:year(stg) });
            end
            count = count + 1;
        end
        if #chart <= 0 then
            return
        end
        return chart;
    end
    return;
end

local function chart_defict_risk(case)
    local defict;
    if has_network[case] then
        defict = bus[case]:load("opt2_deficitmw"):convert_MW_to_GWh();
    else
        defict = system[case]:load("opt2_deficitmw"):convert_MW_to_GWh();
    end
    defict = defict:aggregate_blocks()
                         :aggregate_stages(BY_SUM(), Profile.PER_YEAR);

    local stage_type;
    if defict:loaded() then
        stage_type = defict:stage_type();
    else
        stage_type = 1;
    end
    local dathisc = generic[case]:load("opt2_optgscen"):select_stage(1):set_stage_type(stage_type);

    if dathisc then
        defict = ifelse(defict:gt(0), dathisc, 0):aggregate_scenarios(BY_SUM()):convert("%"):round(0);
    else
        defict = ifelse(defict:gt(0), 1, 0):aggregate_scenarios(BY_AVERAGE()):convert("%"):round(0);
    end

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_line(defict, { color = colors.risk.deficit });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_total_generation(case) 
    local renewable_gen_ind = renewable[case]:load("opt2_gergndmw"):convert_MW_to_GWh();

    local thermal_gen   = generic[case]:load("opt2_gertermw"):convert_MW_to_GWh():aggregate_blocks():round(0);
    local hidro_gen     = hydro[case]:load("opt2_gerhidmw"):convert_MW_to_GWh():aggregate_blocks():round(0);
    local renewable_gen = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(0)):aggregate_blocks():round(0);
    local solar_gen     = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(2)):aggregate_blocks():round(0);
    local wind_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(1)):aggregate_blocks():round(0);
    local bio_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(3)):aggregate_blocks():round(0);
    local pch_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(4)):aggregate_blocks():round(0);
    local csp_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(5)):aggregate_blocks():round(0);
    local battery       = battery[case]:load("opt2_gerbatmw"):convert_MW_to_GWh():aggregate_blocks():round(0);
    local defict        = generic[case]:load("opt2_deficitmw"):convert_MW_to_GWh():aggregate_blocks():round(0);

    local stage_type;
    if defict:loaded() then
        stage_type = defict:stage_type();
    else
        stage_type = 1;
    end
    local dathisc = generic[case]:load("opt2_optgscen"):select_stage(1):set_stage_type(stage_type);
    if dathisc then
        thermal_gen   = (thermal_gen   * dathisc):aggregate_scenarios(BY_SUM());
        hidro_gen     = (hidro_gen     * dathisc):aggregate_scenarios(BY_SUM());
        renewable_gen = (renewable_gen * dathisc):aggregate_scenarios(BY_SUM());
        solar_gen     = (solar_gen     * dathisc):aggregate_scenarios(BY_SUM());
        wind_gen      = (wind_gen      * dathisc):aggregate_scenarios(BY_SUM());
        bio_gen       = (bio_gen       * dathisc):aggregate_scenarios(BY_SUM());
        pch_gen       = (pch_gen       * dathisc):aggregate_scenarios(BY_SUM());
        csp_gen       = (csp_gen       * dathisc):aggregate_scenarios(BY_SUM());
        battery       = (battery       * dathisc):aggregate_scenarios(BY_SUM());
        defict        = (defict        * dathisc):aggregate_scenarios(BY_SUM());
    else
        thermal_gen   = thermal_gen  :aggregate_scenarios(BY_AVERAGE());
        hidro_gen     = hidro_gen    :aggregate_scenarios(BY_AVERAGE());
        renewable_gen = renewable_gen:aggregate_scenarios(BY_AVERAGE());
        solar_gen     = solar_gen    :aggregate_scenarios(BY_AVERAGE());
        wind_gen      = wind_gen     :aggregate_scenarios(BY_AVERAGE());
        bio_gen       = bio_gen      :aggregate_scenarios(BY_AVERAGE());
        pch_gen       = pch_gen      :aggregate_scenarios(BY_AVERAGE());
        csp_gen       = csp_gen      :aggregate_scenarios(BY_AVERAGE());
        battery       = battery      :aggregate_scenarios(BY_AVERAGE());
        defict        = defict       :aggregate_scenarios(BY_AVERAGE());
    end

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_area_spline_stacking(thermal_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(hidro_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(renewable_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(solar_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(wind_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(csp_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(battery:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_spline_stacking(defict:remove_zeros():aggregate_agents(BY_SUM(), dictionary.deficit[language]), { color = colors.total_generation.defict });
    chart:add_area_spline_stacking(bio_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_bio[language]), { color = colors.total_generation.bio });
    chart:add_area_spline_stacking(pch_gen:remove_zeros():aggregate_agents(BY_SUM(), dictionary.total_pch[language]), { color = colors.total_generation.pch });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_hourly_generation_typical_day(case)
    local renewable_gen_ind = renewable[case]:load("opt2_gergndmw"):convert_MW_to_GWh();

    local thermal_gen   = thermal[case]:load("opt2_gertermw"):convert_MW_to_GWh()
                                 :aggregate_agents(BY_SUM(),dictionary.total_thermal[language]);
    local hydro_gen     = hydro[case]:load("opt2_gerhidmw"):convert_MW_to_GWh()
                                 :aggregate_agents(BY_SUM(),dictionary.total_hydro[language]);
    local renewable_gen = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(0) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_renewable[language]);
    local solar_gen     = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(2) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_solar[language]);
    local wind_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(1) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_wind[language]);
    local bio_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(3) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_bio[language]);
    local pch_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(4) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_pch[language]);
    local csp_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(5) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_csp[language]);
    local battery       = battery[case]:load("opt2_gerbatmw"):convert_MW_to_GWh()
                                 :aggregate_agents(BY_SUM(),dictionary.total_battery[language]);
    local defict        = generic[case]:load("opt2_deficitmw"):convert_MW_to_GWh()
                                 :aggregate_agents(BY_SUM(),dictionary.deficit[language]);
                                 
    local stage_type;
    if defict:loaded() then
        stage_type = defict:stage_type();
    else
        stage_type = 1;
    end
    local dathisc = generic[case]:load("opt2_optgscen"):select_stage(1):set_stage_type(stage_type);
    if dathisc then
        thermal_gen   = (thermal_gen   * dathisc):aggregate_scenarios(BY_SUM());
        hydro_gen     = (hydro_gen     * dathisc):aggregate_scenarios(BY_SUM());
        renewable_gen = (renewable_gen * dathisc):aggregate_scenarios(BY_SUM());
        solar_gen     = (solar_gen     * dathisc):aggregate_scenarios(BY_SUM());
        wind_gen      = (wind_gen      * dathisc):aggregate_scenarios(BY_SUM());
        csp_gen       = (csp_gen       * dathisc):aggregate_scenarios(BY_SUM());
        battery       = (battery       * dathisc):aggregate_scenarios(BY_SUM());
        defict        = (defict        * dathisc):aggregate_scenarios(BY_SUM());
        bio_gen       = (bio_gen       * dathisc):aggregate_scenarios(BY_SUM());
        pch_gen       = (pch_gen       * dathisc):aggregate_scenarios(BY_SUM());
    else
        thermal_gen   = thermal_gen  :aggregate_scenarios(BY_AVERAGE());
        hydro_gen     = hydro_gen    :aggregate_scenarios(BY_AVERAGE());
        renewable_gen = renewable_gen:aggregate_scenarios(BY_AVERAGE());
        solar_gen     = solar_gen    :aggregate_scenarios(BY_AVERAGE());
        wind_gen      = wind_gen     :aggregate_scenarios(BY_AVERAGE());
        csp_gen       = csp_gen      :aggregate_scenarios(BY_AVERAGE());
        battery       = battery      :aggregate_scenarios(BY_AVERAGE());
        defict        = defict       :aggregate_scenarios(BY_AVERAGE());
        bio_gen       = bio_gen      :aggregate_scenarios(BY_AVERAGE());
        pch_gen       = pch_gen      :aggregate_scenarios(BY_AVERAGE());
    end

    local stages = defict:stages();
    local vector_of_chart = {};
    local count = 1;
    for stg = 1, stages do
        local thermal_gen_stg   = thermal_gen:select_stage(stg);
        local hydro_gen_stg     = hydro_gen:select_stage(stg);
        local renewable_gen_stg = renewable_gen:select_stage(stg);
        local solar_gen_stg     = solar_gen:select_stage(stg);
        local wind_gen_stg      = wind_gen:select_stage(stg);
        local csp_gen_stg       = csp_gen:select_stage(stg);
        local battery_stg       = battery:select_stage(stg);
        local defict_stg        = defict:select_stage(stg);
        local bio_gen_stg       = bio_gen:select_stage(stg);
        local pch_gen_stg       = pch_gen:select_stage(stg);

        local number_of_tdays = defict_stg:blocks(stg)/24;

        local stage_type = defict_stg:stage_type();
        local stage_type_name = dictionary.month[language];
        local week_month = defict_stg:month(stg);
        if stage_type == 1 then
            stage_type_name = dictionary.week[language];
            week_month = defict_stg:week(stg);
        end

        for day = 1, number_of_tdays do
            if not vector_of_chart[day] then
                vector_of_chart[day] = create_chart(dictionary.typical_day[language] .. " " .. day, case);
                vector_of_chart[day]:enable_controls();
                vector_of_chart[day]:horizontal_legend();
            end
            local initial_block = 1 + 24 * (day - 1);
            local final_block = 24 * day;
            vector_of_chart[day]:add_area_spline_stacking(thermal_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.thermal, sequence = count, sequence_label = stage_type_name .. ":" .. week_month .. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(hydro_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.hydro, sequence = count, sequence_label = stage_type_name .. ":" .. week_month .. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(renewable_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.renewable, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(solar_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.solar, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(wind_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.wind, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(csp_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.csp, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(battery_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.battery, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(defict_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.defict, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(bio_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.bio, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
            vector_of_chart[day]:add_area_spline_stacking(pch_gen_stg:select_blocks(initial_block, final_block)
                                  :force_hourly(), { color = colors.total_generation.pch, sequence = count, sequence_label = stage_type_name .. ":" .. week_month.. " - " .. dictionary.year[language] .. ":" .. defict_stg:year(stg) });
        end
        count = count + 1;
    end

    return vector_of_chart;
end

local function chart_objective_value(case)

    local interest = (1 + study[case].discount_rate) ^ ((study[case].stage_in_year - 1) / study[case]:stages_per_year());
    local dathisc = generic[case]:load("opt2_optgscen"):select_stage(1);
    local opt2_optgcoped = (generic[case]:load("opt2_optgcope"):remove_agents({1}):remove_zeros() * dathisc):aggregate_stages(BY_SUM());

    local chart = create_chart("", case);
    chart:horizontal_legend();
    chart:add_pie(opt2_optgcoped:aggregate_scenarios(BY_AVERAGE()), { color = colors.generic });

    if #chart <= 0 then
        return 
    end

    return chart;
end

function is_monotonous_downward(x_coords, y_coords)
    local indices = {}
    for i = 1, #x_coords do
        table.insert(indices, i)
    end
    table.sort(indices, function(a, b) return x_coords[a] < x_coords[b] end)
    local result = {}
    for i = 1, #x_coords do
        result[i] = false
    end
    local prev_y = y_coords[indices[1]]
    result[indices[1]] = true
    for i = 2, #indices do
        local current_y = y_coords[indices[i]]
        if current_y < prev_y then
            result[indices[i]] = true
            prev_y = current_y
        else
            prev_y = math.min(prev_y, current_y)
        end
    end

    return result
end

local function chart_risk_curve(case)
    local charts = {};

    local inp_table = generic[case]:load_table("outrisk.csv");

    if #inp_table > 0 then
        local Avg = {};
        local year = {};
        local cvar_norm = {};
        local initial_year = study[case]:initial_year();
        for i = 1, #inp_table do
            table.insert(year, inp_table[i]["!year"]);
            table.insert(Avg, tonumber(inp_table[i]["Avg"]));
            table.insert(cvar_norm, (tonumber(inp_table[i]["CVaR"]) - tonumber(inp_table[i]["Avg"])) / tonumber(inp_table[i]["Avg"]));
        end

        local data_y_aux  = {};
        local data_x_aux  = {};
        local hor_count = 1;
        for i, hor in ipairs(year) do
            table.insert(data_y_aux, Avg[i]);
            table.insert(data_x_aux, cvar_norm[i]);
            if i == #year or year[i+1] ~= hor then
                local risk_size = #data_x_aux;
                local is_monot = is_monotonous_downward(data_x_aux, data_y_aux);
                local chart_point_count = 1;
                local position_in_chart = {};
                for j = 1, risk_size do
                    table.insert(position_in_chart, 0);
                end
                local data_y_aux_monot = {};
                local data_x_aux_monot = {};
                for j = 1, risk_size do
                    if is_monot[j] then
                        table.insert(data_y_aux_monot, data_y_aux[j]);
                        table.insert(data_x_aux_monot, data_x_aux[j]);
                        position_in_chart[j] = chart_point_count;
                        chart_point_count = chart_point_count + 1;
                    end
                end
                local data_y_aux_non_monot = {};
                local data_x_aux_non_monot = {};
                for j = 1, risk_size do
                    if not is_monot[j] then
                        table.insert(data_y_aux_non_monot, data_y_aux[j]);
                        table.insert(data_x_aux_non_monot, data_x_aux[j]);
                        position_in_chart[j] = chart_point_count;
                        chart_point_count = chart_point_count + 1;
                    end
                end
                local chart = create_chart(hor, case);
                local graf_y_conv = generic[case]:create(dictionary.risk_expected[language], dictionary.risk_expected[language] .. " (K$)", data_y_aux_monot);
                local graf_x_conv = generic[case]:create(dictionary.risk_var[language], dictionary.risk_var[language], data_x_aux_monot);
                chart:add_scatter(graf_x_conv, graf_y_conv, tostring(hor), { lineWidth = 1, color = colors.generic, type = "spline", marker = { enabled = true}});
                if #data_x_aux_non_monot > 0 then
                    local graf_y_non_conv = generic[case]:create(dictionary.risk_expected[language], dictionary.risk_expected[language] .. " (K$)", data_y_aux_non_monot);
                    local graf_x_non_conv = generic[case]:create(dictionary.risk_var[language], dictionary.risk_var[language], data_x_aux_non_monot);
                    chart:add_scatter(graf_x_non_conv, graf_y_non_conv, tostring(hor), { lineWidth = 0, color = colors.generic});
                end
                for risk_count = 1, risk_size do
                    local tooltip = Tooltip();
                    local dec_table;
                    if not is_opt2 then
                        if risk_count == 1 then
                            dec_table = generic[case]:load_table_without_header(string.format("outpdect%02d.csv", hor_count));
                        else
                            dec_table = generic[case]:load_table_without_header(string.format("outpdec_i%02dt%02d.csv", risk_count - 1, hor_count));
                        end
                    else
                        dec_table = generic[case]:load_table_without_header(string.format("outpdec_y%d_i%d.csv", initial_year + hor_count - 1, risk_count));
                    end
                    if #dec_table > 0 then
                        local thermal_cap = 0;
                        local hydro_cap = 0;
                        local gnd_cap = 0;
                        local battery_cap = 0;
                        local csp_cap = 0;
                        for j = 5, #dec_table do
                            local dec_cap = tonumber(dec_table[j][8]);
                            local dec_typ = tonumber(dec_table[j][7]);
                            if dec_typ == 0 then
                                thermal_cap = thermal_cap + dec_cap;
                            elseif dec_typ == 1 then
                                hydro_cap = hydro_cap + dec_cap;
                            elseif dec_typ == 6 then
                                gnd_cap = gnd_cap + dec_cap;
                            elseif dec_typ == 8 then
                                battery_cap = battery_cap + dec_cap;
                            elseif dec_typ == 22 then
                                csp_cap = csp_cap + dec_cap;
                            end
                        end
                        local thermal_cap_aux = generic[case]:create(dictionary.total_thermal[language], "MW", {thermal_cap});
                        local hydro_cap_aux = generic[case]:create(dictionary.total_hydro[language], "MW", {hydro_cap});
                        local gnd_cap_aux = generic[case]:create(dictionary.total_renewable[language], "MW", {gnd_cap});
                        local battery_cap_aux = generic[case]:create(dictionary.total_battery[language], "MW", {battery_cap});
                        local csp_cap_aux = generic[case]:create(dictionary.total_csp[language], "MW", {csp_cap});
                        local total_cap = concatenate(thermal_cap_aux, hydro_cap_aux, gnd_cap_aux, battery_cap_aux, csp_cap_aux):remove_zeros();
                        tooltip:add_pie(total_cap, { color = colors.generic, width = 400, height = 300 });
                        if is_monot[risk_count] then
                            chart:set_tooltip(1, position_in_chart[risk_count], tooltip);
                        else
                            chart:set_tooltip(2, position_in_chart[risk_count] - #data_y_aux_monot, tooltip);
                        end
                    end
                end
                table.insert(charts, chart);
                data_x_aux = {};
                data_y_aux = {};
                hor_count = hor_count + 1;
            end
        end
    end

    if #charts <= 0 then
        risk_results = false;
    end

    return charts;
end

local function chart_convergence(case)
    local chart = create_chart("", case);

    local gap = generic[case]:load("opt2_optgconv"):select_agent("Gap"):rename_agents({dictionary.GAP[language]})

    chart:add_line(gap, {showInLegend = false});

    if #chart <= 0 then
        return 
    end

    return chart;
end

--=================================================--
-- Create Tabs Functions
--=================================================--
local function tab_investment_report()
    local tab<const> = create_tab(dictionary.investment_report[language], "arrow-right");     

    if plot.accumulated_capacity then
        for case = 1, cases do
            local chart = chart_accumulated_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.accumulated_capacity[language]);
                end
                tab:push(chart);
            end
        end
    end

    if plot.total_installed_capacity then
        for case = 1, cases do
            if study[case]:get_parameter("SKPS",-1) == 0 then
                local chart = chart_total_installed_capacity(case);
                if chart then
                    if case == 1 then
                        tab:push("## " .. dictionary.total_installed_capacity[language]);
                    end
                    tab:push(chart);
                end
            end
        end
    end

    if plot.circuit_accumulated_capacity then
        for case = 1, cases do
            local chart = chart_circuit_accumulated_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.circuit_accumulated_capacity[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.total_cost then
        for case = 1, cases do
            local chart = chart_total_cost(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.total_costs[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.annualized_investment_cost then
        for case = 1, cases do
            local chart = chart_annualized_investment_cost(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.annualized_investment_cost[language]);
                end
               tab:push(chart);
            end
        end
    end


    if plot.total_installed_capacity_mix then
        for case = 1, cases do
            if study[case]:get_parameter("SKPS",-1) == 0 then
                local chart = chart_total_installed_capacity_mix(case);
                if chart then
                    if case == 1 then
                        tab:push("## " .. dictionary.total_installed_capacity_mix[language]);
                    end
                    tab:push(chart);
                end
            end
        end
    end

    if plot.firm_capacity then
        for case = 1, cases do
            local chart = chart_firm_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.firm_capacity[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.firm_capacity_mix then
        for case = 1, cases do
            local chart = chart_firm_capacity_mix(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.firm_capacity_mix[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.firm_energy then
        for case = 1, cases do
            local chart = chart_firm_energy(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.firm_energy[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.firm_energy_mix then
        for case = 1, cases do
            local chart = chart_firm_energy_mix(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.firm_energy_mix[language]);
                end
               tab:push(chart);
            end
        end
    end

    return tab;
end

local function tab_marginal_cost(tab)

    if plot.annual_marginal_cost then
        for case = 1, cases do
            local chart = chart_annual_marginal_cost(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.annual_marginal_cost[language]);
                end
               tab:push(chart);
            end
        end
    end

      if plot.monthly_marginal_cost then
        for case = 1, cases do
            local chart = chart_monthly_marginal_cost(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.monthly_marginal_cost[language]);
                end
                tab:push(chart);
            end
        end
    end

    if plot.hourly_marginal_cost_typical then
        for case = 1, cases do
            local chart = chart_hourly_marginal_cost_per_typical_day(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.hourly_marginal_cost_typical[language]);
                end
               tab:push(chart);
            end
        end
    end

end

local function tab_optgen2_reports()
    local tab<const> = create_tab(dictionary.optgen_2_reports[language], "arrow-right");

    if plot.deficit_risk then
        for case = 1, cases do
            local chart = chart_defict_risk(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.deficit_risk[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.generation_in_each_season then
        for case = 1, cases do
            local chart = chart_total_generation(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.total_generation[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.hourly_generation_typical then
        for case = 1, cases do
            local chart = chart_hourly_generation_typical_day(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.generation_per_typical_day[language]);
                end
                for _, c in ipairs(chart) do
                    tab:push(c);
                end
            end
        end
    end

    if plot.objective_function then
        for case = 1, cases do
            local chart = chart_objective_value(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.objective_functions[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.convergence then
        for case = 1, cases do
            local chart = chart_convergence(case);
            if chart then
                if case == 1 then
                    tab:push("## " .. dictionary.gap_convergence[language]);
                end
               tab:push(chart);
            end
        end
    end

    tab_marginal_cost(tab);

    return tab;
end

local function tab_risk_result()
    local tab<const> = create_tab(dictionary.optgen_risk[language], "arrow-right");

    if plot.risk_curve then
        for case = 1, cases do
            local charts = chart_risk_curve(case);
            if #charts > 0 then
                if case == 1 then
                    tab:push("## " .. dictionary.optgen_risk[language]);
                end
                for _, chart in ipairs(charts) do
                    tab:push(chart);
                end
            end

        end
    end

    return tab;
end

local function tab_expansion_result()
    local tab<const> = create_tab(dictionary.expansion_results[language], "bar-chart-3");
    tab:set_disabled();

    tab:push(tab_investment_report());
    
    if is_opt2 then
        tab:push(tab_optgen2_reports());
    end

    local risk_tab = tab_risk_result();
    if risk_results then
        tab:push(risk_tab);
    end

    return tab;
end

local function tab_sddp()
    local tab<const> = create_tab(dictionary.sddp[language], "bar-chart-3");
    tab:set_disabled();

    local generic_collections = {};
    local info_struct = {};

    for i = 1, cases do
        if not Study(i):file_exists("SDDP.info") then
            return
        end
        generic_collections[i] = Generic(i);
    end

    local info_existence_log = load_model_info(generic_collections, info_struct);
    create_operation_report(tab, cases, info_struct, info_existence_log, false);

    return tab
end

--=================================================--
-- Create Dashboard
--=================================================--
local dashboard<const> = DashboardVue();
dashboard:push(tab_expansion_result());

local sddp_tab = tab_sddp();
if sddp_tab then
    dashboard:push(sddp_tab);
end

dashboard:save("OptGen");
