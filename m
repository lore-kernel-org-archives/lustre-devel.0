From: Binoy Jayan <binoy.jayan@linaro.org>
Date: Wed,  8 Jun 2016 13:20:42 +0530
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: lnet: Replace semaphore
	ln_rc_signal with completion
In-Reply-To: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
References: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
Message-ID: <1465372242-7116-3-git-send-email-binoy.jayan@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org
Cc: Binoy Jayan <binoy.jayan@linaro.org>, driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

The semaphore ln_rc_signal is used as completion, so convert it to
struct completion.  Semaphores are going away in the future.

Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 3 ++-
 drivers/staging/lustre/lnet/lnet/router.c             | 9 +++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 24c4a08..7967b01 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -38,6 +38,7 @@
 #include <linux/kthread.h>
 #include <linux/uio.h>
 #include <linux/types.h>
+#include <linux/completion.h>
 
 #include "types.h"
 #include "lnetctl.h"
@@ -610,7 +611,7 @@ typedef struct {
 	/* rcd ready for free */
 	struct list_head		  ln_rcd_zombie;
 	/* serialise startup/shutdown */
-	struct semaphore		  ln_rc_signal;
+	struct completion		  ln_rc_signal;
 
 	struct mutex			  ln_api_mutex;
 	struct mutex			  ln_lnd_mutex;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index b01dc42..0635432 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -18,6 +18,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+#include <linux/completion.h>
 #include "../../include/linux/lnet/lib-lnet.h"
 
 #define LNET_NRB_TINY_MIN	512	/* min value for each CPT */
@@ -1065,7 +1066,7 @@ lnet_router_checker_start(void)
 		return -EINVAL;
 	}
 
-	sema_init(&the_lnet.ln_rc_signal, 0);
+	init_completion(&the_lnet.ln_rc_signal);
 
 	rc = LNetEQAlloc(0, lnet_router_checker_event, &the_lnet.ln_rc_eqh);
 	if (rc) {
@@ -1079,7 +1080,7 @@ lnet_router_checker_start(void)
 		rc = PTR_ERR(task);
 		CERROR("Can't start router checker thread: %d\n", rc);
 		/* block until event callback signals exit */
-		down(&the_lnet.ln_rc_signal);
+		wait_for_completion(&the_lnet.ln_rc_signal);
 		rc = LNetEQFree(the_lnet.ln_rc_eqh);
 		LASSERT(!rc);
 		the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
@@ -1112,7 +1113,7 @@ lnet_router_checker_stop(void)
 	wake_up(&the_lnet.ln_rc_waitq);
 
 	/* block until event callback signals exit */
-	down(&the_lnet.ln_rc_signal);
+	wait_for_completion(&the_lnet.ln_rc_signal);
 	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN);
 
 	rc = LNetEQFree(the_lnet.ln_rc_eqh);
@@ -1295,7 +1296,7 @@ rescan:
 	lnet_prune_rc_data(1); /* wait for UNLINK */
 
 	the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-	up(&the_lnet.ln_rc_signal);
+	complete(&the_lnet.ln_rc_signal);
 	/* The unlink event callback will signal final completion */
 	return 0;
 }
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
