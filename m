From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:15 -0400
Subject: [lustre-devel] [PATCH 056/151] lustre: llite: check layout size
 after cl_object_layout_get
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Check that layout size is not zero before doing flush for
DoM object. Also patch does that:
- initializes all values in cl_layout explicitly
  in lov_object_layout_get().
- changes cl_dom_comp_size to u64 for future needs, e.g.
  importing an existing filesystem image directly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 877669a282ef ("LU-3285 llite: check layout size after cl_object_layout_get")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29810
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 2 +-
 fs/lustre/llite/namei.c       | 3 +--
 fs/lustre/lov/lov_object.c    | 4 ++++
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 0894b2e..c0d6452 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -287,7 +287,7 @@ struct cl_layout {
 	/** size of layout in lov_mds_md format. */
 	size_t			cl_size;
 	/** size of DoM component if exists or zero otherwise */
-	u32		cl_dom_comp_size;
+	u64			cl_dom_comp_size;
 	/** Layout generation. */
 	u32			cl_layout_gen;
 	/** whether layout is a composite one */
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index fb75441..355a500 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -197,10 +197,9 @@ int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 		CDEBUG(D_INODE, "Cannot get layout for "DFID"\n",
 		       PFID(ll_inode2fid(inode)));
 		rc = -ENODATA;
-	} else if (clt.cl_dom_comp_size == 0) {
+	} else if (clt.cl_size == 0 || clt.cl_dom_comp_size == 0) {
 		CDEBUG(D_INODE, "DOM lock without DOM layout for "DFID"\n",
 		       PFID(ll_inode2fid(inode)));
-		rc = -EINVAL;
 	} else {
 		enum cl_fsync_mode mode;
 		loff_t end = clt.cl_dom_comp_size - 1;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 9fcf51b..3a7b38d 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1869,6 +1869,7 @@ static int lov_object_layout_get(const struct lu_env *env,
 
 	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
+	cl->cl_dom_comp_size = 0;
 	if (lsm_is_composite(lsm->lsm_magic)) {
 		struct lov_stripe_md_entry *lsme = lsm->lsm_entries[0];
 
@@ -1876,7 +1877,10 @@ static int lov_object_layout_get(const struct lu_env *env,
 
 		if (lsme_is_dom(lsme))
 			cl->cl_dom_comp_size = lsme->lsme_extent.e_end;
+	} else {
+		cl->cl_is_composite = false;
 	}
+
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
 
-- 
1.8.3.1
