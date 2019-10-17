function gethyperTagsNonuniform(hyper::Array{Array{Int64,1},1},core::Array{Int64,1},rank::Int64)
    hypergraph=[Int64[]]
    for i in 1:length(hyper)
        if length(intersect(hyper[i],core))>0&&length(hyper[i])<=rank&&length(hyper[i])>1
            push!(hypergraph,hyper[i])
        end
    end
    b=Int64[]
    for i=2:length(hypergraph)
        push!(b,length(hypergraph[i]))
    end
    hypergraph=hypergraph[2:length(hypergraph)]
    unique!(hypergraph)
    a=vcat(hypergraph...)
    return [a,b]
end
