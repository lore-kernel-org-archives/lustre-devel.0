From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:49 -0400
Subject: [lustre-devel] [PATCH 09/18] lustre: llite: bind kthread thread to
 accepted node set
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Bind both the agl and statahead kernel threads to a node that is
apart of the cpt table that Lustre use. This limits the polluting
of the cache of HPC applications.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9441
Lustre-commit: d6e103e6950d9 ("LU-9441 llite: bind kthread thread to accepted node set")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/38730
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/statahead.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index fb25520..895e496 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -39,6 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
+#include <linux/libcfs/libcfs_cpu.h>
 #include <obd_support.h>
 #include <lustre_dlm.h>
 #include "llite_internal.h"
@@ -954,6 +955,7 @@ static void ll_stop_agl(struct ll_statahead_info *sai)
 /* start agl thread */
 static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 {
+	int node = cfs_cpt_spread_node(cfs_cpt_tab, CFS_CPT_ANY);
 	struct ll_inode_info *plli;
 	struct task_struct *task;
 
@@ -961,8 +963,8 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 	       sai, parent);
 
 	plli = ll_i2info(d_inode(parent));
-	task = kthread_create(ll_agl_thread, parent, "ll_agl_%u",
-			      plli->lli_opendir_pid);
+	task = kthread_create_on_node(ll_agl_thread, parent, node, "ll_agl_%u",
+				      plli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
 		sai->sai_agl_valid = 0;
@@ -1535,6 +1537,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 				  bool agl)
 {
+	int node = cfs_cpt_spread_node(cfs_cpt_tab, CFS_CPT_ANY);
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = NULL;
 	struct task_struct *task;
@@ -1586,8 +1589,8 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 	CDEBUG(D_READA, "start statahead thread: [pid %d] [parent %pd]\n",
 	       current->pid, parent);
 
-	task = kthread_create(ll_statahead_thread, parent, "ll_sa_%u",
-			      lli->lli_opendir_pid);
+	task = kthread_create_on_node(ll_statahead_thread, parent, node,
+				      "ll_sa_%u", lli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		spin_lock(&lli->lli_sa_lock);
 		lli->lli_sai = NULL;
-- 
1.8.3.1
