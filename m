From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:40 -0500
Subject: [lustre-devel] [PATCH 07/28] lnet: o2iblnd: Don't retry indefinitely
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If peer is down don't retry indefinitely. Use the retry_count
parameter to restrict the number of retries. After which the
connection fails and error is propagated up.

This prevents long timeouts when mounting a file system with
nodes which might have their NIDs configured in the FS, but the
nodes have been taken offline.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13972
Lustre-commit: 7c8ad11ef08f0f ("LU-13972 o2iblnd: Don't retry indefinitely")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39981
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h           | 2 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        | 9 +++++++++
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 2 +-
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 9a2fb42..9b2f043 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -626,6 +626,8 @@ struct kib_peer_ni {
 	unsigned char		ibp_races;
 	/* # consecutive reconnection attempts to this peer_ni */
 	unsigned int		ibp_reconnected;
+	/* number of total active retries */
+	unsigned int		ibp_retries;
 	/* errno on closing this peer_ni */
 	int			ibp_error;
 	/* max map_on_demand */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b642162..9de733d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2181,6 +2181,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	/* connection established */
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
+	/* reset retry count */
+	peer_ni->ibp_retries = 0;
+
 	conn->ibc_last_send = ktime_get();
 	kiblnd_set_conn_state(conn, IBLND_CONN_ESTABLISHED);
 	kiblnd_peer_alive(peer_ni);
@@ -2631,6 +2634,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		goto out;
 	}
 
+	if (peer_ni->ibp_retries > *kiblnd_tunables.kib_retry_count) {
+		reason = "retry count exceeded due to no listener";
+		goto out;
+	}
+
 	switch (why) {
 	default:
 		reason = "Unknown";
@@ -2688,6 +2696,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		break;
 
 	case IBLND_REJECT_INVALID_SRV_ID:
+		peer_ni->ibp_retries++;
 		reason = "invalid service id";
 		break;
 	}
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 73ad22d..029c9fb 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -93,7 +93,7 @@
 
 static int retry_count = 5;
 module_param(retry_count, int, 0644);
-MODULE_PARM_DESC(retry_count, "Retransmissions when no ACK received");
+MODULE_PARM_DESC(retry_count, "Number of times to retry connection operations");
 
 static int rnr_retry_count = 6;
 module_param(rnr_retry_count, int, 0644);
-- 
1.8.3.1
