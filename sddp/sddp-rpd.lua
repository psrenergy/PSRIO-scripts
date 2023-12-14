local generic = Generic();

local function split(s, delimiter)
    local result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

local result = {};
for agent = 1,2 do
    local reader = generic:create_reader("dprdash_"..agent..".csv");
    local names = "null";
    local unit = "MW"
    local initial_year = 0;
    local initial_stage = 0;
    local data_by_stage = {};
    local stage_data = {};

    local fisrt_line = true;
    local second_line = true;
    local third_line = true;
    local forth_line = true;
    while reader:good() do
        local row = reader:get_line();
        local columns = split(row,",");
        local lenth_columns = #columns;
        if fisrt_line then
            fisrt_line = false;
            local vec_row = split(row, " ");
            names = vec_row[#vec_row];
        elseif second_line then
            second_line = false;
        elseif third_line then
            third_line = false;
        else
            local date = columns[1];
            if date ~= nil then
                if forth_line then
                    forth_line = false;
                    initial_stage = tonumber(split(columns[1],"/")[1]);
                    initial_year = tonumber(split(columns[1],"/")[2]);
                end

                local hour = tonumber(columns[2]);

                local data_agents = {}
                for pos = 3,lenth_columns do
                    local data = tonumber(columns[pos]);
                    local data_frame = generic:create(names, unit, { data });
                    table.insert(data_agents,data_frame);
                end
                table.insert(stage_data,concatenate(data_agents))

                if hour == 24 then
                    table.insert(data_by_stage,concatenate_blocks(stage_data));
                    stage_data = {};
                end

            end
        end

    end

    reader:close();

    table.insert(result,concatenate_stages(data_by_stage));

end
local dprdash_psrio = concatenate(result);
local initial_year = dprdash_psrio:initial_year();
local final_year = dprdash_psrio:final_year();
local n_years = final_year - initial_year + 1;

local dprdash_psrio_agg = dprdash_psrio
                          :set_stage_type(5)
                          :force_hourly()
                          :save_and_load("dprdash_psrio",{fast_csv = true});

local dashboard = Dashboard();

for year = 1,n_years do
    for quartely = 1,4 do
        local tab = Tab("RPD ( " .. quartely .. " quartely / " .. (initial_year - 1) + year);
        for month = (quartely - 1) * 3 + 1, 3 * quartely do
            local chart = Chart("Dynamic Probabilistic Reserve by stage (MW) - RPD " .. " - " .. month .. " month");
            chart:add_line(dprdash_psrio_agg:select_stage(month + (year - 1) * 12));
            tab:push(chart);
        end
        dashboard:push(tab);
    end
end

dashboard:save("dash_RPD")




