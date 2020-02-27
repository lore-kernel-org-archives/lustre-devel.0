From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:14 -0500
Subject: [lustre-devel] [PATCH 266/622] lustre: quota: make overquota flag
 for old req
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-267-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

For the old request with over quota flag, the over quota flag
should still be marked at OSC, because the old request could be
processed afther the new request at OST, then it won't break the
quota enforement at OST.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11678
Lustre-commit: c59cf862c3c0 ("LU-11678 quota: make overquota flag for old req")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34645
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shilong Wang <wshilong@ddn.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_quota.c              | 11 +++++++++--
 include/uapi/linux/lustre/lustre_idl.h |  3 +++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 316e087..8ff803c 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -119,10 +119,17 @@ int osc_quota_setdq(struct client_obd *cli, u64 xid, const unsigned int qid[],
 		return 0;
 
 	mutex_lock(&cli->cl_quota_mutex);
-	if (cli->cl_quota_last_xid > xid)
+	/* still mark the quots is running out for the old request, because it
+	 * could be processed after the new request at OST, the side effect is
+	 * the following request will be processed synchronously, but it will
+	 * not break the quota enforcement.
+	 */
+	if (cli->cl_quota_last_xid > xid && !(flags & OBD_FL_NO_QUOTA_ALL))
 		goto out_unlock;
 
-	cli->cl_quota_last_xid = xid;
+	if (cli->cl_quota_last_xid < xid)
+		cli->cl_quota_last_xid = xid;
+
 	for (type = 0; type < MAXQUOTAS; type++) {
 		struct osc_quota_info *oqi;
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 1b4b018..3a2a093 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -998,6 +998,9 @@ enum obdo_flags {
 				   OBD_FL_CKSUM_T10IP4K |
 				   OBD_FL_CKSUM_T10CRC512 |
 				   OBD_FL_CKSUM_T10CRC4K),
+
+	OBD_FL_NO_QUOTA_ALL = OBD_FL_NO_USRQUOTA | OBD_FL_NO_GRPQUOTA |
+			      OBD_FL_NO_PRJQUOTA,
 };
 
 /*
-- 
1.8.3.1
