include("parsers.jl")
function gethyperConf(core::Array{Int64,1},r::Int64)
    aa=parsers("conf-DBLP-$r-simplices.txt")
    bb=parsers("conf-DBLP-$r-nverts.txt")
    conflist=parsers("conf-DBLP-$r-confs.txt")
    yearlist=parsers("conf-DBLP-$r-years.txt")
    a=Int64[]
    b=Int64[]
    bsum=cumsum(bb)
    lengfirst=bb[1]

    firsthyperedge=aa[1:lengfirst]

    if length(intersect(firsthyperedge,core))>0
        append!(a,firsthyperedge)
        append!(b,lengfirst)
    end

    for i in 2:length(bb)
        firstIndex=bsum[i-1]+1; lastIndex=bsum[i]
        hyperedge=aa[firstIndex:lastIndex]
        if length(intersect(hyperedge,core))>0
            append!(a,hyperedge)
            append!(b,bb[i])
        end
    end
    return [a,b]
end
