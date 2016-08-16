From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:02 -0400
Subject: [lustre-devel] [PATCH 49/80] staging: lustre: lmv: validate lock
	with correct stripe FID
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

In ll_lookup_it_finish, we need use the real parent(stripe)
FID to validate the parent UPDATE lock.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4925
Reviewed-on: http://review.whamcloud.com/10026
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |    5 +++++
 drivers/staging/lustre/lustre/include/obd_class.h |   13 +++++++++++++
 drivers/staging/lustre/lustre/llite/namei.c       |   15 +++++++++++++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       |   19 ++++++++++++++++++-
 4 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 52020a9..b7bdd07 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1103,6 +1103,11 @@ struct md_ops {
 			     ldlm_policy_data_t *, enum ldlm_mode,
 			     enum ldlm_cancel_flags flags, void *opaque);
 
+	int (*get_fid_from_lsm)(struct obd_export *,
+				const struct lmv_stripe_md *,
+				const char *name, int namelen,
+				struct lu_fid *fid);
+
 	int (*intent_getattr_async)(struct obd_export *,
 				    struct md_enqueue_info *,
 				    struct ldlm_enqueue_info *);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index e86961c..69b628b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1699,6 +1699,19 @@ static inline int md_revalidate_lock(struct obd_export *exp,
 	return rc;
 }
 
+static inline int md_get_fid_from_lsm(struct obd_export *exp,
+				      const struct lmv_stripe_md *lsm,
+				      const char *name, int namelen,
+				      struct lu_fid *fid)
+{
+	int rc;
+
+	EXP_CHECK_MD_OP(exp, get_fid_from_lsm);
+	EXP_MD_COUNTER_INCREMENT(exp, get_fid_from_lsm);
+	rc = MDP(exp->exp_obd, get_fid_from_lsm)(exp, lsm, name, namelen, fid);
+	return rc;
+}
+
 /* OBD Metadata Support */
 
 int obd_init_caches(void);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 6e11b99..581b083 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -487,9 +487,20 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		struct lookup_intent parent_it = {
 					.it_op = IT_GETATTR,
 					.it_lock_handle = 0 };
+		struct lu_fid fid = ll_i2info(parent)->lli_fid;
+
+		/* If it is striped directory, get the real stripe parent */
+		if (unlikely(ll_i2info(parent)->lli_lsm_md)) {
+			rc = md_get_fid_from_lsm(ll_i2mdexp(parent),
+						 ll_i2info(parent)->lli_lsm_md,
+						 (*de)->d_name.name,
+						 (*de)->d_name.len, &fid);
+			if (rc)
+				return rc;
+		}
 
-		if (md_revalidate_lock(ll_i2mdexp(parent), &parent_it,
-				       &ll_i2info(parent)->lli_fid, NULL)) {
+		if (md_revalidate_lock(ll_i2mdexp(parent), &parent_it, &fid,
+				       NULL)) {
 			d_lustre_revalidate(*de);
 			ll_intent_release(&parent_it);
 		}
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 03594f0..9821f69 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2991,6 +2991,22 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	return rc;
 }
 
+int lmv_get_fid_from_lsm(struct obd_export *exp,
+			 const struct lmv_stripe_md *lsm,
+			 const char *name, int namelen, struct lu_fid *fid)
+{
+	const struct lmv_oinfo *oinfo;
+
+	LASSERT(lsm);
+	oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+	if (IS_ERR(oinfo))
+		return PTR_ERR(oinfo);
+
+	*fid = oinfo->lmo_fid;
+
+	return 0;
+}
+
 /**
  * For lmv, only need to send request to master MDT, and the master MDT will
  * process with other slave MDTs. The only exception is Q_GETOQUOTA for which
@@ -3155,7 +3171,8 @@ static struct md_ops lmv_md_ops = {
 	.set_open_replay_data	= lmv_set_open_replay_data,
 	.clear_open_replay_data	= lmv_clear_open_replay_data,
 	.intent_getattr_async	= lmv_intent_getattr_async,
-	.revalidate_lock	= lmv_revalidate_lock
+	.revalidate_lock	= lmv_revalidate_lock,
+	.get_fid_from_lsm	= lmv_get_fid_from_lsm,
 };
 
 static int __init lmv_init(void)
-- 
1.7.1
