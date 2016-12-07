From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:36 -0500
Subject: [lustre-devel] [PATCH 1/5] staging/lustre/o2iblnd: Add missing space
In-Reply-To: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
References: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481086660-1610943-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

checkpatch highlighted missing space before assignment
for lock variable.

+       spinlock_t *lock= &kiblnd_data.kib_connd_lock;

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 92692a2..bea408d 100644
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
