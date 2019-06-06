function parsers(simplices::AbstractString, nverts::AbstractString)
a=open(simplices)
a=readlines(a)
a=map(x->parse(Int64,x),a)
b=open(nverts)
b=readlines(b)
b=map(x->parse(Int64,x),b)
return [a,b]
end

function parsers(core::AbstractString)
a=open(core)
a=readlines(a)
a=map(x->parse(Int64,x),a)
return a
end
