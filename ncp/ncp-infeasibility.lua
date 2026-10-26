-- Use the native SDDP Platform renderer, with one diagnosis tab per study.
local dashboard = Dashboard();
dashboard:set_title("NCP | Infeasibility diagnosis");
local found = false;
for study = 1, PSR.studies() do
    local generic = Generic(study);
    local index = generic:create_reader("ncp-infeasibility-index.out");
    if index:is_open() then
        local tab = Tab(PSR.studies() == 1 and "Infeasibility diagnosis" or "Infeasibility diagnosis / Study " .. study);
        tab:set_icon("alert-triangle");
        tab:push("# Infeasibility diagnosis");
        tab:push("## Execution status");
        local result = generic:create_reader("ncp-infeasibility-result.out");
        if result:is_open() then
            while result:good() do
                local line = result:get_line();
                if line then
                    tab:push(line);
                end
            end
            result:close();
        else
            tab:push("Final execution status unavailable. The evidence below describes an infeasible optimization attempt; execution may have been interrupted.");
        end
        local seen = {};
        local count = 0;
        while index:good() do
            local filename = index:get_line();
            if filename and filename:match("^ncp%-infeasibility%-%d+%-%d+%-%d+%-%d+%.out$") and not seen[filename] then
                seen[filename] = true;
                local report = generic:create_reader(filename);
                if report:is_open() then
                    count = count + 1;
                    if count > 1 then
                        tab:push("## Additional recorded conflict");
                    end
                    local technical = false;
                    while report:good() do
                        local line = report:get_line();
                        if line then
                            -- Older report files may still contain a mathematical appendix.
                            if line:find("4. Technical details for traceability", 1, true) then
                                technical = true;
                            end
                            if not technical and line ~= "# Infeasibility diagnosis" then
                                tab:push(line);
                            end
                        end
                    end
                    report:close();
                else
                    tab:push("A recorded conflict report could not be read. Consult the diagnostic TXT and execution log.");
                end
            end
        end
        index:close();
        if count > 0 then
            dashboard:push(tab);
            found = true;
        end
    end
end
if found then
    dashboard:save("NCP-infeasibility");
end
