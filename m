From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:19 -0500
Subject: [lustre-devel] [PATCH v2 24/33] lustre: pfl: fix hang with
 grouplocks
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

This is a makeshift fix. When we hold a group lock of a file,
there should no data written to the file, since during the
write IO, the file's layout could possibly change, and the
write IO will try to update its layout, which could be blocked
by itself.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9344
Reviewed-on: https://review.whamcloud.com/26646
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h |  2 ++
 drivers/staging/lustre/lustre/llite/file.c        | 26 +++++++++++++++++++++++
 drivers/staging/lustre/lustre/lov/lov_object.c    |  1 +
 3 files changed, 29 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 57ced0f..ee71f1c 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -288,6 +288,8 @@ struct cl_layout {
 	size_t		cl_size;
 	/** Layout generation. */
 	u32		cl_layout_gen;
+	/** whether layout is a composite one */
+	bool		cl_is_composite;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6a0a468..08ba8f7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1551,6 +1551,7 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 {
 	struct ll_inode_info   *lli = ll_i2info(inode);
 	struct ll_file_data    *fd = LUSTRE_FPRIVATE(file);
+	struct cl_object *obj = lli->lli_clob;
 	struct ll_grouplock    grouplock;
 	int		     rc;
 
@@ -1572,6 +1573,31 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	LASSERT(!fd->fd_grouplock.lg_lock);
 	spin_unlock(&lli->lli_lock);
 
+	/**
+	 * XXX: group lock needs to protect all OST objects while PFL
+	 * can add new OST objects during the IO, so we'd instantiate
+	 * all OST objects before getting its group lock.
+	 */
+	if (obj) {
+		struct cl_layout cl = {
+			.cl_is_composite = false,
+		};
+		struct lu_env *env;
+		u16 refcheck;
+
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env))
+			return PTR_ERR(env);
+
+		rc = cl_object_layout_get(env, obj, &cl);
+		if (!rc && cl.cl_is_composite)
+			rc = ll_layout_write_intent(inode, 0, OBD_OBJECT_EOF);
+
+		cl_env_put(env, &refcheck);
+		if (rc)
+			return rc;
+	}
+
 	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
 			      arg, (file->f_flags & O_NONBLOCK), &grouplock);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 35c9403..968c49d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1637,6 +1637,7 @@ static int lov_object_layout_get(const struct lu_env *env,
 
 	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
+	cl->cl_is_composite = lsm_is_composite(lsm->lsm_magic);
 
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
-- 
1.8.3.1
