From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:58 -0400
Subject: [lustre-devel] [PATCH 059/124] staging: lustre: at: net AT after
	connect
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-60-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander_boyko@xyratex.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander_boyko@xyratex.com>

Once connected, the previously gathered AT statistics is not valid
anymore because may reflect other routing, etc. The connect by itself
could take a long time due to different reasons (e.g. server was not
ready) and net latency got very high (see import_select_connection())
what does not reflect the current situation.

Take into account only the current (re-)CONNECT rpc latency.

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Signed-off-by: Alexander Boyko <alexander_boyko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5380
Xyratex-bug-id: MRP-1285
Reviewed-on: http://review.whamcloud.com/11155
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 ++--
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    8 ++++++++
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 ++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index bea1c16..27fe00d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -283,8 +283,8 @@ int ptlrpc_at_get_net_latency(struct ptlrpc_request *req)
 }
 
 /* Adjust expected network latency */
-static void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
-				      unsigned int service_time)
+void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
+			       unsigned int service_time)
 {
 	unsigned int nl, oldnl;
 	struct imp_at *at;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 013a957..17f3fec 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -846,6 +846,14 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	imp->imp_obd->obd_self_export->exp_connect_data = *ocd;
 	class_export_put(exp);
 
+	/*
+	 * The net statistics after (re-)connect is not valid anymore,
+	 * because may reflect other routing, etc.
+	 */
+	at_init(&imp->imp_at.iat_net_latency, 0, 0);
+	ptlrpc_at_adj_net_latency(request,
+				  lustre_msg_get_service_time(request->rq_repmsg));
+
 	obd_import_event(imp->imp_obd, imp, IMP_EVENT_OCD);
 
 	if (aa->pcaa_initial_connect) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index a9831fa..29cfac2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -53,6 +53,8 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait);
 int ptlrpcd_start(struct ptlrpcd_ctl *pc);
 
 /* client.c */
+void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
+			       unsigned int service_time);
 struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned npages, unsigned max_brw,
 					 unsigned type, unsigned portal);
 int ptlrpc_request_cache_init(void);
-- 
1.7.1
