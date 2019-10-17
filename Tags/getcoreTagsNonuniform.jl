function getcoreTagsNonuniform(hyper::Array{Array{Int64,1},1},tags::Array{Int64,1},rank::Int64)
    core=[deepcopy(tags)]
    hyperedge=tags
    for j in 1:length(hyper)
        if length(intersect(hyper[j],hyperedge))>0&&length(hyper[j])<=rank&&length(hyper[j])>1
            push!(core,hyper[j])
        end
    end
    return unique(vcat(core...))
end
