From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:29 -0500
Subject: [lustre-devel] [PATCH 221/622] lustre: lov: avoid signed vs.
 unsigned comparison
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-222-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

In the expansion of do_div64() GCC complains about pointer comparison
because loff_t is not a u64 variable as it should be.  lov_do_div64()
also has signed vs. unsigned comparisons due to a signed loff_t.
Change lov_do_div() to use a 64-bit variable for do_div() instead of
loff_t to avoid these warnings.

Change OST_MAXREQSIZE and friends to be consistently unsigned values
to avoid compiler warnings.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11830
Lustre-commit: 632b3591b6ea ("LU-11830 lov: avoid signed vs. unsigned comparison")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33921
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 15 ++++++++-------
 fs/lustre/lov/lov_internal.h   | 15 +++++++++------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 36de665..8d71559 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -281,21 +281,22 @@
  * - OST_IO_MAXREQSIZE must be at least 1 page of cookies plus some spillover
  * - Must be a multiple of 1024
  */
-#define _OST_MAXREQSIZE_BASE	(sizeof(struct lustre_msg) + \
+#define _OST_MAXREQSIZE_BASE ((unsigned long)(sizeof(struct lustre_msg) + \
 				 sizeof(struct ptlrpc_body) + \
 				 sizeof(struct obdo) + \
 				 sizeof(struct obd_ioobj) + \
-				 sizeof(struct niobuf_remote))
-#define _OST_MAXREQSIZE_SUM	(_OST_MAXREQSIZE_BASE + \
+				 sizeof(struct niobuf_remote)))
+#define _OST_MAXREQSIZE_SUM ((unsigned long)(_OST_MAXREQSIZE_BASE + \
 				 sizeof(struct niobuf_remote) * \
-				 (DT_MAX_BRW_PAGES - 1))
+				 (DT_MAX_BRW_PAGES - 1)))
 
 /**
  * FIEMAP request can be 4K+ for now
  */
-#define OST_MAXREQSIZE		(16 * 1024)
-#define OST_IO_MAXREQSIZE	max_t(int, OST_MAXREQSIZE, \
-				      (((_OST_MAXREQSIZE_SUM - 1) | (1024 - 1)) + 1))
+#define OST_MAXREQSIZE		(16UL * 1024UL)
+#define OST_IO_MAXREQSIZE	max(OST_MAXREQSIZE,		\
+				   ((_OST_MAXREQSIZE_SUM - 1) |	\
+				   (1024 - 1)) + 1)
 
 /* Safe estimate of free space in standard RPC, provides upper limit for # of
  * bytes of i/o to pack in RPC (skipping bulk transfer).
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 376ac52..36586b3 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -186,19 +186,22 @@ struct lsm_operations {
 })
 #elif BITS_PER_LONG == 32
 # define lov_do_div64(n, base) ({					      \
+	u64 __num = (n);						      \
 	u64 __rem;							      \
 	if ((sizeof(base) > 4) && (((base) & 0xffffffff00000000ULL) != 0)) {  \
 		int __remainder;					      \
-		LASSERTF(!((base) & (LOV_MIN_STRIPE_SIZE - 1)), "64 bit lov " \
-			 "division %llu / %llu\n", (n), (u64)(base));	      \
-		__remainder = (n) & (LOV_MIN_STRIPE_SIZE - 1);		      \
-		(n) >>= LOV_MIN_STRIPE_BITS;				      \
-		__rem = do_div(n, (base) >> LOV_MIN_STRIPE_BITS);	      \
+		LASSERTF(!((base) & (LOV_MIN_STRIPE_SIZE - 1)),		      \
+			 "64 bit lov division %llu / %llu\n",		      \
+			 __num, (u64)(base));				      \
+		__remainder = __num & (LOV_MIN_STRIPE_SIZE - 1);	      \
+		__num >>= LOV_MIN_STRIPE_BITS;				      \
+		__rem = do_div(__num, (base) >> LOV_MIN_STRIPE_BITS);	      \
 		__rem <<= LOV_MIN_STRIPE_BITS;				      \
 		__rem += __remainder;					      \
 	} else {							      \
-		__rem = do_div(n, base);				      \
+		__rem = do_div(__num, base);				      \
 	}								      \
+	(n) = __num;							      \
 	__rem;								      \
 })
 #endif
-- 
1.8.3.1
