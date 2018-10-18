From: NeilBrown <neilb@suse.com>
Date: Thu, 18 Oct 2018 13:00:50 +1100
Subject: [lustre-devel] [PATCH 16/28] lustre: statahead: missing barrier
 before wake_up
In-Reply-To: <1539543498-29105-17-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-17-git-send-email-jsimmons@infradead.org>
Message-ID: <87d0s8c8tp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> From: Lai Siyao <lai.siyao@whamcloud.com>
>
> A barrier is missing before wake_up() in ll_statahead_interpret(),
> which may cause 'ls' hang. Under the right conditions a basic 'ls'
> can fail. The debug logs show:
>
> statahead.c:683:ll_statahead_interpret()) sa_entry software rc -13
> statahead.c:1666:ll_statahead()) revalidate statahead software: -11.
>
> Obviously statahead failure didn't notify 'ls' process in time.
> The mi_cbdata can be stale so add a barrier before calling
> wake_up().
>
> Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
> Signed-off-by: Bob Glossman <bob.glossman@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9210
> Reviewed-on: https://review.whamcloud.com/27330
> Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/statahead.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index 1ad308c..0174a4c 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -680,8 +680,14 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
>  
>  	spin_lock(&lli->lli_sa_lock);
>  	if (rc) {
> -		if (__sa_make_ready(sai, entry, rc))
> +		if (__sa_make_ready(sai, entry, rc)) {
> +			/* LU-9210 : Under the right conditions even 'ls'
> +			 * can cause the statahead to fail. Using a memory
> +			 * barrier resolves this issue.
> +			 */
> +			smp_mb();
>  			wake_up(&sai->sai_waitq);
> +		}
>  	} else {
>  		int first = 0;
>  		entry->se_minfo = minfo;
> -- 
> 1.8.3.1

Again, this is a fairly lame comment to justify the smp_mb().
It appears to me that the issue is most likely the value of
entry->se_state.
__sa_make_ready() sets this and revalidate_statahead_dentry tests it
after waiting on sai_waitq.
So I think it would be best if we changed __sa_make_ready() to

	smp_store_release(&entry->se_state, ret < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC)

and in ll_statahead_interpret() have

	if (smp_load_acquire(&entry->se_state) == SA_ENTRY_SUCC &&
            entry->se_inode) {

This would make it obvious which variable was important, and would show
the paired synchronization points.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181018/21b73558/attachment-0001.sig>
