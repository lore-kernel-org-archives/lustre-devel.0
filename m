From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:40 -0400
Subject: [lustre-devel] [PATCH 1/7] lustre: quota: cleanup codes of quota
 for new type
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

This patch cleanups codes of quota to prepare for
new type other than USRQUOTA/GRPQUOTA.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Oleg Drokin <green@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4017
Reviewed-on: https://review.whamcloud.com/18894
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  2 ++
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 13 ++++++-
 drivers/staging/lustre/lustre/llite/dir.c          | 21 ++++++++---
 drivers/staging/lustre/lustre/osc/osc_quota.c      | 42 ++++++++++++++--------
 drivers/staging/lustre/lustre/osc/osc_request.c    |  2 +-
 5 files changed, 59 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 66b15c7..9430f11 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1131,6 +1131,8 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
 
+#define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | OBD_MD_FLGRPQUOTA)
+
 #define OBD_MD_FLGETATTR (OBD_MD_FLID    | OBD_MD_FLATIME | OBD_MD_FLMTIME | \
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
 			  OBD_MD_FLMODE  | OBD_MD_FLTYPE  | OBD_MD_FLUID   | \
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 715f1c5..b1961df 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -567,7 +567,18 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define LUSTRE_Q_INVALIDATE  0x80000b	/* deprecated as of 2.4 */
 #define LUSTRE_Q_FINVALIDATE 0x80000c	/* deprecated as of 2.4 */
 
-#define UGQUOTA 2       /* set both USRQUOTA and GRPQUOTA */
+#define ALLQUOTA 255	/* set all quota */
+
+static inline char *qtype_name(int qtype)
+{
+	switch (qtype) {
+	case USRQUOTA:
+		return "usr";
+	case GRPQUOTA:
+		return "grp";
+	}
+	return "unknown";
+}
 
 #define IDENTITY_DOWNCALL_MAGIC 0x6d6dd629
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 36cea8d..7047938 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -902,6 +902,21 @@ static int copy_and_ioctl(int cmd, struct obd_export *exp,
 	return rc;
 }
 
+static inline int check_owner(int type, int id)
+{
+	switch (type) {
+	case USRQUOTA:
+		if (!uid_eq(current_euid(), make_kuid(&init_user_ns, id)))
+			return -EPERM;
+		break;
+	case GRPQUOTA:
+		if (!in_egroup_p(make_kgid(&init_user_ns, id)))
+			return -EPERM;
+		break;
+	}
+	return 0;
+}
+
 static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 {
 	int cmd = qctl->qc_cmd;
@@ -917,11 +932,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 			return -EPERM;
 		break;
 	case Q_GETQUOTA:
-		if (((type == USRQUOTA &&
-		      !uid_eq(current_euid(), make_kuid(&init_user_ns, id))) ||
-		     (type == GRPQUOTA &&
-		      !in_egroup_p(make_kgid(&init_user_ns, id)))) &&
-		      !capable(CAP_SYS_ADMIN))
+		if (check_owner(type, id) && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETINFO:
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 25d06de..13ef482 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -63,7 +63,7 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 			 * quota space on this OST
 			 */
 			CDEBUG(D_QUOTA, "chkdq found noquota for %s %d\n",
-			       type == USRQUOTA ? "user" : "grout", qid[type]);
+			       qtype_name(type), qid[type]);
 			return -EDQUOT;
 		}
 	}
@@ -78,11 +78,29 @@ static void osc_quota_free(struct rcu_head *head)
 	kmem_cache_free(osc_quota_kmem, oqi);
 }
 
+static inline u32 md_quota_flag(int qtype)
+{
+	switch (qtype) {
+	case USRQUOTA:
+		return OBD_MD_FLUSRQUOTA;
+	case GRPQUOTA:
+		return OBD_MD_FLGRPQUOTA;
+	default:
+		return 0;
+	}
+}
 
-#define MD_QUOTA_FLAG(type) ((type == USRQUOTA) ? OBD_MD_FLUSRQUOTA \
-						: OBD_MD_FLGRPQUOTA)
-#define FL_QUOTA_FLAG(type) ((type == USRQUOTA) ? OBD_FL_NO_USRQUOTA \
-						: OBD_FL_NO_GRPQUOTA)
+static inline u32 fl_quota_flag(int qtype)
+{
+	switch (qtype) {
+	case USRQUOTA:
+		return OBD_FL_NO_USRQUOTA;
+	case GRPQUOTA:
+		return OBD_FL_NO_GRPQUOTA;
+	default:
+		return 0;
+	}
+}
 
 int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 		    u32 valid, u32 flags)
@@ -90,20 +108,20 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 	int type;
 	int rc = 0;
 
-	if ((valid & (OBD_MD_FLUSRQUOTA | OBD_MD_FLGRPQUOTA)) == 0)
+	if ((valid & (OBD_MD_FLALLQUOTA)) == 0)
 		return 0;
 
 	for (type = 0; type < MAXQUOTAS; type++) {
 		struct osc_quota_info *oqi;
 
-		if ((valid & MD_QUOTA_FLAG(type)) == 0)
+		if ((valid & md_quota_flag(type)) == 0)
 			continue;
 
 		/* lookup the ID in the per-type hash table */
 		rcu_read_lock();
 		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type], &qid[type],
 					     quota_hash_params);
-		if ((flags & FL_QUOTA_FLAG(type)) != 0) {
+		if ((flags & fl_quota_flag(type)) != 0) {
 			/* This ID is getting close to its quota limit, let's
 			 * switch to sync I/O
 			 */
@@ -130,9 +148,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			}
 
 			CDEBUG(D_QUOTA, "%s: setdq to insert for %s %d (%d)\n",
-			       cli_name(cli),
-			       type == USRQUOTA ? "user" : "group",
-			       qid[type], rc);
+			       cli_name(cli), qtype_name(type), qid[type], rc);
 		} else {
 			/* This ID is now off the hook, let's remove it from
 			 * the hash table
@@ -146,9 +162,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 				call_rcu(&oqi->rcu, osc_quota_free);
 			rcu_read_unlock();
 			CDEBUG(D_QUOTA, "%s: setdq to remove for %s %d (%p)\n",
-			       cli_name(cli),
-			       type == USRQUOTA ? "user" : "group",
-			       qid[type], oqi);
+			       cli_name(cli), qtype_name(type), qid[type], oqi);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 5bab8a3..1d21159 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1476,7 +1476,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	/* set/clear over quota flag for a uid/gid */
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE &&
-	    body->oa.o_valid & (OBD_MD_FLUSRQUOTA | OBD_MD_FLGRPQUOTA)) {
+	    body->oa.o_valid & OBD_MD_FLALLQUOTA) {
 		unsigned int qid[MAXQUOTAS] = { body->oa.o_uid, body->oa.o_gid };
 
 		CDEBUG(D_QUOTA, "setdq for [%u %u] with valid %#llx, flags %x\n",
-- 
1.8.3.1
