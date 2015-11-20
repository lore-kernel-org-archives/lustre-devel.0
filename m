From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:52 -0500
Subject: [lustre-devel] [PATCH 16/40] staging: lustre: make local functions
	static for LNet ni
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

This reduces the code size by about 400 bytes.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11306
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 ---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   10 +++++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 63919dd..874af17 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -690,9 +690,6 @@ void lnet_router_checker_stop(void);
 void lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net);
 void lnet_swap_pinginfo(lnet_ping_info_t *info);
 
-int lnet_ping(lnet_process_id_t id, int timeout_ms,
-	      lnet_process_id_t *ids, int n_ids);
-
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
 int lnet_parse_routes(char *route_str, int *im_a_router);
 int lnet_parse_networks(struct list_head *nilist, char *networks);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 125d018..3b2bfd5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -62,6 +62,10 @@ static int rnet_htable_size = LNET_REMOTE_NETS_HASH_DEFAULT;
 module_param(rnet_htable_size, int, 0444);
 MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
 
+static void lnet_ping_target_fini(void);
+static int lnet_ping(lnet_process_id_t id, int timeout_ms,
+		     lnet_process_id_t *ids, int n_ids);
+
 static char *
 lnet_get_routes(void)
 {
@@ -520,7 +524,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
 	list_add(&lh->lh_hash_chain, &rec->rec_lh_hash[hash]);
 }
 
-int lnet_unprepare(void);
+static int lnet_unprepare(void);
 
 static int
 lnet_prepare(lnet_pid_t requested_pid)
@@ -606,7 +610,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	return rc;
 }
 
-int
+static int
 lnet_unprepare(void)
 {
 	/* NB no LNET_LOCK since this is the last reference.  All LND instances
@@ -2080,7 +2084,7 @@ LNetSnprintHandle(char *str, int len, lnet_handle_any_t h)
 }
 EXPORT_SYMBOL(LNetSnprintHandle);
 
-int
+static int
 lnet_ping(lnet_process_id_t id, int timeout_ms, lnet_process_id_t *ids, int n_ids)
 {
 	lnet_handle_eq_t eqh;
-- 
1.7.1
