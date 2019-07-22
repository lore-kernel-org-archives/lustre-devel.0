From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:10 -0400
Subject: [lustre-devel] [PATCH 03/11] lustre: fid: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Various checkpatch errors exist in the fid /fld layer. This work
address all of those issues making this layer checkpatch error
free.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_request.c  | 1 -
 fs/lustre/fid/lproc_fid.c    | 3 ++-
 fs/lustre/fld/fld_internal.h | 5 +++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index 45dd275..cdf5402 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -267,7 +267,6 @@ int seq_client_alloc_fid(const struct lu_env *env,
  */
 void seq_client_flush(struct lu_client_seq *seq)
 {
-
 	LASSERT(seq);
 	spin_lock(&seq->lcs_lock);
 
diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index d7d23b4..94869d4 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -131,7 +131,8 @@
 	if (seq->lcs_update)
 		rc = -EBUSY;
 	else
-		seq_printf(m, "[%#llx - %#llx]:%x:%s\n", PRANGE(&seq->lcs_space));
+		seq_printf(m, "[%#llx - %#llx]:%x:%s\n",
+			   PRANGE(&seq->lcs_space));
 	spin_unlock(&seq->lcs_lock);
 
 	return rc;
diff --git a/fs/lustre/fld/fld_internal.h b/fs/lustre/fld/fld_internal.h
index e2eda59..465c6ccf 100644
--- a/fs/lustre/fld/fld_internal.h
+++ b/fs/lustre/fld/fld_internal.h
@@ -70,8 +70,9 @@ struct fld_stats {
 
 struct lu_fld_hash {
 	const char	      *fh_name;
-	int (*fh_hash_func)(struct lu_client_fld *, u64);
-	struct lu_fld_target *(*fh_scan_func)(struct lu_client_fld *, u64);
+	int (*fh_hash_func)(struct lu_client_fld *fld, u64 seq);
+	struct lu_fld_target *(*fh_scan_func)(struct lu_client_fld *fld,
+					      u64 seq);
 };
 
 struct fld_cache_entry {
-- 
1.8.3.1
