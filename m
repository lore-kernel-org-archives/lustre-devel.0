From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:31 -0500
Subject: [lustre-devel] [PATCH 163/622] lnet: peer deletion code may hide
 error
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-164-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

lnet_peer_ni_del_locked might return -EBUSY if the
NID to be deleted is a gateway.

Check for the return value of lnet_peer_ni_del_locked
in lnet_peer_del_nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10876
Lustre-commit: a3b6109705dc ("LU-10876 lnet: peer deletion code may hide error")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31861
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 2fc5dfc..24a5cd3 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -494,7 +494,9 @@ void lnet_peer_uninit(void)
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
-	lnet_peer_ni_del_locked(lpni);
+
+	rc = lnet_peer_ni_del_locked(lpni);
+
 	lnet_net_unlock(LNET_LOCK_EX);
 
 out:
-- 
1.8.3.1
