From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:26 -0500
Subject: [lustre-devel] [PATCH 098/622] lustre: obd: use correct
 ip_compute_csum() version
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-99-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The linux kernel provides a generic platform independent version
of ip_compute_csum() as well as platform optimized versions. Some
platforms will disable the generic platform version in favor of
the optimized one. If the generic version is disabled and if the
checksum.h header from asm-generic is used then we will end up
with a undefined symbol error when loading the obdclass module.
The solution is to use the platform specific checksum.h header
that will handle using the generic or optimized version for us.
As a bounus we get better performance with the right kernel
configuration.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11224
Lustre-commit: 82fe90a1d07d ("LU-11224 obd: use correct ip_compute_csum() version")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/32953
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/integrity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index 8348b16..5cb9a25 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -28,7 +28,7 @@
  */
 #include <linux/blkdev.h>
 #include <linux/crc-t10dif.h>
-#include <asm-generic/checksum.h>
+#include <asm/checksum.h>
 #include <obd_class.h>
 #include <obd_cksum.h>
 
-- 
1.8.3.1
