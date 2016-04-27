From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:06 -0400
Subject: [lustre-devel] [PATCH 14/15] staging: lustre: osc: Use SOFT_SYNC to
	urge server commit
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Prakash Surya <surya1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Prakash Surya <surya1@llnl.gov>

This change adds a BRW page flag, OBD_BRW_SOFT_SYNC. This flag is
intended to urge a server to commit a client's unstable pages to
stable storage. A client will add this flag to any BRW requests while
it is in a state where it has "many" unstable pages pinned in its cache.

The server, upon receiving a page with this flag set, *should* begin
an async commit. The idea being that, with the proactive async commit,
the client's pinned unstable pages will transition into a stable state
faster than they would have otherwise. Although, the server side portion
of this agreement is still unimplemented, so the OBD_BRW_SOFT_SYNC flag
will currently fall on deaf ears.

Signed-off-by: Prakash Surya <surya1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2139
Reviewed-on: http://review.whamcloud.com/4375
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    5 +++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    3 ++
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    1 +
 drivers/staging/lustre/lustre/osc/osc_page.c       |   29 ++++++++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    6 ++++
 6 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c3565bf..26819ee 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1734,6 +1734,11 @@ void lustre_swab_obd_statfs(struct obd_statfs *os);
 #define OBD_BRW_MEMALLOC       0x800 /* Client runs in the "kswapd" context */
 #define OBD_BRW_OVER_USRQUOTA 0x1000 /* Running out of user quota */
 #define OBD_BRW_OVER_GRPQUOTA 0x2000 /* Running out of group quota */
+#define OBD_BRW_SOFT_SYNC     0x4000 /* This flag notifies the server
+				      * that the client is running low on
+				      * space for unstable pages; asking
+				      * it to sync quickly
+				      */
 
 #define OBD_OBJECT_EOF 0xffffffffffffffffULL
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 7d1c2c5..5a14bea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2437,6 +2437,9 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			return rc;
 	}
 
+	if (osc_over_unstable_soft_limit(cli))
+		brw_flags |= OBD_BRW_SOFT_SYNC;
+
 	oap->oap_cmd = cmd;
 	oap->oap_page_off = ops->ops_from;
 	oap->oap_count = ops->ops_to - ops->ops_from;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 39e6138..7fad827 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -202,6 +202,7 @@ int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk);
 void osc_inc_unstable_pages(struct ptlrpc_request *req);
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
+int  osc_over_unstable_soft_limit(struct client_obd *cli);
 
 struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 5ec5508..c29c2ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -346,6 +346,32 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	return result;
 }
 
+int osc_over_unstable_soft_limit(struct client_obd *cli)
+{
+	long obd_upages, obd_dpages, osc_upages;
+
+	/* Can't check cli->cl_unstable_count, therefore, no soft limit */
+	if (!cli)
+		return 0;
+
+	obd_upages = atomic_read(&obd_unstable_pages);
+	obd_dpages = atomic_read(&obd_dirty_pages);
+
+	osc_upages = atomic_read(&cli->cl_unstable_count);
+
+	/*
+	 * obd_max_dirty_pages is the max number of (dirty + unstable)
+	 * pages allowed at any given time. To simulate an unstable page
+	 * only limit, we subtract the current number of dirty pages
+	 * from this max. This difference is roughly the amount of pages
+	 * currently available for unstable pages. Thus, the soft limit
+	 * is half of that difference. Check osc_upages to ensure we don't
+	 * set SOFT_SYNC for OSCs without any outstanding unstable pages.
+	 */
+	return osc_upages &&
+	       obd_upages >= (obd_max_dirty_pages - obd_dpages) / 2;
+}
+
 /**
  * Helper function called by osc_io_submit() for every page in an immediate
  * transfer (i.e., transferred synchronously).
@@ -369,6 +395,9 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_count = opg->ops_to - opg->ops_from;
 	oap->oap_brw_flags = brw_flags | OBD_BRW_SYNC;
 
+	if (osc_over_unstable_soft_limit(oap->oap_cli))
+		oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
+
 	if (!client_is_remote(osc_export(obj)) &&
 	    capable(CFS_CAP_SYS_RESOURCE)) {
 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e8a80eb..df06f4f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1147,7 +1147,8 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 {
 	if (p1->flag != p2->flag) {
 		unsigned mask = ~(OBD_BRW_FROM_GRANT | OBD_BRW_NOCACHE |
-				  OBD_BRW_SYNC | OBD_BRW_ASYNC|OBD_BRW_NOQUOTA);
+				  OBD_BRW_SYNC | OBD_BRW_ASYNC |
+				  OBD_BRW_NOQUOTA | OBD_BRW_SOFT_SYNC);
 
 		/* warn if we try to combine flags that we don't know to be
 		 * safe to combine
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 3ffd2d9..87555e4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1639,6 +1639,12 @@ void lustre_assert_wire_constants(void)
 		OBD_BRW_ASYNC);
 	LASSERTF(OBD_BRW_MEMALLOC == 0x800, "found 0x%.8x\n",
 		OBD_BRW_MEMALLOC);
+	LASSERTF(OBD_BRW_OVER_USRQUOTA == 0x1000, "found 0x%.8x\n",
+		 OBD_BRW_OVER_USRQUOTA);
+	LASSERTF(OBD_BRW_OVER_GRPQUOTA == 0x2000, "found 0x%.8x\n",
+		 OBD_BRW_OVER_GRPQUOTA);
+	LASSERTF(OBD_BRW_SOFT_SYNC == 0x4000, "found 0x%.8x\n",
+		 OBD_BRW_SOFT_SYNC);
 
 	/* Checks for struct ost_body */
 	LASSERTF((int)sizeof(struct ost_body) == 208, "found %lld\n",
-- 
1.7.1
