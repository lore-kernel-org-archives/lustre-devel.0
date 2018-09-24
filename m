From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 14:09:01 +1000
Subject: [lustre-devel] [PATCH 17/30] lustre: llite: protect
 ll_dentry_data modification
In-Reply-To: <1537205440-6656-18-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-18-git-send-email-jsimmons@infradead.org>
Message-ID: <87zhw74jvm.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> From: Andriy Skulysh <c17819@cray.com>
>
> The ll_dentry_data bitfields modification should be protected by
> a spinlock.
>
> Signed-off-by: Andriy Skulysh <c17819@cray.com>
> Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9241
> Seagate-bug-id: MRP-4257
> Reviewed-on: https://review.whamcloud.com/26109
> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/llite_nfs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
> index c66072a..5e91e83 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
> @@ -171,8 +171,9 @@ struct lustre_nfs_fid {
>  	 * we came from NFS and so opencache needs to be
>  	 * enabled for this one
>  	 */
> +	spin_lock(&result->d_lock);
>  	ll_d2d(result)->lld_nfs_dentry = 1;
> -
> +	spin_unlock(&result->d_lock);
>  	return result;
>  }

This is a bit weird....
I agree that having a spinlock is needed as the compiler does an R/M/W
to update the bitfield, and that could race with updats to lld_invalid
(and I think that is a good arguement to avoid bitfields in shared structures).

However lld_nfs_dentry is never used.  The only use was removed by

Commit: c1b66fccf986 ("staging: lustre: fid: do open-by-fid by default")

The corresponding commit upstream is

Commit: cb85c0364fd8 ("LU-3544 fid: do open-by-fid by default")

and that commit doesn't remove the use of lld_nfs_dentry.  Maybe because
lld_nfs_dentry didn't exist then - it wasn't added until later
by 65d0add6057b138.

So do we need to bring lld_nfs_dentry back?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/9c40f448/attachment-0001.sig>
