local generic = Generic();

local function split(s, delimiter)
    local result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

local reader = generic:create_reader("dprdash_1.csv");


local chart_name = "null"
local names = {};
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
        chart_name = row
    elseif second_line then
        second_line = false;
    elseif third_line then
        third_line = false;
        for pos = 3,lenth_columns do
            table.insert(names,columns[pos]);
        end
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
                local data_frame = generic:create(names[pos-2], unit, { data });
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

local dprdash_psrio = concatenate_stages(data_by_stage)
                                        :set_stage_type(5)
                                        :force_hourly()
                                        :save_and_load("dprdash_psrio",{fast_csv = true});

local dashboard = Dashboard();
for quartely = 1,4 do
    local tab = Tab("RPD ( " .. quartely .. " quartely )");
    for month = (quartely - 1) * 3 + 1, 3 * quartely do
        local chart = Chart(chart_name .. " - " .. month .. " month");
        chart:add_area(dprdash_psrio:select_stage(month),{color = "#417ee0"});
        tab:push(chart);
    end
    dashboard:push(tab);
end

dashboard:save("dash_RPD")




