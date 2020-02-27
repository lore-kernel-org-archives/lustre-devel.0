From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:36 -0500
Subject: [lustre-devel] [PATCH 168/622] lustre: ptlrpc: Do not map
 unrecognized ELDLM errnos to EIO
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-169-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

The lustre_errno_hton and lustre_errno_ntoh functions map between
host and network error numbers before they are sent over the network.
If an errno is unrecognized then it is mapped to EIO.

However an optimization for x86 and i386 architectures replaced the
functions with macros that simply return the original errno. The
result is that x86 and i386 return the original values for ELDLM
errnos and all other architectures return EIO. This difference is
known to break glimpse lock callback handling which depends on clients
responding with ELDLM_NO_LOCK_DATA. The difference in errnos may
result in other as yet unidentified bugs.

The fix defines mappings for the ELDLM errors that leaves the values
unchanged. Error numbers not found in the mapping tables are still
mapped to EIO.

Cray-bug-id: LUS-6057
WC-bug-id: https://jira.whamcloud.com/browse/LU-9793
Lustre-commit: 641e1d546742 ("LU-9793 ptlrpc: Do not map unrecognized ELDLM errnos to EIO")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/33471
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/errno.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/fs/lustre/ptlrpc/errno.c b/fs/lustre/ptlrpc/errno.c
index b904524..2975010 100644
--- a/fs/lustre/ptlrpc/errno.c
+++ b/fs/lustre/ptlrpc/errno.c
@@ -30,6 +30,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <lustre_errno.h>
+#include <lustre_dlm.h>
 
 /*
  * The two translation tables below must define a one-to-one mapping between
@@ -187,6 +188,19 @@
 	[EBADTYPE]		= LUSTRE_EBADTYPE,
 	[EJUKEBOX]		= LUSTRE_EJUKEBOX,
 	[EIOCBQUEUED]		= LUSTRE_EIOCBQUEUED,
+
+	/*
+	 * The ELDLM errors are Lustre specific errors whose ranges
+	 * lie in the middle of the above system errors. The ELDLM
+	 * numbers must be preserved to avoid LU-9793.
+	 */
+	[ELDLM_LOCK_CHANGED]		= ELDLM_LOCK_CHANGED,
+	[ELDLM_LOCK_ABORTED]		= ELDLM_LOCK_ABORTED,
+	[ELDLM_LOCK_REPLACED]		= ELDLM_LOCK_REPLACED,
+	[ELDLM_NO_LOCK_DATA]		= ELDLM_NO_LOCK_DATA,
+	[ELDLM_LOCK_WOULDBLOCK]		= ELDLM_LOCK_WOULDBLOCK,
+	[ELDLM_NAMESPACE_EXISTS]	= ELDLM_NAMESPACE_EXISTS,
+	[ELDLM_BAD_NAMESPACE]		= ELDLM_BAD_NAMESPACE,
 };
 
 static int lustre_errno_ntoh_mapping[] = {
@@ -333,6 +347,19 @@
 	[LUSTRE_EBADTYPE]		= EBADTYPE,
 	[LUSTRE_EJUKEBOX]		= EJUKEBOX,
 	[LUSTRE_EIOCBQUEUED]		= EIOCBQUEUED,
+
+	/*
+	 * The ELDLM errors are Lustre specific errors whose ranges
+	 * lie in the middle of the above system errors. The ELDLM
+	 * numbers must be preserved to avoid LU-9793.
+	 */
+	[ELDLM_LOCK_CHANGED]		= ELDLM_LOCK_CHANGED,
+	[ELDLM_LOCK_ABORTED]		= ELDLM_LOCK_ABORTED,
+	[ELDLM_LOCK_REPLACED]		= ELDLM_LOCK_REPLACED,
+	[ELDLM_NO_LOCK_DATA]		= ELDLM_NO_LOCK_DATA,
+	[ELDLM_LOCK_WOULDBLOCK]		= ELDLM_LOCK_WOULDBLOCK,
+	[ELDLM_NAMESPACE_EXISTS]	= ELDLM_NAMESPACE_EXISTS,
+	[ELDLM_BAD_NAMESPACE]		= ELDLM_BAD_NAMESPACE,
 };
 
 unsigned int lustre_errno_hton(unsigned int h)
-- 
1.8.3.1
