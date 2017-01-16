From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:37 -0500
Subject: [lustre-devel] [PATCH 34/34] staging: lustre: lnet: change
	sfw_counter_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change sfw_counter_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/console.c     | 4 ++--
 drivers/staging/lustre/lnet/selftest/framework.c   | 2 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 575d23a..c81c246 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -511,13 +511,13 @@ struct srpc_counters {
 	__u64 bulk_put;
 } WIRE_ATTR;
 
-typedef struct {
+struct sfw_counters {
 	/** milliseconds since current session started */
 	__u32 running_ms;
 	__u32 active_batches;
 	__u32 zombie_sessions;
 	__u32 brw_errors;
 	__u32 ping_errors;
-} WIRE_ATTR sfw_counters_t;
+} WIRE_ATTR;
 
 #endif
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 483a1bb..4e7e5c8 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1467,14 +1467,14 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 		       struct lstcon_rpc_ent __user *ent_up)
 {
 	struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
-	sfw_counters_t __user *sfwk_stat;
+	struct sfw_counters __user *sfwk_stat;
 	struct srpc_counters __user *srpc_stat;
 	lnet_counters_t __user *lnet_stat;
 
 	if (rep->str_status)
 		return 0;
 
-	sfwk_stat = (sfw_counters_t __user *)&ent_up->rpe_payload[0];
+	sfwk_stat = (struct sfw_counters __user *)&ent_up->rpe_payload[0];
 	srpc_stat = (struct srpc_counters __user *)(sfwk_stat + 1);
 	lnet_stat = (lnet_counters_t __user *)(srpc_stat + 1);
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 5ca6712..436aef3 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -361,7 +361,7 @@
 sfw_get_stats(struct srpc_stat_reqst *request, struct srpc_stat_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
-	sfw_counters_t *cnt = &reply->str_fw;
+	struct sfw_counters *cnt = &reply->str_fw;
 	struct sfw_batch *bat;
 
 	reply->str_sid = !sn ? LST_INVALID_SID : sn->sn_id;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index a5b44db..418c9c9 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -161,7 +161,7 @@ struct srpc_stat_reqst {
 struct srpc_stat_reply {
 	__u32		   str_status;
 	struct lst_sid	   str_sid;
-	sfw_counters_t	   str_fw;
+	struct sfw_counters	str_fw;
 	struct srpc_counters	str_rpc;
 	lnet_counters_t    str_lnet;
 } WIRE_ATTR;
-- 
1.8.3.1
