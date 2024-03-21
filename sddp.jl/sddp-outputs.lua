PSR.assert_version(">0.20.0");

local function save_inputs()
    local demand = Demand();
    local hydro = Hydro();
    local study = Study();
    local has_flexible_demand = study:has_flexible_demand();

    -- QMAXIM
    local qmaxim = require("sddp/qmaxim");
    qmaxim():save("qmaxim", { horizon = true });

    -- MNSOUT
    local mnsout = require("sddp/mnsout");
    mnsout():save("mnsout", { horizon = true });

    -- PMNTER
    local pmnter = require("sddp/pmnter");
    pmnter():save("pmnter", { horizon = true });

    -- USEFUL_STORAGE
    local useful_storage = require("sddp/useful_storage");
    useful_storage():save("useful_storage", { horizon = true });

    -- VOLMNO
    local volmno = require("sddp/volmno");
    volmno():save("volmno", { horizon = true });

    -- LSHREF
    local flexible_demand = require("sddp/flexible_demand");
    flexible_demand():save("lshref", { force = has_flexible_demand });

    -- LSHMAX
    local lshmax = flexible_demand() * (1 + demand.max_increase:select_agents(demand.is_flexible));
    lshmax:save("lshmax", { force = has_flexible_demand });

    -- LSHMIN
    local lshmin = flexible_demand() * (1 - demand.max_decrease:select_agents(demand.is_flexible));
    lshmin:save("lshmin", { force = has_flexible_demand });

    -- -- FLOOD_CONTROL_HISTORICAL_SCENARIOS
    hydro.flood_control_historical_scenarios:save("flood_control_historical_scenarios", { horizon = true });

    -- -- MIN_STORAGE_HISTORICAL_SCENARIOS
    hydro.min_operative_storage_historical_scenarios:save("min_storage_historical_scenarios", { horizon = true });

    -- -- MAX_STORAGE_HISTORICAL_SCENARIOS
    hydro.max_operative_storage_historical_scenarios:save("max_storage_historical_scenarios", { horizon = true });
end

local function save_hydro_violation(label, suffixes, unit_conversion)
    local hydro = Hydro();

    for _, suffix in ipairs(suffixes) do
        local unit_violation_cost = hydro:load(label .. "_unit_violation_cost" .. suffix);
        local violation = hydro:load(label .. "_violation" .. suffix):convert(unit_conversion);

        if not unit_violation_cost:loaded() and violation:is_hourly() then
            unit_violation_cost = hydro:load(label .. "_unit_violation_cost__week"):to_hour(BY_REPEATING());
        end

        (unit_violation_cost * violation):save(label .. "_violation_cost" .. suffix, { variable_by_block = 2 });
    end
end

local function save_custom_hydro_violation(label_violation, label_violation_cost, label_unit_violation_cost, suffixes)
    local hydro = Hydro();

    for _, suffix in ipairs(suffixes) do
        local unit_violation_cost = hydro:load(label_unit_violation_cost .. suffix);
        local violation = hydro:load(label_violation .. suffix):convert("hm3");

        if not unit_violation_cost:loaded() and violation:is_hourly() then
            unit_violation_cost = hydro:load(label_unit_violation_cost .. "__week"):to_hour(BY_REPEATING());
        end

        (unit_violation_cost * violation):save(label_violation_cost .. suffix, { variable_by_block = 2 });
    end
end

local function save_outputs()
    local study = Study();
    local is_genesys = study:is_genesys();
    local has_flexible_demand = study:has_flexible_demand();

    -- SUFFIXES
    local suffixes = { "" };
    if is_genesys then
        suffixes = { "__day", "__week", "__hour", "__trueup" };
    end

    local outputs = {
        { label = "vturmn" },
        { label = "qtoutf", variable_by_block = 2 },
        { label = "defcit_risk" },
        { label = "usecir" },
        { label = "usedcl" },
        { label = "useful_storage_initial", variable_by_block = 2 },
        { label = "useful_storage_final", variable_by_block = 2 },
        { label = "hydro_spillage_cost" },
        { label = "lshccst", base = "flexible_load_curtailment_cost", force = has_flexible_demand },
        -- POWERVIEW OUTPUTS
        { label = "gerhid_per_bus", force = is_genesys },
        { label = "gerfuel_per_bus", force = is_genesys },
        { label = "gerter2_per_bus", force = is_genesys },
        { label = "gergnd_per_bus", force = is_genesys },
        { label = "gerbat_per_bus", force = is_genesys },
        { label = "powinj_per_bus", force = is_genesys }
    };

    for _, output in ipairs(outputs) do
        local f;
        if output.base == nil then
            f = require("sddp/" .. output.label);
        else
            f = require("sddp/" .. output.base);
        end

        local force = false;
        if output.force ~= nil then
            force = output.force;
        end

        for _, suffix in ipairs(suffixes) do
            if output.variable_by_block == nil then
                f(nil, suffix):save(output.label .. suffix, { force = force });
            else
                f(nil, suffix):save(output.label .. suffix, { force = force, variable_by_block = output.variable_by_block });
            end
        end
    end

    local violations = {
       { label = "alert_storage", unit_conversion = "hm3" },
       { label = "discharge_rate", unit_conversion = "(m3/s)/hour" },
       { label = "irrigation", unit_conversion = "hm3" },
       { label = "max_oper_stge", unit_conversion = "hm3" },   -- "max_operative_storage",
       { label = "max_spill", unit_conversion = "hm3" },       -- "max_spillage",
       { label = "max_total_otflw", unit_conversion = "hm3" }, -- "max_total_outflow",
       { label = "min_oper_stge", unit_conversion = "hm3" },   -- "min_operative_storage",
       { label = "min_spill_pct", unit_conversion = "hm3" },   -- "min_spillage_percentage",
       { label = "min_spill", unit_conversion = "hm3" },       -- "min_spillage",
       { label = "min_total_otflw", unit_conversion = "hm3" }, -- "min_total_outflow",
       { label = "minimum_turbine", unit_conversion = "hm3" },
       { label = "target_storage", unit_conversion = "hm3" },
       { label = "max_outflow_ramp_up", unit_conversion = "hm3" },
       { label = "max_outflow_ramp_down", unit_conversion = "hm3" }
    };

    for _, violation in ipairs(violations) do
        save_hydro_violation(violation.label, suffixes, violation.unit_conversion)
    end

    -- Custom violations
    save_custom_hydro_violation("qverti", "hspcost", "cpnspl", suffixes);
end

local function save_reports()
    -- SDDPCOPE
    local sddpcope = require("sddp-reports/sddpcope");
    sddpcope():save("sddpcope_psrio", { csv = true });

    -- SDDPCOPED
    local sddpcoped = require("sddp-reports/sddpcoped");
    sddpcoped():save("sddpcoped_psrio", { csv = true });

    -- SDDPGRXXD
    local sddpgrxxd = require("sddp-reports/sddpgrxxd");
    sddpgrxxd():save("sddpgrxxd_psrio", { csv = true });

    -- SDDPCMGD
    local sddpcmgd = require("sddp-reports/sddpcmgd");
    sddpcmgd():save("sddpcmgd_psrio", { csv = true });

    -- SDDPCMGA
    local sddpcmga = require("sddp-reports/sddpcmga");
    sddpcmga():save("sddpcmga_psrio", { csv = true });

    -- SDDPRISK
    local sddprisk = require("sddp-reports/sddprisk");
    sddprisk():save("sddprisk_psrio", { csv = true });
end

save_inputs();
save_outputs();
save_reports();
