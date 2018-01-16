From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Tue, 16 Jan 2018 18:02:07 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Fix avoid intensive
 reconnecting for ko2iblnd patch
In-Reply-To: <1516114161-27679-1-git-send-email-Dmitry.Eremin@intel.com>
References: <1516114161-27679-1-git-send-email-Dmitry.Eremin@intel.com>
Message-ID: <9FC73D3DBECE0941BD2ED069D26863425CE76069@irsmsx110.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "Eremin, Dmitry" <dmitry.eremin@intel.com>

The logic of the original commit 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
was assumed conditional free of struct kib_conn if the second argument free_conn in function
kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn) is true. But this hunk of code was dropped
from original commit. As result the logic works wrong and current code use struct kib_conn after
free.

> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
>   3317                          kiblnd_destroy_conn(conn, !peer);
>                                                     ^^^^ Freed always (but should be conditionally)
>   3318
>   3319                          spin_lock_irqsave(lock, flags);
>   3320                          if (!peer)
>   3321                                  continue;
>   3322
>   3323                          conn->ibc_peer = peer;
>                                     ^^^^^^^^^^^^^ Use after free
>   3324                          if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
>   3325                                  list_add_tail(&conn->ibc_list,
>                                                                        ^^^^^^^^^^^^
>   3326                                                &kiblnd_data.kib_reconn_list);
>   3327                          else
>   3328                                  list_add_tail(&conn->ibc_list,
>                                                                         ^^^^^^^^^^^^
>   3329                                                &kiblnd_data.kib_reconn_wait);

After attached patch this code will use struct kib_conn only when it was not freed.

Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2ebc484..a15a625 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -890,7 +890,8 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 		atomic_dec(&net->ibn_nconns);
 	}
 
-	kfree(conn);
+	if (free_conn)
+		kfree(conn);
 }
 
 int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
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
