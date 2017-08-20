From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:00 -0400
Subject: [lustre-devel] [PATCH 06/64 v2] staging: lustre: uapi: remove
	unused function in lustre_disk.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Delete code that is used by only the server or just in user
land. Now this file is a normal kernel header. The UAPI
version of this header is only needed for server side so
no need to create a new header in uapi directory.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/25194
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_disk.h | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index a676bcc..1a532ad 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -108,14 +108,6 @@ struct lustre_mount_data {
 
 #define lmd_is_client(x) ((x)->lmd_flags & LMD_FLG_CLIENT)
 
-/****************** last_rcvd file *********************/
-
-/** version recovery epoch */
-#define LR_EPOCH_BITS   32
-#define lr_epoch(a) ((a) >> LR_EPOCH_BITS)
-#define LR_EXPIRE_INTERVALS 16 /**< number of intervals to track transno */
-#define ENOENT_VERSION 1 /** 'virtual' version of non-existent object */
-
 /****************** superblock additional info *********************/
 
 struct ll_sb_info;
@@ -141,16 +133,6 @@ struct lustre_sb_info {
 #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
 
 #define     get_profile_name(sb)   (s2lsi(sb)->lsi_lmd->lmd_profile)
-#define	    get_mount_flags(sb)	   (s2lsi(sb)->lsi_lmd->lmd_flags)
-#define	    get_mntdev_name(sb)	   (s2lsi(sb)->lsi_lmd->lmd_dev)
-
-/****************** mount lookup info *********************/
-
-struct lustre_mount_info {
-	char		 *lmi_name;
-	struct super_block   *lmi_sb;
-	struct list_head	    lmi_list_chain;
-};
 
 /****************** prototypes *********************/
 
-- 
1.8.3.1
