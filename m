From: Patrick Farrell <paf@cray.com>
Date: Mon, 18 Dec 2017 21:03:54 +0000
Subject: [lustre-devel] [PATCH 11/16] staging: lustre: make polling loop
 in ptlrpc_unregister_bulk more obvious
In-Reply-To: <151358148020.5099.4047116902359752959.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
 <151358148020.5099.4047116902359752959.stgit@noble>
Message-ID: <D65D88CA.C5E2F%paf@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This probably shouldn?t contribute to load, it?s often (mostly?) run out
of the ptlrpcd daemons.

- Patrick

On 12/18/17, 1:18 AM, "lustre-devel on behalf of NeilBrown"
<lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

>This use of l_wait_event() is a polling loop that re-checks
>every second.  Make this more obvious with a while loop
>and wait_event_timeout().
>
>Signed-off-by: NeilBrown <neilb@suse.com>
>---
> drivers/staging/lustre/lustre/ptlrpc/niobuf.c |   14 +++++++-------
> 1 file changed, 7 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
>b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
>index 0c2ded721c49..5606c8f01b5b 100644
>--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
>+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
>@@ -229,7 +229,6 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request
>*req, int async)
> {
> 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
> 	wait_queue_head_t *wq;
>-	struct l_wait_info lwi;
> 	int rc;
> 
> 	LASSERT(!in_interrupt());     /* might sleep */
>@@ -246,7 +245,7 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request
>*req, int async)
> 
> 	/* the unlink ensures the callback happens ASAP and is the last
> 	 * one.  If it fails, it must be because completion just happened,
>-	 * but we must still l_wait_event() in this case to give liblustre
>+	 * but we must still wait_event() in this case to give liblustre
> 	 * a chance to run client_bulk_callback()
> 	 */
> 	mdunlink_iterate_helper(desc->bd_mds, desc->bd_md_max_brw);
>@@ -270,15 +269,16 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request
>*req, int async)
> 		/* Network access will complete in finite time but the HUGE
> 		 * timeout lets us CWARN for visibility of sluggish LNDs
> 		 */
>-		lwi = LWI_TIMEOUT_INTERVAL(LONG_UNLINK * HZ,
>-					   HZ, NULL, NULL);
>-		rc = l_wait_event(*wq, !ptlrpc_client_bulk_active(req), &lwi);
>-		if (rc == 0) {
>+		int cnt = 0;
>+		while (cnt < LONG_UNLINK &&
>+		       (rc = wait_event_timeout(*wq, !ptlrpc_client_bulk_active(req),
>+						HZ)) == 0)
>+			cnt += 1;
>+		if (rc > 0) {
> 			ptlrpc_rqphase_move(req, req->rq_next_phase);
> 			return 1;
> 		}
> 
>-		LASSERT(rc == -ETIMEDOUT);
> 		DEBUG_REQ(D_WARNING, req, "Unexpectedly long timeout: desc %p",
> 			  desc);
> 	}
>
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
