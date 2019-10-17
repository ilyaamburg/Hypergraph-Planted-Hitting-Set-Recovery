include("cliqueMotifPageRank.jl")
include("getcoreConf.jl")
include("gethyperConf.jl")
include("CECGeneral.jl")
include("UMHS.jl")
include("centrality.jl")
include("parsers.jl")
include("corerank2.jl")
include("UMHSiter.jl")
include("centrality.jl")
include("kcore.jl")
include("projectedGraphNonuniform.jl")
include("BorgattiEverett_order.jl")
using Statistics

using ScikitLearn
@sk_import metrics: average_precision_score
using Random
Random.seed!(1234)
confs_full=[[[[1]],[[2]],[[419, 2011], [4132, 2003], [4741, 2011], [2478, 2006], [5363, 2002], [5800, 2011], [2811, 2014], [5663, 2011], [2392, 2001], [5899, 2007], [4833, 2012], [3272, 2014], [1266, 2014], [2864, 2006], [1379, 2013], [4160, 2003], [689, 2004], [4932, 2013], [995, 2009], [5179, 2013], [3089, 2004], [5028, 2002], [599, 2012], [3942, 2009], [6604, 2014], [3432, 2014], [2458, 2011], [2177, 2011], [1664, 2007], [1078, 2010], [5963, 2005], [5443, 2011], [7579, 2009], [1334, 2012], [7280, 2004], [4798, 2014], [374, 2014], [6801, 2014], [6061, 2013], [1193, 2011], [3172, 2009], [2960, 2010], [6415, 2009], [3517, 2012], [5834, 2005], [5022, 2013], [6584, 2002], [2571, 2013], [1282, 2007], [2187, 2011]],[[2686, 2004], [3419, 2012], [3848, 2005], [3194, 2006], [3238, 2007], [4726, 2008], [6205, 2005], [4024, 2004], [5514, 2006], [6036, 2011], [3088, 2007], [7664, 2003], [1517, 2004], [812, 2004], [3909, 2009], [1021, 2012], [1694, 2008], [3436, 2011], [6362, 2004], [6931, 2006], [4800, 2006], [5781, 2005], [7333, 2014], [2113, 2013], [7280, 2005], [6447, 2008], [1540, 2010], [5590, 2014], [6881, 2007], [4368, 2010], [2739, 2012], [4159, 2013], [5425, 2006], [849, 2010], [4302, 2001], [3571, 2006], [1055, 2014], [436, 2005], [6240, 2009], [576, 2007], [730, 2011], [3963, 2010], [603, 2013], [1490, 2014], [5963, 2004], [812, 2006], [6844, 2014], [3007, 2009], [2319, 2002], [5908, 2004]],[[5936, 2006], [7613, 2004], [6751, 2013], [3189, 2005], [1489, 2008], [5087, 2010], [2085, 2006], [3532, 2009], [3848, 2013], [2202, 2012], [7845, 2008], [2633, 2005], [5434, 2009], [5365, 2013], [1695, 2014], [383, 2010], [226, 2006], [2123, 2006], [7810, 2013], [6255, 2012], [3011, 2008], [7474, 2003], [7653, 2014], [5592, 2007], [4363, 2007], [2415, 2005], [128, 2008], [6010, 2011], [7664, 2007], [1463, 2013], [2558, 2008], [2463, 2009], [4590, 2014], [6041, 2010], [2862, 2014], [3067, 2009], [88, 2012], [4778, 2013], [7735, 2002], [1973, 2011], [2136, 2009], [3027, 2014], [2218, 2005], [7002, 2014], [3628, 2008], [1346, 2004], [3184, 2001], [4861, 2012], [114, 2011], [7320, 2006]]]
function resultsConfNonuniform()
    for rank in [3,4,5]
        used_confy=[[1,1897]]
        maxim=50
        tU=[]
        pU=[]
        tD=[]
        pD=[]
        tC=[]
        pC=[]
        tPR=[]
        pPR=[]
        tP=[]
        pP=[]
        tK=[]
        pK=[]
        AUPRCu=[]
        AUPRCd=[]
        AUPRCc=[]
        AUPRCpr=[]
        AUPRCp=[]
        AUPRCk=[]
        lengths=Int64[]
        corelengths=Int64[]
        coverlengths=[Float64[]]
        fractions=[Float64[]]
        numberhyper=Int64[]
        n=1
        for l=1:maxim
            conference=confs_full[rank][l][1]
            year=confs_full[rank][l][2]
            core=getcoreConf(conference,year,rank)
            if length(core)>199||length(core)==0||length(intersect(used_confy,[[conference,year]]))>0; continue; end
            println("iter=$n, conf=$conference$year")
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

                println("graph")
                Tgr1=@elapsed A=projectedGraphNonuniform(a,b)
                println("page rank")
                tPR11=@elapsed pr=cliqueMotifPageRank(a,b)
                println("order")

                resultpr=pr
                pPR11=length(intersect(resultpr[1:leng],core))/leng


                #precision at core size







                resultpr01=zeros(network_size,1)
                for node in resultpr[1:leng]; resultpr01[findfirst(aorder.==node)]=1; end




                precpr=average_precision_score(core01,resultpr01)


            else
                continue
            end

            push!(pPR,pPR11)
            push!(AUPRCpr,precpr)

            n=n+1

        end
        sdPR1=std(pPR)
        mnPR1=mean(pPR)
        sdAUPRCpr=std(AUPRCpr)
        mnAUPRCpr=mean(AUPRCpr)
        open("conference-results/statistics/pagerank-confs-DBLP-$rank-statistics.txt", "w") do f; write(f, "P@CS mean [pr] [$mnPR1] sd [pr] [$sdPR1]\n AUPRC mean [pr] [$mnAUPRCpr] sd [pr] [$sdAUPRCpr]"); end
    end
end
#end
#end
resultsConfNonuniform()
