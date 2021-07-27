local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

local dashboard = Dashboard();

local system = require("collection/system");
local cmgdem = system:load("cmgdem");

local hydro = require("collection/hydro");
local gerhid = hydro:load("gerhid");

local thermal = require("collection/thermal");
local gerter = thermal:load("gerter");

local renewable = require("collection/renewable");
local wind = renewable.tech_type:eq(1);
local solar = renewable.tech_type:eq(2);
local biomass = renewable.tech_type:eq(3);
local gergnd = renewable:load("gergnd");

local battery = require("collection/battery")
local gerbat = battery:load("gerbat");

-- CAPACITY -- 
concatenate(
    thermal.capacity:aggregate_agents(BY_SUM(), "Thermal Capacity"),
    hydro.capacity:aggregate_agents(BY_SUM(), "Hydro Capacity"),
    renewable.capacity:aggregate_agents(BY_SUM(), "Renewable Capacity")
):aggregate_stages(BY_SUM()):save("capacity");

local chart = Chart("Capacity");
chart:push("capacity", "pie");
dashboard:push(chart);

thermal.capacity:aggregate_agents(BY_SUM(), "Thermal Capacity"):aggregate_stages(BY_SUM(), Profile.PER_YEAR):save("thermal_capacity");
hydro.capacity:aggregate_agents(BY_SUM(), "Hydro Capacity"):aggregate_stages(BY_SUM(), Profile.PER_YEAR):save("hydro_capacity");
renewable.capacity:aggregate_agents(BY_SUM(), "Renewable Capacity"):aggregate_stages(BY_SUM(), Profile.PER_YEAR):save("renewable_capacity");

local chart = Chart("Capacity Per Year");
chart:push("thermal_capacity", "column_stacking");
chart:push("hydro_capacity", "column_stacking");
chart:push("renewable_capacity", "column_stacking");
dashboard:push(chart);

-- GENERATION --
local generation = concatenate(
    gerter:aggregate_agents(BY_SUM(), "Thermal"),
    gerhid:aggregate_agents(BY_SUM(), "Hydro"),
    gergnd:select_agents(wind):aggregate_agents(BY_SUM(), "Wind"),
    gergnd:select_agents(solar):aggregate_agents(BY_SUM(), "Solar"),
    gergnd:select_agents(biomass):aggregate_agents(BY_SUM(), "Biomass"),
    gerbat:aggregate_agents(BY_SUM(), "Battery"):convert("GWh")
);
generation:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):save("generation");

local chart = Chart("Generation");
chart:push("generation", "area_stacking");
dashboard:push(chart);

local generation_month = generation
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_AVERAGE(), Profile.PER_MONTH)
    :save_and_load("generation_per_month");

dashboard:column_mode(3);
local stages = generation_month:stages();
for stage = 1,stages,1 do
    local month = months[generation_month:month(stage)];
    local label = "generation_" .. month;
    
    generation_month:select_stages(stage):reshape_stages(Profile.DAILY):aggregate_stages(BY_AVERAGE()):save(label)

    local chart = Chart("Generation " .. month);
    chart:push(label, "area_stacking");
    dashboard:push(chart);
end    
dashboard:row_mode();

-- RENEWABLE GENERATION --
gergnd:select_agents(wind):aggregate_agents(BY_SUM(), "Wind"):aggregate_scenarios(BY_AVERAGE()):save("wind_generation");
gergnd:select_agents(solar):aggregate_agents(BY_SUM(), "Solar"):aggregate_scenarios(BY_AVERAGE()):save("solar_generation");

local chart = Chart("Generation");
chart:push("wind_generation", "line");
chart:push("solar_generation", "line");
dashboard:push(chart);

local gergnd_per_month = gergnd
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_AVERAGE(), Profile.PER_MONTH)
    :save_and_load("gergnd_per_month");

dashboard:column_mode(3);
local stages = gergnd_per_month:stages();
for stage = 1,stages,1 do
    local month = months[gergnd_per_month:month(stage)];
    local label = "gergnd_" .. month;
    
    local data = gergnd_per_month:select_stages(stage):reshape_stages(Profile.DAILY):aggregate_stages(BY_AVERAGE());
    
    concatenate(
        data:select_agents(solar):aggregate_agents(BY_SUM(), "Solar"),
        data:select_agents(wind):aggregate_agents(BY_SUM(), "Wind"),
        data:select_agents(biomass):aggregate_agents(BY_SUM(), "Biomass")
    ):save(label)

    local chart = Chart("Renewable Generation " .. month);
    chart:push(label, "line");
    dashboard:push(chart);
end    
dashboard:row_mode();

dashboard:save_style2("dashboard");

-- concatenate(
--     gerhid:aggregate_agents(BY_SUM(), "Hydro"):aggregate_scenarios(BY_AVERAGE()),
--     gerter:aggregate_agents(BY_SUM(), "Thermal"):aggregate_scenarios(BY_AVERAGE()),
--     gergnd:aggregate_agents(BY_SUM(), "Renewable"):aggregate_scenarios(BY_AVERAGE()),
--     gerbat:aggregate_agents(BY_SUM(), "Battery"):aggregate_scenarios(BY_AVERAGE()):convert("GWh")
-- ):save("foca");

-- local chart = Chart("Generation");
-- chart:push("foca", "area_stacking");
-- dashboard:push(chart);


-- if cmgdem:is_hourly() then
--     cmgdem:aggregate_scenarios(BY_AVERAGE()):save("cmgdem_")
--     local chart = Chart("Load Marginal Cost");
--     chart:push("cmgdem_", "line");
--     dashboard:push(chart);

--     -- local cmgdem_agg = cmgdem
--     --     :aggregate_agents(BY_AVERAGE(), "Load Marginal Price")
--     --     :aggregate_scenarios(BY_AVERAGE())
--     --     :aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)
--     --     :save_and_load("cmgdem_agg");

--     -- cmgdem_agg:aggregate_blocks(BY_AVERAGE()):save("cmgdem_per_year");
    
--     -- local chart = Chart("cmgdem per year");
--     -- chart:push("cmgdem_per_year", "pie");
--     -- dashboard:push(chart);

--     -- dashboard:column_mode(3);
--     -- local stages = cmgdem_agg:stages();
--     -- for stage = 1,stages,1 do
--     --     local year = cmgdem_agg:year(stage);
--     --     local label = "cmgdem_" .. tostring(year);

--     --     cmgdem_agg:select_stages(stage)
--     --         :reshape_stages(Profile.DAILY)
--     --         :aggregate_stages(BY_AVERAGE())
--     --         :save(label);

--     --     local chart = Chart("Marginal Cost " .. tostring(year));
--     --     chart:push(label, "line");
--     --     dashboard:push(chart);
--     -- end
--     -- dashboard:row_mode();

--     -- local cmgdem_per_month = cmgdem:aggregate_agents(BY_AVERAGE(), "cmgdem_per_month")
--     --     :aggregate_scenarios(BY_AVERAGE())
--     --     :aggregate_stages(BY_AVERAGE(), Profile.PER_MONTH)
--     --     :save_and_load("cmgdem_per_month");

--     -- dashboard:column_mode(2);
--     -- local stages = cmgdem_per_month:stages();
--     -- for stage = 1,stages,1 do
--     --     local month = months[cmgdem_per_month:month(stage)];
--     --     local label = "cmgdem_" .. month;
--     --     cmgdem_per_month
--     --         :select_stages(stage)
--     --         :reshape_stages(Profile.DAILY)
--     --         :aggregate_stages(BY_AVERAGE())
--     --         :save(label);

--     --     local chart = Chart("Marginal Cost " .. month);
--     --     chart:push(label, "column");
--     --     dashboard:push(chart);
--     -- end
--     -- dashboard:row_mode();
-- else 

-- end

-- dashboard:save_style2("dashboard");


-- potencia instalada
-- deficit (scenarios: --, blocks: --, stages:--)
-- geração agg
-- geração renovavel 
-- fluxo 
-- carregamento
-- capacidade
-- demanda horaria
-- custo de investimento 
-- expansão do optgen 
-- custo totais





-- local initial_year = gerhid:initial_year();
-- local final_year = gerhid:final_year();

-- local function mod24(data, year) return data:select_stages_by_year(year):reshape_stages(Profile.DAILY):aggregate_stages(BY_AVERAGE()):convert("MW"); end
