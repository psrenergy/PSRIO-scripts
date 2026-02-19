N_cases = PSR.studies();

local lang = "en";

local table_case_color = {
    "#DB3C3C",
    "#528AC5",
    "#2ECC71",
    "#F39C12",
    "#E74C3C",
    "#9B59B6",
    "#1ABC9C",
    "#34495E",
    "#FF6B6B",
    "#4ECDC4",
}

local table_techtype_color = {
    thermal = "#E74C3C",
    hydro = "#3498DB",
    renewable = "#2ECC71",
    battery = "#F39C12",
    reactive_injection_power_penalty = "#9B59B6",
    sincron = "#9C59B6",
    shunt = "#1ABC9C",
}

local dictionary = {
    scenarios = {en = "Scenarios", es = "Escenarios", pt = "Cenários"},
    stages = {en = "Stages", es = "Etapas", pt = "Estágios"},
    costs = {en = "Costs", es = "Costos", pt = "Custos"},
    generation = {en = "Generation", es = "Generación", pt = "Geração"},
    thermal = {en = "Thermal", es = "Térmica", pt = "Térmica"},
    hydro = {en = "Hydro", es = "Hidro", pt = "Hidro"},
    renewable = {en = "Renewable", es = "Renovable", pt = "Renovável"},
    battery = {en = "Battery", es = "Batería", pt = "Bateria"},
    reactive_injection_power_penalty = {en = "Reactive injection power penalty", es = "Penalización de potencia de inyección reactiva", pt = "Penalidade de potência de injeção reativa"},
    shunt = {en = "Shunt", es = "Shunt", pt = "Shunt"},
    sincron = {en = "Sincron", es = "Síncron", pt = "Síncron"},
    static_compensator = {en = "Static compensator", es = "Compensador estático", pt = "Compensador estático"},
    injection = {en = "Injection", es = "Inyección", pt = "Injeção"},
    buses = {en = "Buses", es = "Barras", pt = "Barras"},
    results = {en = "Results", es = "Resultados", pt = "Resultados"},
    deviation = {en = "Deviation", es = "Desviación", pt = "Desvio"},
    voltages = {en = "Voltage", es = "Voltaje", pt = "Tensão"},
    solutions = {en = "Solutions", es = "Soluciones", pt = "Soluções"},

    solution_status = {en = "Convergence status", es = "Estado de convergencia", pt = "Status de convergência"},
    solution_time = {en = "Solution time", es = "Tiempo de solución", pt = "Tempo de solução"},
    not_converged_solution = {en = "Not converged solution", es = "Solución no convergida", pt = "Solução não convergida"},
    unselected = {en = "Unselected", es = "No seleccionado", pt = "Não selecionado"},
    optimal_solution = {en = "Optimal solution", es = "Solución óptima", pt = "Solução ótima"},
    feasible_solution = {en = "Feasible solution", es = "Solución factible", pt = "Solução factível"},
    divergent_solution = {en = "Divergent solution", es = "Solución divergente", pt = "Solução divergente"},

    nonexceedance_solution_times = {en = "Nonexceedance solution times", es = "Tiempos de solución de no superación", pt = "Tempos de solução de não superação"},

    stage_solution_times = {en = "Max stage solution times", es = "Tiempos máximos de solución por etapa", pt = "Tempos máximos de solução por etapa"},

    operative_cost = {en = "Operative cost", es = "Costo operativo", pt = "Custo operativo"},

    operative_cost_stage = {en = "Operative cost per stage", es = "Costo operativo por etapa", pt = "Custo operativo por estágio"},

    solution_mismatches = {en = "Solution mismatches", es = "Desajustes de la solución", pt = "Desajustes da solução"},

    active_power_solution_mismatches = {en = "Active power solution mismatches", es = "Desajustes de potencia activa de la solución", pt = "Desajustes de potência ativa da solução"},
    reactive_power_solution_mismatches = {en = "Reactive power solution mismatches", es = "Desajustes de potencia reactiva de la solución", pt = "Desajustes de potência reativa da solução"},
    load_shedding = {en = "Load shedding", es = "Corte de carga", pt = "Corte de carga"},
    active_load_shedding = {en = "Active load shedding", es = "Corte de carga activo", pt = "Corte de carga ativo"},
    reactive_load_shedding = {en = "Reactive load shedding", es = "Corte de carga reactiva", pt = "Corte de carga reativa"},

    generation_results = {en = "Generation results", es = "Resultados de generación", pt = "Resultados de geração"},
    active_power_generation = {en = "Active power generation", es = "Generación de potencia activa", pt = "Geração de potência ativa"},
    reactive_power_generation = {en = "Reactive power generation", es = "Generación de potencia reactiva", pt = "Geração de potência reativa"},

    power_generation_deviations = {en = "Power generation deviations", es = "Desviaciones de generación de potencia", pt = "Desvios de geração de potência"},
    active_power_generation_deviations = {en = "Active power generation deviations", es = "Desviaciones de generación de potencia activa", pt = "Desvios de geração de potência ativa"},
    thermal_generation_deviations = {en = "Thermal generation deviations", es = "Desviaciones de generación térmica", pt = "Desvios de geração térmica"},
    hydro_generation_deviations = {en = "Hydro generation deviations", es = "Desviaciones de generación hidro", pt = "Desvios de geração hidro"},
    renewable_generation_deviations = {en = "Renewable generation deviations", es = "Desviaciones de generación renovable", pt = "Desvios de geração renovável"},
    battery_generation_deviations = {en = "Battery generation deviations", es = "Desviaciones de generación de baterías", pt = "Desvios de geração de baterias"},
    
    voltage_profiles = {en = "Voltage profiles", es = "Perfiles de voltaje", pt = "Perfis de tensão"},
    voltage_limits = {en = "Voltage limits", es = "Límites de voltaje", pt = "Limites de tensão"},
    voltage_lower_limit = {en = "Voltage lower limit", es = "Límite inferior de voltaje", pt = "Limite inferior de tensão"},
    voltage_upper_limit = {en = "Voltage upper limit", es = "Límite superior de voltaje", pt = "Limite superior de tensão"},
    solution_quality = {en = "Solution quality", es = "Calidad de la solución", pt = "Qualidade da solução"},
    solution_results = {en = "Solution results", es = "Resultados de la solución", pt = "Resultados da solução"},
}

function load_data(output, lang)
    for case = 1, N_cases do
        output.optflow = output.optflow or {};
        output.optflow[case] = {};

        output.sddp = output.sddp or {};
        output.sddp[case] = {};

        output.optflow[case].solution_status = Generic(case):load("opf_status"):aggregate_blocks();
        output.optflow[case].solution_time = Generic(case):load("opf_tcpu");

        output.optflow[case].thermal_cost = Generic(case):load("opf_cotr"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.thermal[lang]);
        output.optflow[case].hydro_cost = Generic(case):load("opf_cohd"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.hydro[lang]);
        output.optflow[case].renewable_cost = Generic(case):load("opf_corn"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.renewable[lang]);
        output.optflow[case].pot_injection_penalty_cost = Generic(case):load("opf_cinj"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.reactive_injection_power_penalty[lang]);

        output.optflow[case].active_power_mismatches = Generic(case):load("opf_mismatmw");
        output.optflow[case].reactive_power_mismatches = Generic(case):load("opf_mismatmvar");

        output.optflow[case].active_thermal_generation = Generic(case):load("opf_pter"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.thermal[lang]);
        output.optflow[case].active_hydro_generation = Generic(case):load("opf_phdr"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.hydro[lang]);
        output.optflow[case].active_renewable_generation = Generic(case):load("opf_pgnd"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.renewable[lang]);
        output.optflow[case].active_batt_generation = Generic(case):load("opf_pbat"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.battery[lang]);

        output.optflow[case].reactive_thermal_generation = Generic(case):load("opf_qter"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.thermal[lang]);
        output.optflow[case].reactive_hydro_generation = Generic(case):load("opf_qhdr"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.hydro[lang]);
        output.optflow[case].reactive_renewable_generation = Generic(case):load("opf_qgnd"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.renewable[lang]);
        output.optflow[case].reactive_batt_generation = Generic(case):load("opf_qbat"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.battery[lang]);
        output.optflow[case].reactive_sinc_generation = Generic(case):load("opf_qsin"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.sincron[lang]);
        output.optflow[case].reactive_shunt_generation = Generic(case):load("opf_shtb"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.shunt[lang]);
        output.optflow[case].reactive_static_compensator_generation = Generic(case):load("opf_qsvc"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.static_compensator[lang]);
        output.optflow[case].reactive_injection_generation = Generic(case):load("opf_qinj"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.injection[lang]);

        output.optflow[case].active_load_shedding = Generic(case):load("opf_lshp"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE());
        output.optflow[case].reactive_load_shedding = Generic(case):load("opf_lshq"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE());

        output.optflow[case].voltage_margin_lower = Generic(case):load("opf_voltagemarginlower"):aggregate_blocks(BY_MAX());
        output.optflow[case].voltage_margin_upper = Generic(case):load("opf_voltagemarginupper"):aggregate_blocks(BY_MAX());

        output.sddp[case].active_thermal_generation = Generic(case):load("gerter"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.thermal[lang]):convert("MW");
        output.sddp[case].active_hydro_generation = Generic(case):load("gerhid"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.hydro[lang]):convert("MW");
        output.sddp[case].active_renewable_generation = Generic(case):load("gergnd"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.renewable[lang]):convert("MW");
        output.sddp[case].active_batt_generation = Generic(case):load("gerbat"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.battery[lang]):convert("MW");
    end
end

local output = {};
load_data(output, lang)

function Tab.add_convergence_status_chart(self, n_cases, Lang)
    
    local options = {
        yLabel = dictionary.scenarios[Lang],
        xLabel = dictionary.stages[Lang],
        showInLegend = true,
        dataClasses = {
            { color = "#8ACE7E", from = -0.1, to = 0.1, name = dictionary.optimal_solution[Lang]},
            { color = "#4E79A7", from = 0.9, to = 1.1, name = dictionary.feasible_solution[Lang]},
            { color = "#C64B3E", from = -1.1, to = -0.9, name = dictionary.unselected[Lang]},
            { color = "#164E74", from = -2.1, to = -2.0, name = dictionary.not_converged_solution[Lang]},
            { color = "#5A1730", from = -2.9, to = -3.1, name = dictionary.divergent_solution[Lang]}
        }
    };

    local subtitle = "";
    local status_charts = {};
    if n_cases > 1 then
        for case = 1, n_cases do
            subtitle = Generic(case):cloudname();
            local chart = Chart(dictionary.solution_status[Lang], subtitle);
            chart:add_heatmap(output.optflow[case].solution_status, options);
            chart:horizontal_legend();

            table.insert(status_charts, chart);
        end

    else
        local chart = Chart(dictionary.solution_status[Lang]);
        chart:add_heatmap(output.optflow[1].solution_status, options);
        chart:horizontal_legend();

        status_charts = chart;
    end

    self:push(status_charts);
    
end

function Tab.add_nonexceedance_solution_times_chart(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;

    local chart = Chart(dictionary.nonexceedance_solution_times[Lang]);
    chart:horizontal_legend();

    for case = 1, n_cases do
        local times = output.optflow[case].solution_time:rename_agent(Generic(case):cloudname());
        chart:add_probability_of_nonexceedance(times, {showInLegend=show_in_legend, color = table_case_color[case]});
    end
    self:push(chart);

end

function Tab.add_stage_solution_times_chart(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;

     -- Stage solution times
    local chart = Chart(dictionary.stage_solution_times[Lang]);
    chart:horizontal_legend();

    for case = 1, n_cases do
        local times = output.optflow[case].solution_time:aggregate_blocks(BY_MAX()):rename_agent(Generic(case):cloudname());
        chart:add_column(times, {showInLegend=show_in_legend, color = table_case_color[case]});
    end
    self:push(chart);
end

function Tab.active_solution_mismatches_charts(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;

    -- Active power solution mismatches
    local chart = Chart(dictionary.active_power_solution_mismatches[Lang]);
    chart:horizontal_legend();

    for case = 1, n_cases do
        chart:add_line(output.optflow[case].active_power_mismatches, Generic(case):cloudname(),  {showInLegend=show_in_legend, color = table_case_color[case]});
    end
    self:push(chart);

end

function Tab.reactive_solution_mismatches_charts(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;
    
    -- Reactive power solution mismatches
    local chart = Chart(dictionary.reactive_power_solution_mismatches[Lang]);
    chart:horizontal_legend();

    for case = 1, n_cases do
        chart:add_line(output.optflow[case].reactive_power_mismatches, Generic(case):cloudname(), {showInLegend=show_in_legend, color = table_case_color[case]});
    end
    self:push(chart);

end

function Tab.operative_cost_charts(self, n_cases, Lang)
    -- Operative cost

    local chart = Chart(dictionary.operative_cost[Lang]);
    chart:horizontal_legend();

    if n_cases > 1 then
        for case = 1, n_cases do
            local objective_cost = concatenate(output.optflow[case].thermal_cost:aggregate_stages(BY_SUM()),
                                               output.optflow[case].hydro_cost:aggregate_stages(BY_SUM()),
                                               output.optflow[case].renewable_cost:aggregate_stages(BY_SUM()),
                                               output.optflow[case].pot_injection_penalty_cost:aggregate_stages(BY_SUM()));

            chart:add_categories(objective_cost:remove_zeros(), Generic(case):cloudname(), {color = table_case_color[case]});
        end
    else
        chart:add_pie(output.optflow[1].thermal_cost:aggregate_stages(BY_SUM()):remove_zeros(), {color = table_techtype_color.thermal});
        chart:add_pie(output.optflow[1].hydro_cost:aggregate_stages(BY_SUM()):remove_zeros(), {color = table_techtype_color.hydro});
        chart:add_pie(output.optflow[1].renewable_cost:aggregate_stages(BY_SUM()):remove_zeros(), {color = table_techtype_color.renewable});
        chart:add_pie(output.optflow[1].pot_injection_penalty_cost:aggregate_stages(BY_SUM()):remove_zeros(), {color = table_techtype_color.reactive_injection_power_penalty});
    end

    if #chart > 1 then
        self:push(chart);
        return true;
    end
    return false;
end

function Tab.operative_stage_cost_charts(self, n_cases, Lang)
    -- Operative stage cost
    local operative_cost_charts = {};

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.operative_cost_stage[Lang], Generic(case):cloudname());
            chart:horizontal_legend();

            chart:add_column_stacking(output.optflow[case].thermal_cost:remove_zeros(), {color = table_techtype_color.thermal, stack = case});
            chart:add_column_stacking(output.optflow[case].hydro_cost:remove_zeros(), {color = table_techtype_color.hydro, stack = case});
            chart:add_column_stacking(output.optflow[case].renewable_cost:remove_zeros(), {color = table_techtype_color.renewable, stack = case});
            chart:add_column_stacking(output.optflow[case].pot_injection_penalty_cost:remove_zeros(), {color = table_techtype_color.reactive_injection_power_penalty, stack = case});

            if #chart > 0 then
                table.insert(operative_cost_charts, chart);
            end
        end
    else
        local chart = Chart(dictionary.operative_cost_stage[Lang]);
        chart:horizontal_legend();

        chart:add_column(output.optflow[1].thermal_cost:remove_zeros(), {color = table_techtype_color.thermal});
        chart:add_column(output.optflow[1].hydro_cost:remove_zeros(), {color = table_techtype_color.hydro});
        chart:add_column(output.optflow[1].renewable_cost:remove_zeros(), {color = table_techtype_color.renewable});
        chart:add_column(output.optflow[1].pot_injection_penalty_cost:remove_zeros(), {color = table_techtype_color.reactive_injection_power_penalty});

        if #chart > 0 then
            operative_cost_charts = chart;
        end
    end

    if #operative_cost_charts > 1 then
        self:push(operative_cost_charts);
        return true;
    end
    return false;
end



function Tab.active_generation_charts(self, n_cases, Lang)

    local generation_charts = {};
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.active_power_generation[Lang], Generic(case):cloudname());
            chart:horizontal_legend();

            chart:add_area_stacking(output.optflow[case].active_thermal_generation, {color = table_techtype_color.thermal});
            chart:add_area_stacking(output.optflow[case].active_hydro_generation, {color = table_techtype_color.hydro});
            chart:add_area_stacking(output.optflow[case].active_renewable_generation, {color = table_techtype_color.renewable});
            chart:add_area_stacking(output.optflow[case].active_batt_generation, {color = table_techtype_color.battery});

            table.insert(generation_charts, chart);
        end

    else
        local chart = Chart(dictionary.active_power_generation[Lang]);
        chart:horizontal_legend();

        chart:add_area_stacking(output.optflow[1].active_thermal_generation, {color = table_techtype_color.thermal});
        chart:add_area_stacking(output.optflow[1].active_hydro_generation, {color = table_techtype_color.hydro});
        chart:add_area_stacking(output.optflow[1].active_renewable_generation, {color = table_techtype_color.renewable});
        chart:add_area_stacking(output.optflow[1].active_batt_generation, {color = table_techtype_color.battery});

        generation_charts = chart;
    end

    self:push(generation_charts);
end

function Tab.reactive_generation_charts(self, n_cases, Lang)
    local reactive_generation_charts = {};
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.reactive_power_generation[Lang], Generic(case):cloudname());
            chart:horizontal_legend();

            chart:add_area_stacking(output.optflow[case].reactive_thermal_generation, {color = table_techtype_color.thermal});
            chart:add_area_stacking(output.optflow[case].reactive_hydro_generation, {color = table_techtype_color.hydro});
            chart:add_area_stacking(output.optflow[case].reactive_renewable_generation, {color = table_techtype_color.renewable});
            chart:add_area_stacking(output.optflow[case].reactive_batt_generation, {color = table_techtype_color.battery});
            chart:add_area_stacking(output.optflow[case].reactive_sinc_generation, {color = table_techtype_color.sincron});
            chart:add_area_stacking(output.optflow[case].reactive_shunt_generation, {color = table_techtype_color.shunt});
            chart:add_area_stacking(output.optflow[case].reactive_static_compensator_generation, {color = table_techtype_color.static_compensator});
            chart:add_area_stacking(output.optflow[case].reactive_injection_generation, {color = table_techtype_color.reactive_injection_power_penalty});

            table.insert(reactive_generation_charts, chart);
        end

    else
        local chart = Chart(dictionary.reactive_power_generation[Lang]);
        chart:horizontal_legend();
        
        chart:add_area_stacking(output.optflow[1].reactive_thermal_generation, {color = table_techtype_color.thermal});
        chart:add_area_stacking(output.optflow[1].reactive_hydro_generation, {color = table_techtype_color.hydro});
        chart:add_area_stacking(output.optflow[1].reactive_renewable_generation, {color = table_techtype_color.renewable});
        chart:add_area_stacking(output.optflow[1].reactive_batt_generation, {color = table_techtype_color.battery});
        chart:add_area_stacking(output.optflow[1].reactive_sinc_generation, {color = table_techtype_color.sincron});
        chart:add_area_stacking(output.optflow[1].reactive_shunt_generation, {color = table_techtype_color.shunt});
        chart:add_area_stacking(output.optflow[1].reactive_static_compensator_generation, {color = table_techtype_color.static_compensator});
        chart:add_area_stacking(output.optflow[1].reactive_injection_generation, {color = table_techtype_color.reactive_injection_power_penalty});

        reactive_generation_charts = chart;
    end

    self:push(reactive_generation_charts);
end

function Tab.active_load_shedding_chart(self, n_cases, Lang)

    local min = 0;
    local max = 100;
    for case = 1, n_cases do
        local case_max = tonumber(output.optflow[case].active_load_shedding:aggregate_blocks(BY_MAX()):aggregate_stages(BY_MAX()):aggregate_agents(BY_MAX(), "total"):to_list()[1]);
        if case_max > max then
            max = case_max;
        end
        local case_min = tonumber(output.optflow[case].active_load_shedding:aggregate_blocks(BY_MIN()):aggregate_stages(BY_MIN()):aggregate_agents(BY_MIN(), "total"):to_list()[1]);
        if case_min < min then
            min = case_min;
        end
    end

    local subTitle = "";
    for case = 1, n_cases do
        if n_cases > 1 then
            subTitle = Generic(case):cloudname();
        end
        local chart = Chart(dictionary.active_load_shedding[Lang], subTitle);

        local options = {
            yLabel = dictionary.stages[Lang],
            xLabel = dictionary.buses[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } },
            stopsMin = min,
            stopsMax = max
        };
        chart:add_heatmap_agents(output.optflow[case].active_load_shedding, options);
        chart:invert_axes();
        chart:enable_vertical_zoom();

        self:push(chart);
    end
end

function Tab.reactive_load_shedding_chart(self, n_cases, Lang)

    local min = 0;
    local max = 100;
    for case = 1, n_cases do
        local case_max = tonumber(output.optflow[case].reactive_load_shedding:aggregate_blocks(BY_MAX()):aggregate_stages(BY_MAX()):aggregate_agents(BY_MAX(), "total"):to_list()[1]);
        if case_max > max then
            max = case_max;
        end
        local case_min = tonumber(output.optflow[case].reactive_load_shedding:aggregate_blocks(BY_MIN()):aggregate_stages(BY_MIN()):aggregate_agents(BY_MIN(), "total"):to_list()[1]);
        if case_min < min then
            min = case_min;
        end
    end

    local subTitle = "";
    for case = 1, n_cases do
        if n_cases > 1 then
            subTitle = Generic(case):cloudname();
        end
        local chart = Chart(dictionary.reactive_load_shedding[Lang], subTitle);

        local options = {
            yLabel = dictionary.stages[Lang],
            xLabel = dictionary.buses[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } },
            stopsMin = min,
            stopsMax = max
        };
        chart:add_heatmap_agents(output.optflow[case].reactive_load_shedding, options);
        chart:invert_axes();
        chart:enable_vertical_zoom();

        self:push(chart);
    end
end

function Tab.generation_deviation_charts(self, n_cases, Lang)
    local deviation_charts = {};
    local subTitle = "";
    for case = 1, n_cases do
        
        if n_cases > 1 then
            subTitle = Generic(case):cloudname();
        end
        
        local chart = Chart(dictionary.active_power_generation_deviations[Lang], subTitle);
        chart:horizontal_legend();

        chart:add_area_stacking(output.optflow[case].active_thermal_generation, {color = table_techtype_color.thermal});
        chart:add_area_stacking(output.optflow[case].active_hydro_generation, {color = table_techtype_color.hydro});
        chart:add_area_stacking(output.optflow[case].active_renewable_generation, {color = table_techtype_color.renewable});
        chart:add_area_stacking(output.optflow[case].active_batt_generation, {color = table_techtype_color.battery});

        table.insert(deviation_charts, chart);

        local chart = Chart(dictionary.active_power_generation_deviations[Lang], subTitle);
        chart:horizontal_legend();

        chart:add_area_stacking(output.sddp[case].active_thermal_generation, {color = table_techtype_color.thermal});
        chart:add_area_stacking(output.sddp[case].active_hydro_generation, {color = table_techtype_color.hydro});
        chart:add_area_stacking(output.sddp[case].active_renewable_generation, {color = table_techtype_color.renewable});
        chart:add_area_stacking(output.sddp[case].active_batt_generation, {color = table_techtype_color.battery});

        table.insert(deviation_charts, chart);
    end
    self:push(deviation_charts);
end

function Tab.generation_deviation_individual_charts(self, n_cases, Lang)
    for case = 1, n_cases do
        local subtitle = "";
        if n_cases > 1 then
            subtitle = Generic(case):cloudname();
        end

        local chart_thermal = Chart(dictionary.thermal_generation_deviations[Lang], subtitle);
        chart_thermal:horizontal_legend();

        local chart_hydro = Chart(dictionary.hydro_generation_deviations[Lang], subtitle);
        chart_hydro:horizontal_legend();

        local chart_renewable = Chart(dictionary.renewable_generation_deviations[Lang], subtitle);
        chart_renewable:horizontal_legend();

        local chart_batt = Chart(dictionary.battery_generation_deviations[Lang], subtitle);
        chart_batt:horizontal_legend();

        local thermal_generation = output.optflow[case].active_thermal_generation:rename_agent("OptFlow");
        local sddp_thermal_generation = output.sddp[case].active_thermal_generation:rename_agent("SDDP");
        local thermal_deviation = (thermal_generation - sddp_thermal_generation):rename_agent("Deviation");
        chart_thermal:add_column(thermal_generation, {color = table_case_color[1]});
        chart_thermal:add_column(sddp_thermal_generation, {color = table_case_color[2]});
        chart_thermal:add_line(thermal_deviation, {dashStyle = "ShortDash", color = "black"});

        local hydro_generation = output.optflow[case].active_hydro_generation:rename_agent("OptFlow");
        local sddp_hydro_generation = output.sddp[case].active_hydro_generation:rename_agent("SDDP");
        local hydro_deviation = (hydro_generation - sddp_hydro_generation):rename_agent("Deviation");
        chart_hydro:add_column(hydro_generation, {color = table_case_color[1]});
        chart_hydro:add_column(sddp_hydro_generation, {color = table_case_color[2]});
        chart_hydro:add_line(hydro_deviation, {dashStyle = "ShortDash", color = "black"});

        local renewable_generation = output.optflow[case].active_renewable_generation:rename_agent("OptFlow");
        local sddp_renewable_generation = output.sddp[case].active_renewable_generation:rename_agent("SDDP");
        local renewable_deviation = (renewable_generation - sddp_renewable_generation):rename_agent("Deviation");
        chart_renewable:add_column(renewable_generation, {color = table_case_color[1]});
        chart_renewable:add_column(sddp_renewable_generation, {color = table_case_color[2]});
        chart_renewable:add_line(renewable_deviation, {dashStyle = "ShortDash", color = "black"});

        local batt_generation = output.optflow[case].active_batt_generation:rename_agent("OptFlow");
        local sddp_batt_generation = output.sddp[case].active_batt_generation:rename_agent("SDDP");
        local batt_deviation = (batt_generation - sddp_batt_generation):rename_agent("Deviation");
        chart_batt:add_column(batt_generation, {color = table_case_color[1]});
        chart_batt:add_column(sddp_batt_generation, {color = table_case_color[2]});
        chart_batt:add_line(batt_deviation, {dashStyle = "ShortDash", color = "black"});

        if #chart_thermal > 1 then
            self:push(chart_thermal);
        end
        if #chart_hydro > 1 then
            self:push(chart_hydro);
        end
        if #chart_renewable > 1 then
            self:push(chart_renewable);
        end
        if #chart_batt > 1 then
            self:push(chart_batt);
        end
    end
end

function Tab.add_voltage_limits_upper_chart(self, n_cases, Lang)
    local options = {
            yLabel = dictionary.stages[Lang],
            xLabel = dictionary.buses[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            tops = { { 0, "#4E79A7" }, { 1, "#C64B3E" } },
            stopsMin = 0,
            stopsMax = 1
        };

    local voltage_limit_charts = {};
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.voltage_upper_limit[Lang], Generic(case):cloudname());

            chart:add_heatmap_agents(output.optflow[case].voltage_margin_upper, options);
            chart:invert_axes();
            chart:enable_vertical_zoom();

            table.insert(voltage_limit_charts, chart);
        end

    else
        local chart = Chart(dictionary.voltage_upper_limit[Lang]);

        chart:add_heatmap_agents(output.optflow[1].voltage_margin_upper, options);
        chart:invert_axes();
        chart:enable_vertical_zoom();

        voltage_limit_charts = chart;
    end

    self:push(voltage_limit_charts);
end

function Tab.add_voltage_limits_lower_chart(self, n_cases, Lang)
    local options = {
        yLabel = dictionary.stages[Lang],
        xLabel = dictionary.buses[Lang],
        showInLegend = false,
        xTickPixelInterval = 400/14,
        tops = { { 0, "#4E79A7" }, { 1, "#C64B3E" } },
        stopsMin = 0,
        stopsMax = 1
    };

    local voltage_limit_charts = {};
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.voltage_lower_limit[Lang], Generic(case):cloudname());

            chart:add_heatmap_agents(output.optflow[case].voltage_margin_lower, options);
            chart:invert_axes();
            chart:enable_vertical_zoom();

            table.insert(voltage_limit_charts, chart);
        end

    else
        local chart = Chart(dictionary.voltage_lower_limit[Lang]);

        chart:add_heatmap_agents(output.optflow[1].voltage_margin_lower, options);
        chart:invert_axes();
        chart:enable_vertical_zoom();

        voltage_limit_charts = chart;
    end

    self:push(voltage_limit_charts);
end



function Tab.Solution_Quality(self, n_cases, Lang)
    self:set_icon("thermometer");

    self:add_convergence_status_chart(n_cases, Lang);

    self:push("# " .. dictionary.solution_time[Lang]);
    self:add_nonexceedance_solution_times_chart(n_cases, Lang);
    self:add_stage_solution_times_chart(n_cases, Lang);

    local subTab_enable = true;
    local subTab = SubTab(dictionary.costs[Lang]);
    subTab:push("# " .. dictionary.costs[Lang]);
    subTab_enable = subTab_enable and subTab:operative_cost_charts(n_cases, Lang);
    subTab_enable = subTab_enable and subTab:operative_stage_cost_charts(n_cases, Lang);
    if subTab_enable then
        self:push(subTab);
    end

    -- local subTab = SubTab(dictionary.solution_mismatches[Lang]);
    self:push("# " .. dictionary.solution_mismatches[Lang]);
    self:active_solution_mismatches_charts(n_cases, Lang);
    self:reactive_solution_mismatches_charts(n_cases, Lang);
    -- self:push(subTab);
end

function Tab.Solution_Results(self, n_cases, Lang)
    self:set_icon("file-waveform");

    local subTab = SubTab(dictionary.generation[Lang]);
    subTab:push("# " .. dictionary.generation_results[Lang]);
    subTab:active_generation_charts(n_cases, Lang);
    subTab:reactive_generation_charts(n_cases, Lang);
    subTab:push("# " .. dictionary.load_shedding[Lang]);
    subTab:active_load_shedding_chart(n_cases, Lang);
    subTab:push("# " .. dictionary.reactive_load_shedding[Lang]);
    subTab:reactive_load_shedding_chart(n_cases, Lang);
    self:push(subTab);


    subTab = SubTab(dictionary.deviation[Lang]);
    subTab:push("# Optflow x SDDP " .. dictionary.results[Lang]);
    subTab:push("## " .. dictionary.power_generation_deviations[Lang]);
    subTab:generation_deviation_charts(n_cases, Lang);
    subTab:generation_deviation_individual_charts(n_cases, Lang);
    self:push(subTab);

end

function Tab.Voltage_Limits(self, n_cases, Lang)
    self:set_icon("bolt")
    self:add_voltage_limits_upper_chart(n_cases, Lang);
    self:add_voltage_limits_lower_chart(n_cases, Lang);
end



local d = Dashboard();
local tab_solution = Tab(dictionary.solutions["en"]);
tab_solution:push("# " .. dictionary.solution_quality["en"]);
tab_solution:Solution_Quality(N_cases, "en");
d:push(tab_solution);

local tab_results = Tab(dictionary.solutions["en"]);
tab_results:set_disabled();
tab_results:push("# " .. dictionary.solution_results["en"]);
tab_results:Solution_Results(N_cases, "en");
d:push(tab_results);

local tab_voltage = Tab(dictionary.voltage_profiles["en"]);
tab_voltage:push("# " .. dictionary.voltages["en"]);
tab_voltage:Voltage_Limits(N_cases, "en");
d:push(tab_voltage);

d:save("OptFlow")