local dashboard = Dashboard();

local study = Study(); 
local weights = study.hours;
local weights_sum = weights:aggregate_stages(BY_SUM(), Profile.PER_YEAR);

local system = System();
local cmgdem = system:load("cmgdem");

for i = 1,cmgdem:agents(),1 do
    local agent = cmgdem:agent(i);
    local label = "pld_" .. cmgdem:agent(i);
	
    local data = cmgdem:select_agents({i}):rename_agents({agent}):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()); 
    local weighted_mean = (data * weights):aggregate_stages(BY_SUM(), Profile.PER_YEAR) / weights_sum;
    weighted_mean:save(label, {csv=true});

    -- plotting
    local chart = Chart("PLD " .. agent);
    chart:push(label, "line");
    dashboard:push(chart);
end

local generic = Generic();
local function create_cache(filename, agents) 
    return generic:load(filename)
        :select_agents(macro_agents(agents))
        :aggregate_agents(BY_SUM(), agents)
        :aggregate_scenarios(BY_AVERAGE())
        :save_and_load(filename .. "_cache") 
end

local gerhid = create_cache("gerhid", "Peru-HydroH");
local gerter = create_cache("gerter", "Peru-GasCC");
local gergnd = create_cache("gergnd", "Peru-Wind");

local initial_year = gerhid:initial_year();
local final_year = gerhid:final_year();

local function mod24(data, year) return data:select_stages_by_year(year):reshape_stages(Profile.DAILY):aggregate_stages(BY_AVERAGE()):convert("MW"); end

for year = initial_year,final_year,1 do
    local label = "generation_" .. tostring(year)
    concatenate(
        mod24(gerhid, year), 
        mod24(gerter, year),
        mod24(gergnd, year)
    ):save(label, {csv=true});

    -- plotting
    local chart = Chart(tostring(year));
    chart:push(label, "line");
    dashboard:push(chart);
end

dashboard:save_style2("dashboard");