From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:34:56 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: add sparse locking
	annotations
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

Adds __acquires / __releases / __must_hold sparse locking annotations to
several functions.

Fixes sparse warnings such as:

libcfs/libcfs/hash.c:127:1: warning: context imbalance in 'cfs_hash_spin_lock'
        - wrong count at exit
libcfs/libcfs/hash.c:133:1: warning: context imbalance in 'cfs_hash_spin_unlock'
        - unexpected unlock
libcfs/libcfs/hash.c:141:9: warning: context imbalance in 'cfs_hash_rw_lock'
        - wrong count at exit
include/linux/rwlock_api_smp.h:221:9: warning: context imbalance in
        'cfs_hash_rw_unlock' - unexpected unlock

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11295
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    3 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    1 +
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c |    2 ++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    3 +++
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    1 +
 5 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8989e36..f43e825 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -750,8 +750,7 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 static int
 kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
-	__releases(conn->ibc_lock)
-	__acquires(conn->ibc_lock)
+	__must_hold(&conn->ibc_lock)
 {
 	kib_msg_t *msg = tx->tx_msg;
 	kib_peer_t *peer = conn->ibc_peer;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 477b385..a0955d2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2336,6 +2336,7 @@ ksocknal_flush_stale_txs(ksock_peer_t *peer)
 
 static int
 ksocknal_send_keepalive_locked(ksock_peer_t *peer)
+	__must_hold(&ksocknal_data.ksnd_global_lock)
 {
 	ksock_sched_t *sched;
 	ksock_conn_t *conn;
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
index 94bc007..d37e457 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
@@ -90,6 +90,7 @@ EXPORT_SYMBOL(cfs_percpt_lock_alloc);
  */
 void
 cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index)
+	__acquires(pcl->pcl_locks)
 {
 	int	ncpt = cfs_cpt_number(pcl->pcl_cptab);
 	int	i;
@@ -124,6 +125,7 @@ EXPORT_SYMBOL(cfs_percpt_lock);
 /** unlock a CPU partition */
 void
 cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index)
+	__releases(pcl->pcl_locks)
 {
 	int	ncpt = cfs_cpt_number(pcl->pcl_cptab);
 	int	i;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index cfb83bc..fb1a60f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1938,6 +1938,7 @@ static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
 static int
 osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 		   struct osc_object *osc)
+	__must_hold(osc)
 {
 	LIST_HEAD(rpclist);
 	struct osc_extent *ext;
@@ -2010,6 +2011,7 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 static int
 osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct osc_object *osc)
+	__must_hold(osc)
 {
 	struct osc_extent *ext;
 	struct osc_extent *next;
@@ -2083,6 +2085,7 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 
 /* called with the loi list lock held */
 static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
+	__must_hold(&cli->cl_loi_list_lock)
 {
 	struct osc_object *osc;
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a9f1bf5..b6691cc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -353,6 +353,7 @@ static int unpack_reply(struct ptlrpc_request *req)
  * If anything goes wrong just ignore it - same as if it never happened
  */
 static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
+	__must_hold(&req->rq_lock)
 {
 	struct ptlrpc_request *early_req;
 	time64_t olddl;
-- 
1.7.1
