From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:24 -0400
Subject: [lustre-devel] [PATCH 07/18] lustre: llite: restore fd_och when
 putting lease
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Henri Doreau <henri.doreau@cea.fr>

fd_och was not restored when putting back a file lease, preventing
from getting a lease, putting it back and taking it again on a FD.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8174
Reviewed-on: http://review.whamcloud.com/20331
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Jean-Baptiste Riaux <riaux.jb@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 132 +++++++++++++++++++++--------
 1 file changed, 97 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index db18d1d..d570232 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -705,6 +705,97 @@ static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
 }
 
 /**
+ * When setting a lease on a file, we take ownership of the lli_mds_*_och
+ * and save it as fd->fd_och so as to force client to reopen the file even
+ * if it has an open lock in cache already.
+ */
+static int ll_lease_och_acquire(struct inode *inode, struct file *file,
+				struct lustre_handle *old_handle)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct obd_client_handle **och_p;
+	u64 *och_usecount;
+	int rc = 0;
+
+	/* Get the openhandle of the file */
+	mutex_lock(&lli->lli_och_mutex);
+	if (fd->fd_lease_och) {
+		rc = -EBUSY;
+		goto out_unlock;
+	}
+
+	if (!fd->fd_och) {
+		if (file->f_mode & FMODE_WRITE) {
+			LASSERT(lli->lli_mds_write_och);
+			och_p = &lli->lli_mds_write_och;
+			och_usecount = &lli->lli_open_fd_write_count;
+		} else {
+			LASSERT(lli->lli_mds_read_och);
+			och_p = &lli->lli_mds_read_och;
+			och_usecount = &lli->lli_open_fd_read_count;
+		}
+
+		if (*och_usecount > 1) {
+			rc = -EBUSY;
+			goto out_unlock;
+		}
+
+		fd->fd_och = *och_p;
+		*och_usecount = 0;
+		*och_p = NULL;
+	}
+
+	*old_handle = fd->fd_och->och_fh;
+
+out_unlock:
+	mutex_unlock(&lli->lli_och_mutex);
+	return rc;
+}
+
+/**
+ * Release ownership on lli_mds_*_och when putting back a file lease.
+ */
+static int ll_lease_och_release(struct inode *inode, struct file *file)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct obd_client_handle *old_och = NULL;
+	struct obd_client_handle **och_p;
+	u64 *och_usecount;
+	int rc = 0;
+
+	mutex_lock(&lli->lli_och_mutex);
+	if (file->f_mode & FMODE_WRITE) {
+		och_p = &lli->lli_mds_write_och;
+		och_usecount = &lli->lli_open_fd_write_count;
+	} else {
+		och_p = &lli->lli_mds_read_och;
+		och_usecount = &lli->lli_open_fd_read_count;
+	}
+
+	/*
+	 * The file may have been open by another process (broken lease) so
+	 * *och_p is not NULL. In this case we should simply increase usecount
+	 * and close fd_och.
+	 */
+	if (*och_p) {
+		old_och = fd->fd_och;
+		(*och_usecount)++;
+	} else {
+		*och_p = fd->fd_och;
+		*och_usecount = 1;
+	}
+	fd->fd_och = NULL;
+	mutex_unlock(&lli->lli_och_mutex);
+
+	if (old_och)
+		rc = ll_close_inode_openhandle(inode, old_och, 0, NULL);
+
+	return rc;
+}
+
+/**
  * Acquire a lease and open the file.
  */
 static struct obd_client_handle *
@@ -724,45 +815,12 @@ static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
 		return ERR_PTR(-EINVAL);
 
 	if (file) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
-		struct obd_client_handle **och_p;
-		__u64 *och_usecount;
-
 		if (!(fmode & file->f_mode) || (file->f_mode & FMODE_EXEC))
 			return ERR_PTR(-EPERM);
 
-		/* Get the openhandle of the file */
-		rc = -EBUSY;
-		mutex_lock(&lli->lli_och_mutex);
-		if (fd->fd_lease_och) {
-			mutex_unlock(&lli->lli_och_mutex);
-			return ERR_PTR(rc);
-		}
-
-		if (!fd->fd_och) {
-			if (file->f_mode & FMODE_WRITE) {
-				LASSERT(lli->lli_mds_write_och);
-				och_p = &lli->lli_mds_write_och;
-				och_usecount = &lli->lli_open_fd_write_count;
-			} else {
-				LASSERT(lli->lli_mds_read_och);
-				och_p = &lli->lli_mds_read_och;
-				och_usecount = &lli->lli_open_fd_read_count;
-			}
-			if (*och_usecount == 1) {
-				fd->fd_och = *och_p;
-				*och_p = NULL;
-				*och_usecount = 0;
-				rc = 0;
-			}
-		}
-		mutex_unlock(&lli->lli_och_mutex);
-		if (rc < 0) /* more than 1 opener */
+		rc = ll_lease_och_acquire(inode, file, &old_handle);
+		if (rc)
 			return ERR_PTR(rc);
-
-		LASSERT(fd->fd_och);
-		old_handle = fd->fd_och->och_fh;
 	}
 
 	och = kzalloc(sizeof(*och), GFP_NOFS);
@@ -2333,6 +2391,10 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 			if (rc < 0)
 				return rc;
 
+			rc = ll_lease_och_release(inode, file);
+			if (rc < 0)
+				return rc;
+
 			if (lease_broken)
 				fmode = 0;
 
-- 
1.8.3.1
