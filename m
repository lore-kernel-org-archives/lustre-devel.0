From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:12 -0400
Subject: [lustre-devel] [PATCH 31/37] lustre: osc: consume grants for direct
 I/O
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

New IO engine implementation lost consuming grants by direct I/O
writes. That led to early emergence of out of space condition during
direct I/O. The below illustrates the problem:
  # OSTSIZE=100000 sh llmount.sh
  # dd if=/dev/zero of=/mnt/lustre/file bs=4k count=100 oflag=direct
  dd: error writing ?/mnt/lustre/file?: No space left on device

Consume grants for direct I/O.

Try to consume grants in osc_queue_sync_pages() when it is called for
pages which are being writted in direct i/o.

Tests are added to verify grant consumption in buffered and direct i/o
and to verify direct i/o overwrite when ost is full.
The overwrite test is for ldiskfs only as zfs is unable to overwrite
when it is full.

Cray-bug-id: LUS-7036
WC-bug-id: https://jira.whamcloud.com/browse/LU-12687
Lustre-commit: 05f326a7988a7a ("LU-12687 osc: consume grants for direct I/O")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/35896
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index fe03c0d..c7aaabb 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2692,6 +2692,28 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 	ext->oe_srvlock = !!(brw_flags & OBD_BRW_SRVLOCK);
 	ext->oe_ndelay = !!(brw_flags & OBD_BRW_NDELAY);
 	ext->oe_dio = !!(brw_flags & OBD_BRW_NOCACHE);
+	if (ext->oe_dio && !ext->oe_rw) { /* direct io write */
+		int grants;
+		int ppc;
+
+		ppc = 1 << (cli->cl_chunkbits - PAGE_SHIFT);
+		grants = cli->cl_grant_extent_tax;
+		grants += (1 << cli->cl_chunkbits) *
+			  ((page_count + ppc - 1) / ppc);
+
+		spin_lock(&cli->cl_loi_list_lock);
+		if (osc_reserve_grant(cli, grants) == 0) {
+			list_for_each_entry(oap, list, oap_pending_item) {
+				osc_consume_write_grant(cli,
+							&oap->oap_brw_page);
+				atomic_long_inc(&obd_dirty_pages);
+			}
+			osc_unreserve_grant_nolock(cli, grants, 0);
+			ext->oe_grants = grants;
+		}
+		spin_unlock(&cli->cl_loi_list_lock);
+	}
+
 	ext->oe_is_rdma_only = !!(brw_flags & OBD_BRW_RDMA_ONLY);
 	ext->oe_nr_pages = page_count;
 	ext->oe_mppr = mppr;
-- 
1.8.3.1
