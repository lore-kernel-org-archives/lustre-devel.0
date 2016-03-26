From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:45 -0400
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: libcfs: limit scope
	of libcfs_crypto.h
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Remove <libcfs/libcfs_crypto.h> from <libcfs/libcfs.h> and only
include it into the places where it is actually needed.  This
works out to be the same places as <obd_cksum.h>, so put it there.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    1 +
 drivers/staging/lustre/lustre/include/obd_cksum.h  |    1 +
 3 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 6a8e0d0..d2e4361 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -96,7 +96,6 @@ void cfs_get_random_bytes(void *buf, int size);
 #include "libcfs_workitem.h"
 #include "libcfs_hash.h"
 #include "libcfs_fail.h"
-#include "libcfs_crypto.h"
 
 struct libcfs_ioctl_handler {
 	struct list_head item;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 8c9377e..d4cb260 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -30,6 +30,7 @@
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
 #include "../../../include/linux/libcfs/libcfs.h"
+#include "../../../include/linux/libcfs/libcfs_crypto.h"
 #include "linux-crypto.h"
 /**
  *  Array of  hash algorithm speed in MByte per second
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index 637fa22..f6c18df 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -35,6 +35,7 @@
 #ifndef __OBD_CKSUM
 #define __OBD_CKSUM
 #include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/libcfs/libcfs_crypto.h"
 #include "lustre/lustre_idl.h"
 
 static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
-- 
1.7.1
