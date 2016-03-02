From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:59 -0500
Subject: [lustre-devel] [PATCH 16/27] staging: lustre: reverse LNet and
	infinband header order
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

LNet is an abstraction built on top of network APIs such
as infiniband or TCP/IP layer. Since LNet is dependent
on these other layers we should ensure LNet headers
should always come after the infiniband header since the
infiniband headers can influence the LNet header
definitions.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5140
Reviewed-on: http://review.whamcloud.com/10571
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Shuichi Ihara <sihara@ddn.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index fb7079c..8e79e09 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -60,17 +60,17 @@
 #include <net/sock.h>
 #include <linux/in.h>
 
+#include <rdma/rdma_cm.h>
+#include <rdma/ib_cm.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_fmr_pool.h>
+
 #define DEBUG_SUBSYSTEM S_LND
 
 #include "../../../include/linux/libcfs/libcfs.h"
 #include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 
-#include <rdma/rdma_cm.h>
-#include <rdma/ib_cm.h>
-#include <rdma/ib_verbs.h>
-#include <rdma/ib_fmr_pool.h>
-
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
 /* # scheduler loops before reschedule */
 #define IBLND_RESCHED			100
-- 
1.7.1
