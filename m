From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:06 -0500
Subject: [lustre-devel] [PATCH 38/60] staging: lustre: llite: Adding timed
	wait in ll_umount_begin
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Rahul Deshmukh <rahul.deshmukh@seagate.com>, Lokesh Nagappa Jaliminche <lokesh.jaliminche@seagate.com>, Jian Yu <jian.yu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Rahul Deshmukh <rahul.deshmukh@seagate.com>

There exists timing race between umount and other
thread which will increment the reference count on
mnt e.g. getattr. If umount thread lose the race
then umount fails with EBUSY error. To avoid this
timed wait is added so that umount thread will wait
for user to decrement the mnt reference count.

Signed-off-by: Rahul Deshmukh <rahul.deshmukh@seagate.com>
Signed-off-by: Lokesh Nagappa Jaliminche <lokesh.jaliminche@seagate.com>
Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1882
Seagate-bug-id: MRP-1192
Reviewed-on: http://review.whamcloud.com/20061
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h |  1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 501957c..ecdfd0c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -506,6 +506,7 @@ struct ll_sb_info {
 						 */
 	/* root squash */
 	struct root_squash_info	  ll_squash;
+	struct path		 ll_mnt;
 
 	__kernel_fsid_t		  ll_fsid;
 	struct kobject		 ll_kobj; /* sysfs object */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0a87058..b229cbc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -304,6 +304,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	sb->s_magic = LL_SUPER_MAGIC;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
 	sbi->ll_namelen = osfs->os_namelen;
+	sbi->ll_mnt.mnt = current->fs->root.mnt;
 
 	if ((sbi->ll_flags & LL_SBI_USER_XATTR) &&
 	    !(data->ocd_connect_flags & OBD_CONNECT_XATTR)) {
@@ -1990,6 +1991,8 @@ void ll_umount_begin(struct super_block *sb)
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct obd_device *obd;
 	struct obd_ioctl_data *ioc_data;
+	wait_queue_head_t waitq;
+	struct l_wait_info lwi;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: superblock %p count %d active %d\n", sb,
 	       sb->s_count, atomic_read(&sb->s_active));
@@ -2022,9 +2025,14 @@ void ll_umount_begin(struct super_block *sb)
 	}
 
 	/* Really, we'd like to wait until there are no requests outstanding,
-	 * and then continue.  For now, we just invalidate the requests,
-	 * schedule() and sleep one second if needed, and hope.
+	 * and then continue. For now, we just periodically checking for vfs
+	 * to decrement mnt_cnt and hope to finish it within 10sec.
 	 */
+	init_waitqueue_head(&waitq);
+	lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(10),
+				   cfs_time_seconds(1), NULL, NULL);
+	l_wait_event(waitq, may_umount(sbi->ll_mnt.mnt), &lwi);
+
 	schedule();
 }
 
-- 
1.8.3.1
