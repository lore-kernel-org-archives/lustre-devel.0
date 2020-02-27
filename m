From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:32 -0500
Subject: [lustre-devel] [PATCH 524/622] lustre: lov: check all entries in
 lov_flush_composite
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-525-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

Check all layout entries for DOM layout and exit with
-ENODATA if no one exists. Caller consider that as valid
case due to layout change.

Define llo_flush methods for all layouts as required
by lov_dispatch().

Patch cleans up also cl_dom_size field in cl_layout which
was used in previous ll_dom_lock_cancel() implementation

Run lov_flush_composite under down_read lov->lo_type_guard to avoid
race with layout change.

Fixes: 865a95df36 ("lustre: llite: improve ll_dom_lock_cancel")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12704
Lustre-commit: 44460570fd21 ("LU-12704 lov: check all entries in lov_flush_composite")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/36368
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  2 --
 fs/lustre/llite/namei.c       |  6 ++++++
 fs/lustre/lov/lov_object.c    | 42 +++++++++++++++++++++++-------------------
 3 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c3376a4..67731b0 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -287,8 +287,6 @@ struct cl_layout {
 	struct lu_buf		cl_buf;
 	/** size of layout in lov_mds_md format. */
 	size_t			cl_size;
-	/** size of DoM component if exists or zero otherwise */
-	u64			cl_dom_comp_size;
 	/** Layout generation. */
 	u32			cl_layout_gen;
 	/** whether layout is a composite one */
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 5b9f3a7..c87653d 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -198,6 +198,12 @@ static int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 
 	/* reach MDC layer to flush data under  the DoM ldlm lock */
 	rc = cl_object_flush(env, lli->lli_clob, lock);
+	if (rc == -ENODATA) {
+		CDEBUG(D_INODE, "inode "DFID" layout has no DoM stripe\n",
+		       PFID(ll_inode2fid(inode)));
+		/* most likely result of layout change, do nothing */
+		rc = 0;
+	}
 
 	cl_env_put(env, &refcheck);
 	return rc;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 5c4d8f9..f2c7bc2 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1048,13 +1048,23 @@ static int lov_flush_composite(const struct lu_env *env,
 			       struct ldlm_lock *lock)
 {
 	struct lov_object *lov = cl2lov(obj);
-	struct lovsub_object *lovsub;
+	struct lov_layout_entry *lle;
+	int rc = -ENODATA;
 
-	if (!lsme_is_dom(lov->lo_lsm->lsm_entries[0]))
-		return -EINVAL;
+	lov_foreach_layout_entry(lov, lle) {
+		if (!lsme_is_dom(lle->lle_lsme))
+			continue;
+		rc = cl_object_flush(env, lovsub2cl(lle->lle_dom.lo_dom), lock);
+		break;
+	}
+
+	return rc;
+}
 
-	lovsub = lov->u.composite.lo_entries[0].lle_dom.lo_dom;
-	return cl_object_flush(env, lovsub2cl(lovsub), lock);
+static int lov_flush_empty(const struct lu_env *env, struct cl_object *obj,
+			   struct ldlm_lock *lock)
+{
+	return 0;
 }
 
 const static struct lov_layout_operations lov_dispatch[] = {
@@ -1066,7 +1076,8 @@ static int lov_flush_composite(const struct lu_env *env,
 		.llo_page_init	= lov_page_init_empty,
 		.llo_lock_init	= lov_lock_init_empty,
 		.llo_io_init	= lov_io_init_empty,
-		.llo_getattr	= lov_attr_get_empty
+		.llo_getattr	= lov_attr_get_empty,
+		.llo_flush	= lov_flush_empty,
 	},
 	[LLT_RELEASED] = {
 		.llo_init	= lov_init_released,
@@ -1076,7 +1087,8 @@ static int lov_flush_composite(const struct lu_env *env,
 		.llo_page_init	= lov_page_init_empty,
 		.llo_lock_init	= lov_lock_init_empty,
 		.llo_io_init	= lov_io_init_released,
-		.llo_getattr	= lov_attr_get_empty
+		.llo_getattr	= lov_attr_get_empty,
+		.llo_flush	= lov_flush_empty,
 	},
 	[LLT_COMP] = {
 		.llo_init	= lov_init_composite,
@@ -1098,6 +1110,7 @@ static int lov_flush_composite(const struct lu_env *env,
 		.llo_lock_init = lov_lock_init_empty,
 		.llo_io_init   = lov_io_init_empty,
 		.llo_getattr   = lov_attr_get_empty,
+		.llo_flush	= lov_flush_empty,
 	},
 };
 
@@ -2085,18 +2098,8 @@ static int lov_object_layout_get(const struct lu_env *env,
 
 	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
-	cl->cl_dom_comp_size = 0;
 	cl->cl_is_released = lsm->lsm_is_released;
-	if (lsm_is_composite(lsm->lsm_magic)) {
-		struct lov_stripe_md_entry *lsme = lsm->lsm_entries[0];
-
-		cl->cl_is_composite = true;
-
-		if (lsme_is_dom(lsme))
-			cl->cl_dom_comp_size = lsme->lsme_extent.e_end;
-	} else {
-		cl->cl_is_composite = false;
-	}
+	cl->cl_is_composite = lsm_is_composite(lsm->lsm_magic);
 
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
@@ -2123,7 +2126,8 @@ static loff_t lov_object_maxbytes(struct cl_object *obj)
 static int lov_object_flush(const struct lu_env *env, struct cl_object *obj,
 			    struct ldlm_lock *lock)
 {
-	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_flush, env, obj, lock);
+	return LOV_2DISPATCH_MAYLOCK(cl2lov(obj), llo_flush, true, env, obj,
+				     lock);
 }
 
 static const struct cl_object_operations lov_ops = {
-- 
1.8.3.1
