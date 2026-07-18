-- classes
NCP_base = {
    -- Atribts
    modelo  = {},
    user    = {},
    xp_opt  = {},
    xp_mod  = {},
    date    = {},
    mode    = {},
    criteri = {},
    type    = {},
    horizo  = {},
    heuris  = {},
    MIP     = {},
    s_time  = {},
    r_gap   = {},
    s_heuri = {},
    stages  = {},
    stg_res = {},
    network = {},
    t_losse = {},
    int_yea = {},
    fin_yea = {}
    
};
--methods
function NCP_base:load_base(file_name,case)
    local generic = Generic(case);
    local table_load = generic:load_table_without_header(file_name);
    if ( #table_load == 0 ) then
        error(file_name.." not founded");
    end
    
    table.insert(NCP_base.modelo,table_load[1][1]);
    table.insert(NCP_base.modelo,table_load[1][2]);

    table.insert(NCP_base.user,table_load[2][1]);
    table.insert(NCP_base.user,table_load[2][2]);

    table.insert(NCP_base.xp_opt,table_load[3][1]);
    table.insert(NCP_base.xp_opt,table_load[3][2]);

    table.insert(NCP_base.xp_mod,table_load[4][1]);
    table.insert(NCP_base.xp_mod,table_load[4][2]);

    table.insert(NCP_base.date,table_load[5][1]);
    table.insert(NCP_base.date,table_load[5][2]);

    table.insert(NCP_base.mode,table_load[6][1]);
    table.insert(NCP_base.mode,map_name(table_load[6][2],{"0","1"},{"Standard","Chronological"}));

    table.insert(NCP_base.criteri,table_load[7][1]);
    table.insert(NCP_base.criteri,map_name(table_load[6][2],{"0","1"},{"Minimize Costs","Maximize Revenues"}));

    table.insert(NCP_base.type,table_load[8][1]);
    table.insert(NCP_base.type,map_name(table_load[8][2],{"0","1"},{"Deterministic","Stochastic"}));

    table.insert(NCP_base.horizo,table_load[9][1]);
    table.insert(NCP_base.horizo,map_name(table_load[9][2],{"0","1"},{"No","Yes"}));

    table.insert(NCP_base.heuris,table_load[10][1]);
    table.insert(NCP_base.heuris,table_load[10][2]);

    table.insert(NCP_base.MIP,table_load[11][1]);
    table.insert(NCP_base.MIP,table_load[11][2]);

    table.insert(NCP_base.s_time,table_load[12][1]);
    table.insert(NCP_base.s_time,sec_2_min(table_load[12][2]));

    table.insert(NCP_base.r_gap,table_load[13][1]);
    table.insert(NCP_base.r_gap,string.format("%.2f", table_load[13][2]));

    table.insert(NCP_base.s_heuri,table_load[14][1]);
    table.insert(NCP_base.s_heuri,map_name(table_load[14][2],{"-1","-2"},{"Automatic","Disabled"},"Custom"));

    table.insert(NCP_base.stages,table_load[15][1]);
    table.insert(NCP_base.stages,table_load[15][2]);

    table.insert(NCP_base.stg_res,table_load[16][1]);
    table.insert(NCP_base.stg_res,map_name(table_load[16][2],{"1","2","4","12"},{"hour","30 min","15 min","05 min"}));

    table.insert(NCP_base.network,table_load[20][1]);
    table.insert(NCP_base.network,map_name(table_load[20][2],{"0","1"},{"No","Yes"}));

    table.insert(NCP_base.t_losse,table_load[21][1]);
    table.insert(NCP_base.t_losse,map_name(table_load[21][2],{"0","1"},{"No","Yes"}));

end


NCP_dim = {
    -- Atribts
    systems = {},
    variabl = {},
    constra = {},
    entitie = {},
    hyd_pla = {
        normal = {}, commt = {}
    },
    hyd_uni = {
        normal = {}, commt = {}
    },     
    the_uni = {},
    the_commt = {},
    ren_pla = {},
    battery = {},
    circuit = {},
    bus     = {},
    pow_inj = {},
    intercn = {}

}
--methods
function NCP_dim:load_base(file_name,case)
    local generic = Generic(case);
    local table_load = generic:load_table_without_header(file_name);
    if not( table_load ) then
        error(file_name.." not founded");
    end

    table.insert(NCP_dim.variabl,table_load[17][1]);
    table.insert(NCP_dim.variabl,table_load[17][2]);

    table.insert(NCP_dim.constra,table_load[18][1]);
    table.insert(NCP_dim.constra,table_load[18][2]);

    table.insert(NCP_dim.entitie,table_load[19][1]);
    table.insert(NCP_dim.entitie,table_load[19][2]);

    table.insert(NCP_dim.hyd_pla.normal,table_load[22][1]);
    table.insert(NCP_dim.hyd_pla.normal,table_load[22][2]);

    table.insert(NCP_dim.hyd_uni.normal,table_load[23][1]);
    table.insert(NCP_dim.hyd_uni.normal,table_load[23][2]);

    table.insert(NCP_dim.the_uni,table_load[24][1]);
    table.insert(NCP_dim.the_uni,table_load[24][2]);

    table.insert(NCP_dim.ren_pla,table_load[25][1]);
    table.insert(NCP_dim.ren_pla,table_load[25][2]);

    table.insert(NCP_dim.battery,table_load[26][1]);
    table.insert(NCP_dim.battery,table_load[26][2]);

    table.insert(NCP_dim.circuit,table_load[27][1]);
    table.insert(NCP_dim.circuit,table_load[27][2]);

    table.insert(NCP_dim.bus,table_load[28][1]);
    table.insert(NCP_dim.bus,table_load[28][2]);

    table.insert(NCP_dim.hyd_pla.commt,table_load[29][1]);
    table.insert(NCP_dim.hyd_pla.commt,table_load[29][2]);

    table.insert(NCP_dim.hyd_uni.commt,table_load[30][1]);
    table.insert(NCP_dim.hyd_uni.commt,table_load[30][2]);

    table.insert(NCP_dim.the_commt,table_load[31][1]);
    table.insert(NCP_dim.the_commt,table_load[31][2]);

end

NCP_data = {
    -- Atribts
    OBJ    = {"NCPCOPE"},
    demand = {"demand"},
    CMO    = {"cmgdemcp"},
    genhid = {"gerhidcp"},
    genter = {"gertercp"},
    genren = {"gergndcp"},
    genbat = {"gerbatcp"},
    losses = {"lossescp"}

};
function NCP_data:load_data(case)
    local system    = System(case);
    local thermal   = Generic(case); -- Problem!!!
    local hydro     = Hydro(case);
    local renewable = Renewable(case);
    local battery   = Battery(case);
    local circuit   = Circuit(case);

    local OBJ    = load_NCPCOPE(case);
    local demand = system:load("demand"):save_cache();
    local CMO    = system:load("cmgdemcp"):save_cache();
    local gerhid = hydro:load("gerhidcp"):save_cache();
    local gerter = thermal:load("gertercp"):save_cache();
    local gergnd = renewable:load("gergndcp"):save_cache();
    local gerbat = battery:load("gerbatcp"):save_cache();
    local losses = circuit:load("lossescp"):save_cache();
    local zero   = demand:fill(0):save_cache();

    table.insert(NCP_data.OBJ ,OBJ)
    table.insert(NCP_data.OBJ ,OBJ:loaded());
    table.insert(NCP_data.demand ,demand)
    table.insert(NCP_data.demand ,demand:loaded());

    table.insert(NCP_data.CMO    ,CMO   )
    table.insert(NCP_data.CMO    ,CMO   :loaded());

    check_ex(gerhid,NCP_data.genhid,zero);
    check_ex(gerter,NCP_data.genter,zero);
    check_ex(gergnd,NCP_data.genren,zero);
    check_ex(gerbat,NCP_data.genbat,zero);
    check_ex(losses,NCP_data.losses,zero);

end