From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:22 -0500
Subject: [lustre-devel] [PATCH 154/622] lustre: flr: add mirror write command
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-155-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

This change allows issuing a RESYNC lease write lock to notify MDS
to prepare destination mirror for the write (instantiate components
of the mirror), then client copy data from a file or STDIN to the
specified mirror of the mirrored file. After the data copy, a
RESYNC_DONE lease unlock is issued to MDS to update the layout
of the mirrored file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10258
Lustre-commit: 14171e787dd0 ("LU-10258 lfs: lfs mirror write command")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33219
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 10 ++++++++--
 fs/lustre/mdc/mdc_reint.c               |  1 +
 fs/lustre/ptlrpc/pack_generic.c         |  1 +
 fs/lustre/ptlrpc/wiretest.c             | 16 ++++++++++++----
 include/uapi/linux/lustre/lustre_idl.h  |  6 ++++--
 include/uapi/linux/lustre/lustre_user.h | 10 ++++++++++
 6 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ed0470d..9de37d2 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1162,10 +1162,11 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
  * After lease is taken, send the RPC MDS_REINT_RESYNC to the MDT
  */
 static int ll_lease_file_resync(struct obd_client_handle *och,
-				struct inode *inode)
+				struct inode *inode, unsigned long arg)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct md_op_data *op_data;
+	struct ll_ioc_lease_id ioc;
 	u64 data_version_unused;
 	int rc;
 
@@ -1174,6 +1175,10 @@ static int ll_lease_file_resync(struct obd_client_handle *och,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	if (copy_from_user(&ioc, (struct ll_ioc_lease_id __user *)arg,
+			   sizeof(ioc)))
+		return -EFAULT;
+
 	/* before starting file resync, it's necessary to clean up page cache
 	 * in client memory, otherwise once the layout version is increased,
 	 * writing back cached data will be denied the OSTs.
@@ -1183,6 +1188,7 @@ static int ll_lease_file_resync(struct obd_client_handle *och,
 		goto out;
 
 	op_data->op_lease_handle = och->och_lease_handle;
+	op_data->op_mirror_id = ioc.lil_mirror_id;
 	rc = md_file_resync(sbi->ll_md_exp, op_data);
 	if (rc)
 		goto out;
@@ -3048,7 +3054,7 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 		return PTR_ERR(och);
 
 	if (ioc->lil_flags & LL_LEASE_RESYNC) {
-		rc = ll_lease_file_resync(och, inode);
+		rc = ll_lease_file_resync(och, inode, arg);
 		if (rc) {
 			ll_lease_close(och, inode, NULL);
 			return rc;
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 5d82449..062685c 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -455,6 +455,7 @@ int mdc_file_resync(struct obd_export *exp, struct md_op_data *op_data)
 	rec->rs_cap	= op_data->op_cap.cap[0];
 	rec->rs_fid	= op_data->op_fid1;
 	rec->rs_bias	= op_data->op_bias;
+	rec->rs_mirror_id = op_data->op_mirror_id;
 
 	lock = ldlm_handle2lock(&op_data->op_lease_handle);
 	if (lock) {
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index d93dbe1..231cb26 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1917,6 +1917,7 @@ void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 	__swab32s(&rr->rr_flags);
 	__swab32s(&rr->rr_flags_h);
 	__swab32s(&rr->rr_umask);
+	__swab16s(&rr->rr_mirror_id);
 
 	BUILD_BUG_ON(offsetof(typeof(*rr), rr_padding_4) == 0);
 };
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index f72e5fc..66dce80 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2854,9 +2854,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding8));
 	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding8) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding8));
-	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding9) == 132, "found %lld\n",
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_mirror_id) == 132, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_mirror_id));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_mirror_id) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_mirror_id));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding9) == 134, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding9));
-	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding9) == 4, "found %lld\n",
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding9) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding9));
 
 	/* Checks for struct mdt_rec_reint */
@@ -2950,9 +2954,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_rec_reint, rr_umask));
 	LASSERTF((int)sizeof(((struct mdt_rec_reint *)0)->rr_umask) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_reint *)0)->rr_umask));
-	LASSERTF((int)offsetof(struct mdt_rec_reint, rr_padding_4) == 132, "found %lld\n",
+	LASSERTF((int)offsetof(struct mdt_rec_reint, rr_mirror_id) == 132, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_reint, rr_mirror_id));
+	LASSERTF((int)sizeof(((struct mdt_rec_reint *)0)->rr_mirror_id) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_reint *)0)->rr_mirror_id));
+	LASSERTF((int)offsetof(struct mdt_rec_reint, rr_padding_4) == 134, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_rec_reint, rr_padding_4));
-	LASSERTF((int)sizeof(((struct mdt_rec_reint *)0)->rr_padding_4) == 4, "found %lld\n",
+	LASSERTF((int)sizeof(((struct mdt_rec_reint *)0)->rr_padding_4) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_reint *)0)->rr_padding_4));
 
 	/* Checks for struct lmv_desc */
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d46a921..8330fe1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1876,7 +1876,8 @@ struct mdt_rec_resync {
 	__u32           rs_padding6;	/* rr_flags */
 	__u32           rs_padding7;	/* rr_flags_h */
 	__u32           rs_padding8;	/* rr_umask */
-	__u32           rs_padding9;	/* rr_padding_4 */
+	__u16           rs_mirror_id;
+	__u16           rs_padding9;	/* rr_padding_4 */
 };
 
 /*
@@ -1910,7 +1911,8 @@ struct mdt_rec_reint {
 	__u32		rr_flags;
 	__u32		rr_flags_h;
 	__u32		rr_umask;
-	__u32		rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
+	__u16		rr_mirror_id;
+	__u16		rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
 };
 
 /* lmv structures */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index db751d8..5551cbf 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -277,6 +277,16 @@ struct ll_ioc_lease {
 	__u32		lil_ids[0];
 };
 
+struct ll_ioc_lease_id {
+	__u32		lil_mode;
+	__u32		lil_flags;
+	__u32		lil_count;
+	__u16		lil_mirror_id;
+	__u16		lil_padding1;
+	__u64		lil_padding2;
+	__u32		lil_ids[0];
+};
+
 /*
  * The ioctl naming rules:
  * LL_*     - works on the currently opened filehandle instead of parent dir
-- 
1.8.3.1
