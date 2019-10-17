include("projectedGraphNonuniform.jl")
include("cliqueMotifPageRank.jl")
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
include("CECGeneral.jl")
using ScikitLearn
@sk_import metrics: average_precision_score

function resultsEmailNonuniform()
    datasets=["Enron","W3C", "Avocado"]
    for dataset in datasets
        for unif in [25]
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
            cec_c = CECGeneral(a,b)
            A=projectedGraphNonuniform(a,b)
            pr=cliqueMotifPageRank(a,b)
            k_core=kcore(a,b)
            println("order")
            proj=BorgattiEverett_order(A)
            resultd=corerank2(a,leng)
            recoveredd=length(intersect(resultd[1:leng],core))/leng
            resultc=cec_c
            recoveredc=length(intersect(resultc[1:leng],core))/leng
            resultpr=pr
            recoveredpr=length(intersect(resultpr[1:leng],core))/leng
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

            resultpr01=zeros(network_size,1)
            for node in resultpr[1:leng]; resultpr01[findfirst(aorder.==node)]=1; end

            resultp01=zeros(network_size,1)
            for node in resultp[1:leng]; resultp01[findfirst(aorder.==node)]=1; end

            resultk01=zeros(network_size,1)
            for node in resultk[1:leng]; resultk01[findfirst(aorder.==node)]=1; end

            precu=average_precision_score(core01,resultu01)
            precd=average_precision_score(core01,resultd01)
            precc=average_precision_score(core01,resultc01)
            precpr=average_precision_score(core01,resultpr01)
            precp=average_precision_score(core01,resultp01)
            preck=average_precision_score(core01,resultk01)

            println(dataset*"$unif")
            hyperlength=length(b)
            open(dataset*"$unif.txt","w") do f; write(f,dataset*"$unif\ncore size=$leng\nnode number=$network_size\nhyperedges=$hyperlength\nUMHS=$results_email50\ndegree=$recoveredd\nclique=$recoveredc\nPR=$recoveredpr\ncore periphery=$recoveredp\nkcore=$recoveredk\nUMHSAUPRC=$precu\ndegreeAUPRC=$precd\ncliqueAUPRC=$precc\nPRAUPRC=$precpr\ncoreperipheryAUPRC=$precp\nkcore=$preck"); end
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




resultsEmailNonuniform()
