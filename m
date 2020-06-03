From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:45 -0400
Subject: [lustre-devel] [PATCH 06/22] lnet: tidy lnet_discover and fix mem
 accounting bug.
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

A recent patch introduce a memory accounting bug because "n_ids"
can change between the ALLOC call and the FREE call.

With this patch we fix that by ensuring n_ids doesn't change - the
current change is not needed.
Also:
  - discard 'max_intf' var.  It is always exactly lnet_interfaces_max,
    so just use that directly.
  - only copy back the number of interfaces found
  - report the number of interfaces actually copied.
  - Move the copy_to_user until after all locks and references are
    dropped so there is no need to re-take any locks.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 45722de60a8fb ("LU-9679 lnet: tidy lnet_discover and fix mem accounting bug.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38644
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e2c364b..629a597 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4163,7 +4163,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	int cpt;
 	int i;
 	int rc;
-	int max_intf = lnet_interfaces_max;
 
 	if (n_ids <= 0 ||
 	    id.nid == LNET_NID_ANY)
@@ -4172,11 +4171,11 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
-	/* if the user buffer has more space than the max_intf
-	 * then only fill it up to max_intf
+	/* If the user buffer has more space than the lnet_interfaces_max,
+	 * then only fill it up to lnet_interfaces_max.
 	 */
-	if (n_ids > max_intf)
-		n_ids = max_intf;
+	if (n_ids > lnet_interfaces_max)
+		n_ids = lnet_interfaces_max;
 
 	buf = kcalloc(n_ids, sizeof(*buf), GFP_KERNEL);
 	if (!buf)
@@ -4204,11 +4203,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	if (rc)
 		goto out_decref;
 
-	/* Peer may have changed. */
-	lp = lpni->lpni_peer_net->lpn_peer;
-	if (lp->lp_nnis < n_ids)
-		n_ids = lp->lp_nnis;
-
 	i = 0;
 	p = NULL;
 	while ((p = lnet_get_next_peer_ni_locked(lp, NULL, p)) != NULL) {
@@ -4217,20 +4211,18 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		if (++i >= n_ids)
 			break;
 	}
+	rc = i;
 
-	lnet_net_unlock(cpt);
-
-	rc = -EFAULT;
-	if (copy_to_user(ids, buf, n_ids * sizeof(*buf)))
-		goto out_relock;
-	rc = n_ids;
-out_relock:
-	lnet_net_lock(cpt);
 out_decref:
 	lnet_peer_ni_decref_locked(lpni);
 out:
 	lnet_net_unlock(cpt);
+
+	if (rc >= 0)
+		if (copy_to_user(ids, buf, rc * sizeof(*buf)))
+			rc = -EFAULT;
 	kfree(buf);
+
 	return rc;
 }
 
-- 
1.8.3.1
