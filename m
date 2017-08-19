From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Aug 2017 23:04:14 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: uapi: properly include
	lustre_errno.h
Message-ID: <1503111854-29944-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The path for lustre_errno.h was not updated to the new path
for errno.c. Also the header lustre_net.h uses code found in
lustre_errno.h but doesn't include the header directly. It
is easy to forget to add the header lustre_errno.h before
including lustre_net.h so it is just easier to include
lustre_errno.h in lustre_net.h. This should resolve the
build issues seen on the ia64 platform.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 1 +
 drivers/staging/lustre/lustre/ptlrpc/errno.c       | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 1ae7e83..bc18131 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -55,6 +55,7 @@
 #include "../../include/uapi/linux/lnet/nidstr.h"
 #include "../../include/linux/lnet/api.h"
 #include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include "lustre_errno.h"
 #include "lustre_ha.h"
 #include "lustre_sec.h"
 #include "lustre_import.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
index 73f8374..faad8d8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/errno.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/errno.c
@@ -26,7 +26,7 @@
  */
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre/lustre_errno.h"
+#include "../include/lustre_errno.h"
 
 /*
  * The two translation tables below must define a one-to-one mapping between
-- 
1.8.3.1
