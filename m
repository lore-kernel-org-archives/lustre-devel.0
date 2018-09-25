From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:16 +1000
Subject: [lustre-devel] [PATCH 30/34] LU-7734 lnet: set primary NID in
 ptlrpc_connection_get()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763601.32103.9360668949112667310.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Set the NID in ptlrpc_connection::c_peer to the primary NID of a peer.
This ensures that regardless of the NID used to start a connection, we
consistently use the same NID (the primary NID) to identify a peer. It
also means that PtlRPC will not create multiple connections to a peer.

The primary NID is obtained by calling LNetPrimaryNID(), an addition
to the exported symbols of the LNet module. The name was chosen to
match the existing naming pattern.

Test-Parameters: trivial
Signed-off-by: Olaf Weber <olaf@sgi.com>
Change-Id: Idc0605d17a58678b634db246221028cf81ad2407
Reviewed-on: http://review.whamcloud.com/21710
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/include/linux/lnet/api.h   |    1 +
 drivers/staging/lustre/lnet/lnet/peer.c           |   25 +++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/connection.c |    1 +
 3 files changed, 27 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 22429213c023..70c991990474 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -77,6 +77,7 @@ int LNetNIFini(void);
  */
 int LNetGetId(unsigned int index, struct lnet_process_id *id);
 int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, __u32 *order);
+lnet_nid_t LNetPrimaryNID(lnet_nid_t nid);
 
 /** @} lnet_addr */
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index d757f4df1f39..747a4fc8d39f 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -610,6 +610,31 @@ lnet_peer_primary_nid(lnet_nid_t nid)
 	return primary_nid;
 }
 
+lnet_nid_t
+LNetPrimaryNID(lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni;
+	lnet_nid_t primary_nid = nid;
+	int rc = 0;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+	lpni = lnet_nid2peerni_locked(nid, cpt);
+	if (IS_ERR(lpni)) {
+		rc = PTR_ERR(lpni);
+		goto out_unlock;
+	}
+	primary_nid = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+	lnet_peer_ni_decref_locked(lpni);
+out_unlock:
+	lnet_net_unlock(cpt);
+
+	CDEBUG(D_NET, "NID %s primary NID %s rc %d\n", libcfs_nid2str(nid),
+	       libcfs_nid2str(primary_nid), rc);
+	return primary_nid;
+}
+EXPORT_SYMBOL(LNetPrimaryNID);
+
 struct lnet_peer_net *
 lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index fb35a89ca6c6..ca9b4caf44b3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -80,6 +80,7 @@ ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
 {
 	struct ptlrpc_connection *conn, *conn2;
 
+	peer.nid = LNetPrimaryNID(peer.nid);
 	conn = rhashtable_lookup_fast(&conn_hash, &peer, conn_hash_params);
 	if (conn) {
 		ptlrpc_connection_addref(conn);
