From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:26 -0400
Subject: [lustre-devel] [PATCH 73/80] staging: lustre: lmv: build error with
	gcc 4.7.0 20110509
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-74-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Fixed comparison between signed and unsigned indexes.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3775
Reviewed-on: http://review.whamcloud.com/7382
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   34 ++++++++++++++------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b8275e1..3e41f49 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -130,12 +130,12 @@ static void lmv_activate_target(struct lmv_obd *lmv,
  *  -ENOTCONN: The UUID is found, but the target connection is bad (!)
  *  -EBADF   : The UUID is found, but the OBD of the wrong type (!)
  */
-static int lmv_set_mdc_active(struct lmv_obd *lmv, struct obd_uuid *uuid,
+static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 			      int activate)
 {
 	struct lmv_tgt_desc    *uninitialized_var(tgt);
 	struct obd_device      *obd;
-	int		     i;
+	u32		     i;
 	int		     rc = 0;
 
 	CDEBUG(D_INFO, "Searching in lmv %p for uuid %s (activate=%d)\n",
@@ -307,7 +307,7 @@ static int lmv_connect(const struct lu_env *env,
 static void lmv_set_timeouts(struct obd_device *obd)
 {
 	struct lmv_obd	*lmv;
-	int		    i;
+	u32 i;
 
 	lmv = &obd->u.lmv;
 	if (lmv->server_timeout == 0)
@@ -333,7 +333,7 @@ static int lmv_init_ea_size(struct obd_export *exp, int easize,
 {
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
-	int		  i;
+	u32 i;
 	int		  rc = 0;
 	int		  change = 0;
 
@@ -578,7 +578,7 @@ int lmv_check_connect(struct obd_device *obd)
 {
 	struct lmv_obd       *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc  *tgt;
-	int		   i;
+	u32 i;
 	int		   rc;
 	int		   easize;
 
@@ -693,7 +693,7 @@ static int lmv_disconnect(struct obd_export *exp)
 	struct obd_device     *obd = class_exp2obd(exp);
 	struct lmv_obd	*lmv = &obd->u.lmv;
 	int		    rc;
-	int		    i;
+	u32 i;
 
 	if (!lmv->tgts)
 		goto out_local;
@@ -822,7 +822,7 @@ static int lmv_hsm_req_count(struct lmv_obd *lmv,
 			     const struct hsm_user_request *hur,
 			     const struct lmv_tgt_desc *tgt_mds)
 {
-	int			i, nr = 0;
+	u32 i, nr = 0;
 	struct lmv_tgt_desc    *curr_tgt;
 
 	/* count how many requests must be sent to the given target */
@@ -963,10 +963,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	struct obd_device    *obddev = class_exp2obd(exp);
 	struct lmv_obd       *lmv = &obddev->u.lmv;
 	struct lmv_tgt_desc *tgt = NULL;
-	int		   i = 0;
+	u32 i = 0;
 	int		   rc = 0;
 	int		   set = 0;
-	int		   count = lmv->desc.ld_tgt_count;
+	u32 count = lmv->desc.ld_tgt_count;
 
 	if (count == 0)
 		return -ENOTTY;
@@ -1444,7 +1444,7 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct lmv_obd	*lmv = &obd->u.lmv;
 	struct obd_statfs     *temp;
 	int		    rc = 0;
-	int		    i;
+	u32 i;
 
 	rc = lmv_check_connect(obd);
 	if (rc)
@@ -1586,7 +1586,7 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 {
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
-	int		  i;
+	u32 i;
 	int		  rc;
 
 	rc = lmv_check_connect(obd);
@@ -1615,7 +1615,7 @@ static int lmv_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	int tgt;
-	int		  i;
+	u32 i;
 	int		  rc;
 
 	rc = lmv_check_connect(obd);
@@ -2923,7 +2923,7 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	int		      rc = 0;
 	int		      err;
-	int		      i;
+	u32 i;
 
 	LASSERT(fid);
 
@@ -2966,7 +2966,7 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	enum ldlm_mode	      rc;
 	int tgt;
-	int		      i;
+	u32 i;
 
 	CDEBUG(D_INODE, "Lock match for "DFID"\n", PFID(fid));
 
@@ -3125,8 +3125,9 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	struct obd_device   *obd = class_exp2obd(exp);
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
-	int		  rc = 0, i;
+	int rc = 0;
 	__u64 curspace = 0, curinodes = 0;
+	u32 i;
 
 	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active ||
 	    !lmv->desc.ld_tgt_count) {
@@ -3169,7 +3170,8 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	struct obd_device   *obd = class_exp2obd(exp);
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
-	int		  i, rc = 0;
+	int rc = 0;
+	u32 i;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		int err;
-- 
1.7.1
