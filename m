From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:16 -0500
Subject: [lustre-devel] [PATCH 448/622] lustre: llite: Fix page count for
 unaligned reads
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-449-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When a read is unaligned on both the first and last page,
the calculation used to determine count of pages for
readahead misses that we access both of those pages.

Increase the calculated count by 1 in this case.

This case is covered by the generic readahead tests added
in LU-12645.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12367
Lustre-commit: d4a54de84c05 ("LU-12367 llite: Fix page count for unaligned reads")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35015
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 847fb5e..e676e62 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -778,6 +778,14 @@ static int vvp_io_read_start(const struct lu_env *env,
 		vio->vui_ra_valid = true;
 		vio->vui_ra_start = cl_index(obj, pos);
 		vio->vui_ra_count = cl_index(obj, tot + PAGE_SIZE - 1);
+		/* If both start and end are unaligned, we read one more page
+		 * than the index math suggests.
+		 */
+		if (pos % PAGE_SIZE != 0 && (pos + tot) % PAGE_SIZE != 0)
+			vio->vui_ra_count++;
+
+		CDEBUG(D_READA, "tot %ld, ra_start %lu, ra_count %lu\n", tot,
+		       vio->vui_ra_start, vio->vui_ra_count);
 	}
 
 	/* BUG: 5972 */
-- 
1.8.3.1
