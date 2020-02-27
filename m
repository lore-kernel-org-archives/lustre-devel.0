From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:00 -0500
Subject: [lustre-devel] [PATCH 012/622] lustre: lov: protected ost pool
 count updation
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jadhav Vikram <jadhav.vikram@seagate.com>

ASSERTION(iter->lpi_idx <= ((iter->lpi_pool)->pool_obds.op_count)
caused due to reading of ost pool count is not protected in
pool_proc_next and pool_proc_show, pool_proc_show get called when
op_count was zero.

Fix to protect ost pool count by taking lock at start sequence
function pool_proc_start and released lock in pool_proc_stop.
Rather than using down_read / up_read pairs around pool_proc_next
and pool_proc_show, this changes make sure ost pool data gets
protected throughout sequence operation.

Seagate-bug-id: MRP-3629
WC-bug-id: https://jira.whamcloud.com/browse/LU-9620
Lustre-commit: 61c803319b91 ("LU-9620 lod: protected ost pool count updation")
Signed-off-by: Jadhav Vikram <jadhav.vikram@seagate.com>
Reviewed-by: Ashish Purkar <ashish.purkar@seagate.com>
Reviewed-by: Vladimir Saveliev <vladimir.saveliev@seagate.com>
Reviewed-on: https://review.whamcloud.com/27506
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pool.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 60565b9..a0552fb 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -117,14 +117,11 @@ static void *pool_proc_next(struct seq_file *s, void *v, loff_t *pos)
 
 	/* iterate to find a non empty entry */
 	prev_idx = iter->idx;
-	down_read(&pool_tgt_rw_sem(iter->pool));
 	iter->idx++;
-	if (iter->idx == pool_tgt_count(iter->pool)) {
+	if (iter->idx >= pool_tgt_count(iter->pool)) {
 		iter->idx = prev_idx; /* we stay on the last entry */
-		up_read(&pool_tgt_rw_sem(iter->pool));
 		return NULL;
 	}
-	up_read(&pool_tgt_rw_sem(iter->pool));
 	(*pos)++;
 	/* return != NULL to continue */
 	return iter;
@@ -157,6 +154,7 @@ static void *pool_proc_start(struct seq_file *s, loff_t *pos)
 	 */
 	/* /!\ do not forget to restore it to pool before freeing it */
 	s->private = iter;
+	down_read(&pool_tgt_rw_sem(pool));
 	if (*pos > 0) {
 		loff_t i;
 		void *ptr;
@@ -179,6 +177,7 @@ static void pool_proc_stop(struct seq_file *s, void *v)
 	 * we have to free only if s->private is an iterator
 	 */
 	if ((iter) && (iter->magic == POOL_IT_MAGIC)) {
+		up_read(&pool_tgt_rw_sem(iter->pool));
 		/* we restore s->private so next call to pool_proc_start()
 		 * will work
 		 */
@@ -197,9 +196,7 @@ static int pool_proc_show(struct seq_file *s, void *v)
 	LASSERT(iter->pool);
 	LASSERT(iter->idx <= pool_tgt_count(iter->pool));
 
-	down_read(&pool_tgt_rw_sem(iter->pool));
 	tgt = pool_tgt(iter->pool, iter->idx);
-	up_read(&pool_tgt_rw_sem(iter->pool));
 	if (tgt)
 		seq_printf(s, "%s\n", obd_uuid2str(&tgt->ltd_uuid));
 
-- 
1.8.3.1
