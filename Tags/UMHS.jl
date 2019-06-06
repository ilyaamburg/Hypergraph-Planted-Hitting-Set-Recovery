# The Union of Minimal Hitting Sets algorithm for recovery of planted
# hitting sets in hypergraphs
#
# Inputs a and b characterize the hypergraph in that a is a flattening of
# the nodes in the hypergraph while b counts how many nodes appear in each
# hyperedge. So if the network is given by [[1,2,3],[3,4]] then
# a=[1,2,3,3,4] and b=[3,2]. Input nhits simply gives the number of times
# the greedy Algorithm 1 subroutines is called. Typically this parameter does
# not have to be too large to obtain good results.

using Random
function UMHS(a::Array{Int64,1},b::Array{Int64,1},nhit::Int64)

    # Partition a into hyperedge
    hyper=[a[1:b[1]]]
    index=b[1]
    for j in 1:length(b)-1
        push!(hyper,a[index+1:index+b[j+1]])
        index=index+b[j+1]
    end

    umhs=zeros(Int64,findmax(a)[1])
    for i in 1:nhit
        println(i)
        # r-approximation with a random ordering of hyperedges
        hits=zeros(Int64, findmax(a)[1])
        order=shuffle(hyper)
        while length(order) > 0
            sect=pop!(order)
            if hits[sect]==zeros(Int64, length(sect)); hits[sect]=ones(Int64, length(sect)); end
        end

        #Remove nodes that do not intersect with other hyperedges
        while true
            reduced=false
            for h in shuffle(findall(hits.==1))
                nbrs=[];
                for k in 1:length(hyper)
                    if length(findall(hyper[k].==h))>0; append!(nbrs,hyper[k]); end
                end
                unique!(nbrs)
                if sum(hits[nbrs])==length(nbrs)
                    hits[h]=0
                    reduced=true
                end
            end
            if !reduced; break; end
        end

        #Indicator function to index
        hits=findall(hits.==1)

        #Reduce to minimal hitting sets
        smallerhits=deepcopy(hits)
        for u in 1:length(hits)
            remove=hits[u]
            reducedhits=setdiff(smallerhits,remove)
            n=0
            for z in 1:length(hyper)
                if length(intersect(hyper[z],reducedhits))>0; n=n+1; end
            end
            if length(hyper)==n; setdiff!(smallerhits,remove); end
        end
        umhs[smallerhits].=1
    end

    #Sort by degree of vertex (number of hyperedges each vertex is in)
    d=zeros(Int64,length(umhs))
    for q=1:length(umhs); d[q]=length(findall(a.==q)); end
    return [sort(findall(umhs.==1),by=v->d[v],rev=true),
    sort(findall(umhs.==0),by=v->d[v],rev=true)]
end
