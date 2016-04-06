From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:50 -0400
Subject: [lustre-devel] [PATCH 24/24] staging: lustre: selftest: change
	srpc_state_t to proper enum
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_state_t to proper enum

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/rpc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 812b9a5..4a45904 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -46,19 +46,19 @@
 
 #include "selftest.h"
 
-typedef enum {
+enum srpc_state {
 	SRPC_STATE_NONE,
 	SRPC_STATE_NI_INIT,
 	SRPC_STATE_EQ_INIT,
 	SRPC_STATE_RUNNING,
 	SRPC_STATE_STOPPING,
-} srpc_state_t;
+};
 
 static struct smoketest_rpc {
 	spinlock_t	 rpc_glock;	/* global lock */
 	struct srpc_service	*rpc_services[SRPC_SERVICE_MAX_ID + 1];
 	lnet_handle_eq_t rpc_lnet_eq;	/* _the_ LNet event queue */
-	srpc_state_t	 rpc_state;
+	enum srpc_state	 rpc_state;
 	srpc_counters_t	 rpc_counters;
 	__u64		 rpc_matchbits;	/* matchbits counter */
 } srpc_data;
-- 
1.7.1
