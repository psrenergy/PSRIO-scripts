generic = Generic();
diesel_generation = generic:load("DSO_diesel_generation");
renewable_generation = generic:load("DSO_renewable_generation");
demand_response_load = generic:load("DSO_demand_response_load");

-- GENERATION -- 
dashboard_generation = Dashboard("Generation");

dashboard_generation:push("# Generation Dashboard");
dashboard_generation:push("#### bla bla bla.");

chart = Chart("Generation");
chart:add_area_stacking(diesel_generation:aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), "Thermal"), {color="red"});
chart:add_area_stacking(renewable_generation:aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), "Renewable"), {color="green"});
chart:add_line(demand_response_load:aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), "Demand Response"), {color="blue"});
dashboard_generation:push(chart);

-- THERMAL GENERATION --
dashboard_thermal = Dashboard("Thermal Generation");

chart = Chart("Diesel");
chart:add_line(diesel_generation:aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), "Thermal"));
dashboard_thermal:push(chart);

(dashboard_generation + dashboard_thermal):save("dashboard");

