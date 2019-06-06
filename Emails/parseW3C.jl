function parseW3C()

    for r in [3,4,5]
        aa=parsers("email-W3C-hyperedges.txt")
        bb=parsers("email-W3C-hyperedge-sizes.txt")

        ccore=parsers("email-W3C-core.txt")

        a=Int64[]
        b=Int64[]
        core=Int64[]
        bsum=cumsum(bb)
        lengfirst=bb[1]
        if lengfirst==r
            append!(a,aa[1:lengfirst])
            append!(b,lengfirst)
        end
        for i in 2:length(bb)
            if bb[i]==r
                firstIndex=bsum[i-1]+1
                lastIndex=bsum[i]
                ad=aa[firstIndex:lastIndex]
                for j in 1:r
                    if length(intersect(ccore,ad[j]))>0
                        append!(core,ad[j])
                    end
                end

                append!(a,aa[firstIndex:lastIndex])
                append!(b,bb[i])
            end
        end


        open("email-W3C-$r-nverts.txt", "w") do h
            for hyperl in b
                write(h,"$hyperl\n")
            end
        end

        open("email-W3C-$r-simplices.txt", "w") do g
            for node in a
                write(g,"$node\n")
            end
        end

        open("core-email-W3C-$r.txt", "w") do g
            for node in core
                write(g,"$node\n")
            end
        end
    end

end
parseW3C()
