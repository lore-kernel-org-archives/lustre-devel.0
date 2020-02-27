From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:01 -0500
Subject: [lustre-devel] [PATCH 433/622] lustre: osc: layout and chunkbits
 alignment mismatch
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-434-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

In the discard case, the OSC fsync/writeback code asserts
that each OSC extent is fully covered by the fsync request.

It may happen that a start(or an end) of a component does not match
the first (the last) osc object extent start (end), which is aligned
by the cl_chunkbits which depends on the OST block size.

The requirement for the component alignment is LOV_MIN_STRIPE_SIZE
which is 64K, the ZFS block size could be in MBs.

Use an aligned by chunk size the fsync reqion in the assertion.

Fixes: 58c252e47d ("lustre: osc: Do not assert for first extent")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12462
Lustre-commit: 7a9f7dec700c ("LU-12462 osc: layout and chunkbits alignment mismatch")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Cray-bug-id: LUS-7498
Reviewed-on: https://review.whamcloud.com/35733
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 9e2f90d..3d47c02 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2930,18 +2930,25 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 					list_move_tail(&ext->oe_link, list);
 				unplug = true;
 			} else {
+				struct client_obd *cli = osc_cli(obj);
+				int pcc_bits = cli->cl_chunkbits - PAGE_SHIFT;
+				pgoff_t align_by = (1 << pcc_bits);
+				pgoff_t a_start = round_down(start, align_by);
+				pgoff_t a_end = round_up(end, align_by);
+
+				/* overflow case */
+				if (end && !a_end)
+					a_end = CL_PAGE_EOF;
 				/* the only discarder is lock cancelling, so
-				 * [start, end] must contain this extent.
-				 * However, with DOM, osc extent alignment may
-				 * cause the first extent to start before the
-				 * OST portion of the layout.  This is never
-				 * accessed for i/o, but the unused portion
-				 * will not be covered by the sync request,
-				 * so we cannot assert in that case.
+				 * [start, end], aligned by chunk size, must
+				 * contain this extent
 				 */
-				EASSERT(ergo(!(ext == first_extent(obj)),
-					ext->oe_start >= start &&
-					ext->oe_end <= end), ext);
+				LASSERTF(ext->oe_start >= a_start &&
+					 ext->oe_end <= a_end,
+					 "ext [%lu, %lu] reg [%lu, %lu] orig [%lu %lu] align %lu bits %d\n",
+					 ext->oe_start, ext->oe_end,
+					 a_start, a_end, start, end,
+					 align_by, pcc_bits);
 				osc_extent_state_set(ext, OES_LOCKING);
 				ext->oe_owner = current;
 				list_move_tail(&ext->oe_link, &discard_list);
-- 
1.8.3.1
