include("parsers.jl")
function getcoreConf(cf::Int64,yr::Int64,r::Int64)
    core=Int64[]
    aa=parsers("conf-DBLP-$r-simplices.txt")
    bb=parsers("conf-DBLP-$r-nverts.txt")
    conflist=parsers("conf-DBLP-$r-confs.txt")
    yearlist=parsers("conf-DBLP-$r-years.txt")
    a=Int64[]
    b=Int64[]
    bsum=cumsum(bb)
    lengfirst=bb[1]
    if yearlist[lengfirst]==yr && conflist[lengfirst]==cf
        append!(a,aa[1:lengfirst])
        append!(b,lengfirst)
    end
    for i in 2:length(bb)
        if yearlist[bsum[i]]==yr && conflist[bsum[i]]==cf
            firstIndex=bsum[i-1]+1
            lastIndex=bsum[i]
            ad=aa[firstIndex:lastIndex]
            append!(a,aa[firstIndex:lastIndex])
            append!(b,bb[i])
        end
    end
    return unique(sort(a))
end
