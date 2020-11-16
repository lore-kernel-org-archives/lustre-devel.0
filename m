From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:35 -0500
Subject: [lustre-devel] [PATCH 02/28] lustre: llite: disable statahead_agl
 for sanity test_56ra
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The sanity test_56ra can fail because statahead_agl can cause extra
glimpse request.

If a stat() systemcall is made after an AGL glimpse request is sent,
but before the reply has been received, the code handling the stat
cannot see that glimpse request and so will send another.  This
elevates the number of requests counted.

There is a parameter (statahead_agl) which make it easy to disable the
AGL, but it isn't implemented properly.  Specifically, inodes can
still be added to the sai_agls list when agl is disabled.  They will
never be removed, which causes an assertion to fail.

To clean this up, remove the sai_agl_valid flag, and use a test on
sai_task being non-NULL instead.  Also check agl_should_run() while
locked against ->sai_task changing, and before adding anything
to lli_agl_list.

We don't need the 'added' variable.  It is perfectly OK to wake_up the
sai_agl_task *before* adding to the list as long is that is all done
under the lock.  The task will wait for the lock before checking the
list, so it won't see it being empty.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13017
Lustre-commit: 3e04c4f0757c22 ("LU-13017 tests: disable statahead_agl for sanity test_56ra")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39667
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 -
 fs/lustre/llite/statahead.c      | 31 +++++++++++++------------------
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 0bd6795..9d988aac 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1398,7 +1398,6 @@ struct ll_statahead_info {
 	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
 					     * hidden entries
 					     */
-				sai_agl_valid:1,/* AGL is valid for the dir */
 				sai_in_readpage:1;/* statahead in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct task_struct     *sai_task;       /* stat-ahead thread */
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 895e496..a7d3a43 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -129,7 +129,7 @@ static inline int sa_hash(int val)
 static inline int agl_should_run(struct ll_statahead_info *sai,
 				 struct inode *inode)
 {
-	return (inode && S_ISREG(inode->i_mode) && sai->sai_agl_valid);
+	return inode && S_ISREG(inode->i_mode) && sai->sai_agl_task;
 }
 
 /* statahead window is full */
@@ -424,7 +424,6 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 {
 	struct ll_inode_info *child = ll_i2info(inode);
 	struct ll_inode_info *parent = ll_i2info(sai->sai_dentry->d_inode);
-	int added = 0;
 
 	spin_lock(&child->lli_agl_lock);
 	if (child->lli_agl_index == 0) {
@@ -433,18 +432,20 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 
 		LASSERT(list_empty(&child->lli_agl_list));
 
-		igrab(inode);
 		spin_lock(&parent->lli_agl_lock);
-		if (list_empty(&sai->sai_agls))
-			added = 1;
-		list_add_tail(&child->lli_agl_list, &sai->sai_agls);
+		/* Re-check under the lock */
+		if (agl_should_run(sai, inode)) {
+			if (list_empty(&sai->sai_agls))
+				wake_up_process(sai->sai_agl_task);
+			igrab(inode);
+			list_add_tail(&child->lli_agl_list, &sai->sai_agls);
+		} else {
+			child->lli_agl_index = 0;
+		}
 		spin_unlock(&parent->lli_agl_lock);
 	} else {
 		spin_unlock(&child->lli_agl_lock);
 	}
-
-	if (added > 0)
-		wake_up_process(sai->sai_agl_task);
 }
 
 /* allocate sai */
@@ -936,7 +937,6 @@ static void ll_stop_agl(struct ll_statahead_info *sai)
 
 	sai->sai_agl_task = NULL;
 	spin_lock(&plli->lli_agl_lock);
-	sai->sai_agl_valid = 0;
 	while ((clli = list_first_entry_or_null(&sai->sai_agls,
 						struct ll_inode_info,
 						lli_agl_list)) != NULL) {
@@ -967,16 +967,11 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 				      plli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
-		sai->sai_agl_valid = 0;
 		return;
 	}
 
 	sai->sai_agl_task = task;
-	LASSERT(sai->sai_agl_valid == 1);
 	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_agl_total);
-	spin_lock(&plli->lli_agl_lock);
-	sai->sai_agl_valid = 1;
-	spin_unlock(&plli->lli_agl_lock);
 	/* Get an extra reference that the thread holds */
 	ll_sai_get(d_inode(parent));
 
@@ -1569,7 +1564,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 	}
 
 	sai->sai_ls_all = (first == LS_FIRST_DOT_DE);
-	sai->sai_agl_valid = agl;
 
 	/*
 	 * if current lli_opendir_key was deauthorized, or dir re-opened by
@@ -1643,10 +1637,11 @@ static inline bool ll_statahead_started(struct inode *dir, bool agl)
 
 	spin_lock(&lli->lli_sa_lock);
 	sai = lli->lli_sai;
-	if (sai && sai->sai_agl_valid != agl)
+	if (sai && (sai->sai_agl_task != NULL) != agl)
 		CDEBUG(D_READA,
 		       "%s: Statahead AGL hint changed from %d to %d\n",
-		       ll_i2sbi(dir)->ll_fsname, sai->sai_agl_valid, agl);
+		       ll_i2sbi(dir)->ll_fsname,
+		       sai->sai_agl_task != NULL, agl);
 	spin_unlock(&lli->lli_sa_lock);
 
 	return !!sai;
-- 
1.8.3.1
