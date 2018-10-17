From: NeilBrown <neilb@suse.com>
Date: Thu, 18 Oct 2018 09:43:01 +1100
Subject: [lustre-devel] [PATCH 03/28] lustre: ptlrpc: missing barrier
 before wake_up
In-Reply-To: <1539543498-29105-4-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-4-git-send-email-jsimmons@infradead.org>
Message-ID: <87y3awchze.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> From: Lai Siyao <lai.siyao@whamcloud.com>
>
> ptlrpc_client_wake_req() misses a memory barrier, which may cause
> strange errors.
>
> Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8935
> Reviewed-on: https://review.whamcloud.com/26583
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Wang Shilong <wshilong@ddn.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/lustre_net.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index ce7e98c..468a03e 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -2211,6 +2211,8 @@ static inline int ptlrpc_status_ntoh(int n)
>  static inline void
>  ptlrpc_client_wake_req(struct ptlrpc_request *req)
>  {
> +	/* ensure ptlrpc_register_bulk see rq_resend as set. */
> +	smp_mb();
>  	if (!req->rq_set)
>  		wake_up(&req->rq_reply_waitq);
>  	else

It is good that this memory barrier has a comment, but the comment isn't
very helpful.
There is no matching memory barrier in ptlrpc_register_bulk(), so it
isn't clear what sequencing is important.

And ptl_send_rpc() tests ->rq_resend *before* ptlrpc_register_bulk() is
called (which also tests it).  Presumably these should see that same
value?  So why does the comment refer to ptlrpc_register_bulk() instead
of ptl_send_rpc() ??

It all seems rather confusing, so it is very hard to be sure that the
code is now correct.
Is someone able to explain?

Thanks,
NeilBrown



> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181018/6b7a3e91/attachment.sig>
