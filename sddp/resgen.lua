function save_resgen()
    if generation_constraint == nil then generation_constraint = GenerationConstraint(); end
    generation_constraint.capacity:save("resgen");
end