From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:56 -0400
Subject: [lustre-devel] [PATCH 057/124] staging: lustre: statahead:
	ll_intent_drop_lock() called in spinlock
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

ll_intent_drop_lock() may sleep, which should not be called inside
spinlock.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2272
Reviewed-on: http://review.whamcloud.com/9665
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |   24 ++++++++++++++++------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index d041720..5be955d 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -661,6 +661,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	struct ll_inode_info     *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
+	__u64 handle = 0;
 	bool wakeup;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
@@ -677,6 +678,21 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
 	       entry->se_qstr.len, entry->se_qstr.name, rc);
 
+	if (rc) {
+		ll_intent_release(it);
+		iput(dir);
+		kfree(minfo);
+	} else {
+		/*
+		 * release ibits lock ASAP to avoid deadlock when statahead
+		 * thread enqueues lock on parent in readdir and another
+		 * process enqueues lock on child with parent lock held, eg.
+		 * unlink.
+		 */
+		handle = it->it_lock_handle;
+		ll_intent_drop_lock(it);
+	}
+
 	spin_lock(&lli->lli_sa_lock);
 	if (rc) {
 		wakeup = __sa_make_ready(sai, entry, rc);
@@ -689,8 +705,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 * for readpage and other tries to enqueue lock on child
 		 * with parent's lock held, for example: unlink.
 		 */
-		entry->se_handle = it->it_lock_handle;
-		ll_intent_drop_lock(it);
+		entry->se_handle = handle;
 		wakeup = !sa_has_callback(sai);
 		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
 	}
@@ -700,11 +715,6 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		wake_up(&sai->sai_thread.t_ctl_waitq);
 	spin_unlock(&lli->lli_sa_lock);
 
-	if (rc) {
-		ll_intent_release(it);
-		iput(dir);
-		kfree(minfo);
-	}
 	return rc;
 }
 
-- 
1.7.1
