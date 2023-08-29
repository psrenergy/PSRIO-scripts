-- C:\Users\iury\Desktop\PSRio_Atual\psrio.exe --model OPTGEN -r "D:\PSRIO-scripts\md\input_relatory.lua" "D:\Dropbox (PSR)\PSR_main\OPTGEN\DASHBOARD\caso_timing"

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

local function get_study_parameter(i, key, true_value)
    if study[i]:get_parameter(key, -1) == true_value then
        return "yes";
    else
        return "no";
    end
end

function Tab.push_cases_header(self)
    local row = "| Case Parameter | ";
    for i = 1, studies do
        row = row .. generic[i]:dirname() .. " | ";
    end
    self:push(row);

    local row = "|:-:| ";
    for i = 1, studies do
        row = row .. ":-:|";
    end
    self:push(row);
end

function Tab.push_collections_size(self, label, collection)
    local row = "| " .. label .. " | ";
    for i = 1, studies do
        row = row .. #collection[i] .. " | ";
    end
    self:push(row);
end

local function tab_info()
    local tab<const> = create_tab("Info", "info");

    tab:push("## Summary");

    tab:push_cases_header();

    local row = "| Execution Type | ";
    for i = 1, studies do
        local execution_type = "Policy";
        if study[i]:get_parameter("Objetivo", -1) == 2 then
            execution_type = "Simulation";
        end
        row = row .. execution_type .. " | ";
    end
    tab:push(row);

    local row = "| Stage Type | ";
    for i = 1, studies do
        local stage_type = "Unknow";
        if study[i]:stage_type() == 1 then
            stage_type = "Weekly";
        elseif study[i]:stage_type() == 2 then
            stage_type = "Monthly";
        end
        row = row .. stage_type .. " | ";
    end
    tab:push(row);

    local row = "| Stages | ";
    for i = 1, studies do
        local stages = study[i]:stages();
        row = row .. stages .. " | ";
    end
    tab:push(row);

    local row = "| Initial Year of Study | ";
    for i = 1, studies do
        local initial_year = study[i]:initial_year();
        row = row .. initial_year .. " | ";
    end
    tab:push(row);

    local row = "| Blocks | ";
    for i = 1, studies do
        local blocks = study[i]:get_parameter("NumberBlocks", 0);
        row = row .. blocks .. " | ";
    end
    tab:push(row);

    local row = "| Forward Series | ";
    for i = 1, studies do
        local scenarios = study[i]:scenarios();
        row = row .. scenarios .. " | ";
    end
    tab:push(row);

    local row = "| Backward Series | ";
    for i = 1, studies do
        local openings = study[i]:openings();
        row = row .. openings .. " | ";
    end
    tab:push(row);

    local row = "| Hourly Representation | ";
    for i = 1, studies do
        local hourly = get_study_parameter(i, "SIMH", 2);
        row = row .. hourly .. " | ";
    end
    tab:push(row);

    local row = "| Network Representation | ";
    for i = 1, studies do
        local network = get_study_parameter(i, "Rede", 1);
        row = row .. network .. " | ";
    end
    tab:push(row);

    local row = "| Typical Days Representation | ";
    for i = 1, studies do
        local typical_days = get_study_parameter(i, "TDAY", 1);
        row = row .. typical_days .. " | ";
    end
    tab:push(row);

    tab:push("## Dimensions");

    tab:push_cases_header();
    tab:push_collections_size("Systems", system);
    tab:push_collections_size("Hydro Plants", hydro);
    tab:push_collections_size("Thermal Plants", thermal);
    tab:push_collections_size("Renewable Plants", renewable);
    tab:push_collections_size("Batteries", battery);
    tab:push_collections_size("Power Injections", powerinjection);
    tab:push_collections_size("Interconnections", interconnection);

    return tab;
end

local dashboard<const> = Dashboard();
dashboard:push(tab_info());
dashboard:save("dashboard");