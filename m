From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Thu, 29 Dec 2016 21:09:01 +0530
Subject: [lustre-devel] [PATCH] staging:lustre:fixed space coding style in
	o2iblnd_cb.c
Message-ID: <1483025941-2726-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Space required before assignment operator,
to make close to kernel coding style.
This error is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b27de88..ba1782b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3276,7 +3276,7 @@ kiblnd_disconnect_conn(struct kib_conn *conn)
 int
 kiblnd_connd(void *arg)
 {
-	spinlock_t *lock= &kiblnd_data.kib_connd_lock;
+	spinlock_t *lock = &kiblnd_data.kib_connd_lock;
 	wait_queue_t wait;
 	unsigned long flags;
 	struct kib_conn *conn;
-- 
2.7.4
