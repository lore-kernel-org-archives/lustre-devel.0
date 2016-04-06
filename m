From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:33 -0400
Subject: [lustre-devel] [PATCH 07/24] staging: lustre: selftest: convert
	srpc_service_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_service_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    3 +-
 drivers/staging/lustre/lnet/selftest/console.c   |    3 +-
 drivers/staging/lustre/lnet/selftest/framework.c |    8 +++---
 drivers/staging/lustre/lnet/selftest/ping_test.c |    3 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |   10 ++++----
 drivers/staging/lustre/lnet/selftest/selftest.h  |   26 +++++++++++-----------
 6 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 442f431..d2a8379 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -497,7 +497,8 @@ void brw_init_test_client(void)
 	brw_test_client.tso_done_rpc = brw_client_done_rpc;
 };
 
-srpc_service_t brw_test_service;
+struct srpc_service brw_test_service;
+
 void brw_init_test_service(void)
 {
 	brw_test_service.sv_id = SRPC_SERVICE_BRW;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index dcfc83d..1352310 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1986,7 +1986,8 @@ out:
 	return rc;
 }
 
-static srpc_service_t lstcon_acceptor_service;
+static struct srpc_service lstcon_acceptor_service;
+
 static void lstcon_init_acceptor_service(void)
 {
 	/* initialize selftest console acceptor service table */
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 6c0af58..0eb275f 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -135,7 +135,7 @@ sfw_find_test_case(int id)
 }
 
 static int
-sfw_register_test(srpc_service_t *service, sfw_test_client_ops_t *cliops)
+sfw_register_test(struct srpc_service *service, sfw_test_client_ops_t *cliops)
 {
 	sfw_test_case_t *tsc;
 
@@ -1584,7 +1584,7 @@ sfw_post_rpc(struct srpc_client_rpc *rpc)
 	spin_unlock(&rpc->crpc_lock);
 }
 
-static srpc_service_t sfw_services[] = {
+static struct srpc_service sfw_services[] = {
 	{
 		/* sv_id */    SRPC_SERVICE_DEBUG,
 		/* sv_name */  "debug",
@@ -1628,7 +1628,7 @@ sfw_startup(void)
 	int i;
 	int rc;
 	int error;
-	srpc_service_t *sv;
+	struct srpc_service *sv;
 	sfw_test_case_t *tsc;
 
 	if (session_timeout < 0) {
@@ -1721,7 +1721,7 @@ sfw_startup(void)
 void
 sfw_shutdown(void)
 {
-	srpc_service_t *sv;
+	struct srpc_service *sv;
 	sfw_test_case_t	*tsc;
 	int i;
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 1f2ddf6..c09b599 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -219,7 +219,8 @@ void ping_init_test_client(void)
 	ping_test_client.tso_done_rpc = ping_client_done_rpc;
 }
 
-srpc_service_t ping_test_service;
+struct srpc_service ping_test_service;
+
 void ping_init_test_service(void)
 {
 	ping_test_service.sv_id = SRPC_SERVICE_PING;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index e711571..1e2fd8a 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -56,7 +56,7 @@ typedef enum {
 
 static struct smoketest_rpc {
 	spinlock_t	 rpc_glock;	/* global lock */
-	srpc_service_t	*rpc_services[SRPC_SERVICE_MAX_ID + 1];
+	struct srpc_service	*rpc_services[SRPC_SERVICE_MAX_ID + 1];
 	lnet_handle_eq_t rpc_lnet_eq;	/* _the_ LNet event queue */
 	srpc_state_t	 rpc_state;
 	srpc_counters_t	 rpc_counters;
@@ -338,7 +338,7 @@ srpc_add_service(struct srpc_service *sv)
 }
 
 int
-srpc_remove_service(srpc_service_t *sv)
+srpc_remove_service(struct srpc_service *sv)
 {
 	int id = sv->sv_id;
 
@@ -755,7 +755,7 @@ srpc_abort_service(struct srpc_service *sv)
 }
 
 void
-srpc_shutdown_service(srpc_service_t *sv)
+srpc_shutdown_service(struct srpc_service *sv)
 {
 	struct srpc_service_cd *scd;
 	struct srpc_server_rpc *rpc;
@@ -1414,7 +1414,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 	struct srpc_client_rpc *crpc;
 	struct srpc_server_rpc *srpc;
 	struct srpc_buffer *buffer;
-	srpc_service_t *sv;
+	struct srpc_service *sv;
 	srpc_msg_t *msg;
 	srpc_msg_type_t type;
 
@@ -1663,7 +1663,7 @@ srpc_shutdown(void)
 		spin_lock(&srpc_data.rpc_glock);
 
 		for (i = 0; i <= SRPC_SERVICE_MAX_ID; i++) {
-			srpc_service_t *sv = srpc_data.rpc_services[i];
+			struct srpc_service *sv = srpc_data.rpc_services[i];
 
 			LASSERTF(!sv, "service not empty: id %d, name %s\n",
 				 i, sv->sv_name);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 55f8154..0ad6e53 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -307,7 +307,7 @@ struct srpc_service_cd {
 #define SFW_FRWK_WI_MIN		16
 #define SFW_FRWK_WI_MAX		256
 
-typedef struct srpc_service {
+struct srpc_service {
 	int			sv_id;		/* service id */
 	const char		*sv_name;	/* human readable name */
 	int			sv_wi_total;	/* total server workitems */
@@ -321,7 +321,7 @@ typedef struct srpc_service {
 	 */
 	int (*sv_handler)(struct srpc_server_rpc *);
 	int (*sv_bulk_ready)(struct srpc_server_rpc *, int);
-} srpc_service_t;
+};
 
 typedef struct {
 	struct list_head sn_list;    /* chain on fw_zombie_sessions */
@@ -409,7 +409,7 @@ typedef struct sfw_test_unit {
 
 typedef struct sfw_test_case {
 	struct list_head      tsc_list;		/* chain on fw_tests */
-	srpc_service_t	      *tsc_srv_service; /* test service */
+	struct srpc_service	*tsc_srv_service;	/* test service */
 	sfw_test_client_ops_t *tsc_cli_ops;	/* ops of test client */
 } sfw_test_case_t;
 
@@ -442,13 +442,13 @@ struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned bulk_npg,
 				  unsigned bulk_len, int sink);
 int srpc_send_rpc(struct swi_workitem *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
-int srpc_add_service(srpc_service_t *sv);
-int srpc_remove_service(srpc_service_t *sv);
-void srpc_shutdown_service(srpc_service_t *sv);
-void srpc_abort_service(srpc_service_t *sv);
-int srpc_finish_service(srpc_service_t *sv);
-int srpc_service_add_buffers(srpc_service_t *sv, int nbuffer);
-void srpc_service_remove_buffers(srpc_service_t *sv, int nbuffer);
+int srpc_add_service(struct srpc_service *sv);
+int srpc_remove_service(struct srpc_service *sv);
+void srpc_shutdown_service(struct srpc_service *sv);
+void srpc_abort_service(struct srpc_service *sv);
+int srpc_finish_service(struct srpc_service *sv);
+int srpc_service_add_buffers(struct srpc_service *sv, int nbuffer);
+void srpc_service_remove_buffers(struct srpc_service *sv, int nbuffer);
 void srpc_get_counters(srpc_counters_t *cnt);
 void srpc_set_counters(const srpc_counters_t *cnt);
 
@@ -595,7 +595,7 @@ do {									\
 } while (0)
 
 static inline void
-srpc_wait_service_shutdown(srpc_service_t *sv)
+srpc_wait_service_shutdown(struct srpc_service *sv)
 {
 	int i = 2;
 
@@ -613,13 +613,13 @@ srpc_wait_service_shutdown(srpc_service_t *sv)
 extern sfw_test_client_ops_t brw_test_client;
 void brw_init_test_client(void);
 
-extern srpc_service_t brw_test_service;
+extern struct srpc_service brw_test_service;
 void brw_init_test_service(void);
 
 extern sfw_test_client_ops_t ping_test_client;
 void ping_init_test_client(void);
 
-extern srpc_service_t ping_test_service;
+extern struct srpc_service ping_test_service;
 void ping_init_test_service(void);
 
 #endif /* __SELFTEST_SELFTEST_H__ */
-- 
1.7.1
