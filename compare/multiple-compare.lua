local labels = {"Case 1", "Case 2", "Case 3", "Case 4", "Case 5", "Case 6"}
N = #labels
local cases = {}
for i=1,N do
    cases[i] = Generic(i)
end

local report = Report("Multiple cases compare");

local function compare_outputs(dashboard, filename, title, blocks_aggregation)
    local output = {}
    for i=1,N do
        output[i] = cases[i]:load(filename);
    end

    if output[1]:loaded() then
        local compare = Compare(filename);
        for i=1,N do
            compare:add(output[i]);
        end
        report:push(compare);

        local chart = Chart(title);
        for i=1,N do
            chart:add_line(output[i]:aggregate_blocks(blocks_aggregation):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), labels[i]));
        end
        dashboard:push(chart);
    end
end

local function compare_outputs_convergence(dashboard, filename, agent)

    local output = {}
    for i=1,N do
        output[i] = cases[i]:load(filename):set_initial_year(1970);
    end

    if output[1]:loaded() then
        local compare = Compare(filename);
        for i=1,N do
            compare:add(output[i]);
        end
        report:push(compare);

        local chart = Chart(agent);
        for i=1,N do
            chart:add_line(output[i]:select_agents{agent}:rename_agents{labels[i]});
        end
        dashboard:push(chart);
    end
end

local function compare_outputs_agent(dashboard, filename, agent, blocks_aggregation)

    local output = {}
    for i=1,N do
        output[i] = cases[i]:load(filename);
    end

    if output[1]:loaded() then
        local compare = Compare(filename);
        for i=1,N do
            compare:add(output[i]);
        end
        report:push(compare);

        local chart = Chart(agent);
        for i=1,N do
            chart:add_line(output[i]:aggregate_blocks(blocks_aggregation):aggregate_scenarios(BY_AVERAGE()):select_agents{agent}:rename_agents{labels[i]});
        end
        dashboard:push(chart);
    end
end

local total_costs = Dashboard("Total Costs");
compare_outputs_agent(total_costs, "objcop", "Total Cost", BY_SUM());
compare_outputs_agent(total_costs, "objcop", "T. Ope. Cost", BY_SUM());
compare_outputs_agent(total_costs, "objcop", "SpillPenal", BY_SUM());
compare_outputs_agent(total_costs, "objcop", "AlerSPenal", BY_SUM());
compare_outputs_agent(total_costs, "objcop", "GenCtrPen", BY_SUM());
compare_outputs(total_costs, "coster", "Thermal Cost", BY_SUM());
compare_outputs(total_costs, "defcos", "Deficit Cost", BY_SUM());

local marg_costs = Dashboard("Marginal Costs");
compare_outputs(marg_costs, "cmgdem", "Load Marginal Cost", BY_AVERAGE());
compare_outputs(marg_costs, "cmgbus", "Bus Marginal Cost", BY_AVERAGE());
compare_outputs(marg_costs, "cmgcir", "Circuit Marginal Cost", BY_AVERAGE());

local system = Dashboard("System");
compare_outputs(system, "enever", "Spilled energy of the system", BY_AVERAGE());
compare_outputs(system, "demand", "Total load supplied", BY_AVERAGE());

local water = Dashboard("Water Storage");
compare_outputs(water, "volini", "Initial Storage", BY_SUM());
compare_outputs(water, "volfin", "Final Storage", BY_SUM());
compare_outputs(water, "qverti", "Spilled Outflow", BY_SUM());
compare_outputs(water, "qturbi", "Turbined Outflow", BY_SUM());

local generation = Dashboard("Generation");
compare_outputs(generation, "gerhid", "Hydro Generation", BY_SUM());
compare_outputs(generation, "gergnd", "Renewable Generation", BY_SUM());
compare_outputs(generation, "gerter", "Thermal Generation", BY_SUM());
compare_outputs(generation, "defcit", "Deficit", BY_SUM());

local network = Dashboard("Network");
compare_outputs(network, "angulo", "AC Bus voltage angle", BY_SUM());
compare_outputs(network, "cirflw", "AC Circuit flow", BY_SUM());
compare_outputs(network, "defbus", "Deficit in each node of the system", BY_SUM());
compare_outputs(network, "interc", "Interconnection flow between systems", BY_SUM());

local convergence = Dashboard("Convergence");
compare_outputs_convergence(convergence, "sddpconv", "Zsup");
compare_outputs_convergence(convergence, "sddpconv", "Zinf");
compare_outputs_convergence(convergence, "sddpconv", "Gap");
compare_outputs_convergence(convergence, "sddptimed", "Backward");
compare_outputs_convergence(convergence, "sddptimed", "Forward");

report:save("multiple_compare");
(total_costs + marg_costs + system + generation + water + network + convergence):save("multiple_compare");


-- balanc.hdr
-- capint1.hdr
-- cmgint.hdr
-- coster.hdr
-- dclink.hdr
-- defbusp.hdr
-- defcit.hdr
-- defcos.hdr
-- demamw.hdr
-- demand.hdr
-- demxba.hdr
-- dfbind.hdr
-- duraci.hdr
-- duracipu.hdr
-- earm65.hdr
-- earmzm.hdr
-- enaf65.hdr
-- enaflu.hdr
-- enearm.hdr
-- enearm65.hdr
-- eneemb.hdr
-- enever.hdr
-- envehd.hdr
-- excbus.hdr
-- excsis.hdr
-- gergnd.hdr
-- gerhid.hdr
-- gerter.hdr
-- hblock.hdr
-- inflow.hdr
-- interc.hdr
-- maxflw.hdr
-- objcop.hdr
-- pmnter.hdr
-- qmaxim.hdr
-- qminim.hdr
-- scenarioyearmap.hdr
-- sumcir.hdr
-- vergnd.hdr
-- volini.hdr
-- wdrbus.hdr

    -- "coster" 
    -- "defcit" 
    -- "volfin" 
    -- "fprodt"
    -- "qverti" 
    -- "qturbi" 
    -- "interc" 
    -- "cirflw"
    -- "enever" 
    -- "volini" 
    -- "fuelcn" 
    -- "cmgcir"
    -- "rrodhd" 
    -- "rrodtr" 
    -- "cmgrrt" 
    -- "cmgrrh"
    -- "penreg" 
    -- "cmgreg" 
    -- "vrestg"