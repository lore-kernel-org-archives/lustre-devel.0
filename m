From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:36 -0500
Subject: [lustre-devel] [PATCH 03/28] lustre: seq_file .next functions must
 update *pos
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

A seq_file .next function must update *pos on EOF to a value which
will cause a subsequent ->start to also return EOF.
If it doesn't the last record of the file can be returned
twice to a 'read()'.  Also the seq_file code will generate
a warning.

This patch fixes various ->next functions to always update
*pos.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13985
Lustre-commit: 817d6c11659963 ("LU-13985 lustre: seq_file .next functions must update *pos")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40035
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pool.c        | 2 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 9e937ac..f8f14f9 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -111,6 +111,7 @@ static void *pool_proc_next(struct seq_file *s, void *v, loff_t *pos)
 
 	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X\n", iter->magic);
 
+	(*pos)++;
 	/* test if end of file */
 	if (*pos >= pool_tgt_count(iter->pool))
 		return NULL;
@@ -122,7 +123,6 @@ static void *pool_proc_next(struct seq_file *s, void *v, loff_t *pos)
 		iter->idx = prev_idx; /* we stay on the last entry */
 		return NULL;
 	}
-	(*pos)++;
 	/* return != NULL to continue */
 	return iter;
 }
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 4d2ae14..7276f81 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -932,6 +932,7 @@ struct ptlrpc_srh_iterator {
 	}
 
 	kfree(srhi);
+	++*pos;
 	return NULL;
 }
 
-- 
1.8.3.1
