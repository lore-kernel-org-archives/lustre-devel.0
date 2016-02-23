From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:26 -0500
Subject: [lustre-devel] [PATCH 48/56] staging/lustre/lmv: Adjust comments to
	better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-49-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lmv/lmv_fld.c    |  3 ++-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |  9 ++++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c    | 37 +++++++++++++++++---------
 3 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index ee23592..378691b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -58,7 +58,8 @@ int lmv_fld_lookup(struct lmv_obd *lmv,
 	int rc;
 
 	/* FIXME: Currently ZFS still use local seq for ROOT unfortunately, and
-	 * this fid_is_local check should be removed once LU-2240 is fixed */
+	 * this fid_is_local check should be removed once LU-2240 is fixed
+	 */
 	LASSERTF((fid_seq_in_fldb(fid_seq(fid)) ||
 		  fid_seq_is_local_file(fid_seq(fid))) &&
 		 fid_is_sane(fid), DFID" is insane!\n", PFID(fid));
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index cb1ed42..259b211 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -110,11 +110,13 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	if (parent_fid) {
 		/* The parent fid is only for remote open to
 		 * check whether the open is from OBF,
-		 * see mdt_cross_open */
+		 * see mdt_cross_open
+		 */
 		LASSERT(it->it_op & IT_OPEN);
 		op_data->op_fid2 = *parent_fid;
 		/* Add object FID to op_fid3, in case it needs to check stale
-		 * (M_CHECK_STALE), see mdc_finish_intent_lock */
+		 * (M_CHECK_STALE), see mdc_finish_intent_lock
+		 */
 		op_data->op_fid3 = body->fid1;
 	}
 
@@ -173,7 +175,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(tgt);
 
 	/* If it is ready to open the file by FID, do not need
-	 * allocate FID at all, otherwise it will confuse MDT */
+	 * allocate FID at all, otherwise it will confuse MDT
+	 */
 	if ((it->it_op & IT_CREAT) &&
 	    !(it->it_flags & MDS_OPEN_BY_FID)) {
 		/*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index eb1c85f..67746c9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -679,7 +679,8 @@ repeat_fid2path:
 		goto out_fid2path;
 
 	/* If remote_gf != NULL, it means just building the
-	 * path on the remote MDT, copy this path segment to gf */
+	 * path on the remote MDT, copy this path segment to gf
+	 */
 	if (remote_gf) {
 		struct getinfo_fid2path *ori_gf;
 		char *ptr;
@@ -797,7 +798,8 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 	/* unregister request (call from llapi_hsm_copytool_fini) */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		/* best effort: try to clean as much as possible
-		 * (continue on error) */
+		 * (continue on error)
+		 */
 		obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len, lk, uarg);
 	}
 
@@ -821,7 +823,8 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 
 	/* All or nothing: try to register to all MDS.
 	 * In case of failure, unregister from previous MDS,
-	 * except if it because of inactive target. */
+	 * except if it because of inactive target.
+	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp,
 				   len, lk, uarg);
@@ -841,8 +844,8 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 				return rc;
 			}
 			/* else: transient error.
-			 * kuc will register to the missing MDT
-			 * when it is back */
+			 * kuc will register to the missing MDT when it is back
+			 */
 		} else {
 			any_set = true;
 		}
@@ -1028,7 +1031,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 
 		/* if the request is about a single fid
 		 * or if there is a single MDS, no need to split
-		 * the request. */
+		 * the request.
+		 */
 		if (reqcount == 1 || count == 1) {
 			tgt = lmv_find_target(lmv,
 					      &hur->hur_user_item[0].hui_fid);
@@ -1104,7 +1108,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 				continue;
 			/* ll_umount_begin() sets force flag but for lmv, not
-			 * mdc. Let's pass it through */
+			 * mdc. Let's pass it through
+			 */
 			mdc_obd = class_exp2obd(lmv->tgts[i]->ltd_exp);
 			mdc_obd->obd_force = obddev->obd_force;
 			err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len,
@@ -1211,7 +1216,8 @@ static int lmv_placement_policy(struct obd_device *obd,
 	}
 
 	/* Allocate new fid on target according to operation type and parent
-	 * home mds. */
+	 * home mds.
+	 */
 	*mds = op_data->op_mds;
 	return 0;
 }
@@ -1363,7 +1369,8 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 	switch (lcfg->lcfg_command) {
 	case LCFG_ADD_MDC:
 		/* modify_mdc_tgts add 0:lustre-clilmv  1:lustre-MDT0000_UUID
-		 * 2:0  3:1  4:lustre-MDT0000-mdc_UUID */
+		 * 2:0  3:1  4:lustre-MDT0000-mdc_UUID
+		 */
 		if (LUSTRE_CFG_BUFLEN(lcfg, 1) > sizeof(obd_uuid.uuid)) {
 			rc = -EINVAL;
 			goto out;
@@ -1427,7 +1434,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 			 * i.e. mount does not need the merged osfs
 			 * from all of MDT.
 			 * And also clients can be mounted as long as
-			 * MDT0 is in service*/
+			 * MDT0 is in service
+			 */
 			if (flags & OBD_STATFS_FOR_MDT0)
 				goto out_free_temp;
 		} else {
@@ -2122,7 +2130,8 @@ static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
 				break;
 
 			/* Enlarge the end entry lde_reclen from 0 to
-			 * first entry of next lu_dirpage. */
+			 * first entry of next lu_dirpage.
+			 */
 			LASSERT(le16_to_cpu(end_dirent->lde_reclen) == 0);
 			end_dirent->lde_reclen =
 				cpu_to_le16((char *)(dp->ldp_entries) -
@@ -2260,7 +2269,8 @@ retry:
 	 * 4. Then A will resend unlink RPC to MDT0. (retry 2nd times).
 	 *
 	 * In theory, it might try unlimited time here, but it should
-	 * be very rare case.  */
+	 * be very rare case.
+	 */
 	op_data->op_fid2 = body->fid1;
 	ptlrpc_req_finished(*request);
 	*request = NULL;
@@ -2275,7 +2285,8 @@ static int lmv_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 	switch (stage) {
 	case OBD_CLEANUP_EARLY:
 		/* XXX: here should be calling obd_precleanup() down to
-		 * stack. */
+		 * stack.
+		 */
 		break;
 	case OBD_CLEANUP_EXPORTS:
 		fld_client_debugfs_fini(&lmv->lmv_fld);
-- 
2.1.0
