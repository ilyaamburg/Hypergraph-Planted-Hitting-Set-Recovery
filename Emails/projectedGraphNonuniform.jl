using SparseArrays
using LinearAlgebra
using LightGraphs
using Arpack
function projectedGraphNonuniform(aa::Array{Int64,1},bb::Array{Int64,1})
    aaorder=sort(unique(aa))
    a=replace(x->findall(aaorder.==x)[1],aa)
    b=bb
    aorder=unique(sort(a))
    # Partition a into hyperedge
    hyper=[a[1:b[1]]]
    index=b[1]
    for j in 1:length(b)-1
        push!(hyper,a[index+1:index+b[j+1]])
        index=index+b[j+1]
    end

    A=spzeros(Int64,length(aorder),length(b))
    for i in 1:length(hyper)
        for j=1:length(hyper[i])
            A[hyper[i][j],i]=A[hyper[i][j],i]+1
        end
    end
    d=zeros(Int64,length(aorder))
    for q=1:length(aorder); d[q]=length(findall(a.==q)); end
    A=A*A'-spdiagm(0=>d)
    return A
end
