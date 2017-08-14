From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:11 -0400
Subject: [lustre-devel] [PATCH 43/64] staging: lustre: uapi: use proper
	byteorder functions in lustre_idl.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

In order for lustre_idl.h to be usable for both user
land and kernel space it has to use the proper
byteorder functions.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/16916
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_idl.h   | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index b7c1a1e..9613f7c 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -67,6 +67,7 @@
 #ifndef _LUSTRE_IDL_H_
 #define _LUSTRE_IDL_H_
 
+#include <asm/byteorder.h>
 #include <linux/types.h>
 
 #include "../lnet/lnet-types.h"
@@ -389,7 +390,7 @@ enum lu_dirpage_flags {
 
 static inline struct lu_dirent *lu_dirent_start(struct lu_dirpage *dp)
 {
-	if (le32_to_cpu(dp->ldp_flags) & LDF_EMPTY)
+	if (__le32_to_cpu(dp->ldp_flags) & LDF_EMPTY)
 		return NULL;
 	else
 		return dp->ldp_entries;
@@ -399,8 +400,8 @@ static inline struct lu_dirent *lu_dirent_next(struct lu_dirent *ent)
 {
 	struct lu_dirent *next;
 
-	if (le16_to_cpu(ent->lde_reclen) != 0)
-		next = ((void *)ent) + le16_to_cpu(ent->lde_reclen);
+	if (__le16_to_cpu(ent->lde_reclen) != 0)
+		next = ((void *)ent) + __le16_to_cpu(ent->lde_reclen);
 	else
 		next = NULL;
 
@@ -1840,11 +1841,11 @@ static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 
 static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 {
-	switch (le32_to_cpu(lmm->lmv_magic)) {
+	switch (__le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
-		return le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
+		return __le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
 	case LMV_USER_MAGIC:
-		return le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
+		return __le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
 	default:
 		return -EINVAL;
 	}
-- 
1.8.3.1
