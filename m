From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:18 -0500
Subject: [lustre-devel] [PATCH 450/622] lustre: llite: prevent mulitple
 group locks
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-451-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The patch adds mutex for group lock enqueue. It also adds waiting
of group lock users on a client side for a same node. This prevents
mulitple locks on the same resource and fixes a bugs when two locks
cover the same dirty pages.

The patch adds test sanity 244b. It creates threads which
opens file, takes group lock, writes data, puts group lock, closes.
It recreates the problem when a client has two or more group locks
for a single file. This leads to a wrong behaviour for a flush etc.
osc_cache_writeback_range()) ASSERTION( hp == 0 && discard == 0 )
failed
One more test for group lock with open file and fork. It checks that
child doesn't unlock file until the last close.

Cray-bug-id: LUS-7232
WC-bug-id: https://jira.whamcloud.com/browse/LU-9964
Lustre-commit: aba68250a67a ("LU-9964 llite: prevent mulitple group locks")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/35791
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c    |  3 +-
 fs/lustre/llite/file.c           | 75 ++++++++++++++++++++++++++--------------
 fs/lustre/llite/llite_internal.h |  3 ++
 fs/lustre/llite/llite_lib.c      |  3 ++
 fs/lustre/osc/osc_lock.c         |  2 ++
 5 files changed, 60 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 75492f6..0dd9fea 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -750,7 +750,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	lock->l_conn_export = exp;
 	lock->l_export = NULL;
 	lock->l_blocking_ast = einfo->ei_cb_bl;
-	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
+	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL |
+				    LDLM_FL_ATOMIC_CB));
 	lock->l_activity = ktime_get_real_seconds();
 
 	/* lock not sent to server yet */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 6c5b9eb..856aa64 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2075,15 +2075,30 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
 
-	spin_lock(&lli->lli_lock);
+retry:
+	if (file->f_flags & O_NONBLOCK) {
+		if (!mutex_trylock(&lli->lli_group_mutex))
+			return -EAGAIN;
+	} else
+		mutex_lock(&lli->lli_group_mutex);
+
 	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 		CWARN("group lock already existed with gid %lu\n",
 		      fd->fd_grouplock.lg_gid);
-		spin_unlock(&lli->lli_lock);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
+	}
+	if (arg != lli->lli_group_gid && lli->lli_group_users != 0) {
+		if (file->f_flags & O_NONBLOCK) {
+			rc = -EAGAIN;
+			goto out;
+		}
+		mutex_unlock(&lli->lli_group_mutex);
+		wait_var_event(&lli->lli_group_users, !lli->lli_group_users);
+		rc = 0;
+		goto retry;
 	}
 	LASSERT(!fd->fd_grouplock.lg_lock);
-	spin_unlock(&lli->lli_lock);
 
 	/**
 	 * XXX: group lock needs to protect all OST objects while PFL
@@ -2102,8 +2117,10 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 		u16 refcheck;
 
 		env = cl_env_get(&refcheck);
-		if (IS_ERR(env))
-			return PTR_ERR(env);
+		if (IS_ERR(env)) {
+			rc = PTR_ERR(env);
+			goto out;
+		}
 
 		rc = cl_object_layout_get(env, obj, &cl);
 		if (!rc && cl.cl_is_composite)
@@ -2112,28 +2129,26 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 
 		cl_env_put(env, &refcheck);
 		if (rc)
-			return rc;
+			goto out;
 	}
 
 	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
 			      arg, (file->f_flags & O_NONBLOCK), &grouplock);
-	if (rc)
-		return rc;
 
-	spin_lock(&lli->lli_lock);
-	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
-		spin_unlock(&lli->lli_lock);
-		CERROR("another thread just won the race\n");
-		cl_put_grouplock(&grouplock);
-		return -EINVAL;
-	}
+	if (rc)
+		goto out;
 
 	fd->fd_flags |= LL_FILE_GROUP_LOCKED;
 	fd->fd_grouplock = grouplock;
-	spin_unlock(&lli->lli_lock);
+	if (lli->lli_group_users == 0)
+		lli->lli_group_gid = grouplock.lg_gid;
+	lli->lli_group_users++;
 
 	CDEBUG(D_INFO, "group lock %lu obtained\n", arg);
-	return 0;
+out:
+	mutex_unlock(&lli->lli_group_mutex);
+
+	return rc;
 }
 
 static int ll_put_grouplock(struct inode *inode, struct file *file,
@@ -2142,30 +2157,40 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_grouplock grouplock;
+	int rc;
 
-	spin_lock(&lli->lli_lock);
+	mutex_lock(&lli->lli_group_mutex);
 	if (!(fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-		spin_unlock(&lli->lli_lock);
 		CWARN("no group lock held\n");
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 	LASSERT(fd->fd_grouplock.lg_lock);
 
 	if (fd->fd_grouplock.lg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
 		      arg, fd->fd_grouplock.lg_gid);
-		spin_unlock(&lli->lli_lock);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
 	grouplock = fd->fd_grouplock;
 	memset(&fd->fd_grouplock, 0, sizeof(fd->fd_grouplock));
 	fd->fd_flags &= ~LL_FILE_GROUP_LOCKED;
-	spin_unlock(&lli->lli_lock);
 
 	cl_put_grouplock(&grouplock);
+
+	lli->lli_group_users--;
+	if (lli->lli_group_users == 0) {
+		lli->lli_group_gid = 0;
+		wake_up_var(&lli->lli_group_users);
+	}
 	CDEBUG(D_INFO, "group lock %lu released\n", arg);
-	return 0;
+	rc = 0;
+out:
+	mutex_unlock(&lli->lli_group_mutex);
+
+	return rc;
 }
 
 /**
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 49c0c78..232fb0a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -210,6 +210,9 @@ struct ll_inode_info {
 			struct mutex		 lli_pcc_lock;
 			enum lu_pcc_state_flags	 lli_pcc_state;
 			struct pcc_inode	*lli_pcc_inode;
+			struct mutex			lli_group_mutex;
+			u64				lli_group_users;
+			unsigned long			lli_group_gid;
 		};
 	};
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 86be562..8946dc6 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -983,6 +983,9 @@ void ll_lli_init(struct ll_inode_info *lli)
 		mutex_init(&lli->lli_pcc_lock);
 		lli->lli_pcc_state = PCC_STATE_FL_NONE;
 		lli->lli_pcc_inode = NULL;
+		mutex_init(&lli->lli_group_mutex);
+		lli->lli_group_users = 0;
+		lli->lli_group_gid = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 33fdc7e7..c748e58 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1182,6 +1182,8 @@ int osc_lock_init(const struct lu_env *env,
 
 	oscl->ols_flags = osc_enq2ldlm_flags(enqflags);
 	oscl->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
+	if (lock->cll_descr.cld_mode == CLM_GROUP)
+		oscl->ols_flags |= LDLM_FL_ATOMIC_CB;
 
 	if (oscl->ols_flags & LDLM_FL_HAS_INTENT) {
 		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
-- 
1.8.3.1
