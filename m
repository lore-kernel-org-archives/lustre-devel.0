From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:12 -0400
Subject: [lustre-devel] [PATCH 16/23] lnet: socklnd: remove declarations of
 missing functions.
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

None of ksocknal_query(), ksocknal_notify(), and
ksocknal_lib_bind_thread_to_cpu() exist, so don't declare them.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 4e69e77201b4d ("LU-6142 socklnd: remove declarations of missing functions.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39326
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 350f2c8..261cbb46 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -638,7 +638,6 @@ int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 void ksocknal_next_tx_carrier(struct ksock_conn *conn);
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
-void ksocknal_notify(lnet_nid_t gw_nid);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
@@ -682,6 +681,5 @@ int ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem,
 void ksocknal_lib_csum_tx(struct ksock_tx *tx);
 
 int ksocknal_lib_memory_pressure(struct ksock_conn *conn);
-int ksocknal_lib_bind_thread_to_cpu(int id);
 
 #endif /* _SOCKLND_SOCKLND_H_ */
-- 
1.8.3.1
