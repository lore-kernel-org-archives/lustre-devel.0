From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:12 -0500
Subject: [lustre-devel] [PATCH 09/34] staging: lustre: lnet: change
	lstcon_trans_stat_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_trans_stat_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 34 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/conctl.c      |  4 +--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  8 ++---
 drivers/staging/lustre/lnet/selftest/conrpc.h      |  2 +-
 drivers/staging/lustre/lnet/selftest/console.h     |  4 +--
 5 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index f5c68c1..48dc06f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -137,7 +137,7 @@ struct lstcon_rpc_ent {
 	char			rpe_payload[0];	/* private reply payload */
 };
 
-typedef struct {
+struct lstcon_trans_stat {
 	int	trs_rpc_stat[4];	/* RPCs stat (0: total
 						      1: failed
 						      2: finished
@@ -146,94 +146,94 @@ struct lstcon_rpc_ent {
 	int	trs_fwk_stat[8];	/* framework stat */
 	int	trs_fwk_errno;		/* errno of the first remote error */
 	void	*trs_fwk_private;	/* private framework stat */
-} lstcon_trans_stat_t;
+};
 
 static inline int
-lstcon_rpc_stat_total(lstcon_trans_stat_t *stat, int inc)
+lstcon_rpc_stat_total(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_rpc_stat[0] : stat->trs_rpc_stat[0];
 }
 
 static inline int
-lstcon_rpc_stat_success(lstcon_trans_stat_t *stat, int inc)
+lstcon_rpc_stat_success(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_rpc_stat[1] : stat->trs_rpc_stat[1];
 }
 
 static inline int
-lstcon_rpc_stat_failure(lstcon_trans_stat_t *stat, int inc)
+lstcon_rpc_stat_failure(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_rpc_stat[2] : stat->trs_rpc_stat[2];
 }
 
 static inline int
-lstcon_sesop_stat_success(lstcon_trans_stat_t *stat, int inc)
+lstcon_sesop_stat_success(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[0] : stat->trs_fwk_stat[0];
 }
 
 static inline int
-lstcon_sesop_stat_failure(lstcon_trans_stat_t *stat, int inc)
+lstcon_sesop_stat_failure(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[1] : stat->trs_fwk_stat[1];
 }
 
 static inline int
-lstcon_sesqry_stat_active(lstcon_trans_stat_t *stat, int inc)
+lstcon_sesqry_stat_active(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[0] : stat->trs_fwk_stat[0];
 }
 
 static inline int
-lstcon_sesqry_stat_busy(lstcon_trans_stat_t *stat, int inc)
+lstcon_sesqry_stat_busy(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[1] : stat->trs_fwk_stat[1];
 }
 
 static inline int
-lstcon_sesqry_stat_unknown(lstcon_trans_stat_t *stat, int inc)
+lstcon_sesqry_stat_unknown(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[2] : stat->trs_fwk_stat[2];
 }
 
 static inline int
-lstcon_tsbop_stat_success(lstcon_trans_stat_t *stat, int inc)
+lstcon_tsbop_stat_success(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[0] : stat->trs_fwk_stat[0];
 }
 
 static inline int
-lstcon_tsbop_stat_failure(lstcon_trans_stat_t *stat, int inc)
+lstcon_tsbop_stat_failure(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[1] : stat->trs_fwk_stat[1];
 }
 
 static inline int
-lstcon_tsbqry_stat_idle(lstcon_trans_stat_t *stat, int inc)
+lstcon_tsbqry_stat_idle(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[0] : stat->trs_fwk_stat[0];
 }
 
 static inline int
-lstcon_tsbqry_stat_run(lstcon_trans_stat_t *stat, int inc)
+lstcon_tsbqry_stat_run(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[1] : stat->trs_fwk_stat[1];
 }
 
 static inline int
-lstcon_tsbqry_stat_failure(lstcon_trans_stat_t *stat, int inc)
+lstcon_tsbqry_stat_failure(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[2] : stat->trs_fwk_stat[2];
 }
 
 static inline int
-lstcon_statqry_stat_success(lstcon_trans_stat_t *stat, int inc)
+lstcon_statqry_stat_success(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[0] : stat->trs_fwk_stat[0];
 }
 
 static inline int
-lstcon_statqry_stat_failure(lstcon_trans_stat_t *stat, int inc)
+lstcon_statqry_stat_failure(struct lstcon_trans_stat *stat, int inc)
 {
 	return inc ? ++stat->trs_fwk_stat[1] : stat->trs_fwk_stat[1];
 }
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 9438302..a897738 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -851,7 +851,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		goto out;
 	}
 
-	memset(&console_session.ses_trans_stat, 0, sizeof(lstcon_trans_stat_t));
+	memset(&console_session.ses_trans_stat, 0, sizeof(struct lstcon_trans_stat));
 
 	switch (opc) {
 	case LSTIO_SESSION_NEW:
@@ -913,7 +913,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	}
 
 	if (copy_to_user(data->ioc_pbuf2, &console_session.ses_trans_stat,
-			 sizeof(lstcon_trans_stat_t)))
+			 sizeof(struct lstcon_trans_stat)))
 		rc = -EFAULT;
 out:
 	mutex_unlock(&console_session.ses_mutex);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bc924f9..3b97915 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -43,7 +43,7 @@
 #include "console.h"
 
 void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
-			   struct lstcon_node *, lstcon_trans_stat_t *);
+			   struct lstcon_node *, struct lstcon_trans_stat *);
 
 static void
 lstcon_rpc_done(struct srpc_client_rpc *rpc)
@@ -420,7 +420,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 void
-lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans, lstcon_trans_stat_t *stat)
+lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans, struct lstcon_trans_stat *stat)
 {
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *rep;
@@ -964,7 +964,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 void
 lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, struct srpc_msg *msg,
-		      struct lstcon_node *nd, lstcon_trans_stat_t *stat)
+		      struct lstcon_node *nd, struct lstcon_trans_stat *stat)
 {
 	struct srpc_rmsn_reply *rmsn_rep;
 	struct srpc_debug_reply *dbg_rep;
@@ -1320,7 +1320,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	lstcon_rpc_trans_stat(console_session.ses_ping, lstcon_trans_stat());
 	lstcon_rpc_trans_destroy(console_session.ses_ping);
 
-	memset(lstcon_trans_stat(), 0, sizeof(lstcon_trans_stat_t));
+	memset(lstcon_trans_stat(), 0, sizeof(struct lstcon_trans_stat));
 
 	console_session.ses_ping = NULL;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index ad0a49e..7141d2c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -125,7 +125,7 @@ int  lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 			     void *arg, lstcon_rpc_cond_func_t condition,
 			     struct lstcon_rpc_trans **transpp);
 void lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans,
-			   lstcon_trans_stat_t *stat);
+			   struct lstcon_trans_stat *stat);
 int  lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 				  struct list_head __user *head_up,
 				  lstcon_rpc_readent_func_t readent);
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index f8d61ce..05b4b70 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -158,7 +158,7 @@ struct lstcon_session {
 	char		    ses_name[LST_NAME_SIZE];/* session name */
 	struct lstcon_rpc_trans	*ses_ping;		/* session pinger */
 	struct stt_timer	 ses_ping_timer;   /* timer for pinger */
-	lstcon_trans_stat_t ses_trans_stat;   /* transaction stats */
+	struct lstcon_trans_stat ses_trans_stat;   /* transaction stats */
 
 	struct list_head    ses_trans_list;   /* global list of transaction */
 	struct list_head    ses_grp_list;     /* global list of groups */
@@ -173,7 +173,7 @@ struct lstcon_session {
 
 extern struct lstcon_session	 console_session;
 
-static inline lstcon_trans_stat_t *
+static inline struct lstcon_trans_stat *
 lstcon_trans_stat(void)
 {
 	return &console_session.ses_trans_stat;
-- 
1.8.3.1
