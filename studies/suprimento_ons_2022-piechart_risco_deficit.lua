-- PSR Energy Consulting and Analytics
-- Análise de suprimento para 2022 - ONS

local function create_deficit_risk_chart(dashboard, systems, case, case_description)
    gen = Generic(case);

    name = systems[1] .. " / " .. systems[2];

    -- Load deficit and demand outputs
    defcit = gen:load("defcit"):aggregate_blocks(BY_SUM()):select_agents(systems):aggregate_agents(BY_SUM(),name):select_stages_by_year(2022):reset_stages();
    demand = gen:load("demand"):aggregate_blocks(BY_SUM()):select_agents(systems):aggregate_agents(BY_SUM(),name):select_stages_by_year(2022):reset_stages();

    agg_defict = defcit:aggregate_stages(BY_SUM()):reset_stages();
    agg_demand = demand:select_stages(9, 12):aggregate_stages(BY_SUM()):reset_stages();

    -- Profundidade de déficit em relação de à demanda do período especificado
    defcit_pu = ifelse(agg_demand:ne(0.0), agg_defict/agg_demand, 0.0);

    -- Classificação das séries
    ifelse(defcit_pu:le(0.05),1,0):save("SeriesVerdesAmarelas-" .. systems[1] .. "_" .. systems[2] .. "-caso-" .. case, {csv=true});

    -- Mapeando os percentuais
    range_000_000 = ifelse(defcit_pu:eq(0.00)                   ,1,0):rename_agents("Sem racionamento"        ):aggregate_scenarios(BY_SUM()):force_unit("séries");
    range_000_005 = ifelse(defcit_pu:gt(0.00)&defcit_pu:le(0.05),1,0):rename_agents("0% < Racionamento <= 5%" ):aggregate_scenarios(BY_SUM()):force_unit("séries");
    range_005_010 = ifelse(defcit_pu:gt(0.05)&defcit_pu:le(0.10),1,0):rename_agents("5% < Racionamento <= 10%"):aggregate_scenarios(BY_SUM()):force_unit("séries");
    range_010_100 = ifelse(defcit_pu:gt(0.10)&defcit_pu:le(1.00),1,0):rename_agents("Racionamento > 10%"      ):aggregate_scenarios(BY_SUM()):force_unit("séries");

    chart = Chart("Caso " .. case .. ": " .. case_description);
    chart:add_pie(range_000_000,{color="#22B14C"});
    chart:add_pie(range_000_005,{color="#FFEC73"});
    chart:add_pie(range_005_010,{color="#FAB13B"});
    chart:add_pie(range_010_100,{color="#D82E2E"});

    dashboard:push(chart);
end

local function create_dashboard(systems)
    name = systems[1] .. " / " .. systems[2];

    dashboard = Dashboard(name);

    dashboard:push("# Análise de suprimento 2022 - " .. name);
    dashboard:push("Risco e profundidade de racionamento uniforme de setembro a dezembro.");
    dashboard:push("_Racionamento em % da demanda_");
    dashboard:push("");

    create_deficit_risk_chart(dashboard,systems,1,"Demanda ONS, sem CREG, vazões PAR(p)");
    create_deficit_risk_chart(dashboard,systems,2,"Demanda ONS, sem CREG, vazões PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,3,"Demanda ONS, sem CREG, Oferta reduzida, PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,4,"Demanda ALTA, sem CREG, Oferta reduzida, PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,5,"Demanda ALTA, com CREG, Oferta reduzida, PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,6,"Demanda ALTA, com CREG, Oferta normal, PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,7,"Demanda ALTA, sem CREG, Oferta reduzida, hidrograma IBAMA, PAR(p)-NN");
    create_deficit_risk_chart(dashboard,systems,8,"Demanda ALTA, sem CREG, Oferta reduzida, hidrograma B, PAR(p)-NN");

    return dashboard;
end

dashboard_SE_SU = create_dashboard({"SUDESTE" , "SUL"  });
dashboard_NE_NO = create_dashboard({"NORDESTE", "NORTE"});

(dashboard_SE_SU + dashboard_NE_NO):save("Suprimento_ONS_2022-Risco_Deficit");