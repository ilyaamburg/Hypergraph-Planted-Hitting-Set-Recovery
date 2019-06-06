function parsersPlot(simplices::AbstractString, nverts::AbstractString)
    a=open(simplices)
    a=readlines(a)
    a=map(x->parse(Float64,x),a)
    b=open(nverts)
    b=readlines(b)
    b=map(x->parse(Float64,x),b)
    return [a,b]
end

function parsersPlot(core::AbstractString)
    a=open(core)
    a=readlines(a)
    a=map(x->parse(Float64,x),a)
    return a
end
