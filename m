From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:23 -0500
Subject: [lustre-devel] [PATCH 515/622] lustre: llite: move agl_thread
 cleanup out of thread.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-516-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

When we start a thread with kthread_create() and later stop
it with kthread_stop(), there is no guarantee that the thread
function runs at all.  So it is not safe to leave cleanup
to the thread.

So move the cleanup code to a separate function which
stops the thread and then cleans up.

Fixes: c044fb0f835c ("staging: lustre: remove 'ptlrpc_thread usage' for sai_agl_thread")
Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/llite/statahead.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 497aba3..1639408 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -915,7 +915,19 @@ static int ll_agl_thread(void *arg)
 			schedule();
 		__set_current_state(TASK_RUNNING);
 	}
+	return 0;
+}
+
+static void ll_stop_agl(struct ll_statahead_info *sai)
+{
+	struct ll_inode_info *plli = ll_i2info(sai->sai_dentry->d_inode);
+	struct ll_inode_info *clli;
 
+	CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
+	       sai, (unsigned int)sai->sai_agl_task->pid);
+	kthread_stop(sai->sai_agl_task);
+
+	sai->sai_agl_task = NULL;
 	spin_lock(&plli->lli_agl_lock);
 	sai->sai_agl_valid = 0;
 	while ((clli = list_first_entry_or_null(&sai->sai_agls,
@@ -929,9 +941,8 @@ static int ll_agl_thread(void *arg)
 	}
 	spin_unlock(&plli->lli_agl_lock);
 	CDEBUG(D_READA, "agl thread stopped: sai %p, parent %pd\n",
-	       sai, parent);
+	       sai, sai->sai_dentry);
 	ll_sai_put(sai);
-	return 0;
 }
 
 /* start agl thread */
@@ -1134,13 +1145,9 @@ static int ll_statahead_thread(void *arg)
 		__set_current_state(TASK_RUNNING);
 	}
 out:
-	if (sai->sai_agl_task) {
-		kthread_stop(sai->sai_agl_task);
+	if (sai->sai_agl_task)
+		ll_stop_agl(sai);
 
-		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
-		       sai, (unsigned int)sai->sai_agl_task->pid);
-		sai->sai_agl_task = NULL;
-	}
 	/*
 	 * wait for inflight statahead RPCs to finish, and then we can free sai
 	 * safely because statahead RPC will access sai data
-- 
1.8.3.1
