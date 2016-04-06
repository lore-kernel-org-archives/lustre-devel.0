From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:36 -0400
Subject: [lustre-devel] [PATCH 10/24] staging: lustre: selftest: convert
	sfw_test_client_ops_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_test_client_ops_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    3 ++-
 drivers/staging/lustre/lnet/selftest/framework.c |    2 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c |    3 ++-
 drivers/staging/lustre/lnet/selftest/selftest.h  |   14 +++++++-------
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 8e789ba..5cba2c3 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -488,7 +488,8 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 	return 0;
 }
 
-sfw_test_client_ops_t brw_test_client;
+struct sfw_test_client_ops brw_test_client;
+
 void brw_init_test_client(void)
 {
 	brw_test_client.tso_init = brw_client_init;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 0d7c3c5..d42ee18 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -135,7 +135,7 @@ sfw_find_test_case(int id)
 }
 
 static int
-sfw_register_test(struct srpc_service *service, sfw_test_client_ops_t *cliops)
+sfw_register_test(struct srpc_service *service, struct sfw_test_client_ops *cliops)
 {
 	sfw_test_case_t *tsc;
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index df33a13..be13004 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -210,7 +210,8 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 	return 0;
 }
 
-sfw_test_client_ops_t ping_test_client;
+struct sfw_test_client_ops ping_test_client;
+
 void ping_init_test_client(void)
 {
 	ping_test_client.tso_init = ping_client_init;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 50237bc..b536e98 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -350,7 +350,7 @@ struct sfw_batch {
 	struct list_head bat_tests;	/* test instances */
 };
 
-typedef struct {
+struct sfw_test_client_ops {
 	int  (*tso_init)(struct sfw_test_instance *tsi); /* initialize test
 							  * client */
 	void (*tso_fini)(struct sfw_test_instance *tsi); /* finalize test
@@ -360,13 +360,13 @@ typedef struct {
 			     struct srpc_client_rpc **rpc);	/* prep a tests rpc */
 	void (*tso_done_rpc)(struct sfw_test_unit *tsu,
 			     struct srpc_client_rpc *rpc);	/* done a test rpc */
-} sfw_test_client_ops_t;
+};
 
 typedef struct sfw_test_instance {
 	struct list_head	   tsi_list;		/* chain on batch */
 	int			   tsi_service;		/* test type */
 	struct sfw_batch		*tsi_batch;	/* batch */
-	sfw_test_client_ops_t	   *tsi_ops;		/* test client operation
+	struct sfw_test_client_ops	*tsi_ops;	/* test client operation
 							 */
 
 	/* public parameter for all test units */
@@ -409,8 +409,8 @@ typedef struct sfw_test_unit {
 
 typedef struct sfw_test_case {
 	struct list_head      tsc_list;		/* chain on fw_tests */
-	struct srpc_service	*tsc_srv_service;	/* test service */
-	sfw_test_client_ops_t *tsc_cli_ops;	/* ops of test client */
+	struct srpc_service		*tsc_srv_service;	/* test service */
+	struct sfw_test_client_ops	*tsc_cli_ops;	/* ops of test client */
 } sfw_test_case_t;
 
 struct srpc_client_rpc *
@@ -610,13 +610,13 @@ srpc_wait_service_shutdown(struct srpc_service *sv)
 	}
 }
 
-extern sfw_test_client_ops_t brw_test_client;
+extern struct sfw_test_client_ops brw_test_client;
 void brw_init_test_client(void);
 
 extern struct srpc_service brw_test_service;
 void brw_init_test_service(void);
 
-extern sfw_test_client_ops_t ping_test_client;
+extern struct sfw_test_client_ops ping_test_client;
 void ping_init_test_client(void);
 
 extern struct srpc_service ping_test_service;
-- 
1.7.1
