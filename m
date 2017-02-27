From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:48 -0500
Subject: [lustre-devel] [PATCH 23/34] staging: lustre: lnet: change
	lnet_counter_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_counter_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  2 +-
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  2 +-
 drivers/staging/lustre/include/linux/lnet/types.h     |  4 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 10 +++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c            |  6 +++---
 drivers/staging/lustre/lnet/lnet/router_proc.c        |  2 +-
 drivers/staging/lustre/lnet/selftest/console.c        |  4 ++--
 drivers/staging/lustre/lnet/selftest/rpc.h            |  2 +-
 8 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 4ffe79c..4a1e0a1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -603,7 +603,7 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 
 /** @} lnet_fault_simulation */
 
-void lnet_counters_get(lnet_counters_t *counters);
+void lnet_counters_get(struct lnet_counters *counters);
 void lnet_counters_reset(void);
 
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index ffc961f..c98af93 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -573,7 +573,7 @@ struct lnet {
 	struct cfs_percpt_lock		 *ln_net_lock;
 	/* percpt message containers for active/finalizing/freed message */
 	struct lnet_msg_container	**ln_msg_containers;
-	lnet_counters_t			**ln_counters;
+	struct lnet_counters		**ln_counters;
 	struct lnet_peer_table		**ln_peer_tables;
 	/* failure simulation */
 	struct list_head		  ln_test_peers;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index e81b079..d2af335 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -250,7 +250,7 @@ struct lnet_ping_info {
 	struct lnet_ni_status	pi_ni[0];
 } WIRE_ATTR;
 
-typedef struct lnet_counters {
+struct lnet_counters {
 	__u32	msgs_alloc;
 	__u32	msgs_max;
 	__u32	errors;
@@ -262,7 +262,7 @@ struct lnet_ping_info {
 	__u64	recv_length;
 	__u64	route_length;
 	__u64	drop_length;
-} WIRE_ATTR lnet_counters_t;
+} WIRE_ATTR;
 
 #define LNET_NI_STATUS_UP      0x15aac0de
 #define LNET_NI_STATUS_DOWN    0xdeadface
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 024b8e3..34b9b10 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -315,9 +315,9 @@ static void lnet_assert_wire_constants(void)
 EXPORT_SYMBOL(lnet_unregister_lnd);
 
 void
-lnet_counters_get(lnet_counters_t *counters)
+lnet_counters_get(struct lnet_counters *counters)
 {
-	lnet_counters_t *ctr;
+	struct lnet_counters *ctr;
 	int i;
 
 	memset(counters, 0, sizeof(*counters));
@@ -344,13 +344,13 @@ static void lnet_assert_wire_constants(void)
 void
 lnet_counters_reset(void)
 {
-	lnet_counters_t *counters;
+	struct lnet_counters *counters;
 	int i;
 
 	lnet_net_lock(LNET_LOCK_EX);
 
 	cfs_percpt_for_each(counters, i, the_lnet.ln_counters)
-		memset(counters, 0, sizeof(lnet_counters_t));
+		memset(counters, 0, sizeof(struct lnet_counters));
 
 	lnet_net_unlock(LNET_LOCK_EX);
 }
@@ -560,7 +560,7 @@ struct lnet_libhandle *
 	the_lnet.ln_interface_cookie = ktime_get_ns();
 
 	the_lnet.ln_counters = cfs_percpt_alloc(lnet_cpt_table(),
-						sizeof(lnet_counters_t));
+						sizeof(struct lnet_counters));
 	if (!the_lnet.ln_counters) {
 		CERROR("Failed to allocate counters for LNet\n");
 		rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 128c335..4b5e3a8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -132,7 +132,7 @@
 lnet_msg_commit(struct lnet_msg *msg, int cpt)
 {
 	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
-	lnet_counters_t *counters  = the_lnet.ln_counters[cpt];
+	struct lnet_counters *counters  = the_lnet.ln_counters[cpt];
 
 	/* routed message can be committed for both receiving and sending */
 	LASSERT(!msg->msg_tx_committed);
@@ -164,7 +164,7 @@
 static void
 lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 {
-	lnet_counters_t	*counters;
+	struct lnet_counters	*counters;
 	lnet_event_t *ev = &msg->msg_ev;
 
 	LASSERT(msg->msg_tx_committed);
@@ -216,7 +216,7 @@
 static void
 lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 {
-	lnet_counters_t *counters;
+	struct lnet_counters *counters;
 	lnet_event_t *ev = &msg->msg_ev;
 
 	LASSERT(!msg->msg_tx_committed); /* decommitted or never committed */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 0065cc1..72b80c5 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -77,7 +77,7 @@ static int __proc_lnet_stats(void *data, int write,
 			     loff_t pos, void __user *buffer, int nob)
 {
 	int rc;
-	lnet_counters_t *ctrs;
+	struct lnet_counters *ctrs;
 	int len;
 	char *tmpstr;
 	const int tmpsiz = 256; /* 7 %u and 4 %llu */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 4e7e5c8..358cae8 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1469,14 +1469,14 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
 	struct sfw_counters __user *sfwk_stat;
 	struct srpc_counters __user *srpc_stat;
-	lnet_counters_t __user *lnet_stat;
+	struct lnet_counters __user *lnet_stat;
 
 	if (rep->str_status)
 		return 0;
 
 	sfwk_stat = (struct sfw_counters __user *)&ent_up->rpe_payload[0];
 	srpc_stat = (struct srpc_counters __user *)(sfwk_stat + 1);
-	lnet_stat = (lnet_counters_t __user *)(srpc_stat + 1);
+	lnet_stat = (struct lnet_counters __user *)(srpc_stat + 1);
 
 	if (copy_to_user(sfwk_stat, &rep->str_fw, sizeof(*sfwk_stat)) ||
 	    copy_to_user(srpc_stat, &rep->str_rpc, sizeof(*srpc_stat)) ||
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 418c9c9..a765537 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -163,7 +163,7 @@ struct srpc_stat_reply {
 	struct lst_sid	   str_sid;
 	struct sfw_counters	str_fw;
 	struct srpc_counters	str_rpc;
-	lnet_counters_t    str_lnet;
+	struct lnet_counters    str_lnet;
 } WIRE_ATTR;
 
 struct test_bulk_req {
-- 
1.8.3.1
