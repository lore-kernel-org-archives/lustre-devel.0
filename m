From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jun 2018 07:27:16 +1000
Subject: [lustre-devel] [PATCH v3 04/13] lustre: libcfs: fix
 cfs_print_to_console()
In-Reply-To: <1530128322-32535-5-git-send-email-jsimmons@infradead.org>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
 <1530128322-32535-5-git-send-email-jsimmons@infradead.org>
Message-ID: <8760237wej.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 27 2018, James Simmons wrote:

> The original code for cfs_print_to_console() used printk() and
> used tricks to select which printk level to use. Later a cleanup
> patch landed the just converted printk directly to pr_info which
> is not exactly correct. Instead of converting back to printk lets
> move everything to pr_* type functions which simplify the code.
> This allows us to fold both dbghdr_to_err_string() and the
> function dbghdr_to_info_string() into cfs_print_to_console().
>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

Thanks!
This code is much nicer now, and the whole series is much easier to
review now that you've broken it up.

It'll all appear in my lustre-testing shortly.

Thanks,
NeilBrown


> ---
>  .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 55 ++++++----------------
>  1 file changed, 14 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> index 3af7722..c1747c4 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> @@ -140,54 +140,27 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
>  	header->ph_extern_pid = 0;
>  }
>  
> -static char *
> -dbghdr_to_err_string(struct ptldebug_header *hdr)
> -{
> -	switch (hdr->ph_subsys) {
> -	case S_LND:
> -	case S_LNET:
> -		return "LNetError";
> -	default:
> -		return "LustreError";
> -	}
> -}
> -
> -static char *
> -dbghdr_to_info_string(struct ptldebug_header *hdr)
> -{
> -	switch (hdr->ph_subsys) {
> -	case S_LND:
> -	case S_LNET:
> -		return "LNet";
> -	default:
> -		return "Lustre";
> -	}
> -}
> -
>  void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
>  			  const char *buf, int len, const char *file,
>  			  const char *fn)
>  {
> -	char *prefix = "Lustre", *ptype = NULL;
> +	char *prefix = "Lustre";
> +
> +	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
> +		prefix = "LNet";
>  
> -	if (mask & D_EMERG) {
> -		prefix = dbghdr_to_err_string(hdr);
> -		ptype = KERN_EMERG;
> +	if (mask & (D_CONSOLE | libcfs_printk)) {
> +		pr_info("%s: %.*s", prefix, len, buf);
> +	} else if (mask & D_EMERG) {
> +		pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
> +			 hdr->ph_pid, hdr->ph_extern_pid, file,
> +			 hdr->ph_line_num, fn, len, buf);
>  	} else if (mask & D_ERROR) {
> -		prefix = dbghdr_to_err_string(hdr);
> -		ptype = KERN_ERR;
> +		pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
> +		       hdr->ph_pid, hdr->ph_extern_pid, file,
> +		       hdr->ph_line_num, fn, len, buf);
>  	} else if (mask & D_WARNING) {
> -		prefix = dbghdr_to_info_string(hdr);
> -		ptype = KERN_WARNING;
> -	} else if (mask & (D_CONSOLE | libcfs_printk)) {
> -		prefix = dbghdr_to_info_string(hdr);
> -		ptype = KERN_INFO;
> -	}
> -
> -	if (mask & D_CONSOLE) {
> -		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
> -	} else {
> -		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
> +		pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
>  			hdr->ph_pid, hdr->ph_extern_pid, file,
>  			hdr->ph_line_num, fn, len, buf);
>  	}
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/510b8380/attachment.sig>
