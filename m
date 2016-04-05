From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:48 -0400
Subject: [lustre-devel] [PATCH 03/18] staging: lustre: libcfs: remove
	userland comments in libcfs_debug.h
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Remove comments about userland use.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/7243
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 98430e7..7472a31 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -85,7 +85,6 @@ struct ptldebug_header {
 #define PH_FLAG_FIRST_RECORD 1
 
 /* Debugging subsystems (32 bits, non-overlapping) */
-/* keep these in sync with lnet/utils/debug.c and lnet/libcfs/debug.c */
 #define S_UNDEFINED	0x00000001
 #define S_MDC		0x00000002
 #define S_MDS		0x00000004
@@ -118,10 +117,8 @@ struct ptldebug_header {
 #define S_MGS		0x20000000
 #define S_FID		0x40000000 /* b_new_cmd */
 #define S_FLD		0x80000000 /* b_new_cmd */
-/* keep these in sync with lnet/utils/debug.c and lnet/libcfs/debug.c */
 
 /* Debugging masks (32 bits, non-overlapping) */
-/* keep these in sync with lnet/utils/debug.c and lnet/libcfs/debug.c */
 #define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
 #define D_INODE		0x00000002
 #define D_SUPER		0x00000004
@@ -151,7 +148,6 @@ struct ptldebug_header {
 #define D_QUOTA		0x04000000
 #define D_SEC		0x08000000
 #define D_LFSCK		0x10000000 /* For both OI scrub and LFSCK */
-/* keep these in sync with lnet/{utils,libcfs}/debug.c */
 
 #define D_HSM	 D_TRACE
 
-- 
1.7.1
