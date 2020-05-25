From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:53 -0400
Subject: [lustre-devel] [PATCH 16/45] lustre: llite: do not flush COW pages
 from mapping
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

Do not flush COW pages from an executable mapping, as this will cause
running binaries to segfault when mapped pages disappear under them.

This was modified to allow non-blocking PCC caching, but triggers
immediate segfaults for binaries when the DLM locks are revoked, even
when PCC is not in use.

The added test case failed 100% without this patch.

This patch is only a partial fix to avoid the segfaults.  There still
needs to be something done to re-introduce the PCC functionality, but
should be conditional on PCC enabled, and not for running binaries.

There is a problem for PCC when multiple clients read/write on a
shared mmapped file. We exclude mmap_sanity tst6 in test_4 from
PCC testing temporarily.

Fixes: 38a1a6ad3f79 ("lustre: pcc: Non-blocking PCC caching")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13137
Lustre-commit: 13a0066afb8d8 ("LU-13137 llite: do not flush COW pages from mapping")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37278
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Stephan Thiell <sthiell@stanford.edu>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 2 +-
 fs/lustre/llite/vvp_object.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index ee1bff1..f77b8f9 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -519,7 +519,7 @@ int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
 	if (mapping_mapped(mapping)) {
 		rc = 0;
 		unmap_mapping_range(mapping, first + PAGE_SIZE - 1,
-				    last - first + 1, 1);
+				    last - first + 1, 0);
 	}
 
 	return rc;
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 50a1a0b..0c40814 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -146,7 +146,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 * a price themselves.
 		 */
 		unmap_mapping_range(conf->coc_inode->i_mapping,
-				    0, OBD_OBJECT_EOF, 1);
+				    0, OBD_OBJECT_EOF, 0);
 		pcc_layout_invalidate(conf->coc_inode);
 	}
 
-- 
1.8.3.1
