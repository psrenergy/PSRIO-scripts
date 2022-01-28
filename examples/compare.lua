study1 = Study(1);
study2 = Study(2);

generic1 = Generic(1);
generic2 = Generic(2);

case1 = study1:parent_path();
case2 = study2:parent_path();

report = Report(case1 .. " vs " .. case2);

local function push_input_comparison(collection, variable) 
    do_string("input1 = " .. collection .. "1." .. variable .. ";");
    do_string("input2 = " .. collection .. "2." .. variable .. ";");

    local compare = Compare(collection .. "." .. variable);
    compare:add(input1);
    compare:add(input2);
    report:push(compare);
end

battery1 = Battery(1);
battery2 = Battery(2);

push_input_comparison("battery", "existing");
push_input_comparison("battery", "capacity");

dclink1 = DCLink(1);
dclink2 = DCLink(2);

push_input_comparison("dclink", "existing");
push_input_comparison("dclink", "capacity_right");
push_input_comparison("dclink", "capacity_left");

demand1 = Demand(1);
demand2 = Demand(2);

push_input_comparison("demand", "is_elastic");
push_input_comparison("demand", "inelastic_hour");
push_input_comparison("demand", "inelastic_block");

demandsegment1 = DemandSegment(1);
demandsegment2 = DemandSegment(2);

push_input_comparison("demandsegment", "hour");
push_input_comparison("demandsegment", "block");
push_input_comparison("demandsegment", "hour_scenarios");

hydro1 = Hydro(1);
hydro2 = Hydro(2);

push_input_comparison("hydro", "existing");
push_input_comparison("hydro", "capacity");
push_input_comparison("hydro", "capacity_maintenance");
push_input_comparison("hydro", "FOR");
push_input_comparison("hydro", "COR");
push_input_comparison("hydro", "vmax");
push_input_comparison("hydro", "vmin");
push_input_comparison("hydro", "qmax");
push_input_comparison("hydro", "qmin");
push_input_comparison("hydro", "omcost");
push_input_comparison("hydro", "irrigation");
push_input_comparison("hydro", "min_total_outflow_modification");
push_input_comparison("hydro", "target_storage_tolerance");
push_input_comparison("hydro", "disconsider_in_stored_and_inflow_energy");
push_input_comparison("hydro", "min_total_outflow_historical_scenarios_nodata");
push_input_comparison("hydro", "min_total_outflow_historical_scenarios");
push_input_comparison("hydro", "min_total_outflow");
push_input_comparison("hydro", "max_total_outflow_historical_scenarios_nodata");
push_input_comparison("hydro", "max_total_outflow_historical_scenarios");
push_input_comparison("hydro", "max_total_outflow");
push_input_comparison("hydro", "vmin_chronological_historical_scenarios_nodata");
push_input_comparison("hydro", "vmin_chronological_historical_scenarios");
push_input_comparison("hydro", "vmin_chronological");
push_input_comparison("hydro", "vmax_chronological_historical_scenarios_nodata");
push_input_comparison("hydro", "vmax_chronological_historical_scenarios");
push_input_comparison("hydro", "vmax_chronological");
push_input_comparison("hydro", "flood_control_historical_scenarios_nodata");
push_input_comparison("hydro", "flood_control_historical_scenarios");
push_input_comparison("hydro", "flood_control");
push_input_comparison("hydro", "alert_storage_historical_scenarios_nodata");
push_input_comparison("hydro", "alert_storage_historical_scenarios");
push_input_comparison("hydro", "alert_storage");
push_input_comparison("hydro", "min_spillage_historical_scenarios_nodata");
push_input_comparison("hydro", "min_spillage_historical_scenarios");
push_input_comparison("hydro", "min_spillage");
push_input_comparison("hydro", "max_spillage_historical_scenarios_nodata");
push_input_comparison("hydro", "max_spillage_historical_scenarios");
push_input_comparison("hydro", "max_spillage");
push_input_comparison("hydro", "min_bio_spillage_historical_scenarios_nodata");
push_input_comparison("hydro", "min_bio_spillage_historical_scenarios");
push_input_comparison("hydro", "min_bio_spillage"); 
push_input_comparison("hydro", "target_storage_historical_scenarios_nodata"); 
push_input_comparison("hydro", "target_storage_historical_scenarios"); 
push_input_comparison("hydro", "target_storage");

gaugingstation1 = GaugingStation(1);
gaugingstation2 = GaugingStation(2);

push_input_comparison("gaugingstation", "inflow");
push_input_comparison("gaugingstation", "forward");
push_input_comparison("gaugingstation", "backward");

renewable1 = Renewable(1);
renewable2 = Renewable(2);

push_input_comparison("renewable", "existing");
push_input_comparison("renewable", "tech_type");
push_input_comparison("renewable", "capacity");
push_input_comparison("renewable", "omcost");

renewablegaugingstation1 = RenewableGaugingStation(1);
renewablegaugingstation2 = RenewableGaugingStation(2);

push_input_comparison("renewablegaugingstation", "hour_generation");

thermal1 = Thermal(1);
thermal2 = Thermal(2);

push_input_comparison("thermal", "existing");
push_input_comparison("thermal", "capacity");
push_input_comparison("thermal", "capacity_maintenance");
push_input_comparison("thermal", "FOR");
push_input_comparison("thermal", "COR");
push_input_comparison("thermal", "germin");
push_input_comparison("thermal", "germin_maintenance");
push_input_comparison("thermal", "startup_cost");
push_input_comparison("thermal", "omcost");
push_input_comparison("thermal", "cesp1");
push_input_comparison("thermal", "cesp2");
push_input_comparison("thermal", "cesp3");
push_input_comparison("thermal", "transport_cost");
push_input_comparison("thermal", "must_run");
push_input_comparison("thermal", "forced_generation");

local function push_output_comparison(filename) 
    local output1 = generic1:load(filename);
    local output2 = generic2:load(filename);

    local compare = Compare(filename);
    compare:add(output1);
    compare:add(output2);
    report:push(compare);
end

outputs = {
    "angulo__week",
    "BalancingAreaContingencyReserveHydro__day",
    "BalancingAreaContingencyReserveHydro__hour",
    "BalancingAreaContingencyReserveHydro__trueup",
    "BalancingAreaContingencyReserveHydro__week",
    "BalancingAreaContingencyReserveThermal__day",
    "BalancingAreaContingencyReserveThermal__hour",
    "BalancingAreaContingencyReserveThermal__trueup",
    "BalancingAreaContingencyReserveThermal__week",
    "BalancingAreaDemand__day",
    "BalancingAreaDemand__hour",
    "BalancingAreaDemand__trueup",
    "BalancingAreaDemand__week",
    "BalancingAreaDownReserveHydro__day",
    "BalancingAreaDownReserveHydro__hour",
    "BalancingAreaDownReserveHydro__trueup",
    "BalancingAreaDownReserveHydro__week",
    "BalancingAreaDownReserveThermal__day",
    "BalancingAreaDownReserveThermal__hour",
    "BalancingAreaDownReserveThermal__trueup",
    "BalancingAreaDownReserveThermal__week",
    "BalancingAreaTotalContingencyReserve__day",
    "BalancingAreaTotalContingencyReserve__hour",
    "BalancingAreaTotalContingencyReserve__trueup",
    "BalancingAreaTotalContingencyReserve__week",
    "BalancingAreaTotalRegulationDownReserve__day",
    "BalancingAreaTotalRegulationDownReserve__hour",
    "BalancingAreaTotalRegulationDownReserve__trueup",
    "BalancingAreaTotalRegulationDownReserve__week",
    "BalancingAreaTotalRegulationUpReserve__day",
    "BalancingAreaTotalRegulationUpReserve__hour",
    "BalancingAreaTotalRegulationUpReserve__trueup",
    "BalancingAreaTotalRegulationUpReserve__week",
    "BalancingAreaUpReserveHydro__day",
    "BalancingAreaUpReserveHydro__hour",
    "BalancingAreaUpReserveHydro__trueup",
    "BalancingAreaUpReserveHydro__week",
    "BalancingAreaUpReserveThermal__day",
    "BalancingAreaUpReserveThermal__hour",
    "BalancingAreaUpReserveThermal__trueup",
    "BalancingAreaUpReserveThermal__week",
    "BATotalContingencyReserveBattery__day",
    "BATotalContingencyReserveBattery__hour",
    "BATotalContingencyReserveBattery__trueup",
    "BATotalContingencyReserveBattery__week",
    "BATotalContingencyReserveHydro__day",
    "BATotalContingencyReserveHydro__hour",
    "BATotalContingencyReserveHydro__trueup",
    "BATotalContingencyReserveHydro__week",
    "BATotalContingencyReserveThermal__day",
    "BATotalContingencyReserveThermal__hour",
    "BATotalContingencyReserveThermal__trueup",
    "BATotalContingencyReserveThermal__week",
    "BATotalDownReserveBattery__day",
    "BATotalDownReserveBattery__hour",
    "BATotalDownReserveBattery__trueup",
    "BATotalDownReserveBattery__week",
    "BATotalDownReserveHydro__day",
    "BATotalDownReserveHydro__hour",
    "BATotalDownReserveHydro__trueup",
    "BATotalDownReserveHydro__week",
    "BATotalDownReserveThermal__day",
    "BATotalDownReserveThermal__hour",
    "BATotalDownReserveThermal__trueup",
    "BATotalDownReserveThermal__week",
    "BATotalUpReserveBattery__day",
    "BATotalUpReserveBattery__hour",
    "BATotalUpReserveBattery__trueup",
    "BATotalUpReserveBattery__week",
    "BATotalUpReserveHydro__day",
    "BATotalUpReserveHydro__hour",
    "BATotalUpReserveHydro__trueup",
    "BATotalUpReserveHydro__week",
    "BATotalUpReserveThermal__day",
    "BATotalUpReserveThermal__hour",
    "BATotalUpReserveThermal__trueup",
    "BATotalUpReserveThermal__week",
    "batstg__day",
    "batstg__hour",
    "batstg__trueup",
    "batstg__week",
    "businj__week",
    "cmgbts__day",
    "cmgbts__hour",
    "cmgbts__trueup",
    "cmgbts__week",
    "cmgbus__day",
    "cmgbus__hour",
    "cmgbus__trueup",
    "cmgbus__week",
    "cmgdem__day",
    "cmgdem__hour",
    "cmgdem__trueup",
    "cmgdem__week",
    "cmgemb__day",
    "cmgemb__hour",
    "cmgemb__trueup",
    "cmgemb__week",
    "cmglnk__day",
    "cmglnk__hour",
    "cmglnk__trueup",
    "cmglnk__week",
    "cmgreg__day",
    "cmgreg__hour",
    "cmgreg__trueup",
    "cmgreg__week",
    "cmgsuc__week",
    "cmgter2__day",
    "cmgter2__hour",
    "cmgter2__trueup",
    "cmgter2__week",
    "cmgter__day",
    "cmgter__hour",
    "cmgter__trueup",
    "cmgter__week",
    "cmgtmn__day",
    "cmgtmn__hour",
    "cmgtmn__trueup",
    "cmgtmn__week",
    "cmgtur__day",
    "cmgtur__hour",
    "cmgtur__trueup",
    "cmgtur__week",
    "commit__day",
    "commit__hour",
    "commit__trueup",
    "commit__week",
    "coshid__day",
    "coshid__hour",
    "coshid__trueup",
    "coshid__week",
    "coster2__day",
    "coster2__hour",
    "coster2__trueup",
    "coster2__week",
    "coster__day",
    "coster__hour",
    "coster__trueup",
    "coster__week",
    "cotfin__day",
    "cotfin__hour",
    "cotfin__trueup",
    "cotfin__week",
    "cotfue2__day",
    "cotfue2__hour",
    "cotfue2__trueup",
    "cotfue2__week",
    "cotfue__day",
    "cotfue__hour",
    "cotfue__trueup",
    "cotfue__week",
    "cotoem2__day",
    "cotoem2__hour",
    "cotoem2__trueup",
    "cotoem2__week",
    "cotoem__day",
    "cotoem__hour",
    "cotoem__trueup",
    "cotoem__week",
    "cpnspl__day",
    "cpnspl__hour",
    "cpnspl__trueup",
    "cpnspl__week",
    "cvlmto__day",
    "cvlmto__hour",
    "cvlmto__trueup",
    "cvlmto__week",
    "dclink__day",
    "dclink__hour",
    "dclink__trueup",
    "dclink__week",
    "deadstorageviolationcost__week",
    "deadstorageviolation__week",
    "defbus__day",
    "defbus__hour",
    "defbus__trueup",
    "defbus__week",
    "defcit_risk__day",
    "defcit_risk__hour",
    "defcit_risk__trueup",
    "defcit_risk__week",
    "defcit__day",
    "defcit__hour",
    "defcit__trueup",
    "defcit__week",
    "defcos__day",
    "defcos__hour",
    "defcos__trueup",
    "defcos__week",
    "demandel__week",
    "demand__day",
    "demand__hour",
    "demand__trueup",
    "demand__week",
    "demxbael__week",
    "demxba__day",
    "demxba__hour",
    "demxba__trueup",
    "demxba__week",
    "discharge_rate_viol__week",
    "duracipu__week",
    "duraci__day",
    "duraci__hour",
    "duraci__trueup",
    "duraci__week",
    "eco2tr2__day",
    "eco2tr2__hour",
    "eco2tr2__trueup",
    "eco2tr2__week",
    "eco2tr__day",
    "eco2tr__hour",
    "eco2tr__trueup",
    "eco2tr__week",
    "eneemb__day",
    "eneemb__hour",
    "eneemb__trueup",
    "eneemb__week",
    "excbus__week",
    "excsis__week",
    "extime",
    "finalhead__day",
    "finalhead__hour",
    "finalhead__trueup",
    "finalhead__week",
    "flood_control_historical_scenarios",
    "forebay_viol__day",
    "forebay_viol__hour",
    "forebay_viol__trueup",
    "forebay_viol__week",
    "fprodtacc__week",
    "fprodt__week",
    "fuelcn__day",
    "fuelcn__hour",
    "fuelcn__trueup",
    "fuelcn__week",
    "fueltr__day",
    "fueltr__hour",
    "fueltr__trueup",
    "fueltr__week",
    "gerbat_per_bus__day",
    "gerbat_per_bus__hour",
    "gerbat_per_bus__trueup",
    "gerbat_per_bus__week",
    "gerbat__day",
    "gerbat__hour",
    "gerbat__trueup",
    "gerbat__week",
    "gergnd_per_bus__day",
    "gergnd_per_bus__hour",
    "gergnd_per_bus__trueup",
    "gergnd_per_bus__week",
    "gergnd__day",
    "gergnd__hour",
    "gergnd__trueup",
    "gergnd__week",
    "gerhid_per_bus__day",
    "gerhid_per_bus__hour",
    "gerhid_per_bus__trueup",
    "gerhid_per_bus__week",
    "gerhid__day",
    "gerhid__hour",
    "gerhid__trueup",
    "gerhid__week",
    "gerter2_per_bus__day",
    "gerter2_per_bus__hour",
    "gerter2_per_bus__trueup",
    "gerter2_per_bus__week",
    "gerter2__day",
    "gerter2__hour",
    "gerter2__trueup",
    "gerter2__week",
    "gerter_per_bus__day",
    "gerter_per_bus__hour",
    "gerter_per_bus__trueup",
    "gerter_per_bus__week",
    "gerter__day",
    "gerter__hour",
    "gerter__trueup",
    "gerter__week",
    "hblock__week",
    "hrstat",
    "inflow__week",
    "island__week",
    "loslnk__day",
    "loslnk__hour",
    "loslnk__trueup",
    "loslnk__week",
    "max_storage_historical_scenarios",
    "mgvwat__day",
    "mgvwat__hour",
    "mgvwat__trueup",
    "mgvwat__week",
    "min_storage_historical_scenarios",
    "mnsout",
    "natinflow__week",
    "objcop",
    "objcop__week",
    "oppchg__day",
    "oppchg__hour",
    "oppchg__trueup",
    "oppchg__week",
    "penreg__day",
    "penreg__hour",
    "penreg__trueup",
    "penreg__week",
    "pmnter",
    "powinj_per_bus__day",
    "powinj_per_bus__hour",
    "powinj_per_bus__trueup",
    "powinj_per_bus__week",
    "powinj__day",
    "powinj__hour",
    "powinj__trueup",
    "powinj__week",
    "qevapo__week",
    "qfiltr__week",
    "qmaxim",
    "qriego__week",
    "qtoutf__day",
    "qtoutf__hour",
    "qtoutf__trueup",
    "qtoutf__week",
    "qturbi__day",
    "qturbi__hour",
    "qturbi__trueup",
    "qturbi__week",
    "qverti__day",
    "qverti__hour",
    "qverti__trueup",
    "qverti__week",
    "resghd__week",
    "resgtr2__week",
    "resgtr__week",
    "rgbsec__day",
    "rgbsec__hour",
    "rgbsec__trueup",
    "rgbsec__week",
    "rghsec__day",
    "rghsec__hour",
    "rghsec__trueup",
    "rghsec__week",
    "rgtsec2__day",
    "rgtsec2__hour",
    "rgtsec2__trueup",
    "rgtsec2__week",
    "rgtsec__day",
    "rgtsec__hour",
    "rgtsec__trueup",
    "rgtsec__week",
    "sddpcoped_psrio",
    "sddpcope_psrio",
    "sumcir__week",
    "targetstoragectr__week",
    "targetstorage_lo__week",
    "targetstorage_up__week",
    "trstup__day",
    "trstup__hour",
    "trstup__trueup",
    "trstup__week",
    "usedcl__day",
    "usedcl__hour",
    "usedcl__trueup",
    "usedcl__week",
    "useful_storage",
    "useful_storage_final__day",
    "useful_storage_final__hour",
    "useful_storage_final__trueup",
    "useful_storage_final__week",
    "useful_storage_initial__day",
    "useful_storage_initial__hour",
    "useful_storage_initial__trueup",
    "useful_storage_initial__week",
    "vdefmn__day",
    "vdefmn__hour",
    "vdefmn__trueup",
    "vdefmn__week",
    "vdefmx__day",
    "vdefmx__hour",
    "vdefmx__trueup",
    "vdefmx__week",
    "vergnd__day",
    "vergnd__hour",
    "vergnd__trueup",
    "vergnd__week",
    "vimnbiosp__day",
    "vimnbiosp__hour",
    "vimnbiosp__trueup",
    "vimnbiosp__week",
    "vimnsp__day",
    "vimnsp__hour",
    "vimnsp__trueup",
    "vimnsp__week",
    "vimxsp__day",
    "vimxsp__hour",
    "vimxsp__trueup",
    "vimxsp__week",
    "vinflow__week",
    "volfin__day",
    "volfin__hour",
    "volfin__trueup",
    "volfin__week",
    "volini__day",
    "volini__hour",
    "volini__trueup",
    "volini__week",
    "volmno",
    "vrestg__day",
    "vrestg__hour",
    "vrestg__trueup",
    "vrestg__week",
    "vriego__day",
    "vriego__hour",
    "vriego__trueup",
    "vriego__week",
    "vturmn__day",
    "vturmn__hour",
    "vturmn__trueup",
    "vturmn__week",
    "vvaler__day",
    "vvaler__hour",
    "vvaler__trueup",
    "vvaler__week",
    "vvolmn__day",
    "vvolmn__hour",
    "vvolmn__trueup",
    "vvolmn__week"
};

for _, output in ipairs(outputs) do 
    push_output_comparison(output) 
end


report:save("report");