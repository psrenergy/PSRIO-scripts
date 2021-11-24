local function save_inputs()
    local hydro = Hydro();

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

    -- FLOOD_CONTROL_HISTORICAL_SCENARIOS
    hydro.flood_control_historical_scenarios:save("flood_control_historical_scenarios", { horizon = true });

    -- MIN_STORAGE_HISTORICAL_SCENARIOS
    hydro.vmin_chronological_historical_scenarios:save("min_storage_historical_scenarios", { horizon = true });

    -- MAX_STORAGE_HISTORICAL_SCENARIOS
    hydro.vmax_chronological_historical_scenarios:save("max_storage_historical_scenarios", { horizon = true }); 
end

local function save_hydro_violation(label, suffixes)
    local hydro = Hydro();

    for _, suffix in ipairs(suffixes) do 
        local unit_violation_cost = hydro:load(label .. "_unit_violation_cost" .. suffix);
        local violation = hydro:load(label .. "_violation" .. suffix);

        if not unit_violation_cost:loaded() and violation:is_hourly() then
            unit_violation_cost = hydro:load(label .. "_unit_violation_cost__week"):to_hour(BY_REPEATING());
        end
        
        (unit_violation_cost * violation):save(label .. "_violation_cost" .. suffix)
    end
end

local function save_outputs()
    local study = Study();
    local suffixes = {""};
    if study:is_genesys() then
        suffixes = {"__day", "__week", "__hour", "__trueup"};
    end

    local labels = {
        "vturmn", 
        "qtoutf", 
        "defcit_risk", 
        "usecir", 
        "usedcl", 
        "useful_storage_initial", 
        "useful_storage_final",
        -- POWERVIEW OUTPUTS
        "gerhid_per_bus", 
        "gerfuel_per_bus", 
        "gerter2_per_bus", 
        "gergnd_per_bus", 
        "gerbat_per_bus", 
        "powinj_per_bus"
    };

    for _, label in ipairs(labels) do 
        local output = require("sddp/" .. label);
        for _, suffix in ipairs(suffixes) do 
            output(suffix):save(label .. suffix);
        end
    end

    local violations = {
        "alert_storage",
        "discharge_rate",
        "irrigation",
        "maximum_operative_storage",
        "maximum_spillage",
        "maximum_total_outflow",
        "minimum_operative_storage",
        "minimum_spillage_percentage",
        "minimum_spillage",
        "minimum_total_outflow",
        "minimum_turbine",
        "target_storage"
    };

    for _, violation in ipairs(violations) do 
        save_hydro_violation(violation, suffixes)
    end
end

-- REPORTS --
function save_reports()
    -- SDDPCOPE
    local sddpcope = require("sddp-reports/sddpcope");
    sddpcope():save("sddpcope_psrio", {csv=true, remove_zeros=true});

    -- SDDPCOPED
    local sddpcoped = require("sddp-reports/sddpcoped");
    sddpcoped():save("sddpcoped_psrio", {csv=true, remove_zeros=true});

    -- SDDPGRXXD
    local sddpgrxxd = require("sddp-reports/sddpgrxxd");
    sddpgrxxd():save("sddpgrxxd_psrio", {csv=true});

    -- SDDPCMGD
    local sddpcmgd = require("sddp-reports/sddpcmgd");
    sddpcmgd():save("sddpcmgd_psrio", {csv=true});

    -- SDDPCMGA
    local sddpcmga = require("sddp-reports/sddpcmga");
    sddpcmga():save("sddpcmga_psrio", {csv=true});
end

save_inputs();
save_outputs();
save_reports();