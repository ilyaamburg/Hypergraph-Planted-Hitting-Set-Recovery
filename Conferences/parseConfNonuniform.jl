#using EzXML
#include("../../common.jl")
const proc_start = "<inproceedings"
const proc_end = "</inproceedings"
const auth_start = "<author"
const year_start = "<year"
const booktitle_start = "<booktitle"
const informal_pub = "publtype=\"informal publication\""
function parseConfNonuniform(rank::Int64)
    function has_start_key(ln::String, key::String)
        n_key = length(key)
        return length(ln) > n_key && ln[1:n_key] == key
    end
    # Write out value --> key for a Dict
    function write_data_map(data_map::Dict, outfile::AbstractString)
        sorted_data_map = sort([(value, key) for (key, value) in data_map])
        open(outfile, "w") do f
            for (value, key) in sorted_data_map
                write(f, "$(value) $(key)\n")
            end
        end
    end

    is_publication_start(ln::String) = has_start_key(ln, proc_start)
    is_publication_end(ln::String)   = has_start_key(ln, proc_end)
    no_key(ln::String, key::String)  = !occursin(key, ln)
    function get_val(dict::Dict{AbstractString,Int64}, key::AbstractString)
        if !haskey(dict, key)
            n = length(dict) + 1
            dict[key] = n
            return n
        end
        return dict[key]
    end
    author_map = Dict{AbstractString, Int64}()
    conf_map = Dict{AbstractString, Int64}()
    curr_auths = Int64[]
    curr_year = 0
    curr_conf = 0

    I = Int64[]
    b=Int64[]

    years = Int64[]

    confs = Int64[]

    parsing = false

    f = open("dblp.xml")
    for (linenum, ln) in enumerate(eachline(f))
        if linenum % 10000000 == 0; @show linenum; end
        # Start of paper
        if is_publication_start(ln) && no_key(ln, informal_pub)
            parsing = true
            continue
        end
        if !parsing; continue; end
        # <author>
        if has_start_key(ln, auth_start)
            # Author
            start = findfirst(isequal('>'), ln) + 1
            author = split(ln[start:end], "<")[1]
            auth_key = get_val(author_map, author)
            push!(curr_auths, auth_key)
            continue
        end
        # <year>
        if has_start_key(ln, year_start)
            start = findfirst(isequal('>'), ln) + 1
            curr_year = parse(Int64, split(ln[start:end], "<")[1])
            continue
        end
        # <booktitle>
        if has_start_key(ln, booktitle_start)
            start = findfirst(isequal('>'), ln) + 1
            conf = split(ln[start:end], "<")[1]
            end_ind = findfirst(isequal('('), conf)
            if end_ind != nothing
                conf = strip(conf[1:(end_ind - 1)])
            end
            curr_conf = get_val(conf_map, conf)
            continue
        end

        # End of paper
        if is_publication_end(ln)
            nauth = length(curr_auths)
            if nauth <= rank && nauth>1
                for i = 1:nauth
                    push!(I, curr_auths[i])
                    push!(years, curr_year)
                    push!(confs, curr_conf)
                end
                push!(b,nauth)
            end
            curr_auths = Int64[]
            curr_year = 0
            curr_conf = 0
            parsing = false
        end
    end
    open("conf-DBLP-$rank-simplices.txt", "w") do g
        for node in I
            write(g,"$node\n")
        end
    end

    open("conf-DBLP-$rank-nverts.txt", "w") do g
        for node in b
            write(g,"$node\n")
        end
    end

    open("conf-DBLP-$rank-years.txt", "w") do g
        for node in years
            write(g,"$node\n")
        end
    end

    open("conf-DBLP-$rank-confs.txt", "w") do g
        for node in confs
            write(g,"$node\n")
        end
    end

end
parseConfNonuniform(25)
