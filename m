From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:20 -0500
Subject: [lustre-devel] [PATCH 13/22] staging: lustre: statahead: set
	sai_index_wait with lli_sa_lock held
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

It is the sponsor thread of the statahead thread to update the
sai::sai_index_wait. Originally, it didn't hold the lli_sa_lock
when did that. Becuase of out-of-order execution others may miss
to wakeup such thread.

On the other hand, if the statahead RPC gets failure, it should
wakeup the sponsor thread, not the statahead thread.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7828
Reviewed-on: http://review.whamcloud.com/18499
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index b43955f..4769a22 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -659,8 +659,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	struct ll_inode_info     *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
+	wait_queue_head_t *waitq = NULL;
 	__u64 handle = 0;
-	bool wakeup;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		rc = -ENOENT;
@@ -693,7 +693,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 
 	spin_lock(&lli->lli_sa_lock);
 	if (rc) {
-		wakeup = __sa_make_ready(sai, entry, rc);
+		if (__sa_make_ready(sai, entry, rc))
+			waitq = &sai->sai_waitq;
 	} else {
 		entry->se_minfo = minfo;
 		entry->se_req = ptlrpc_request_addref(req);
@@ -704,13 +705,15 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 * with parent's lock held, for example: unlink.
 		 */
 		entry->se_handle = handle;
-		wakeup = !sa_has_callback(sai);
+		if (!sa_has_callback(sai))
+			waitq = &sai->sai_thread.t_ctl_waitq;
+
 		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
 	}
 	sai->sai_replied++;
 
-	if (wakeup)
-		wake_up(&sai->sai_thread.t_ctl_waitq);
+	if (waitq)
+		wake_up(waitq);
 	spin_unlock(&lli->lli_sa_lock);
 
 	return rc;
@@ -1397,10 +1400,10 @@ static int revalidate_statahead_dentry(struct inode *dir,
 				       struct dentry **dentryp,
 				       bool unplug)
 {
+	struct ll_inode_info *lli = ll_i2info(dir);
 	struct sa_entry *entry = NULL;
 	struct l_wait_info lwi = { 0 };
 	struct ll_dentry_data *ldd;
-	struct ll_inode_info *lli;
 	int rc = 0;
 
 	if ((*dentryp)->d_name.name[0] == '.') {
@@ -1446,7 +1449,9 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		sa_handle_callback(sai);
 
 	if (!sa_ready(entry)) {
+		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
+		spin_unlock(&lli->lli_sa_lock);
 		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
 				       LWI_ON_SIGNAL_NOOP, NULL);
 		rc = l_wait_event(sai->sai_waitq, sa_ready(entry), &lwi);
@@ -1514,7 +1519,6 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	 * dentry_may_statahead().
 	 */
 	ldd = ll_d2d(*dentryp);
-	lli = ll_i2info(dir);
 	/* ldd can be NULL if llite lookup failed. */
 	if (ldd)
 		ldd->lld_sa_generation = lli->lli_sa_generation;
-- 
1.7.1
