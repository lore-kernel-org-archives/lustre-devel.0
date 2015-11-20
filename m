From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:00 -0500
Subject: [lustre-devel] [PATCH 24/40] staging: lustre: make some lnet
	functions static
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

Some functions and variables are only used in their C file, so reduce
their scope. This reduces the code size, and fixes sparse warnings
such as:

warning: symbol 'proc_lnet_routes' was not declared.
        Should it be static?
warning: symbol 'proc_lnet_routers' was not declared.
        Should it be static?

Some prototypes were removed from C files and added to the proper
header.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/12206
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 ++
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 --
 drivers/staging/lustre/lnet/selftest/console.c     |    4 +---
 drivers/staging/lustre/lnet/selftest/framework.c   |   10 ----------
 drivers/staging/lustre/lnet/selftest/module.c      |    4 +---
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
 6 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 4c2d824..00ef4d0 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -446,6 +446,8 @@ lnet_ni_t *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 lnet_ni_t *lnet_net2ni_locked(__u32 net, int cpt);
 lnet_ni_t *lnet_net2ni(__u32 net);
 
+extern int portal_rotor;
+
 int lnet_init(void);
 void lnet_fini(void);
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index af7423f..73183f1 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -795,8 +795,6 @@ static struct lnet_portal_rotors	portal_rotors[] = {
 	},
 };
 
-extern int portal_rotor;
-
 static int __proc_lnet_portal_rotor(void *data, int write,
 				    loff_t pos, void __user *buffer, int nob)
 {
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index f8d6dfe..551d664 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1694,8 +1694,6 @@ lstcon_new_session_id(lst_sid_t *sid)
 	sid->ses_stamp = cfs_time_current();
 }
 
-extern srpc_service_t lstcon_acceptor_service;
-
 int
 lstcon_session_new(char *name, int key, unsigned feats,
 		   int timeout, int force, lst_sid_t __user *sid_up)
@@ -1974,7 +1972,7 @@ out:
 	return rc;
 }
 
-srpc_service_t lstcon_acceptor_service;
+static srpc_service_t lstcon_acceptor_service;
 static void lstcon_init_acceptor_service(void)
 {
 	/* initialize selftest console acceptor service table */
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 1a2da74..b04c147 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1622,16 +1622,6 @@ static srpc_service_t sfw_services[] = {
 	}
 };
 
-extern sfw_test_client_ops_t ping_test_client;
-extern srpc_service_t	ping_test_service;
-extern void ping_init_test_client(void);
-extern void ping_init_test_service(void);
-
-extern sfw_test_client_ops_t brw_test_client;
-extern srpc_service_t	brw_test_service;
-extern void brw_init_test_client(void);
-extern void brw_init_test_service(void);
-
 int
 sfw_startup(void)
 {
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 46cbdf0..91564e5 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -37,6 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "selftest.h"
+#include "console.h"
 
 enum {
 	LST_INIT_NONE = 0,
@@ -47,9 +48,6 @@ enum {
 	LST_INIT_CONSOLE
 };
 
-extern int lstcon_console_init(void);
-extern int lstcon_console_fini(void);
-
 static int lst_init_step = LST_INIT_NONE;
 
 struct cfs_wi_sched *lst_sched_serial;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 2212199..9b823be 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1082,7 +1082,7 @@ srpc_client_rpc_expired(void *data)
 	spin_unlock(&srpc_data.rpc_glock);
 }
 
-inline void
+static void
 srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
 {
 	stt_timer_t *timer = &rpc->crpc_timer;
-- 
1.7.1
