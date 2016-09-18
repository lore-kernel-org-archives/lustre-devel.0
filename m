From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:57 -0400
Subject: [lustre-devel] [PATCH 058/124] staging: lustre: statahead: race in
	start/stop statahead
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

When starting statahead thread, it should check whether current
lli_opendir_key was deauthorized in the mean time by another
process.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3270
Reviewed-on: http://review.whamcloud.com/9666
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |   29 +++++++++++++++++++---
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 5be955d..70ca252 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1509,7 +1509,24 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	CDEBUG(D_READA, "start statahead thread: sai %p, parent %pd\n",
 	       sai, parent);
 
+	/*
+	 * if another process started statahead thread, or deauthorized current
+	 * lli_opendir_key, don't start statahead.
+	 */
+	spin_lock(&lli->lli_sa_lock);
+	if (unlikely(lli->lli_sai || lli->lli_opendir_key ||
+		     lli->lli_opendir_pid != current->pid)) {
+		spin_unlock(&lli->lli_sa_lock);
+
+		dput(parent);
+		iput(sai->sai_inode);
+		rc = -EAGAIN;
+		goto out;
+	}
 	lli->lli_sai = sai;
+	spin_unlock(&lli->lli_sa_lock);
+
+	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_running);
 
 	task = kthread_run(ll_statahead_thread, parent, "ll_sa_%u",
 			   lli->lli_opendir_pid);
@@ -1518,9 +1535,12 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 		rc = PTR_ERR(task);
 		CERROR("cannot start ll_sa thread: rc = %d\n", rc);
 		dput(parent);
-		lli->lli_opendir_key = NULL;
+
+		spin_lock(&lli->lli_sa_lock);
 		thread_set_flags(thread, SVC_STOPPED);
 		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
+		spin_unlock(&lli->lli_sa_lock);
+
 		ll_sai_put(sai);
 		LASSERT(!lli->lli_sai);
 		return -EAGAIN;
@@ -1529,7 +1549,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	l_wait_event(thread->t_ctl_waitq,
 		     thread_is_running(thread) || thread_is_stopped(thread),
 		     &lwi);
-	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_sa_running);
 	ll_sai_put(sai);
 
 	/*
@@ -1540,9 +1559,11 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 
 out:
 	kfree(sai);
+	/*
+	 * once we start statahead thread failed, disable statahead so
+	 * subsequent won't waste time to try it.
+	 */
 	spin_lock(&lli->lli_sa_lock);
-	lli->lli_opendir_key = NULL;
-	lli->lli_opendir_pid = 0;
 	lli->lli_sa_enabled = 0;
 	spin_unlock(&lli->lli_sa_lock);
 
-- 
1.7.1
