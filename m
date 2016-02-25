From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:47 -0500
Subject: [lustre-devel] [PATCH v2 64/84] staging/lustre: Remove unused
	lustre_build_lock_params()
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-65-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

And also struct lustre_rw_params that is only referenced by it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_lite.h    | 48 ----------------------
 1 file changed, 48 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index f6d7aae..9852325 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -53,54 +53,6 @@
 #define LL_MAX_BLKSIZE_BITS     (22)
 #define LL_MAX_BLKSIZE	  (1UL<<LL_MAX_BLKSIZE_BITS)
 
-#include "lustre/lustre_user.h"
-
-struct lustre_rw_params {
-	int		lrp_lock_mode;
-	ldlm_policy_data_t lrp_policy;
-	u32		lrp_brw_flags;
-	int		lrp_ast_flags;
-};
-
-/*
- * XXX nikita: this function lives in the header because it is used by both
- * llite kernel module and liblustre library, and there is no (?) better place
- * to put it in.
- */
-static inline void lustre_build_lock_params(int cmd, unsigned long open_flags,
-					    __u64 connect_flags,
-					    loff_t pos, ssize_t len,
-					    struct lustre_rw_params *params)
-{
-	params->lrp_lock_mode = (cmd == OBD_BRW_READ) ? LCK_PR : LCK_PW;
-	params->lrp_brw_flags = 0;
-
-	params->lrp_policy.l_extent.start = pos;
-	params->lrp_policy.l_extent.end = pos + len - 1;
-	/*
-	 * for now O_APPEND always takes local locks.
-	 */
-	if (cmd == OBD_BRW_WRITE && (open_flags & O_APPEND)) {
-		params->lrp_policy.l_extent.start = 0;
-		params->lrp_policy.l_extent.end   = OBD_OBJECT_EOF;
-	} else if (LIBLUSTRE_CLIENT && (connect_flags & OBD_CONNECT_SRVLOCK)) {
-		/*
-		 * liblustre: OST-side locking for all non-O_APPEND
-		 * reads/writes.
-		 */
-		params->lrp_lock_mode = LCK_NL;
-		params->lrp_brw_flags = OBD_BRW_SRVLOCK;
-	} else {
-		/*
-		 * nothing special for the kernel. In the future llite may use
-		 * OST-side locks for small writes into highly contended
-		 * files.
-		 */
-	}
-	params->lrp_ast_flags = (open_flags & O_NONBLOCK) ?
-		LDLM_FL_BLOCK_NOWAIT : 0;
-}
-
 /*
  * This is embedded into liblustre and llite super-blocks to keep track of
  * connect flags (capabilities) supported by all imports given mount is
-- 
2.1.0
