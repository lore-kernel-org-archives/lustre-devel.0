From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 01/20] staging: lustre: ptlrpc: convert
 conn_hash to rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368853.12394.3972511682718703007.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Linux has a resizeable hashtable implementation in lib,
so we should use that instead of having one in libcfs.

This patch converts the ptlrpc conn_hash to use rhashtable.
In the process we gain lockless lookup.

As connections are never deleted until the hash table is destroyed,
there is no need to count the reference in the hash table.  There
is also no need to enable automatic_shrinking.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 
 .../staging/lustre/lustre/include/obd_support.h    |    3 
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |  164 +++++++-------------
 3 files changed, 64 insertions(+), 107 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d13db55b7242..35b43a77eb18 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -67,6 +67,8 @@
 #include <obd_support.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 
+#include <linux/rhashtable.h>
+
 /* MD flags we _always_ use */
 #define PTLRPC_MD_OPTIONS  0
 
@@ -286,7 +288,7 @@ struct ptlrpc_replay_async_args {
  */
 struct ptlrpc_connection {
 	/** linkage for connections hash table */
-	struct hlist_node	c_hash;
+	struct rhash_head	c_hash;
 	/** Our own lnet nid for this connection */
 	lnet_nid_t	      c_self;
 	/** Remote side nid for this connection */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index eb2d6cb6b40b..aebcab191442 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -67,9 +67,6 @@ extern char obd_jobid_var[];
 #define HASH_UUID_BKT_BITS 5
 #define HASH_UUID_CUR_BITS 7
 #define HASH_UUID_MAX_BITS 12
-#define HASH_CONN_BKT_BITS 5
-#define HASH_CONN_CUR_BITS 5
-#define HASH_CONN_MAX_BITS 15
 /* Timeout definitions */
 #define OBD_TIMEOUT_DEFAULT	     100
 /* Time to wait for all clients to reconnect during recovery (hard limit) */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index dfdb4587d49d..fb35a89ca6c6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -38,8 +38,41 @@
 
 #include "ptlrpc_internal.h"
 
-static struct cfs_hash *conn_hash;
-static struct cfs_hash_ops conn_hash_ops;
+static struct rhashtable conn_hash;
+
+/*
+ * struct lnet_process_id may contain unassigned bytes which might not
+ * be zero, so we cannot just hash and compare bytes.
+ */
+
+static u32 lnet_process_id_hash(const void *data, u32 len, u32 seed)
+{
+	const struct lnet_process_id *lpi = data;
+
+	seed = hash_32(seed ^ lpi->pid, 32);
+	seed ^= hash_64(lpi->nid, 32);
+	return seed;
+}
+
+static int lnet_process_id_cmp(struct rhashtable_compare_arg *arg,
+			       const void *obj)
+{
+	const struct lnet_process_id *lpi = arg->key;
+	const struct ptlrpc_connection *con = obj;
+
+	if (lpi->nid == con->c_peer.nid &&
+	    lpi->pid == con->c_peer.pid)
+		return 0;
+	return -ESRCH;
+}
+
+static const struct rhashtable_params conn_hash_params = {
+	.key_len	= 1, /* actually variable-length */
+	.key_offset	= offsetof(struct ptlrpc_connection, c_peer),
+	.head_offset	= offsetof(struct ptlrpc_connection, c_hash),
+	.hashfn		= lnet_process_id_hash,
+	.obj_cmpfn	= lnet_process_id_cmp,
+};
 
 struct ptlrpc_connection *
 ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
@@ -47,9 +80,11 @@ ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
 {
 	struct ptlrpc_connection *conn, *conn2;
 
-	conn = cfs_hash_lookup(conn_hash, &peer);
-	if (conn)
+	conn = rhashtable_lookup_fast(&conn_hash, &peer, conn_hash_params);
+	if (conn) {
+		ptlrpc_connection_addref(conn);
 		goto out;
+	}
 
 	conn = kzalloc(sizeof(*conn), GFP_NOFS);
 	if (!conn)
@@ -57,7 +92,6 @@ ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
 
 	conn->c_peer = peer;
 	conn->c_self = self;
-	INIT_HLIST_NODE(&conn->c_hash);
 	atomic_set(&conn->c_refcount, 1);
 	if (uuid)
 		obd_str2uuid(&conn->c_remote_uuid, uuid->uuid);
@@ -65,17 +99,18 @@ ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
 	/*
 	 * Add the newly created conn to the hash, on key collision we
 	 * lost a racing addition and must destroy our newly allocated
-	 * connection.  The object which exists in the has will be
-	 * returned and may be compared against out object.
-	 */
-	/* In the function below, .hs_keycmp resolves to
-	 * conn_keycmp()
+	 * connection.  The object which exists in the hash will be
+	 * returned, otherwise NULL is returned on success.
 	 */
-	/* coverity[overrun-buffer-val] */
-	conn2 = cfs_hash_findadd_unique(conn_hash, &peer, &conn->c_hash);
-	if (conn != conn2) {
+	conn2 = rhashtable_lookup_get_insert_fast(&conn_hash, &conn->c_hash,
+						  conn_hash_params);
+	if (conn2 != NULL) {
+		/* insertion failed */
 		kfree(conn);
+		if (IS_ERR(conn2))
+			return NULL;
 		conn = conn2;
+		ptlrpc_connection_addref(conn);
 	}
 out:
 	CDEBUG(D_INFO, "conn=%p refcount %d to %s\n",
@@ -91,7 +126,7 @@ int ptlrpc_connection_put(struct ptlrpc_connection *conn)
 	if (!conn)
 		return rc;
 
-	LASSERT(atomic_read(&conn->c_refcount) > 1);
+	LASSERT(atomic_read(&conn->c_refcount) > 0);
 
 	/*
 	 * We do not remove connection from hashtable and
@@ -109,7 +144,7 @@ int ptlrpc_connection_put(struct ptlrpc_connection *conn)
 	 * when ptlrpc_connection_fini()->lh_exit->conn_exit()
 	 * path is called.
 	 */
-	if (atomic_dec_return(&conn->c_refcount) == 1)
+	if (atomic_dec_return(&conn->c_refcount) == 0)
 		rc = 1;
 
 	CDEBUG(D_INFO, "PUT conn=%p refcount %d to %s\n",
@@ -130,88 +165,11 @@ ptlrpc_connection_addref(struct ptlrpc_connection *conn)
 	return conn;
 }
 
-int ptlrpc_connection_init(void)
-{
-	conn_hash = cfs_hash_create("CONN_HASH",
-				    HASH_CONN_CUR_BITS,
-				    HASH_CONN_MAX_BITS,
-				    HASH_CONN_BKT_BITS, 0,
-				    CFS_HASH_MIN_THETA,
-				    CFS_HASH_MAX_THETA,
-				    &conn_hash_ops, CFS_HASH_DEFAULT);
-	if (!conn_hash)
-		return -ENOMEM;
-
-	return 0;
-}
-
-void ptlrpc_connection_fini(void)
-{
-	cfs_hash_putref(conn_hash);
-}
-
-/*
- * Hash operations for net_peer<->connection
- */
-static unsigned int
-conn_hashfn(struct cfs_hash *hs, const void *key, unsigned int mask)
-{
-	return cfs_hash_djb2_hash(key, sizeof(struct lnet_process_id), mask);
-}
-
-static int
-conn_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct ptlrpc_connection *conn;
-	const struct lnet_process_id *conn_key;
-
-	LASSERT(key);
-	conn_key = key;
-	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
-
-	return conn_key->nid == conn->c_peer.nid &&
-	       conn_key->pid == conn->c_peer.pid;
-}
-
-static void *
-conn_key(struct hlist_node *hnode)
-{
-	struct ptlrpc_connection *conn;
-
-	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
-	return &conn->c_peer;
-}
-
-static void *
-conn_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct ptlrpc_connection, c_hash);
-}
-
 static void
-conn_get(struct cfs_hash *hs, struct hlist_node *hnode)
+conn_exit(void *vconn, void *data)
 {
-	struct ptlrpc_connection *conn;
+	struct ptlrpc_connection *conn = vconn;
 
-	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
-	atomic_inc(&conn->c_refcount);
-}
-
-static void
-conn_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ptlrpc_connection *conn;
-
-	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
-	atomic_dec(&conn->c_refcount);
-}
-
-static void
-conn_exit(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ptlrpc_connection *conn;
-
-	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
 	/*
 	 * Nothing should be left. Connection user put it and
 	 * connection also was deleted from table by this time
@@ -223,12 +181,12 @@ conn_exit(struct cfs_hash *hs, struct hlist_node *hnode)
 	kfree(conn);
 }
 
-static struct cfs_hash_ops conn_hash_ops = {
-	.hs_hash	= conn_hashfn,
-	.hs_keycmp      = conn_keycmp,
-	.hs_key		= conn_key,
-	.hs_object      = conn_object,
-	.hs_get		= conn_get,
-	.hs_put_locked  = conn_put_locked,
-	.hs_exit	= conn_exit,
-};
+int ptlrpc_connection_init(void)
+{
+	return rhashtable_init(&conn_hash, &conn_hash_params);
+}
+
+void ptlrpc_connection_fini(void)
+{
+	rhashtable_free_and_destroy(&conn_hash, conn_exit, NULL);
+}
