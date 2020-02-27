From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:49 -0500
Subject: [lustre-devel] [PATCH 181/622] lustre: lmv: Fix style issues for
 lmv_fld.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-182-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch for file
fs/lustre/lmv/lmv_fld.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 72ee63625055 ("LU-6142 lmv: Fix style issues for lmv_fld.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33566
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_fld.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/lmv/lmv_fld.c b/fs/lustre/lmv/lmv_fld.c
index 00dc858..ef2c866 100644
--- a/fs/lustre/lmv/lmv_fld.c
+++ b/fs/lustre/lmv/lmv_fld.c
@@ -58,15 +58,17 @@ int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
 	 */
 	if (!fid_is_sane(fid) || !(fid_seq_in_fldb(fid_seq(fid)) ||
 				   fid_seq_is_local_file(fid_seq(fid)))) {
-		CERROR("%s: invalid FID " DFID "\n", obd->obd_name, PFID(fid));
-		return -EINVAL;
+		rc = -EINVAL;
+		CERROR("%s: invalid FID " DFID ": rc = %d\n", obd->obd_name,
+		       PFID(fid), rc);
+		return rc;
 	}
 
 	rc = fld_client_lookup(&lmv->lmv_fld, fid_seq(fid), mds,
 			       LU_SEQ_RANGE_MDT, NULL);
 	if (rc) {
-		CERROR("Error while looking for mds number. Seq %#llx, err = %d\n",
-		       fid_seq(fid), rc);
+		CERROR("%s: Error while looking for mds number. Seq %#llx: rc = %d\n",
+		       obd->obd_name, fid_seq(fid), rc);
 		return rc;
 	}
 
@@ -74,9 +76,10 @@ int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
 	       *mds, PFID(fid));
 
 	if (*mds >= lmv->desc.ld_tgt_count) {
-		CERROR("FLD lookup got invalid mds #%x (max: %x) for fid=" DFID "\n", *mds, lmv->desc.ld_tgt_count,
-		       PFID(fid));
 		rc = -EINVAL;
+		CERROR("%s: FLD lookup got invalid mds #%x (max: %x) for fid=" DFID ": rc = %d\n",
+		       obd->obd_name, *mds, lmv->desc.ld_tgt_count, PFID(fid),
+		       rc);
 	}
 	return rc;
 }
-- 
1.8.3.1
