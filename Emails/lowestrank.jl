function lowestrank(a::Array{Int64,1})
    d=Int64[]
    for q in sort(unique(a)); append!(d,length(findall(a.==q))); end
    #return d
    a=sort(unique(a))
    rank=sort(a,by=v->d[findfirst(isequal(v),a)])
    lowes=findmin(d)
    nlowest=length(findall(d.==lowes[1]))
    return rank[1:nlowest]
end
