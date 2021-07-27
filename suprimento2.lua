local function get_energia_atual_SE(meta_SU, meta_SE, energia_atual_SU, energia_atual_SE, energia_max_SU,  energia_max_SE, deficit)
    local energia_SE_atual_proporcao_do_vutil = calcula_proporcao(energia_atual_SE, meta_SE, energia_max_SE)
    local energia_SU_atual_proporcao_do_vutil = calcula_proporcao(energia_atual_SU, meta_SU, energia_max_SU)

    return 
    ifelse(deficit:gt(0), 
        ifelse(energia_atual_SU:gt(meta_SU) & energia_atual_SE:gt(meta_SE),
            ifelse(energia_SE_atual_proporcao_do_vutil:gt(energia_SU_atual_proporcao_do_vutil),
                min(energia_atual_SE - deficit, meta_SE + energia_SU_atual_proporcao_do_vutil * energia_max_SE),
                0                                                                                   
            ),
            0
        ),
        0
    )
end

local function get_energia_atual_SU(meta_SU, meta_SE, energia_atual_SU, energia_atual_SE, energia_max_SU,  energia_max_SE, deficit)
    local energia_SE_atual_proporcao_do_vutil = calcula_proporcao(energia_atual_SE, meta_SE, energia_max_SE)
    local energia_SU_atual_proporcao_do_vutil = calcula_proporcao(energia_atual_SU, meta_SU, energia_max_SU)
    
    return
    ifelse(deficit:gt(0),
        ifelse(energia_atual_SU:gt(meta_SU) & energia_atual_SE:(meta_SE),
            ifelse(energia_SE_atual_proporcao_do_vutil:lt(energia_SU_atual_proporcao_do_vutil),
                min(energia_atual_SU - deficit, meta_SU + energia_SE_atual_proporcao_do_vutil * energia_max_SU),
                0
            ),
            0
        ),
        0
    )
end

energia_SE = get_energia_SE(meta_SU, meta_SE, energia_atual_SU, energia_atual_SE, energia_max_SU,  energia_max_SE, deficit)
energia_SU = get_energia_SU(meta_SU, meta_SE, energia_atual_SU, energia_atual_SE, energia_max_SU,  energia_max_SE, deficit)

deficit = deficit - (energia_atual_SE - energia_SE) - (energia_atual_SU - energia_SU)

local pode_esvaziar = energia_atual_SE - meta_SE + energia_atual_SU - meta_SU
energia_atual_SE = ifelse(deficit:gt(pode_esvaziar), meta_SE, meta_SE + (pode_esvaziar - deficit) * (energia_atual_SE - meta_SE)/pode_esvaziar)
energia_atual_SU = ifelse(deficit:gt(pode_esvaziar), meta_SU, meta_SU + (pode_esvaziar - deficit) * (energia_atual_SU - meta_SU)/pode_esvaziar)
deficit = ifelse(deficit:gt(pode_esvaziar, deficit - pode_esvaziar, 0)