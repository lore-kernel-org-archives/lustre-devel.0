From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 10:35:24 +1000
Subject: [lustre-devel] [PATCH v3 05/26] staging: lustre: libcfs: remove
 excess space
In-Reply-To: <1529875250-11531-6-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-6-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7rjaek3.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> From: Amir Shehata <amir.shehata@intel.com>
>
> The function cfs_cpt_table_print() was adding two spaces
> to the string buffer. Just add it once.

No it doesn't.  Maybe it did in the out-of-tree code, but the linux code
is different.

The extra space is

                       rc = snprintf(tmp, len, " %d", j);

But in Linux that is

			rc = snprintf(tmp, len, "%d ", j);

Both are wrong, but for different reasons.
I've change this patch to be:

			rc = snprintf(tmp, len, "%d\t:", i);
and
			rc = snprintf(tmp, len, " %d", j);
and changed the comment to say that we don't need a stray space at the
end of the line.

NeilBrown



>
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
> Reviewed-on: http://review.whamcloud.com/18916
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index ea8d55c..680a2b1 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -177,7 +177,7 @@ struct cfs_cpt_table *
>  
>  	for (i = 0; i < cptab->ctb_nparts; i++) {
>  		if (len > 0) {
> -			rc = snprintf(tmp, len, "%d\t: ", i);
> +			rc = snprintf(tmp, len, "%d\t:", i);
>  			len -= rc;
>  		}
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/a16a4b8f/attachment.sig>
