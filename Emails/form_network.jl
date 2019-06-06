using TimeZones
a=Int64[]
b=Int64[]
const FAIL = -1

function remove_quotes(s::AbstractString)
    if length(s) > 0 && s[1] == '"' && s[end] == '"'
        return s[2:(end - 1)]
    end
    return s
end

add_generic_tz(ts::String) = "$(ts) +0000"

function parse_sender(sender::String)
    sender = remove_quotes(strip(sender))
    sender = split(split(sender)[1], "(")[1]
    return strip(strip(sender), '\\')
end

function proper_address(s::AbstractString)
    if  occursin(" ", s); return false; end
    if  occursin(">", s); return false; end
    if !occursin("@", s); return false; end
    if !occursin(".", s); return false; end
    if findfirst(s, "@") != findlast(s, "@"); return false; end
    return true
end

function parse_receivers(receivers::String)
    parsed_receivers = String[]
    receivers = remove_quotes(receivers)
    for rcvr in split(receivers, ",")
        rcvr = strip(rcvr)
        if length(rcvr) == 0; continue; end
        rcvr = remove_quotes(rcvr)
        bad = false
        first = 0
        try
            first = findfirst(rcvr, '<')
        catch
            first = 0
        end
        if first > 0
            last = findfirst(rcvr, '>')
            if last == 0; continue; end
            if sum(collect(rcvr) .== '<') > 1; continue; end
            if sum(collect(rcvr) .== '>') > 1; continue; end
            rcvr = rcvr[(first + 1):(last - 1)]
        end

        rcvr = strip(rcvr)
        if length(rcvr) == 0; continue; end
        rcvr = split(rcvr)[1]
        if length(rcvr) == 0; continue; end
        rcvr = split(rcvr, "(")[1]
        if length(rcvr) == 0; continue; end
        rcvr = strip(strip(rcvr), '\\')
        if length(rcvr) == 0; continue; end

        if proper_address(rcvr)
            push!(parsed_receivers, rcvr)
        end
    end
    return parsed_receivers
end

function parse_email_file(filename::String)
    sender = ""
    receivers = ""
    timestamp = ""
    open(filename) do f
        for line in eachline(f)
            line = transcode(String, line)
            try line = strip(string(line)); catch; continue; end
            if length(line) > 6 && line[1:6] == "email="
                try sender = lowercase(strip(line[7:end])); catch; return FAIL; end
            end
            if length(line) > 5 && line[1:5] == "sent="
                timestamp = string(strip(line[6:end]))
            end
            if length(line) > 3 && line[1:3] == "To:" && sender != "" && timestamp != ""
                try receivers = lowercase(strip(line[4:end])); catch; continue; end
            end
        end
    end
    if !(occursin("w3.org", sender) || occursin("w3.org", receivers)); return FAIL; end
    if sender == "" || receivers == "" || timestamp == ""; return FAIL; end

    # Try to parse everything
    sender = parse_sender(sender)
    if !proper_address(sender); return FAIL; end
    receivers = [r for r in parse_receivers(receivers) if proper_address(r)]
    if length(receivers) == 0; return FAIL; end

    # Return parsed everything
    return (sender, receivers, timestamp)
end

function is_core(s::AbstractString)
    domain = strip(split(s, "@")[end])
    return occursin("w3.org", domain)
end

function form_network(rank::Int64)
    email_map = Dict{AbstractString,Int64}()
    function mapped_id(x::AbstractString)
        if !haskey(email_map, x)
            id = length(email_map) + 1
            email_map[x] = id
            return id
        end
        return email_map[x]
    end
    open("email-data-W3C-nverts.txt", "w") do f
        open("email-data-W3C-simplices.txt", "w") do g
            for basedir in ["w3c-emails", "w3c-emails-part2", "w3c-emails-part3"]
                for (i, filename) in enumerate(readdir(basedir))
                    dirfile = "$basedir/$filename"
                    ret = parse_email_file(dirfile)
                    println("$i\n$filename\n")
                    if ret != -1
                        sender, receivers, dt = ret
                        #if typeof(dt.utc_datetime.instant.periods) != (Base.Dates.Millisecond); assert(0); end
                        #ts = dt.utc_datetime.instant.periods.value / 1000
                        year = 2000
                        if year > 1985 && year < 2010
                            for receiver in receivers
                                if is_core(sender) || is_core(receiver)
                                    s = mapped_id(sender)
                                    hyperedge=[]
                                    if length(receivers)==rank-1
                                        push!(hyperedge, s)
                                        write(g,"$s\n")
                                        for receiver in receivers
                                            r = mapped_id(receiver); write(g,"$r\n")
                                            push!(hyperedge, r)
                                        end
                                        hyperlength=length(hyperedge)
                                        push!(b,hyperlength)
                                        write(f,"$hyperlength\n")
                                        append!(a,hyperedge)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    # Write out address map
    sorted_data_map = sort([(value, key) for (key, value) in email_map])
    open("address-W3C.txt", "w") do f
        for (value, key) in sorted_data_map
            write(f, "$(value) $(key)\n")
        end
    end

    # Write out core
    core = Int64[]
    for (key, value) in email_map
        if is_core(key); push!(core, value); end
    end
    sort!(core)
    open("email-W3C-temporal-core.txt", "w") do f
        for c in core; write(f, "$c\n"); end
    end
    return(a,b,core)
end
