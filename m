From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:48 -0400
Subject: [lustre-devel] [PATCH 07/37] lustre: osc: disable ext merging for
 rdma only pages and non-rdma
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

This patch try to add logic to prevent CPU memory pages and RDMA
memory pages from merging into one RPC, codes which set OBD_BRW_RDMA_ONLY
will be added whenever RDMA only codes added later.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13180
Lustre-commit: 9f6c9fa44d6e6 ("LU-13180 osc: disable ext merging for rdma only pages and non-rdma")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/37567
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 4 +++-
 fs/lustre/osc/osc_cache.c      | 4 ++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 11b7e92..cd08f27 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -939,7 +939,9 @@ struct osc_extent {
 	/* Non-delay RPC should be used for this extent. */
 				oe_ndelay:1,
 	/* direct IO pages */
-				oe_dio:1;
+				oe_dio:1,
+	/* this extent consists of RDMA only pages */
+				oe_is_rdma_only;
 	/* how many grants allocated for this extent.
 	 *  Grant allocated for this extent. There is no grant allocated
 	 *  for reading extents and sync write extents.
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 474b711..f811dadb 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1927,6 +1927,9 @@ static inline unsigned int osc_extent_chunks(const struct osc_extent *ext)
 	if (in_rpc->oe_dio && overlapped(ext, in_rpc))
 		return false;
 
+	if (ext->oe_is_rdma_only != in_rpc->oe_is_rdma_only)
+		return false;
+
 	return true;
 }
 
@@ -2688,6 +2691,7 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 	ext->oe_srvlock = !!(brw_flags & OBD_BRW_SRVLOCK);
 	ext->oe_ndelay = !!(brw_flags & OBD_BRW_NDELAY);
 	ext->oe_dio = !!(brw_flags & OBD_BRW_NOCACHE);
+	ext->oe_is_rdma_only = !!(brw_flags & OBD_BRW_RDMA_ONLY);
 	ext->oe_nr_pages = page_count;
 	ext->oe_mppr = mppr;
 	list_splice_init(list, &ext->oe_pages);
-- 
1.8.3.1
