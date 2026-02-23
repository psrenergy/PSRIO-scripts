N_cases = PSR.studies();

local function load_Lang()
    local Lang = Study(1):get_parameter("Idioma", 0);

    if Lang == 1 then
        return "es";
    elseif Lang == 2 then
        return "pt";
    else -- Lang == 0
        return "en";
    end
end

-- local lang = load_Lang();
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
    thermal = "#F28E2B",
    hydro = "#4E79A7",
    renewable = "#8CD17D",
    battery = "#4BC9B2",
    reactive_injection_power_penalty = "#9B59B6",
    sincron = "#9C59B6",
    shunt = "#1ABC9C",
    deficit = "#34495E",
}

local dictionary = {
    scenarios = {en = "Scenarios", es = "Escenarios", pt = "Cenários"},
    scenario = {en = "Scenario", es = "Escenario", pt = "Cenário"},
    stages = {en = "Stages", es = "Etapas", pt = "Estágios"},
    stage = {en = "Stage", es = "Etapa", pt = "Estágio"},
    costs = {en = "Costs", es = "Costos", pt = "Custos"},
    generation = {en = "Generation", es = "Generación", pt = "Geração"},
    thermal = {en = "Thermal", es = "Térmica", pt = "Térmica"},
    hydro = {en = "Hydro", es = "Hidro", pt = "Hidro"},
    renewable = {en = "Renewable", es = "Renovable", pt = "Renovável"},
    battery = {en = "Battery", es = "Batería", pt = "Bateria"},
    active_load = {en = "Active load", es = "Carga activa", pt = "Carga ativa"},
    reactive_load = {en = "Reactive load", es = "Carga reactiva", pt = "Carga reativa"},
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
    biggest_busses = {en = "Biggest buses values", es = "Valores de las barras más grandes", pt = "Maiores valores das barras"},
    active_deficit = {en = "Active deficit", es = "Déficit activo", pt = "Déficit ativo"},
    reactive_deficit = {en = "Reactive deficit", es = "Déficit reactivo", pt = "Déficit reativo"},
    cell_case = {en = "Case", es = "Caso", pt = "Caso"},
    cell_directory_name = {en = "Directory name", es = "Nombre del directorio", pt = "Nome do diretório"},
    cell_path = {en = "Path", es = "Ruta", pt = "Caminho"},
    cell_execution_status = {en = "Execution status", es = "Estado de ejecución", pt = "Status de execução"},
    cell_initial_date = {en = "Initial date", es = "Fecha inicial", pt = "Data inicial"},
    cell_final_date = {en = "Final date", es = "Fecha final", pt = "Data final"},
    cell_series_representation = {en = "Series representation", es = "Representación de series", pt = "Representação de séries"},
    cell_all = {en = "All", es = "Todas", pt = "Todas"},
    cell_selected = {en = "Selected", es = "Seleccionadas", pt = "Selecionadas"},
    cell_selected_series = {en = "Selected series", es = "Series seleccionadas", pt = "Séries selecionadas"},
    cell_resolution_representation = {en = "Resolution representation", es = "Representación de resolución", pt = "Representação de resolução"},
    cell_selected_resolution = {en = "Selected resolution", es = "Resolución seleccionada", pt = "Resolução selecionada"},
    cell_selected_systems = {en = "Selected systems", es = "Sistemas seleccionados", pt = "Sistemas selecionados"},
    objective_function = {en = "Objective function", es = "Función objetivo", pt = "Função objetivo"},
    cell_minimun_cost = {en = "Minimun cost", es = "Costo mínimo", pt = "Custo mínimo"},
    cell_minimun_loss = {en = "Minimun loss", es = "Pérdida mínima", pt = "Perda mínima"},
    cell_minimun_deviation = {en = "Minimun deviation", es = "Desviación mínima", pt = "Desvio mínimo"},
    cell_objective_function_type = {en = "Objective function type", es = "Tipo de función objetivo", pt = "Tipo de função objetivo"},
    variables_constraints = {en = "Variables and constraints", es = "Variables y restricciones", pt = "Variáveis e restrições"},
    cell_variables_constraints = {en = "Present variables and constraints", es = "Variables y restricciones presentes", pt = "Variáveis e restrições presentes"},
    cell_generator_reactive_power = {en = "Generator reactive power", es = "Potencia reactiva de generadores", pt = "Potência reativa de geradores"},
    cell_generator_voltage_control = {en = "Generator voltage control", es = "Control de voltaje de generadores", pt = "Controle de tensão de geradores"},
    cell_switched_shunt = {en = "Switched shunt", es = "Shunt conmutado", pt = "Shunt comutado"},
    cell_shunt_voltage_control = {en = "Shunt with voltage control", es = "Shunt con control de voltaje", pt = "Shunt com controle de tensão"},
    cell_tap = {en = "Tap", es = "Tap", pt = "Tap"},
    cell_tap_voltage_control = {en = "Tap with voltage control", es = "Tap con control de voltaje", pt = "Tap com controle de tensão"},
    cell_phase_shifter = {en = "Phase shifter", es = "Desfasador", pt = "Desfasador"},
    cell_phase_shifter_flow_control = {en = "Phase shifter with flow control", es = "Desfasador con control de flujo", pt = "Desfasador com controle de fluxo"},
    cell_series_capacitor = {en = "Series capacitor", es = "Capacitor en serie", pt = "Capacitor em série"},
    cell_series_capacitor_flow_control = {en = "Series capacitor with flow control", es = "Capacitor en serie con control de flujo", pt = "Capacitor em série com controle de fluxo"},
    cell_acdc_converter_angle = {en = "AC-DC converter angle", es = "Ángulo de convertidor AC-DC", pt = "Ângulo de conversor AC-DC"},
    cell_acdc_converter_tap = {en = "AC-DC converter tap", es = "Tap de convertidor AC-DC", pt = "Tap de conversor AC-DC"},
    cell_syncrhonous_reactive_power = {en = "Syncrhonous reactive power", es = "Potencia reactiva síncrona", pt = "Potência reativa síncrona"},
    cell_svc = {en = "SVC", es = "SVC", pt = "SVC"},
    cell_svc_voltage_control = {en = "SVC with voltage control", es = "SVC con control de voltaje", pt = "SVC com controle de tensão"},
    cell_cons_flow_mw = {en = "Flow constraint in MW", es = "Restricción de flujo en MW", pt = "Restrição de fluxo em MW"},
    cell_cons_flow_mva = {en = "Flow constraint in MVA", es = "Restricción de flujo en MVA", pt = "Restrição de fluxo em MVA"},
    cell_cons_sum_circuit_flow = {en = "Sum of circuit flow constraint", es = "Restricción de suma de flujos en circuitos", pt = "Restrição de soma de fluxos em circuitos"},
    cell_ac_line = {
        en = "AC line",
        es = "Línea de CA",
        pt = "Linha de CA",
    },
    cell_dc_line = {
        en = "DC line",
        es = "Línea de CC",
        pt = "Linha de CC",
    },
    cell_transformers = {
        en = "Transformers",
        es = "Transformadores",
        pt = "Transformadores",
    },
    cell_3wind_transformers = {
        en = "Three winding transformers",
        es = "Transformadores de tres devanados",
        pt = "Transformadores de três enrolamentos",
    },

    ---
    cell_model = {en = "Model", es = "Modelo", pt = "Modelo"},
    cell_user = {en = "User", es = "Usuario", pt = "Usuário"},
    cell_version = {en = "Version", es = "Versión", pt = "Versão"},
    cell_ID = {en = "ID", es = "ID", pt = "ID"},
    cell_arch = {en = "Architecture", es = "Arquitectura", pt = "Arquitetura"},
    cell_title = {en = "Title", es = "Título", pt = "Título"},
    cell_execution_type = {en = "Execution type", es = "Tipo de ejecución", pt = "Tipo de execução"},
    cell_total_processes = {en = "Total processes", es = "Procesos totales", pt = "Processos totais"},
    cell_total_nodes = {en = "Total nodes", es = "Nodos totales", pt = "Nós totais"},
    cell_success = {en = "Success", es = "Éxito", pt = "Sucesso"},
    about_model = {en = "About the model and environment", es = "Acerca del modelo y el entorno", pt = "Sobre o modelo e o ambiente"},
    about_nodes = {en = "About the execution nodes", es = "Acerca de los nodos de ejecución", pt = "Sobre os nós de execução"},
    case_title = {en = "Case title", es = "Título del caso", pt = "Título do caso"},
    hor_resol_exec = {
        en = "Horizon, resolution and execution options",
        es = "Horizonte, resolución y opciones de ejecución",
        pt = "Horizonte, resolução e opções de execução"
    },
    cell_case_parameters = {
        en = "Case parameters",
        es = "Parámetros del caso",
        pt = "Parâmetros do caso"
    },
    cell_case_type = {
        en = "Case type",
        es = "Tipo de caso",
        pt = "Tipo de caso"
    },
    cell_stages = {
        en = "Stages",
        es = "Etapas",
        pt = "Estágios"
    },
    cell_ini_date = {
        en = "Initial date",
        es = "Fecha inicial",
        pt = "Data inicial"
    },
    cell_plc_resolution = {
        en = "Policy resolution",
        es = "Resolución de la politica",
        pt = "Resolução da política"
    },
    cell_sim_resolution = {
        en = "Simulation resolution",
        es = "Resolución de la simulación",
        pt = "Resolução da simulação"
    },
    cell_blocks = {
        en = "Blocks",
        es = "Bloques",
        pt = "Blocos"
    },
    cell_hourly = {
        en = "Hourly",
        es = "Horaria",
        pt = "Horária"
    },
    cell_fwd_series = {
        en = "Foward series",
        es = "Series Foward",
        pt = "Séries Foward"
    },
    cell_bwd_series = {
        en = "Backward series",
        es = "Series Backward",
        pt = "Séries Backward"
    },
    cell_sim_series = {
        en = "Simulated series",
        es = "Series simuladas",
        pt = "Séries Simuladas"
    },
    cell_hourly_representation = {
        en = "Hourly representation",
        es = "Representación horaria",
        pt = "Representação horária"
    },
    cell_network_representation = {
        en = "Network representation",
        es = "Representación de la red",
        pt = "Representação de rede"
    },
    cell_typicalday_representation = {
        en = "Typical days representation",
        es = "Representación de días típicos",
        pt = "Representação de dias típicos"
    },
    cell_system = {
        en = "System",
        es = "Sistema",
        pt = "Sistema",
    },
    cell_batteries = {
        en = "Batteries",
        es = "Baterías",
        pt = "Baterias",
    },
    cell_buses = {
        en = "Buses",
        es = "Barras",
        pt = "Barras",
    },
    cell_ac_circuits = {
        en = "AC circuits",
        es = "Circuitos de CA",
        pt = "Circuitos de CA",
    },
    cell_dc_circuits = {
        en = "DC circuits",
        es = "Circuitos de CC",
        pt = "Circuitos de CC",
    },
    cell_interconnections = {
        en = "Interconnections",
        es = "Interconexiones",
        pt = "Interconexões",
    },
    cell_hydro_plants = {
        en = "Hydro plants",
        es = "Plantas hidroeléctricas",
        pt = "Usinas hidrelétricas",
    },
    cell_power_injections = {
        en = "Power injections",
        es = "Inyecciones de energía",
        pt = "Injeções de energia",
    },
    cell_renewable_wind = {
        en = "Renewable plants - Wind",
        es = "Plantas renovables - Eólicas",
        pt = "Usinas renováveis - Eólicas",
    },
    cell_renewable_solar = {
        en = "Renewable plants - Solar",
        es = "Plantas renovables - Solares",
        pt = "Usinas renováveis - Solares",
    },
    cell_renewable_small_hydro = {
        en = "Renewable plants - Small hydro",
        es = "Plantas renovables - Pequeñas centrais hidroeléctricas",
        pt = "Usinas renováveis - Pequenas centrais hidrelétricas",
    },
    cell_renewable_csp = {
        en = "Renewable plants - CSP",
        es = "Plantas renovables - CSP",
        pt = "Usinas renováveis - CSP",
    },
    cell_renewable_other = {
        en = "Renewable plants - Other techs",
        es = "Plantas renovables - Otras tecnologías",
        pt = "Usinas renováveis - Outras tecnologias",
    },
    cell_thermal_plants = {
        en = "Thermal plants",
        es = "Plantas térmicas",
        pt = "Usinas térmicas",
    },
    cell_non_convexities_type = {
        en = "Non convexities type",
        es = "Tipo de no-convexidades",
        pt = "Tipo de não-convexidades",
    },
    cell_count = {
        en = "Count",
        es = "Cantidad",
        pt = "Contagem",
    },
    cell_policy = {
        en = "Policy",
        es = "Política",
        pt = "Política"
    },
    cell_simulation = {
        en = "Simulation",
        es = "Simulación",
        pt = "Simulação"
    },
    cell_commercial_simulation = {
        en = "Commercial simulation",
        es = "Simulación comercial",
        pt = "Simulação comercial"
    },
    cell_monthly = {
        en = "Monthly",
        es = "Mensual",
        pt = "Mensal"
    },
    cell_weekly = {
        en = "Weekly",
        es = "Semanal",
        pt = "Semanal"
    },
    -- cell_success = {
    --     en = "SUCCESS",
    --     es = "ÉXITO",
    --     pt = "SUCESSO"
    -- },
    cell_loss_representation = {
        en = "Losses representation",
        es = "Representación de pérdidas",
        pt = "Representação de perdas"
    },
    -- cell_total_processes = {
    --     en = "Total number of processes",
    --     es = "Numero total de procesos",
    --     pt = "Número total de processos"
    -- },
    -- cell_total_nodes = {
    --     en = "Total number of nodes",
    --     es = "Número total de nodos",
    --     pt = "Número total de nós"
    -- },
    inflows_type = {
        en = "Type of inflows",
        es = "Tipos de afluencias",
        pt = "Tipos de afluências"
    },
    arp = {
        en = "ARP",
        es = "ARP",
        pt = "ARP"
    },
    historical = {
        en = "Historical data",
        es = "Histórico",
        pt = "Histórico"
    },
    external_f_b = {
        en = "External: forward/backward",
        es = "Externo: forward/backward",
        pt = "Externo: forward/backward"
    },
    external_f = {
        en = "External: forward",
        es = "Externo: forward",
        pt = "Externo: forward"
    },
    inflows_initial_year = {
        en = "Initial year of hydrology",
        es = "Año inicial de hidrología",
        pt = "Ano inicial de hidrologia"
    },
    additional_years_mensage = {
        en = "Additional years were not considered in the final simulation",
        es = "No se consideraron años adicionales en la simulación final",
        pt = "Anos adicionais não foram considerados na simulação final"
    },
    final_simulation = {
        en = "Final simulation",
        es = "Simulación final",
        pt = "Simulação final"
    },
    warning = {
        en = "WARNING",
        es = "ADVERTENCIA",
        pt = "AVISO"
    },
    node_details = {
        en = "Node details",
        es = "Detalles del nodo",
        pt = "Detalhes do nó"
    },
    dimentions = {
        en = "Dimensions",
        es = "Dimensiones",
        pt = "Dimensões"
    },





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

    summary = {en = "Summary", es = "Resumen", pt = "Resumo"},
    case_information = {en = "Case information", es = "Información del caso", pt = "Informações do caso"},
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
        output.optflow[case].active_demand = Generic(case):load("opf_ploa"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.active_load[lang]);

        output.optflow[case].reactive_thermal_generation = Generic(case):load("opf_qter"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.thermal[lang]);
        output.optflow[case].reactive_hydro_generation = Generic(case):load("opf_qhdr"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.hydro[lang]);
        output.optflow[case].reactive_renewable_generation = Generic(case):load("opf_qgnd"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.renewable[lang]);
        output.optflow[case].reactive_batt_generation = Generic(case):load("opf_qbat"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.battery[lang]);
        output.optflow[case].reactive_sinc_generation = Generic(case):load("opf_qsin"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.sincron[lang]);
        output.optflow[case].reactive_shunt_generation = Generic(case):load("opf_shtb"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.shunt[lang]);
        output.optflow[case].reactive_static_compensator_generation = Generic(case):load("opf_qsvc"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.static_compensator[lang]);
        output.optflow[case].reactive_injection_generation = Generic(case):load("opf_qinj"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.injection[lang]);
        output.optflow[case].reactive_demand = -Generic(case):load("opf_qloa"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.reactive_load[lang]);

        output.optflow[case].active_load_shedding = Generic(case):load("opf_lshp"):aggregate_blocks():aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.active_deficit[lang]);
        output.optflow[case].reactive_load_shedding = Generic(case):load("opf_lshq"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), dictionary.reactive_deficit[lang]);

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
            { color = "#7A7A7A", from = -1.1, to = -0.9, name = dictionary.unselected[Lang]},
            { color = "#FF796A", from = -2.1, to = -2.0, name = dictionary.not_converged_solution[Lang]},
            { color = "#C64B3E", from = -2.9, to = -3.1, name = dictionary.divergent_solution[Lang]}
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
    local n = 5;

    local max = -1000;
    local min = 1000;

    for case = 1, n_cases do
        local case_max = tonumber(output.optflow[case].reactive_power_mismatches:aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX()):aggregate_stages(BY_MAX()):aggregate_agents(BY_MAX(), "total"):to_list()[1]);
        if case_max > max then
            max = case_max;
        end
        local case_min = tonumber(output.optflow[case].reactive_power_mismatches:aggregate_blocks(BY_MIN()):aggregate_scenarios(BY_MIN()):aggregate_stages(BY_MIN()):aggregate_agents(BY_MIN(), "total"):to_list()[1]);
        if case_min < min then
            min = case_min;
        end
    end

    local subtitle = "";
    for case = 1, n_cases do
        if n_cases > 1 then
            subtitle = Generic(case):cloudname();
        end

        -- Active power solution mismatches
        local chart = Chart(dictionary.active_power_solution_mismatches[Lang] .. " (" .. n .. " " .. dictionary.biggest_busses[Lang] .. ")", subtitle);
        chart:enable_controls();
        chart:invert_axes();
        chart:enable_vertical_zoom();

        local options = {
            yLabel = dictionary.buses[Lang],
            xLabel = dictionary.scenarios[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            stopsMin = min,
            stopsMax = max,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } }
        };

        for s = 1,output.optflow[case].active_power_mismatches:stages() do
            local active_power_mismatches_stage = output.optflow[case].active_power_mismatches:select_stage(s);
            local agents = active_power_mismatches_stage:abs():select_largest_agents(n):agents();
   
            options.sequence = s;
            options.sequence_label = dictionary.stage[Lang] .. " " .. s;
            chart:add_heatmap_series_agents(active_power_mismatches_stage:select_agents(agents), options);
        end
        
        self:push(chart);
    end

end

function Tab.reactive_solution_mismatches_charts(self, n_cases, Lang)
    local n = 5;

    local max = -1000;
    local min = 1000;

    for case = 1, n_cases do
        local case_max = tonumber(output.optflow[case].reactive_power_mismatches:aggregate_blocks(BY_MAX()):aggregate_scenarios(BY_MAX()):aggregate_stages(BY_MAX()):aggregate_agents(BY_MAX(), "total"):to_list()[1]);
        if case_max > max then
            max = case_max;
        end
        local case_min = tonumber(output.optflow[case].reactive_power_mismatches:aggregate_blocks(BY_MIN()):aggregate_scenarios(BY_MIN()):aggregate_stages(BY_MIN()):aggregate_agents(BY_MIN(), "total"):to_list()[1]);
        if case_min < min then
            min = case_min;
        end
    end

    local subtitle = "";
    for case = 1, n_cases do

        if n_cases > 1 then
            subtitle = Generic(case):cloudname();
        end

         -- Reactive power solution mismatches
        local chart = Chart(dictionary.reactive_power_solution_mismatches[Lang] .. " (" .. n .. " " .. dictionary.biggest_busses[Lang] .. ")", subtitle);
        chart:enable_controls();
        chart:invert_axes();
        chart:enable_vertical_zoom();

        local options = {
            yLabel = dictionary.buses[Lang],
            xLabel = dictionary.scenarios[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            stopsMin = min,
            stopsMax = max,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } }
        };

        for s = 1,output.optflow[case].reactive_power_mismatches:stages() do
            local reactive_power_mismatches_stage = output.optflow[case].reactive_power_mismatches:select_stage(s);
            local agents = reactive_power_mismatches_stage:abs():select_largest_agents(n):agents();

            options.sequence = s;
            options.sequence_label = dictionary.stage[Lang] .. " " .. s;
            chart:add_heatmap_series_agents(reactive_power_mismatches_stage:select_agents(agents), options);
        end
        
        self:push(chart);
    end

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

    if #chart >= 1 then
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

    if #operative_cost_charts >= 1 then
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
            chart:add_line(output.optflow[case].active_demand, {color = "black", width = 2, dashStyle = "ShortDash"});

            table.insert(generation_charts, chart);
        end

    else
        local chart = Chart(dictionary.active_power_generation[Lang]);
        chart:horizontal_legend();

        chart:add_area_stacking(output.optflow[1].active_thermal_generation, {color = table_techtype_color.thermal});
        chart:add_area_stacking(output.optflow[1].active_hydro_generation, {color = table_techtype_color.hydro});
        chart:add_area_stacking(output.optflow[1].active_renewable_generation, {color = table_techtype_color.renewable});
        chart:add_area_stacking(output.optflow[1].active_batt_generation, {color = table_techtype_color.battery});
        chart:add_line(output.optflow[1].active_demand, {color = "black", width = 2, dashStyle = "ShortDash"});
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
            chart:add_line(output.optflow[case].reactive_demand, {color = "black", width = 2, dashStyle = "ShortDash"});

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
        chart:add_line(output.optflow[1].reactive_demand, {color = "black", width = 2, dashStyle = "ShortDash"});

        reactive_generation_charts = chart;
    end

    self:push(reactive_generation_charts);
end

function Tab.active_load_shedding_chart(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;

    local suffix = "";
    for case = 1, n_cases do
        if n_cases > 1 then
            suffix = " " .. Generic(case):cloudname();
        end
        local chart = Chart(dictionary.active_load_shedding[Lang]);

        chart:add_column(output.optflow[case].active_load_shedding:add_suffix(suffix), {color = table_techtype_color.deficit, showInLegend = show_in_legend});

        self:push(chart);
    end
end

function Tab.reactive_load_shedding_chart(self, n_cases, Lang)
    local show_in_legend = n_cases > 1;

    local suffix = "";
    for case = 1, n_cases do
        if n_cases > 1 then
            suffix = " " .. Generic(case):cloudname();
        end
        local chart = Chart(dictionary.reactive_load_shedding[Lang]);

        chart:add_column(output.optflow[case].reactive_load_shedding:add_suffix(suffix), {color = table_techtype_color.deficit, showInLegend = show_in_legend});

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
    local n = 5;

    local max = 1;
    local min = 0;

    local subtitle = "";
    for case = 1, n_cases do

        if n_cases > 1 then
            subtitle = Generic(case):cloudname();
        end

         -- Voltage upper limit
        local chart = Chart(dictionary.voltage_upper_limit[Lang] .. " (" .. n .. " " .. dictionary.biggest_busses[Lang] .. ")", subtitle);
        chart:enable_controls();
        chart:invert_axes();
        chart:enable_vertical_zoom();

        local options = {
            yLabel = dictionary.buses[Lang],
            xLabel = dictionary.scenarios[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            stopsMin = min,
            stopsMax = max,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } }
        };

        for s = 1,output.optflow[case].voltage_margin_upper:stages() do
            local voltage_margin_upper_stage = output.optflow[case].voltage_margin_upper:select_stage(s);
            local agents = voltage_margin_upper_stage:abs():select_largest_agents(n):agents();

            options.sequence = s;
            options.sequence_label = dictionary.stage[Lang] .. " " .. s;
            chart:add_heatmap_series_agents(voltage_margin_upper_stage:select_agents(agents), options);
        end
        
        self:push(chart);
    end

end

function Tab.add_voltage_limits_lower_chart(self, n_cases, Lang)
    local n = 5;

    local max = 1;
    local min = 0;

    local subtitle = "";
    for case = 1, n_cases do

        if n_cases > 1 then
            subtitle = Generic(case):cloudname();
        end

         -- Voltage lower limit
        local chart = Chart(dictionary.voltage_lower_limit[Lang] .. " (" .. n .. " " .. dictionary.biggest_busses[Lang] .. ")", subtitle);
        chart:enable_controls();
        chart:invert_axes();
        chart:enable_vertical_zoom();

        local options = {
            yLabel = dictionary.buses[Lang],
            xLabel = dictionary.scenarios[Lang],
            showInLegend = false,
            xTickPixelInterval = 400/14,
            stopsMin = min,
            stopsMax = max,
            tops = { { min, "#4E79A7" }, { max, "#C64B3E" } }
        };

        for s = 1,output.optflow[case].voltage_margin_lower:stages() do
            local voltage_margin_lower_stage = output.optflow[case].voltage_margin_lower:select_stage(s);
            local agents = voltage_margin_lower_stage:abs():select_largest_agents(n):agents();

            options.sequence = s;
            options.sequence_label = dictionary.stage[Lang] .. " " .. s;
            chart:add_heatmap_series_agents(voltage_margin_lower_stage:select_agents(agents), options);
        end
        
        self:push(chart);
    end
end



function Tab.Solution_Quality(self, n_cases, Lang)
    self:set_icon("thermometer");

    self:add_convergence_status_chart(n_cases, Lang);

    self:push("# " .. dictionary.solution_time[Lang]);
    self:add_nonexceedance_solution_times_chart(n_cases, Lang);
    self:add_stage_solution_times_chart(n_cases, Lang);

    -- local subTab = SubTab(dictionary.solution_mismatches[Lang]);
    self:push("# " .. dictionary.solution_mismatches[Lang]);
    self:active_solution_mismatches_charts(n_cases, Lang);
    self:reactive_solution_mismatches_charts(n_cases, Lang);
    -- self:push(subTab);

    local subTab_enable = true;
    local subTab = SubTab(dictionary.costs[Lang]);
    subTab:push("# " .. dictionary.costs[Lang]);
    subTab_enable = subTab_enable and subTab:operative_cost_charts(n_cases, Lang);
    subTab_enable = subTab_enable and subTab:operative_stage_cost_charts(n_cases, Lang);
    if subTab_enable then
        self:push(subTab);
    end


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


function Tab.create_summary(self, n_cases, Lang, info_struct, optflow_data)
    self:set_icon("info");

    local exe_status_str;

    local label = {};
    local path = {};

    local model = {};
    local user = {}
    local version = {};
    local hash = {};
    local description = {};

    for i = 1, n_cases do
        table.insert(label,Generic(i):cloudname());
        table.insert(path, Generic(i):path());

        local study = Study(i);
        table.insert(description, study:get_parameter("Descricao", ""));
    end

    local case             = dictionary.cell_case[Lang];
    local directory_name   = dictionary.cell_directory_name[Lang];
    local path_cell        = dictionary.cell_path[Lang];
    local execution_status = dictionary.cell_execution_status[Lang];
    local model            = dictionary.cell_model[Lang];
    local user             = dictionary.cell_user[Lang];
    local version          = dictionary.cell_version[Lang];
    local ID               = dictionary.cell_ID[Lang];
	local cloud_arch       = dictionary.cell_arch[Lang];
    local title            = dictionary.cell_title[Lang];
    local execution_type   = dictionary.cell_execution_type[Lang];
    local total_process    = dictionary.cell_total_processes[Lang];
    local total_nodes      = dictionary.cell_total_nodes[Lang];

	-- Execution status
    if n_cases == 1 then 
        self:push("| " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        self:push("|:--------------:|:----:|:----------------:|");
        for i = 1, n_cases do
            exe_status_str = dictionary.cell_success[Lang];
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end

            self:push("| " .. label[i] .. " | " .. path[i].. " | " .. exe_status_str);
        end
    else
        self:push("| " .. case .. " | " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        self:push("|:----:|:--------------:|:----:|:----------------:|");
        for i = 1, n_cases do
            exe_status_str = dictionary.cell_success[Lang];
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end

            self:push("| " .. i .. " | " .. label[i] .. " | " .. path[i] .. " | " .. exe_status_str);
        end
    end

	-- About the model (hash, version name...)
    self:push("## " .. dictionary.about_model[Lang]);
    if n_cases == 1 then
        self:push("| " .. model .. " | " .. user .. " | " .. version .. " | " .. ID ..  "|" .. cloud_arch .. " |");
        self:push("|:-------:|:-------:|:-------:|:-------:|:-------:|");
        for i = 1, n_cases do
            self:push("| " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " | " .. info_struct[i].arch .. " |");
        end
    else
        self:push("| " .. case .. " | " .. model .. " | " .. user .. " | " .. version .." | " .. ID .. "|" .. cloud_arch .. " |");
        self:push("|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " | " .. info_struct[i].arch .. " |");
        end
    end

    -- About nodes
    self:push("## " .. dictionary.about_nodes[Lang]);
    if n_cases == 1 then
        self:push("| " .. execution_type .. " | "  .. total_nodes .. " | " .. total_process .. " |");
        self:push("|:-----------------:|:-----------------:|:-----------------:|");
        self:push("| " .. info_struct[1].processing_type .. " | " .. info_struct[1].total_nodes .. " | " .. info_struct[1].total_processes .. " |");

    else
        self:push("| " .. case .. " | " .. execution_type .. " | " .. total_nodes .. " | " .. total_process .. " |");
        self:push("|:----:|:-----------------:|:-----------------:|:-----------------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. info_struct[i].processing_type .. " | " .. info_struct[i].total_nodes .. " | " .. info_struct[i].total_processes .. " |");
        end

    end


	-- Cases' titles
    self:push("## " .. dictionary.case_title[Lang]);
    if n_cases == 1 then
        self:push("| " .. title .. " |");
        self:push("|:-----------:|");
        for i = 1, n_cases do
            self:push("| " .. description[i] .. " | ");
        end
    else
        self:push("| " .. case .. " | " .. title .. " |");
        self:push("|:----:|:-----------:|");
        for i = 1, n_cases do
            self:push("| " .. i .. " | " .. description[i] .. " | ");
        end
    end

	-- Horizon, resolution, execution options
    self:push("## " .. dictionary.hor_resol_exec[Lang]);

    local header_string                    = "| " .. dictionary.cell_case_parameters[Lang];
    local lower_header_string              = "|---------------";
    local case_type_string                 = "| " .. dictionary.cell_case_type[Lang];
    local sim_resolution                   = "| " .. dictionary.cell_sim_resolution[Lang];
    local hrep_string                      = "| " .. dictionary.cell_hourly_representation[Lang];
    local typday_string                    = "| " .. dictionary.cell_typicalday_representation[Lang];
    local initial_date_string              = "| " .. dictionary.cell_initial_date[Lang];
    local final_date_string                = "| " .. dictionary.cell_final_date[Lang];
    local selected_series_string           = "| " .. dictionary.cell_selected_series[Lang];
    local selected_resolution_string       = "| " .. dictionary.cell_selected_resolution[Lang];
    local selected_systems_string          = "| " .. dictionary.cell_selected_systems[Lang];

    for i = 1, n_cases do

        -- type of resolution
        local stage_type = dictionary.cell_monthly[Lang];
        if Study(i):stage_type() == 1 then
            stage_type = dictionary.cell_weekly[Lang];
        end
        case_type_string = case_type_string .. " | " .. stage_type;


        local number_of_blocks = Study(i):get_parameter("NumberBlocks", -1);
        local resolution_of_simulation = number_of_blocks .. " " .. dictionary.cell_blocks[Lang]
        if Study(i):is_hourly() then
            resolution_of_simulation = dictionary.cell_hourly[Lang];
        end
        sim_resolution   = sim_resolution   .. " | " .. resolution_of_simulation;


        local hour_represetation = "❌";
        if Study(i):get_parameter("SIMH", -1) == 2 then
            hour_represetation = "✔️";
        end
        hrep_string = hrep_string .. " | " .. hour_represetation;


        local typday_representation = "❌";
        if Study(i):get_parameter("TDAY", -1) == 1 then
            typday_representation = "✔️";
        end
        typday_string = typday_string .. " | " .. typday_representation;


        header_string = header_string             .. " | " .. Generic(i):username();

        initial_date_string = initial_date_string .. " | " .. optflow_data[i].initial_stage .. "/" .. optflow_data[i].initial_year;
        final_date_string   = final_date_string   .. " | " .. optflow_data[i].final_stage .. "/" .. optflow_data[i].final_year;


        local selected_series =  dictionary.cell_all[Lang];
        if #optflow_data[i].selected_series > 0 then
            selected_series = "";
            for j = 1, #optflow_data[i].selected_series do
                selected_series = selected_series .. optflow_data[i].selected_series[j] .. ",";
            end
            selected_series = selected_series:sub(1, -2);
        end
        selected_series_string = selected_series_string .. " | " .. selected_series;


        local selected_resolution =  dictionary.cell_all[Lang];
        if #optflow_data[i].selected_resolutions > 0 then
            selected_resolution = "";
            for j = 1, #optflow_data[i].selected_resolutions do
                selected_resolution = selected_resolution .. optflow_data[i].selected_resolutions[j] .. ",";
            end
            selected_resolution = selected_resolution:sub(1, -2);
        end
        selected_resolution_string = selected_resolution_string .. " | " .. selected_resolution;


        local selected_systems = dictionary.cell_all[Lang];
        if #optflow_data[i].selected_systems > 0 then
            selected_systems = "";
            for j = 1, #optflow_data[i].selected_systems do
                selected_systems = selected_systems .. optflow_data[i].selected_systems[j] .. ",";
            end
            selected_systems = selected_systems:sub(1, -2);
        end
        selected_systems_string = selected_systems_string .. " | " .. selected_systems;


        lower_header_string = lower_header_string .. "|-----------";


        if i == n_cases then
            header_string                    = header_string              .. "|";
            lower_header_string              = lower_header_string        .. "|";
            case_type_string                 = case_type_string           .. "|";
            sim_resolution                   = sim_resolution             .. "|";
            hrep_string                      = hrep_string                .. "|";
            typday_string                    = typday_string              .. "|";
            initial_date_string              = initial_date_string        .. "|";
            final_date_string                = final_date_string          .. "|";
            selected_series_string           = selected_series_string     .. "|";
            selected_resolution_string       = selected_resolution_string .. "|";
            selected_systems_string          = selected_systems_string    .. "|";
        end


    end

    self:push(header_string);
    self:push(lower_header_string);
    self:push(case_type_string);
    self:push(sim_resolution);
    self:push(hrep_string);
    self:push(typday_string);
    self:push(initial_date_string);
    self:push(final_date_string);
    self:push(selected_series_string);
    self:push(selected_resolution_string);
    self:push(selected_systems_string);


    -- objective function
    self:push("## " .. dictionary.objective_function[Lang]);
    local header_string = "| " .. dictionary.cell_objective_function_type[Lang];
    local lower_header_string              = "|---------------";
    local min_cost = "| " .. dictionary.cell_minimun_cost[Lang];
    local min_loss = "| " .. dictionary.cell_minimun_loss[Lang];
    local min_devi = "| " .. dictionary.cell_minimun_deviation[Lang];

    for i = 1, n_cases do

        header_string = header_string             .. " | " .. Generic(i):username();
        lower_header_string = lower_header_string .. "|-----------";

        local is_min_cost = "❌";
        local is_min_loss = "❌";
        local is_min_devi = "❌";

        if optflow_data[i].obj_min_cost_reactive then
            is_min_cost = "✔️";
        end
        min_cost = min_cost .. " | " .. is_min_cost;

        if optflow_data[i].obj_min_active_losses then
            is_min_loss = "✔️";
        end
        min_loss = min_loss .. " | " .. is_min_loss;

        if optflow_data[i].obj_min_desviation_active_gen then
            is_min_devi = "✔️";
        end
        min_devi = min_devi .. " | " .. is_min_devi;

        if i == n_cases then
            header_string = header_string .. "|";
            lower_header_string = lower_header_string .. "|";
            min_cost = min_cost .. " |";
            min_loss = min_loss .. " |";
            min_devi = min_devi .. " |";
        end
    end
    self:push(header_string);
    self:push(lower_header_string);
    self:push(min_cost);
    self:push(min_loss);
    self:push(min_devi);

    --variable and constraints
    self:push("## " .. dictionary.variables_constraints[Lang]);
    local header_string = "| " .. dictionary.cell_variables_constraints[Lang];
    local lower_header_string              = "|---------------";
    local cell_generator_reactive_power_string = "| " .. dictionary.cell_generator_reactive_power[Lang];
    local cell_voltage_string               = "| " .. dictionary.cell_generator_voltage_control[Lang];
    local cell_switched_shunt_string        = "| " .. dictionary.cell_switched_shunt[Lang];
    local cell_shunt_voltage_control_string = "| " .. dictionary.cell_shunt_voltage_control[Lang];
    local cell_tap_string                   = "| " .. dictionary.cell_tap[Lang];
    local cell_tap_voltage_control_string    = "| " .. dictionary.cell_tap_voltage_control[Lang];
    local cell_phase_shifter_string         = "| " .. dictionary.cell_phase_shifter[Lang];
    local cell_phase_shifter_flow_control_string = "| " .. dictionary.cell_phase_shifter_flow_control[Lang];
    local cell_series_capacitor_string      = "| " .. dictionary.cell_series_capacitor[Lang];
    local cell_series_capacitor_flow_control_string = "| " .. dictionary.cell_series_capacitor_flow_control[Lang];
    local cell_acdc_converter_angle_string  = "| " .. dictionary.cell_acdc_converter_angle[Lang];
    local cell_acdc_converter_tap_string    = "| " .. dictionary.cell_acdc_converter_tap[Lang];
    local cell_syncrhonous_reactive_power_string = "| " .. dictionary.cell_syncrhonous_reactive_power[Lang];
    local cell_svc_string                   = "| " .. dictionary.cell_svc[Lang];
    local cell_svc_voltage_control_string    = "| " .. dictionary.cell_svc_voltage_control[Lang];
    local cell_cons_flow_mw_string           = "| " .. dictionary.cell_cons_flow_mw[Lang];
    local cell_cons_flow_mva_string          = "| " .. dictionary.cell_cons_flow_mva[Lang];
    local cell_cons_sum_circuit_flow_string   = "| " .. dictionary.cell_cons_sum_circuit_flow[Lang];

    for i = 1, n_cases do

        header_string = header_string             .. " | " .. Generic(i):username();
        lower_header_string = lower_header_string .. "|-----------";

        local has_generator_reactive_power_variables = "❌";
        if optflow_data[i].ctrl_gen_reactive_power then
            has_generator_reactive_power_variables = "✔️";
        end
        local has_voltage_variables = "❌";
        if optflow_data[i].ctrl_gen_voltage then
            has_voltage_variables = "✔️";
        end
        local has_switched_shunt_variables = "❌";
        if optflow_data[i].ctrl_switched_shunt then
            has_switched_shunt_variables = "✔️";
        end
        local has_shunt_voltage_control_variables = "❌";
        if optflow_data[i].ctrl_shunt_voltage_control then
            has_shunt_voltage_control_variables = "✔️";
        end
        local has_tap_variables = "❌";
        if optflow_data[i].ctrl_tap then
            has_tap_variables = "✔️";
        end
        local has_tap_voltage_control_variables = "❌";
        if optflow_data[i].ctrl_tap_voltage_control then
            has_tap_voltage_control_variables = "✔️";
        end
        local has_phase_shifter_variables = "❌";
        if optflow_data[i].ctrl_phase_shifter then
            has_phase_shifter_variables = "✔️";
        end
        local has_phase_shifter_flow_control_variables = "❌";
        if optflow_data[i].ctrl_phase_shifter_flow_control then
            has_phase_shifter_flow_control_variables = "✔️";
        end
        local has_series_capacitor_variables = "❌";
        if optflow_data[i].ctrl_series_capacitor then
            has_series_capacitor_variables = "✔️";
        end
        local has_series_capacitor_flow_control_variables = "❌";
        if optflow_data[i].ctrl_series_capacitor_flow_control then
            has_series_capacitor_flow_control_variables = "✔️";
        end
        local has_acdc_converter_angle_variables = "❌";
        if optflow_data[i].ctrl_acdc_converter_angle then
            has_acdc_converter_angle_variables = "✔️";
        end
        local has_acdc_converter_tap_variables = "❌";
        if optflow_data[i].ctrl_acdc_converter_tap then
            has_acdc_converter_tap_variables = "✔️";
        end
        local has_syncrhonous_reactive_power_variables = "❌";
        if optflow_data[i].ctrl_syncrhonous_reactive_power then
            has_syncrhonous_reactive_power_variables = "✔️";
        end
        local has_svc_variables = "❌";
        if optflow_data[i].ctrl_svc then
            has_svc_variables = "✔️";
        end
        local has_svc_voltage_control_variables = "❌";
        if optflow_data[i].ctrl_svc_voltage_control then
            has_svc_voltage_control_variables = "✔️";
        end
        local has_cell_cons_flow_mw = "❌";
        if optflow_data[i].cons_flow_mw then
            has_cell_cons_flow_mw = "✔️";
        end
        local has_cell_cons_flow_mva = "❌";
        if optflow_data[i].cons_flow_mvar then
            has_cell_cons_flow_mva = "✔️";
        end
        local has_cell_cons_sum_circuit_flow = "❌";
        if optflow_data[i].cons_sum_circuit_flow then
            has_cell_cons_sum_circuit_flow = "✔️";
        end


        cell_generator_reactive_power_string = cell_generator_reactive_power_string .. " | " .. has_generator_reactive_power_variables;
        cell_voltage_string = cell_voltage_string .. " | " .. has_voltage_variables;
        cell_switched_shunt_string = cell_switched_shunt_string .. " | " .. has_switched_shunt_variables;
        cell_shunt_voltage_control_string = cell_shunt_voltage_control_string .. " | " .. has_shunt_voltage_control_variables;
        cell_tap_string = cell_tap_string .. " | " .. has_tap_variables;
        cell_tap_voltage_control_string = cell_tap_voltage_control_string .. " | " .. has_tap_voltage_control_variables;
        cell_phase_shifter_string = cell_phase_shifter_string .. " | " .. has_phase_shifter_variables;
        cell_phase_shifter_flow_control_string = cell_phase_shifter_flow_control_string .. " | " .. has_phase_shifter_flow_control_variables;
        cell_series_capacitor_string = cell_series_capacitor_string .. " | " .. has_series_capacitor_variables;
        cell_series_capacitor_flow_control_string = cell_series_capacitor_flow_control_string .. " | " .. has_series_capacitor_flow_control_variables;
        cell_acdc_converter_angle_string = cell_acdc_converter_angle_string .. " | " .. has_acdc_converter_angle_variables;
        cell_acdc_converter_tap_string = cell_acdc_converter_tap_string .. " | " .. has_acdc_converter_tap_variables;
        cell_syncrhonous_reactive_power_string = cell_syncrhonous_reactive_power_string .. " | " .. has_syncrhonous_reactive_power_variables;
        cell_svc_string = cell_svc_string .. " | " .. has_svc_variables;
        cell_svc_voltage_control_string = cell_svc_voltage_control_string .. " | " .. has_svc_voltage_control_variables;
        cell_cons_flow_mw_string = cell_cons_flow_mw_string .. " | " .. has_cell_cons_flow_mw;
        cell_cons_flow_mva_string = cell_cons_flow_mva_string .. " | " .. has_cell_cons_flow_mva;
        cell_cons_sum_circuit_flow_string = cell_cons_sum_circuit_flow_string .. " | " .. has_cell_cons_sum_circuit_flow;

        if i == n_cases then
            header_string = header_string .. "|";
            lower_header_string = lower_header_string .. "|";
            cell_generator_reactive_power_string = cell_generator_reactive_power_string .. "|";
            cell_voltage_string = cell_voltage_string .. "|";
            cell_switched_shunt_string = cell_switched_shunt_string .. "|";
            cell_shunt_voltage_control_string = cell_shunt_voltage_control_string .. "|";
            cell_tap_string = cell_tap_string .. "|";
            cell_tap_voltage_control_string = cell_tap_voltage_control_string .. "|";
            cell_phase_shifter_string = cell_phase_shifter_string .. "|";
            cell_phase_shifter_flow_control_string = cell_phase_shifter_flow_control_string .. "|";
            cell_series_capacitor_string = cell_series_capacitor_string .. "|";
            cell_series_capacitor_flow_control_string = cell_series_capacitor_flow_control_string .. "|";
            cell_acdc_converter_angle_string = cell_acdc_converter_angle_string .. "|";
            cell_acdc_converter_tap_string = cell_acdc_converter_tap_string .. "|";
            cell_syncrhonous_reactive_power_string = cell_syncrhonous_reactive_power_string .. "|";
            cell_svc_string = cell_svc_string .. "|";
            cell_svc_voltage_control_string = cell_svc_voltage_control_string .. "|";
            cell_cons_flow_mw_string = cell_cons_flow_mw_string .. "|";
            cell_cons_flow_mva_string = cell_cons_flow_mva_string .. "|";
            cell_cons_sum_circuit_flow_string = cell_cons_sum_circuit_flow_string .. "|";
        end
    end
    self:push(header_string);
    self:push(lower_header_string);
    self:push(cell_generator_reactive_power_string);
    self:push(cell_voltage_string);
    self:push(cell_switched_shunt_string);
    self:push(cell_shunt_voltage_control_string);
    self:push(cell_tap_string);
    self:push(cell_tap_voltage_control_string);
    self:push(cell_phase_shifter_string);
    self:push(cell_phase_shifter_flow_control_string);
    self:push(cell_series_capacitor_string);
    self:push(cell_series_capacitor_flow_control_string);
    self:push(cell_acdc_converter_angle_string);
    self:push(cell_acdc_converter_tap_string);
    self:push(cell_syncrhonous_reactive_power_string);
    self:push(cell_svc_string);
    self:push(cell_svc_voltage_control_string);
    self:push(cell_cons_flow_mw_string);
    self:push(cell_cons_flow_mva_string);
    self:push(cell_cons_sum_circuit_flow_string);


    -- dimentions
    self:push("## " .. dictionary.dimentions[Lang]);

    local sys_string            = "| " .. dictionary.cell_system[Lang];
    local battery_string        = "| " .. dictionary.cell_batteries[Lang];
    local bus_string            = "| " .. dictionary.cell_buses[Lang];
    local ac_line_string        = "| " .. dictionary.cell_ac_line[Lang];
    local dc_line_string        = "| " .. dictionary.cell_dc_line[Lang];
    local transformer_string    = "| " .. dictionary.cell_transformers[Lang];
    local three_winding_string  = "| " .. dictionary.cell_3wind_transformers[Lang];
    local hydro_string          = "| " .. dictionary.cell_hydro_plants[Lang];
    local pinj_string           = "| " .. dictionary.cell_power_injections[Lang];
    local renw_w_string         = "| " .. dictionary.cell_renewable_wind[Lang];
    local renw_s_string         = "| " .. dictionary.cell_renewable_solar[Lang];
    local renw_sh_string        = "| " .. dictionary.cell_renewable_small_hydro[Lang];
    local renw_csp_string       = "| " .. dictionary.cell_renewable_csp[Lang];
    local renw_oth_string       = "| " .. dictionary.cell_renewable_other[Lang];
    local thermal_string        = "| " .. dictionary.cell_thermal_plants[Lang];

    for i = 1, n_cases do
        sys_string = sys_string             .. " | " .. tostring(#System(i):labels());
        battery_string = battery_string     .. " | " .. tostring(#Battery(i):labels());

        bus_string     = bus_string        .. " | " .. tostring(#Bus(i):labels());
        ac_line_string = ac_line_string .. " | " .. tostring(#ACLine(i):labels());
        dc_line_string = dc_line_string .. " | " .. tostring(#DCLink(i):labels());
        transformer_string = transformer_string .. " | " .. tostring(#Transformer(i):labels());
        three_winding_string = three_winding_string .. " | " .. tostring(#ThreeWindingTransformer(i):labels());

        hydro_string    = hydro_string    .. " | " .. tostring(#Hydro(i):labels());
        pinj_string     = pinj_string     .. " | " .. tostring(#PowerInjection(i):labels());

        total_renw = #Renewable(i):labels();
        renw_wind  = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(1)):agents_size();
        renw_solar = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(2)):agents_size();
        renw_sh    = Renewable(i).tech_type:select_agents(Renewable(i).tech_type:eq(4)):agents_size();
        renw_oth   = total_renw - renw_wind - renw_solar - renw_sh;

        renw_csp = #ConcentratedSolarPower(i):labels();

        thermal_string  = thermal_string  .. " | " .. tostring(#Thermal(i):labels());

        renw_sh_string  = renw_sh_string  .. " | " .. tostring(renw_sh);
        renw_w_string   = renw_w_string   .. " | " .. tostring(renw_wind);
        renw_s_string   = renw_s_string   .. " | " .. tostring(renw_solar);
        renw_csp_string = renw_csp_string .. " | " .. tostring(renw_csp);
        renw_oth_string = renw_oth_string .. " | " .. tostring(renw_oth);


    end

    self:push(header_string);
    self:push(lower_header_string);
    self:push(sys_string);
    self:push(hydro_string);
    self:push(thermal_string);
    self:push(renw_w_string);
    self:push(renw_s_string);
    self:push(renw_sh_string)
    self:push(renw_oth_string);
    self:push(renw_csp_string);
    self:push(battery_string);
    self:push(pinj_string);
    self:push(bus_string);
    self:push(ac_line_string);
    self:push(dc_line_string);
    self:push(transformer_string);
    self:push(three_winding_string);
end


function Generic.username(self)
    local generic = Generic(1);
    local index = self:get_study_index();

    local user_name_file = generic:load_table_without_header("case_compare.metadata");

    local user_name = "";
    if #user_name_file >= index then
        user_name = user_name_file[index][1];
    else
        user_name = self:dirname();
    end
    return user_name;
end

function load_info_file(file_name,case_index)

    -- Initialize struct
    info_struct = {{model = ""}, {user = ""}, {version = ""}, {hash = ""}, {model = ""}, {status = ""}, {infrep = ""}, {dash_name = ""}, {cloud = ""}, {exe_mode=0}, {arch = ""}, {total_nodes = 1}, {total_processes = 1}, {processing_type = ""}};

    local toml      = Generic(case_index):load_toml(file_name);
    model           = toml:get_string("model", "-");
    user            = toml:get_string("user", "-");
    version         = toml:get_string("version", "-");
    hash            = toml:get_string("hash", "-");
    status          = toml:get_string("status", "-");
    infrep          = toml:get_string("infrep", "-");
    dash_name       = toml:get_string("dash", "-");
    cloud           = toml:get_string("cloud", "-");
    exe_mode        = toml:get_integer("mode", 0);
	arch            = toml:get_string("arch", "-");
    total_nodes     = toml:get_integer("total_nodes", 1);
    total_processes = toml:get_integer("total_process", 1);
    processing_type = toml:get_string("processing_type", "-");

    info_struct.model           = model;
    info_struct.user            = user;
    info_struct.version         = version;
    info_struct.hash            = hash;
    info_struct.status          = tonumber(status);
    info_struct.infrep          = infrep;
    info_struct.dash_name       = dash_name;
    info_struct.cloud           = cloud;
    info_struct.exe_mode        = exe_mode;
	info_struct.arch            = arch;
    info_struct.total_nodes     = total_nodes;
    info_struct.total_processes = total_processes;
    info_struct.processing_type = processing_type;

    return info_struct;
end

function load_optflow_data(file_name, case_index)
    local optflow_struct = {
        -- Dates
        initial_stage = 0, initial_year = 0,
        final_stage = 0, final_year = 0,
        
        -- Representations
        serie_representation = 0, selected_series = {},
        resolution_representation = 0, selected_resolutions = {},
        system_representation = 0, selected_systems = {},
        
        -- Objective functions (Booleanos)
        obj_min_cost_reactive = false,
        obj_min_active_losses = false,
        obj_min_desviation_active_gen = false,
        
        -- Variables Control (Booleanos)
        ctrl_gen_reactive_power = false,
        ctrl_gen_voltage = false,
        ctrl_switched_shunt = false,
        ctrl_shunt_voltage = false,
        ctrl_tap = false,
        ctrl_tap_voltage = false,
        ctrl_phase_shifter = false,
        ctrl_phase_shifter_flow = false,
        ctrl_series_cap = false,
        ctrl_series_cap_flow = false,
        ctrl_acdc_angle = false,
        ctrl_acdc_tap = false,
        ctrl_sync_reactive = false,
        ctrl_svc = false,
        ctrl_svc_voltage = false,
        
        -- Constraints (Booleanos)
        cons_flow_mw = false,
        cons_flow_mva = false,
        cons_sum_circuit_flow = false
    }

    local data = Generic(case_index):load_table_without_header(file_name)

    -- CORREÇÃO AQUI: #data[1] em vez de #data
    for i = 1, #data do
        local line = data[i][1]
        if type(line) == "string" then
            if not string.find(line, "#", 1, true) then
                local key, val_str = string.match(line, "([A-Z_]+)%s*=%s*(.+)")
                if key and val_str then
                    local val = tonumber(val_str);

                    -- Dates
                    if key == "DCNV_INIS" then optflow_struct.initial_stage = val
                    elseif key == "DCNV_INIY" then optflow_struct.initial_year = val
                    elseif key == "DCNV_ENDS" then optflow_struct.final_stage = val
                    elseif key == "DCNV_ENDY" then optflow_struct.final_year = val
                    
                    -- Series
                    elseif key == "DCNV_SSER" then optflow_struct.serie_representation = val
                    elseif key == "DCNV_VSER" then
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optflow_struct.selected_series, tonumber(num))
                        end
                        
                    -- Resolution 
                    elseif key == "DCNV_SDUR" then optflow_struct.resolution_representation = val
                    elseif key == "DCNV_VDUR" then 
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optflow_struct.selected_resolutions, tonumber(num))
                        end
                        
                    -- Systems
                    elseif key == "DCNV_SSIS" then optflow_struct.system_representation = val
                    elseif key == "DCNV_VSIS" then
                        for num in string.gmatch(val_str, "%S+") do
                            table.insert(optflow_struct.selected_systems, tonumber(num))
                        end
                        
                    -- Objective functions
                    elseif key == "DOBJ_AVAR" then optflow_struct.obj_min_cost_reactive = (val == 1)
                    elseif key == "DOBJ_LOSS" then optflow_struct.obj_min_active_losses = (val == 1)
                    elseif key == "DOBJ_DGMW" then optflow_struct.obj_min_desviation_active_gen = (val == 1)
                    
                    -- Variables Control
                    elseif key == "DCON_QGEN" then
                        if val == 1 then optflow_struct.ctrl_gen_reactive_power = true
                        elseif val == 2 then optflow_struct.ctrl_gen_voltage = true end
                        
                    elseif key == "DCON_SHNT" then
                        if val == 1 then optflow_struct.ctrl_switched_shunt = true
                        elseif val == 2 then optflow_struct.ctrl_shunt_voltage = true end
                        
                    elseif key == "DCON_TAPC" then
                        if val == 1 or val == 3 then optflow_struct.ctrl_tap = true
                        elseif val == 2 or val == 4 then optflow_struct.ctrl_tap_voltage = true end
                        
                    elseif key == "DCON_PHSS" then
                        if val == 1 then optflow_struct.ctrl_phase_shifter = true
                        elseif val == 2 then optflow_struct.ctrl_phase_shifter_flow = true end
                        
                    elseif key == "DCON_CAPS" then
                        if val == 1 then optflow_struct.ctrl_series_cap = true
                        elseif val == 2 then optflow_struct.ctrl_series_cap_flow = true end
                        
                    elseif key == "DCON_ADSP" then optflow_struct.ctrl_acdc_angle = (val == 1)
                    elseif key == "DCON_CTAP" then optflow_struct.ctrl_acdc_tap = (val ~= 0)
                    elseif key == "DCON_QSIN" then optflow_struct.ctrl_sync_reactive = (val == 1)
                    
                    elseif key == "DCON_QCER" then
                        if val == 1 then optflow_struct.ctrl_svc = true
                        elseif val == 2 then optflow_struct.ctrl_svc_voltage = true end
                        
                    -- Constraints
                    elseif key == "DCNS_FLOW" then
                        if val == 1 then optflow_struct.cons_flow_mw = true
                        elseif val == 2 then optflow_struct.cons_flow_mva = true end
                        
                    elseif key == "DCNS_SUMC" then optflow_struct.cons_sum_circuit_flow = (val == 1)
                    end
                end
            end
        end
    end
    
    return optflow_struct
end

local info_struct = {};
local optflow_data = {};
for case = 1, N_cases do
    local info_file_name = "optflow.info";
    table.insert(info_struct, load_info_file(info_file_name, case) );

    local optflow_data_file_name = "optflow.dat";
    table.insert(optflow_data, load_optflow_data(optflow_data_file_name, case) );
end

local d = Dashboard();

local summary_tab = Tab(dictionary.summary[lang]);
summary_tab:push("# " .. dictionary.case_information[lang]);
summary_tab:create_summary(N_cases, lang, info_struct, optflow_data);
d:push(summary_tab);

local tab_solution = Tab(dictionary.solutions[lang]);
tab_solution:push("# " .. dictionary.solution_quality[lang]);
tab_solution:Solution_Quality(N_cases, lang);
d:push(tab_solution);

local tab_results = Tab(dictionary.solutions[lang]);
tab_results:set_disabled();
tab_results:push("# " .. dictionary.solution_results[lang]);
tab_results:Solution_Results(N_cases, lang);
d:push(tab_results);

local tab_voltage = Tab(dictionary.voltage_profiles[lang]);
tab_voltage:push("# " .. dictionary.voltages[lang]);
tab_voltage:Voltage_Limits(N_cases, lang);
d:push(tab_voltage);

d:save("OptFlow")