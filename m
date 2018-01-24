From: Dmitry Eremin <dmitry.eremin@intel.com>
Date: Wed, 24 Jan 2018 17:14:12 +0300
Subject: [lustre-devel] [PATCH v3] staging: lustre: separate a connection
 destroy from free struct kib_conn
In-Reply-To: <20180122103924.GB23996@kroah.com>
References: <20180122103924.GB23996@kroah.com>
Message-ID: <1516803252-14266-1-git-send-email-dmitry.eremin@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Dmitry Eremin <Dmitry.Eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Rewrite the logic of the original commit 4d99b2581eff ("staging: lustre: avoid
intensive reconnecting for ko2iblnd") and move the freeing a struct kib_conn
outside of the function kiblnd_destroy_conn(). The freeing of struct kib_conn
should be depending on the second argument free_conn of function
kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn). If it true the
structure should be freed.

Fixes: 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 7 +++----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 ++++--
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2ebc484385b3..ec84edfda271 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -824,14 +824,15 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 	return conn;
 
  failed_2:
-	kiblnd_destroy_conn(conn, true);
+	kiblnd_destroy_conn(conn);
+	kfree(conn);
  failed_1:
 	kfree(init_qp_attr);
  failed_0:
 	return NULL;
 }
 
-void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
+void kiblnd_destroy_conn(struct kib_conn *conn)
 {
 	struct rdma_cm_id *cmid = conn->ibc_cmid;
 	struct kib_peer *peer = conn->ibc_peer;
@@ -889,8 +890,6 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 		rdma_destroy_id(cmid);
 		atomic_dec(&net->ibn_nconns);
 	}
-
-	kfree(conn);
 }
 
 int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 171eced213f8..b18911d09e9a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -1016,7 +1016,7 @@ int  kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 struct kib_conn *kiblnd_create_conn(struct kib_peer *peer,
 				    struct rdma_cm_id *cmid,
 				    int state, int version);
-void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn);
+void kiblnd_destroy_conn(struct kib_conn *conn);
 void kiblnd_close_conn(struct kib_conn *conn, int error);
 void kiblnd_close_conn_locked(struct kib_conn *conn, int error);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9b3328c5d1e7..b3e7f28eb978 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3314,11 +3314,13 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
 
-			kiblnd_destroy_conn(conn, !peer);
+			kiblnd_destroy_conn(conn);
 
 			spin_lock_irqsave(lock, flags);
-			if (!peer)
+			if (!peer) {
+				kfree(conn);
 				continue;
+			}
 
 			conn->ibc_peer = peer;
 			if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
-- 
1.8.3.1


--------------------------------------------------------------------
Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park,
17 Krylatskaya Str., Bldg 4, Moscow 121614,
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
