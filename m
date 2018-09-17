From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:25 -0400
Subject: [lustre-devel] [PATCH 15/30] lustre: ptlrpc: drain
 "ptlrpc_request_buffer_desc" objects
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Prior to this patch, new "ptlrpc_request_buffer_desc"
could be additionally allocated upon need by
ptlrpc_check_rqbd_pool(), but will never be freed
until OST umount/stop by ptlrpc_service_purge_all().
Now try to release some of them when possible.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9372
Reviewed-on: https://review.whamcloud.com/26752
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 79baadc..6a5a9c5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -802,11 +802,21 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			spin_lock(&svcpt->scp_lock);
 			/*
 			 * now all reqs including the embedded req has been
-			 * disposed, schedule request buffer for re-use.
+			 * disposed, schedule request buffer for re-use
+			 * or free it to drain some in excess.
 			 */
 			LASSERT(atomic_read(&rqbd->rqbd_req.rq_refcount) ==
 				0);
-			list_add_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
+			if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group &&
+			    !test_req_buffer_pressure) {
+				/* like in ptlrpc_free_rqbd() */
+				svcpt->scp_nrqbds_total--;
+				kvfree(rqbd->rqbd_buffer);
+				kfree(rqbd);
+			} else {
+				list_add_tail(&rqbd->rqbd_list,
+					      &svcpt->scp_rqbd_idle);
+			}
 		}
 
 		spin_unlock(&svcpt->scp_lock);
-- 
1.8.3.1
