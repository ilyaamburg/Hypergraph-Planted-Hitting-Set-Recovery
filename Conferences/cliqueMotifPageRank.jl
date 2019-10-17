using SparseArrays
using LinearAlgebra
using LightGraphs
using Arpack


function cliqueMotifPageRank(aa::Array{Int64,1},bb::Array{Int64,1},alpha::Float64=0.9)
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

    A=spzeros(Float64,length(aorder),length(b))
    for i in 1:length(hyper)
        for j=1:length(hyper[i])
            A[hyper[i][j],i]=A[hyper[i][j],i]+1
        end
    end
    d=zeros(Int64,length(aorder))
    for q=1:length(aorder); d[q]=length(findall(a.==q)); end
    A=A*A'-spdiagm(0=>d)
    for j in 1:length(aorder); A[:,j]=A[:,j]/sum(A[:,j]); end
    onevect=ones(Float64,length(aorder))
    P=(alpha*A+(1-alpha)*(1/length(aorder))*onevect*onevect')
    #return P
    v = eigs(P,nev=1,which=:LR,tol=1e-5,maxiter=200)[2][:,1]
    v=real(v)
    if v[1]<0; v=-v; end
    v=v/norm(v, 1)
    index= sort(aorder,by=x->v[x],rev=true)
    return [aaorder[index[i]] for i in 1:length(aorder)]
end
function fraccliqueMotifPageRank(aa::Array{Int64,1},bb::Array{Int64,1},alpha::Float64=0.9)
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

    A=spzeros(Float64,length(aorder),length(b))
    for i in 1:length(hyper)
        for j=1:length(hyper[i])
            A[hyper[i][j],i]=A[hyper[i][j],i]+1
        end
    end
    d=zeros(Int64,length(aorder))
    for q=1:length(aorder); d[q]=length(findall(a.==q)); end
    A=A*A'-spdiagm(0=>d)
    for j in 1:length(aorder); A[:,j]=A[:,j]/sum(A[:,j]); end
    onevect=ones(Float64,length(aorder))
    P=(alpha*A+(1-alpha)*(1/length(aorder))*onevect*onevect')
    #return P
    v = eigs(P,nev=1,which=:LR,tol=1e-5,maxiter=200)[2][:,1]
    v=real(v)
    if v[1]<0; v=-v; end
    v=v/norm(v, 1)
    return v
end
