function save_inputs()
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

function save_outputs()
    local study = Study();
    local suffixes = {""};
    if study:is_genesys() then
        suffixes = {"__day", "__week", "__hour", "__trueup"};
    end

    local labels = {
        "vturmn", 
        "qtoutf", 
        "minimum_spillage_percentage_violation_cost",
        "minimum_spillage_violation_cost",
        "minimum_total_outflow_violation_cost",
        "minimum_turbine_violation_cost",
        "maximum_spillage_unit_violation_cost",
        "discharge_rate_violation_cost",
        "maximum_total_outflow_violation_cost",
        "maximum_operative_storage_violation_cost",
        "irrigation_violation_cost",
        "defcit_risk", 
        "usecir", 
        "usedcl", 
        "useful_storage_initial", 
        "useful_storage_final",
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