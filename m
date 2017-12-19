From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 19 Dec 2017 23:38:08 +0000
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: use strim instead
 of cfs_trimwhite.
In-Reply-To: <151363810769.11899.15503930546886979038.stgit@noble>
References: <151363798156.11899.768707943431676479.stgit@noble>
 <151363810769.11899.15503930546886979038.stgit@noble>
Message-ID: <17ADFDA6-8E70-4019-B749-B095F56F3DC0@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Dec 18, 2017, at 16:01, NeilBrown <neilb@suse.com> wrote:
> 
> Linux lib provides identical functionality to cfs_trimwhite,
> so discard that code and use the standard.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> .../lustre/include/linux/libcfs/libcfs_string.h    |    1 -
> drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   20 --------------------
> .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |    8 ++++----
> drivers/staging/lustre/lnet/lnet/config.c          |   10 +++++-----
> drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
> 5 files changed, 10 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
> index c1375733ff31..66463477074a 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
> @@ -73,7 +73,6 @@ struct cfs_expr_list {
> 	struct list_head	el_exprs;
> };
> 
> -char *cfs_trimwhite(char *str);
> int cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res);
> int cfs_str2num_check(char *str, int nob, unsigned int *num,
> 		      unsigned int min, unsigned int max);
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> index b1d8faa3f7aa..442889a3d729 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> @@ -137,26 +137,6 @@ char *cfs_firststr(char *str, size_t size)
> }
> EXPORT_SYMBOL(cfs_firststr);
> 
> -char *
> -cfs_trimwhite(char *str)
> -{
> -	char *end;
> -
> -	while (isspace(*str))
> -		str++;
> -
> -	end = str + strlen(str);
> -	while (end > str) {
> -		if (!isspace(end[-1]))
> -			break;
> -		end--;
> -	}
> -
> -	*end = 0;
> -	return str;
> -}
> -EXPORT_SYMBOL(cfs_trimwhite);
> -
> /**
>  * Extracts tokens from strings.
>  *
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> index e9156bf05ed4..d30650f8dcb4 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> @@ -818,7 +818,7 @@ cfs_cpt_table_create_pattern(char *pattern)
> 	int c;
> 	int i;
> 
> -	str = cfs_trimwhite(pattern);
> +	str = strim(pattern);
> 	if (*str == 'n' || *str == 'N') {
> 		pattern = str + 1;
> 		if (*pattern != '\0') {
> @@ -870,7 +870,7 @@ cfs_cpt_table_create_pattern(char *pattern)
> 
> 	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
> 
> -	for (str = cfs_trimwhite(pattern), c = 0;; c++) {
> +	for (str = strim(pattern), c = 0;; c++) {
> 		struct cfs_range_expr *range;
> 		struct cfs_expr_list *el;
> 		char *bracket = strchr(str, '[');
> @@ -905,7 +905,7 @@ cfs_cpt_table_create_pattern(char *pattern)
> 			goto failed;
> 		}
> 
> -		str = cfs_trimwhite(str + n);
> +		str = strim(str + n);
> 		if (str != bracket) {
> 			CERROR("Invalid pattern %s\n", str);
> 			goto failed;
> @@ -945,7 +945,7 @@ cfs_cpt_table_create_pattern(char *pattern)
> 			goto failed;
> 		}
> 
> -		str = cfs_trimwhite(bracket + 1);
> +		str = strim(bracket + 1);
> 	}
> 
> 	return cptab;
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index fd53c74766a7..44eeca63f458 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -269,7 +269,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
> 
> 			if (comma)
> 				*comma++ = 0;
> -			net = libcfs_str2net(cfs_trimwhite(str));
> +			net = libcfs_str2net(strim(str));
> 
> 			if (net == LNET_NIDNET(LNET_NID_ANY)) {
> 				LCONSOLE_ERROR_MSG(0x113,
> @@ -292,7 +292,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
> 		}
> 
> 		*bracket = 0;
> -		net = libcfs_str2net(cfs_trimwhite(str));
> +		net = libcfs_str2net(strim(str));
> 		if (net == LNET_NIDNET(LNET_NID_ANY)) {
> 			tmp = str;
> 			goto failed_syntax;
> @@ -322,7 +322,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
> 			if (comma)
> 				*comma++ = 0;
> 
> -			iface = cfs_trimwhite(iface);
> +			iface = strim(iface);
> 			if (!*iface) {
> 				tmp = iface;
> 				goto failed_syntax;
> @@ -356,7 +356,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
> 		comma = strchr(bracket + 1, ',');
> 		if (comma) {
> 			*comma = 0;
> -			str = cfs_trimwhite(str);
> +			str = strim(str);
> 			if (*str) {
> 				tmp = str;
> 				goto failed_syntax;
> @@ -365,7 +365,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
> 			continue;
> 		}
> 
> -		str = cfs_trimwhite(str);
> +		str = strim(str);
> 		if (*str) {
> 			tmp = str;
> 			goto failed_syntax;
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 8d6d6b4d6619..1a71ffebc889 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -829,7 +829,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
> 	if (rc < 0)
> 		goto out;
> 
> -	tmp = cfs_trimwhite(buf);
> +	tmp = strim(buf);
> 
> 	rc = -EINVAL;
> 	lnet_res_lock(0);
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
