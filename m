From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:26:58 -0400
Subject: [lustre-devel] [PATCH 02/20] lnet: test against LNET_STATE_RUNNING
 rather than LNET_STATE_SHUTDOWN
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

The difference between LNET_STATE_STOPPING and LNET_STATE_SHUTDOWN
is of little interest.  As soon as the state isn't
LNET_STATE_RUNNING, various API calls should refuse
to act.

So change tests for SHUTDOWN to instead compare against
RUNNING.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/lnet/lnet/api-ni.c | 2 +-
 net/lnet/lnet/peer.c   | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 62b4fa7..7c91800 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -309,7 +309,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 * changing the value dynamically, we want to set it after
 	 * updating the peers
 	 */
-	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
 		*discovery_off = value;
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 5869a20..f745394 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -810,7 +810,7 @@ struct lnet_peer_ni *
 	int rc;
 
 	rc = -ESHUTDOWN;
-	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN)
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		goto done;
 
 	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
@@ -1805,7 +1805,7 @@ struct lnet_peer_ni *
 	lnet_net_lock(cpt);
 
 	/* Lock has been dropped, check again for shutdown. */
-	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
 		if (!IS_ERR(lpni))
 			lnet_peer_ni_decref_locked(lpni);
 		lpni = ERR_PTR(-ESHUTDOWN);
@@ -2816,7 +2816,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * LNET_LOCK_EX mode is used.
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
-	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
 		rc = -ESHUTDOWN;
 		goto out;
 	}
-- 
1.8.3.1
