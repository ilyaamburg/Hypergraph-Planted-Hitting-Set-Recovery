include("UMHS.jl")
include("degreeRank.jl")
include("CECGeneral.jl")
include("cliqueMotifPageRank.jl")
using DelimitedFiles
using ScikitLearn
@sk_import metrics: average_precision_score

#Enron
#P@CS


a,b=parsers("email-enron-simplices.txt","email-enron-nverts.txt")
core=parsers("core-email-Enron.txt")
leng=length(core)
aorder=sort(unique(a))
network_size=length(aorder)
(resultu,coverlength,fraction)=UMHSiter(a,b,core,40)
resultd=degreeRank(a,b)
resultc=CECGeneral(a,b)
resultp=cliqueMotifPageRank(a,b)

recoveredu=length(intersect(resultu[1:leng],core))/leng
recoveredd=length(intersect(resultd[1:leng],core))/leng
recoveredc=length(intersect(resultc[1:leng],core))/leng
recoveredp=length(intersect(resultp[1:leng],core))/leng

resultpr=[recoveredu,recoveredd,recoveredc,recoveredp]


#
# AUPRC
for i in 1:length(core)
    if findfirst(a.==core[i])==nothing
        println(core[i])
    end
end
core01=zeros(network_size,1)
for node in core; core01[findfirst(aorder.==node)]=1; end

resultu01=zeros(network_size,1)
for node in resultu[1:leng]; resultu01[findfirst(aorder.==node)]=1; end

resultd01=zeros(network_size,1)
for node in resultd[1:leng]; resultd01[findfirst(aorder.==node)]=1; end

resultc01=zeros(network_size,1)
for node in resultc[1:leng]; resultc01[findfirst(aorder.==node)]=1; end

resultp01=zeros(network_size,1)
for node in resultp[1:leng]; resultp01[findfirst(aorder.==node)]=1; end

precu=average_precision_score(core01,resultu01)
precd=average_precision_score(core01,resultd01)
precc=average_precision_score(core01,resultc01)
precp=average_precision_score(core01,resultp01)

resultprec=[precu,precd,precc,precp]

open("higher-order/enron-pacs.txt","w") do f
    for result in resultpr
        write(f,"$result\n")
    end
end
open("higher-order/enron-auprc.txt","w") do f
    for result in resultprec
        write(f,"$result\n")
    end
end
