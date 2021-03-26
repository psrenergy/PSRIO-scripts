if system == nil then system = System(); end

-- DEFIND
defcit = system:load("defcit");
ifelse(defcit:gt(0), 1, 0):save("defind");