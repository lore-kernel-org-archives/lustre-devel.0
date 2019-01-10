From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:19:47 +0000
Subject: [lustre-devel] [PATCH 28/29] lustre: osc_request: assorted
 white-space and check-patch fixes.
In-Reply-To: <154701504282.26726.12048576544354457365.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504282.26726.12048576544354457365.stgit@noble>
Message-ID: <C6E49B56-15FA-4660-AB79-F68E03E1531B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> Just misc formatting fixes.  Some minot code change

(typo) "minor"

> where an 'else' after 'return' was discarded.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/osc/osc_request.c |  163 +++++++++++++----------
> 1 file changed, 89 insertions(+), 74 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index ccc491efa982..c2239c99a7b2 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> 
> @@ -652,8 +651,8 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
> 		 * Wait until the number of on-going destroy RPCs drops
> 		 * under max_rpc_in_flight
> 		 */
> -		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
> -						      osc_can_send_destroy(cli));
> +		rc = l_wait_event_abortable_exclusive(
> +			cli->cl_destroy_waitq, osc_can_send_destroy(cli));
> 		if (rc) {
> 			ptlrpc_req_finished(req);
> 			return rc;

I don't really see this change as an improvement?  I'd instead just de-indent
the osc_can_send_destroy() by a space or two so it fits within 80 colunmns.
That is IMHO closer to the normal coding style.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
