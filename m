From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:39 -0400
Subject: [lustre-devel] [PATCH 13/24] staging: lustre: selftest: convert
	sfw_test_case_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_test_case_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |   16 ++++++++--------
 drivers/staging/lustre/lnet/selftest/selftest.h  |    4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 8d364b0..56bcc8c 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -118,10 +118,10 @@ static struct smoketest_framework {
 int sfw_stop_batch(struct sfw_batch *tsb, int force);
 void sfw_destroy_session(struct sfw_session *sn);
 
-static inline sfw_test_case_t *
+static inline struct sfw_test_case *
 sfw_find_test_case(int id)
 {
-	sfw_test_case_t *tsc;
+	struct sfw_test_case *tsc;
 
 	LASSERT(id <= SRPC_SERVICE_MAX_ID);
 	LASSERT(id > SRPC_FRAMEWORK_SERVICE_MAX_ID);
@@ -137,7 +137,7 @@ sfw_find_test_case(int id)
 static int
 sfw_register_test(struct srpc_service *service, struct sfw_test_client_ops *cliops)
 {
-	sfw_test_case_t *tsc;
+	struct sfw_test_case *tsc;
 
 	if (sfw_find_test_case(service->sv_id)) {
 		CERROR("Failed to register test %s (%d)\n",
@@ -145,7 +145,7 @@ sfw_register_test(struct srpc_service *service, struct sfw_test_client_ops *clio
 		return -EEXIST;
 	}
 
-	LIBCFS_ALLOC(tsc, sizeof(sfw_test_case_t));
+	LIBCFS_ALLOC(tsc, sizeof(struct sfw_test_case));
 	if (!tsc)
 		return -ENOMEM;
 
@@ -199,7 +199,7 @@ __must_hold(&sfw_data.fw_lock)
 	struct sfw_session *sn = sfw_data.fw_session;
 	int nactive = 0;
 	struct sfw_batch *tsb;
-	sfw_test_case_t *tsc;
+	struct sfw_test_case *tsc;
 
 	if (!sn)
 		return;
@@ -1629,7 +1629,7 @@ sfw_startup(void)
 	int rc;
 	int error;
 	struct srpc_service *sv;
-	sfw_test_case_t *tsc;
+	struct sfw_test_case *tsc;
 
 	if (session_timeout < 0) {
 		CERROR("Session timeout must be non-negative: %d\n",
@@ -1722,7 +1722,7 @@ void
 sfw_shutdown(void)
 {
 	struct srpc_service *sv;
-	sfw_test_case_t	*tsc;
+	struct sfw_test_case	*tsc;
 	int i;
 
 	spin_lock(&sfw_data.fw_lock);
@@ -1778,7 +1778,7 @@ sfw_shutdown(void)
 
 	while (!list_empty(&sfw_data.fw_tests)) {
 		tsc = list_entry(sfw_data.fw_tests.next,
-				 sfw_test_case_t, tsc_list);
+				 struct sfw_test_case, tsc_list);
 
 		srpc_wait_service_shutdown(tsc->tsc_srv_service);
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index f08bc70..1a47772 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -407,11 +407,11 @@ struct sfw_test_unit {
 	struct swi_workitem	tsu_worker;	/* workitem of the test unit */
 };
 
-typedef struct sfw_test_case {
+struct sfw_test_case {
 	struct list_head      tsc_list;		/* chain on fw_tests */
 	struct srpc_service		*tsc_srv_service;	/* test service */
 	struct sfw_test_client_ops	*tsc_cli_ops;	/* ops of test client */
-} sfw_test_case_t;
+};
 
 struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
-- 
1.7.1
