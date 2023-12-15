local generic = Generic();

local dprdash_psrio = generic:load("dprdashboard"):force_hourly():force_unit("");
local initial_year = dprdash_psrio:initial_year();
local final_year = dprdash_psrio:final_year();
local n_years = final_year - initial_year + 1;

local dashboard = Dashboard();

for year = 1,n_years do
    for quartely = 1,4 do
        local tab = Tab("RPD ( " .. quartely .. " quarter / " .. (initial_year - 1) + year .." )");
        for month = (quartely - 1) * 3 + 1, 3 * quartely do
            local chart = Chart("Dynamic Probabilistic Reserve by stage (MW) - RPD " .. " - " .. month .. " month");
            chart:add_line(dprdash_psrio:select_stage(month + (year - 1) * 12));
            tab:push(chart);
        end
        dashboard:push(tab);
    end
end

dashboard:save("dash_RPD")




