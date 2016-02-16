From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:38 -0500
Subject: [lustre-devel] [PATCH 06/45] staging/lustre: Remove unused function
	oti_init
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All the users seems to have disappeared.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h | 28 ----------------------------
 1 file changed, 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 514e12b..991d2c6 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -595,34 +595,6 @@ struct obd_trans_info {
 	struct obd_uuid	 *oti_ost_uuid;
 };
 
-static inline void oti_init(struct obd_trans_info *oti,
-			    struct ptlrpc_request *req)
-{
-	if (oti == NULL)
-		return;
-	memset(oti, 0, sizeof(*oti));
-
-	if (req == NULL)
-		return;
-
-	oti->oti_xid = req->rq_xid;
-	/** VBR: take versions from request */
-	if (req->rq_reqmsg != NULL &&
-	    lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY) {
-		__u64 *pre_version = lustre_msg_get_versions(req->rq_reqmsg);
-
-		oti->oti_pre_version = pre_version ? pre_version[0] : 0;
-		oti->oti_transno = lustre_msg_get_transno(req->rq_reqmsg);
-	}
-
-	/** called from mds_create_objects */
-	if (req->rq_repmsg != NULL)
-		oti->oti_transno = lustre_msg_get_transno(req->rq_repmsg);
-	oti->oti_thread = req->rq_svc_thread;
-	if (req->rq_reqmsg != NULL)
-		oti->oti_conn_cnt = lustre_msg_get_conn_cnt(req->rq_reqmsg);
-}
-
 static inline void oti_alloc_cookies(struct obd_trans_info *oti,
 				     int num_cookies)
 {
-- 
2.1.0
