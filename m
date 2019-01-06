From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:38 -0500
Subject: [lustre-devel] [PATCH 05/14] lustre: uapi: fix lustre_user.h to C++
 compatible
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Minh Diep <mdiep@whamcloud.com>

Add missing user land headers. constifiy some inline
functions.

Signed-off-by: Minh Diep <mdiep@whamcloud.com>
WC-bug-id: https://jira.hpdd.intel.com/browse/LU-4107
Reviewed-on: http://review.whamcloud.com/8033
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_user.h  | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 4412dc8..fef53b1 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -50,6 +50,8 @@
 # include <linux/version.h>
 #else /* !__KERNEL__ */
 # define NEED_QUOTA_DEFS
+# include <limits.h>
+# include <stdbool.h>
 # include <stdio.h> /* snprintf() */
 # include <string.h>
 # include <sys/quota.h>
@@ -1052,7 +1054,7 @@ enum hsm_progress_states {
 
 #define HPS_NONE	0
 
-static inline char *hsm_progress_state2name(enum hsm_progress_states s)
+static inline const char *hsm_progress_state2name(enum hsm_progress_states s)
 {
 	switch  (s) {
 	case HPS_WAITING:	return "waiting";
@@ -1114,7 +1116,7 @@ enum hsm_user_action {
 	HUA_CANCEL  = 14  /* cancel a request */
 };
 
-static inline char *hsm_user_action2name(enum hsm_user_action  a)
+static inline const char *hsm_user_action2name(enum hsm_user_action  a)
 {
 	switch  (a) {
 	case HUA_NONE:    return "NOOP";
@@ -1201,7 +1203,7 @@ enum hsm_copytool_action {
 	HSMA_CANCEL  = 23
 };
 
-static inline char *hsm_copytool_action2name(enum hsm_copytool_action  a)
+static inline const char *hsm_copytool_action2name(enum hsm_copytool_action  a)
 {
 	switch  (a) {
 	case HSMA_NONE:    return "NOOP";
@@ -1294,9 +1296,10 @@ static inline struct hsm_action_item *hai_next(struct hsm_action_item *hai)
 }
 
 /* Return size of an hsm_action_list */
-static inline int hal_size(struct hsm_action_list *hal)
+static inline size_t hal_size(struct hsm_action_list *hal)
 {
-	int i, sz;
+	__u32 i;
+	size_t sz;
 	struct hsm_action_item *hai;
 
 	sz = sizeof(*hal) + cfs_size_round(strlen(hal->hal_fsname) + 1);
-- 
1.8.3.1
