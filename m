From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:34 -0500
Subject: [lustre-devel] [PATCH 01/14] lustre: llite: Add S_NOSEC support
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

We must use the i_mutex to protect permission changes,
which means we need to take it when we write to a file with
the setuid or setgid bit set (as this removes those bits).

LU-8025 attempted to use IS_NOSEC to check for this case,
but did not actually add support for the S_NOSEC flag to
Lustre.

S_NOSEC was added in upstream kernel commit:
69b4573296469fd3f70cf7044693074980517067
But a key change requiring parallel filesystems to opt in
with a superblock flag was added in:
9e1f1de02c2275d7172e18dc4e7c2065777611bf

This patch adds the required support.

Specifically, Lustre should set S_NOSEC correctly when an
inode is created (ll_iget), but only for new inodes.
Setting it for existing inodes requires taking the i_mutex,
creating an unacceptable metadata performance impact in the
lookup code.

Existing inodes get S_NOSEC set either by a setattr call
(see below), or by the first writer to write to the node,
in file_remove_privs/file_remove_suid.  So it's OK not to
set S_NOSEC on all inodes in ll_iget.

Also, Lustre must clear S_NOSEC when it gets a metadata
update because another node could have changed permissions.
i_flags is already cleared in ll_update_inode, but we would
prefer to have S_NOSEC set whenever possible, so we want to
re-do the check after the update.

This requires holding the i_mutex to avoid a check/set race
with permissions changes.

We cannot easily take the i_mutex in ll_update_inode (it is
called from too many places, some of which already hold the
i_mutex).

It is acceptable to sometimes not have S_NOSEC set (since
occasionally taking the i_mutex when not needed is OK), so
we look at getting it set most of the time.

It looks like the primary concern is ll_md_setattr.  The
caller (ll_setattr_raw) takes the i_mutex before returning,
so we do the relevant call there.

This opens a window during which S_NOSEC is not set, but
again, this merely creates a situation where we take the
i_mutex unnecessarily, and should be rare in practice.

Testing with multiple writers shows that we only very
rarely attempt to take the i_mutex, so the performance
impact is minimal.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8656
Reviewed-on: https://review.whamcloud.com/22853
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_support.h |  2 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c     | 19 +++++++++++++++++--
 drivers/staging/lustre/lustre/llite/namei.c         |  1 +
 drivers/staging/lustre/lustre/llite/vvp_io.c        | 10 +++++++++-
 4 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 1832193..79875fa 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -442,6 +442,8 @@
 #define OBD_FAIL_LLITE_LOST_LAYOUT		    0x1407
 #define OBD_FAIL_GETATTR_DELAY			    0x1409
 #define OBD_FAIL_LLITE_CREATE_NODE_PAUSE	    0x140c
+#define OBD_FAIL_LLITE_IMUTEX_SEC		    0x140e
+#define OBD_FAIL_LLITE_IMUTEX_NOSEC		    0x140f
 
 #define OBD_FAIL_FID_INDIR	0x1501
 #define OBD_FAIL_FID_INLMA	0x1502
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index cd169c1..203a1f7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -227,6 +227,11 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (sbi->ll_flags & LL_SBI_USER_XATTR)
 		data->ocd_connect_flags |= OBD_CONNECT_XATTR;
 
+	/* Setting this indicates we correctly support S_NOSEC (See kernel
+	 * commit 9e1f1de02c2275d7172e18dc4e7c2065777611bf)
+	 */
+	sb->s_flags |= MS_NOSEC;
+
 	if (sbi->ll_flags & LL_SBI_FLOCK)
 		sbi->ll_fop = &ll_file_operations_flock;
 	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
@@ -1638,6 +1643,13 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		inode_lock(inode);
 		if ((attr->ia_valid & ATTR_SIZE) && !hsm_import)
 			inode_dio_wait(inode);
+		/* Once we've got the i_mutex, it's safe to set the S_NOSEC
+		 * flag.  ll_update_inode (called from ll_md_setattr), clears
+		 * inode flags, so there is a gap where S_NOSEC is not set.
+		 * This can cause a writer to take the i_mutex unnecessarily,
+		 * but this is safe to do and should be rare.
+		 */
+		inode_has_no_xattr(inode);
 	}
 
 	ll_stats_ops_tally(ll_i2sbi(inode), (attr->ia_valid & ATTR_SIZE) ?
@@ -1847,6 +1859,11 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 			inode->i_ctime.tv_sec = body->mbo_ctime;
 		lli->lli_ctime = body->mbo_ctime;
 	}
+
+	/* Clear i_flags to remove S_NOSEC before permissions are updated */
+	if (body->mbo_valid & OBD_MD_FLFLAGS)
+		ll_update_inode_flags(inode, body->mbo_flags);
+
 	if (body->mbo_valid & OBD_MD_FLMODE)
 		inode->i_mode = (inode->i_mode & S_IFMT) |
 				(body->mbo_mode & ~S_IFMT);
@@ -1865,8 +1882,6 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		inode->i_gid = make_kgid(&init_user_ns, body->mbo_gid);
 	if (body->mbo_valid & OBD_MD_FLPROJID)
 		lli->lli_projid = body->mbo_projid;
-	if (body->mbo_valid & OBD_MD_FLFLAGS)
-		ll_update_inode_flags(inode, body->mbo_flags);
 	if (body->mbo_valid & OBD_MD_FLNLINK)
 		set_nlink(inode, body->mbo_nlink);
 	if (body->mbo_valid & OBD_MD_FLRDEV)
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index f2bd57e..b5b46f7 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -130,6 +130,7 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			iput(inode);
 			inode = ERR_PTR(rc);
 		} else {
+			inode_has_no_xattr(inode);
 			unlock_new_inode(inode);
 		}
 	} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index d6b27ba..b772e25 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -925,9 +925,10 @@ static int vvp_io_write_start(const struct lu_env *env,
 	struct cl_object   *obj   = io->ci_obj;
 	struct inode       *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
-	ssize_t result = 0;
+	bool lock_inode = !inode_is_locked(inode) && !IS_NOSEC(inode);
 	loff_t pos = io->u.ci_wr.wr.crw_pos;
 	size_t cnt = io->u.ci_wr.wr.crw_count;
+	ssize_t result = 0;
 
 	down_read(&lli->lli_trunc_sem);
 
@@ -963,6 +964,13 @@ static int vvp_io_write_start(const struct lu_env *env,
 		return -EFBIG;
 	}
 
+	/* Tests to verify we take the i_mutex correctly */
+	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_SEC) && !lock_inode)
+		return -EINVAL;
+
+	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_NOSEC) && lock_inode)
+		return -EINVAL;
+
 	if (!vio->vui_iter) {
 		/* from a temp io in ll_cl_init(). */
 		result = 0;
-- 
1.8.3.1
