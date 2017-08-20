From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:11 -0400
Subject: [lustre-devel] [PATCH 17/64 v2] staging: lustre: uapi: remove
	included headers out of lustre_param.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

All the included headers in lustre_param.h are lustre kernel
internal headers and they are not even needed. Just remove them.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24325
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_param.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index 2620e02..f6f4752 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -39,9 +39,6 @@
 #ifndef _LUSTRE_PARAM_H
 #define _LUSTRE_PARAM_H
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/types.h"
-
 /** \defgroup param param
  *
  * @{
-- 
1.8.3.1
