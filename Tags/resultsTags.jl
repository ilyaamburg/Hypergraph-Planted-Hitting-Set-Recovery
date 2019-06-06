include("getcoreTags.jl")
include("gethyperTags.jl")
include("buildtensor.jl")
include("UMHS.jl")
include("centrality.jl")
include("parsers.jl")
include("corerank2.jl")
include("UMHSiter.jl")
include("centrality.jl")
include("kcore.jl")
include("projectedGraph.jl")
include("BorgattiEverett_order.jl")
using Statistics

using ScikitLearn
@sk_import metrics: average_precision_score

function resultsTags()
    for dataset in ["math-sx","ask-ubuntu"]
        for rank in [3,4,5]
            used_tags=Int64[]
            maxim=50
            tU=[]
            pU=[]
            tD=[]
            pD=[]
            tC=[]
            pC=[]
            tZ=[]
            pZ=[]
            tH=[]
            pH=[]
            tP=[]
            pP=[]
            tK=[]
            pK=[]
            AUPRCu=[]
            AUPRCd=[]
            AUPRCc=[]
            AUPRCz=[]
            AUPRCh=[]
            AUPRCp=[]
            AUPRCk=[]
            lengths=Int64[]
            corelengths=Int64[]
            coverlengths=[Float64[]]
            fractions=[Float64[]]
            numberhyper=Int64[]
            n=1
            simplices="tags-"*dataset*"-simplices.txt"
            nverts="tags-"*dataset*"-nverts.txt"
            (aa,bb)=parsers(simplices,nverts)
            lengOverall=findmax(aa)[1]
            # Partition a into hyperedge
            hyper=[aa[1:bb[1]]]
            index=bb[1]
            for j in 1:length(bb)-1
                push!(hyper,aa[index+1:index+bb[j+1]])
                index=index+bb[j+1]
            end
            unique!(hyper)
            while n<maxim+1
                println("tags_number = $n")
                tags=rand((1000:lengOverall))
                if length(intersect(tags,used_tags))>0; continue; end
                core=getcoreTags(hyper,[tags],rank)
                if length(core)==1||length(core)>15; continue; end
                (a,b)=gethyperTags(hyper,core,rank)
                if length(unique(a))>1
                    push!(lengths,length(unique(a)))
                    push!(numberhyper,length(b))
                    core=sort(unique(core))
                    leng=length(core)
                    push!(corelengths,leng)
                    network_size=length(unique(a))
                    aorder=sort(unique(a))
                    println([leng, network_size])
                    core01=zeros(network_size,1)
                    for node in core; core01[findfirst(aorder.==node)]=1; end
                    iter=50
                    tK11=@elapsed k_core=kcore(a,b)
                    println("kcore")
                    if k_core==[0]; continue; end
                    println("i=$n")
                    tU11=@elapsed (resultu,coverlength,fraction)=UMHSiter(a,b,core,iter)
                    pU11=fraction[50]
                    tensorTime=@elapsed T=buildtensor(a,b,rank)
                    # Clique motif Eigenvector Centrality (CEC)
                    println("c\n")
                    tC11=@elapsed (cec_c, cec_converged) = CEC(T)
                    # Z-eigenvector Centrality (ZEC)
                    println("z\n")
                    tZ11=@elapsed (zec_c, zec_converged) = ZEC(T)
                    # H-eigenvector Centrality (HEC)
                    println("h\n")
                    tH11=@elapsed (hec_c, hec_converged) = HEC(T)
                    #Projected core periphery scores
                    tC11=tC11+tensorTime; tZ11=tZ11+tensorTime;
                    println("graph")
                    Tgr1=@elapsed A=projectedGraph(a,b,rank)
                    println("order")
                    Tgr2=@elapsed proj=BorgattiEverett_order(A)
                    tP11=Tgr1+Tgr2
                    println("degree")
                    tD11=@elapsed resultd=corerank2(a,leng)
                    pD11=length(intersect(resultd[1:leng],core))/leng
                    resultc=sort(aorder,by=v->cec_c[findall(aorder.==v)],rev=true)
                    pC11=length(intersect(resultc[1:leng],core))/leng
                    resultz=sort(aorder,by=v->zec_c[findall(aorder.==v)],rev=true)
                    pZ11=length(intersect(resultz[1:leng],core))/leng
                    resulth=sort(aorder,by=v->hec_c[findall(aorder.==v)],rev=true)
                    pH11=length(intersect(resulth[1:leng],core))/leng
                    resultp=aorder[proj]
                    pP11=length(intersect(resultp[1:leng],core))/leng
                    resultk=k_core
                    pK11=length(intersect(resultk[1:leng],core))/leng

                    #precision at core size




                    resultu01=zeros(network_size,1)

                    for node in resultu[1:leng]; resultu01[findfirst(aorder.==node)]=1; end


                    resultd01=zeros(network_size,1)
                    for node in resultd[1:leng]; resultd01[findfirst(aorder.==node)]=1; end

                    resultc01=zeros(network_size,1)
                    for node in resultc[1:leng]; resultc01[findfirst(aorder.==node)]=1; end

                    resultz01=zeros(network_size,1)
                    for node in resultz[1:leng]; resultz01[findfirst(aorder.==node)]=1; end

                    resulth01=zeros(network_size,1)
                    for node in resulth[1:leng]; resulth01[findfirst(aorder.==node)]=1; end

                    resultp01=zeros(network_size,1)
                    for node in resultp[1:leng]; resultp01[findfirst(aorder.==node)]=1; end

                    resultk01=zeros(network_size,1)
                    for node in resultk[1:leng]; resultk01[findfirst(aorder.==node)]=1; end

                    precu=average_precision_score(core01,resultu01)
                    precd=average_precision_score(core01,resultd01)
                    precc=average_precision_score(core01,resultc01)
                    precz=average_precision_score(core01,resultz01)
                    prech=average_precision_score(core01,resulth01)
                    precp=average_precision_score(core01,resultp01)
                    preck=average_precision_score(core01,resultk01)
                else
                    continue
                end

                push!(tU,tU11)
                push!(pU,pU11)
                push!(tD,tD11)
                push!(pD,pD11)
                push!(tC,tC11)
                push!(pC,pC11)
                push!(tZ,tZ11)
                push!(pZ,pZ11)
                push!(tH,tH11)
                push!(pH,pH11)
                push!(tP,tP11)
                push!(pP,pP11)
                push!(tK,tK11)
                push!(pK,pK11)
                push!(fractions,fraction)
                push!(coverlengths,coverlength)
                push!(used_tags,tags)

                push!(AUPRCu,precu)
                push!(AUPRCd,precd)
                push!(AUPRCc,precc)
                push!(AUPRCz,precz)
                push!(AUPRCh,prech)
                push!(AUPRCp,precp)
                push!(AUPRCk,preck)

                n=n+1

            end


            betterD=length(findall(pU.>=pD))
            betterC=length(findall(pU.>=pC))
            betterZ=length(findall(pU.>=pZ))
            betterH=length(findall(pU.>=pH))
            betterP=length(findall(pU.>=pP))
            betterK=length(findall(pU.>=pK))

            AUPRCbetterD=length(findall(AUPRCu.>=AUPRCd))
            AUPRCbetterC=length(findall(AUPRCu.>=AUPRCc))
            AUPRCbetterZ=length(findall(AUPRCu.>=AUPRCz))
            AUPRCbetterH=length(findall(AUPRCu.>=AUPRCh))
            AUPRCbetterP=length(findall(AUPRCu.>=AUPRCp))
            AUPRCbetterK=length(findall(AUPRCu.>=AUPRCk))

            sdU1=std(pU)
            mnU1=mean(pU)
            sdD1=std(pD)
            mnD1=mean(pD)
            sdC1=std(pC)
            mnC1=mean(pC)
            sdZ1=std(pZ)
            mnZ1=mean(pZ)
            sdH1=std(pH)
            mnH1=mean(pH)
            sdP1=std(pP)
            mnP1=mean(pP)
            sdK1=std(pK)
            mnK1=mean(pK)
            sdAUPRCu=std(AUPRCu)
            mnAUPRCu=mean(AUPRCu)
            sdAUPRCd=std(AUPRCd)
            mnAUPRCd=mean(AUPRCd)
            sdAUPRCc=std(AUPRCc)
            mnAUPRCc=mean(AUPRCc)
            sdAUPRCz=std(AUPRCz)
            mnAUPRCz=mean(AUPRCz)
            sdAUPRCh=std(AUPRCh)
            mnAUPRCh=mean(AUPRCh)
            sdAUPRCp=std(AUPRCp)
            mnAUPRCp=mean(AUPRCp)
            sdAUPRCk=std(AUPRCk)
            mnAUPRCk=mean(AUPRCk)


            smallcore=findmin(corelengths)[1]
            bigcore=findmax(corelengths)[1]
            smallvert=findmin(lengths)[1]
            bigvert=findmax(lengths)[1]
            smallhyper=findmin(numberhyper)[1]
            bighyper=findmax(numberhyper)[1]

            open("tags-results/statistics/tags-"*dataset*"-$rank-statistics.txt", "w") do f; write(f, dataset*"$rank\nP@CS mean [u,d,c,z,h,p,k] [$mnU1,$mnD1,$mnC1,$mnZ1,$mnH1,$mnP1,$mnC1] sd [u,d,c,z,h,p,k] [$sdU1,$sdD1,$sdC1,$sdZ1,$sdH1,$sdP1,$sdK1]\n AUPRC mean [u,d,c,z,h,p,k] [$mnAUPRCu,$mnAUPRCd,$mnAUPRCc,$mnAUPRCz,$mnAUPRCh,$mnAUPRCp,$mnAUPRCk] sd [u,d,c,z,h,p,k] [$sdAUPRCu,$sdAUPRCd,$sdAUPRCc,$sdAUPRCz,$sdAUPRCh,$sdAUPRCp,$sdAUPRCk]\nbetter than [D,C,Z,H,P,K] core precision at [$betterD,$betterC,$betterZ,$betterH,$betterP,$betterK] nodes\nbetter than [D,C,Z,H,P,K] AUPRC at [$AUPRCbetterD,$AUPRCbetterC,$AUPRCbetterZ,$AUPRCbetterH,$AUPRCbetterP,$AUPRCbetterK] nodes\nsmallest core=$smallcore\nbiggest core=$bigcore\nsmallest nodes=$smallvert\nbiggest nodes=$bigvert\nsmallesthyper=$smallhyper\nbiggest hyper=$bighyper"); end
            end
    end
end

resultsTags()
