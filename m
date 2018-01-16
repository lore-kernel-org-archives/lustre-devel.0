From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Tue, 16 Jan 2018 15:01:49 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Fix avoid intensive
 reconnecting for ko2iblnd patch
In-Reply-To: <1516114161-27679-1-git-send-email-Dmitry.Eremin@intel.com>
References: <1516114161-27679-1-git-send-email-Dmitry.Eremin@intel.com>
Message-ID: <9FC73D3DBECE0941BD2ED069D26863425CE75F26@irsmsx110.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

In the original commit 4d99b2581effe115376402e710fbcb1c3c073769
was missed one hunk. Added it now to avoid issue with use after free.

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
