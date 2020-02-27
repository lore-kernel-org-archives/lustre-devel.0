From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:34 -0500
Subject: [lustre-devel] [PATCH 286/622] lustre: osc: don't check capability
 for every page
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-287-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

We check CFS_CAP_SYS_RESOURCE for every page during the io.
This is expensive on apparmor enabled systems, we can only
do that once for the entire io and use the result when
submitting the pages.

Don't init the oap_brw_flags during osc_page_init(), the flag
will be set in either osc_queue_async_io() or osc_page_submit().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12093
Lustre-commit: c1cab789aaa2 ("LU-12093 osc: don't check capability for every page")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/34478
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 4 +++-
 fs/lustre/osc/osc_cache.c      | 5 +----
 fs/lustre/osc/osc_io.c         | 6 ++++--
 fs/lustre/osc/osc_page.c       | 5 +++--
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index aa3d4c3..1c5af80 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -139,7 +139,9 @@ struct osc_io {
 	/* true if this io is lockless. */
 	unsigned int		oi_lockless:1,
 	/* true if this io is counted as active IO */
-				oi_is_active:1;
+				oi_is_active:1,
+	/** true if this io has CAP_SYS_RESOURCE */
+				oi_cap_sys_resource:1;
 	/* how many LRU pages are reserved for this IO */
 	unsigned long		oi_lru_reserved;
 
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index bdaf65f..a02adac 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2283,9 +2283,6 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	oap->oap_obj_off = offset;
 	LASSERT(!(offset & ~PAGE_MASK));
 
-	if (capable(CAP_SYS_RESOURCE))
-		oap->oap_brw_flags = OBD_BRW_NOQUOTA;
-
 	INIT_LIST_HEAD(&oap->oap_pending_item);
 	INIT_LIST_HEAD(&oap->oap_rpc_item);
 
@@ -2324,7 +2321,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 	/* Set the OBD_BRW_SRVLOCK before the page is queued. */
 	brw_flags |= ops->ops_srvlock ? OBD_BRW_SRVLOCK : 0;
-	if (capable(CAP_SYS_RESOURCE)) {
+	if (oio->oi_cap_sys_resource) {
 		brw_flags |= OBD_BRW_NOQUOTA;
 		cmd |= OBD_BRW_NOQUOTA;
 	}
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 76657f3..dfdf064 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -357,18 +357,20 @@ int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct osc_object *osc = cl2osc(ios->cis_obj);
 	struct obd_import *imp = osc_cli(osc)->cl_import;
+	struct osc_io *oio = osc_env_io(env);
 	int rc = -EIO;
 
 	spin_lock(&imp->imp_lock);
 	if (likely(!imp->imp_invalid)) {
-		struct osc_io *oio = osc_env_io(env);
-
 		atomic_inc(&osc->oo_nr_ios);
 		oio->oi_is_active = 1;
 		rc = 0;
 	}
 	spin_unlock(&imp->imp_lock);
 
+	if (capable(CAP_SYS_RESOURCE))
+		oio->oi_cap_sys_resource = 1;
+
 	return rc;
 }
 EXPORT_SYMBOL(osc_io_iter_init);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 7382e0d..0910f3a 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -302,6 +302,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags)
 {
+	struct osc_io *oio = osc_env_io(env);
 	struct osc_async_page *oap = &opg->ops_oap;
 
 	LASSERTF(oap->oap_magic == OAP_MAGIC,
@@ -313,9 +314,9 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_cmd = crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
 	oap->oap_page_off = opg->ops_from;
 	oap->oap_count = opg->ops_to - opg->ops_from;
-	oap->oap_brw_flags = brw_flags | OBD_BRW_SYNC;
+	oap->oap_brw_flags = OBD_BRW_SYNC | brw_flags;
 
-	if (capable(CAP_SYS_RESOURCE)) {
+	if (oio->oi_cap_sys_resource) {
 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
 	}
-- 
1.8.3.1
