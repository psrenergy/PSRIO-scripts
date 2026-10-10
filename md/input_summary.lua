-- C:\Users\iury\Desktop\PSRio_Atual\psrio.exe --model SDDP -r "D:\PSRIO-scripts\md\input_summary.lua" "C:\PSR\Sddp17.2\Example\Hourly_representation\Case27"

local studies<const> = PSR.studies();

-- COLLECTIONS
local area<const> = {};
local balancingarea<const> = {};
local balancingareahydro<const> = {};
local balancingareathermal<const> = {};
local battery<const> = {};
local bus<const> = {};
local circuit<const> = {};
local circuitssum<const> = {};
local concentratedsolarpower<const> = {};
local dclink<const> = {};
local demand<const> = {};
local demandsegment<const> = {};
local electrificationdemand<const> = {};
local electrificationdemandsegment<const> = {};
local electrificationnetwork<const> = {};
local electrificationnode<const> = {};
local electrificationprocess<const> = {};
local electrificationproducer<const> = {};
local electrificationstorage<const> = {};
local electrificationtransport<const> = {};
local expansioncapacity<const> = {};
local expansionconstraint<const> = {};
local expansiondecision<const> = {};
local expansionproject<const> = {};
local flowcontroller<const> = {};
local fuel<const> = {};
local fuelconsumption<const> = {};
local fuelcontract<const> = {};
local fuelreservoir<const> = {};
local gasemission<const> = {};
local gasnode<const> = {};
local generator<const> = {};
local generationconstraint<const> = {};
local generic<const> = {};
local genericconstraint<const> = {};
local hydro<const> = {};
local hydrogaugingstation<const> = {};
local interconnection<const> = {};
local interconnectionsum<const> = {};
local maintenance<const> = {};
local powerinjection<const> = {};
local region<const> = {};
local renewable<const> = {};
local renewablegaugingstation<const> = {};
local reservegenerationconstraint<const> = {};
local reservoirset<const> = {};
local system<const> = {};
local study<const> = {};
local thermal<const> = {};
local thermalcombinedcycle<const> = {};

-- colors
local colors<const> = {
    inelastic_demand  = "#082B70",
    elastic_demand  = "#3AB495",
    thermal = "#F28E2B",
    hydro = "#4E79A7",
    solar = "#F1CE63",
    wind = "#8CD17D",
    renewable = "#8a8881",
    csp = "#b0ada4",
    battery = "#FF9DA7",
};

-- dictionary
local dictionary<const> = {
    tab_name = {
        en = "Summary",
        es = "Resumem",
        pt = "Resumo"
    },
    inelastic_demand = {
        en = "Demand",
        es = "Demanda",
        pt = "Demanda"
    },
    elastic_demand = {
        en = "Elastic demand",
        es = "Demanda elástica",
        pt = "Demanda elástica"
    },
    thermal_capacity = {
        en = "Thermal capacity",
        es = "Capacidad térmica",
        pt = "Capacidade térmica"
    },
    hydro_capacity = {
        en = "Hydro capacity",
        es = "Capacidad hidrica",
        pt = "Capacidade hidrica"
    },
    solar_capacity = {
        en = "Solar capacity",
        es = "Capacidad solar",
        pt = "Capacidade solar"
    },
    wind_capacity = {
        en = "Wind capacity",
        es = "Capacidad eólica",
        pt = "Capacidade eólica"
    },
    Others_renewables_capacity = {
        en = "Other renewables capacity",
        es = "Capacidad de otras energías renovables",
        pt = "Capacidade de outras energias renováveis"
    },
    csp_capacity = {
        en = "CSP capacity",
        es = "Capacidad CSP",
        pt = "Capacidade CSP"
    },
    battery_capacity = {
        en = "Battery capacity",
        es = "Capacidad de batería",
        pt = "Capacidade da bateria"
    },
    capacity_by_tech = {
        en = "Technology Capacity",
        es = "Capacidad per Tecnología",
        pt = "Capacidade por tecnologia"
    },
    capacity_mix = {
        en = "Capacity mix",
        es = "Mezcla de capacidad",
        pt = "Mix de capacidade"
    },
    injections = {
        en = "Injections",
        es = "Inyecciones",
        pt = "Injeções"
    },
    inflows = {
        en = "Inflows",
        es = "Aportes",
        pt = "Afluências"
    },
    system = {
        en = "System",
        es = "Sistema",
        pt = "Sistema"
    },
    capacity = {
        en = "Capacity",
        es = "Capacidad",
        pt = "Capacidade"
    }
};

for i = 1, studies do
    table.insert(area, Area(i));
    table.insert(balancingarea, BalancingArea(i));
    table.insert(balancingareahydro, BalancingAreaHydro(i));
    table.insert(balancingareathermal, BalancingAreaThermal(i));
    table.insert(battery, Battery(i));
    table.insert(bus, Bus(i));
    table.insert(circuit, Circuit(i));
    table.insert(circuitssum, CircuitsSum(i));
    table.insert(concentratedsolarpower, ConcentratedSolarPower(i));
    table.insert(dclink, DCLink(i));
    table.insert(demand, Demand(i));
    table.insert(demandsegment, DemandSegment(i));
    table.insert(electrificationdemand, ElectrificationDemand(i));
    table.insert(electrificationdemandsegment, ElectrificationDemandSegment(i));
    table.insert(electrificationnetwork, ElectrificationNetwork(i));
    table.insert(electrificationnode, ElectrificationNode(i));
    table.insert(electrificationprocess, ElectrificationProcess(i));
    table.insert(electrificationproducer, ElectrificationProducer(i));
    table.insert(electrificationstorage, ElectrificationStorage(i));
    table.insert(electrificationtransport, ElectrificationTransport(i));
    table.insert(expansioncapacity, ExpansionCapacity(i));
    table.insert(expansionconstraint, ExpansionConstraint(i));
    table.insert(expansiondecision, ExpansionDecision(i));
    table.insert(expansionproject, ExpansionProject(i));
    table.insert(flowcontroller, FlowController(i));
    table.insert(fuel, Fuel(i));
    table.insert(fuelconsumption, FuelConsumption(i));
    table.insert(fuelcontract, FuelContract(i));
    table.insert(fuelreservoir, FuelReservoir(i));
    table.insert(gasemission, GasEmission(i));
    table.insert(gasnode, GasNode(i));
    table.insert(generator, Generator(i));
    table.insert(generationconstraint, GenerationConstraint(i));
    table.insert(generic, Generic(i));
    table.insert(genericconstraint, GenericConstraint(i));
    table.insert(hydro, Hydro(i));
    table.insert(hydrogaugingstation, HydroGaugingStation(i));
    table.insert(interconnection, Interconnection(i));
    table.insert(interconnectionsum, InterconnectionSum(i));
    table.insert(maintenance, Maintenance(i));
    table.insert(powerinjection, PowerInjection(i));
    table.insert(region, Region(i));
    table.insert(renewable, Renewable(i));
    table.insert(renewablegaugingstation, RenewableGaugingStation(i));
    table.insert(reservegenerationconstraint, ReserveGenerationConstraint(i));
    table.insert(reservoirset, ReservoirSet(i));
    table.insert(system, System(i));
    table.insert(study, Study(i));
    table.insert(thermal, Thermal(i));
    table.insert(thermalcombinedcycle, ThermalCombinedCycle(i));
end

-- get language
local function get_language(case)
    local language<const> = study[case]:get_parameter("Idioma", 0);
    if language == 1 then
        return "es";
    elseif language == 2 then
        return "pt";
    else -- language == 0
        return "en";
    end
end
local language = get_language(1);

local function demand_hourly(case)
    local generic = Generic(case);
    local sddp = generic:load_table_without_header("sddp.dat");

    for key = 1,#sddp do
        if string.sub(sddp[key][1],1,9) == "DCHR LOAD" then
            if string.sub(sddp[key][1],11,11) == "1" then
                return true
            end
        end
    end

    return false
end
local demand_is_hourly = demand_hourly(1)

local function create_tab(label, icon)
    local tab = Tab(label);
    tab:set_icon(icon);
    tab:push("# " .. label);
    return tab;
end


local function create_prefix(label)
    local prefix = "";
    if studies > 1 then
        prefix = "|" .. label;
    end
    return prefix;
end

local function demand_data(case, tab)
    local demand = demand[case];
    local study  = study[case];
    local system = system[case];

    local demand_data;
    if demand_is_hourly then
        demand_data = system.sensitivity * demand.inelastic_hour:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM(),Profile.PER_YEAR);
    else
        demand_data = system.sensitivity * demand.inelastic_block:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM(),Profile.PER_YEAR);
    end

    if demand_data:loaded() then
        -- local chart = Chart();
        -- chart:add_column(demand_data);
        -- tab:push("## " .. dictionary.inelastic_demand[language]);
        -- tab:push(chart);
        demand_data:save("demanda_MD",{fast_csv = true})
    end

end

local function capacity_data(case, tab)
    local thermal = thermal[case];
    local hydro = hydro[case];
    local battery = battery[case];
    local renewable = renewable[case];
    local system = system[case];

    local thermal_capacity = ifelse(thermal.state:ne(1),thermal.max_generation_available,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local hydro_capacity = ifelse(hydro.state:ne(1),hydro.max_generation_available,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local renewable_capacity = ifelse(renewable.state:ne(1) & renewable.tech_type:ne(2) & renewable.tech_type:ne(1) & renewable.tech_type:ne(5),renewable.capacity,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local solar_capacity = ifelse(renewable.state:ne(1) & renewable.tech_type:eq(2),renewable.capacity,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local wind_capacity = ifelse(renewable.state:ne(1) & renewable.tech_type:eq(1),renewable.capacity,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local csp_capacity = ifelse(renewable.state:ne(1) & renewable.tech_type:eq(5),renewable.capacity,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    local battery_capacity = ifelse(battery.state:ne(1),battery.capacity,0):aggregate_agents(BY_SUM(),Collection.SYSTEM):aggregate_stages(BY_SUM(),Profile.PER_YEAR):select_stage(1);
    
    local some_data_loaded = thermal_capacity:loaded() or
                             hydro_capacity:loaded() or
                             solar_capacity:loaded() or
                             wind_capacity:loaded() or
                             renewable_capacity:loaded() or
                             csp_capacity:loaded() or
                             battery_capacity:loaded();

    if some_data_loaded then
        -- local chart = Chart();
        -- chart:add_categories(thermal_capacity, dictionary.thermal_capacity[language],
        --                                                         {xLabel = dictionary.system[language],
        --                                                          yLabel = dictionary.capacity[language]});
        -- chart:add_categories(hydro_capacity,  dictionary.hydro_capacity[language]);
        -- chart:add_categories(solar_capacity,  dictionary.solar_capacity[language]);
        -- chart:add_categories(wind_capacity,  dictionary.wind_capacity[language]);
        -- chart:add_categories(renewable_capacity,  dictionary.Others_renewables_capacity[language]);
        -- chart:add_categories(csp_capacity,  dictionary.csp_capacity[language]);
        -- chart:add_categories(battery_capacity,  dictionary.battery_capacity[language]);
        -- tab:push("## " .. dictionary.capacity_by_tech[language]);
        -- tab:push(chart);

        -- local chart = Chart();
        -- chart:add_pie(thermal_capacity:aggregate_agents(BY_SUM(),dictionary.thermal_capacity[language]));
        -- chart:add_pie(hydro_capacity:aggregate_agents(BY_SUM(),dictionary.hydro_capacity[language]));
        -- chart:add_pie(solar_capacity:aggregate_agents(BY_SUM(),dictionary.solar_capacity[language]));
        -- chart:add_pie(wind_capacity:aggregate_agents(BY_SUM(),dictionary.wind_capacity[language]));
        -- chart:add_pie(renewable_capacity:aggregate_agents(BY_SUM(),dictionary.wind_capacity[language]));
        -- chart:add_pie(csp_capacity:aggregate_agents(BY_SUM(),dictionary.csp_capacity[language]));
        -- chart:add_pie(battery_capacity:aggregate_agents(BY_SUM(),dictionary.battery_capacity[language]));
        -- tab:push("## " .. dictionary.capacity_mix[language]);
        -- tab:push(chart);
    
        local concatenate_data = {};
        local concatenate_data_percent = {};
        for _,system in ipairs(system:labels()) do
            local concatenate_capacity = concatenate(thermal_capacity:select_agents({system}):add_suffix("_" .. dictionary.thermal_capacity[language]),
                                                     hydro_capacity:select_agents({system}):add_suffix("_" .. dictionary.hydro_capacity[language]),
                                                     solar_capacity:select_agents({system}):add_suffix("_" .. dictionary.solar_capacity[language]),
                                                     wind_capacity:select_agents({system}):add_suffix("_" .. dictionary.wind_capacity[language]),
                                                     renewable_capacity:select_agents({system}):add_suffix("_" .. dictionary.Others_renewables_capacity[language]),
                                                     csp_capacity:select_agents({system}):add_suffix("_" .. dictionary.csp_capacity[language]),
                                                     battery_capacity:select_agents({system}):add_suffix("_" .. dictionary.battery_capacity[language])
                                                    );
            local total_capacity = concatenate_capacity:aggregate_agents(BY_SUM(),"Total_Capacity");
            table.insert(concatenate_data,concatenate_capacity);
            table.insert(concatenate_data_percent,(concatenate_capacity/total_capacity):convert("%"));
        end
        concatenate(concatenate_data):save("capacity_MD",{fast_csv = true})
        concatenate(concatenate_data_percent):save("capacity_MD_percent",{fast_csv = true})
    end

end

-- local dashboard<const> = Dashboard();
-- local tab = create_tab(dictionary.tab_name[language],"book-open");
demand_data(1, tab)
capacity_data(1, tab)
-- dashboard:push(tab);
-- dashboard:save("dashboard");