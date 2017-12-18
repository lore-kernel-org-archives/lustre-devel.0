From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:41:42 +1100
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: replace cfs_rand() with
 prandom_u32_max()
In-Reply-To: <151356119565.24290.5570928075046338898.stgit@noble>
References: <151356119565.24290.5570928075046338898.stgit@noble>
Message-ID: <151356130236.24290.3477673707432595018.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

All occurrences of
   cfs_rand() % X
are replaced with
   prandom_u32_max(X)

cfs_rand() is a simple Linear Congruential PRNG.  prandom_u32_max()
is at least as random, is seeded with more randomness, and uses
cpu-local state to avoid cross-cpu issues.

This is the first step is discarding the libcfs prng with
the standard linux prng.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/fail.c       |    2 +
 drivers/staging/lustre/lnet/lnet/net_fault.c    |   38 ++++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router.c       |    4 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c |    4 +-
 4 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 5d501beeb622..39439b303d65 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -61,7 +61,7 @@ int __cfs_fail_check_set(u32 id, u32 value, int set)
 
 	/* Fail 1/cfs_fail_val times */
 	if (cfs_fail_loc & CFS_FAIL_RAND) {
-		if (cfs_fail_val < 2 || cfs_rand() % cfs_fail_val > 0)
+		if (cfs_fail_val < 2 || prandom_u32_max(cfs_fail_val) > 0)
 			return 0;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 0318e64c413f..e3468cef273b 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -170,10 +170,10 @@ lnet_drop_rule_add(struct lnet_fault_attr *attr)
 	rule->dr_attr = *attr;
 	if (attr->u.drop.da_interval) {
 		rule->dr_time_base = cfs_time_shift(attr->u.drop.da_interval);
-		rule->dr_drop_time = cfs_time_shift(cfs_rand() %
-						    attr->u.drop.da_interval);
+		rule->dr_drop_time = cfs_time_shift(
+			prandom_u32_max(attr->u.drop.da_interval));
 	} else {
-		rule->dr_drop_at = cfs_rand() % attr->u.drop.da_rate;
+		rule->dr_drop_at = prandom_u32_max(attr->u.drop.da_rate);
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
@@ -277,10 +277,10 @@ lnet_drop_rule_reset(void)
 
 		memset(&rule->dr_stat, 0, sizeof(rule->dr_stat));
 		if (attr->u.drop.da_rate) {
-			rule->dr_drop_at = cfs_rand() % attr->u.drop.da_rate;
+			rule->dr_drop_at = prandom_u32_max(attr->u.drop.da_rate);
 		} else {
-			rule->dr_drop_time = cfs_time_shift(cfs_rand() %
-						attr->u.drop.da_interval);
+			rule->dr_drop_time = cfs_time_shift(
+				prandom_u32_max(attr->u.drop.da_interval));
 			rule->dr_time_base = cfs_time_shift(attr->u.drop.da_interval);
 		}
 		spin_unlock(&rule->dr_lock);
@@ -315,8 +315,8 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
 				rule->dr_time_base = now;
 
 			rule->dr_drop_time = rule->dr_time_base +
-					     cfs_time_seconds(cfs_rand() %
-						attr->u.drop.da_interval);
+				cfs_time_seconds(
+					prandom_u32_max(attr->u.drop.da_interval));
 			rule->dr_time_base += cfs_time_seconds(attr->u.drop.da_interval);
 
 			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lu\n",
@@ -330,7 +330,7 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
 
 		if (!do_div(rule->dr_stat.fs_count, attr->u.drop.da_rate)) {
 			rule->dr_drop_at = rule->dr_stat.fs_count +
-					   cfs_rand() % attr->u.drop.da_rate;
+				prandom_u32_max(attr->u.drop.da_rate);
 			CDEBUG(D_NET, "Drop Rule %s->%s: next drop: %lu\n",
 			       libcfs_nid2str(attr->fa_src),
 			       libcfs_nid2str(attr->fa_dst), rule->dr_drop_at);
@@ -483,8 +483,9 @@ delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
 				rule->dl_time_base = now;
 
 			rule->dl_delay_time = rule->dl_time_base +
-					     cfs_time_seconds(cfs_rand() %
-						attr->u.delay.la_interval);
+				cfs_time_seconds(
+					prandom_u32_max(
+						attr->u.delay.la_interval));
 			rule->dl_time_base += cfs_time_seconds(attr->u.delay.la_interval);
 
 			CDEBUG(D_NET, "Delay Rule %s->%s: next delay : %lu\n",
@@ -498,7 +499,7 @@ delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
 		/* generate the next random rate sequence */
 		if (!do_div(rule->dl_stat.fs_count, attr->u.delay.la_rate)) {
 			rule->dl_delay_at = rule->dl_stat.fs_count +
-					    cfs_rand() % attr->u.delay.la_rate;
+				prandom_u32_max(attr->u.delay.la_rate);
 			CDEBUG(D_NET, "Delay Rule %s->%s: next delay: %lu\n",
 			       libcfs_nid2str(attr->fa_src),
 			       libcfs_nid2str(attr->fa_dst), rule->dl_delay_at);
@@ -771,10 +772,10 @@ lnet_delay_rule_add(struct lnet_fault_attr *attr)
 	rule->dl_attr = *attr;
 	if (attr->u.delay.la_interval) {
 		rule->dl_time_base = cfs_time_shift(attr->u.delay.la_interval);
-		rule->dl_delay_time = cfs_time_shift(cfs_rand() %
-						     attr->u.delay.la_interval);
+		rule->dl_delay_time = cfs_time_shift(
+			prandom_u32_max(attr->u.delay.la_interval));
 	} else {
-		rule->dl_delay_at = cfs_rand() % attr->u.delay.la_rate;
+		rule->dl_delay_at = prandom_u32_max(attr->u.delay.la_rate);
 	}
 
 	rule->dl_msg_send = -1;
@@ -920,10 +921,11 @@ lnet_delay_rule_reset(void)
 
 		memset(&rule->dl_stat, 0, sizeof(rule->dl_stat));
 		if (attr->u.delay.la_rate) {
-			rule->dl_delay_at = cfs_rand() % attr->u.delay.la_rate;
+			rule->dl_delay_at = prandom_u32_max(attr->u.delay.la_rate);
 		} else {
-			rule->dl_delay_time = cfs_time_shift(cfs_rand() %
-						attr->u.delay.la_interval);
+			rule->dl_delay_time =
+				cfs_time_shift(prandom_u32_max(
+						       attr->u.delay.la_interval));
 			rule->dl_time_base = cfs_time_shift(attr->u.delay.la_interval);
 		}
 		spin_unlock(&rule->dl_lock);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index c40aa79baf5c..e5c9b29e199f 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -277,8 +277,8 @@ lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
 		len++;
 	}
 
-	/* len+1 positions to add a new entry, also prevents division by 0 */
-	offset = cfs_rand() % (len + 1);
+	/* len+1 positions to add a new entry */
+	offset = prandom_u32_max(len + 1);
 	list_for_each(e, &rnet->lrn_routes) {
 		if (!offset)
 			break;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 77fa8fea0249..79ff85feab64 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -523,7 +523,7 @@ static void do_requeue(struct config_llog_data *cld)
  * in order to not flood the MGS.
  */
 #define MGC_TIMEOUT_MIN_SECONDS   5
-#define MGC_TIMEOUT_RAND_CENTISEC 0x1ff /* ~500 */
+#define MGC_TIMEOUT_RAND_CENTISEC 500
 
 static int mgc_requeue_thread(void *data)
 {
@@ -537,7 +537,7 @@ static int mgc_requeue_thread(void *data)
 	while (!(rq_state & RQ_STOP)) {
 		struct l_wait_info lwi;
 		struct config_llog_data *cld, *cld_prev;
-		int rand = cfs_rand() & MGC_TIMEOUT_RAND_CENTISEC;
+		int rand = prandom_u32_max(MGC_TIMEOUT_RAND_CENTISEC);
 		int to;
 
 		/* Any new or requeued lostlocks will change the state */
