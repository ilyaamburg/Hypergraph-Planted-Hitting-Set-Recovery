using LightXML
include("core.jl")

using TimeZones
const phone_key1      = """/o=web by phone/ou=wbp/cn=recipients/cn="""
const phone_key2      = """/o=web by phone/ou=idc/cn=recipients/cn="""
const phone_key3      = """/o=web by phone/ou=epcanada/cn=recipients/cn="""
const phone_key4      = """/o=web by phone/ou=wbp/cn=sitraka/cn="""
const phone_key5      = """/o=kl group inc./ou=exchange.tor/cn=recipients/cn="""
const phone_key6      = """/o=iq.com/ou=office/cn=recipients/cn="""
const phone_key7      = """/o=mitsubishi/ou=meamela/cn=recipients/cn="""
const phone_key8      = """/o=puma technology, inc./ou=puma west/cn=recipients/cn="""
const phone_key9      = """/o=web by phone/ou=wbp/cn=configuration/cn=servers/cn=hqexch01/cn="""
const source_file_key = "<source_file"
const item_id_key     = "<item id="
const email_type_key  = """type=\"email\" """
const end_item_key    = "</item>"

starts_with_key(line::AbstractString, key::String) =
    length(line) >= length(key) && line[1:length(key)] == key

function parse_address(addr::AbstractString)
    addr = lowercase(strip(addr))
    addr = strip(addr, '\'')
    addr = strip(addr, '\"')
    addr = strip(addr)
    addr = strip(addr, '\'')
    addr = strip(addr, '\"')
    addr = strip(addr)
    addr = replace(addr, "   "=> " ")
    addr = replace(addr, "  "=> " ")
    if length(addr) == 0; return addr; end
    for phone_key in [phone_key1, phone_key2, phone_key3,
                      phone_key4, phone_key5, phone_key6,
                      phone_key7, phone_key8, phone_key9,]
        if starts_with_key(addr, phone_key)
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
                " (mto)", " (xrcc)", " [pcs]", " (work)", " (altavista)", " (off)",
                " (avocadoit)", " - work", " (pathway)",
                "@avocadoit.com",
                "@bugzilla.avocadoit.com", "@bugzillanew.avocadoit.com",
                "@support.avocadoit.com"]
        addr = split(addr, str)[1]
    end
    addr = strip(split(addr, " -")[1])
    addr = strip(split(addr, ",")[1])
    addr = strip(split(addr, "<")[1])
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
            #dt = DateTime(content(c), "y-m-dTH:M:SZ")
            #timestamp = convert(Int64, dt.instant.periods.value / 1000)
            #
            #
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

function keep_address(address::String)
    if split(address, "@")[end] in ["1.americanexpress.com",
                                    "24x7reply.sun.com",
                                    "2mbb.com",
                                    "a1f3-tr1.4at3.net",
                                    "away.customer-email.com",
                                    "b.verticalresponse.com",
                                    "b01.ptinv.com",
                                    "b04.ptinv.com",
                                    "banjo.agora.com",
                                    "beema.nl00.net",
                                    "c0olmail.com",
                                    "cahners-mail.flonetwork.com",
                                    "cahners.flonetwork.com",
                                    "cancun.rbexpress.org",
                                    "caymans.responsego.com",
                                    "cda01.cdnow.com",
                                    "csfb.xmr3.com",
                                    "dealdelivery.com",
                                    "dealmate.com",
                                    "dealseveryday.com",
                                    "dealsinyouremail.net",
                                    "dm.prognostics.com",
                                    "e-mailprograms.delta.com",
                                    "ejst5.com",
                                    "email.victoriassecret.com",
                                    "emails.iprint.com",
                                    "enews.buy.com",
                                    "eros.rbidaho.net",
                                    "eros.rbmailsource.com",
                                    "etoys.reply.tm0.com",
                                    "evalueexpress.com",
                                    "everydayoffers.com",
                                    "ewk.omessage.com",
                                    "expedia.customer-email.com",
                                    "fdbl.net",
                                    "funfabdeals.com",
                                    "gifts.redenvelopegifts.com",
                                    "greatest-specials.com",
                                    "greatest-specials.com",
                                    "handspring.p0.com",
                                    "hbsp.ed10.net",
                                    "hoovers.p0.com",
                                    "hot-farealert.p0.com",
                                    "illuminations.p0.com",
                                    "imp.enlist.com",
                                    "insync-palm.com",
                                    "iqmailer.net",
                                    "kanadmz.iwov.com",
                                    "kc-mx.avantgo.com",
                                    "lanebryantmail.com",
                                    "link2buy.com",
                                    "list.streamingmedia.com",
                                    "list3.internet.com",
                                    "list5.internet.com",
                                    "listbot.com",
                                    "lists.plesser.com",
                                    "lists.zoanmail.com",
                                    "listserv.redherring.com",
                                    "madbrandz.com",
                                    "mail212.c0olmail.com",
                                    "mailb.travelocity.com",
                                    "mailsubs.com",
                                    "maui.dlbnetwork.net",
                                    "messagereach.com",
                                    "mm.petsmart.com",
                                    "monterey.liz5000.net",
                                    "ms83.com",
                                    "msnnewsletters.customer-email.com",
                                    "mta01.optamail.com",
                                    "mta12.optamail.com",
                                    "multexinvestornetwork.com",
                                    "mx.lodo.exactis.com",
                                    "my.cdnow.com",
                                    "mycreativeoffers.com",
                                    "nec.omessage.com",
                                    "news.clickrewards.com",
                                    "news.forbesdigital.com",
                                    "newsletter.online.com",
                                    "newsletters.microsoft.com",
                                    "nws.currentmail.com",
                                    "offer.nsi-direct.com",
                                    "officemax.p0.com",
                                    "onyx.acc0.com",
                                    "palmplatform.p0.com",
                                    "ppi.currentmail.com",
                                    "reply.dwdata.com",
                                    "reply.ebay.com",
                                    "reply.interwoven.com",
                                    "reply.wow-com.com",
                                    "reply3.ebay.com",
                                    "response.musicmatch.com",
                                    "summertimedeals.com",
                                    "survey.agora.com",
                                    "svrn.com",
                                    "thecreek.coldwatercreek.com",
                                    "thesuperspecialsales.com",
                                    "thriftytales.com",
                                    "tonga.ivaluenetwork.com",
                                    "top-special-offers.com",
                                    "traffic.kpix.com",
                                    "tremendousbuys.com",
                                    "xmr3.com",
                                    "yourwebspecials.com"]
        return false
end
splits = split(address, "@")
if length(strip(address)) == 0;                                      return false; end
if length(splits) == 2 && splits[1] == "hot_deals";                  return false; end
if address == "bugzilla-daemon";                                     return false; end
if splits[1] == "mpmail" && findfirst("mypoints.com", address) != 0:-1; return false; end
if starts_with_key(address, "investorinsights");                     return false; end
if starts_with_key(address, "mailer-daemon");                        return false; end
if starts_with_key(address, "optitarget-");                          return false; end
if findfirst("n0o1.com", address) != 0:-1;                           return false; end
return true
end

function process_graph(rank::Int64)
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

    senders, receivers, timestamps = Int64[], Int64[], Int64[]
    dir = "data/custodians/"

    open("email-Avocado-$rank-nverts.txt", "w") do h
        open("email-Avocado-$rank-simplices.txt", "w") do g
            for file in readdir(dir)  # loop over all files
                currently_building_email_item = false
                email_xml = String[]
                println("$dir/$file")
                open("$dir/$file") do f
                    for line in eachline(f)
                        stripped = strip(line)

                        # Check for start of email
                        #<item id="097-000001-EM" type="email" attachments="0" pst-folder-id="3014">
                        if starts_with_key(stripped, item_id_key) &&
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
                                if s == nothing || rs == nothing; continue; end
                                if !keep_address(s); continue; end
                                rs = unique(rs)
                                rs = [r for r in rs if keep_address(r)]
                                if length(rs) == 0; continue; end
                                s_mid = get_mapped_id(s)
                                rs_mids = unique([get_mapped_id(r) for r in rs])
                                if length(rs_mids)!==rank-1; continue; end
                                isincorelist=Bool[]
                                push!(isincorelist, haskey(cmap,s_mid))
                                for r in rs_mids; push!(isincorelist, haskey(cmap,r)); end
                                if length(findall(isincorelist.==true))>0
                                    hyperlength=length(rs_mids)+1
                                    write(h,"$hyperlength")
                                    write(h,"test$file")
                                    write(g,"$s_mid\n")
                                    write(h,"test$file")
                                    for receiver in rs_mids
                                        r = mapped_id(receiver);
                                        write(g,"$r\n")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    core_ids = sort(unique([v for (k, v) in cmap]))
    open("core-email-Avocado.txt", "w") do f
        for c in core_ids
            write(f, "$(c)\n")
        end
    end

    open("email-Avocado.txt", "w") do f
        for (s, r, t) in unique([(x, y, tm) for (x, y, tm) in zip(senders, receivers, timestamps)])
            write(f, "$(s) $(r) $(t)\n")
        end
    end

    open("addresses-email-Avocado.txt", "w") do f
        for (id, addr) in sort([(v, k) for (k, v) in all_map])
            write(f, "$(id) $(addr)\n")
        end
    end
end
