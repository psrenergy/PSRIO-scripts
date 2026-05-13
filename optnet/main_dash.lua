N_cases = PSR.studies();

local function load_Lang()
    local Lang = Study(1):get_parameter("Idioma", 0);
    if Lang == 1 then
        return "es";
    elseif Lang == 2 then
        return "pt";
    else
        return "en";
    end
end

local lang = load_Lang();

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
    thermal   = "#F28E2B",
    hydro     = "#4E79A7",
    renewable = "#8CD17D",
    battery   = "#4BC9B2",
    deficit   = "#34495E",
}

local table_element_color = {
    ac_line           = "#4E79A7",
    transformer       = "#F28E2B",
    three_winding     = "#59A14F",
    series_capacitor  = "#E15759",
    flow_controller   = "#76B7B2",
    dc_line           = "#EDC948",
    converter         = "#B07AA1",
    dc_link           = "#FF9DA7",
    investment        = "#4E79A7",
    operative         = "#F28E2B",
}

local dictionary = {
    -- General
    scenarios        = {en = "Scenarios",       es = "Escenarios",  pt = "Cenários"},
    scenarios_blocks = {en = "Resolution - Scenario", es = "Resolución - Escenario", pt = "Resolução - Cenário"},
    scenario         = {en = "Scenario",         es = "Escenario",   pt = "Cenário"},
    stages           = {en = "Stages",           es = "Etapas",      pt = "Estágios"},
    stage            = {en = "Stage",            es = "Etapa",       pt = "Estágio"},
    results          = {en = "Results",          es = "Resultados",  pt = "Resultados"},
    thermal          = {en = "Thermal",          es = "Térmica",     pt = "Térmica"},
    hydro            = {en = "Hydro",            es = "Hidro",       pt = "Hidro"},
    renewable        = {en = "Renewable",        es = "Renovable",   pt = "Renovável"},
    battery          = {en = "Battery",          es = "Batería",     pt = "Bateria"},
    active_load      = {en = "Active load",      es = "Carga activa",pt = "Carga ativa"},
    summary          = {en = "Info",             es = "Información", pt = "Informações"},
    case_information = {en = "Case information", es = "Información del caso", pt = "Informações do caso"},
    warning          = {en = "WARNING",          es = "ADVERTENCIA", pt = "AVISO"},

    -- Solution quality
    solution_quality = {en = "Solution quality", es = "Calidad de la solución", pt = "Qualidade da solução"},
    convergence      = {en = "Convergence",      es = "Convergencia",           pt = "Convergência"},

    -- Convergence status
    convergence_investment_status = {
        en = "Convergence investment status",
        es = "Estado de convergencia de la inversión",
        pt = "Status de convergência do investimento",
    },
    convergence_operative_status = {
        en = "Convergence operative status",
        es = "Estado de convergencia operativo",
        pt = "Status de convergência operativo",
    },
    no_expansion_required = {
        en = "No expansion required",
        es = "Sin expansión requerida",
        pt = "Sem expansão necessária",
    },
    heuristic_solution = {
        en = "Heuristic solution",
        es = "Solución heurística",
        pt = "Solução heurística",
    },
    decomposition_solution = {
        en = "Decomposition solution",
        es = "Solución por descomposición",
        pt = "Solução por decomposição",
    },
    solution_with_slack_violation = {
        en = "Solution with slack violation",
        es = "Solución con violación de holgura",
        pt = "Solução com violação de folga",
    },
    optimal_solution_found = {
        en = "Optimal solution found",
        es = "Solución óptima encontrada",
        pt = "Solução ótima encontrada",
    },
    optimal_solution_not_found = {
        en = "Optimal solution not found",
        es = "Solución óptima no encontrada",
        pt = "Solução ótima não encontrada",
    },
    case_not_solved = {
        en = "Case not solved",
        es = "Caso no resuelto",
        pt = "Caso não resolvido",
    },

    -- Solution time
    solution_time      = {en = "Solution time",       es = "Tiempo de solución",      pt = "Tempo de solução"},
    total_cpu_time     = {en = "Total solution time",  es = "Tiempo total de solución", pt = "Tempo total de solução"},
    investment_problem = {en = "Investment problem",   es = "Problema de inversión",    pt = "Problema de investimento"},
    operative_problem  = {en = "Operative problem",    es = "Problema operativo",       pt = "Problema operativo"},

    -- Circuit loading
    circuit_loading      = {en = "Circuit Loading",      es = "Carga de circuitos",       pt = "Carregamento de circuitos"},
    circuit_flow_loading = {en = "Circuit Flow Loading", es = "Carga de flujo de circuito",pt = "Carregamento de fluxo de circuito"},
    ac_lines             = {en = "AC Lines",             es = "Líneas de CA",              pt = "Linhas de CA"},
    transformers         = {en = "Transformers",         es = "Transformadores",           pt = "Transformadores"},
    three_winding_transformers = {
        en = "Three Winding Transformers",
        es = "Transformadores de tres devanados",
        pt = "Transformadores de três enrolamentos",
    },
    series_capacitors    = {en = "Series Capacitors",    es = "Capacitores en serie",      pt = "Capacitores em série"},
    flow_controllers     = {en = "Flow Controllers",     es = "Controladores de flujo",    pt = "Controladores de fluxo"},
    dc_lines_label       = {en = "DC Lines",             es = "Líneas de CC",              pt = "Linhas de CC"},
    converters_label     = {en = "Converters",           es = "Conversores",               pt = "Conversores"},
    dc_links_label       = {en = "DC Links",             es = "Vínculos DC",               pt = "Vínculos DC"},

    -- Redundancy
    check_redundancy = {en = "Check Redundancy", es = "Verificación de redundancia", pt = "Verificação de redundância"},

    -- Investment results
    investment             = {en = "Investment",            es = "Inversión",             pt = "Investimento"},
    accumulated_capacity   = {en = "Accumulated Capacity",  es = "Capacidad acumulada",   pt = "Capacidade acumulada"},
    total_cost             = {en = "Total Cost",            es = "Costo total",           pt = "Custo total"},

    -- Active power results
    active_power           = {en = "Active Power",          es = "Potencia activa",       pt = "Potência ativa"},
    total_generation       = {en = "Total Generation",      es = "Generación total",      pt = "Geração total"},
    total_gen_deviation    = {en = "Total Generation Deviation", es = "Desviación total de generación", pt = "Desvio total de geração"},
    thermal_deviation      = {en = "Thermal deviation",     es = "Desviación térmica",    pt = "Desvio térmico"},
    hydro_deviation        = {en = "Hydro deviation",       es = "Desviación hidro",      pt = "Desvio hidro"},
    renewable_deviation    = {en = "Renewable deviation",   es = "Desviación renovable",  pt = "Desvio renovável"},
    total_load_shedding    = {en = "Total Load Shedding",   es = "Corte de carga total",  pt = "Corte de carga total"},
    total_circuit_slack    = {en = "Total Circuit Slack",   es = "Holgura total de circuito", pt = "Folga total de circuito"},

    -- Info / Summary cells
    cell_case              = {en = "Case",             es = "Caso",              pt = "Caso"},
    cell_directory_name    = {en = "Directory name",   es = "Nombre del directorio", pt = "Nome do diretório"},
    cell_path              = {en = "Path",             es = "Ruta",              pt = "Caminho"},
    cell_execution_status  = {en = "Execution status", es = "Estado de ejecución",pt = "Status de execução"},
    cell_success           = {en = "Success",          es = "Éxito",             pt = "Sucesso"},
    cell_model             = {en = "Model",            es = "Modelo",            pt = "Modelo"},
    cell_user              = {en = "User",             es = "Usuario",           pt = "Usuário"},
    cell_version           = {en = "Version",          es = "Versión",           pt = "Versão"},
    cell_ID                = {en = "ID",               es = "ID",                pt = "ID"},
    cell_arch              = {en = "Architecture",     es = "Arquitectura",      pt = "Arquitetura"},
    cell_title             = {en = "Title",            es = "Título",            pt = "Título"},
    cell_execution_type    = {en = "Execution type",   es = "Tipo de ejecución", pt = "Tipo de execução"},
    cell_total_processes   = {en = "Total processes",  es = "Procesos totales",  pt = "Processos totais"},
    cell_total_nodes       = {en = "Total nodes",      es = "Nodos totales",     pt = "Nós totais"},
    about_model            = {en = "About the model and environment", es = "Acerca del modelo y el entorno", pt = "Sobre o modelo e o ambiente"},
    about_nodes            = {en = "About the execution nodes",       es = "Acerca de los nodos de ejecución", pt = "Sobre os nós de execução"},
    node_details           = {en = "Node details",     es = "Detalles del nodo", pt = "Detalhes do nó"},
    case_title             = {en = "Case title",       es = "Título del caso",   pt = "Título do caso"},

    -- Horizon and resolution
    hor_resol_exec = {
        en = "Horizon, resolution, and execution options",
        es = "Horizonte, resolución y opciones de ejecución",
        pt = "Horizonte, resolução e opções de execução",
    },
    cell_case_parameters    = {en = "Case parameters",     es = "Parámetros del caso",      pt = "Parâmetros do caso"},
    cell_case_type          = {en = "Case type",           es = "Tipo de caso",             pt = "Tipo de caso"},
    cell_hourly             = {en = "Hourly",              es = "Horaria",                  pt = "Horária"},
    cell_monthly            = {en = "Monthly",             es = "Mensual",                  pt = "Mensal"},
    cell_weekly             = {en = "Weekly",              es = "Semanal",                  pt = "Semanal"},
    cell_hourly_representation   = {en = "Hourly resolution",       es = "Resolución horaria",      pt = "Resolução horária"},
    cell_typicalday_representation = {en = "Typical days resolution", es = "Resolución de días típicos", pt = "Resolução de dias típicos"},
    cell_blocks_resolution  = {en = "Block resolution",    es = "Resolución por bloques",   pt = "Resolução por blocos"},
    cell_initial_date       = {en = "Initial date",        es = "Fecha inicial",            pt = "Data inicial"},
    cell_final_date         = {en = "Final date",          es = "Fecha final",              pt = "Data final"},
    cell_series_representation  = {en = "Series representation",    es = "Representación de series", pt = "Representação de séries"},
    cell_all                = {en = "All",                 es = "Todas",                    pt = "Todas"},
    cell_selected           = {en = "Selected",            es = "Seleccionadas",            pt = "Selecionadas"},
    cell_selected_series    = {en = "Selected series",     es = "Series seleccionadas",     pt = "Séries selecionadas"},
    cell_resolution_representation = {en = "Resolution representation", es = "Representación de resolución", pt = "Representação de resolução"},
    cell_selected_resolution = {en = "Selected resolution", es = "Resolución seleccionada", pt = "Resolução selecionada"},
    cell_selected_systems   = {en = "Selected systems",    es = "Sistemas seleccionados",   pt = "Sistemas selecionados"},

    -- Solution strategy
    solution_strategy = {
        en = "Solution strategy",
        es = "Estrategia de solución",
        pt = "Estratégia de solução",
    },
    cell_solution_method = {
        en = "Solution method",
        es = "Método de solución",
        pt = "Método de solução",
    },
    cell_decomposition      = {en = "Decomposition",          es = "Descomposición",        pt = "Decomposição"},
    cell_heuristic          = {en = "Heuristic",              es = "Heurístico",            pt = "Heurístico"},
    cell_redundancy_analysis = {en = "Redundancy analysis",   es = "Análisis de redundancia",pt = "Análise de redundância"},
    cell_critical_scenario_criterion = {
        en = "Critical scenario criterion",
        es = "Criterio de escenario crítico",
        pt = "Critério de cenário crítico",
    },
    cell_greater_distribution = {
        en = "Greater distribution",
        es = "Mayor distribución",
        pt = "Maior distribuição",
    },
    cell_greater_value      = {en = "Greater value",          es = "Mayor valor",           pt = "Maior valor"},
    cell_greater_covering_overloads = {
        en = "Greater covering overloads",
        es = "Mayor cobertura de sobrecargas",
        pt = "Maior cobertura de sobrecargas",
    },
    cell_num_critical_scenarios = {
        en = "Number of critical scenarios",
        es = "Número de escenarios críticos",
        pt = "Número de cenários críticos",
    },
    cell_mip_rel_gap        = {en = "MIP Relative gap tolerance (%)", es = "Tolerancia MIP de brecha relativa (%)", pt = "Tolerância MIP de gap relativo (%)"},
    cell_mip_cpu_limit      = {en = "MIP CPU Time limit (min)",       es = "Límite de tiempo CPU MIP (min)",       pt = "Limite de tempo de CPU MIP (min)"},
    cell_slack_representation = {
        en = "Slack representation",
        es = "Representación de holgura",
        pt = "Representação de folga",
    },
    cell_load_shedding_slack = {
        en = "Load shedding",
        es = "Corte de carga",
        pt = "Corte de carga",
    },
    cell_circuit_loading_slack = {
        en = "Circuit loading",
        es = "Carga de circuito",
        pt = "Carregamento de circuito",
    },
    cell_slack_penalty      = {en = "Slack penalty (k$/MW)",          es = "Penalidad de holgura (k$/MW)",         pt = "Penalidade de folga (k$/MW)"},
    cell_gen_deviation      = {en = "Generation deviation",           es = "Desviación de generación",             pt = "Desvio de geração"},
    cell_gen_deviation_type = {
        en = "Generation deviation type",
        es = "Tipo de desviación de generación",
        pt = "Tipo de desvio de geração",
    },
    cell_dev_type_generation = {en = "Generation",                    es = "Generación",                           pt = "Geração"},
    cell_dev_type_capacity   = {en = "Capacity",                      es = "Capacidad",                            pt = "Capacidade"},
    cell_dev_type_by_generator = {en = "By generator",                es = "Por generador",                        pt = "Por gerador"},
    cell_gen_deviation_factor = {en = "Generation deviation factor (%)", es = "Factor de desviación de generación (%)", pt = "Fator de desvio de geração (%)"},
    cell_cap_deviation_factor = {en = "Capacity deviation factor (%)",   es = "Factor de desviación de capacidad (%)",  pt = "Fator de desvio de capacidade (%)"},
    cell_circuit_overload   = {en = "Circuit overload",               es = "Sobrecarga de circuito",               pt = "Sobrecarga de circuito"},
    cell_circuit_overload_all = {en = "All",                          es = "Todos",                                pt = "Todos"},
    cell_circuit_overload_selected = {en = "Selected",                es = "Seleccionados",                        pt = "Selecionados"},
    cell_sum_circuit_flow   = {en = "Sum of circuit flow",            es = "Suma de flujo de circuito",            pt = "Soma de fluxo de circuito"},
    cell_contingency        = {en = "Contingency representation",     es = "Representación de contingencias",      pt = "Representação de contingências"},
    cell_yes                = {en = "Yes",                            es = "Sí",                                   pt = "Sim"},
    cell_no                 = {en = "No",                             es = "No",                                   pt = "Não"},

    -- Dimensions
    dimentions              = {en = "Dimensions",                 es = "Dimensiones",        pt = "Dimensões"},
    cell_system             = {en = "Systems",                    es = "Sistemas",           pt = "Sistemas"},
    cell_hydro_plants       = {en = "Hydro plants",               es = "Plantas hidroeléctricas", pt = "Usinas hidrelétricas"},
    cell_thermal_plants     = {en = "Thermal plants",             es = "Plantas térmicas",   pt = "Usinas térmicas"},
    cell_renewable_wind     = {en = "Renewable plants - Wind",    es = "Plantas renovables - Eólicas",  pt = "Usinas renováveis - Eólicas"},
    cell_renewable_solar    = {en = "Renewable plants - Solar",   es = "Plantas renovables - Solares",  pt = "Usinas renováveis - Solares"},
    cell_renewable_small_hydro = {en = "Renewable plants - Small hydro", es = "Plantas renovables - Pequeñas centrales", pt = "Usinas renováveis - Pequenas centrais"},
    cell_renewable_csp      = {en = "Renewable plants - CSP",    es = "Plantas renovables - CSP",      pt = "Usinas renováveis - CSP"},
    cell_renewable_other    = {en = "Renewable plants - Other techs", es = "Plantas renovables - Otras tecnologías", pt = "Usinas renováveis - Outras tecnologias"},
    cell_batteries          = {en = "Batteries",                  es = "Baterías",           pt = "Baterias"},
    cell_buses              = {en = "Buses",                      es = "Barras",             pt = "Barras"},
    cell_power_injections   = {en = "Power injections",           es = "Inyecciones de energía", pt = "Injeções de energia"},
    cell_ac_line            = {en = "AC lines",                   es = "Líneas de CA",       pt = "Linhas de CA"},
    cell_dc_line_dim        = {en = "DC lines",                   es = "Líneas de CC",       pt = "Linhas de CC"},
    cell_dc_link_dim        = {en = "DC links",                   es = "Vínculos DC",        pt = "Vínculos DC"},
    cell_ac_interconnection = {en = "AC Interconnections",        es = "Interconexión AC",   pt = "Interconexão AC"},
    cell_transformers_dim   = {en = "Transformers",               es = "Transformadores",    pt = "Transformadores"},
    cell_3wind_transformers = {en = "Three winding transformers", es = "Transformadores de tres devanados", pt = "Transformadores de três enrolamentos"},
    cell_converters_dim     = {en = "AC-DC converters",           es = "Conversores CA-CC",  pt = "Conversores CA-CC"},
}

---------------------------------------------------------------------------
-- Expression extension: filter by optnet date/series/resolution/system
---------------------------------------------------------------------------

function Expression.select_optnet_date_scn_blcks(self, optnet_data_case, system_codes, select_system, agg_blocks, agg_scenarios)
    local self_selected = self:select_stages_by_year_period(optnet_data_case.initial_year, optnet_data_case.initial_stage, optnet_data_case.final_year, optnet_data_case.final_stage);

    if not self_selected:loaded() then
        return self_selected;
    end

    if self_selected:stage_type() ~= 10 then
        if optnet_data_case.resolution_representation ~= 0 then
            if agg_blocks then
                self_selected = self_selected:aggregate_blocks(optnet_data_case.selected_resolutions);
            else
                self_selected = self_selected:select_blocks(optnet_data_case.selected_resolutions);
            end
        else
            if agg_blocks then
                self_selected = self_selected:aggregate_blocks();
            end
        end
    end

    if optnet_data_case.serie_representation ~= 0 then
        if agg_scenarios then
            self_selected = self_selected:aggregate_scenarios(BY_AVERAGE(), optnet_data_case.selected_series);
        else
            self_selected = self_selected:select_scenarios(optnet_data_case.selected_series);
        end
    else
        if agg_scenarios then
            self_selected = self_selected:aggregate_scenarios(BY_AVERAGE());
        end
    end

    if optnet_data_case.system_representation ~= 0 and select_system then
        local selected_systems_names = system_codes:select_agents_by_code(optnet_data_case.selected_systems):agents();
        self_selected = self_selected:select_agents(Collection.SYSTEM, selected_systems_names);
    end

    return self_selected;
end

---------------------------------------------------------------------------
-- Data loading
---------------------------------------------------------------------------

function load_data(output, lang, optnet_data)
    for case = 1, N_cases do
        local generic          = Generic(case);
        local thermal          = Thermal(case);
        local hydro            = Hydro(case);
        local renewable        = Renewable(case);
        local battery          = Battery(case);
        local bus              = Bus(case);
        local acline           = ACLine(case);
        local transformer      = Transformer(case);
        local three_winding    = ThreeWindingTransformer(case);
        local series_capacitor = SeriesCapacitor(case);
        local dcline           = DCLine(case);
        local dclink           = DCLink(case);
        local flwcontroller    = FlowController(case);
        local system_codes     = System(case).code;

        output.optnet          = output.optnet or {};
        output.optnet[case]    = {};

        -- ── Convergence status ──────────────────────────────────────────
        output.optnet[case].investment_status = generic:load("opn_status_investment")
            :select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, false, false);

        output.optnet[case].operative_status  = generic:load("opn_status_operative")
            :select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, false, false);

        -- ── Solution time (annual totals already in the binary) ─────────
        output.optnet[case].tcpu_investment = generic:load("opn_tcpu_investment"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, true, true)
            :aggregate_agents(BY_SUM(), dictionary.investment_problem[lang]);

        output.optnet[case].tcpu_operative  = generic:load("opn_tcpu_operative"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, true, true)
            :aggregate_agents(BY_SUM(), dictionary.operative_problem[lang]);

        -- ── Circuit loading (max annual loading per element) ────────────
        output.optnet[case].acline_loading       = acline:load("opn_dashboard_acline_flow_loading"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :aggregate_agents(BY_MAX(), dictionary.ac_lines[lang]);

        output.optnet[case].transformer_loading  = transformer:load("opn_dashboard_transformers_flow_loading"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :aggregate_agents(BY_MAX(), dictionary.transformers[lang]);

        output.optnet[case].three_winding_loading = three_winding:load("opn_dashboard_threewindingtransformers_flow_loading"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :aggregate_agents(BY_MAX(), dictionary.three_winding_transformers[lang]);

        output.optnet[case].series_cap_loading   = series_capacitor:load("opn_dashboard_seriescapacitor_flow_loading"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :aggregate_agents(BY_MAX(), dictionary.series_capacitors[lang]);

        -- ── Redundancy (max annual violation per element) ───────────────
        output.optnet[case].acline_redundancy       = acline:load("opn_dashboard_acline_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].transformer_redundancy  = transformer:load("opn_dashboard_transformers_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].three_winding_redundancy = three_winding:load("opn_dashboard_threewindingtransformers_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].series_cap_redundancy   = series_capacitor:load("opn_dashboard_seriescapacitor_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].flow_ctrl_redundancy    = flwcontroller:load("opn_dashboard_flowcontroller_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].dc_line_redundancy      = dcline:load("opn_dashboard_dcline_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].converter_redundancy    = generic:load("opn_dashboard_converter_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        output.optnet[case].dc_link_redundancy      = dclink:load("opn_dashboard_dclink_redundancy"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, false, false)
            :aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX())
            :aggregate_stages(BY_MAX(), Profile.PER_YEAR)
            :remove_zeros();

        -- ── Investment results ──────────────────────────────────────────
        output.optnet[case].investment_capacity = generic:load("opn_dashboard_investment_capacity"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, true, true)
            :aggregate_stages(BY_SUM(), Profile.PER_YEAR);

        output.optnet[case].investment_cost     = generic:load("opn_dashboard_investment_cost"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, false, true, true)
            :aggregate_stages(BY_SUM(), Profile.PER_YEAR);

        -- ── Active power: generation ────────────────────────────────────
        output.optnet[case].thermal_generation   = thermal:load("opn_pter"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.thermal[lang]);

        output.optnet[case].hydro_generation     = hydro:load("opn_phdr"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.hydro[lang]);

        output.optnet[case].renewable_generation = renewable:load("opn_pgnd"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.renewable[lang]);

        output.optnet[case].battery_generation   = battery:load("opn_pbat"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.battery[lang]);

        output.optnet[case].active_load          = bus:load("opn_ploa"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.active_load[lang]);

        -- ── Active power: generation deviation ─────────────────────────
        output.optnet[case].thermal_deviation   = thermal:load("opn_dter"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.thermal_deviation[lang]);

        output.optnet[case].hydro_deviation     = hydro:load("opn_dhdr"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.hydro_deviation[lang]);

        output.optnet[case].renewable_deviation = renewable:load("opn_dgnd"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.renewable_deviation[lang]);

        -- ── Load shedding ───────────────────────────────────────────────
        output.optnet[case].load_shedding = bus:load("opn_lshd"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.total_load_shedding[lang]);

        -- ── Circuit slack ───────────────────────────────────────────────
        output.optnet[case].acline_slack       = acline:load("opn_acline_slack"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.ac_lines[lang]);

        output.optnet[case].transformer_slack  = transformer:load("opn_transformer_slack"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.transformers[lang]);

        output.optnet[case].three_winding_slack = three_winding:load("opn_threewindingtransformer_slack"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.three_winding_transformers[lang]);

        output.optnet[case].series_cap_slack   = series_capacitor:load("opn_seriescapacitor_slack"):select_optnet_date_scn_blcks(optnet_data[case], system_codes, true, true, true)
            :aggregate_agents(BY_SUM(), dictionary.series_capacitors[lang]);
    end
end

---------------------------------------------------------------------------
-- Tab methods: Solution Quality
---------------------------------------------------------------------------

function Tab.add_investment_status_chart(self, n_cases, Lang, output)
    local options = {
        yLabel = dictionary.scenarios_blocks[Lang],
        xLabel = dictionary.stages[Lang],
        showInLegend = true,
        dataClasses = {
            { color = "#8ACE7E", from = -0.1, to =  0.1, name = dictionary.no_expansion_required[Lang] },
            { color = "#4E79A7", from =  0.9, to =  1.1, name = dictionary.heuristic_solution[Lang] },
            { color = "#9B59B6", from =  1.9, to =  2.1, name = dictionary.decomposition_solution[Lang] },
            { color = "#FF796A", from =  2.9, to =  3.1, name = dictionary.solution_with_slack_violation[Lang] },
        }
    };

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.convergence_investment_status[Lang], Generic(case):cloudname());
            chart:add_heatmap(output.optnet[case].investment_status, options);
            chart:horizontal_legend();
            self:push(chart);
        end
    else
        local chart = Chart(dictionary.convergence_investment_status[Lang]);
        chart:add_heatmap(output.optnet[1].investment_status, options);
        chart:horizontal_legend();
        self:push(chart);
    end
end

function Tab.add_operative_status_chart(self, n_cases, Lang, output)
    local options = {
        yLabel = dictionary.scenarios_blocks[Lang],
        xLabel = dictionary.stages[Lang],
        showInLegend = true,
        dataClasses = {
            { color = "#7A7A7A", from = -1.1, to = -0.9, name = dictionary.case_not_solved[Lang] },
            { color = "#8ACE7E", from = -0.1, to =  0.1, name = dictionary.optimal_solution_found[Lang] },
            { color = "#FF796A", from =  1.9, to =  2.1, name = dictionary.optimal_solution_not_found[Lang] },
        }
    };

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.convergence_operative_status[Lang], Generic(case):cloudname());
            chart:add_heatmap(output.optnet[case].operative_status, options);
            chart:horizontal_legend();
            self:push(chart);
        end
    else
        local chart = Chart(dictionary.convergence_operative_status[Lang]);
        chart:add_heatmap(output.optnet[1].operative_status, options);
        chart:horizontal_legend();
        self:push(chart);
    end
end

function Tab.add_solution_time_chart(self, n_cases, Lang, output)
    local show_in_legend = n_cases > 1;

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.total_cpu_time[Lang], Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column_stacking(output.optnet[case].tcpu_investment,
                { color = table_element_color.investment, showInLegend = show_in_legend });
            chart:add_column_stacking(output.optnet[case].tcpu_operative,
                { color = table_element_color.operative,  showInLegend = show_in_legend });
            self:push(chart);
        end
    else
        local chart = Chart(dictionary.total_cpu_time[Lang]);
        chart:horizontal_legend();
        chart:add_column_stacking(output.optnet[1].tcpu_investment, { color = table_element_color.investment });
        chart:add_column_stacking(output.optnet[1].tcpu_operative,  { color = table_element_color.operative  });
        self:push(chart);
    end
end

function Tab.add_circuit_loading_chart(self, n_cases, Lang, output)
    local has_data = false;

    if n_cases > 1 then
        for case = 1, n_cases do
            local loading = concatenate(
                output.optnet[case].acline_loading,
                output.optnet[case].transformer_loading,
                output.optnet[case].three_winding_loading,
                output.optnet[case].series_cap_loading
            ):remove_zeros();

            local chart = Chart(dictionary.circuit_flow_loading[Lang], Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column(loading:select_agents(dictionary.ac_lines[Lang]),
                { color = table_element_color.ac_line });
            chart:add_column(loading:select_agents(dictionary.transformers[Lang]),
                { color = table_element_color.transformer });
            chart:add_column(loading:select_agents(dictionary.three_winding_transformers[Lang]),
                { color = table_element_color.three_winding });
            chart:add_column(loading:select_agents(dictionary.series_capacitors[Lang]),
                { color = table_element_color.series_capacitor });

            if #chart > 0 then
                self:push(chart);
                has_data = true;
            end
        end
    else
        --local loading = concatenate(
        --    output.optnet[1].acline_loading,
        --    output.optnet[1].transformer_loading,
        --    output.optnet[1].three_winding_loading,
        --    output.optnet[1].series_cap_loading
        --):remove_zeros();

        local chart = Chart(dictionary.circuit_flow_loading[Lang]);
        chart:horizontal_legend();
        chart:add_column(output.optnet[1].acline_loading:remove_zeros(),
            { color = table_element_color.ac_line });
        chart:add_column(output.optnet[1].transformer_loading:remove_zeros(),
            { color = table_element_color.transformer });
        chart:add_column(output.optnet[1].three_winding_loading:remove_zeros(),
            { color = table_element_color.three_winding });
        chart:add_column(output.optnet[1].series_cap_loading:remove_zeros(),
            { color = table_element_color.series_capacitor });

        if #chart > 0 then
            self:push(chart);
            has_data = true;
        end
    end

    return has_data;
end

function Tab.add_redundancy_chart(self, n_cases, Lang, output)
    local has_data = false;

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.check_redundancy[Lang], Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column(output.optnet[case].acline_redundancy,
                { color = table_element_color.ac_line });
            chart:add_column(output.optnet[case].transformer_redundancy,
                { color = table_element_color.transformer });
            chart:add_column(output.optnet[case].three_winding_redundancy,
                { color = table_element_color.three_winding });
            chart:add_column(output.optnet[case].series_cap_redundancy,
                { color = table_element_color.series_capacitor });
            chart:add_column(output.optnet[case].flow_ctrl_redundancy,
                { color = table_element_color.flow_controller });
            chart:add_column(output.optnet[case].dc_line_redundancy,
                { color = table_element_color.dc_line });
            chart:add_column(output.optnet[case].converter_redundancy,
                { color = table_element_color.converter });
            chart:add_column(output.optnet[case].dc_link_redundancy,
                { color = table_element_color.dc_link });

            if #chart > 0 then
                self:push(chart);
                has_data = true;
            end
        end
    else
        local chart = Chart(dictionary.check_redundancy[Lang]);
        chart:horizontal_legend();
        chart:add_column(output.optnet[1].acline_redundancy,
            { color = table_element_color.ac_line });
        chart:add_column(output.optnet[1].transformer_redundancy,
            { color = table_element_color.transformer });
        chart:add_column(output.optnet[1].three_winding_redundancy,
            { color = table_element_color.three_winding });
        chart:add_column(output.optnet[1].series_cap_redundancy,
            { color = table_element_color.series_capacitor });
        chart:add_column(output.optnet[1].flow_ctrl_redundancy,
            { color = table_element_color.flow_controller });
        chart:add_column(output.optnet[1].dc_line_redundancy,
            { color = table_element_color.dc_line });
        chart:add_column(output.optnet[1].converter_redundancy,
            { color = table_element_color.converter });
        chart:add_column(output.optnet[1].dc_link_redundancy,
            { color = table_element_color.dc_link });

        if #chart > 0 then
            self:push(chart);
            has_data = true;
        end
    end

    return has_data;
end

function Tab.Solution_Quality(self, n_cases, Lang, output)
    self:set_icon("alert-triangle");

    local subTab_conv = SubTab(dictionary.convergence[Lang]);
    subTab_conv:push("# " .. dictionary.convergence_investment_status[Lang]);
    subTab_conv:add_investment_status_chart(n_cases, Lang, output);
    subTab_conv:push("# " .. dictionary.convergence_operative_status[Lang]);
    subTab_conv:add_operative_status_chart(n_cases, Lang, output);
    self:push(subTab_conv);

    local subTab_time = SubTab(dictionary.solution_time[Lang]);
    subTab_time:add_solution_time_chart(n_cases, Lang, output);
    self:push(subTab_time);

    local subTab_loading = SubTab(dictionary.circuit_loading[Lang]);
    subTab_loading:add_circuit_loading_chart(n_cases, Lang, output);
    if #subTab_loading > 0 then
        self:push(subTab_loading);
    end

    local subTab_redund = SubTab(dictionary.check_redundancy[Lang]);
    subTab_redund:add_redundancy_chart(n_cases, Lang, output);
    self:push(subTab_redund);
end

---------------------------------------------------------------------------
-- Tab methods: Results
---------------------------------------------------------------------------

function Tab.add_investment_charts(self, n_cases, Lang, output)
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart_cap = Chart(dictionary.accumulated_capacity[Lang] .. " (MW)", Generic(case):cloudname());
            chart_cap:horizontal_legend();
            chart_cap:add_column_stacking(output.optnet[case].investment_capacity:remove_zeros(),
                { showInLegend = true, color = table_case_color[case] });

            local chart_cost = Chart(dictionary.total_cost[Lang] .. " (k$)", Generic(case):cloudname());
            chart_cost:horizontal_legend();
            chart_cost:add_column_stacking(output.optnet[case].investment_cost:remove_zeros(),
                { showInLegend = true, color = table_case_color[case] });

            if #chart_cap > 0 then self:push(chart_cap); end
            if #chart_cost > 0 then self:push(chart_cost) end
        end
    else
        local chart_cap = Chart(dictionary.accumulated_capacity[Lang] .. " (MW)");
        chart_cap:horizontal_legend();
        local investment_capacity = output.optnet[1].investment_capacity:remove_zeros();
        chart_cap:add_column(investment_capacity:select_agent("AC Line"), {color = table_element_color.ac_line});
        chart_cap:add_column(investment_capacity:select_agent("Transformer"), {color = table_element_color.transformer});
        chart_cap:add_column(investment_capacity:select_agent("Three Winding Transformer"), {color = table_element_color.three_winding});
        chart_cap:add_column(investment_capacity:select_agent("Series Capacitor"), {color = table_element_color.series_capacitor});
        chart_cap:add_column(investment_capacity:select_agent("Flow Controller"), {color = table_element_color.flow_controller});
        chart_cap:add_column(investment_capacity:select_agent("DC Link"), {color = table_element_color.dc_link});

        local chart_cost = Chart(dictionary.total_cost[Lang] .. " (k$)");
        chart_cost:horizontal_legend();
        local investment_cost = output.optnet[1].investment_cost:remove_zeros();
        chart_cost:add_column(investment_cost:select_agent("AC Line"), {color = table_element_color.ac_line});
        chart_cost:add_column(investment_cost:select_agent("Transformer"), {color = table_element_color.transformer});
        chart_cost:add_column(investment_cost:select_agent("Three Winding Transformer"), {color = table_element_color.three_winding});
        chart_cost:add_column(investment_cost:select_agent("Series Capacitor"), {color = table_element_color.series_capacitor});
        chart_cost:add_column(investment_cost:select_agent("Flow Controller"), {color = table_element_color.flow_controller});
        chart_cost:add_column(investment_cost:select_agent("DC Link"), {color = table_element_color.dc_link});

        if #chart_cap  > 0 then self:push(chart_cap)  end
        if #chart_cost > 0 then self:push(chart_cost) end
    end
end

function Tab.add_total_generation_chart(self, n_cases, Lang, output)
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.total_generation[Lang] .. " (MW)", Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column_stacking(output.optnet[case].thermal_generation,   { color = table_techtype_color.thermal   });
            chart:add_column_stacking(output.optnet[case].hydro_generation,     { color = table_techtype_color.hydro     });
            chart:add_column_stacking(output.optnet[case].renewable_generation, { color = table_techtype_color.renewable });
            chart:add_column_stacking(output.optnet[case].battery_generation,   { color = table_techtype_color.battery   });
            chart:add_line(output.optnet[case].active_load, { color = "black", lineWidth = 2, dashStyle = "ShortDash" });
            self:push(chart);
        end
    else
        local chart = Chart(dictionary.total_generation[Lang] .. " (MW)");
        chart:horizontal_legend();
        chart:add_column_stacking(output.optnet[1].thermal_generation,   { color = table_techtype_color.thermal   });
        chart:add_column_stacking(output.optnet[1].hydro_generation,     { color = table_techtype_color.hydro     });
        chart:add_column_stacking(output.optnet[1].renewable_generation, { color = table_techtype_color.renewable });
        chart:add_column_stacking(output.optnet[1].battery_generation,   { color = table_techtype_color.battery   });
        chart:add_line(output.optnet[1].active_load, { color = "black", lineWidth = 2, dashStyle = "ShortDash" });
        self:push(chart);
    end
end

function Tab.add_generation_deviation_chart(self, n_cases, Lang, output)
    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.total_gen_deviation[Lang] .. " (MW)", Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column_stacking(output.optnet[case].thermal_deviation,   { color = table_techtype_color.thermal   });
            chart:add_column_stacking(output.optnet[case].hydro_deviation,     { color = table_techtype_color.hydro     });
            chart:add_column_stacking(output.optnet[case].renewable_deviation, { color = table_techtype_color.renewable });
            if #chart > 0 then self:push(chart) end
        end
    else
        local chart = Chart(dictionary.total_gen_deviation[Lang] .. " (MW)");
        chart:horizontal_legend();
        chart:add_column_stacking(output.optnet[1].thermal_deviation,   { color = table_techtype_color.thermal   });
        chart:add_column_stacking(output.optnet[1].hydro_deviation,     { color = table_techtype_color.hydro     });
        chart:add_column_stacking(output.optnet[1].renewable_deviation, { color = table_techtype_color.renewable });
        if #chart > 0 then self:push(chart) end
    end
end

function Tab.add_load_shedding_chart(self, n_cases, Lang, output)
    local has_data = false;
    local show_in_legend = n_cases > 1;

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.total_load_shedding[Lang] .. " (MW)", Generic(case):cloudname());
            chart:add_column(output.optnet[case].load_shedding,
                { color = table_techtype_color.deficit, showInLegend = show_in_legend });
            if #chart > 0 then
                self:push(chart);
                has_data = true;
            end
        end
    else
        local chart = Chart(dictionary.total_load_shedding[Lang] .. " (MW)");
        chart:add_column(output.optnet[1].load_shedding,
            { color = table_techtype_color.deficit });
        if #chart > 0 then
            self:push(chart);
            has_data = true;
        end
    end

    return has_data;
end

function Tab.add_circuit_slack_chart(self, n_cases, Lang, output)
    local has_data = false;

    if n_cases > 1 then
        for case = 1, n_cases do
            local chart = Chart(dictionary.total_circuit_slack[Lang] .. " (MW)", Generic(case):cloudname());
            chart:horizontal_legend();
            chart:add_column_stacking(output.optnet[case].acline_slack,
                { color = table_element_color.ac_line });
            chart:add_column_stacking(output.optnet[case].transformer_slack,
                { color = table_element_color.transformer });
            chart:add_column_stacking(output.optnet[case].three_winding_slack,
                { color = table_element_color.three_winding });
            chart:add_column_stacking(output.optnet[case].series_cap_slack,
                { color = table_element_color.series_capacitor });
            if #chart > 0 then
                self:push(chart);
                has_data = true;
            end
        end
    else
        local chart = Chart(dictionary.total_circuit_slack[Lang] .. " (MW)");
        chart:horizontal_legend();
        chart:add_column_stacking(output.optnet[1].acline_slack,
            { color = table_element_color.ac_line });
        chart:add_column_stacking(output.optnet[1].transformer_slack,
            { color = table_element_color.transformer });
        chart:add_column_stacking(output.optnet[1].three_winding_slack,
            { color = table_element_color.three_winding });
        chart:add_column_stacking(output.optnet[1].series_cap_slack,
            { color = table_element_color.series_capacitor });
        if #chart > 0 then
            self:push(chart);
            has_data = true;
        end
    end

    return has_data;
end

function Tab.Results(self, n_cases, Lang, output, slack_representation)
    self:set_icon("line-chart");

    local subTab_inv = SubTab(dictionary.investment[Lang]);
    subTab_inv:add_investment_charts(n_cases, Lang, output);
    self:push(subTab_inv);

    local subTab_ap = SubTab(dictionary.active_power[Lang]);
    subTab_ap:push("# " .. dictionary.total_generation[Lang]);
    subTab_ap:add_total_generation_chart(n_cases, Lang, output);
    subTab_ap:push("# " .. dictionary.total_gen_deviation[Lang]);
    subTab_ap:add_generation_deviation_chart(n_cases, Lang, output);
    if slack_representation == 1 then
        subTab_ap:push("# " .. dictionary.total_load_shedding[Lang]);
        subTab_ap:add_load_shedding_chart(n_cases, Lang, output);
    elseif slack_representation == 2 then
        subTab_ap:push("# " .. dictionary.total_circuit_slack[Lang]);
        subTab_ap:add_circuit_slack_chart(n_cases, Lang, output);
    end
    self:push(subTab_ap);
end

---------------------------------------------------------------------------
-- Tab method: Info / Summary
---------------------------------------------------------------------------

function Tab.create_summary(self, n_cases, Lang, info_struct, optnet_data)
    self:set_icon("info");

    local label       = {};
    local path        = {};
    local description = {};

    for i = 1, n_cases do
        table.insert(label,       Generic(i):cloudname());
        table.insert(path,        Generic(i):path());
        table.insert(description, Study(i):get_parameter("Descricao", ""));
    end

    local case            = dictionary.cell_case[Lang];
    local directory_name  = dictionary.cell_directory_name[Lang];
    local path_cell       = dictionary.cell_path[Lang];
    local execution_status = dictionary.cell_execution_status[Lang];
    local model_cell      = dictionary.cell_model[Lang];
    local user_cell       = dictionary.cell_user[Lang];
    local version_cell    = dictionary.cell_version[Lang];
    local id_cell         = dictionary.cell_ID[Lang];
    local arch_cell       = dictionary.cell_arch[Lang];
    local title_cell      = dictionary.cell_title[Lang];
    local exec_type_cell  = dictionary.cell_execution_type[Lang];
    local total_proc_cell = dictionary.cell_total_processes[Lang];
    local total_nodes_cell = dictionary.cell_total_nodes[Lang];

    -- Case summary
    if n_cases == 1 then
        self:push("| " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        self:push("|:--------------:|:----:|:----------------:|");
        for i = 1, n_cases do
            local exe_status_str = dictionary.cell_success[Lang];
            if info_struct[i].status > 0 then exe_status_str = "FAIL"; end
            self:push("| " .. label[i] .. " | " .. path[i] .. " | " .. exe_status_str .. " |");
        end
    else
        self:push("| " .. case .. " | " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        self:push("|:----:|:--------------:|:----:|:----------------:|");
        for i = 1, n_cases do
            local exe_status_str = dictionary.cell_success[Lang];
            if info_struct[i].status > 0 then exe_status_str = "FAIL"; end
            self:push("| " .. i .. " | " .. label[i] .. " | " .. path[i] .. " | " .. exe_status_str .. " |");
        end
    end

    -- About the model
    self:push("## " .. dictionary.about_model[Lang]);
    if n_cases == 1 then
        self:push("| " .. model_cell .. " | " .. user_cell .. " | " .. version_cell .. " | " .. id_cell .. " | " .. arch_cell .. " |");
        self:push("|:-------:|:-------:|:-------:|:-------:|:-------:|");
        for i = 1, n_cases do
            self:push("| " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " | " .. info_struct[i].arch .. " |");
        end
    else
        self:push("| " .. case .. " | " .. model_cell .. " | " .. user_cell .. " | " .. version_cell .. " | " .. id_cell .. " | " .. arch_cell .. " |");
        self:push("|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " | " .. info_struct[i].arch .. " |");
        end
    end

    -- About the execution nodes
    self:push("## " .. dictionary.about_nodes[Lang]);
    if n_cases == 1 then
        self:push("| " .. exec_type_cell .. " | " .. total_nodes_cell .. " | " .. total_proc_cell .. " |");
        self:push("|:-----------------:|:-----------------:|:-----------------:|");
        self:push("| " .. info_struct[1].processing_type .. " | " .. info_struct[1].total_nodes .. " | " .. info_struct[1].total_processes .. " |");
    else
        self:push("| " .. case .. " | " .. exec_type_cell .. " | " .. total_nodes_cell .. " | " .. total_proc_cell .. " |");
        self:push("|:----:|:-----------------:|:-----------------:|:-----------------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. info_struct[i].processing_type .. " | " .. info_struct[i].total_nodes .. " | " .. info_struct[i].total_processes .. " |");
        end
    end

    -- Case title
    self:push("## " .. dictionary.case_title[Lang]);
    if n_cases == 1 then
        self:push("| " .. title_cell .. " |");
        self:push("|:-----------:|");
        for i = 1, n_cases do
            self:push("| " .. description[i] .. " |");
        end
    else
        self:push("| " .. case .. " | " .. title_cell .. " |");
        self:push("|:----:|:-----------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. description[i] .. " |");
        end
    end

    -- Horizon, resolution, execution options
    self:push("## " .. dictionary.hor_resol_exec[Lang]);

    local header_str      = "| " .. dictionary.cell_case_parameters[Lang];
    local sep_str         = "|---------------";
    local case_type_str   = "| " .. dictionary.cell_case_type[Lang];
    local block_str       = "| " .. dictionary.cell_blocks_resolution[Lang];
    local hrep_str        = "| " .. dictionary.cell_hourly_representation[Lang];
    local typday_str      = "| " .. dictionary.cell_typicalday_representation[Lang];
    local ini_date_str    = "| " .. dictionary.cell_initial_date[Lang];
    local fin_date_str    = "| " .. dictionary.cell_final_date[Lang];
    local ser_repr_str    = "| " .. dictionary.cell_selected_series[Lang];
    local res_repr_str    = "| " .. dictionary.cell_selected_resolution[Lang];
    local sys_repr_str    = "| " .. dictionary.cell_selected_systems[Lang];

    for i = 1, n_cases do
        local stage_type = dictionary.cell_monthly[Lang];
        if Study(i):stage_type() == 1 then stage_type = dictionary.cell_weekly[Lang]; end
        case_type_str = case_type_str .. " | " .. stage_type;

        local block_rep = "❌";
        if Study(i):get_parameter("SIMB", -1) == 1 then block_rep = "✔️"; end
        block_str = block_str .. " | " .. block_rep;

        local hour_rep = "❌";
        if Study(i):get_parameter("SIMH", -1) == 2 then hour_rep = "✔️"; end
        hrep_str = hrep_str .. " | " .. hour_rep;

        local typday_rep = "❌";
        if Study(i):get_parameter("TDAY", -1) == 1 then typday_rep = "✔️"; end
        typday_str = typday_str .. " | " .. typday_rep;

        header_str  = header_str  .. " | " .. Generic(i):username();
        ini_date_str = ini_date_str .. " | " .. optnet_data[i].initial_stage .. "/" .. optnet_data[i].initial_year;
        fin_date_str = fin_date_str  .. " | " .. optnet_data[i].final_stage   .. "/" .. optnet_data[i].final_year;

        local sel_series = dictionary.cell_all[Lang];
        if #optnet_data[i].selected_series > 0 then
            sel_series = "";
            for j = 1, #optnet_data[i].selected_series do
                sel_series = sel_series .. optnet_data[i].selected_series[j] .. ",";
            end
            sel_series = sel_series:sub(1, -2);
        end
        ser_repr_str = ser_repr_str .. " | " .. sel_series;

        local sel_res = dictionary.cell_all[Lang];
        if #optnet_data[i].selected_resolutions > 0 then
            sel_res = "";
            for j = 1, #optnet_data[i].selected_resolutions do
                sel_res = sel_res .. optnet_data[i].selected_resolutions[j] .. ",";
            end
            sel_res = sel_res:sub(1, -2);
        end
        res_repr_str = res_repr_str .. " | " .. sel_res;

        local sel_sys = dictionary.cell_all[Lang];
        if #optnet_data[i].selected_systems > 0 then
            sel_sys = "";
            for j = 1, #optnet_data[i].selected_systems do
                sel_sys = sel_sys .. optnet_data[i].selected_systems[j] .. ",";
            end
            sel_sys = sel_sys:sub(1, -2);
        end
        sys_repr_str = sys_repr_str .. " | " .. sel_sys;

        sep_str = sep_str .. "|-----------";

        if i == n_cases then
            header_str   = header_str     .. "|";
            sep_str      = sep_str        .. "|";
            case_type_str = case_type_str .. "|";
            block_str    = block_str      .. "|";
            hrep_str     = hrep_str       .. "|";
            typday_str   = typday_str     .. "|";
            ini_date_str = ini_date_str   .. "|";
            fin_date_str = fin_date_str   .. "|";
            ser_repr_str = ser_repr_str   .. "|";
            res_repr_str = res_repr_str   .. "|";
            sys_repr_str = sys_repr_str   .. "|";
        end
    end

    self:push(header_str);
    self:push(sep_str);
    self:push(case_type_str);
    self:push(block_str);
    self:push(hrep_str);
    self:push(typday_str);
    self:push(ini_date_str);
    self:push(fin_date_str);
    self:push(ser_repr_str);
    self:push(res_repr_str);
    self:push(sys_repr_str);

    -- Solution strategy
    self:push("## " .. dictionary.solution_strategy[Lang]);

    local strat_header = "| " .. dictionary.solution_strategy[Lang];
    local strat_sep    = "|---------------";

    local sol_method_str   = "| " .. dictionary.cell_solution_method[Lang];
    local crit_scn_str     = "| " .. dictionary.cell_critical_scenario_criterion[Lang];
    local num_crit_str     = "| " .. dictionary.cell_num_critical_scenarios[Lang];
    local mip_gap_str      = "| " .. dictionary.cell_mip_rel_gap[Lang];
    local mip_cpu_str      = "| " .. dictionary.cell_mip_cpu_limit[Lang];
    local slack_repr_str   = "| " .. dictionary.cell_slack_representation[Lang];
    local slack_pen_str    = "| " .. dictionary.cell_slack_penalty[Lang];
    local gen_dev_str      = "| " .. dictionary.cell_gen_deviation[Lang];
    local gen_dev_type_str = "| " .. dictionary.cell_gen_deviation_type[Lang];
    local gen_dev_fac_str  = "| " .. dictionary.cell_gen_deviation_factor[Lang];
    local cap_dev_fac_str  = "| " .. dictionary.cell_cap_deviation_factor[Lang];
    local circ_ovl_str     = "| " .. dictionary.cell_circuit_overload[Lang];
    local sum_circ_str     = "| " .. dictionary.cell_sum_circuit_flow[Lang];
    local contingency_str  = "| " .. dictionary.cell_contingency[Lang];

    for i = 1, n_cases do
        strat_header = strat_header .. " | " .. Generic(i):username();
        strat_sep    = strat_sep    .. "|-----------";

        -- Solution method
        local sol_method = optnet_data[i].solution_method;
        local sol_method_val = "-";
        if sol_method == 1 then sol_method_val = dictionary.cell_decomposition[Lang];
        elseif sol_method == 2 then sol_method_val = dictionary.cell_heuristic[Lang];
        elseif sol_method == 5 then sol_method_val = dictionary.cell_redundancy_analysis[Lang]; end
        sol_method_str = sol_method_str .. " | " .. sol_method_val;

        -- Critical scenario criterion
        local crit_scn = optnet_data[i].critical_scenario_criterion;
        local crit_scn_val = "-";
        if crit_scn == 1 then crit_scn_val = dictionary.cell_greater_distribution[Lang];
        elseif crit_scn == 2 then crit_scn_val = dictionary.cell_greater_value[Lang];
        elseif crit_scn == 3 then crit_scn_val = dictionary.cell_greater_covering_overloads[Lang]; end
        crit_scn_str = crit_scn_str .. " | " .. crit_scn_val;

        num_crit_str   = num_crit_str   .. " | " .. tostring(optnet_data[i].num_critical_scenarios);
        mip_gap_str    = mip_gap_str    .. " | " .. tostring(optnet_data[i].mip_rel_gap);
        mip_cpu_str    = mip_cpu_str    .. " | " .. tostring(optnet_data[i].mip_cpu_limit);

        -- Slack representation
        local slack_repr = optnet_data[i].slack_representation;
        local slack_repr_val = "-";
        if slack_repr == 1 then slack_repr_val = dictionary.cell_load_shedding_slack[Lang];
        elseif slack_repr == 2 then slack_repr_val = dictionary.cell_circuit_loading_slack[Lang]; end
        slack_repr_str = slack_repr_str .. " | " .. slack_repr_val;

        slack_pen_str  = slack_pen_str  .. " | " .. tostring(optnet_data[i].slack_penalty);

        -- Generation deviation
        local gen_dev_flag = optnet_data[i].gen_deviation;
        local gen_dev_val  = "❌";
        if gen_dev_flag then
            gen_dev_val  = "✔️";
        end
        gen_dev_str = gen_dev_str .. " | " .. gen_dev_val;

        -- Generation deviation type (only when flag is active)
        local gen_dev_type_val = "-";
        if gen_dev_flag then
            local t = optnet_data[i].gen_deviation_type;
            if t == 1 then gen_dev_type_val = dictionary.cell_dev_type_generation[Lang];
            elseif t == 2 then gen_dev_type_val = dictionary.cell_dev_type_capacity[Lang];
            elseif t == 3 then gen_dev_type_val = dictionary.cell_dev_type_by_generator[Lang]; end
        end
        gen_dev_type_str = gen_dev_type_str .. " | " .. gen_dev_type_val;

        local gen_dev_fac_val = gen_dev_flag and tostring(optnet_data[i].gen_deviation_factor) or "-";
        local cap_dev_fac_val = gen_dev_flag and tostring(optnet_data[i].cap_deviation_factor) or "-";
        gen_dev_fac_str = gen_dev_fac_str .. " | " .. gen_dev_fac_val;
        cap_dev_fac_str = cap_dev_fac_str .. " | " .. cap_dev_fac_val;

        -- Circuit overload
        local circ_ovl = optnet_data[i].circuit_overload;
        local circ_ovl_val = "-";
        if circ_ovl == 1 then circ_ovl_val = dictionary.cell_circuit_overload_all[Lang];
        elseif circ_ovl == 2 then circ_ovl_val = dictionary.cell_circuit_overload_selected[Lang]; end
        circ_ovl_str = circ_ovl_str .. " | " .. circ_ovl_val;

        local sum_circ_val = "❌";
        if optnet_data[i].sum_circuit_flow then
            sum_circ_val = "✔️";
        end
        sum_circ_str = sum_circ_str .. " | " .. sum_circ_val;

        local contingency_val = "❌";
        if optnet_data[i].contingency then
            contingency_val = "✔️";
        end
        contingency_str = contingency_str .. " | " .. contingency_val;

        if i == n_cases then
            strat_header    = strat_header      .. "|";
            strat_sep       = strat_sep         .. "|";
            sol_method_str  = sol_method_str    .. "|";
            crit_scn_str    = crit_scn_str      .. "|";
            num_crit_str    = num_crit_str      .. "|";
            mip_gap_str     = mip_gap_str       .. "|";
            mip_cpu_str     = mip_cpu_str       .. "|";
            slack_repr_str  = slack_repr_str    .. "|";
            slack_pen_str   = slack_pen_str     .. "|";
            gen_dev_str     = gen_dev_str       .. "|";
            gen_dev_type_str = gen_dev_type_str .. "|";
            gen_dev_fac_str = gen_dev_fac_str   .. "|";
            cap_dev_fac_str = cap_dev_fac_str   .. "|";
            circ_ovl_str    = circ_ovl_str      .. "|";
            sum_circ_str    = sum_circ_str      .. "|";
            contingency_str = contingency_str   .. "|";
        end
    end

    self:push(strat_header);
    self:push(strat_sep);
    self:push(sol_method_str);
    self:push(crit_scn_str);
    self:push(num_crit_str);
    self:push(mip_gap_str);
    self:push(mip_cpu_str);
    self:push(slack_repr_str);
    self:push(slack_pen_str);
    self:push(gen_dev_str);
    self:push(gen_dev_type_str);
    self:push(gen_dev_fac_str);
    self:push(cap_dev_fac_str);
    self:push(circ_ovl_str);
    self:push(sum_circ_str);
    self:push(contingency_str);

    -- Dimensions
    self:push("## " .. dictionary.dimentions[Lang]);

    local dim_header        = "| " .. dictionary.cell_case_parameters[Lang];
    local dim_sep           = "|---------------";
    local sys_str           = "| " .. dictionary.cell_system[Lang];
    local hydro_str         = "| " .. dictionary.cell_hydro_plants[Lang];
    local thermal_str       = "| " .. dictionary.cell_thermal_plants[Lang];
    local renw_w_str        = "| " .. dictionary.cell_renewable_wind[Lang];
    local renw_s_str        = "| " .. dictionary.cell_renewable_solar[Lang];
    local renw_sh_str       = "| " .. dictionary.cell_renewable_small_hydro[Lang];
    local renw_csp_str      = "| " .. dictionary.cell_renewable_csp[Lang];
    local renw_oth_str      = "| " .. dictionary.cell_renewable_other[Lang];
    local battery_str       = "| " .. dictionary.cell_batteries[Lang];
    local bus_str           = "| " .. dictionary.cell_buses[Lang];
    local pinj_str          = "| " .. dictionary.cell_power_injections[Lang];
    local acline_str        = "| " .. dictionary.cell_ac_line[Lang];
    local transformer_str   = "| " .. dictionary.cell_transformers_dim[Lang];
    local three_wind_str    = "| " .. dictionary.cell_3wind_transformers[Lang];
    local dc_line_str       = "| " .. dictionary.cell_dc_line_dim[Lang];
    local dc_link_str       = "| " .. dictionary.cell_ac_interconnection[Lang];
    --local converter_str     = "| " .. dictionary.cell_converters_dim[Lang];

    for i = 1, n_cases do
        dim_header    = dim_header    .. " | " .. Generic(i):username();
        dim_sep       = dim_sep       .. "|-----------";

        sys_str       = sys_str       .. " | " .. tostring(#System(i):labels());
        hydro_str     = hydro_str     .. " | " .. tostring(#Hydro(i):labels());
        thermal_str   = thermal_str   .. " | " .. tostring(#Thermal(i):labels());
        battery_str   = battery_str   .. " | " .. tostring(#Battery(i):labels());
        bus_str       = bus_str       .. " | " .. tostring(#Bus(i):labels());
        pinj_str      = pinj_str      .. " | " .. tostring(#PowerInjection(i):labels());
        acline_str    = acline_str    .. " | " .. tostring(#ACLine(i):labels());
        transformer_str = transformer_str .. " | " .. tostring(#Transformer(i):labels());
        three_wind_str  = three_wind_str  .. " | " .. tostring(#ThreeWindingTransformer(i):labels());
        dc_line_str   = dc_line_str   .. " | " .. tostring(#DCLine(i):labels());
        dc_link_str   = dc_link_str   .. " | " .. tostring(#DCLink(i):labels());
        --converter_str = converter_str .. " | " .. tostring(#DCLink(i):labels());

        local total_renw = #Renewable(i):labels();
        local renw_wind  = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(1)):agents_size();
        local renw_solar = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(2)):agents_size();
        local renw_sh    = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(4)):agents_size();
        local renw_csp   = #ConcentratedSolarPower(i):labels();
        local renw_oth   = total_renw - renw_wind - renw_solar - renw_sh;

        renw_w_str   = renw_w_str   .. " | " .. tostring(renw_wind);
        renw_s_str   = renw_s_str   .. " | " .. tostring(renw_solar);
        renw_sh_str  = renw_sh_str  .. " | " .. tostring(renw_sh);
        renw_csp_str = renw_csp_str .. " | " .. tostring(renw_csp);
        renw_oth_str = renw_oth_str .. " | " .. tostring(renw_oth);

        if i == n_cases then
            dim_header      = dim_header      .. "|";
            dim_sep         = dim_sep         .. "|";
            sys_str         = sys_str         .. "|";
            hydro_str       = hydro_str       .. "|";
            thermal_str     = thermal_str     .. "|";
            renw_w_str      = renw_w_str      .. "|";
            renw_s_str      = renw_s_str      .. "|";
            renw_sh_str     = renw_sh_str     .. "|";
            renw_csp_str    = renw_csp_str    .. "|";
            renw_oth_str    = renw_oth_str    .. "|";
            battery_str     = battery_str     .. "|";
            bus_str         = bus_str         .. "|";
            pinj_str        = pinj_str        .. "|";
            acline_str      = acline_str      .. "|";
            transformer_str = transformer_str .. "|";
            three_wind_str  = three_wind_str  .. "|";
            dc_line_str     = dc_line_str     .. "|";
            dc_link_str     = dc_link_str     .. "|";
            --converter_str   = converter_str   .. "|";
        end
    end

    self:push(dim_header);
    self:push(dim_sep);
    self:push(sys_str);
    self:push(hydro_str);
    self:push(thermal_str);
    self:push(renw_w_str);
    self:push(renw_s_str);
    self:push(renw_sh_str);
    self:push(renw_oth_str);
    self:push(renw_csp_str);
    self:push(battery_str);
    self:push(pinj_str);
    self:push(bus_str);
    self:push(acline_str);
    self:push(transformer_str);
    self:push(three_wind_str);
    self:push(dc_line_str);
    self:push(dc_link_str);
    --self:push(converter_str);
end

---------------------------------------------------------------------------
-- Helper: username (same as optflow)
---------------------------------------------------------------------------

function Generic.username(self)
    local generic = Generic(1);
    local index   = self:get_study_index();
    local user_name_file = generic:load_table_without_header("case_compare.metadata");
    local user_name = "";
    if #user_name_file >= index then
        user_name = user_name_file[index][1];
    else
        user_name = self:dirname();
    end
    return user_name;
end

---------------------------------------------------------------------------
-- Helper: load info file (same structure as optflow, file = optnet.info)
---------------------------------------------------------------------------

function load_info_file(file_name, case_index)
    local info_struct = { model = "", user = "", version = "", hash = "",
                          status = 0, arch = "", total_nodes = 1,
                          total_processes = 1, processing_type = "" };

    local toml          = Generic(case_index):load_toml(file_name);
    info_struct.model           = toml:get_string("model", "-");
    info_struct.user            = toml:get_string("user", "-");
    info_struct.version         = toml:get_string("version", "-");
    info_struct.hash            = toml:get_string("hash", "-");
    info_struct.status          = tonumber(toml:get_string("status", "0"));
    info_struct.arch            = toml:get_string("arch", "-");
    info_struct.total_nodes     = toml:get_integer("total_nodes", 1);
    info_struct.total_processes = toml:get_integer("total_process", 1);
    info_struct.processing_type = toml:get_string("processing_type", "-");

    return info_struct;
end

---------------------------------------------------------------------------
-- Helper: load optnet.dat parameters
---------------------------------------------------------------------------

function load_optnet_data(file_name, case_index)
    local optnet_struct = {
        -- Dates
        initial_stage = 0, initial_year = 0,
        final_stage   = 0, final_year   = 0,

        -- Representations
        serie_representation       = 0, selected_series      = {},
        resolution_representation  = 0, selected_resolutions = {},
        system_representation      = 0, selected_systems     = {},

        -- Solution strategy
        solution_method             = 0,
        critical_scenario_criterion = 0,
        num_critical_scenarios      = 0,
        mip_rel_gap                 = 0,
        mip_cpu_limit               = 0,
        slack_representation        = 0,
        slack_penalty               = 0,
        gen_deviation               = false,
        gen_deviation_type          = 0,
        gen_deviation_factor        = 0,
        cap_deviation_factor        = 0,
        circuit_overload            = 0,
        sum_circuit_flow            = false,
        contingency                 = false,
    }

    local data = Generic(case_index):load_table_without_header(file_name);

    for i = 1, #data do
        local line = data[i][1];
        if type(line) == "string" then
            if not string.find(line, "#", 1, true) then
                local key, val_str = string.match(line, "([A-Z_]+)%s*=%s*(.+)");
                if key and val_str then
                    local val = tonumber(val_str);

                    -- Dates
                    if     key == "DCNV_INIS" then optnet_struct.initial_stage = val
                    elseif key == "DCNV_INIY" then optnet_struct.initial_year  = val
                    elseif key == "DCNV_ENDS" then optnet_struct.final_stage   = val
                    elseif key == "DCNV_ENDY" then optnet_struct.final_year    = val

                    -- Series
                    elseif key == "DCNV_SSER" then optnet_struct.serie_representation = val
                    elseif key == "DCNV_VSER" then
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optnet_struct.selected_series, tonumber(num));
                        end

                    -- Resolution
                    elseif key == "DCNV_SDUR" then optnet_struct.resolution_representation = val
                    elseif key == "DCNV_VDUR" then
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optnet_struct.selected_resolutions, tonumber(num));
                        end

                    -- Systems
                    elseif key == "DCNV_SSIS" then optnet_struct.system_representation = val
                    elseif key == "DCNV_VSIS" then
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optnet_struct.selected_systems, tonumber(num));
                        end

                    -- Solution strategy
                    elseif key == "DEXE_ANLS" then optnet_struct.solution_method             = val
                    elseif key == "DEXE_CSCN" then optnet_struct.critical_scenario_criterion = val
                    elseif key == "DEXE_MSCN" then optnet_struct.num_critical_scenarios      = val
                    elseif key == "DEXE_TMIP" then optnet_struct.mip_rel_gap                 = val
                    elseif key == "DEXE_TCPU" then optnet_struct.mip_cpu_limit               = val
                    elseif key == "DEXE_EXOP" then optnet_struct.slack_representation        = val
                    elseif key == "DEXE_LSHC" then optnet_struct.slack_penalty               = val
                    elseif key == "DEXE_MDEV" then optnet_struct.gen_deviation               = (val == 1)
                    elseif key == "DEXE_OPDF" then optnet_struct.gen_deviation_type          = val
                    elseif key == "DEXE_DEVF" then optnet_struct.gen_deviation_factor        = val
                    elseif key == "DEXE_DEVX" then optnet_struct.cap_deviation_factor        = val
                    elseif key == "DEXE_CMON" then optnet_struct.circuit_overload            = val
                    elseif key == "DEXE_SUMC" then optnet_struct.sum_circuit_flow            = (val == 1)
                    elseif key == "DEXE_SCTG" then optnet_struct.contingency                 = (val == 1)
                    end
                end
            end
        end
    end

    return optnet_struct;
end

---------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------

local info_struct  = {};
local optnet_data  = {};

for case = 1, N_cases do
    table.insert(info_struct, load_info_file("optnet.info", case));
    table.insert(optnet_data, load_optnet_data("optnet.dat", case));
end

local output = {};
load_data(output, lang, optnet_data);

local d = Dashboard();

local tab_solution = Tab(dictionary.solution_quality[lang]);
tab_solution:set_disabled();
tab_solution:Solution_Quality(N_cases, lang, output);
d:push(tab_solution);

local tab_results = Tab(dictionary.results[lang]);
tab_results:set_disabled();
tab_results:Results(N_cases, lang, output, optnet_data[1].slack_representation);
d:push(tab_results);

local summary_tab = Tab(dictionary.summary[lang]);
summary_tab:push("# " .. dictionary.case_information[lang]);
summary_tab:create_summary(N_cases, lang, info_struct, optnet_data);
d:push(summary_tab);

d:hide_links();
d:save("OptNet");
