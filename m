From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:48 -0500
Subject: [lustre-devel] [PATCH 4/6] staging: lustre: headers: sort headers
	affected by obdo move
In-Reply-To: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480707650-24089-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

It was found if you sort the headers alphabetically
that it reduced patch conflicts. This patch sorts
the headers alphabetically and also place linux
header first, then uapi header and finally the
lustre kernel headers.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/16917
Reviewed-on: http://review.whamcloud.com/19266
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4d4d3eb..f2365b9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -34,19 +34,20 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_net.h"
 #include "../include/lustre/lustre_user.h"
-#include "../include/obd_cksum.h"
+#include "../include/lustre/lustre_ioctl.h"
 
-#include "../include/lustre_ha.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_debug.h"
-#include "../include/lustre_param.h"
 #include "../include/lustre_fid.h"
+#include "../include/lustre_ha.h"
+#include "../include/lustre_obdo.h"
+#include "../include/lustre_param.h"
+
+#include "../include/obd_cksum.h"
 #include "../include/obd_class.h"
 #include "../include/obd.h"
+
 #include "osc_internal.h"
 #include "osc_cl_internal.h"
 
-- 
1.7.1
