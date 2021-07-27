local dashboard = Dashboard();

local circuit = require("collection/circuit");
local losses = circuit:load("opt2_losses");
local cirflow = circuit:load("opt2_cirflow");
local circap = circuit:load("opt2_circap");

local function add_typical_days(dashboard, title, data)
    for season = 1,data:stages(),1 do
        local data_season = data:select_stages(season):reshape_stages(Profile.DAILY):reset_stages();

        local to_concatenate = {};
        for typical_day = 1,data_season:stages(),1 do
            local item = data_season:select_stages(typical_day):reset_stages():rename_agents({"typical day " .. tostring(typical_day)});
            table.insert(to_concatenate, item);
        end

        local label = title .. " Season " .. tostring(season);
        concatenate(to_concatenate):save(label);
        dashboard:push(Chart(title .. " Season " .. tostring(season)):push(label, "line"));
    end    
end

local data = losses:aggregate_scenarios(BY_SUM()):aggregate_agents(BY_SUM(), "agents"):force_hourly();
add_typical_days(dashboard, "Losses", data);

local data = (losses / circap):aggregate_scenarios(BY_SUM()):aggregate_agents(BY_AVERAGE(), "agents"):force_hourly();
add_typical_days(dashboard, "Losses per Capacity", data);

local data = (ifelse(cirflow:eq(0), 0, losses / cirflow:abs())):aggregate_scenarios(BY_SUM()):aggregate_agents(BY_AVERAGE(), "agents"):force_hourly();
add_typical_days(dashboard, "Losses per Flow", data);

dashboard:save_style1("tales");
dashboard:save_style2("tales");

