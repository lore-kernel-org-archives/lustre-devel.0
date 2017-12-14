From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Dec 2017 15:43:43 +1100
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: Fix recent breakage
 from list_for_each conversion
Message-ID: <87a7ylor5s.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Haneen Mohammed <hamohammed.sa@gmail.com>


Commit 8e55b6fd0660 ("staging: lustre: lnet: replace list_for_each
with list_for_each_entry") was intended to be an idempotent change,
but actually broke the behavior of ksocknal_add_peer() causing mounts to fail.
The fact that it caused an existing "route2 = NULL;" to become
redundant could have been a clue.  The fact that the loop body
set the new loop variable to NULL might also have been a clue

The original code relied on "route2" being NULL if nothing was found.
The new code would always set route2 to a non-NULL value if the list
was empty, and would likely crash if the list was not empty.

Restore correct functionality by using code-flow rather the value of
"route2" to determine whether to use on old route, or to add a new one.

Fixes: 8e55b6fd0660 ("staging: lustre: lnet: replace list_for_each with list_for_each_entry")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 23 ++++++++++------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 9c92a83f214a..634c0cc7909f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -487,21 +487,18 @@ ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 			      ksocknal_nid2peerlist(id.nid));
 	}
 
-	route2 = NULL;
 	list_for_each_entry(route2, &peer->ksnp_routes, ksnr_list) {
-		if (route2->ksnr_ipaddr == ipaddr)
-			break;
-
-		route2 = NULL;
-	}
-	if (!route2) {
-		ksocknal_add_route_locked(peer, route);
-		route->ksnr_share_count++;
-	} else {
-		ksocknal_route_decref(route);
-		route2->ksnr_share_count++;
+		if (route2->ksnr_ipaddr == ipaddr) {
+			/* Route already exists, use the old one */
+			ksocknal_route_decref(route);
+			route2->ksnr_share_count++;
+			goto out;
+		}
 	}
-
+	/* Route doesn't already exist, add the new one */
+	ksocknal_add_route_locked(peer, route);
+	route->ksnr_share_count++;
+out:
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	return 0;
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171214/2d9cd09d/attachment-0001.sig>
