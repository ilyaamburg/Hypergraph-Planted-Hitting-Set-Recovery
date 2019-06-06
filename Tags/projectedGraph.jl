using SparseArrays
function projectedGraph(aa::Array{Int64,1},bb::Array{Int64,1},rank::Int64)
    aaorder=sort(unique(aa))
    a=replace(x->findall(aaorder.==x)[1],aa)
    b=bb
    aorder=unique(sort(a))
    result=spzeros(Int64,length(aorder),length(aorder))
    # Partition a into hyperedge
    hyper=[a[1:b[1]]]
    index=b[1]
    for j in 1:length(b)-1
        push!(hyper,a[index+1:index+b[j+1]])
        index=index+b[j+1]
    end
    if rank==3
        for k in 1:length(hyper)
            f=hyper[k][1]; s=hyper[k][2]
            l=hyper[k][3]
            result[f,s]=result[f,s]+1
            result[f,l]=result[f,l]+1
            result[s,f]=result[s,f]+1
            result[s,l]=result[s,l]+1
            result[l,f]=result[l,f]+1
            result[l,s]=result[l,s]+1
        end
    elseif rank ==4
        for k in 1:length(hyper)
            f=hyper[k][1]; s=hyper[k][2]; t=hyper[k][3]; l=hyper[k][4];
            result[f, s]=result[f, s]+1; result[f, t]=result[f, t]+1; result[f, l]=result[f, l]+1; result[s, f]=result[s,
            f]+1; result[s, t]=result[s, t]+1; result[s, l]=result[s, l]+1; result[t, f]=result[t, f]+1; result[t,
            s]=result[t, s]+1; result[t, l]=result[t, l]+1; result[l, f]=result[l, f]+1; result[l, s]=result[l,
            s]+1; result[l, t]=result[l, t]+1
        end


    else
        for k in 1:length(hyper)
            f=hyper[k][1]; s=hyper[k][2]; t=hyper[k][3]; r=hyper[k][4]; l=hyper[k][5]
            result[f, s]=result[f, s]+1; result[f, t]=result[f, t]+1; result[f, r]=result[f, r]+1; result[f, l]=result[f,
            l]+1; result[s, f]=result[s, f]+1; result[s, t]=result[s, t]+1; result[s, r]=result[s, r]+1; result[s,
            l]=result[s, l]+1; result[t, f]=result[t, f]+1; result[t, s]=result[t, s]+1; result[t, r]=result[t,
            r]+1; result[t, l]=result[t, l]+1; result[r, f]=result[r, f]+1; result[r, s]=result[r, s]+1; result[r,
            t]=result[r, t]+1; result[r, l]=result[r, l]+1; result[l, f]=result[l, f]+1; result[l, s]=result[l,
            s]+1; result[l, t]=result[l, t]+1; result[l, r]=result[l, r]+1
        end

    end


    return sparse(result)
end
