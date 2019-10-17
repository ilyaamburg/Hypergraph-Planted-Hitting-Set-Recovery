include("projectedGraphNonuniform.jl")
include("cliqueMotifPageRank.jl")
include("getcoreTagsNonuniform.jl")
include("gethyperTagsNonuniform.jl")
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
include("CECGeneral.jl")
using Statistics

using ScikitLearn
@sk_import metrics: average_precision_score


using Random
Random.seed!(1234)
tags_full=[[1],[2],[1496, 1532, 1203, 1236, 1479, 1216, 1019, 1284, 1567, 1133, 1625, 1485, 1132, 1438, 1490, 1172, 1517, 1107, 1317, 1026, 1106, 1144, 1555, 1285, 1529, 1563, 1125, 1152, 1578, 1401, 1596, 1543, 1293, 1370, 1130, 1272, 1391, 1371, 1516, 1439, 1162, 1403, 1119, 1287, 1610, 1530, 1528, 1199, 1579, 1472],
[1269, 1418, 1538, 1272, 1337, 1495, 1104, 1058, 1619, 1354, 1245, 1200, 1103, 1446, 1123, 1482, 1375, 1602, 1373, 1130, 1442, 1199, 1054, 1302, 1026, 1382, 1429, 1521, 1542, 1419, 1579, 1208, 1528, 1613, 1398, 1407, 1096, 1174, 1448, 1604, 1343, 1401, 1094, 1403, 1119, 1392, 1438, 1338, 1261, 1534],
[1297, 1243, 1615, 1534, 1561, 1167, 1340, 1579, 1621, 1447, 1338, 1610, 1425, 1156, 1571, 1308, 1306, 1599, 1512, 1462, 1485, 1504, 1402, 1404, 1434, 1564, 1152, 1236, 1103, 1408, 1387, 1397, 1609, 1481, 1620, 1563, 1111, 1590, 1210, 1260, 1455, 1081, 1454, 1113, 1553, 1596, 1364, 1057, 1218, 1496]]

function resultsTagsNonuniform()
    for dataset in ["math-sx"]
        for rank in [3,4,5]
            used_tags=Int64[]
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
            for l in 1:maxim
                println("tags_number = $n")
                tags=tags_full[rank][l]
                println(tags)
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
            open("tags-results/statistics/pagerank-tags-"*dataset*"-$rank-statistics.txt", "w") do f; write(f, "P@CS mean [pr] [$mnPR1] sd [pr] [$sdPR1]\n AUPRC mean [pr] [$mnAUPRCpr] sd [pr] [$sdAUPRCpr]");
    end
end
end

end

resultsTagsNonuniform()
