From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:05 -0500
Subject: [lustre-devel] [PATCH 02/34] staging: lustre: lnet: change
	lst_bid_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_bid_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/console.h     | 2 +-
 drivers/staging/lustre/lnet/selftest/framework.c   | 4 ++--
 drivers/staging/lustre/lnet/selftest/rpc.h         | 4 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h    | 2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 68c7f58..b721287 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -75,9 +75,9 @@ struct lst_sid {
 
 extern struct lst_sid LST_INVALID_SID;
 
-typedef struct {
+struct lst_bid {
 	__u64	bat_id;		/* unique id in session */
-} lst_bid_t;			/*** batch id (group of tests) */
+};				/*** batch id (group of tests) */
 
 /* Status of test node */
 #define LST_NODE_ACTIVE		0x1	/* node in this session */
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 4bf7ecd..b37c37e 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -81,7 +81,7 @@ struct lstcon_group {
 #define LST_BATCH_RUNNING 0xB1	    /* running batch */
 
 struct lstcon_tsb_hdr {
-	lst_bid_t	 tsb_id;	 /* batch ID */
+	struct lst_bid	 tsb_id;	 /* batch ID */
 	int		 tsb_index;	 /* test index */
 };
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 4100f67..5ca6712 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -316,7 +316,7 @@
 }
 
 static struct sfw_batch *
-sfw_find_batch(lst_bid_t bid)
+sfw_find_batch(struct lst_bid bid)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	struct sfw_batch *bat;
@@ -332,7 +332,7 @@
 }
 
 static struct sfw_batch *
-sfw_bid2batch(lst_bid_t bid)
+sfw_bid2batch(struct lst_bid bid)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	struct sfw_batch *bat;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 3324c3f..f2987c5 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -139,7 +139,7 @@ struct srpc_debug_reply {
 struct srpc_batch_reqst {
 	__u64		   bar_rpyid;	   /* reply buffer matchbits */
 	struct lst_sid	   bar_sid;	   /* session id */
-	lst_bid_t	   bar_bid;	   /* batch id */
+	struct lst_bid	   bar_bid;	   /* batch id */
 	__u32		   bar_opc;	   /* create/start/stop batch */
 	__u32		   bar_testidx;    /* index of test */
 	__u32		   bar_arg;	   /* parameters */
@@ -188,7 +188,7 @@ struct srpc_test_reqst {
 	__u64			tsr_rpyid;	/* reply buffer matchbits */
 	__u64			tsr_bulkid;	/* bulk buffer matchbits */
 	struct lst_sid		tsr_sid;	/* session id */
-	lst_bid_t		tsr_bid;	/* batch id */
+	struct lst_bid		tsr_bid;	/* batch id */
 	__u32			tsr_service;	/* test type: bulk|ping|... */
 	__u32			tsr_loop;	/* test client loop count or
 						 * # server buffers needed
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 35f98ae..79b05aa 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -340,7 +340,7 @@ struct sfw_session {
 
 struct sfw_batch {
 	struct list_head bat_list;	/* chain on sn_batches */
-	lst_bid_t	 bat_id;	/* batch id */
+	struct lst_bid	 bat_id;	/* batch id */
 	int		 bat_error;	/* error code of batch */
 	struct sfw_session	*bat_session;	/* batch's session */
 	atomic_t	 bat_nactive;	/* # of active tests */
-- 
1.8.3.1
