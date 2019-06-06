using LightXML
include("core.jl")

const phone_key1      = """/o=web by phone/ou=wbp/cn=recipients/cn="""
const phone_key2      = """/o=web by phone/ou=idc/cn=recipients/cn="""
const phone_key3      = """/o=web by phone/ou=epcanada/cn=recipients/cn="""
const phone_key4      = """/o=web by phone/ou=wbp/cn=sitraka/cn="""
const phone_key5      = """/o=kl group inc./ou=exchange.tor/cn=recipients/cn="""
const phone_key6      = """/o=iq.com/ou=office/cn=recipients/cn="""
const source_file_key = "<source_file"
const item_id_key     = "<item id="
const email_type_key  = """type=\"email\" """
const end_item_key    = "</item>"

start_with_key(line::String, key::String) =
    length(line) >= length(key) && line[1:length(key)] == key

function parse_address(addr::AbstractString)
    addr = lowercase(strip(addr))
    addr = strip(addr, '\'')
    addr = strip(addr, '\"')
    addr = strip(addr)
    addr = strip(addr, '\'')
    addr = strip(addr, '\"')    
    addr = strip(addr)
    addr = replace(addr, "   ", " ")
    addr = replace(addr, "  ", " ")    
    if length(addr) == 0; return addr; end
    for phone_key in [phone_key1, phone_key2, phone_key3,
                      phone_key4, phone_key5]
        if start_with_key(addr, phone_key)
            addr = addr[(length(phone_key) + 1):end]
            break
        end
    end
    addr = strip(addr)
    if addr[1] == '\'';   addr = addr[2:end];     end
    if addr[end] == '\''; addr = addr[1:(end-1)]; end
    for str in [" (e-mail)", " - india", " (india)",
                " (business fax)", " (exchange)",
                " (email1)", " (e-mail 2)", " (e-mail 3)", " (cts)", " (drkb)",
                " (mto)", " (xrcc)", " [pcs]", " (off)", " (avocadoit)", " (avocadoit-alternate)",
                "@avocadoit.com",
                "@bugzilla.avocadoit.com", "@bugzillanew.avocadoit.com",
                "@support.avocadoit.com"]
        addr = split(addr, str)[1]
    end
    addr = strip(addr, '\'')
    addr = strip(addr, '\"')    
    addr = strip(addr)
    return convert(String, addr)
end

function parse_email_item(str::String)
    xroot = root(parse_string(str))
    metadata = get_elements_by_tagname(xroot, "metadata")
    if length(metadata) == 0; return (nothing, nothing, nothing); end
    metadata = metadata[1]
    sender    = nothing
    receivers = nothing
    timestamp = nothing
    for c in child_elements(metadata)
        if     attribute(c, "name") == "sender_address"
            sender = parse_address(content(c))
        elseif attribute(c, "name") == "sentto_address"
            receivers = [parse_address(v) for v in split(content(c), ";")]
        elseif attribute(c, "name") == "sent_date"
            # 2001-07-01T10:00:01Z
            dt = DateTime(content(c), "y-m-dTH:M:SZ")
            timestamp = convert(Int64, dt.instant.periods.value / 1000)
        end
    end
    return (sender, receivers, timestamp)
end

function filter_receivers(receivers::Vector{String})
    new_receivers = AbstractString[]
    for rcvr in receivers
        if length(rcvr) == 0; continue; end

        if rcvr in ["2.6_admin tool",
                    "2.6_any db team",
                    "2.6_emds usaability",
                    "2.6_http server certification",
                    "2.6_i18 license",
                    "2.6_imode",
                    "2.6_installation",
                    "2.6_multiple cards",
                    "2.6_offline browsing",
                    "2.6_performance",
                    "2.6_persistence",
                    "2.6_platform certification",
                    "2.6_proxy utility",
                    "2.6_standard api",
                    "systems administrators",
                    "mobility - professional sevices",
                    "monitor etrade",
                    "2.6_standard api",
                    "2.6_wml reduced data",
                    "3.0_admin tool",
                    "3.0_any db team",
                    "3.0_emds usaability",
                    "3.0_http server certification",
                    "3.0_i18 license",
                    "3.0_imode",
                    "3.0_installation",
                    "3.0_japanese",
                    "3.0_jdbc connector",
                    "3.0_multiple cards",
                    "3.0_offline browsing",
                    "3.0_performance",
                    "3.0_persistence",
                    "3.0_platform certification",
                    "3.0_proxy utility",
                    "3.0_standard api",
                    "3.0_wml reduced data",
                    "3.3_j2ee",
                    "3.5_admin tool",
                    "3.5_alerts",
                    "3.5_alwayson",
                    "3.5_https_tunneling",
                    "3.5_installation",
                    "3.5_jdbc",
                    "4.0_rd_team",
                    "@facilities",
                    "@helpdesk",
                    "@opssupport",
                    "admin assistants",
                    "administrator",
                    "ae etrade",
                    "ae- san jose",
                    "all employees",
                    "all employees-india",
                    "all users",
                    "all",
                    "app_framework",
                    "applications engineering contractors",
                    "applications engineering team",
                    "applications team",
                    "applications",
                    "avocadoit event",
                    "avocadoit",
                    "beta feedback",
                    "beta launch",
                    "beta support",
                    "biogen_dev",
                    "biogenproject",
                    "bugzilla-daemon",
                    "bus_ops",
                    "business development team",
                    "channel wave users",
                    "cm team",
                    "cm_emas_3.5_functionaltest",
                    "cm_emas_3.5_sanitytest",
                    "cmadm",
                    "company info",
                    "cs toronto",
                    "cs",
                    "ctia - content development system",
                    "customer marketing",
                    "customer services management",
                    "customer support",
                    "daily",
                    "developersupport",
                    "mobilesiebeldeveloper",
                    "dell online sales",
                    "dinner group",
                    "e_staff",
                    "east coast sales",
                    "emds",
                    "engineering",
                    "ep canada",
                    "epj_support",
                    "ep europe",
                    "ep japan",
                    "epeurope",
                    "prof svcs management",
                    "epj engineering",
                    "epr",
                    "etrade.compid",
                    "executive",
                    "facilities",
                    "faqs",
                    "fdbl client alerts",
                    "fdbl seminars",
                    "fdbl",
                    "finance",
                    "finance&administration",
                    "global telecom business unit",
                    "growth report",
                    "helpdesk",
                    "hiring managers",
                    "i18n_team",
                    "idc all employees",
                    "idc all employees-india",
                    "intelligencer",
                    "intranet team",
                    "it team",
                    "java server team",
                    "leadgen",
                    "leads",
                    "list member",
                    "production_alert",
                    "mail master",
                    "sm. dev",
                    "manager's meeting",
                    "marketing team",                    
                    "mc and se",
                    "members interested in numbering issues",
                    "monitoretrade",
                    "monitoretradefilter",
                    "multiple recipients of list news",
                    "next service pack",
                    "o_staff",
                    "offline development",
                    "online_team",
                    "operations pager",
                    "operations",
                    "ops_pager",
                    "patch request",
                    "pm team",
                    "program mgnt team",
                    "project management",
                    "publications team",
                    "qa team san jose",
                    "qa team",
                    "qateamsanjose",
                    "r&d admin",
                    "r&d alerts",
                    "r&d managers",
                    "r&d qa",
                    "r&d san jose",
                    "r&d team",
                    "r&d tech pubs",
                    "r&d toronto",
                    "r&d",
                    "r&d_dev",
                    "r&d_dev",
                    "r&dalerts",
                    "rdalerts",
                    "receptionist",
                    "rnd_dev",
                    "sales & marketing",
                    "sales and mc",
                    "sales team",
                    "sales_sales",
                    "san jose employees",
                    "santa clara employees",
                    "se support",
                    "se support",
                    "se team",
                    "se",
                    "server engineering",
                    "service pack",
                    "siebel_dev",
                    "stc emerging technologies sig discussions",
                    "support",
                    "tech support",
                    "technical marketing",
                    "telephony server team",
                    "ui team",
                    "undisclosed-recipient:",
                    "unstrung weekly",
                    "us employees",
                    "webmaster",
                    "wireless business & technology",
                    "wireless support group",
                    "xml team",
                    "you_bad_ass_boys_of_avocadoit",
                    "zlist",
                    ]
            continue
        end
        push!(new_receivers, rcvr)
    end
    return new_receivers
end

function process_file(filename::String)
    account = nothing
    currently_building_email_item = false
    email_xml = String[]
    open("$filename.out", "w") do g
        open("xml/$filename") do f
            for line in eachline(f)
                stripped = strip(line)
                if currently_building_email_item
                    push!(email_xml, stripped)
                    if stripped == end_item_key
                        s, rs, ts = parse_email_item(join(email_xml, "\n"))
                        currently_building_email_item = false
                        email_xml = String[]
                        # Skip some things
                        if s == nothing || rs == nothing || ts == nothing; continue; end
                        rs = filter_receivers(rs)
                        if length(rs) == 0; continue; end
                        if s == "bugzilla-daemon"; continue; end
                        write(g, "$s --> $(rs) ($ts)\n")
                    else
                        continue
                    end
                end
                
                # Check for name of person
                if start_with_key(stripped, source_file_key)
                    #<source_file size="268MB">MEHRAK.HAMZEH.PST</source_file>
                    account = content(root(parse_string(stripped)))
                    write(g, "account: $account\n\n")
                end
                
                # Check for start of email
                #<item id="097-000001-EM" type="email" attachments="0" pst-folder-id="3014">
                if start_with_key(stripped, item_id_key) &&
                    findfirst(email_type_key, stripped) != 0:-1
                    currently_building_email_item = true
                    push!(email_xml, stripped)
                    continue
                end
            end
        end
    end
end


function process_graph()
    cmap, max_id = core_map()
    all_map = Dict{AbstractString, Int64}()
    for (k, v) in cmap; all_map[k] = v; end
    next_id = max_id + 1

    function get_mapped_id(x::AbstractString)
        if haskey(all_map, x)
            return all_map[x]
        else
            all_map[x] = next_id
            next_id += 1
            return next_id - 1
        end
    end

    function keep_address(address::String)
        if split(address, "@")[end] in ["1.americanexpress.com",
                                        "24x7reply.sun.com",
                                        "2mbb.com",
                                        "a1f3-tr1.4at3.net",
                                        "away.customer-email.com",
                                        "b.verticalresponse.com",
                                        "b04.ptinv.com",
                                        "banjo.agora.com",
                                        "banjo.agora.com",
                                        "c0olmail.com",
                                        "cahners-mail.flonetwork.com",
                                        "cda01.cdnow.com",
                                        "csfb.xmr3.com",
                                        "dealdelivery.com",
                                        "dealmate.com",
                                        "dealseveryday.com",
                                        "dealsinyouremail.net",
                                        "e-mailprograms.delta.com",
                                        "ejst5.com",
                                        "email.victoriassecret.com",
                                        "emails.iprint.com",
                                        "etoys.reply.tm0.com",
                                        "evalueexpress.com",
                                        "evalueexpress.com",
                                        "expedia.customer-email.com",
                                        "fdbl.net",
                                        "funfabdeals.com",
                                        "gifts.redenvelopegifts.com",
                                        "hbsp.ed10.net",
                                        "hoovers.p0.com",
                                        "illuminations.p0.com",
                                        "imp.enlist.com",
                                        "insync-palm.com",
                                        "link2buy.com",
                                        "lists.plesser.com",
                                        "lists.zoanmail.com",
                                        "listserv.redherring.com",
                                        "madbrandz.com",
                                        "mail212.c0olmail.com",
                                        "mailb.travelocity.com",
                                        "mailsubs.com",
                                        "maui.dlbnetwork.net",
                                        "ms83.com",
                                        "mta01.optamail.com",
                                        "mta12.optamail.com",
                                        "multexinvestornetwork.com",
                                        "mx.lodo.exactis.com",
                                        "news.forbesdigital.com",
                                        "newsletter.online.com",
                                        "newsletters.microsoft.com",
                                        "nws.currentmail.com",
                                        "officemax.p0.com",
                                        "onyx.acc0.com",
                                        "palmplatform.p0.com",
                                        "ppi.currentmail.com",
                                        "reply.dwdata.com",
                                        "reply.ebay.com",
                                        "summertimedeals.com",
                                        "svrn.com",
                                        "thecreek.coldwatercreek.com",
                                        "thesuperspecialsales.com",
                                        "thriftytales.com",
                                        "top-special-offers.com",
                                        "tremendousbuys.com",
                                        "xmr3.com"]
            return false
        end
        splits = split(address, "@")
        if length(splits) == 2 && splits[1] == "hot_deals"; return false; end
        return true
    end

    senders, receivers, timestamps = Int64[], Int64[], Int64[]
    dir = "data/custodians/"
    for file in readdir(dir)  # loop over all files
        currently_building_email_item = false
        email_xml = String[]
        open("$dir/$file") do f
            for line in eachline(f)
                stripped = strip(line)
                
                # Check for start of email
                #<item id="097-000001-EM" type="email" attachments="0" pst-folder-id="3014">
                if start_with_key(stripped, item_id_key) &&
                    findfirst(email_type_key, stripped) != 0:-1
                    currently_building_email_item = true
                    push!(email_xml, stripped)
                    continue
                end
                
                if currently_building_email_item
                    push!(email_xml, stripped)
                    if stripped == end_item_key
                        s, rs, ts = parse_email_item(join(email_xml, "\n"))
                        currently_building_email_item = false
                        email_xml = String[]
                        
                        # Skip some things
                        if s == nothing || rs == nothing || ts == nothing; continue; end
                        if length(rs) == 0; continue; end
                        if s == "bugzilla-daemon"; continue; end
                        if !keep_address(s); continue; end
                        rs = [r for r in rs if keep_address(r)]
                        if length(rs) == 0; continue; end
                        
                        s_mid = get_mapped_id(s)
                        rs = unique(rs)
                        rs_mids = unique([get_mapped_id(r) for r in rs])
                        if haskey(cmap, s)
                            for r_mid in rs_mids
                                push!(senders, s_mid)
                                push!(receivers, r_mid)
                                push!(timestamps, ts)
                            end
                        else
                            for r in rs
                                if haskey(cmap, r)
                                    push!(senders, s_mid)
                                    r_mid = get_mapped_id(r)
                                    push!(receivers, r_mid)
                                    push!(timestamps, ts)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    open("addresses-core-email-Avocado.txt", "w") do f
        for (id, address) in sort([(v, k) for (k, v) in cmap])
            write(f, "$(id) $(address)\n")
        end
    end

    open("email-Avocado.txt", "w") do f
    for (s, r, t) in unique([(x, y, tm) for (x, y, tm) in zip(senders, receivers, timestamps)])
        write(f, "$(s) $(r) $(t)\n")
    end

    open("periph-addresses1.txt", "w") do f1
        open("periph-addresses2.txt", "w") do f2
            for address in sort([k for (k, v) in all_map if !haskey(cmap, k)])
                if findfirst("@", address) != 0:-1
                    write(f1, "$(address)\n")
                else
                    write(f2, "$(address)\n")
                end
            end
        end
    end
end
