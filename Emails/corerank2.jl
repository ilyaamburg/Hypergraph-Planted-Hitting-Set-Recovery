function corerank2(a::Array{Int64,1},numb::Int64)
    d=Int64[]
    for q in sort(unique(a)); append!(d,length(findall(a.==q))); end
    a=sort(unique(a))
    rank=sort(a,by=v->d[findfirst(isequal(v),a)],rev=true)
    return(rank[1:numb])
end
