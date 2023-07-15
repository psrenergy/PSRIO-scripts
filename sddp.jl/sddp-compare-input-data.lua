PSR.assert_version(">0.24.0");

-- LuaFormatter off
local collections = {
    "Area",
    "BalancingArea",
    "BalancingAreaHydro",
    "BalancingAreaThermal",
    "Battery",
    "Bus",
    "Circuit",
    "CircuitsSum",
    "ConcentratedSolarPower",
    "DCLink",
    "Demand",
    "DemandSegment",
    "ElectrificationDemand",
    "ElectrificationDemandSegment",
    "ElectrificationNetwork",
    "ElectrificationNode",
    "ElectrificationProcess",
    "ElectrificationProducer",
    "ElectrificationStorage",
    "ElectrificationTransport",
    "ExpansionCapacity",
    "ExpansionConstraint",
    "ExpansionDecision",
    "ExpansionProject",
    "FlowController",
    "Fuel",
    "FuelConsumption",
    "FuelContract",
    "FuelReservoir",
    "GasEmission",
    "GasNode",
    "Generator",
    "GenerationConstraint",
    "GenericConstraint",
    "Hydro",
    "HydroGaugingStation",
    "Interconnection",
    "InterconnectionSum",
    "Load",
    "Maintenance",
    "PowerInjection",
    "Region",
    "Renewable",
    "RenewableGaugingStation",
    "ReserveGenerationConstraint",
    "ReservoirSet",
    "System",
    "Study",
    "Thermal",
    "ThermalCombinedCycle",
};
-- LuaFormatter on

local cases = PSR.studies();

local header = "----------------------------------------------------------------------------------------------------\n";
for case = 1, cases do
    header = header .. "case " .. case .. ": " .. Study(case):path() .. "\n";
end
header = header .. "----------------------------------------------------------------------------------------------------";

local report = Report("Input data");
report:add_header(header);

for i, collection in ipairs(collections) do
    local collection_function = load("return " .. collection .. "();");
    if collection_function then
        local collection_data = collection_function();
        local inputs = collection_data:inputs();

        for _, input in ipairs(inputs) do
            local compare = Compare(collection .. "." .. input);

            local has_values = false;
            for case = 1, cases do
                local input_function = load("return " .. collection .. "(" .. case .. ")." .. input .. ";");
                if input_function then
                    local input_data = input_function();
                    compare:add(input_data);

                    if input_data:loaded() then
                        has_values = true;
                    end
                end
            end

            if has_values then
                report:push(compare);
            end
        end
    end
end

report:save("compare-input-data");
