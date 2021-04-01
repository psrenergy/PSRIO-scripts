function save_defind()
    if system == nil then system = System(); end
    local defcit = system:load("defcit");
    ifelse(defcit:gt(0), 1, 0):save("defind");
end