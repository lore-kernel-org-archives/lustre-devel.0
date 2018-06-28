From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 28 Jun 2018 22:39:00 +0000
Subject: [lustre-devel] [PATCH v3 02/13] lustre: libcfs: open code
 cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
In-Reply-To: <1530128322-32535-3-git-send-email-jsimmons@infradead.org>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
 <1530128322-32535-3-git-send-email-jsimmons@infradead.org>
Message-ID: <D3940542-5913-4E4D-8FEB-E3B27CB7AD04@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 27, 2018, at 13:38, James Simmons <jsimmons@infradead.org> wrote:
> 
> From: NeilBrown <neilb@suse.com>
> 
> This function in used twice.
> In libcfs_debug_init() the usage is pointless as
> the only place that set libcfs_debug_mb ensures
> that it does not exceed the maximum.  So checking
> again can never help.
> 
> So open-code the small function into the only
> other place that it is used - in cfs_trace_set_debug_mb(),
> which is used to set libcfs_debug_mb.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lnet/libcfs/debug.c           | 6 +++---
> drivers/staging/lustre/lnet/libcfs/linux-tracefile.c | 7 -------
> drivers/staging/lustre/lnet/libcfs/tracefile.c       | 3 ++-
> drivers/staging/lustre/lnet/libcfs/tracefile.h       | 1 -
> 4 files changed, 5 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
> index 06f694f..71effcf 100644
> --- a/drivers/staging/lustre/lnet/libcfs/debug.c
> +++ b/drivers/staging/lustre/lnet/libcfs/debug.c
> @@ -411,10 +411,10 @@ int libcfs_debug_init(unsigned long bufsize)
> 			sizeof(libcfs_debug_file_path_arr));
> 	}
> 
> -	/* If libcfs_debug_mb is set to an invalid value or uninitialized
> -	 * then just make the total buffers smp_num_cpus * TCD_MAX_PAGES
> +	/* If libcfs_debug_mb is uninitialized then just make the
> +	 * total buffers smp_num_cpus * TCD_MAX_PAGES
> 	 */
> -	if (max > cfs_trace_max_debug_mb() || max < num_possible_cpus()) {
> +	if (max < num_possible_cpus()) {

The libcfs_debug_mb value may be set as a module option, so that the debug
buffer can be sized before any debugging messages are logged (in case of
problems early on in module loading and such).  This code validates that
the value set via module parameter is sane.

It may be that there is a mechanism to limit the value set by module option
in newer kernels, but that wasn't the case in the past.

Cheers, Andreas

> 		max = TCD_MAX_PAGES;
> 	} else {
> 		max = max / num_possible_cpus();
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> index 9e72220..64a5bc1 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> @@ -227,10 +227,3 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
> 			hdr->ph_line_num, fn, len, buf);
> 	}
> }
> -
> -int cfs_trace_max_debug_mb(void)
> -{
> -	int  total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
> -
> -	return max(512, (total_mb * 80) / 100);
> -}
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index 5f31933..72321ce 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -933,7 +933,8 @@ int cfs_trace_set_debug_mb(int mb)
> 	int i;
> 	int j;
> 	int pages;
> -	int limit = cfs_trace_max_debug_mb();
> +	int total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
> +	int limit = max(512, (total_mb * 80) / 100);
> 	struct cfs_trace_cpu_data *tcd;
> 
> 	if (mb < num_possible_cpus()) {
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> index 9f6b73d..bd1a1ef 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> @@ -88,7 +88,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
> void libcfs_register_panic_notifier(void);
> void libcfs_unregister_panic_notifier(void);
> extern int libcfs_panic_in_progress;
> -int cfs_trace_max_debug_mb(void);
> 
> #define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
> #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
> --
> 1.8.3.1
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/70844d26/attachment.sig>
