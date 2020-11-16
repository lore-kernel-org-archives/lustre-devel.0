From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:38 -0500
Subject: [lustre-devel] [PATCH 05/28] lnet: o2ib: raise bind cap before
 resolving address
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In kiblnd_resolve_addr(), ensure that the current task has
CAP_NET_BIND_SERVICE before calling rdma_resolve_addr() with a
protected source port.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14006
Lustre-commit: 1e4bd16acfa26a ("LU-14006 o2ib: raise bind cap before resolving address")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40127
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 38 +++++++++++++++++++++++++++++++++----
 1 file changed, 34 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index ba2f46f..b642162 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1219,14 +1219,17 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	spin_unlock(&conn->ibc_lock);
 }
 
-static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
-			       struct sockaddr_in *srcaddr,
-			       struct sockaddr_in *dstaddr,
-			       int timeout_ms)
+static int
+kiblnd_resolve_addr_cap(struct rdma_cm_id *cmid,
+			struct sockaddr_in *srcaddr,
+			struct sockaddr_in *dstaddr,
+			int timeout_ms)
 {
 	unsigned short port;
 	int rc;
 
+	LASSERT(capable(CAP_NET_BIND_SERVICE));
+
 	/* allow the port to be reused */
 	rc = rdma_set_reuseaddr(cmid, 1);
 	if (rc) {
@@ -1256,6 +1259,33 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	return rc;
 }
 
+static int
+kiblnd_resolve_addr(struct rdma_cm_id *cmid,
+		    struct sockaddr_in *srcaddr,
+		    struct sockaddr_in *dstaddr,
+		    int timeout_ms)
+{
+	const struct cred *old_creds = NULL;
+	struct cred *new_creds;
+	int rc;
+
+	if (!capable(CAP_NET_BIND_SERVICE)) {
+		new_creds = prepare_creds();
+		if (!new_creds)
+			return -ENOMEM;
+
+		cap_raise(new_creds->cap_effective, CAP_NET_BIND_SERVICE);
+		old_creds = override_creds(new_creds);
+	}
+
+	rc = kiblnd_resolve_addr_cap(cmid, srcaddr, dstaddr, timeout_ms);
+
+	if (old_creds)
+		revert_creds(old_creds);
+
+	return rc;
+}
+
 static void
 kiblnd_connect_peer(struct kib_peer_ni *peer_ni)
 {
-- 
1.8.3.1
