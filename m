Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 32988FA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:22:09 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Myncb1vsnz21Jc;
	Thu, 27 Oct 2022 07:09:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynZY2yhHz21BD
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:08:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7FB1A1009100;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 767B7FD4FC; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:33 -0400
Message-Id: <1666879542-10737-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/15] lustre: llite: revert: "lustre: llite:
 prevent mulitple group locks"
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

This reverts commit a1fd83a981c5813e3d9bc031c767bb21ba2305d2
since it makes group unlock synchronous what leads to poor performance
on shared file IO under group lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16046
Lustre-commit: bc37f89a81ea0a2fa ("LU-16046 revert: "LU-9964 llite: prevent mulitple group locks"")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48037
Reviewed-by: Alexander <alexander.boyko@hpe.com>
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c    |  3 +-
 fs/lustre/llite/file.c           | 76 ++++++++++++++--------------------------
 fs/lustre/llite/llite_internal.h |  3 --
 fs/lustre/llite/llite_lib.c      |  3 --
 fs/lustre/osc/osc_lock.c         |  2 --
 5 files changed, 27 insertions(+), 60 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 56ae9b1..cf5a290 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -773,8 +773,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	lock->l_conn_export = exp;
 	lock->l_export = NULL;
 	lock->l_blocking_ast = einfo->ei_cb_bl;
-	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL |
-				    LDLM_FL_ATOMIC_CB));
+	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
 	lock->l_activity = ktime_get_real_seconds();
 
 	/* lock not sent to server yet */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e75f482..f96557e 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2448,30 +2448,15 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
 
-retry:
-	if (file->f_flags & O_NONBLOCK) {
-		if (!mutex_trylock(&lli->lli_group_mutex))
-			return -EAGAIN;
-	} else
-		mutex_lock(&lli->lli_group_mutex);
-
+	read_lock(&lli->lli_lock);
 	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 		CWARN("group lock already existed with gid %lu\n",
 		      fd->fd_grouplock.lg_gid);
-		rc = -EINVAL;
-		goto out;
-	}
-	if (arg != lli->lli_group_gid && lli->lli_group_users != 0) {
-		if (file->f_flags & O_NONBLOCK) {
-			rc = -EAGAIN;
-			goto out;
-		}
-		mutex_unlock(&lli->lli_group_mutex);
-		wait_var_event(&lli->lli_group_users, !lli->lli_group_users);
-		rc = 0;
-		goto retry;
+		read_unlock(&lli->lli_lock);
+		return -EINVAL;
 	}
 	LASSERT(!fd->fd_grouplock.lg_lock);
+	read_unlock(&lli->lli_lock);
 
 	/**
 	 * XXX: group lock needs to protect all OST objects while PFL
@@ -2490,10 +2475,8 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 		u16 refcheck;
 
 		env = cl_env_get(&refcheck);
-		if (IS_ERR(env)) {
-			rc = PTR_ERR(env);
-			goto out;
-		}
+		if (IS_ERR(env))
+			return PTR_ERR(env);
 
 		rc = cl_object_layout_get(env, obj, &cl);
 		if (rc >= 0 && cl.cl_is_composite)
@@ -2502,26 +2485,28 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 
 		cl_env_put(env, &refcheck);
 		if (rc < 0)
-			goto out;
+			return rc;
 	}
 
 	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
 			      arg, (file->f_flags & O_NONBLOCK), &grouplock);
-
 	if (rc)
-		goto out;
+		return rc;
+
+	write_lock(&lli->lli_lock);
+	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
+		write_unlock(&lli->lli_lock);
+		CERROR("another thread just won the race\n");
+		cl_put_grouplock(&grouplock);
+		return -EINVAL;
+	}
 
 	fd->fd_flags |= LL_FILE_GROUP_LOCKED;
 	fd->fd_grouplock = grouplock;
-	if (lli->lli_group_users == 0)
-		lli->lli_group_gid = grouplock.lg_gid;
-	lli->lli_group_users++;
+	write_unlock(&lli->lli_lock);
 
 	CDEBUG(D_INFO, "group lock %lu obtained\n", arg);
-out:
-	mutex_unlock(&lli->lli_group_mutex);
-
-	return rc;
+	return 0;
 }
 
 static int ll_put_grouplock(struct inode *inode, struct file *file,
@@ -2530,40 +2515,31 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_file_data *fd = file->private_data;
 	struct ll_grouplock grouplock;
-	int rc;
 
-	mutex_lock(&lli->lli_group_mutex);
+	write_lock(&lli->lli_lock);
 	if (!(fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
+		write_unlock(&lli->lli_lock);
 		CWARN("no group lock held\n");
-		rc = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
+
 	LASSERT(fd->fd_grouplock.lg_lock);
 
 	if (fd->fd_grouplock.lg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
 		      arg, fd->fd_grouplock.lg_gid);
-		rc = -EINVAL;
-		goto out;
+		write_unlock(&lli->lli_lock);
+		return -EINVAL;
 	}
 
 	grouplock = fd->fd_grouplock;
 	memset(&fd->fd_grouplock, 0, sizeof(fd->fd_grouplock));
 	fd->fd_flags &= ~LL_FILE_GROUP_LOCKED;
+	write_unlock(&lli->lli_lock);
 
 	cl_put_grouplock(&grouplock);
-
-	lli->lli_group_users--;
-	if (lli->lli_group_users == 0) {
-		lli->lli_group_gid = 0;
-		wake_up_var(&lli->lli_group_users);
-	}
 	CDEBUG(D_INFO, "group lock %lu released\n", arg);
-	rc = 0;
-out:
-	mutex_unlock(&lli->lli_group_mutex);
-
-	return rc;
+	return 0;
 }
 
 /**
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6d85b96..e7e4387 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -253,9 +253,6 @@ struct ll_inode_info {
 			u64				lli_pcc_generation;
 			enum pcc_dataset_flags		lli_pcc_dsflags;
 			struct pcc_inode		*lli_pcc_inode;
-			struct mutex			lli_group_mutex;
-			u64				lli_group_users;
-			unsigned long			lli_group_gid;
 
 			u64				lli_attr_valid;
 			u64				lli_lazysize;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 81c7fa3..645fbd9 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1194,9 +1194,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_pcc_inode = NULL;
 		lli->lli_pcc_dsflags = PCC_DATASET_INVALID;
 		lli->lli_pcc_generation = 0;
-		mutex_init(&lli->lli_group_mutex);
-		lli->lli_group_users = 0;
-		lli->lli_group_gid = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index dd10949..3b22688 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1221,8 +1221,6 @@ int osc_lock_init(const struct lu_env *env,
 
 	oscl->ols_flags = osc_enq2ldlm_flags(enqflags);
 	oscl->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
-	if (lock->cll_descr.cld_mode == CLM_GROUP)
-		oscl->ols_flags |= LDLM_FL_ATOMIC_CB;
 
 	if (oscl->ols_flags & LDLM_FL_HAS_INTENT) {
 		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
