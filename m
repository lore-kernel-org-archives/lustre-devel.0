From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Fri, 6 Nov 2015 02:04:21 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: selftest: Move extern
 declarations to headers
Message-ID: <20151105203421.GA12506@amitoj-Inspiron-3542>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch moves extern declarations to respective header files.

This patch also removes extern keyword from function declarations
since functions have the extern specifier by default.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/console.c   |  4 ----
 drivers/staging/lustre/lnet/selftest/console.h   |  2 ++
 drivers/staging/lustre/lnet/selftest/framework.c | 11 -----------
 drivers/staging/lustre/lnet/selftest/module.c    |  3 ---
 drivers/staging/lustre/lnet/selftest/selftest.h  | 13 +++++++++++++
 5 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 024aaee..ab9906f 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1698,8 +1698,6 @@ lstcon_new_session_id(lst_sid_t *sid)
 	sid->ses_stamp = cfs_time_current();
 }
 
-extern srpc_service_t lstcon_acceptor_service;
-
 int
 lstcon_session_new(char *name, int key, unsigned feats,
 		   int timeout, int force, lst_sid_t *sid_up)
@@ -1984,8 +1982,6 @@ static void lstcon_init_acceptor_service(void)
 	lstcon_acceptor_service.sv_wi_total = SFW_FRWK_WI_MAX;
 }
 
-extern int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data);
-
 static DECLARE_IOCTL_HANDLER(lstcon_ioctl_handler, lstcon_ioctl_entry);
 
 /* initialize console */
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index acd1312..fe1974a 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -169,6 +169,8 @@ typedef struct {
 } lstcon_session_t; /* session descriptor */
 
 extern lstcon_session_t	 console_session;
+extern srpc_service_t lstcon_acceptor_service;
+int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data);
 
 static inline lstcon_trans_stat_t *
 lstcon_trans_stat(void)
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 177beaf..34072d0 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1623,17 +1623,6 @@ static srpc_service_t sfw_services[] = {
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
-
 int
 sfw_startup(void)
 {
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 09b8f46..c2a8ee5 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -47,9 +47,6 @@ enum {
 	LST_INIT_CONSOLE
 };
 
-extern int lstcon_console_init(void);
-extern int lstcon_console_fini(void);
-
 static int lst_init_step = LST_INIT_NONE;
 
 struct cfs_wi_sched *lst_sched_serial;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 4832253..7e6a234 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -452,6 +452,19 @@ void srpc_service_remove_buffers(srpc_service_t *sv, int nbuffer);
 void srpc_get_counters(srpc_counters_t *cnt);
 void srpc_set_counters(const srpc_counters_t *cnt);
 
+int lstcon_console_init(void);
+int lstcon_console_fini(void);
+
+extern sfw_test_client_ops_t ping_test_client;
+extern srpc_service_t	ping_test_service;
+void ping_init_test_client(void);
+void ping_init_test_service(void);
+
+extern sfw_test_client_ops_t brw_test_client;
+extern srpc_service_t	brw_test_service;
+void brw_init_test_client(void);
+void brw_init_test_service(void);
+
 extern struct cfs_wi_sched *lst_sched_serial;
 extern struct cfs_wi_sched **lst_sched_test;
 
-- 
1.9.1
