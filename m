From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 16:21:53 +1000
Subject: [lustre-devel] [PATCH 07/38] lustre: llite: register mountpoint
 before process llog
In-Reply-To: <1534475441-15543-8-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-8-git-send-email-jsimmons@infradead.org>
Message-ID: <871saxsebi.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> From: Emoly Liu <emoly@whamcloud.com>
>
> In ll_fill_super(), ll_debugfs_register_super() should be
> called before lustre_process_log(), otherwise the directory
> /sys/fs/lustre/llite/* can't be created in time and the params
> "llite.*.*" won't be set correctly.
>
> Also, this patch adds sbi->ll_xattr_cache_set to mark the flag
> LL_SBI_XATTR_CACHE already set during lustre_process_log(),
> in case that it will be overwritten in client_common_fill_super().
>
> Signed-off-by: Emoly Liu <emoly@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9399
> Reviewed-on: https://review.whamcloud.com/27241
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
> Reviewed-on: https://review.whamcloud.com/#/c/32516
> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/lustre/llite/llite_internal.h   |  5 +-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    | 75 ++++++++++++++++------
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  | 30 +++------
>  3 files changed, 68 insertions(+), 42 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 5577407..9e60c5e 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -461,12 +461,15 @@ struct ll_sb_info {
>  	struct obd_uuid	   ll_sb_uuid;
>  	struct obd_export	*ll_md_exp;
>  	struct obd_export	*ll_dt_exp;
> +	struct obd_device	*ll_md_obd;
> +	struct obd_device	*ll_dt_obd;
>  	struct dentry		*ll_debugfs_entry;
>  	struct lu_fid	     ll_root_fid; /* root object fid */
>  
>  	int		       ll_flags;
>  	unsigned int		  ll_umounting:1,
>  				  ll_xattr_cache_enabled:1,
> +				ll_xattr_cache_set:1, /* already set to 0/1 */
>  				  ll_client_common_fill_super_succeeded:1;

Bit fields are dangerous in a shared data structures.
You need locking for updates as the compiler produces a
read-modify-write on the whole 32bit word.
I note that no locking is used...  I don't think there is a real
risk of anything going wrong, but it is poor practice.

I also note ll_umounting is never tested - should be removed.

There is room for improvement here.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/49838d23/attachment.sig>
