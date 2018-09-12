From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:54:18 +0000
Subject: [lustre-devel] [PATCH 33/34] Completely re-write
 lnet_parse_networks().
In-Reply-To: <153628137255.8267.7924367116215461900.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137255.8267.7924367116215461900.stgit@noble>
Message-ID: <260B47CF-351E-43CD-964D-E1A4D383082E@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    From: Amir Shehata <amir.shehata@intel.com>
    
    Was:
    
    LU-7734 lnet: Multi-Rail local NI split
    
    This patch allows the configuration of multiple NIs under one Net.
    It is now possible to have multiple NIDs on the same network:
       Ex: <ip1>@tcp, <ip2>@tcp.
    This can be configured using the following syntax:
       Ex: tcp(eth0, eth1)
    
    The data structures for the example above can be visualized
    as follows
    
                   NET(tcp)
                    |
            -----------------
            |               |
          NI(eth0)        NI(eth1)
    
    For more details refer to the Mult-Rail Requirements and HLD
    documents
    
    Signed-off-by: Amir Shehata <amir.shehata@intel.com>
    Change-Id: Id7c73b9b811a3082b61e53b9e9f95743188cbd51
    Reviewed-on: http://review.whamcloud.com/18274
    Tested-by: Jenkins
    Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
    Tested-by: Maloo <hpdd-maloo@intel.com>
    Reviewed-by: Olaf Weber <olaf@sgi.com>
    ---
     drivers/staging/lustre/lnet/lnet/config.c |  341 ++++++++++++++++++-----------
     1 file changed, 217 insertions(+), 124 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
    index 11d6dbc80507..0571fa6a7249 100644
    --- a/drivers/staging/lustre/lnet/lnet/config.c
    +++ b/drivers/staging/lustre/lnet/lnet/config.c
    @@ -48,8 +48,11 @@ static int lnet_tbnob;			/* track text buf allocation */
     #define LNET_MAX_TEXTBUF_NOB     (64 << 10)	/* bound allocation */
     #define LNET_SINGLE_TEXTBUF_NOB  (4 << 10)
     
    +#define SPACESTR " \t\v\r\n"
    +#define DELIMITERS ":()[]"
    +
     static void
    -lnet_syntax(char *name, char *str, int offset, int width)
    +lnet_syntax(const char *name, const char *str, int offset, int width)
     {
     	static char dots[LNET_SINGLE_TEXTBUF_NOB];
     	static char dashes[LNET_SINGLE_TEXTBUF_NOB];
    @@ -363,6 +366,42 @@ lnet_net_alloc(__u32 net_id, struct list_head *net_list)
     	return net;
     }
     
    +static int
    +lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
    +{
    +	int niface = 0;
    +
    +	if (ni == NULL)
    +		return -ENOMEM;
    +
    +	/* Allocate a separate piece of memory and copy
    +	 * into it the string, so we don't have
    +	 * a depencency on the tokens string.  This way we
    +	 * can free the tokens@the end of the function.
    +	 * The newly allocated ni_interfaces[] can be
    +	 * freed when freeing the NI */
    +	while (niface < LNET_MAX_INTERFACES &&
    +	       ni->ni_interfaces[niface] != NULL)
    +		niface++;
    +
    +	if (niface >= LNET_MAX_INTERFACES) {
    +		LCONSOLE_ERROR_MSG(0x115, "Too many interfaces "
    +				   "for net %s\n",
    +				   libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
    +		return -EINVAL;
    +	}
    +
    +	ni->ni_interfaces[niface] = kstrdup(iface, GFP_KERNEL);
    +
    +	if (ni->ni_interfaces[niface] == NULL) {
    +		CERROR("Can't allocate net interface name\n");
    +		return -ENOMEM;
    +	}
    +
    +	return 0;
    +}
    +
    +/* allocate and add to the provided network */
     struct lnet_ni *
     lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
     {
    @@ -439,24 +478,33 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
     		goto failed;
     	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
     
    +	/* if an interface name is provided then make sure to add in that
    +	 * interface name in NI */
    +	if (iface != NULL)
    +		if (lnet_ni_add_interface(ni, iface) != 0)
    +			goto failed;
    +
     	return ni;
     failed:
     	lnet_ni_free(ni);
     	return NULL;
     }
     
    +/*
    + * Parse the networks string and create the matching set of NIs on the
    + * nilist.
    + */
     int
     lnet_parse_networks(struct list_head *netlist, char *networks)
     {
    -	struct cfs_expr_list *el = NULL;
    +	struct cfs_expr_list *net_el = NULL;
    +	struct cfs_expr_list *ni_el = NULL;
     	char *tokens;
     	char *str;
    -	char *tmp;
     	struct lnet_net *net;
     	struct lnet_ni *ni = NULL;
     	__u32 net_id;
     	int nnets = 0;
    -	struct list_head *temp_node;
     
     	if (!networks) {
     		CERROR("networks string is undefined\n");
    @@ -476,84 +524,108 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     		return -ENOMEM;
     	}
     
    -	tmp = tokens;
     	str = tokens;
     
    -	while (str && *str) {
    -		char *comma = strchr(str, ',');
    -		char *bracket = strchr(str, '(');
    -		char *square = strchr(str, '[');
    -		char *iface;
    -		int niface;
    +	/*
    +	 * Main parser loop.
    +	 *
    +	 * NB we don't check interface conflicts here; it's the LNDs
    +	 * responsibility (if it cares at all)
    +	 */
    +	do {
    +		char *nistr;
    +		char *elstr;
    +		char *name;
     		int rc;
     
     		/*
    -		 * NB we don't check interface conflicts here; it's the LNDs
    -		 * responsibility (if it cares at all)
    +		 * Parse a network string into its components.
    +		 *
    +		 * <name>{"("...")"}{"["<el>"]"}
     		 */
    -		if (square && (!comma || square < comma)) {
    -			/*
    -			 * i.e: o2ib0(ib0)[1,2], number between square
    -			 * brackets are CPTs this NI needs to be bond
    -			 */
    -			if (bracket && bracket > square) {
    -				tmp = square;
    +
    +		/* Network name (mandatory)
    +		 */
    +		while (isspace(*str))
    +			*str++ = '\0';
    +		if (!*str)
    +			break;
    +		name = str;
    +		str += strcspn(str, SPACESTR ":()[],");
    +		while (isspace(*str))
    +			*str++ = '\0';
    +
    +		/* Interface list (optional) */
    +		if (*str == '(') {
    +			*str++ = '\0';
    +			nistr = str;
    +			str += strcspn(str, ")");
    +			if (*str != ')') {
    +				str = nistr;
     				goto failed_syntax;
     			}
    +			do {
    +				*str++ = '\0';
    +			} while (isspace(*str));
    +		} else {
    +			nistr = NULL;
    +		}
     
    -			tmp = strchr(square, ']');
    -			if (!tmp) {
    -				tmp = square;
    +		/* CPT expression (optional) */
    +		if (*str == '[') {
    +			elstr = str;
    +			str += strcspn(str, "]");
    +			if (*str != ']') {
    +				str = elstr;
     				goto failed_syntax;
     			}
    -
    -			rc = cfs_expr_list_parse(square, tmp - square + 1,
    -						 0, LNET_CPT_NUMBER - 1, &el);
    +			rc = cfs_expr_list_parse(elstr, str - elstr + 1,
    +						0, LNET_CPT_NUMBER - 1,
    +						&net_el);
     			if (rc) {
    -				tmp = square;
    +				str = elstr;
     				goto failed_syntax;
     			}
    -
    -			while (square <= tmp)
    -				*square++ = ' ';
    +			*elstr = '\0';
    +			do {
    +				*str++ = '\0';
    +			} while (isspace(*str));
     		}
     
    -		if (!bracket || (comma && comma < bracket)) {
    -			/* no interface list specified */
    +		/* Bad delimiters */
    +		if (*str && (strchr(DELIMITERS, *str) != NULL))
    +			goto failed_syntax;
     
    -			if (comma)
    -				*comma++ = 0;
    -			net_id = libcfs_str2net(strim(str));
    +		/* go to the next net if it exits */
    +		str += strcspn(str, ",");
    +		if (*str == ',')
    +			*str++ = '\0';
     
    -			if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
    -				LCONSOLE_ERROR_MSG(0x113,
    -						   "Unrecognised network type\n");
    -				tmp = str;
    -				goto failed_syntax;
    -			}
    -
    -			if (LNET_NETTYP(net_id) != LOLND) { /* LO is implicit */
    -				net = lnet_net_alloc(net_id, netlist);
    -				if (!net ||
    -				    !lnet_ni_alloc(net, el, NULL))
    -					goto failed;
    -			}
    +		/*
    +		 * At this point the name is properly terminated.
    +		 */
    +		net_id = libcfs_str2net(name);
    +		if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
    +			LCONSOLE_ERROR_MSG(0x113,
    +					"Unrecognised network type\n");
    +			str = name;
    +			goto failed_syntax;
    +		}
     
    -			if (el) {
    -				cfs_expr_list_free(el);
    -				el = NULL;
    +		if (LNET_NETTYP(net_id) == LOLND) {
    +			/* Loopback is implicit, and there can be only one. */
    +			if (net_el) {
    +				cfs_expr_list_free(net_el);
    +				net_el = NULL;
     			}
    -
    -			str = comma;
    +			/* Should we error out instead? */
     			continue;
     		}
     
    -		*bracket = 0;
    -		net_id = libcfs_str2net(strim(str));
    -		if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
    -			tmp = str;
    -			goto failed_syntax;
    -		}
    +		/*
    +		 * All network paramaters are now known.
    +		 */
    +		nnets++;
     
     		/* always allocate a net, since we will eventually add an
     		 * interface to it, or we will fail, in which case we'll
    @@ -562,88 +634,107 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     		if (IS_ERR_OR_NULL(net))
     			goto failed;
     
    -		ni = lnet_ni_alloc(net, el, NULL);
    -		if (IS_ERR_OR_NULL(ni))
    -			goto failed;
    -
    -		if (el) {
    -			cfs_expr_list_free(el);
    -			el = NULL;
    -		}
    -
    -		niface = 0;
    -		iface = bracket + 1;
    +		if (!nistr) {
    +			/*
    +			 * No interface list was specified, allocate a
    +			 * ni using the defaults.
    +			 */
    +			ni = lnet_ni_alloc(net, net_el, NULL);
    +			if (IS_ERR_OR_NULL(ni))
    +				goto failed;
     
    -		bracket = strchr(iface, ')');
    -		if (!bracket) {
    -			tmp = iface;
    -			goto failed_syntax;
    +			if (net_el) {
    +				cfs_expr_list_free(net_el);
    +				net_el = NULL;
    +			}
    +			continue;
     		}
     
    -		*bracket = 0;
     		do {
    -			comma = strchr(iface, ',');
    -			if (comma)
    -				*comma++ = 0;
    -
    -			iface = strim(iface);
    -			if (!*iface) {
    -				tmp = iface;
    -				goto failed_syntax;
    +			elstr = NULL;
    +
    +			/* Interface name (mandatory) */
    +			while (isspace(*nistr))
    +				*nistr++ = '\0';
    +			name = nistr;
    +			nistr += strcspn(nistr, SPACESTR "[],");
    +			while (isspace(*nistr))
    +				*nistr++ = '\0';
    +
    +			/* CPT expression (optional) */
    +			if (*nistr == '[') {
    +				elstr = nistr;
    +				nistr += strcspn(nistr, "]");
    +				if (*nistr != ']') {
    +					str = elstr;
    +					goto failed_syntax;
    +				}
    +				rc = cfs_expr_list_parse(elstr,
    +							nistr - elstr + 1,
    +							0, LNET_CPT_NUMBER - 1,
    +							&ni_el);
    +				if (rc != 0) {
    +					str = elstr;
    +					goto failed_syntax;
    +				}
    +				*elstr = '\0';
    +				do {
    +					*nistr++ = '\0';
    +				} while (isspace(*nistr));
    +			} else {
    +				ni_el = net_el;
     			}
     
    -			if (niface == LNET_MAX_INTERFACES) {
    -				LCONSOLE_ERROR_MSG(0x115,
    -						   "Too many interfaces for net %s\n",
    -						   libcfs_net2str(net_id));
    -				goto failed;
    +			/*
    +			 * End of single interface specificaton,
    +			 * advance to the start of the next one, if
    +			 * any.
    +			 */
    +			if (*nistr == ',') {
    +				do {
    +					*nistr++ = '\0';
    +				} while (isspace(*nistr));
    +				if (!*nistr) {
    +					str = nistr;
    +					goto failed_syntax;
    +				}
    +			} else if (*nistr) {
    +				str = nistr;
    +				goto failed_syntax;
     			}
     
     			/*
    -			 * Allocate a separate piece of memory and copy
    -			 * into it the string, so we don't have
    -			 * a depencency on the tokens string.  This way we
    -			 * can free the tokens@the end of the function.
    -			 * The newly allocated ni_interfaces[] can be
    -			 * freed when freeing the NI
    +			 * At this point the name
    +			 is properly terminated.
     			 */
    -			ni->ni_interfaces[niface] = kstrdup(iface, GFP_KERNEL);
    -			if (!ni->ni_interfaces[niface]) {
    -				CERROR("Can't allocate net interface name\n");
    -				goto failed;
    -			}
    -			niface++;
    -			iface = comma;
    -		} while (iface);
    -
    -		str = bracket + 1;
    -		comma = strchr(bracket + 1, ',');
    -		if (comma) {
    -			*comma = 0;
    -			str = strim(str);
    -			if (*str) {
    -				tmp = str;
    +			if (!*name) {
    +				str = name;
     				goto failed_syntax;
     			}
    -			str = comma + 1;
    -			continue;
    -		}
     
    -		str = strim(str);
    -		if (*str) {
    -			tmp = str;
    -			goto failed_syntax;
    -		}
    -	}
    +			ni = lnet_ni_alloc(net, ni_el, name);
    +			if (IS_ERR_OR_NULL(ni))
    +				goto failed;
     
    -	list_for_each(temp_node, netlist)
    -		nnets++;
    +			if (ni_el) {
    +				if (ni_el != net_el) {
    +					cfs_expr_list_free(ni_el);
    +					ni_el = NULL;
    +				}
    +			}
    +		} while (*nistr);
    +
    +		if (net_el) {
    +			cfs_expr_list_free(net_el);
    +			net_el = NULL;
    +		}
    +	} while (*str);
     
     	kfree(tokens);
     	return nnets;
     
      failed_syntax:
    -	lnet_syntax("networks", networks, (int)(tmp - tokens), strlen(tmp));
    +	lnet_syntax("networks", networks, (int)(str - tokens), strlen(str));
      failed:
     	/* free the net list and all the nis on each net */
     	while (!list_empty(netlist)) {
    @@ -653,8 +744,10 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     		lnet_net_free(net);
     	}
     
    -	if (el)
    -		cfs_expr_list_free(el);
    +	if (ni_el && ni_el != net_el)
    +		cfs_expr_list_free(ni_el);
    +	if (net_el)
    +		cfs_expr_list_free(net_el);
     
     	kfree(tokens);
     
    
    
    
