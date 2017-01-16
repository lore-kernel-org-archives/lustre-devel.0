From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:11 -0500
Subject: [lustre-devel] [PATCH 08/34] staging: lustre: lnet: change
	lstcon_rpc_ent_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_rpc_ent_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.h      | 2 +-
 drivers/staging/lustre/lnet/selftest/console.c     | 6 +++---
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index adc03fe..f5c68c1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -124,7 +124,7 @@ struct lstcon_test_batch_ent {
 };				/*** test/batch verbose information entry,
 				 *** for list_batch command */
 
-typedef struct {
+struct lstcon_rpc_ent {
 	struct list_head	rpe_link;	/* link chain */
 	lnet_process_id_t	rpe_peer;	/* peer's id */
 	struct timeval		rpe_stamp;	/* time stamp of RPC */
@@ -135,7 +135,7 @@ struct lstcon_test_batch_ent {
 	int			rpe_fwk_errno;	/* framework errno */
 	int			rpe_priv[4];	/* private data */
 	char			rpe_payload[0];	/* private reply payload */
-} lstcon_rpc_ent_t;
+};
 
 typedef struct {
 	int	trs_rpc_stat[4];	/* RPCs stat (0: total
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 84ae010..bc924f9 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -469,7 +469,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 {
 	struct list_head tmp;
 	struct list_head __user *next;
-	lstcon_rpc_ent_t *ent;
+	struct lstcon_rpc_ent *ent;
 	struct srpc_generic_reply *rep;
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *msg;
@@ -492,7 +492,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 		next = tmp.next;
 
-		ent = list_entry(next, lstcon_rpc_ent_t, rpe_link);
+		ent = list_entry(next, struct lstcon_rpc_ent, rpe_link);
 
 		LASSERT(crpc->crp_stamp);
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index e629e87..ad0a49e 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -103,7 +103,7 @@ struct lstcon_rpc_trans {
 
 typedef int (*lstcon_rpc_cond_func_t)(int, struct lstcon_node *, void *);
 typedef int (*lstcon_rpc_readent_func_t)(int, struct srpc_msg *,
-					 lstcon_rpc_ent_t __user *);
+					 struct lstcon_rpc_ent __user *);
 
 int  lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
 			unsigned int version, struct lstcon_rpc **crpc);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index bf4111a..b01023c 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -368,7 +368,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_sesrpc_readent(int transop, struct srpc_msg *msg,
-		      lstcon_rpc_ent_t __user *ent_up)
+		      struct lstcon_rpc_ent __user *ent_up)
 {
 	struct srpc_debug_reply *rep;
 
@@ -1385,7 +1385,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_tsbrpc_readent(int transop, struct srpc_msg *msg,
-		      lstcon_rpc_ent_t __user *ent_up)
+		      struct lstcon_rpc_ent __user *ent_up)
 {
 	struct srpc_batch_reply *rep = &msg->msg_body.bat_reply;
 
@@ -1464,7 +1464,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_statrpc_readent(int transop, struct srpc_msg *msg,
-		       lstcon_rpc_ent_t __user *ent_up)
+		       struct lstcon_rpc_ent __user *ent_up)
 {
 	struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
 	sfw_counters_t __user *sfwk_stat;
-- 
1.8.3.1
