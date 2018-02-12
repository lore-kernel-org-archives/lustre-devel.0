From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 10:47:59 +1100
Subject: [lustre-devel] [PATCH 09/19] staging: lustre: open code polling
 loop instead of using l_wait_event()
In-Reply-To: <151847037709.22826.16175867257667686132.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
Message-ID: <151847927897.19840.8283814090245785502.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Two places that LWI_TIMEOUT_INTERVAL() is used, the outcome is a
simple polling loop that polls every second for some event (with a
limit).

So write a simple loop to make this more apparent.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |   11 +++++------
 drivers/staging/lustre/lustre/lov/lov_request.c |   12 +++++-------
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ccb614bd7f53..9e96a8ee1783 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1984,8 +1984,7 @@ void ll_umount_begin(struct super_block *sb)
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct obd_device *obd;
 	struct obd_ioctl_data *ioc_data;
-	wait_queue_head_t waitq;
-	struct l_wait_info lwi;
+	int cnt = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: superblock %p count %d active %d\n", sb,
 	       sb->s_count, atomic_read(&sb->s_active));
@@ -2021,10 +2020,10 @@ void ll_umount_begin(struct super_block *sb)
 	 * and then continue. For now, we just periodically checking for vfs
 	 * to decrement mnt_cnt and hope to finish it within 10sec.
 	 */
-	init_waitqueue_head(&waitq);
-	lwi = LWI_TIMEOUT_INTERVAL(10 * HZ,
-				   HZ, NULL, NULL);
-	l_wait_event(waitq, may_umount(sbi->ll_mnt.mnt), &lwi);
+	while (cnt < 10 && !may_umount(sbi->ll_mnt.mnt)) {
+		schedule_timeout_uninterruptible(HZ);
+		cnt ++;
+	}
 
 	schedule();
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index fb3b7a7fa32a..c1e58fcc30b3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -99,8 +99,7 @@ static int lov_check_set(struct lov_obd *lov, int idx)
  */
 static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 {
-	wait_queue_head_t waitq;
-	struct l_wait_info lwi;
+	int cnt = 0;
 	struct lov_tgt_desc *tgt;
 	int rc = 0;
 
@@ -125,11 +124,10 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 
 	mutex_unlock(&lov->lov_lock);
 
-	init_waitqueue_head(&waitq);
-	lwi = LWI_TIMEOUT_INTERVAL(obd_timeout * HZ,
-				   HZ, NULL, NULL);
-
-	rc = l_wait_event(waitq, lov_check_set(lov, ost_idx), &lwi);
+	while (cnt < obd_timeout && !lov_check_set(lov, ost_idx)) {
+		schedule_timeout_uninterruptible(HZ);
+		cnt ++;
+	}
 	if (tgt->ltd_active)
 		return 1;
 
