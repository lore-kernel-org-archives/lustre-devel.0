From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Thu, 4 Jun 2015 11:05:54 +0530
Subject: [lustre-devel] [PATCH v4 1/7] staging:lustre: move tcpip
	abstraction
In-Reply-To: <1433361433-24976-2-git-send-email-jsimmons@infradead.org>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20150604053554.GB6376@sudip-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 03:57:07PM -0400, James Simmons wrote:
> Rename libcfs/linux/linux-tcpip.c to lnet/lnet/lib-socket.c
looks like you have not just renamed the file, but there was also a change
in the #include which is not mentioned in the commit message.

--- drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.old	2015-06-04 11:01:01.862374309 +0530
+++ drivers/staging/lustre/lnet/lnet/lib-socket.c	2015-06-04 11:01:37.082375681 +0530
@@ -35,7 +35,8 @@
  */
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/lnet/lib-lnet.h"
 
 #include <linux/if.h>
 #include <linux/in.h>

regards
sudip
