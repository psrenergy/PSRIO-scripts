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
        defict = "#000000"
    },
    total_circuit = {
        ac = "#e3554b",
        dc = "#9a4be3",
    },
    total_costs = {
        operational = "#8CD17D",
        invetiment  = "#F1CE63",
        thermal = "#F28E2B",
        hydro = "#4E79A7",
        renewable = "#8a8881",
        solar = "#F1CE63",
        wind = "#8CD17D",
        csp = "#b0ada4",
        battery = "#FF9DA7",
        ac = "#e3554b",
        dc ="#9a4be3"
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
        pt = "Reporte de investimentos"
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
        en = "Accumulated capacity",
        es = "Capacidad acumulada",
        pt = "Capacidade acumulada"
    },
    circuit_accumulated_capacity = {
        en = "Circuit accumulated capacity",
        es = "Capacidad acumulada de circuitos",
        pt = "Capacidade acumulada de circuitos"
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
        en = "Total thermal",
        es = "Total térmica",
        pt = "Total térmica"
    },
    total_hydro = {
        en = "Total hydro",
        es = "Total hidro",
        pt = "Total hidro"
    },
    total_renewable = {
        en = "Total others renewable",
        es = "Total otras renovable",
        pt = "Total outra renovável"
    },
    total_solar = {
        en = "Total solar",
        es = "Total solar",
        pt = "Total solar"
    },
    total_wind = {
        en = "Total wind",
        es = "Total eólica",
        pt = "Total eólica"
    },
    total_csp = {
        en = "Total CSP",
        es = "Total CSP",
        pt = "Total CSP"
    },
    total_battery = {
        en = "Total battery",
        es = "Total batería",
        pt = "Total bateria"
    },
    total_injection = {
        en = "Total injection",
        es = "Total inyección",
        pt = "Total injeção"
    },
    total_ac_circuit = {
        en = "Total circuit AC",
        es = "Total circuito AC",
        pt = "Total circuito AC"
    },
    total_dc_circuit = {
        en = "Total circuit DC",
        es = "Total circuito DC",
        pt = "Total circuito DC"
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
        en = "Hourly marginal cost per yypical day",
        es = "Costo marginal horario por día típico",
        pt = "Custo marginal horário por dia típico"
    },
    omc = {
        en = "OMC",
        es = "CMO",
        pt = "CMO"
    },
    deficit_risk = {
        en = "Deficit risk",
        es = "Riesgo de déficit",
        pt = "Risco de deficit"
    },
    generation_in_season = {
        en = "Generation in each season of the year",
        es = "Generación en cada estación del año",
        pt = "Geração em cada estação do ano"
    },
    generation_per_typical_day = {
        en = "Hourly generation per typical day",
        es = "Generación horaria por día típico",
        pt = "Geração horária por dia típico"
    },
    season = {
        en = "Seson",
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
    }
};

--=================================================--
-- Dictionaries of Charts plots
--=================================================--
local plot<const> = {
    accumulated_capacity         = true,
    circuit_accumulated_capacity = true,
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
           study[case]:get_parameter("DecisionType", -1) == 1) then
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
local function by_day(data) -- vai deixar de existir
    if data:loaded() then
        local block_base = 24;

        local blocks = data:blocks(1);

        local n_typ_day = blocks / block_base;

        local day_data = {};
        for day = 1, n_typ_day do
            local data_aux = {};

            for blc = 1 + block_base * (day - 1), block_base * day do
                local stg_data = data:select_block(blc);
                table.insert(data_aux, stg_data);
            end

            table.insert(day_data,
                concatenate_blocks(data_aux)
                    :set_stage_type(10)
                    :force_hourly()
                    :add_suffix(" - (Typical Day " .. day .. ")")
            );
        end

        return n_typ_day, day_data;
    end

    return nil, { data, data, data, data, data,
                  data, data, data, data, data,
                  data, data, data, data, data,
                  data, data, data, data, data,
                  data, data, data, data, data,
                  data, data, data, data, data,
                  data, data, data, data, data
                }
end

local function opt2_format_to_chart_scatterplot(year_vec, data_vec, col_name_vec, chart, unit, case) -- vai deixar de existir
    if #col_name_vec ~= #data_vec then
        warn("Vector Column name and Vector Data has not the same size in opt2_format function");
        return nil;
    end

    for i, data in ipairs(data_vec) do
        if #data ~= #year_vec then
            local number = tostring(i);
            warn("Data " .. number .. " has not the same size of year vec in opt2_format function");
            return nil;
        end
    end

    local initial_year = year_vec[1];
    local final_year  = year_vec[#year_vec]
    local data_x_aux  = {};
    local data_y_aux  = {};
    for year = initial_year, final_year do
        for i, data_year in ipairs(year_vec) do
            if tonumber(year) == tonumber(data_year) then
                table.insert(data_x_aux, tonumber(data_vec[1][i]));
                table.insert(data_y_aux, tonumber(data_vec[2][i]));
            end
        end
        local graf_x = generic[case]:create(col_name_vec[1], col_name_vec[1] .. "(" .. unit .. ")", data_x_aux);
        local graf_y = generic[case]:create(col_name_vec[2], col_name_vec[2] .. "(" .. unit .. ")", data_y_aux);
        chart:add_scatter(graf_x, graf_y, tostring(year), { lineWidth = 1, color = colors.generic });

        data_x_aux = {};
        data_y_aux = {};
    end
end

--=================================================--
-- Create Base Functions
--=================================================--
local function create_tab(label, icon)
    local tab<const> = Tab(label);
    tab:set_icon(icon);
    tab:push("# " .. label);
    return tab;
end

local function create_chart(label, case)
    if cases == 1 then
        return Chart(label);
    else
        return Chart(label .. " (case " .. case .. ")");
    end
end

--=================================================--
-- Create Charts Functions
--=================================================--
local function chart_accumulated_capacity(case)
    local outidec = expansionproject[case]:load("outidec");

    local thermal_cap   = outidec:select_agents(Collection.THERMAL)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local hydro_cap     = outidec:select_agents(Collection.HYDRO)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local renewable_cap = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:ne(1 | 2 | 5))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local solar_cap     = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(2))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local wind_cap      = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(1))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local csp_cap       = outidec:select_agents(Collection.RENEWABLE):select_agents(renewable[case].tech_type:eq(5))
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);
    local battery_cap   = outidec:select_agents(Collection.BATTERY)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR):remove_zeros():round(0);


    local chart = create_chart("", case);
    chart:add_column_stacking(thermal_cap:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_column_stacking(hydro_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_column_stacking(renewable_cap:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_column_stacking(solar_cap:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_column_stacking(wind_cap:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_column_stacking(csp_cap:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_column_stacking(battery_cap:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_circuit_accumulated_capacity(case)
    local outidec = expansionproject[case]:load("outidec");

    local ac_cap   = outidec:select_agents(Collection.CIRCUIT)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR);
    local dc_cap   = outidec:select_agents(Collection.DCLINK)
                                :aggregate_stages(BY_LAST_VALUE(),Profile.PER_YEAR);

    local chart = create_chart("", case);
    chart:add_column_stacking(ac_cap:aggregate_agents(BY_SUM(), dictionary.total_ac_circuit[language]):remove_zeros():round(0), { color = colors.total_circuit.ac });
    chart:add_column_stacking(dc_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]):remove_zeros():round(0), { color = colors.total_circuit.dc });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_total_cost(case)
    local objcop   = generic[case]:load("objcop"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE());
    local outdfact = generic[case]:load("outdfact");
    local outdisbu = expansionproject[case]:load("outdisbu"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()) * outdfact;

    local costs;
    if study[case]:is_hourly() then
        costs = (objcop:remove_agents({1}) * outdfact):aggregate_stages(BY_SUM()); -- remove future cost
    else
        costs = (objcop:remove_agents({1}):remove_agents({-1}) * outdfact):aggregate_stages(BY_SUM()); -- remove total cost -- remove future cost
    end

    local inv_total = outdisbu:aggregate_stages(BY_SUM()):remove_zeros():round(0);
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
                              :select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                              :aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_ac    = outdisbu:select_agents(Collection.CIRCUIT):aggregate_stages(BY_SUM()):remove_zeros():round(0);
    local inv_dc    = outdisbu:select_agents(Collection.DCLINK ):aggregate_stages(BY_SUM()):remove_zeros():round(0);

    local chart_a = create_chart("", case);
    chart_a:add_pie(costs:aggregate_agents(BY_SUM(), dictionary.total_operational_costs[language]), { color = colors.total_costs.operational });
    chart_a:add_pie(inv_total:aggregate_agents(BY_SUM(), dictionary.total_investment_cost[language]), { color = colors.total_costs.invetiment });

    local chart_b = create_chart("", case);
    chart_b:add_pie(inv_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_costs.thermal });
    chart_b:add_pie(inv_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_costs.hydro });
    chart_b:add_pie(inv_other:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_costs.renewable });
    chart_b:add_pie(inv_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_costs.solar });
    chart_b:add_pie(inv_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_costs.wind });
    chart_b:add_pie(inv_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_costs.csp });
    chart_b:add_pie(inv_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_costs.battery });
    chart_b:add_pie(inv_ac:aggregate_agents(BY_SUM(), dictionary.total_ac_circuit[language]), { color = colors.total_costs.ac });
    chart_b:add_pie(inv_dc:aggregate_agents(BY_SUM(), dictionary.total_dc_circuit[language]), { color = colors.total_costs.dc });

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
    local renewable_cap = renewable_cap_ind:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local solar_cap     = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(2) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local wind_cap      = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(1) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local csp_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bat_cap       = batte_cap:aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:add_area_spline_stacking(thermal_cap:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(hydro_cap:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(renewable_cap:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(solar_cap:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(wind_cap:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(csp_cap:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(bat_cap:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_total_installed_capacity_mix(case)
    local renewable_cap_ind = renewable[case]:load("pnomnd"):aggregate_stages(BY_MAX());

    local thermal_cap   = thermal[case]:load("pnomtr"):aggregate_stages(BY_MAX()):remove_zeros():round(0);
    local hydro_cap     = hydro[case]:load("pnomhd"):aggregate_stages(BY_MAX()):remove_zeros():round(0);
    local batte_cap     = battery[case]:load("pnombat"):aggregate_stages(BY_MAX()):remove_zeros():round(0);
    local renewable_cap = renewable_cap_ind:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local solar_cap     = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(2) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local wind_cap      = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(1) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local csp_cap       = renewable_cap_ind:select_agents(renewable[case].tech_type:eq(5) )
                                           :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);
    local bat_cap       = batte_cap:aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local vector_of_charts = {};
    local initial_year = study[case]:initial_year();
    local final_year   = study[case]:final_year();
    -- for year = initial_year,final_year do
    for _, year in ipairs({ initial_year, final_year }) do
        local chart = create_chart("Year - "..year, case);
        local thermal_cap_annual   = thermal_cap:select_stages_by_year(year);
        local hydro_cap_annual     = hydro_cap:select_stages_by_year(year);
        local solar_cap_annual     = solar_cap:select_stages_by_year(year);
        local wind_cap_annual      = wind_cap:select_stages_by_year(year);
        local csp_cap_annual       = csp_cap:select_stages_by_year(year);
        local renewable_cap_annual = renewable_cap:select_stages_by_year(year);
        local bat_cap_annual       = bat_cap:select_stages_by_year(year);

        chart:add_pie(thermal_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
        chart:add_pie(hydro_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
        chart:add_pie(renewable_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
        chart:add_pie(solar_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
        chart:add_pie(wind_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
        chart:add_pie(csp_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
        chart:add_pie(bat_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

        if #chart <= 0 then
            return 
        end

        table.insert(vector_of_charts, chart);
    end
    return vector_of_charts;
end

local function chart_firm_capacity(case)
    local firm_capacity_renew = renewable[case]:load("outrpa"):remove_zeros():round(0);
    local firm_capacity_hydro = hydro[case]:load("outhpa"):remove_zeros():round(0);
    local firm_capacity_therm = thermal[case]:load("outtpa"):remove_zeros():round(0);
    local firm_capacity_batte = battery[case]:load("outbpa"):remove_zeros():round(0);
    local firm_capacity_renew = firm_capacity_renew:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_capacity_solar = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_capacity_wind  = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_capacity_csp   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);
    
    local chart = create_chart("", case);
    chart:add_area_spline_stacking(firm_capacity_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(firm_capacity_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(firm_capacity_renew:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(firm_capacity_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(firm_capacity_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(firm_capacity_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(firm_capacity_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_firm_capacity_mix(case)
    local firm_capacity_renew = renewable[case]:load("outrpa"):remove_zeros():round(0);
    local firm_capacity_hydro = hydro[case]:load("outhpa"):remove_zeros():round(0);
    local firm_capacity_therm = thermal[case]:load("outtpa"):remove_zeros():round(0);
    local firm_capacity_batte = battery[case]:load("outbpa"):remove_zeros():round(0);
    local firm_capacity_solar = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_capacity_wind  = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_capacity_csp   = firm_capacity_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_capacity_renew = firm_capacity_renew:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                                   :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local vector_of_charts = {};
    local initial_year = study[case]:initial_year();
    local final_year   = firm_capacity_therm:final_year();

    -- for year = initial_year,final_year do
    for _, year in ipairs({ initial_year, final_year }) do
        local chart = create_chart("Year - "..year, case);
        local thermal_cap_annual   = firm_capacity_therm:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local hydro_cap_annual     = firm_capacity_hydro:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local solar_cap_annual     = firm_capacity_solar:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local wind_cap_annual      = firm_capacity_wind:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local csp_cap_annual       = firm_capacity_csp:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local renewable_cap_annual = firm_capacity_renew:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local bat_cap_annual       = firm_capacity_batte:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);

        chart:add_pie(thermal_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
        chart:add_pie(hydro_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
        chart:add_pie(renewable_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
        chart:add_pie(solar_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
        chart:add_pie(wind_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
        chart:add_pie(csp_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
        chart:add_pie(bat_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

        if #chart <= 0 then
            return 
        end

        table.insert(vector_of_charts, chart);
    end

    return vector_of_charts;
end

local function chart_firm_energy(case)
    local firm_energy_renew = renewable[case]:load("outrea"):remove_zeros():round(0);
    local firm_energy_hydro = hydro[case]:load("outhea"):remove_zeros():round(0);
    local firm_energy_therm = thermal[case]:load("outtea"):remove_zeros():round(0);
    local firm_energy_batte = battery[case]:load("outbea"):remove_zeros():round(0);
    local firm_energy_solar   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(2) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_energy_wind    = firm_energy_renew:select_agents(renewable[case].tech_type:eq(1) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_energy_csp     = firm_energy_renew:select_agents(renewable[case].tech_type:eq(5) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_energy_renew   = firm_energy_renew:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                                 :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:add_area_spline_stacking(firm_energy_therm:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(firm_energy_hydro:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(firm_energy_renew:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(firm_energy_solar:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(firm_energy_wind:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(firm_energy_csp:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(firm_energy_batte:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_firm_energy_mix(case)
    local firm_energy_renew = renewable[case]:load("outrea"):remove_zeros():round(0);
    local firm_energy_hydro = hydro[case]:load("outhea"):remove_zeros():round(0);
    local firm_energy_therm = thermal[case]:load("outtea"):remove_zeros():round(0);
    local firm_energy_batte = battery[case]:load("outbea"):remove_zeros():round(0);
    local firm_energy_solar = firm_energy_renew:select_agents(renewable[case].tech_type:eq(2) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_solar[language]):remove_zeros():round(0);
    local firm_energy_wind  = firm_energy_renew:select_agents(renewable[case].tech_type:eq(1) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_wind[language]):remove_zeros():round(0);
    local firm_energy_csp   = firm_energy_renew:select_agents(renewable[case].tech_type:eq(5) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_csp[language]):remove_zeros():round(0);
    local firm_energy_renew = firm_energy_renew:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                               :aggregate_agents(BY_SUM(), dictionary.total_renewable[language]):remove_zeros():round(0);

    local vector_of_charts = {};
    local initial_year = study[case]:initial_year();
    local final_year   = firm_energy_therm:final_year();

    -- for year = initial_year,final_year do
    for _, year in ipairs({ initial_year, final_year }) do

        local chart = create_chart("Year - "..year, case);
        local thermal_cap_annual   = firm_energy_therm:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local hydro_cap_annual     = firm_energy_hydro:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local solar_cap_annual     = firm_energy_solar:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local wind_cap_annual      = firm_energy_wind:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local csp_cap_annual       = firm_energy_csp:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local renewable_cap_annual = firm_energy_renew:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);
        local bat_cap_annual       = firm_energy_batte:aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stages_by_year(year);

        chart:add_pie(thermal_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
        chart:add_pie(hydro_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
        chart:add_pie(renewable_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
        chart:add_pie(solar_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
        chart:add_pie(wind_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
        chart:add_pie(csp_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
        chart:add_pie(bat_cap_annual:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });

        if #chart <= 0 then
            return 
        end

        table.insert(vector_of_charts, chart);
    end

    return vector_of_charts;
end

local function chart_annual_marginal_cost(case)
    local cmgdem;
    if has_network[case] then
        cmgdem = bus[case]:load("opt2_cmgdem2");
    else
        cmgdem = system[case]:load("opt2_cmgdem2");
    end

    cmgdem = cmgdem:aggregate_agents(BY_AVERAGE(),Collection.SYSTEM)
                   :aggregate_blocks(BY_AVERAGE())
                   :aggregate_stages(BY_AVERAGE(),Profile.PER_YEAR)
                   :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:add_column(cmgdem, { color = colors.generic });

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
                   :aggregate_blocks(BY_AVERAGE())
                   :aggregate_scenarios(BY_AVERAGE()):remove_zeros():round(0);

    local chart = create_chart("", case);
    chart:add_line(cmgdem, { color = colors.generic });

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

    local cmgdem2 = cmgdem:aggregate_agents(BY_AVERAGE(),Collection.SYSTEM)
                          :aggregate_scenarios(BY_AVERAGE())
                          :aggregate_agents(BY_AVERAGE(),dictionary.omc[language]):remove_zeros():round(0);

    local vector_of_charts = {};
    local _, day_data = by_day(cmgdem2);
    day_data = concatenate(day_data); -- mudar
    local stages = day_data:stages();

    for month = 1, 1 do
        local year = study[case]:initial_year() + day_data:select_stage(month):aggregate_stages(BY_SUM(), Profile.PER_YEAR):first_stage() - 1;
        local chart = create_chart(dictionary.season[language] .. " - " .. month .. " | " .. dictionary.year[language] .. " - " .. year, case);
        chart:add_line(day_data:select_stage(month), { color = colors.generic });
        table.insert(vector_of_charts, chart);

        if #chart <= 0 then
            return 
        end
    end

    return vector_of_charts;
end

local function chart_defict_risk(case)
    local defict;
    if has_network[case] then
        defict = bus[case]:load("opt2_deficitmw");
    else
        defict = system[case]:load("opt2_deficitmw");
    end
    defict = defict:aggregate_blocks(BY_AVERAGE())
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
    chart:add_line(defict, { color = colors.risk.deficit });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_generation_in_season(case) 
    local renewable_gen_ind = renewable[case]:load("opt2_gergndmw"):aggregate_blocks(BY_AVERAGE())

    local thermal_gen   = generic[case]:load("opt2_gertermw"):aggregate_blocks(BY_AVERAGE()) -- problemas
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local hidro_gen     = hydro[case]:load("opt2_gerhidmw"):aggregate_blocks(BY_AVERAGE())
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local renewable_gen = renewable_gen_ind:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local solar_gen     = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(2))
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local wind_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(1))
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local csp_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(5))
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local battery       = battery[case]:load("opt2_gerbatmw"):aggregate_blocks(BY_AVERAGE())
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);
    local defict        = generic[case]:load("opt2_deficitmw"):aggregate_blocks(BY_AVERAGE())
                                :aggregate_blocks(BY_SUM()):remove_zeros():round(0);

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
        csp_gen       = (csp_gen       * dathisc):aggregate_scenarios(BY_SUM());
        battery       = (battery       * dathisc):aggregate_scenarios(BY_SUM());
        defict        = (defict        * dathisc):aggregate_scenarios(BY_SUM());
    else
        thermal_gen   = thermal_gen  :aggregate_scenarios(BY_AVERAGE());
        hidro_gen     = hidro_gen    :aggregate_scenarios(BY_AVERAGE());
        renewable_gen = renewable_gen:aggregate_scenarios(BY_AVERAGE());
        solar_gen     = solar_gen    :aggregate_scenarios(BY_AVERAGE());
        wind_gen      = wind_gen     :aggregate_scenarios(BY_AVERAGE());
        csp_gen       = csp_gen      :aggregate_scenarios(BY_AVERAGE());
        battery       = battery      :aggregate_scenarios(BY_AVERAGE());
        defict        = defict       :aggregate_scenarios(BY_AVERAGE());
    end

    local chart = create_chart("", case);
    chart:add_area_spline_stacking(thermal_gen:aggregate_agents(BY_SUM(), dictionary.total_thermal[language]), { color = colors.total_generation.thermal });
    chart:add_area_spline_stacking(hidro_gen:aggregate_agents(BY_SUM(), dictionary.total_hydro[language]), { color = colors.total_generation.hydro });
    chart:add_area_spline_stacking(renewable_gen:aggregate_agents(BY_SUM(), dictionary.total_renewable[language]), { color = colors.total_generation.renewable });
    chart:add_area_spline_stacking(solar_gen:aggregate_agents(BY_SUM(), dictionary.total_solar[language]), { color = colors.total_generation.solar });
    chart:add_area_spline_stacking(wind_gen:aggregate_agents(BY_SUM(), dictionary.total_wind[language]), { color = colors.total_generation.wind });
    chart:add_area_spline_stacking(csp_gen:aggregate_agents(BY_SUM(), dictionary.total_csp[language]), { color = colors.total_generation.csp });
    chart:add_area_spline_stacking(battery:aggregate_agents(BY_SUM(), dictionary.total_battery[language]), { color = colors.total_generation.battery });
    chart:add_area_spline_stacking(defict:aggregate_agents(BY_SUM(), dictionary.deficit[language]), { color = colors.total_generation.defict });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_hourly_generation_typical_day(case)
    local renewable_gen_ind = renewable[case]:load("opt2_gergndmw")

    local thermal_gen   = thermal[case]:load("opt2_gertermw")
                                 :aggregate_agents(BY_SUM(),dictionary.total_thermal[language]);
    local hidro_gen     = hydro[case]:load("opt2_gerhidmw")
                                 :aggregate_agents(BY_SUM(),dictionary.total_hydro[language]);
    local renewable_gen = renewable_gen_ind:select_agents(renewable[case].tech_type:ne(1 | 2 | 5) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_renewable[language]);
    local solar_gen     = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(2) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_solar[language]);
    local wind_gen      = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(1) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_wind[language]);
    local csp_gen       = renewable_gen_ind:select_agents(renewable[case].tech_type:eq(5) )
                                 :aggregate_agents(BY_SUM(),dictionary.total_csp[language]);
    local battery       = battery[case]:load("opt2_gerbat")
                                 :aggregate_agents(BY_SUM(),dictionary.total_battery[language]);
    local defict        = generic[case]:load("opt2_deficitmw") -- com problema
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
        hidro_gen     = (hidro_gen     * dathisc):aggregate_scenarios(BY_SUM());
        renewable_gen = (renewable_gen * dathisc):aggregate_scenarios(BY_SUM());
        solar_gen     = (solar_gen     * dathisc):aggregate_scenarios(BY_SUM());
        wind_gen      = (wind_gen      * dathisc):aggregate_scenarios(BY_SUM());
        csp_gen       = (csp_gen       * dathisc):aggregate_scenarios(BY_SUM());
        battery       = (battery       * dathisc):aggregate_scenarios(BY_SUM());
        defict        = (defict        * dathisc):aggregate_scenarios(BY_SUM());
    else
        thermal_gen   = thermal_gen  :aggregate_scenarios(BY_AVERAGE());
        hidro_gen     = hidro_gen    :aggregate_scenarios(BY_AVERAGE());
        renewable_gen = renewable_gen:aggregate_scenarios(BY_AVERAGE());
        solar_gen     = solar_gen    :aggregate_scenarios(BY_AVERAGE());
        wind_gen      = wind_gen     :aggregate_scenarios(BY_AVERAGE());
        csp_gen       = csp_gen      :aggregate_scenarios(BY_AVERAGE());
        battery       = battery      :aggregate_scenarios(BY_AVERAGE());
        defict        = defict       :aggregate_scenarios(BY_AVERAGE());
    end

    local vector_of_chart = {};
    local _,day_thermal_gen   = by_day(thermal_gen  );
    local _            ,day_hidro_gen     = by_day(hidro_gen    );
    local _            ,day_renewable_gen = by_day(renewable_gen);
    local _            ,day_solar_gen     = by_day(solar_gen    );
    local _            ,day_wind_gen      = by_day(wind_gen     );
    local _            ,day_csp_gen       = by_day(csp_gen      );
    local _            ,day_battery       = by_day(battery      );
    local N_typical_day,day_defict        = by_day(defict       );

    if not N_typical_day then -- mudar
        error("N_typical_day nil");
    end

    local initial_year = study[case]:initial_year();
    local final_year   = defict:final_year();
    for year = initial_year,initial_year do -- mudar
        local first_stg = 1;
        local final_stga = study[case]:stages_per_year();

        if year == initial_year then
            first_stg  = study[case]:initial_stage();
            final_stga = final_stga - first_stg;
        end

        if year == final_year then
            final_stga = (study[case]:stages() - study[case]:initial_stage())%study[case]:stages_per_year();
        end

        for stg = first_stg, first_stg do
            for t_day = 1, 1 do -- mudar
                local year_day_thermal_gen   = day_thermal_gen  [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_hidro_gen     = day_hidro_gen    [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_renewable_gen = day_renewable_gen[t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_solar_gen     = day_solar_gen    [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_wind_gen      = day_wind_gen     [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_csp_gen       = day_csp_gen      [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_battery       = day_battery      [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);
                local year_day_defict        = day_defict       [t_day]:select_stages_by_year(year):select_stage(stg):remove_zeros():round(0);

                local chart = create_chart(dictionary.season[language] .. " - " .. stg .." | "..
                                           dictionary.year[language] .. " - " .. year .. " | " ..
                                           dictionary.typical_day[language] .. " - " .. t_day,case);
                chart:add_area_spline_stacking(year_day_thermal_gen  , { color = colors.total_generation.thermal });
                chart:add_area_spline_stacking(year_day_hidro_gen    , { color = colors.total_generation.hydro });
                chart:add_area_spline_stacking(year_day_renewable_gen, { color = colors.total_generation.renewable });
                chart:add_area_spline_stacking(year_day_solar_gen    , { color = colors.total_generation.solar });
                chart:add_area_spline_stacking(year_day_wind_gen     , { color = colors.total_generation.wind });
                chart:add_area_spline_stacking(year_day_csp_gen      , { color = colors.total_generation.csp });
                chart:add_area_spline_stacking(year_day_battery      , { color = colors.total_generation.battery });
                chart:add_area_spline_stacking(year_day_defict       , { color = colors.total_generation.defict });

                if #chart <= 0 then
                    return 
                end

                table.insert(vector_of_chart, chart);
            end
        end
    end

    return vector_of_chart;
end

local function chart_objective_value(case)
    local interest = (1 + study[case].discount_rate) ^ ((study[case].stage_in_year - 1) / study[case]:stages_per_year());
    local dathisc = generic[case]:load("opt2_optgscen"):select_stage(1);
    local opt2_optgcoped = (generic[case]:load("opt2_optgcope") * interest * dathisc):aggregate_stages(BY_SUM());

    local chart = create_chart("", case);
    chart:add_pie(opt2_optgcoped, { color = colors.generic });

    if #chart <= 0 then
        return 
    end

    return chart;
end

local function chart_risk_curve(case)
    local chart = create_chart("", case);

    local inp_table = generic[case]:load_table("outrisk.csv");

    if #inp_table > 0 then
        local FObj = {};
        local year = {};
        local LHS = {};
        for i = 1, #inp_table do
            table.insert(year, inp_table[i]["year"]);
            table.insert(FObj, inp_table[i]["FObj"]);
            table.insert(LHS, inp_table[i]["LHS"]);
        end

        opt2_format_to_chart_scatterplot(year, { LHS, FObj }, { "LHS", "FObj" }, chart, "K$", case);
    end

    if #chart <= 0 then
        risk_results = false;
        return 
    end

    return chart;
end

local function chart_convergence(case)
    local chart = create_chart("", case);

    local gap = generic[case]:load("opt2_optgconv"):select_agent("Gap"):rename_agents({dictionary.GAP[language]});

    chart:add_line(gap);

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
                    tab:push("### " .. dictionary.accumulated_capacity[language]);
                end
                tab:push(chart);
            end
        end
    end

    if plot.circuit_accumulated_capacity then
        for case = 1, cases do
            local chart = chart_circuit_accumulated_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.circuit_accumulated_capacity[language]);
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
                    tab:push("### " .. dictionary.total_costs[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.total_installed_capacity then
        for case = 1, cases do
            local chart = chart_total_installed_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.total_installed_capacity[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.total_installed_capacity_mix then
        for case = 1, cases do
            local chart = chart_total_installed_capacity_mix(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.total_installed_capacity_mix[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.firm_capacity then
        for case = 1, cases do
            local chart = chart_firm_capacity(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.firm_capacity[language]);
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
                    tab:push("### " .. dictionary.firm_capacity_mix[language]);
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
                    tab:push("### " .. dictionary.firm_energy[language]);
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
                    tab:push("### " .. dictionary.firm_capacity_mix[language]);
                end
               tab:push(chart);
            end
        end
    end

    return tab;
end

local function tab_optgen2_reports()
    local tab<const> = create_tab(dictionary.optgen_2_reports[language], "arrow-right");

    if plot.annual_marginal_cost then
        for case = 1, cases do
            local chart = chart_annual_marginal_cost(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.annual_marginal_cost[language]);
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
                    tab:push("### " .. dictionary.monthly_marginal_cost[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.hourly_generation_typical then
        for case = 1, cases do
            local chart = chart_hourly_marginal_cost_per_typical_day(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.hourly_marginal_cost_typical[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.deficit_risk then
        for case = 1, cases do
            local chart = chart_defict_risk(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.deficit_risk[language]);
                end
               tab:push(chart);
            end
        end
    end

    if plot.generation_in_each_season then
        for case = 1, cases do
            local chart = chart_generation_in_season(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.generation_in_season[language]);
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
                    tab:push("### " .. dictionary.generation_per_typical_day[language]);
                end
               tab:push(chart);
            end

        end
    end

    if plot.objective_function then
        for case = 1, cases do
            local chart = chart_objective_value(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.objective_functions[language]);
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
                    tab:push("### " .. dictionary.convergence[language]);
                end
               tab:push(chart);
            end
        end
    end

    return tab;
end

local function tab_risk_result()
    local tab<const> = create_tab(dictionary.optgen_risk[language], "arrow-right");

    if plot.risk_curve then
        for case = 1, cases do
            local chart = chart_risk_curve(case);
            if chart then
                if case == 1 then
                    tab:push("### " .. dictionary.optgen_risk[language]);
                end
               tab:push(chart);
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
        if not Study(i):file_exists("sddp.info") then
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
local dashboard<const> = Dashboard();
dashboard:push(tab_expansion_result());

local sddp_tab = tab_sddp();
if sddp_tab then
    dashboard:push(sddp_tab);
end

dashboard:save("OptGen");
