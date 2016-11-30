From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 Nov 2016 20:33:33 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: repair improper
	unlikely test
Message-ID: <1480469613-7866-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The scripts to replace NULL test got confused with the
macro parenthesis so the unlikely test in libcfs_private.h
ended up incorrect. This fixes this error.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index fc180b8..41a651f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -96,7 +96,7 @@
 
 #define LIBCFS_ALLOC_POST(ptr, size)					    \
 do {									    \
-	if (!unlikely((ptr))) {						    \
+	if (unlikely(!(ptr))) {						    \
 		CERROR("LNET: out of memory at %s:%d (tried to alloc '"	    \
 		       #ptr "' = %d)\n", __FILE__, __LINE__, (int)(size));  \
 	} else {							    \
@@ -147,7 +147,7 @@
 
 #define LIBCFS_FREE(ptr, size)					  \
 do {								    \
-	if (!unlikely((ptr))) {						\
+	if (unlikely(!(ptr))) {						\
 		CERROR("LIBCFS: free NULL '" #ptr "' (%d bytes) at "    \
 		       "%s:%d\n", (int)(size), __FILE__, __LINE__);	\
 		break;						  \
-- 
1.7.1
