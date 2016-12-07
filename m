From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:39 -0500
Subject: [lustre-devel] [PATCH 4/5] staging/lustre/o2iblnd: Fix misspelling
	intialized->intialized
In-Reply-To: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
References: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481086660-1610943-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Highlighted by checkpatch:
+       if (!ps->ps_net) /* intialized? */

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index e2fc65f..7f761b3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1489,7 +1489,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 static void kiblnd_fail_fmr_poolset(struct kib_fmr_poolset *fps,
 				    struct list_head *zombies)
 {
-	if (!fps->fps_net) /* intialized? */
+	if (!fps->fps_net) /* initialized? */
 		return;
 
 	spin_lock(&fps->fps_lock);
@@ -1812,7 +1812,7 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
 
 static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombies)
 {
-	if (!ps->ps_net) /* intialized? */
+	if (!ps->ps_net) /* initialized? */
 		return;
 
 	spin_lock(&ps->ps_lock);
-- 
2.7.4
