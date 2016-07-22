From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:19 -0400
Subject: [lustre-devel] [PATCH 26/58] staging: lustre: lmv: remove duplicate
	MAX_HASH_*
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The MAX_HASH_* macros already exist in obd.h. Remove
the duplicated defines in lustre_idl.h.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 32471a6..5f31724 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2486,10 +2486,6 @@ struct lmv_desc {
 #define MEA_MAGIC_ALL_CHARS      0xb222a11c
 #define MEA_MAGIC_HASH_SEGMENT   0xb222a11b
 
-#define MAX_HASH_SIZE_32	 0x7fffffffUL
-#define MAX_HASH_SIZE	    0x7fffffffffffffffULL
-#define MAX_HASH_HIGHEST_BIT     0x1000000000000000ULL
-
 /* lmv structures */
 #define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
 #define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
-- 
1.7.1
