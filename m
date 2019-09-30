From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:50 -0400
Subject: [lustre-devel] [PATCH 031/151] lnet: decref on peer after use
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

After looking up the peer for both ping and discover
we need to decref the peer so we don't lose a reference
on it. This needs to be done while the mutex_lock is held
to ensure the peer list remains stable.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9918
Lustre-commit: 440c1c03fe08 ("LU-9918 lnet: decref on peer after use")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28722
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 78fd05f..bc3f808 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3297,11 +3297,15 @@ u32 lnet_get_dlc_seq_locked(void)
 		if (rc < 0)
 			return rc;
 
+		mutex_lock(&the_lnet.ln_api_mutex);
 		lp = lnet_find_peer(ping->ping_id.nid);
 		if (lp) {
 			ping->ping_id.nid = lp->lp_primary_nid;
 			ping->mr_info = lnet_peer_is_multi_rail(lp);
+			lnet_peer_decref_locked(lp);
 		}
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
 		ping->ping_count = rc;
 		return 0;
 	}
@@ -3315,11 +3319,15 @@ u32 lnet_get_dlc_seq_locked(void)
 				   discover->ping_count);
 		if (rc < 0)
 			return rc;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
 		lp = lnet_find_peer(discover->ping_id.nid);
 		if (lp) {
 			discover->ping_id.nid = lp->lp_primary_nid;
 			discover->mr_info = lnet_peer_is_multi_rail(lp);
+			lnet_peer_decref_locked(lp);
 		}
+		mutex_unlock(&the_lnet.ln_api_mutex);
 
 		discover->ping_count = rc;
 		return 0;
-- 
1.8.3.1
