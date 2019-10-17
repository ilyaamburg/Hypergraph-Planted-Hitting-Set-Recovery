include("cliqueMotifPageRank.jl")
include("centrality.jl")
include("parsers.jl")
include("corerank2.jl")
include("projectedGraphNonuniform.jl")
using Statistics
using ScikitLearn
include("BorgattiEverett_order.jl")
@sk_import metrics:average_precision_score
using Random
Random.seed!(1234)
function pagerankEmailUniform()
    datasets = ["Enron", "W3C", "Avocado"]
    for dataset in datasets
        tPR = []
        pPR = []
        AUPRCpr = []
        for unif in [3, 4, 5]
            (a, b) = parsers(
                "email-" * dataset * "-$unif-simplices.txt",
                "email-" * dataset * "-$unif-nverts.txt",
            )
            core = parsers("core-email-" * dataset * "-$unif.txt")
            core = sort(unique(core))
            leng = length(core)
            network_size = length(unique(a))
            aorder = sort(unique(a))
            println([leng, network_size])
            core01 = zeros(network_size, 1)
            for node in core; core01[findfirst(aorder .== node)] = 1; end
            println("graph")
            Tgr1 = @elapsed A = projectedGraphNonuniform(a, b)
            println("page rank")
            tPR11 = @elapsed pr = cliqueMotifPageRank(a, b)
            println("order")
            resultpr = pr
            pPR11 = length(intersect(resultpr[1:leng], core)) / leng
            resultpr01 = zeros(network_size, 1)
            for node in resultpr[1:leng]; resultpr01[findfirst(aorder .== node)] = 1; end
            precpr = average_precision_score(core01, resultpr01)

            push!(pPR, pPR11)
            push!(AUPRCpr, precpr)
        end
        open("pagerank-email-$dataset-uniform-statistics.txt", "w") do f; write(f, "P@CS [pr] [$pPR] AUPRC [pr] [$AUPRCpr]"); end
    end
end
pagerankEmailUniform()
