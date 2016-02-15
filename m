From: Shalin Mehta <shalinmehta85@gmail.com>
Date: Sun, 14 Feb 2016 19:37:02 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: Fixed the parenthesis
Message-ID: <1455507422-13568-1-git-send-email-shalinmehta85@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, kernel-janitors@lists.osdl.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Shalin Mehta <shalinmehta85@gmail.com>

The parentehsis are fixed in the macro for the ldlm lock to set and
clear the flags.

Signed-off-by: Shalin Mehta <shalinmehta85@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre_dlm_flags.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 0d3ed87..4f9e9ad 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -365,10 +365,10 @@
 #define LDLM_TEST_FLAG(_l, _b)        (((_l)->l_flags & (_b)) != 0)
 
 /** set a ldlm_lock flag bit */
-#define LDLM_SET_FLAG(_l, _b)         (((_l)->l_flags |= (_b))
+#define LDLM_SET_FLAG(_l, _b)         ((_l)->l_flags |= (_b))
 
 /** clear a ldlm_lock flag bit */
-#define LDLM_CLEAR_FLAG(_l, _b)       (((_l)->l_flags &= ~(_b))
+#define LDLM_CLEAR_FLAG(_l, _b)       ((_l)->l_flags &= ~(_b))
 
 /** Mask of flags inherited from parent lock when doing intents. */
 #define LDLM_INHERIT_FLAGS            LDLM_FL_INHERIT_MASK
-- 
1.9.1
