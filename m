From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:42 -0500
Subject: [lustre-devel] [PATCH 474/622] lnet: socklnd: remove ksnp_sharecount
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-475-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set, though its value is printed.
Remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 408a5a527567 ("LU-6142 socklnd: remove ksnp_sharecount")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35892
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 4 ++--
 net/lnet/klnds/socklnd/socklnd.h | 1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 78f6c7e..e2a9819 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2471,10 +2471,10 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			CWARN("Active peer_ni on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
+			CWARN("Active peer_ni on shutdown: %s, ref %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
 			      libcfs_id2str(peer_ni->ksnp_id),
 			      atomic_read(&peer_ni->ksnp_refcount),
-			      peer_ni->ksnp_sharecount, peer_ni->ksnp_closing,
+			      peer_ni->ksnp_closing,
 			      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
 			      peer_ni->ksnp_zc_next_cookie,
 			      !list_empty(&peer_ni->ksnp_tx_queue),
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 80c2e19..efdd02e 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -415,7 +415,6 @@ struct ksock_peer {
 							 */
 	struct lnet_process_id	ksnp_id;		/* who's on the other end(s) */
 	atomic_t		ksnp_refcount;		/* # users */
-	int			ksnp_sharecount;	/* lconf usage counter */
 	int			ksnp_closing;		/* being closed */
 	int			ksnp_accepting;		/* # passive connections pending
 							 */
-- 
1.8.3.1
