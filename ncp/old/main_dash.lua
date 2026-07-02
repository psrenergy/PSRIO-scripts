-- C:\PSR\GraphModule\Oper\psrplot\psrio\psrio.exe -r "D:\Dropbox (PSR)\NCP\Dashboard\dash_NCP\main_dash.lua" -o "D:\Dropbox (PSR)\NCP\Dashboard\result" "D:\Dropbox (PSR)\NCP\Dashboard\casos\teste_1"

include("general_function.lua");
include("types.lua");
include("grafs.lua");
include("globals.lua");

-- # of cases
local N_case = PSR.studies();;

-- create dashboard
local dash = Dashboard();

-- call load
NCP_base_vec, NCP_dim_vec, NCP_data_vec = load("ncpstat.psr",N_case);

-- case_summary tab
dash:push(case_summary(N_case,NCP_base_vec, NCP_dim_vec));

-- results tab
dash:push(results(N_case,NCP_base_vec, NCP_data_vec));

dash:save("NCP_dashboard")