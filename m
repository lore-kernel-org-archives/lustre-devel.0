From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 08:31:21 +1000
Subject: [lustre-devel] [PATCH 08/31] lustre: llite: don't zero
 timestamps internally
In-Reply-To: <1533003983-29311-9-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-9-git-send-email-jsimmons@infradead.org>
Message-ID: <87d0v3rq9y.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 30 2018, James Simmons wrote:
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -138,6 +138,11 @@ struct ll_inode_info {
>  	s64				lli_ctime;
>  	spinlock_t			lli_agl_lock;
>  
> +	/* update atime from MDS no matter if it's older than
> +	 * local inode atime.
> +	 */
> +	unsigned int			lli_update_atime:1;
> +

Why not make this another flag bit in lli_flags ??

I might add a patch to do that.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/6c1efa30/attachment.sig>
