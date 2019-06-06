include("parsers.jl")
include("UMHSiter.jl")
include("buildtensor.jl")
include("centrality.jl")
include("corerank2.jl")
include("kcore.jl")
include("projectedGraph.jl")
include("BorgattiEverett_order.jl")
using ScikitLearn
@sk_import metrics: average_precision_score

function resultsEmail()
    datasets=["Enron","W3C", "Avocado"]
    for dataset in datasets
        for unif in [3,4,5]
            (a,b)=parsers("email-"*dataset*"-$unif-simplices.txt","email-"*dataset*"-$unif-nverts.txt")
            core=parsers("core-email-"*dataset*"-$unif.txt")
            core=sort(unique(core))
            leng=length(core)
            network_size=length(unique(a))
            aorder=sort(unique(a))
            println([leng, network_size])
            core01=zeros(network_size,1)
            for node in core; core01[findfirst(aorder.==node)]=1; end
            iter=50
            (resultu,coverlength,fraction)=UMHSiter(a,b,core,iter)
            coverlength=coverlength
            results_email50=fraction[50]
            T=buildtensor(a,b,unif)
            # Clique motif Eigenvector Centrality (CEC)
            println("c\n")
            (cec_c, cec_converged) = CEC(T)
            # Z-eigenvector Centrality (ZEC)
            println("z\n")
            (zec_c, zec_converged) = ZEC(T)
            # H-eigenvector Centrality (HEC)
            println("h\n")
            (hec_c, hec_converged) = HEC(T)
            #Projected core periphery scores

            println("kcore")
            k_core=kcore(a,b)
            println("periphery")
            println("graph")
            A=projectedGraph(a,b,unif)
            println("order")
            proj=BorgattiEverett_order(A)
            println("degree")
            resultd=corerank2(a,leng)
            recoveredd=length(intersect(resultd[1:leng],core))/leng
            resultc=sort(aorder,by=v->cec_c[findall(aorder.==v)],rev=true)
            recoveredc=length(intersect(resultc[1:leng],core))/leng
            resultz=sort(aorder,by=v->zec_c[findall(aorder.==v)],rev=true)
            recoveredz=length(intersect(resultz[1:leng],core))/leng
            resulth=sort(aorder,by=v->hec_c[findall(aorder.==v)],rev=true)
            recoveredh=length(intersect(resulth[1:leng],core))/leng
            println("periphery")
            resultp=aorder[proj]
            recoveredp=length(intersect(resultp[1:leng],core))/leng
            println("kcore")
            resultk=k_core
            recoveredk=length(intersect(resultk[1:leng],core))/leng

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

            println(dataset*"$unif")
            hyperlength=length(b)
            open(dataset*"$unif.txt","w") do f; write(f,dataset*"$unif\ncore size=$leng\nnode number=$network_size\nhyperedges=$hyperlength\nUMHS=$results_email50\ndegree=$recoveredd\nclique=$recoveredc\nZ=$recoveredz\nH=$recoveredh\ncore periphery=$recoveredp\nkcore=$recoveredk\nUMHSAUPRC=$precu\ndegreeAUPRC=$precd\ncliqueAUPRC=$precc\nZAUPRC=$precz\nHAUPRC=$prech\ncoreperipheryAUPRC=$precp\nkcore=$preck"); end
            (iterations,fracs)=(coverlength,fraction)
            open(dataset*"-$unif-size-iteration.txt","w") do f
                for it in iterations
                    write(f,"$it\n")
                end
            end
            open(dataset*"-$unif-fraction-recovered-iteration.txt","w") do f
                for frac in fracs
                    write(f,"$frac\n")
                end
            end


        end
    end

end
