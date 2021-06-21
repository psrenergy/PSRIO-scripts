local study = require("collection/study");
local suffixes;
if study:is_genesys() then
    suffixes = {"__day", "__week", "__hour", "__trueup"};
else
    suffixes = {""};
end

local hydro = require("collection/hydro");

-- INPUT DATA
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

-- OUTPUT DATA
-- GERHID_PER_BUS
local gerhid_per_bus = require("sddp/gerhid_per_bus");
for _, suffix in ipairs(suffixes) do gerhid_per_bus(suffix):save("gerhid_per_bus" .. suffix); end

-- GERTER_PER_BUS
local gerfuel_per_bus = require("sddp/gerfuel_per_bus");
for _, suffix in ipairs(suffixes) do gerfuel_per_bus(suffix):save("gerter_per_bus" .. suffix); end

-- GERTER2_PER_BUS
local gerter2_per_bus = require("sddp/gerter2_per_bus");
for _, suffix in ipairs(suffixes) do gerter2_per_bus(suffix):save("gerter2_per_bus" .. suffix); end

-- GERGND_PER_BUS
local gergnd_per_bus = require("sddp/gergnd_per_bus");
for _, suffix in ipairs(suffixes) do gergnd_per_bus(suffix):save("gergnd_per_bus" .. suffix); end

-- GERBAT_PER_BUS
local gerbat_per_bus = require("sddp/gerbat_per_bus");
for _, suffix in ipairs(suffixes) do gerbat_per_bus(suffix):save("gerbat_per_bus" .. suffix); end

-- POWINJ_PER_BUS
local powinj_per_bus = require("sddp/powinj_per_bus");
for _, suffix in ipairs(suffixes) do powinj_per_bus(suffix):save("powinj_per_bus" .. suffix); end

-- DEFCIT_RISK
local defcit_risk = require("sddp/defcit_risk");
for _, suffix in ipairs(suffixes) do defcit_risk(suffix):save("defcit_risk" .. suffix); end

-- USECIR
local usecir = require("sddp/usecir");
for _, suffix in ipairs(suffixes) do usecir(suffix):save("usecir" .. suffix); end

-- USEDCL
local usedcl = require("sddp/usedcl");
for _, suffix in ipairs(suffixes) do usedcl(suffix):save("usedcl" .. suffix); end

-- USEFUL_STORAGE_INITIAL
local useful_storage_initial = require("sddp/useful_storage_initial");
for _, suffix in ipairs(suffixes) do useful_storage_initial(suffix):save("useful_storage_initial" .. suffix); end

-- USEFUL_STORAGE_FINAL
local useful_storage_final = require("sddp/useful_storage_final");
for _, suffix in ipairs(suffixes) do useful_storage_final(suffix):save("useful_storage_final" .. suffix); end

-- VTURMN - MINIMUM TURBINED OUTFLOW VIOLATION
local vturmn = require("sddp/vturmn");
for _, suffix in ipairs(suffixes) do vturmn(suffix):save("vturmn" .. suffix); end

-- QTOUTF
local qtoutf = require("sddp/qtoutf");
for _, suffix in ipairs(suffixes) do qtoutf(suffix):save("qtoutf" .. suffix); end

-- REPORTS --
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