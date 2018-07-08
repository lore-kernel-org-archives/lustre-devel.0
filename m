From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:28 -0400
Subject: [lustre-devel] [PATCH v4 14/14] lustre: libcfs: format macros in
 tracefile.h
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The __LASSERT_* macros are ugly and hard to read. This patch
beautifies them.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index dc782a6..67107b1 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -161,21 +161,21 @@ void cfs_trace_assertion_failed(const char *str,
 				struct libcfs_debug_msg_data *m);
 
 /* ASSERTION that is safe to use within the debug system */
-#define __LASSERT(cond)						 \
-do {								    \
+#define __LASSERT(cond)							\
+do {									\
 	if (unlikely(!(cond))) {					\
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_EMERG, NULL);     \
-		cfs_trace_assertion_failed("ASSERTION("#cond") failed", \
-					   &msgdata);		   \
-	}							       \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_EMERG, NULL);	\
+		cfs_trace_assertion_failed("ASSERTION("#cond") failed",	\
+					   &msgdata);			\
+	}								\
 } while (0)
 
-#define __LASSERT_TAGE_INVARIANT(tage)				  \
-do {								    \
-	__LASSERT(tage);					\
-	__LASSERT(tage->page);				  \
-	__LASSERT(tage->used <= PAGE_SIZE);			 \
-	__LASSERT(page_count(tage->page) > 0);		      \
+#define __LASSERT_TAGE_INVARIANT(tage)			\
+do {							\
+	__LASSERT(tage);				\
+	__LASSERT(tage->page);				\
+	__LASSERT(tage->used <= PAGE_SIZE);		\
+	__LASSERT(page_count(tage->page) > 0);		\
 } while (0)
 
 #endif /* __LIBCFS_TRACEFILE_H__ */
-- 
1.8.3.1
