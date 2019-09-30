From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:08 -0400
Subject: [lustre-devel] [PATCH 109/151] lustre: flr: revise lease API
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-110-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Introduce new user land API LL_LEASE_LAYOUT_MERGE which allows
direct control of the bias. Remove special MERGE_LAYOUTS_CLOSE.
Instead always use SWAP_LAYOUTS_CLOSE which simplifies the code
handling the layout swap on file close.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10418
Lustre-commit: 8f1c7c1e44a4 ("LU-10418 flr: revise lease API")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/30363
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 74 +++++++++++++++++++++++----------
 include/uapi/linux/lustre/lustre_user.h |  3 +-
 2 files changed, 53 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f1db600..9d60587 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -970,12 +970,10 @@ static int ll_check_swap_layouts_validity(struct inode *inode1,
 }
 
 static int ll_swap_layouts_close(struct obd_client_handle *och,
-				 struct inode *inode, struct inode *inode2,
-				 int intent)
+				 struct inode *inode, struct inode *inode2)
 {
 	const struct lu_fid *fid1 = ll_inode2fid(inode);
 	const struct lu_fid *fid2;
-	enum mds_op_bias bias;
 	int rc;
 
 	CDEBUG(D_INODE, "%s: biased close of file " DFID "\n",
@@ -994,24 +992,13 @@ static int ll_swap_layouts_close(struct obd_client_handle *och,
 		goto out_free_och;
 	}
 
-	switch (intent) {
-	case SWAP_LAYOUTS_CLOSE:
-		bias = MDS_CLOSE_LAYOUT_SWAP;
-		break;
-	case MERGE_LAYOUTS_CLOSE:
-		bias = MDS_CLOSE_LAYOUT_MERGE;
-		break;
-	default:
-		rc = -EOPNOTSUPP;
-		goto out_free_och;
-	}
-
 	/*
 	 * Close the file and {swap,merge} layouts between inode & inode2.
 	 * NB: lease lock handle is released in mdc_close_layout_swap_pack()
 	 * because we still need it to pack l_remote_handle to MDT.
 	 */
-	rc = ll_close_inode_openhandle(inode, och, bias, inode2);
+	rc = ll_close_inode_openhandle(inode, och, MDS_CLOSE_LAYOUT_SWAP,
+				       inode2);
 
 	och = NULL; /* freed in ll_close_inode_openhandle() */
 
@@ -2675,6 +2662,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	bool lease_broken;
 	fmode_t fmode = 0;
 	enum mds_op_bias bias = 0;
+	struct file *layout_file = NULL;
 	void *data = NULL;
 	size_t data_size = 0;
 	long rc;
@@ -2693,7 +2681,8 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 
 	fmode = och->och_flags;
 
-	if (ioc->lil_flags & LL_LEASE_RESYNC_DONE) {
+	switch (ioc->lil_flags) {
+	case LL_LEASE_RESYNC_DONE:
 		if (ioc->lil_count > IOC_IDS_MAX) {
 			rc = -EINVAL;
 			goto out;
@@ -2712,6 +2701,40 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		}
 
 		bias = MDS_CLOSE_RESYNC_DONE;
+		break;
+	case LL_LEASE_LAYOUT_MERGE: {
+		int fd;
+
+		if (ioc->lil_count != 1) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		arg += sizeof(*ioc);
+		if (copy_from_user(&fd, (void __user *)arg, sizeof(u32))) {
+			rc = -EFAULT;
+			goto out;
+		}
+
+		layout_file = fget(fd);
+		if (!layout_file) {
+			rc = -EBADF;
+			goto out;
+		}
+
+		if ((file->f_flags & O_ACCMODE) == O_RDONLY ||
+		    (layout_file->f_flags & O_ACCMODE) == O_RDONLY) {
+			rc = -EPERM;
+			goto out;
+		}
+
+		data = file_inode(layout_file);
+		bias = MDS_CLOSE_LAYOUT_MERGE;
+		break;
+	}
+	default:
+		/* without close intent */
+		break;
 	}
 
 	rc = ll_lease_close_intent(och, inode, &lease_broken, bias, data);
@@ -2726,7 +2749,16 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		fmode = 0;
 
 out:
-	kfree(data);
+	switch (ioc->lil_flags) {
+	case LL_LEASE_RESYNC_DONE:
+		kfree(data);
+		break;
+	case LL_LEASE_LAYOUT_MERGE:
+		if (layout_file)
+			fput(layout_file);
+		break;
+	}
+
 	if (!rc)
 		rc = ll_lease_type_from_fmode(fmode);
 	return rc;
@@ -2847,7 +2879,6 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
 		struct file *file2;
 		struct lustre_swap_layouts lsl;
-		u64 intent;
 
 		if (copy_from_user(&lsl, (char __user *)arg,
 				   sizeof(struct lustre_swap_layouts)))
@@ -2866,8 +2897,7 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 			goto out;
 		}
 
-		intent = lsl.sl_flags & INTENT_LAYOUTS_CLOSE;
-		if (intent) {
+		if (lsl.sl_flags & SWAP_LAYOUTS_CLOSE) {
 			struct obd_client_handle *och = NULL;
 			struct ll_inode_info *lli;
 			struct inode *inode2;
@@ -2884,7 +2914,7 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 				goto out;
 			}
 			inode2 = file_inode(file2);
-			rc = ll_swap_layouts_close(och, inode, inode2, intent);
+			rc = ll_swap_layouts_close(och, inode, inode2);
 		} else {
 			rc = ll_swap_layouts(file, file2, &lsl);
 		}
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d53e795..36f78a6 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -253,6 +253,7 @@ enum ll_lease_mode {
 enum ll_lease_flags {
 	LL_LEASE_RESYNC		= 0x1,
 	LL_LEASE_RESYNC_DONE	= 0x2,
+	LL_LEASE_LAYOUT_MERGE	= 0x4,
 };
 
 #define IOC_IDS_MAX	4096
@@ -824,8 +825,6 @@ struct if_quotactl {
 #define SWAP_LAYOUTS_KEEP_MTIME		(1 << 2)
 #define SWAP_LAYOUTS_KEEP_ATIME		(1 << 3)
 #define SWAP_LAYOUTS_CLOSE		(1 << 4)
-#define MERGE_LAYOUTS_CLOSE		(1 << 5)
-#define INTENT_LAYOUTS_CLOSE	(SWAP_LAYOUTS_CLOSE | MERGE_LAYOUTS_CLOSE)
 
 /* Swap XATTR_NAME_HSM as well, only on the MDT so far */
 #define SWAP_LAYOUTS_MDS_HSM		(1 << 31)
-- 
1.8.3.1
