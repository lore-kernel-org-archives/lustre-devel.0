From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:34 -0400
Subject: [lustre-devel] [PATCH 40/64 v2] staging: lustre: uapi: remove
	libcfs.h from lustre_id.h/lustre_user.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

These are the last UAPI headers that contain libcfs.h which is
internal kernel header. Since it is not available to user land
remove libcfs.h and add the need headers that libcfs.h provided.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/22138
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h  | 3 ++-
 drivers/staging/lustre/lustre/include/lustre/lustre_user.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d26c599..fe443f8 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -69,7 +69,8 @@
 #ifndef _LUSTRE_IDL_H_
 #define _LUSTRE_IDL_H_
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/types.h>
+
 #include "../../../include/uapi/linux/lnet/lnet-types.h"
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index edff8dc..bee93d0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -43,6 +43,7 @@
  */
 
 #ifdef __KERNEL__
+# include <linux/fs.h>
 # include <linux/quota.h>
 # include <linux/sched/signal.h>
 # include <linux/string.h> /* snprintf() */
-- 
1.8.3.1
