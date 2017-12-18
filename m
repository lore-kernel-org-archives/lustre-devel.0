From: Patrick Farrell <paf@cray.com>
Date: Mon, 18 Dec 2017 21:09:18 +0000
Subject: [lustre-devel] [PATCH 15/16] staging: lustre: use explicit poll
 loop in ptlrpc_unregister_reply
In-Reply-To: <151358148034.5099.17386685003288433122.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
 <151358148034.5099.17386685003288433122.stgit@noble>
Message-ID: <D65D8A40.C5E44%paf@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This should not contribute to load, since it?s called out of the ptlrpcd
daemons.

On 12/18/17, 1:18 AM, "lustre-devel on behalf of NeilBrown"
<lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

>replace l_wait_event() with wait_event_timeout() and explicit
>loop.  This approach is easier to understand.
>
>Signed-off-by: NeilBrown <neilb@suse.com>
>---
> drivers/staging/lustre/lustre/ptlrpc/client.c |   14 +++++++-------
> 1 file changed, 7 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c
>b/drivers/staging/lustre/lustre/ptlrpc/client.c
>index 3e6d22beb9f5..bb8c9ab68f5f 100644
>--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
>+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
>@@ -2500,7 +2500,6 @@ static int ptlrpc_unregister_reply(struct
>ptlrpc_request *request, int async)
> {
> 	int rc;
> 	wait_queue_head_t *wq;
>-	struct l_wait_info lwi;
> 
> 	/* Might sleep. */
> 	LASSERT(!in_interrupt());
>@@ -2543,16 +2542,17 @@ static int ptlrpc_unregister_reply(struct
>ptlrpc_request *request, int async)
> 		 * Network access will complete in finite time but the HUGE
> 		 * timeout lets us CWARN for visibility of sluggish NALs
> 		 */
>-		lwi = LWI_TIMEOUT_INTERVAL(LONG_UNLINK * HZ,
>-					   HZ, NULL, NULL);
>-		rc = l_wait_event(*wq, !ptlrpc_client_recv_or_unlink(request),
>-				  &lwi);
>-		if (rc == 0) {
>+		int cnt = 0;
>+		while (cnt < LONG_UNLINK &&
>+		       (rc = wait_event_timeout(*wq,
>+						!ptlrpc_client_recv_or_unlink(request),
>+						HZ)) == 0)
>+			cnt += 1;
>+		if (rc > 0) {
> 			ptlrpc_rqphase_move(request, request->rq_next_phase);
> 			return 1;
> 		}
> 
>-		LASSERT(rc == -ETIMEDOUT);
> 		DEBUG_REQ(D_WARNING, request,
> 			  "Unexpectedly long timeout receiving_reply=%d req_ulinked=%d
>reply_unlinked=%d",
> 			  request->rq_receiving_reply,
>
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
