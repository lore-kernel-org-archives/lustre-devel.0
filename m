From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:50 -0400
Subject: [lustre-devel] [PATCH 05/18] staging: lustre: libcfs: make D_HSM a
	unique value
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Redefine D_HSM. It was defined to D_TRACE.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/7243
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 5e60c6f..455c54d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -154,8 +154,7 @@ struct ptldebug_header {
 #define D_QUOTA		0x04000000
 #define D_SEC		0x08000000
 #define D_LFSCK		0x10000000 /* For both OI scrub and LFSCK */
-
-#define D_HSM	 D_TRACE
+#define D_HSM		0x20000000
 
 #define LIBCFS_DEBUG_MASKS_NAMES {					\
 	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
-- 
1.7.1
