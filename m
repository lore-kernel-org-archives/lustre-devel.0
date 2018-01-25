From: Dmitry Eremin <dmitry.eremin@intel.com>
Date: Thu, 25 Jan 2018 16:51:04 +0300
Subject: [lustre-devel] [PATCH v4] staging: lustre: separate a connection
 destroy from free struct kib_conn
In-Reply-To: <20180124142954.GA4658@kroah.com>
References: <20180124142954.GA4658@kroah.com>
Message-ID: <1516888264-26273-1-git-send-email-dmitry.eremin@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, stable@vger.kernel.org, Dmitry Eremin <Dmitry.Eremin@intel.com>

The logic of the original commit 4d99b2581eff ("staging: lustre: avoid
intensive reconnecting for ko2iblnd") was assumed conditional free of
struct kib_conn if the second argument free_conn in function
kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn) is true.
But this hunk of code was dropped from original commit. As result the logic
works wrong and current code use struct kib_conn after free.

> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> 3317  kiblnd_destroy_conn(conn, !peer);
>                           ^^^^ Freed always (but should be conditionally)
> 3318
> 3319  spin_lock_irqsave(lock, flags);
> 3320  if (!peer)
> 3321      continue;
> 3322
> 3323  conn->ibc_peer = peer;
>       ^^^^^^^^^^^^^^ Use after free
> 3324  if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
> 3325      list_add_tail(&conn->ibc_list,
>                          ^^^^^^^^^^^^^^ Use after free
> 3326                    &kiblnd_data.kib_reconn_list);
> 3327  else
> 3328      list_add_tail(&conn->ibc_list,
>                          ^^^^^^^^^^^^^^ Use after free
> 3329                    &kiblnd_data.kib_reconn_wait);

To avoid confusion this fix moved the freeing a struct kib_conn outside of
the function kiblnd_destroy_conn() and free as it was intended in original
commit.

Cc: <stable@vger.kernel.org> # v4.6
Fixes: 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
---
Changes in v4:
    - fixed the issue with use after free by moving the freeing a struct
      kib_conn outside of the function kiblnd_destroy_conn()

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
