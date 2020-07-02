From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:51 -0400
Subject: [lustre-devel] [PATCH 11/18] lustre: llite: truncate deadlock with
 DoM files
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

All MDT intent RPCs are sent with inode mutex locked
while read/write and setattr unlocks inode mutex on entry,
takes LDLM lock and locks inode mutex again and sends the RPC.
So a deadlock can occur since LDLM lock is the same in case of DoM.

In fact read/write and setattr takes lli_trunc_sem, so
inode mutex can be ommited in truncate case.

Replace inode_lock with new lli_setattr_mutex to keep protection
from concurrent setattr time updates.

HPE-bug-id: LUS-8455
WC-bug-id: https://jira.whamcloud.com/browse/LU-13467
Lustre-commit: 8958ecee22010 ("LU-13467 llite: truncate deadlock with DoM files")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/38288
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 1 +
 fs/lustre/llite/llite_lib.c      | 1 +
 fs/lustre/llite/vvp_io.c         | 8 ++++----
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a688bd8..2556dd8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -191,6 +191,7 @@ struct ll_inode_info {
 			char			       *lli_symlink_name;
 			struct ll_trunc_sem		lli_trunc_sem;
 			struct range_lock_tree		lli_write_tree;
+			struct mutex			lli_setattr_mutex;
 
 			struct rw_semaphore		lli_glimpse_sem;
 			ktime_t				lli_glimpse_time;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 0db9eae..b30feb0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1014,6 +1014,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		init_rwsem(&lli->lli_lsm_sem);
 	} else {
 		mutex_init(&lli->lli_size_mutex);
+		mutex_init(&lli->lli_setattr_mutex);
 		lli->lli_symlink_name = NULL;
 		ll_trunc_sem_init(&lli->lli_trunc_sem);
 		range_lock_tree_init(&lli->lli_write_tree);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 8df5d39..8edd3c1 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -702,13 +702,13 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 
 	if (cl_io_is_trunc(io)) {
 		trunc_sem_down_write(&lli->lli_trunc_sem);
-		inode_lock(inode);
+		mutex_lock(&lli->lli_setattr_mutex);
 		inode_dio_wait(inode);
 	} else if (cl_io_is_fallocate(io)) {
 		inode_lock(inode);
 		inode_dio_wait(inode);
 	} else {
-		inode_lock(inode);
+		mutex_lock(&lli->lli_setattr_mutex);
 	}
 
 	if (io->u.ci_setattr.sa_avalid & TIMES_SET_FLAGS)
@@ -729,12 +729,12 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		 * because osc has already notified to destroy osc_extents.
 		 */
 		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
-		inode_unlock(inode);
+		mutex_unlock(&lli->lli_setattr_mutex);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else if (cl_io_is_fallocate(io)) {
 		inode_unlock(inode);
 	} else {
-		inode_unlock(inode);
+		mutex_unlock(&lli->lli_setattr_mutex);
 	}
 }
 
-- 
1.8.3.1
