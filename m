From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:36 -0500
Subject: [lustre-devel] [PATCH 33/34] staging: lustre: lnet: change
	srpc_counters_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change srpc_counters_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/console.c     | 4 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c         | 6 +++---
 drivers/staging/lustre/lnet/selftest/rpc.h         | 2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    | 4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index a9c5b6d..575d23a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -501,7 +501,7 @@ struct lst_test_ping_param {
 	int	png_flags;	/* reserved flags */
 };
 
-typedef struct {
+struct srpc_counters {
 	__u32 errors;
 	__u32 rpcs_sent;
 	__u32 rpcs_rcvd;
@@ -509,7 +509,7 @@ struct lst_test_ping_param {
 	__u32 rpcs_expired;
 	__u64 bulk_get;
 	__u64 bulk_put;
-} WIRE_ATTR srpc_counters_t;
+} WIRE_ATTR;
 
 typedef struct {
 	/** milliseconds since current session started */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index b01023c..483a1bb 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1468,14 +1468,14 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 {
 	struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
 	sfw_counters_t __user *sfwk_stat;
-	srpc_counters_t __user *srpc_stat;
+	struct srpc_counters __user *srpc_stat;
 	lnet_counters_t __user *lnet_stat;
 
 	if (rep->str_status)
 		return 0;
 
 	sfwk_stat = (sfw_counters_t __user *)&ent_up->rpe_payload[0];
-	srpc_stat = (srpc_counters_t __user *)(sfwk_stat + 1);
+	srpc_stat = (struct srpc_counters __user *)(sfwk_stat + 1);
 	lnet_stat = (lnet_counters_t __user *)(srpc_stat + 1);
 
 	if (copy_to_user(sfwk_stat, &rep->str_fw, sizeof(*sfwk_stat)) ||
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index ce9de8c..92cd411 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -55,7 +55,7 @@ enum srpc_state {
 	struct srpc_service	*rpc_services[SRPC_SERVICE_MAX_ID + 1];
 	lnet_handle_eq_t rpc_lnet_eq;	/* _the_ LNet event queue */
 	enum srpc_state	 rpc_state;
-	srpc_counters_t	 rpc_counters;
+	struct srpc_counters	 rpc_counters;
 	__u64		 rpc_matchbits;	/* matchbits counter */
 } srpc_data;
 
@@ -69,14 +69,14 @@ enum srpc_state {
 /* forward ref's */
 int srpc_handle_rpc(struct swi_workitem *wi);
 
-void srpc_get_counters(srpc_counters_t *cnt)
+void srpc_get_counters(struct srpc_counters *cnt)
 {
 	spin_lock(&srpc_data.rpc_glock);
 	*cnt = srpc_data.rpc_counters;
 	spin_unlock(&srpc_data.rpc_glock);
 }
 
-void srpc_set_counters(const srpc_counters_t *cnt)
+void srpc_set_counters(const struct srpc_counters *cnt)
 {
 	spin_lock(&srpc_data.rpc_glock);
 	srpc_data.rpc_counters = *cnt;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index f2987c5..a5b44db 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -162,7 +162,7 @@ struct srpc_stat_reply {
 	__u32		   str_status;
 	struct lst_sid	   str_sid;
 	sfw_counters_t	   str_fw;
-	srpc_counters_t    str_rpc;
+	struct srpc_counters	str_rpc;
 	lnet_counters_t    str_lnet;
 } WIRE_ATTR;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 79b05aa..1e5526c 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -453,8 +453,8 @@ struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
 int srpc_finish_service(struct srpc_service *sv);
 int srpc_service_add_buffers(struct srpc_service *sv, int nbuffer);
 void srpc_service_remove_buffers(struct srpc_service *sv, int nbuffer);
-void srpc_get_counters(srpc_counters_t *cnt);
-void srpc_set_counters(const srpc_counters_t *cnt);
+void srpc_get_counters(struct srpc_counters *cnt);
+void srpc_set_counters(const struct srpc_counters *cnt);
 
 extern struct cfs_wi_sched *lst_sched_serial;
 extern struct cfs_wi_sched **lst_sched_test;
-- 
1.8.3.1
