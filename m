From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:45 -0500
Subject: [lustre-devel] [PATCH 15/35] staging: lustre: llite: tar restore
	fails for HSM released files.
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Aditya Pandit <panditadityashreesh@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Aditya Pandit <panditadityashreesh@yahoo.com>

If you create a file, archive and release it, it keeps only a
link and all information in xattr. If you tar the file
with --xattr you will store the same striping information and link
information in the tar. If you delete the file, the file and archive
state does not make sense. Now if you restore the file using tar
with xattr having the RELEASED flag turned on, then it is not correct
because this is a new file. Hence ignoring the HSM xattr and masking
out the "RELEASED" flag for the files, which are not archived.

Signed-off-by: Aditya Pandit <panditadityashreesh@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6214
Reviewed-on: http://review.whamcloud.com/16060
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 drivers/staging/lustre/lustre/llite/xattr.c        |   61 +++++++++++++++++++-
 2 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 579ef14..e393ae3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -1001,6 +1001,7 @@ struct ioc_data_version {
  * See HSM_FLAGS below.
  */
 enum hsm_states {
+	HS_NONE		= 0x00000000,
 	HS_EXISTS	= 0x00000001,
 	HS_DIRTY	= 0x00000002,
 	HS_RELEASED	= 0x00000004,
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index ea3becc..7a848eb 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -112,8 +112,9 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 		return -EPERM;
 
 	/* b10667: ignore lustre special xattr for now */
-	if ((handler->flags == XATTR_TRUSTED_T && !strcmp(name, "lov")) ||
-	    (handler->flags == XATTR_LUSTRE_T && !strcmp(name, "lov")))
+	if (!strcmp(name, "hsm") ||
+	    ((handler->flags == XATTR_TRUSTED_T && !strcmp(name, "lov")) ||
+	     (handler->flags == XATTR_LUSTRE_T && !strcmp(name, "lov"))))
 		return 0;
 
 	/* b15587: ignore security.capability xattr for now */
@@ -147,6 +148,37 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	return 0;
 }
 
+static int get_hsm_state(struct inode *inode, u32 *hus_states)
+{
+	struct md_op_data *op_data;
+	struct hsm_user_state *hus;
+	int rc;
+
+	hus = kzalloc(sizeof(*hus), GFP_NOFS);
+	if (!hus)
+		return -ENOMEM;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, hus);
+	if (!IS_ERR(op_data)) {
+		rc = obd_iocontrol(LL_IOC_HSM_STATE_GET, ll_i2mdexp(inode),
+				   sizeof(*op_data), op_data, NULL);
+		if (!rc)
+			*hus_states = hus->hus_states;
+		else
+			CDEBUG(D_VFSTRACE, "obd_iocontrol failed. rc = %d\n",
+			       rc);
+
+		ll_finish_md_op_data(op_data);
+	} else {
+		rc = PTR_ERR(op_data);
+		CDEBUG(D_VFSTRACE, "Could not prepare the opdata. rc = %d\n",
+		       rc);
+	}
+	kfree(hus);
+	return rc;
+}
+
 static int ll_xattr_set(const struct xattr_handler *handler,
 			struct dentry *dentry, struct inode *inode,
 			const char *name, const void *value, size_t size,
@@ -183,6 +215,31 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 		if (lump && lump->lmm_stripe_offset == 0)
 			lump->lmm_stripe_offset = -1;
 
+		/* Avoid anyone directly setting the RELEASED flag. */
+		if (lump && (lump->lmm_pattern & LOV_PATTERN_F_RELEASED)) {
+			/* Only if we have a released flag check if the file
+			 * was indeed archived.
+			 */
+			u32 state = HS_NONE;
+
+			rc = get_hsm_state(inode, &state);
+			if (rc)
+				return rc;
+
+			if (!(state & HS_ARCHIVED)) {
+				CDEBUG(D_VFSTRACE,
+				       "hus_states state = %x, pattern = %x\n",
+				state, lump->lmm_pattern);
+				/*
+				 * Here the state is: real file is not
+				 * archived but user is requesting to set
+				 * the RELEASED flag so we mask off the
+				 * released flag from the request
+				 */
+				lump->lmm_pattern ^= LOV_PATTERN_F_RELEASED;
+			}
+		}
+
 		if (lump && S_ISREG(inode->i_mode)) {
 			__u64 it_flags = FMODE_WRITE;
 			int lum_size;
-- 
1.7.1
