From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:39 -0500
Subject: [lustre-devel] [PATCH 06/14] lustre: uapi: replace cfs_size_*
 macros with __ALIGN_KERNEL
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The lustre specific cfs_size_* macros can be easily replaced with
the __ALIGN_KERNEL macro provided by the linux kernel for our
user land code. This brings us closer to building against the
upstream client.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/30379
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 32 +++++++++-------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index fef53b1..aac91a1 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -42,6 +42,9 @@
  * @{
  */
 
+#include <linux/kernel.h>
+#include <linux/types.h>
+
 #ifdef __KERNEL__
 # include <linux/fs.h>
 # include <linux/quota.h>
@@ -835,8 +838,8 @@ enum changelog_send_flag {
 	CHANGELOG_FLAG_JOBID	= 0x04,
 };
 
-#define CR_MAXSIZE cfs_size_round(2 * NAME_MAX + 2 + \
-				  changelog_rec_offset(CLF_SUPPORTED))
+#define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
+				  changelog_rec_offset(CLF_SUPPORTED), 8)
 
 /* 31 usable bytes string + null terminator. */
 #define LUSTRE_JOBID_SIZE	32
@@ -1270,29 +1273,20 @@ struct hsm_action_list {
 	 */
 } __packed;
 
-#ifndef HAVE_CFS_SIZE_ROUND
-static inline int cfs_size_round(int val)
-{
-	return (val + 7) & (~0x7);
-}
-
-#define HAVE_CFS_SIZE_ROUND
-#endif
-
 /* Return pointer to first hai in action list */
 static inline struct hsm_action_item *hai_first(struct hsm_action_list *hal)
 {
-	return (struct hsm_action_item *)(hal->hal_fsname +
-					  cfs_size_round(strlen(hal-> \
-								hal_fsname)
-							 + 1));
+	size_t offset = __ALIGN_KERNEL(strlen(hal->hal_fsname) + 1, 8);
+
+	return (struct hsm_action_item *)(hal->hal_fsname + offset);
 }
 
 /* Return pointer to next hai */
 static inline struct hsm_action_item *hai_next(struct hsm_action_item *hai)
 {
-	return (struct hsm_action_item *)((char *)hai +
-					  cfs_size_round(hai->hai_len));
+	size_t offset = __ALIGN_KERNEL(hai->hai_len, 8);
+
+	return (struct hsm_action_item *)((char *)hai + offset);
 }
 
 /* Return size of an hsm_action_list */
@@ -1302,10 +1296,10 @@ static inline size_t hal_size(struct hsm_action_list *hal)
 	size_t sz;
 	struct hsm_action_item *hai;
 
-	sz = sizeof(*hal) + cfs_size_round(strlen(hal->hal_fsname) + 1);
+	sz = sizeof(*hal) + __ALIGN_KERNEL(strlen(hal->hal_fsname) + 1, 8);
 	hai = hai_first(hal);
 	for (i = 0; i < hal->hal_count; i++, hai = hai_next(hai))
-		sz += cfs_size_round(hai->hai_len);
+		sz += __ALIGN_KERNEL(hai->hai_len, 8);
 
 	return sz;
 }
-- 
1.8.3.1
