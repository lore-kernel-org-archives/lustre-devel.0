From: Dmitry Eremin <dmitry.eremin@intel.com>
Date: Wed, 24 Jan 2018 15:45:36 +0300
Subject: [lustre-devel] [PATCH v2] staging: lustre: Fix avoid intensive
 reconnecting for ko2iblnd patch
In-Reply-To: <20180122103924.GB23996@kroah.com>
References: <20180122103924.GB23996@kroah.com>
Message-ID: <1516797936-5938-1-git-send-email-dmitry.eremin@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <Dmitry.Eremin@intel.com>, stable@vger.kernel.org, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <Dmitry.Eremin@intel.com>

The logic of the original commit 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
was assumed conditional free of struct kib_conn if the second argument free_conn
in function kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn) is true.
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

After attached patch this code will use struct kib_conn only when it was not freed.

Cc: <stable@vger.kernel.org> # v4.6
Fixes: 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2ebc484385b3..a15a625ee9b6 100644
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
