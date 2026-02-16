--======================
-- Functions to fill charts
--======================
function add_data_to_line_charts(chart, value_real_loss, value_linear_loss, annual, stochastic)
    local variable_real_loss_avg = value_real_loss:aggregate_scenarios(BY_AVERAGE());
    local variable_linear_loss_avg = value_linear_loss:aggregate_scenarios(BY_AVERAGE());

    if OneYearCase and annual then
        chart:add_line(variable_real_loss_avg, {color=ColorTable.real_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "circle", radius = 4 }});
        chart:add_line(variable_linear_loss_avg, {color=ColorTable.real_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "circle", radius = 4 }});
    else
        chart:add_line(variable_real_loss_avg, { color = ColorTable.real_losses, dashStyle = "solid"});
        chart:add_line(variable_linear_loss_avg, { color = ColorTable.linear_losses, dashStyle = "solid"});
    end

    if stochastic then
        local variable_low_percentile_real = value_real_loss:aggregate_scenarios(BY_PERCENTILE(LowPercentile)):add_suffix(" P"..LowPercentile.." - Quadratic Losses");
        local variable_high_percentile_real = value_real_loss:aggregate_scenarios(BY_PERCENTILE(HighPercentile)):add_suffix(" P"..HighPercentile.." - Quadratic Losses");

        local variable_low_percentile_linear = value_linear_loss:aggregate_scenarios(BY_PERCENTILE(LowPercentile)):add_suffix(" P"..LowPercentile.." - Linear Losses");
        local variable_high_percentile_linear = value_linear_loss:aggregate_scenarios(BY_PERCENTILE(HighPercentile)):add_suffix(" P"..HighPercentile.." - Linear Losses");

        if OneYearCase and annual then
            chart:add_line( variable_low_percentile_real,{color=ColorTable.real_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "triangle-down", radius = 4 }} );
            chart:add_line( variable_high_percentile_real,{color=ColorTable.real_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "triangle", radius = 4 }} );
            chart:add_line( variable_low_percentile_linear,{color=ColorTable.linear_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "triangle-down", radius = 4 }} );
            chart:add_line( variable_high_percentile_linear,{color=ColorTable.linear_losses, dashStyle="solid",dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "triangle", radius = 4 }} );
        else
            chart:add_area_range(
                variable_low_percentile_real:rename_agents("(P"..LowPercentile),
                variable_high_percentile_real:rename_agents("P"..HighPercentile..")"),
                { color = ColorTable.real_losses, lineWidth = 0, fillOpacity = 0.3 }
            );

            chart:add_area_range(
                variable_low_percentile_linear:rename_agents("(P"..LowPercentile),
                variable_high_percentile_linear:rename_agents("P"..HighPercentile..")"),
                { color = ColorTable.linear_losses, lineWidth = 0, fillOpacity = 0.3 }
            );
        end
    end
end

function create_losses_tabs(tab, element_name, qdr_loss_file, linear_loss_file, flow_file)
    --======================
    -- Load Losses Datas
    --======================
    local circ_flow = Generic():load(flow_file):select_stages(1, FinalStage):convert("MW");
    local real_losses_block = Generic():load(qdr_loss_file):select_stages(1, FinalStage):convert("MW");
    local linear_losses_block = Generic():load(linear_loss_file):select_stages(1, FinalStage):convert("MW");
    linear_losses_block = linear_losses_block:select_agents(real_losses_block:agents());
    local real_losses = real_losses_block:aggregate_blocks():save_cache();
    local linear_losses = linear_losses_block:aggregate_blocks():save_cache();
    local losses_diff = (real_losses - linear_losses):save_cache();

    --======================
    -- Create and fill general losses Tab
    --======================
    local general_losses_tab = Tab("General "..element_name.." Losses");

    -- Total losses
    local chart_total_losses = Chart("Total Losses");
    chart_total_losses:horizontal_legend();

    local total_real_losses = real_losses:aggregate_agents(BY_SUM(), "Total Quadratic Losses"):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_AVERAGE());
    local total_linear_losses = linear_losses:aggregate_agents(BY_SUM(), "Total Linear Losses"):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_AVERAGE());

    chart_total_losses:add_column_categories(total_real_losses, "Total Quadratic Losses",{ color = ColorTable.real_losses});
    chart_total_losses:add_column_categories(total_linear_losses, "Total Linear Losses",{ color = ColorTable.linear_losses});

    if #chart_total_losses > 0 then
        general_losses_tab:push(chart_total_losses);
    end

    -- Total difference per stage chart
    local chart_area_stacking_diff = Chart("Total Difference - "..StageType.."ly (MW)");
    chart_area_stacking_diff:horizontal_legend();

    local total_difference_per_stage = losses_diff:aggregate_agents(BY_SUM(), "Total Losses Difference"):aggregate_scenarios(BY_AVERAGE());
    chart_area_stacking_diff:add_area_stacking(total_difference_per_stage, {color = ColorTable.difference, dataLabels = {enabled = true, format = "{point.y:,.1f}"},marker = { enabled = true, symbol = "circle", radius = 4 }}); -- TALVEZ FAZER ISSO COM P10 e P90 em um grafico normal

    if #chart_area_stacking_diff > 0 then
        general_losses_tab:push(chart_area_stacking_diff);
    end

    -- Annual and stage total losses chart
    local chart_total_annual = Chart("Total Losses - Annual (MW)");
    chart_total_annual:horizontal_legend();
    local chart_total_stage = Chart("Total Losses - "..StageType.."ly (MW)");
    chart_total_stage:horizontal_legend();

    local total_stage_real_losses = real_losses:aggregate_agents(BY_SUM(), "Total Quadratic Losses");
    local total_stage_linear_losses = linear_losses:aggregate_agents(BY_SUM(), "Total Linear Losses");

    local total_annual_real_losses = total_stage_real_losses:aggregate_stages(BY_WEIGHTED_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());
    local total_annual_linear_losses = total_stage_linear_losses:aggregate_stages(BY_WEIGHTED_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());

    --add_data_to_line_charts(chart_total_annual, total_annual_real_losses, total_annual_linear_losses, true, Stochastic);
    add_data_to_line_charts(chart_total_stage, total_stage_real_losses, total_stage_linear_losses, false, Stochastic);

    chart_total_annual:add_column(total_annual_real_losses, { color = ColorTable.real_losses});
    chart_total_annual:add_column(total_annual_linear_losses, { color = ColorTable.linear_losses});

    if #chart_total_annual > 0 then
        general_losses_tab:push(chart_total_annual);
    end
    if #chart_total_stage > 0 then
        general_losses_tab:push(chart_total_stage);
    end

    --======================
    -- Create and fill loss by circuit Tab
    --======================
    local losses_by_bus_tab = Tab("Losses by "..element_name);

    -- column_categories chart
    local chart_column_category = Chart("Largest Absolute Differences in Losses per "..element_name.." (MW)");

    local abs_losses_diff = losses_diff:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_AVERAGE()):round(3):remove_zeros():abs();
    abs_losses_diff = abs_losses_diff:select_largest_agents(#abs_losses_diff:agents());
    chart_column_category:add_column_categories(abs_losses_diff, "", { showInLegend = false});

    if #chart_column_category > 0 then
        losses_by_bus_tab:push(chart_column_category);
    end

    -- annual and per stage value of losses for each of the 10 largest diff plants
    for i, agent in ipairs(abs_losses_diff:select_largest_agents(N_LARGESST_CIRCUITS_TO_GET):agents()) do
        if i == 1 then
            losses_by_bus_tab:push("## Linear and quadratic losses for the "..N_LARGESST_CIRCUITS_TO_GET.." "..element_name.." with the largest absolute difference in them");
        end
        local chart_annual = Chart(agent.." Losses - Annual (MW)");
        local chart_stage = Chart(agent.." Losses - "..StageType.."ly (MW)");
        local chart_scatter_plot = Chart(agent.." Losses by "..element_name.." Flow (MW)");

        chart_annual:horizontal_legend();
        chart_stage:horizontal_legend();
        chart_scatter_plot:horizontal_legend();

        local agent_real_losses = real_losses:select_agent(agent):add_suffix(" - Quadratic Losses");
        local agent_linear_losses = linear_losses:select_agent(agent):add_suffix(" - Linear Losses");

        local annual_agent_real_losses = agent_real_losses:aggregate_stages(BY_WEIGHTED_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());
        local annual_agent_linear_losses = agent_linear_losses:aggregate_stages(BY_WEIGHTED_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());

        --add_data_to_line_charts(chart_annual, annual_agent_real_losses, annual_agent_linear_losses, true, Stochastic);
        add_data_to_line_charts(chart_stage, agent_real_losses, agent_linear_losses, false, Stochastic);

        chart_annual:add_column(annual_agent_real_losses, { color = ColorTable.real_losses});
        chart_annual:add_column(annual_agent_linear_losses, { color = ColorTable.linear_losses});

        chart_scatter_plot:add_scatter(circ_flow:select_agent(agent), linear_losses_block:select_agent(agent), "Linear Losses", { color = ColorTable.linear_losses, marker = { enabled = true, symbol = "circle", radius = 2 }});
        chart_scatter_plot:add_scatter(circ_flow:select_agent(agent), real_losses_block:select_agent(agent), "Quadratic Losses", {color = ColorTable.real_losses, marker = { enabled = true, symbol = "square", radius = 2 }});

        if #chart_annual > 0 then
            losses_by_bus_tab:push(chart_annual);
        end
        if #chart_stage > 0 then
            losses_by_bus_tab:push(chart_stage);
        end
        if #chart_scatter_plot > 0 then
            losses_by_bus_tab:push(chart_scatter_plot);
        end
    end

    --======================
    -- Push tabs in the Macro Tab
    --======================
    if #general_losses_tab > 0 then
        tab:push(general_losses_tab);
    end
    if #losses_by_bus_tab > 0 then
        tab:push(losses_by_bus_tab);
    end
end


--======================
-- Setting the color for each type of data
--======================
ColorTable = {
    real_losses = "#4E79A7",
    linear_losses = "#F28E2B",
    difference = "red",
};

--======================
-- Checking if the PSRIO version is compatible with this script
--======================
PsrioVersion = PSR.version();
if tonumber(string.sub(PsrioVersion,1,3)) < 1.3 then
  error("This script cannot be run in this version of PSRIO, update to version 1.3.0 or higher");
end

--======================
-- Getting case informations
--======================
-- get the low and high percentile
LowPercentile = 10;
HighPercentile = 90;

-- Getting if the case is deterministic or stochastic
Stochastic = true;
local scenario_number = Study():scenarios();
if scenario_number < 1 then
    error("It was not possible to find the number of series in the sddp case");
elseif scenario_number == 1 then
    Stochastic = false;
end

-- Get the stage type of the case
StageType = "Month";
if Study():stage_type() == 1 then
    StageType = "Week";
end

-- check if the case has more than one year
OneYearCase = false;
if Study():initial_year() == Study():final_year_without_buffer_years() then
    OneYearCase = true;
end

-- Getting the final year
FinalStage = Study():stages_without_buffer_years();

-- Number of circuits with largest losses to represent in the dashboard
N_LARGESST_CIRCUITS_TO_GET = 10

--======================
-- Create and fill tabs
--======================
local tab_ac_circuit = Tab("AC Circuit");
tab_ac_circuit:set_disabled();
tab_ac_circuit:set_collapsed(true);
create_losses_tabs(tab_ac_circuit, "Circuit", "qdrlss", "losses", "cirflw");

local tab_dc_link = Tab("DC Line");
tab_dc_link:set_disabled();
tab_dc_link:set_collapsed(true);
create_losses_tabs(tab_dc_link, "DC line", "qdrlssdl", "loslnk", "dclink");

local tab_transformers = Tab("Transformers");
tab_transformers:set_disabled();
tab_transformers:set_collapsed(true);
create_losses_tabs(tab_transformers, "transformers", "transformer_quadraticlosses", "transformer_losses", "transformer_flow");

local tab_three_winding_transformers = Tab("Three Winding Transformers");
tab_three_winding_transformers:set_disabled();
tab_three_winding_transformers:set_collapsed(true);
create_losses_tabs(tab_three_winding_transformers, "three winding transformers", "threewindingtransformer_quadratic_losses", "threewindingtransformer_losses", "threewindingtransformer_flow");

local tab_capacitors = Tab("Series Capacitor");
tab_capacitors:set_disabled();
tab_capacitors:set_collapsed(true);
create_losses_tabs(tab_capacitors, "series capacitor", "seriescapacitor_quadratic_losses", "seriescapacitor_losses", "seriescapacitor_flow");

--======================
-- Create Dashboard and Push Tabs
--======================
local dashboard = Dashboard();

if #tab_ac_circuit > 0 then dashboard:push(tab_ac_circuit) end
if #tab_dc_link > 0 then dashboard:push(tab_dc_link) end
if #tab_transformers > 0 then dashboard:push(tab_transformers) end
if #tab_three_winding_transformers > 0 then dashboard:push(tab_three_winding_transformers) end
if #tab_capacitors > 0 then dashboard:push(tab_capacitors) end

dashboard:save("Dashboard_losses");
