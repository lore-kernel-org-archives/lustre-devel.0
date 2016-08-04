From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:05 -0400
Subject: [lustre-devel] [PATCH 29/31] staging: lustre: osc: Automatically
	increase the max_dirty_mb
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Hongchao Zhang <hongchao.zhang@intel.com>

When RPC size or the max RPCs in flight is increased, the actual
limit might be max_dirty_mb. This patch automatically increases
the max_dirty_mb value at connection time and when the related
values are tuned manually by proc file system.

this patch also changes the unit of "cl_dirty" and "cl_dirty_max"
in client_obd from byte to page.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4933
Reviewed-on: http://review.whamcloud.com/10446
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h     |   28 +++++++++++++++++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c   |   12 +++++---
 drivers/staging/lustre/lustre/osc/lproc_osc.c   |   10 ++++---
 drivers/staging/lustre/lustre/osc/osc_cache.c   |   28 +++++++++---------
 drivers/staging/lustre/lustre/osc/osc_request.c |   34 +++++++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/import.c   |    1 +
 6 files changed, 74 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e7e03be..e91f65a 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -222,8 +222,8 @@ struct client_obd {
 	struct sptlrpc_flavor    cl_flvr_mgc;   /* fixed flavor of mgc->mgs */
 
 	/* the grant values are protected by loi_list_lock below */
-	long		     cl_dirty;	 /* all _dirty_ in bytes */
-	long		     cl_dirty_max;     /* allowed w/o rpc */
+	long		     cl_dirty_pages;	/* all _dirty_ in pahges */
+	long		     cl_dirty_max_pages;/* allowed w/o rpc */
 	long		     cl_dirty_transit; /* dirty synchronous */
 	long		     cl_avail_grant;   /* bytes of credit for ost */
 	long		     cl_lost_grant;    /* lost credits (trunc) */
@@ -1225,4 +1225,28 @@ static inline int cli_brw_size(struct obd_device *obd)
 	return obd->u.cli.cl_max_pages_per_rpc << PAGE_SHIFT;
 }
 
+/*
+ * when RPC size or the max RPCs in flight is increased, the max dirty pages
+ * of the client should be increased accordingly to avoid sending fragmented
+ * RPCs over the network when the client runs out of the maximum dirty space
+ * when so many RPCs are being generated.
+ */
+static inline void client_adjust_max_dirty(struct client_obd *cli)
+{
+	/* initializing */
+	if (cli->cl_dirty_max_pages <= 0)
+		cli->cl_dirty_max_pages =
+			(OSC_MAX_DIRTY_DEFAULT * 1024 * 1024) >> PAGE_SHIFT;
+	else {
+		long dirty_max = cli->cl_max_rpcs_in_flight *
+				 cli->cl_max_pages_per_rpc;
+
+		if (dirty_max > cli->cl_dirty_max_pages)
+			cli->cl_dirty_max_pages = dirty_max;
+	}
+
+	if (cli->cl_dirty_max_pages > totalram_pages / 8)
+		cli->cl_dirty_max_pages = totalram_pages / 8;
+}
+
 #endif /* __OBD_H */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index ee40006..3c98ce2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -299,12 +299,14 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	       min_t(unsigned int, LUSTRE_CFG_BUFLEN(lcfg, 2),
 		     sizeof(server_uuid)));
 
-	cli->cl_dirty = 0;
+	cli->cl_dirty_pages = 0;
 	cli->cl_avail_grant = 0;
-	/* FIXME: Should limit this for the sum of all cl_dirty_max. */
-	cli->cl_dirty_max = OSC_MAX_DIRTY_DEFAULT * 1024 * 1024;
-	if (cli->cl_dirty_max >> PAGE_SHIFT > totalram_pages / 8)
-		cli->cl_dirty_max = totalram_pages << (PAGE_SHIFT - 3);
+	/* FIXME: Should limit this for the sum of all cl_dirty_max_pages. */
+	/*
+	 * cl_dirty_max_pages may be changed@connect time in
+	 * ptlrpc_connect_interpret().
+	 */
+	client_adjust_max_dirty(cli);
 	INIT_LIST_HEAD(&cli->cl_cache_waiters);
 	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 7e83d39..9172b78 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -119,6 +119,7 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 
 	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_rpcs_in_flight = val;
+	client_adjust_max_dirty(cli);
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
@@ -136,10 +137,10 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	int mult;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	val = cli->cl_dirty_max;
+	val = cli->cl_dirty_max_pages;
 	spin_unlock(&cli->cl_loi_list_lock);
 
-	mult = 1 << 20;
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, val, mult);
 }
 
@@ -166,7 +167,7 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 		return -ERANGE;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_dirty_max = (u32)(pages_number << PAGE_SHIFT);
+	cli->cl_dirty_max_pages = pages_number;
 	osc_wake_cache_waiters(cli);
 	spin_unlock(&cli->cl_loi_list_lock);
 
@@ -244,7 +245,7 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 	int len;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%lu\n", cli->cl_dirty);
+	len = sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	return len;
@@ -583,6 +584,7 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 	}
 	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_pages_per_rpc = val;
+	client_adjust_max_dirty(cli);
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index deaf912..c6e37c0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1387,7 +1387,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
 	       "lru {in list: %d, left: %d, waiters: %d }" fmt,		      \
 	       __tmp->cl_import->imp_obd->obd_name,			      \
-	       __tmp->cl_dirty, __tmp->cl_dirty_max,			      \
+	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
 	       atomic_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
 	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
@@ -1403,7 +1403,7 @@ static void osc_consume_write_grant(struct client_obd *cli,
 	assert_spin_locked(&cli->cl_loi_list_lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
 	atomic_inc(&obd_dirty_pages);
-	cli->cl_dirty += PAGE_SIZE;
+	cli->cl_dirty_pages++;
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
 	       PAGE_SIZE, pga, pga->pg);
@@ -1423,11 +1423,11 @@ static void osc_release_write_grant(struct client_obd *cli,
 
 	pga->flag &= ~OBD_BRW_FROM_GRANT;
 	atomic_dec(&obd_dirty_pages);
-	cli->cl_dirty -= PAGE_SIZE;
+	cli->cl_dirty_pages--;
 	if (pga->flag & OBD_BRW_NOCACHE) {
 		pga->flag &= ~OBD_BRW_NOCACHE;
 		atomic_dec(&obd_dirty_transit_pages);
-		cli->cl_dirty_transit -= PAGE_SIZE;
+		cli->cl_dirty_transit--;
 	}
 }
 
@@ -1496,7 +1496,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 
 	spin_lock(&cli->cl_loi_list_lock);
 	atomic_sub(nr_pages, &obd_dirty_pages);
-	cli->cl_dirty -= nr_pages << PAGE_SHIFT;
+	cli->cl_dirty_pages -= nr_pages;
 	cli->cl_lost_grant += lost_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
 		/* borrow some grant from truncate to avoid the case that
@@ -1509,7 +1509,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 	spin_unlock(&cli->cl_loi_list_lock);
 	CDEBUG(D_CACHE, "lost %u grant: %lu avail: %lu dirty: %lu\n",
 	       lost_grant, cli->cl_lost_grant,
-	       cli->cl_avail_grant, cli->cl_dirty);
+	       cli->cl_avail_grant, cli->cl_dirty_pages << PAGE_SHIFT);
 }
 
 /**
@@ -1539,11 +1539,11 @@ static int osc_enter_cache_try(struct client_obd *cli,
 	if (rc < 0)
 		return 0;
 
-	if (cli->cl_dirty + PAGE_SIZE <= cli->cl_dirty_max &&
+	if (cli->cl_dirty_pages <= cli->cl_dirty_max_pages &&
 	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
-			cli->cl_dirty_transit += PAGE_SIZE;
+			cli->cl_dirty_transit++;
 			atomic_inc(&obd_dirty_transit_pages);
 			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
 		}
@@ -1590,8 +1590,8 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	 * of queued writes and create a discontiguous rpc stream
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
-	    cli->cl_dirty_max < PAGE_SIZE     ||
-	    cli->cl_ar.ar_force_sync || loi->loi_ar.ar_force_sync) {
+	    !cli->cl_dirty_max_pages || cli->cl_ar.ar_force_sync ||
+	    loi->loi_ar.ar_force_sync) {
 		rc = -EDQUOT;
 		goto out;
 	}
@@ -1612,7 +1612,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	init_waitqueue_head(&ocw.ocw_waitq);
 	ocw.ocw_oap   = oap;
 	ocw.ocw_grant = bytes;
-	while (cli->cl_dirty > 0 || cli->cl_w_in_flight > 0) {
+	while (cli->cl_dirty_pages > 0 || cli->cl_w_in_flight > 0) {
 		list_add_tail(&ocw.ocw_entry, &cli->cl_cache_waiters);
 		ocw.ocw_rc = 0;
 		spin_unlock(&cli->cl_loi_list_lock);
@@ -1667,11 +1667,11 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
-		if ((cli->cl_dirty + PAGE_SIZE > cli->cl_dirty_max) ||
+		if ((cli->cl_dirty_pages > cli->cl_dirty_max_pages) ||
 		    (atomic_read(&obd_dirty_pages) + 1 > obd_max_dirty_pages)) {
 			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
-			       cli->cl_dirty,
-			       cli->cl_dirty_max, obd_max_dirty_pages);
+			       cli->cl_dirty_pages, cli->cl_dirty_max_pages,
+			       obd_max_dirty_pages);
 			goto wakeup;
 		}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 90c8416..b1cfa1e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -801,11 +801,12 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 
 	oa->o_valid |= bits;
 	spin_lock(&cli->cl_loi_list_lock);
-	oa->o_dirty = cli->cl_dirty;
-	if (unlikely(cli->cl_dirty - cli->cl_dirty_transit >
-		     cli->cl_dirty_max)) {
+	oa->o_dirty = cli->cl_dirty_pages << PAGE_SHIFT;
+	if (unlikely(cli->cl_dirty_pages - cli->cl_dirty_transit >
+		     cli->cl_dirty_max_pages)) {
 		CERROR("dirty %lu - %lu > dirty_max %lu\n",
-		       cli->cl_dirty, cli->cl_dirty_transit, cli->cl_dirty_max);
+		       cli->cl_dirty_pages, cli->cl_dirty_transit,
+		       cli->cl_dirty_max_pages);
 		oa->o_undirty = 0;
 	} else if (unlikely(atomic_read(&obd_dirty_pages) -
 			    atomic_read(&obd_dirty_transit_pages) >
@@ -820,15 +821,17 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		       atomic_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
 		oa->o_undirty = 0;
-	} else if (unlikely(cli->cl_dirty_max - cli->cl_dirty > 0x7fffffff)) {
+	} else if (unlikely(cli->cl_dirty_max_pages - cli->cl_dirty_pages >
+		   0x7fffffff)) {
 		CERROR("dirty %lu - dirty_max %lu too big???\n",
-		       cli->cl_dirty, cli->cl_dirty_max);
+		       cli->cl_dirty_pages, cli->cl_dirty_max_pages);
 		oa->o_undirty = 0;
 	} else {
 		long max_in_flight = (cli->cl_max_pages_per_rpc <<
 				      PAGE_SHIFT)*
 				     (cli->cl_max_rpcs_in_flight + 1);
-		oa->o_undirty = max(cli->cl_dirty_max, max_in_flight);
+		oa->o_undirty = max(cli->cl_dirty_max_pages << PAGE_SHIFT,
+				    max_in_flight);
 	}
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
 	oa->o_dropped = cli->cl_lost_grant;
@@ -1028,22 +1031,24 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 {
 	/*
 	 * ocd_grant is the total grant amount we're expect to hold: if we've
-	 * been evicted, it's the new avail_grant amount, cl_dirty will drop
-	 * to 0 as inflight RPCs fail out; otherwise, it's avail_grant + dirty.
+	 * been evicted, it's the new avail_grant amount, cl_dirty_pages will
+	 * drop to 0 as inflight RPCs fail out; otherwise, it's avail_grant +
+	 * dirty.
 	 *
 	 * race is tolerable here: if we're evicted, but imp_state already
-	 * left EVICTED state, then cl_dirty must be 0 already.
+	 * left EVICTED state, then cl_dirty_pages must be 0 already.
 	 */
 	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_import->imp_state == LUSTRE_IMP_EVICTED)
 		cli->cl_avail_grant = ocd->ocd_grant;
 	else
-		cli->cl_avail_grant = ocd->ocd_grant - cli->cl_dirty;
+		cli->cl_avail_grant = ocd->ocd_grant -
+				      (cli->cl_dirty_pages << PAGE_SHIFT);
 
 	if (cli->cl_avail_grant < 0) {
 		CWARN("%s: available grant < 0: avail/ocd/dirty %ld/%u/%ld\n",
 		      cli->cl_import->imp_obd->obd_name, cli->cl_avail_grant,
-		      ocd->ocd_grant, cli->cl_dirty);
+		      ocd->ocd_grant, cli->cl_dirty_pages << PAGE_SHIFT);
 		/* workaround for servers which do not have the patch from
 		 * LU-2679
 		 */
@@ -3014,8 +3019,9 @@ static int osc_reconnect(const struct lu_env *env,
 		long lost_grant;
 
 		spin_lock(&cli->cl_loi_list_lock);
-		data->ocd_grant = (cli->cl_avail_grant + cli->cl_dirty) ?:
-				2 * cli_brw_size(obd);
+		data->ocd_grant = (cli->cl_avail_grant +
+				   cli->cl_dirty_pages << PAGE_SHIFT) ?:
+				   2 * cli_brw_size(obd);
 		lost_grant = cli->cl_lost_grant;
 		cli->cl_lost_grant = 0;
 		spin_unlock(&cli->cl_loi_list_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index af8ffbc..c0122ef 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1132,6 +1132,7 @@ finish:
 
 		LASSERT((cli->cl_max_pages_per_rpc <= PTLRPC_MAX_BRW_PAGES) &&
 			(cli->cl_max_pages_per_rpc > 0));
+		client_adjust_max_dirty(cli);
 	}
 
 out:
-- 
1.7.1
