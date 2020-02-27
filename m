From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:10 -0500
Subject: [lustre-devel] [PATCH 322/622] lnet: invalidate recovery ping mdh
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-323-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

For cleanliness, ensure that recovery ping mdh is invalidated when
an peer ni or a local ni are allocated

WC-bug-id: https://jira.whamcloud.com/browse/LU-11297
Lustre-commit: d7b5f3114d51 ("LU-11297 lnet: invalidate recovery ping mdh")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34771
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/config.c | 1 +
 net/lnet/lnet/peer.c   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 5e0831a..760452c 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -443,6 +443,7 @@ struct lnet_net *
 	spin_lock_init(&ni->ni_lock);
 	INIT_LIST_HEAD(&ni->ni_netlist);
 	INIT_LIST_HEAD(&ni->ni_recovery);
+	LNetInvalidateMDHandle(&ni->ni_ping_mdh);
 	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
 				       sizeof(*ni->ni_refs[0]));
 	if (!ni->ni_refs)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 24a5cd3..7b11f28 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -126,6 +126,7 @@
 	INIT_LIST_HEAD(&lpni->lpni_peer_nis);
 	INIT_LIST_HEAD(&lpni->lpni_recovery);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
+	LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
 
 	spin_lock_init(&lpni->lpni_lock);
 
-- 
1.8.3.1
