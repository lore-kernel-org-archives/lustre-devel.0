From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:15 -0400
Subject: [lustre-devel] [PATCH 25/28] lustre: llite: disable statahead if
 starting statahead fail
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Once starting statahead thread fails, it should disable statahead.
Current code only does this when "sai != NULL", instead it should
check whether current process is opening this dir, so for cases
like current file is not the first dirent, or sai allocation fail,
it won't retry statahead.

Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10165
Reviewed-on: https://review.whamcloud.com/29817
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 0174a4c..8f3ff7f 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1512,6 +1512,9 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	task = kthread_create(ll_statahead_thread, parent, "ll_sa_%u",
 			      lli->lli_opendir_pid);
 	if (IS_ERR(task)) {
+		spin_lock(&lli->lli_sa_lock);
+		lli->lli_sai = NULL;
+		spin_unlock(&lli->lli_sa_lock);
 		rc = PTR_ERR(task);
 		CERROR("can't start ll_sa thread, rc : %d\n", rc);
 		goto out;
@@ -1537,8 +1540,8 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	 * that subsequent stat won't waste time to try it.
 	 */
 	spin_lock(&lli->lli_sa_lock);
-	lli->lli_sa_enabled = 0;
-	lli->lli_sai = NULL;
+	if (lli->lli_opendir_pid == current->pid)
+		lli->lli_sa_enabled = 0;
 	spin_unlock(&lli->lli_sa_lock);
 	if (sai)
 		ll_sai_free(sai);
-- 
1.8.3.1
