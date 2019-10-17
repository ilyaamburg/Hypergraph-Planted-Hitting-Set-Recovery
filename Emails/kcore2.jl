include("corerank2.jl")
function kcore2(aa::Array{Int64,1},bb::Array{Int64,1})
        a=deepcopy(aa)
        b=deepcopy(bb)
results=Int64[]
while length(a.==0)>2
        lowestdegr=last(corerank2(a,length(unique(a))))
        push!(results,lowestdegr)
        remove=findall(a.==lowestdegr)
        bsum=cumsum(b)
        for i in remove

                if 0!==1
                        breduce=findfirst(bsum.>=i)
                        if b[breduce]!==2
                                b[breduce]=b[breduce]-1
                                a[i]=0
                        else
                                b[i]=0
                                if bsum[breduce]==i
                                        a[i]=0
                                        a[i-1]=0
                                else
                                        a[i]=0
                                        a[i+1]=0
                                end
                        end
                end
                println("lowest=$lowestdegr\na=$a\nbsum=$bsum\nb=$b\n")
        end
end


append!(results,sort(a,rev=true))
#return lowestdegr


return reverse(results)
end
