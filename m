From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:21 -0500
Subject: [lustre-devel] [PATCH 333/622] lnet: Do not allow deleting of
 router nis
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-334-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Check the peer before deleting a peer_ni. If it's a router then do
not allow deletion of the peer-ni.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11551
Lustre-commit: 7832a9f52d90 ("LU-11551 lnet: Do not allow deleting of router nis")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33448
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index faaf94a..cb70bc7 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1550,6 +1550,15 @@ struct lnet_peer_net *
 		return -ENODEV;
 	}
 
+	lnet_net_lock(LNET_LOCK_EX);
+	if (lp->lp_rtr_refcount > 0) {
+		lnet_net_unlock(LNET_LOCK_EX);
+		CERROR("%s is a router. Can not be deleted\n",
+		       libcfs_nid2str(prim_nid));
+		return -EBUSY;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+
 	if (nid == LNET_NID_ANY || nid == lp->lp_primary_nid)
 		return lnet_peer_del(lp);
 
-- 
1.8.3.1
