include("lowestrank.jl")
function kcore(aa::Array{Int64,1},bb::Array{Int64,1})
        a=deepcopy(aa)
        b=deepcopy(bb)
        hyper=[a[1:b[1]]]
        index=b[1]
        for j in 1:length(b)-1
            push!(hyper,a[index+1:index+b[j+1]])
            index=index+b[j+1]
        end
        unique!(hyper)
        a=vcat(hyper...)
        b=Int64[]
        for h in 1:length(hyper); push!(b,length(hyper[h])); end
results=Int64[]
#for h in 1:10
i=0
while length(a)>0
        lowestdegr=lowestrank(a)
        leng=length(a)
        #println("kcore_length=$leng")
        append!(results,reverse(lowestdegr))
        remove=Int64[]
        for i=1:length(lowestdegr); append!(remove,findall(a.==lowestdegr[i])); end
        if length(lowestdegr)==0;
                open("testing.txt","w") do f
                        write(f,"$a")
                end
        end
        remaining_nodes=setdiff(unique(a),a[remove])
        bsum=cumsum(b)
        for i in remove
                breduce=findfirst(bsum.>=i)
                if breduce==1
                        firstIndex=1
                else
                        firstIndex=bsum[breduce-1]+1
                end
                lastIndex=bsum[breduce]
                if length(intersect([j for j in firstIndex:lastIndex],remove))<=b[breduce]-2
                        b[breduce]=b[breduce]-1
                        a[i]=0
                else
                        b[breduce]=0
                        a[firstIndex:lastIndex]=zeros(lastIndex-firstIndex+1,1)
                end
        end
        if sum(a)==0
                results=reverse(results); prepend!(results,sort(remaining_nodes))
                return unique(results)
        end
        #println("remove=$remove\nremaining_nodes=$remaining_nodes\nlowest=$lowestdegr\na=$a\nbsum=$bsum\nb=$b\n")
        lremove=length(remove)
        lremaining=length(remaining_nodes)
        #println("lremove=$lremove\nlremaining=$lremaining")
        a=a[findall(a.!==0)]
        b=b[findall(b.!==0)]
        hyper=[a[1:b[1]]]
        index=b[1]
        for j in 1:length(b)-1
            push!(hyper,a[index+1:index+b[j+1]])
            index=index+b[j+1]
        end
        unique!(hyper)
        a=vcat(hyper...)
        b=Int64[]
        for h in 1:length(hyper); push!(b,length(hyper[h])); end
        if i>2000; return [0]; end
        i=i+1
end
end