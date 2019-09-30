From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:51 -0400
Subject: [lustre-devel] [PATCH 092/151] lustre: llite: change
 lli_glimpse_time to ktime
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-93-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently lli_glimpse_time is in jiffies which can vary between
platforms. Migrate to ktime since we need more than second
time resolution that is consistent on any platform. Replace the
last cfs_time_current_sec() with ktime_get_real_seconds().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: 9a484620bdd9 ("LU-9019 llite: change lli_glimpse_time to ktime")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/30601
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 4 ++--
 fs/lustre/llite/llite_lib.c      | 2 +-
 fs/lustre/llite/statahead.c      | 9 +++++----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a44aec06..bdc90bb 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -194,7 +194,7 @@ struct ll_inode_info {
 			struct range_lock_tree		lli_write_tree;
 
 			struct rw_semaphore		lli_glimpse_sem;
-			unsigned long			lli_glimpse_time;
+			ktime_t				lli_glimpse_time;
 			struct list_head		lli_agl_list;
 			u64				lli_agl_index;
 
@@ -1193,7 +1193,7 @@ static inline int ll_glimpse_size(struct inode *inode)
 
 	down_read(&lli->lli_glimpse_sem);
 	rc = cl_glimpse_size(inode);
-	lli->lli_glimpse_time = jiffies;
+	lli->lli_glimpse_time = ktime_get();
 	up_read(&lli->lli_glimpse_sem);
 	return rc;
 }
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 12a68873..9e4c797 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -926,7 +926,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		init_rwsem(&lli->lli_trunc_sem);
 		range_lock_tree_init(&lli->lli_write_tree);
 		init_rwsem(&lli->lli_glimpse_sem);
-		lli->lli_glimpse_time = 0;
+		lli->lli_glimpse_time = ktime_set(0, 0);
 		INIT_LIST_HEAD(&lli->lli_agl_list);
 		lli->lli_agl_index = 0;
 		lli->lli_async_rc = 0;
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 8fc4471..2b7015d 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -494,10 +494,10 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	u64 index = lli->lli_agl_index;
+	ktime_t expire;
 	int rc;
 
 	LASSERT(list_empty(&lli->lli_agl_list));
-
 	/* AGL maybe fall behind statahead with one entry */
 	if (is_omitted_entry(sai, index + 1)) {
 		lli->lli_agl_index = 0;
@@ -539,8 +539,9 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	 *    relative rare. AGL can ignore such case, and it will not muchly
 	 *    affect the performance.
 	 */
-	if (lli->lli_glimpse_time != 0 &&
-	    time_before(jiffies - 1 * HZ, lli->lli_glimpse_time)) {
+	expire = ktime_sub_ns(ktime_get(), NSEC_PER_SEC);
+	if (ktime_to_ns(lli->lli_glimpse_time) &&
+	    ktime_before(expire, lli->lli_glimpse_time)) {
 		up_write(&lli->lli_glimpse_sem);
 		lli->lli_agl_index = 0;
 		iput(inode);
@@ -552,7 +553,7 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 
 	cl_agl(inode);
 	lli->lli_agl_index = 0;
-	lli->lli_glimpse_time = jiffies;
+	lli->lli_glimpse_time = ktime_get();
 	up_write(&lli->lli_glimpse_sem);
 
 	CDEBUG(D_READA, "Handled (init) async glimpse: inode= "
-- 
1.8.3.1
