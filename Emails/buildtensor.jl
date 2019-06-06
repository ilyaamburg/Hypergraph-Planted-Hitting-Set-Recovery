include("centrality.jl")
function buildtensor(aa::Array{Int64,1},bb::Array{Int64,1},rank::Int64)
    colu1=Int64[]
    colu2=Int64[]
    colu3=Int64[]
    colu4=Int64[]
    colu5=Int64[]
    aaorder=sort(unique(aa))
    a=replace(x->findall(aaorder.==x)[1],aa)
    if rank==3
        for i=1:length(a)
            if mod(i,rank)==1
                append!(colu1,a[i])
            elseif mod(i,rank)==2
                append!(colu2,a[i])
            else
                append!(colu3,a[i])
            end
        end
    elseif rank==4
        for i=1:length(a)
            if mod(i,rank)==1
                append!(colu1,a[i])
            elseif mod(i,rank)==2
                append!(colu2,a[i])
            elseif mod(i,rank)==3
                append!(colu3,a[i])
            else
                append!(colu4,a[i])
            end
        end
    elseif rank==5
        for i=1:length(a)
            if mod(i,rank)==1
                append!(colu1,a[i])
            elseif mod(i,rank)==2
                append!(colu2,a[i])
            elseif mod(i,rank)==3
                append!(colu3,a[i])
            elseif mod(i,rank)==4
                append!(colu4,a[i])
            else
                append!(colu5,a[i])
            end
        end
    end
    dimension=length(unique(aa))
    
    if rank==3
        return SymTensor3(colu1,colu2,colu3,ones(Float64, length(colu1)),dimension)
    elseif rank==4
        return SymTensor4(colu1,colu2,colu3,colu4,ones(Float64, length(colu1)),dimension)
    elseif rank==5
        return SymTensor5(colu1,colu2,colu3,colu4,colu5,ones(Float64, length(colu1)),dimension)
    end
end
