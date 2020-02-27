From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:56 -0500
Subject: [lustre-devel] [PATCH 368/622] lustre: osc: reduce lock contention
 in osc_unreserve_grant
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-369-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

In osc_queue_async_io() the cl_loi_list_lock is acquired to reserve
and consume the grant and released, right after we expand the extent
the same lock is used to unreserve the grant.
We can keep the spinlock when we are done with the grant to improve
the throughput.

mpirun  -np 32 /root/ior-openmpi/src/ior -w -t 1m -b 8g -F -e -vv
        -o /scratch0/file -i 1
master:
Max Write: 13799.70 MiB/sec (14470.04 MB/sec)
master with 33858:
Max Write: 14339.57 MiB/sec (15036.13 MB/sec)

WC-bug-id: https://jira.whamcloud.com/browse/LU-11775
Lustre-commit: 8a1ae45a3e4f ("LU-11775 osc: reduce lock contention in osc_unreserve_grant")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/33858
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 8ffd8f9..3b4c598 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -636,6 +636,7 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 			 */
 			osc_extent_state_set(ext, OES_TRUNC);
 			ext->oe_trunc_pending = 0;
+			osc_object_unlock(obj);
 		} else {
 			int grant = 0;
 
@@ -648,8 +649,6 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 				grant += cli->cl_grant_extent_tax;
 			if (!osc_extent_merge(env, ext, next_extent(ext)))
 				grant += cli->cl_grant_extent_tax;
-			if (grant > 0)
-				osc_unreserve_grant(cli, 0, grant);
 
 			if (ext->oe_urgent)
 				list_move_tail(&ext->oe_link,
@@ -658,8 +657,10 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 				list_move_tail(&ext->oe_link,
 					       &obj->oo_full_exts);
 			}
+			osc_object_unlock(obj);
+			if (grant > 0)
+				osc_unreserve_grant(cli, 0, grant);
 		}
-		osc_object_unlock(obj);
 
 		osc_io_unplug_async(env, cli, obj);
 	}
@@ -1483,13 +1484,20 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	}
 }
 
-static void osc_unreserve_grant(struct client_obd *cli,
-				unsigned int reserved, unsigned int unused)
+static void osc_unreserve_grant_nolock(struct client_obd *cli,
+				       unsigned int reserved,
+				       unsigned int unused)
 {
-	spin_lock(&cli->cl_loi_list_lock);
 	__osc_unreserve_grant(cli, reserved, unused);
 	if (unused > 0)
 		osc_wake_cache_waiters(cli);
+}
+
+static void osc_unreserve_grant(struct client_obd *cli,
+				unsigned int reserved, unsigned int unused)
+{
+	spin_lock(&cli->cl_loi_list_lock);
+	osc_unreserve_grant_nolock(cli, reserved, unused);
 	spin_unlock(&cli->cl_loi_list_lock);
 }
 
@@ -2385,7 +2393,6 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			grants = 0;
 			need_release = true;
 		}
-		spin_unlock(&cli->cl_loi_list_lock);
 		if (!need_release && ext->oe_end < index) {
 			tmp = grants;
 			/* try to expand this extent */
@@ -2396,10 +2403,11 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			} else {
 				OSC_EXTENT_DUMP(D_CACHE, ext,
 						"expanded for %lu.\n", index);
-				osc_unreserve_grant(cli, grants, tmp);
+				osc_unreserve_grant_nolock(cli, grants, tmp);
 				grants = 0;
 			}
 		}
+		spin_unlock(&cli->cl_loi_list_lock);
 		rc = 0;
 	} else if (ext) {
 		/* index is located outside of active extent */
-- 
1.8.3.1
