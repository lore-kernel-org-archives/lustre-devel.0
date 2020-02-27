From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:31 -0500
Subject: [lustre-devel] [PATCH 403/622] lustre: osc: Do not assert for first
 extent
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-404-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

In the discard case, the OSC fsync/writeback code asserts
that each OSC extent is fully covered by the fsync request.

This is not valid for the DOM case, because OSC extent
alignment requirements can create OSC extents which start
before the OST region of the layout (ie, they cross in to
the DOM region).  This is OK because the layout prevents
them from ever being used for i/o, but this same behavior
means that the OSC fsync start/end is aligned with the
layout, and so does not necessarily cover that first
extent.

The simplest solution is just to not assert on the first
extent.  (There is no way at the OSC layer to recognize the
DOM case.)

WC-bug-id: https://jira.whamcloud.com/browse/LU-12462
Lustre-commit: 092ecd66127e ("LU-12462 osc: Do not assert for first extent")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35525
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 3b4c598..9e2f90d 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2931,10 +2931,17 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 				unplug = true;
 			} else {
 				/* the only discarder is lock cancelling, so
-				 * [start, end] must contain this extent
+				 * [start, end] must contain this extent.
+				 * However, with DOM, osc extent alignment may
+				 * cause the first extent to start before the
+				 * OST portion of the layout.  This is never
+				 * accessed for i/o, but the unused portion
+				 * will not be covered by the sync request,
+				 * so we cannot assert in that case.
 				 */
-				EASSERT(ext->oe_start >= start &&
-					ext->oe_end <= end, ext);
+				EASSERT(ergo(!(ext == first_extent(obj)),
+					ext->oe_start >= start &&
+					ext->oe_end <= end), ext);
 				osc_extent_state_set(ext, OES_LOCKING);
 				ext->oe_owner = current;
 				list_move_tail(&ext->oe_link, &discard_list);
-- 
1.8.3.1
