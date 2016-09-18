From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:56 -0400
Subject: [lustre-devel] [PATCH 117/124] staging: lustre: mdc:
	cl_default_mds_easize not refreshed
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-118-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ned Bass <bass6@llnl.gov>, Kyle Blatter <kyleblatter@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Ned Bass <bass6@llnl.gov>

The client_obd::cl_default_mds_easize field should track the largest
observed EA size advertised by the MDT, subject to a reasonable upper
bound. The MDC uses cl_default_mds_easize to calculate the initial
size of request buffers.  The default value should be small enough to
avoid wasted memory and excessive use of vmalloc(), yet large enough
to accommodate the common use case.

In the current code, the default value is only updated if
client_obd::cl_max_mds_easize is strictly less than
mdt_body::mbo_max_mdsize. This condition is almost never met, because
client_obd::cl_max_mds_easize is computed at client mount-time based
on the number of OSTs in the filesystem, so the MDT won't ever observe
and advertise an EA size larger than that.

As a result, client_obd::cl_default_mds_easize indefinitely retains
its initial value, which is computed at client mount-time based on
the filesystem's default stripe width. Any getattr() requests for
widely striped files will consequently allocate a request buffer
that is too small, forcing reallocations on both the client and
server side. To avoid this, update client_obd::cl_default_mds_easize
independently of the value of client_obd::cl_max_mds_easize.

In addition, this patch includes these changes:

 - Add comments to the client_obd structure to clarify what the
   cl_{default,max}_mds_{cookie,ea}size values mean.

 - Prevent mdc_get_info() from storing uninitialized data in
   client_obd::cl_max_mds_cookiesize.

 - Use 4096 as an upper bound for the default values.  The former
   bound of PAGE_CACHE_SIZE is too large on 64k-page platforms
   (i.e. PPC), so it fails to prevent the vmalloc() spinlock
   contention described in LU-3338. The new value was chosen to
   be large enough to accommodate common use cases while staying
   well below the 16k threshold at which allocations start using
   vmalloc().

Signed-off-by: Ned Bass <bass6@llnl.gov>
Signed-off-by: Kyle Blatter <kyleblatter@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5549
Reviewed-on: http://review.whamcloud.com/11614
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   37 ++++++++++++-----
 drivers/staging/lustre/lustre/include/obd.h        |   41 +++++++++++++++++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    3 +-
 3 files changed, 67 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 9549fb4..8fc2d3f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -156,26 +156,41 @@ static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
 	mutex_unlock(&lck->rpcl_mutex);
 }
 
-/* Update the maximum observed easize and cookiesize.  The default easize
- * and cookiesize is initialized to the minimum value but allowed to grow
- * up to a single page in size if required to handle the common case.
+/**
+ * Update the maximum possible easize and cookiesize.
+ *
+ * The values are learned from ptlrpc replies sent by the MDT.  The
+ * default easize and cookiesize is initialized to the minimum value but
+ * allowed to grow up to a single page in size if required to handle the
+ * common case.
+ *
+ * \see client_obd::cl_default_mds_easize and
+ * client_obd::cl_default_mds_cookiesize
+ *
+ * \param[in] exp	export for MDC device
+ * \param[in] body	body of ptlrpc reply from MDT
+ *
  */
 static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 					       struct mdt_body *body)
 {
 	if (body->mbo_valid & OBD_MD_FLMODEASIZE) {
 		struct client_obd *cli = &exp->exp_obd->u.cli;
+		u32 def_cookiesize, def_easize;
 
-		if (cli->cl_max_mds_easize < body->mbo_max_mdsize) {
+		if (cli->cl_max_mds_easize < body->mbo_max_mdsize)
 			cli->cl_max_mds_easize = body->mbo_max_mdsize;
-			cli->cl_default_mds_easize =
-			    min_t(__u32, body->mbo_max_mdsize, PAGE_SIZE);
-		}
-		if (cli->cl_max_mds_cookiesize < body->mbo_max_cookiesize) {
+
+		def_easize = min_t(__u32, body->mbo_max_mdsize,
+				   OBD_MAX_DEFAULT_EA_SIZE);
+		cli->cl_default_mds_easize = def_easize;
+
+		if (cli->cl_max_mds_cookiesize < body->mbo_max_cookiesize)
 			cli->cl_max_mds_cookiesize = body->mbo_max_cookiesize;
-			cli->cl_default_mds_cookiesize =
-			    min_t(__u32, body->mbo_max_cookiesize, PAGE_SIZE);
-		}
+
+		def_cookiesize = min_t(__u32, body->mbo_max_cookiesize,
+				       OBD_MAX_DEFAULT_COOKIE_SIZE);
+		cli->cl_default_mds_cookiesize = def_cookiesize;
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ef11534..f6fc4dd 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -196,6 +196,16 @@ enum obd_cl_sem_lock_class {
 	OBD_CLI_SEM_MDCOSC,
 };
 
+/*
+ * Limit reply buffer size for striping data to one x86_64 page. This
+ * value is chosen to fit the striping data for common use cases while
+ * staying well below the limit at which the buffer must be backed by
+ * vmalloc(). Excessive use of vmalloc() may cause spinlock contention
+ * on the MDS.
+ */
+#define OBD_MAX_DEFAULT_EA_SIZE		4096
+#define OBD_MAX_DEFAULT_COOKIE_SIZE	4096
+
 struct mdc_rpc_lock;
 struct obd_import;
 struct client_obd {
@@ -203,12 +213,39 @@ struct client_obd {
 	struct obd_uuid	  cl_target_uuid;
 	struct obd_import       *cl_import; /* ptlrpc connection state */
 	size_t			 cl_conn_count;
-	/* max_mds_easize is purely a performance thing so we don't have to
-	 * call obd_size_diskmd() all the time.
+	/*
+	 * Cache maximum and default values for easize and cookiesize. This is
+	 * strictly a performance optimization to minimize calls to
+	 * obd_size_diskmd(). The default values are used to calculate the
+	 * initial size of a request buffer. The ptlrpc layer will resize the
+	 * buffer as needed to accommodate a larger reply from the
+	 * server. The default values should be small enough to avoid wasted
+	 * memory and excessive use of vmalloc(), yet large enough to avoid
+	 * reallocating the buffer in the common use case.
+	 */
+	/*
+	 * Default EA size for striping attributes. It is initialized at
+	 * mount-time based on the default stripe width of the filesystem,
+	 * then it tracks the largest observed EA size advertised by
+	 * the MDT, up to a maximum value of OBD_MAX_DEFAULT_EA_SIZE.
 	 */
 	u32			 cl_default_mds_easize;
+	/* Maximum possible EA size computed at mount-time based on
+	 * the number of OSTs in the filesystem. May be increased at
+	 * run-time if a larger observed size is advertised by the MDT.
+	 */
 	u32			 cl_max_mds_easize;
+	/* Default cookie size for llog cookies (see struct llog_cookie). It is
+	 * initialized to zero at mount-time, then it tracks the largest
+	 * observed cookie size advertised by the MDT, up to a maximum value of
+	 * OBD_MAX_DEFAULT_COOKIE_SIZE. Note that llog_cookies are not
+	 * used by clients communicating with MDS versions 2.4.0 and later.
+	 */
 	u32			 cl_default_mds_cookiesize;
+	/* Maximum possible cookie size computed at mount-time based on
+	 * the number of OSTs in the filesystem. May be increased at
+	 * run-time if a larger observed size is advertised by the MDT.
+	 */
 	u32			 cl_max_mds_cookiesize;
 
 	enum lustre_sec_part     cl_sp_me;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index dab08a0..5dcaca0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -619,7 +619,8 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
  */
 int ll_set_default_mdsize(struct ll_sb_info *sbi, int lmmsize)
 {
-	if (lmmsize < sizeof(struct lov_mds_md) || lmmsize > PAGE_SIZE)
+	if (lmmsize < sizeof(struct lov_mds_md) ||
+	    lmmsize > OBD_MAX_DEFAULT_EA_SIZE)
 		return -EINVAL;
 
 	return obd_set_info_async(NULL, sbi->ll_md_exp,
-- 
1.7.1
