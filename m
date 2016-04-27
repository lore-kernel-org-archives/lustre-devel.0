From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:55 -0400
Subject: [lustre-devel] [PATCH 03/15] staging: lustre: obdclass: add
	LCT_SERVER_SESSION for server session
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Wang Di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Wang Di <di.wang@intel.com>

Add LCT_SERVER_SESSION for server session, and separate the
server session flag from LCT_SESSION, so to avoid allocating
session info for client stack for each server request, if
client and server are on the same node.

Signed-off-by: Wang Di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3806
Reviewed-on: http://review.whamcloud.com/7412
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h |    4 ++++
 drivers/staging/lustre/lustre/include/obd_class.h |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c    |    3 ++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index b5b0c81..a27e76f 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1006,6 +1006,10 @@ enum lu_context_tag {
 	 */
 	LCT_LOCAL = 1 << 7,
 	/**
+	 * session for server thread
+	 **/
+	LCT_SERVER_SESSION = BIT(8),
+	/**
 	 * Set when@least one of keys, having values in this context has
 	 * non-NULL lu_context_key::lct_exit() method. This is used to
 	 * optimize lu_context_exit() call.
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 40f7a23..32863bc 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -477,7 +477,7 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 		struct lu_context  session_ctx;
 		struct lu_env env;
 
-		lu_context_init(&session_ctx, LCT_SESSION);
+		lu_context_init(&session_ctx, LCT_SESSION | LCT_SERVER_SESSION);
 		session_ctx.lc_thread = NULL;
 		lu_context_enter(&session_ctx);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 1bbd1d3..fc2632f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1649,7 +1649,8 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 				    at_get(&svcpt->scp_at_estimate));
 	}
 
-	rc = lu_context_init(&request->rq_session, LCT_SESSION | LCT_NOREF);
+	rc = lu_context_init(&request->rq_session, LCT_SERVER_SESSION |
+						   LCT_NOREF);
 	if (rc) {
 		CERROR("Failure to initialize session: %d\n", rc);
 		goto out_req;
-- 
1.7.1
