From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:51 -0500
Subject: [lustre-devel] [PATCH 003/622] lustre: uapi: remove enum
 hsm_progress_states
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This enum is used only by server side code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 0566afad..f5474c5 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1532,27 +1532,6 @@ enum hsm_states {
  */
 #define HSM_FLAGS_MASK  (HSM_USER_MASK | HSM_STATUS_MASK)
 
-/**
- * HSM??request progress state
- */
-enum hsm_progress_states {
-	HPS_WAITING	= 1,
-	HPS_RUNNING	= 2,
-	HPS_DONE	= 3,
-};
-
-#define HPS_NONE	0
-
-static inline const char *hsm_progress_state2name(enum hsm_progress_states s)
-{
-	switch  (s) {
-	case HPS_WAITING:	return "waiting";
-	case HPS_RUNNING:	return "running";
-	case HPS_DONE:		return "done";
-	default:		return "unknown";
-	}
-}
-
 struct hsm_extent {
 	__u64 offset;
 	__u64 length;
-- 
1.8.3.1
