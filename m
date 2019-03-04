From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 21/28] lustre: vvp_dev;
 increment *pos in .next
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109883.31333.637949571436251317.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As described in

Commit 78bb03e221c4 ("lustre: llite: change how "dump_page_cache" walks a hash table")

The .next function should increment *pos.  For some reason it didn't,
and this can trigger the warning in that function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/vvp_dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index c10ca6e7c606..568943dcb3b4 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -564,7 +564,7 @@ static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 	struct vvp_seq_private *priv = f->private;
 
 	WARN_ON(*pos != priv->vsp_prev_pos);
-
+	*pos += 1;
 	priv->vsp_prev_pos = *pos;
 	return vvp_pgcache_next_page(priv);
 }
