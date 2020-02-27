From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:43 -0500
Subject: [lustre-devel] [PATCH 235/622] lustre: quota: protect quota flags
 at OSC
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-236-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

There is no protection in OSC quota hash tracking the quota flags of
different qid, which could cause the previous request to modify the
quota flags which was set by the current request because the replies
could be out of order.

This patch also adds a lock to protect the operations on the quota
hash from different requests.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11678
Lustre-commit: 77d9f4e05a5c ("LU-11678 quota: protect quota flags at OSC")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33747
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h      |  3 +++
 fs/lustre/osc/osc_internal.h |  2 +-
 fs/lustre/osc/osc_quota.c    | 11 ++++++++++-
 fs/lustre/osc/osc_request.c  |  3 ++-
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index bf0bf97..ff94092 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -344,8 +344,11 @@ struct client_obd {
 	/* ptlrpc work for writeback in ptlrpcd context */
 	void			*cl_writeback_work;
 	void			*cl_lru_work;
+	struct mutex		cl_quota_mutex;
 	/* hash tables for osc_quota_info */
 	struct rhashtable	cl_quota_hash[MAXQUOTAS];
+	/* the xid of the request updating the hash tables */
+	u64			cl_quota_last_xid;
 	/* Links to the global list of registered changelog devices */
 	struct list_head	cl_chg_dev_linkage;
 };
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 0f0f4d4..6f71d8d 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -136,7 +136,7 @@ static inline char *cli_name(struct client_obd *cli)
 
 int osc_quota_setup(struct obd_device *obd);
 int osc_quota_cleanup(struct obd_device *obd);
-int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
+int osc_quota_setdq(struct client_obd *cli, u64 xid, const unsigned int qid[],
 		    u32 valid, u32 flags);
 int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[]);
 int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index cb5ddef..316e087 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -109,7 +109,7 @@ static inline u32 fl_quota_flag(int qtype)
 	}
 }
 
-int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
+int osc_quota_setdq(struct client_obd *cli, u64 xid, const unsigned int qid[],
 		    u32 valid, u32 flags)
 {
 	int type;
@@ -118,6 +118,11 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 	if ((valid & (OBD_MD_FLALLQUOTA)) == 0)
 		return 0;
 
+	mutex_lock(&cli->cl_quota_mutex);
+	if (cli->cl_quota_last_xid > xid)
+		goto out_unlock;
+
+	cli->cl_quota_last_xid = xid;
 	for (type = 0; type < MAXQUOTAS; type++) {
 		struct osc_quota_info *oqi;
 
@@ -175,6 +180,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 		}
 	}
 
+out_unlock:
+	mutex_unlock(&cli->cl_quota_mutex);
 	return rc;
 }
 
@@ -191,6 +198,8 @@ int osc_quota_setup(struct obd_device *obd)
 	struct client_obd *cli = &obd->u.cli;
 	int i, type;
 
+	mutex_init(&cli->cl_quota_mutex);
+
 	for (type = 0; type < MAXQUOTAS; type++) {
 		if (rhashtable_init(&cli->cl_quota_hash[type],
 				    &quota_hash_params) != 0)
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 14180a4..dca141f 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1753,7 +1753,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		       "setdq for [%u %u %u] with valid %#llx, flags %x\n",
 		       body->oa.o_uid, body->oa.o_gid, body->oa.o_projid,
 		       body->oa.o_valid, body->oa.o_flags);
-		osc_quota_setdq(cli, qid, body->oa.o_valid, body->oa.o_flags);
+		osc_quota_setdq(cli, req->rq_xid, qid, body->oa.o_valid,
+				body->oa.o_flags);
 	}
 
 	osc_update_grant(cli, body);
-- 
1.8.3.1
