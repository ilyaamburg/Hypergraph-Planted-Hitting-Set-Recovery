using Plots
pyplot()
include("parsersPlot.jl")
function emailPlots()
    datasets=["Avocado"]
    iter=50
    for dataset in datasets

            PyPlot.clf()
            to_plot=parsersPlot(dataset*"-3-size-iteration.txt")
            plot(collect(1:iter),to_plot,linewidth=2,grid=false,linestyle=:dash, framestyle=:box, legend=:none, title=dataset*" UMHS output size", xlabel="iteration", ylabel="(output size)/(core size)")
            for rank in [4,5]
                to_plot=parsersPlot(dataset*"-$rank-size-iteration.txt")
                if rank==4
                    lw=3
                else
                    lw=1
                end
                plot!(collect(1:iter),to_plot,linewidth=lw,grid=false,framestyle=:box,tickfontsize=18,titlefontsize=22,guidefontsize=22,legendfontsize=18, legend=:none, title=dataset*" UMHS output size", xlabel="iteration", ylabel="(output size)/(core size)")
            end
            savefig(dataset*"-size.eps")
        PyPlot.clf()
        to_plot=parsersPlot(dataset*"-3-fraction-recovered-iteration.txt")
        plot(collect(1:iter),to_plot,linewidth=2,grid=false,linestyle=:dash,framestyle=:box,label="r=3", title=dataset*" UMHS fraction recovered", xlabel="iteration", ylabel="fraction recovered")
        for rank in [4,5]
            to_plot=parsersPlot(dataset*"-$rank-fraction-recovered-iteration.txt")
            if rank==4
                lw=3
            else
                lw=1
            end
            plot!(collect(1:iter),to_plot,linewidth=lw,grid=false,framestyle=:box,tickfontsize=18,titlefontsize=22,guidefontsize=22,legendfontsize=18, label="r=$rank", title=dataset*" UMHS fraction recovered", xlabel="iteration", ylabel="fraction recovered")

        end
        savefig(dataset*"-fractionrecovered.eps")

    end
    datasets=["Enron","W3C"]
    iter=50
    for dataset in datasets

            PyPlot.clf()
            to_plot=parsersPlot(dataset*"-3-size-iteration.txt")
            plot(collect(1:iter),to_plot,linewidth=2,grid=false,linestyle=:dash, framestyle=:box, legend=:none, title=dataset*" UMHS output size", xlabel="iteration", ylabel="(output size)/(core size)")
            for rank in [4,5]
                to_plot=parsersPlot(dataset*"-$rank-size-iteration.txt")
                if rank==4
                    lw=3
                else
                    lw=1
                end
                plot!(collect(1:iter),to_plot,linewidth=lw,grid=false,framestyle=:box,tickfontsize=18,titlefontsize=22,guidefontsize=22,legendfontsize=18, legend=:none, title=dataset*" UMHS output size", xlabel="iteration", ylabel="(output size)/(core size)")
            end
            savefig(dataset*"-size.eps")
        PyPlot.clf()
        to_plot=parsersPlot(dataset*"-3-fraction-recovered-iteration.txt")
        plot(collect(1:iter),to_plot,linewidth=2,grid=false,linestyle=:dash,framestyle=:box, legend=:none, title=dataset*" UMHS fraction recovered", xlabel="iteration", ylabel="fraction recovered")
        for rank in [4,5]
            to_plot=parsersPlot(dataset*"-$rank-fraction-recovered-iteration.txt")
            if rank==4
                lw=3
            else
                lw=1
            end
            plot!(collect(1:iter),to_plot,linewidth=lw,grid=false,framestyle=:box,tickfontsize=18,titlefontsize=22,guidefontsize=22,legendfontsize=18, legend=:none, title=dataset*" UMHS fraction recovered", xlabel="iteration", ylabel="fraction recovered")

        end
        savefig(dataset*"-fractionrecovered.eps")

    end
end


emailPlots()
