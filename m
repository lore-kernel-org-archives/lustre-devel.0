From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 17:35:22 -0400
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: place linux header
	first in hash.c
In-Reply-To: <1446154522-12929-1-git-send-email-jsimmons@infradead.org>
References: <1446154522-12929-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446154522-12929-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Always place linux headers first in libcfs header files.
This avoid can potential build issues if any changes to
a libcfs header land that starts using a linux header
definition.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/hash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index ed4e1f1..4cd8776 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -106,9 +106,9 @@
  *   Now we support both locked iteration & lockless iteration of hash
  *   table. Also, user can break the iteration by return 1 in callback.
  */
+#include <linux/seq_file.h>
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include <linux/seq_file.h>
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
-- 
1.7.1
