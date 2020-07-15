From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:03 -0400
Subject: [lustre-devel] [PATCH 22/37] lnet: o2iblnd: wait properly for
 fps->increasing.
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

If we need to allocate a new fmr_pool and another thread is currently
allocating one, we call schedule() and then try again.  This can spin,
consuming a CPU and wasting power.

Instead, use wait_var_event() and wake_up_var() to
wait for fps_increasing to be cleared.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 530eca31556f7 ("LU-12768 o2iblnd: wait properly for fps->increasing.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39124
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index e2e94b7..6c7659c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1750,7 +1750,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	if (fps->fps_increasing) {
 		spin_unlock(&fps->fps_lock);
 		CDEBUG(D_NET, "Another thread is allocating new FMR pool, waiting for her to complete\n");
-		schedule();
+		wait_var_event(fps, !fps->fps_increasing);
 		goto again;
 	}
 
@@ -1767,6 +1767,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	rc = kiblnd_create_fmr_pool(fps, &fpo);
 	spin_lock(&fps->fps_lock);
 	fps->fps_increasing = 0;
+	wake_up_var(fps);
 	if (!rc) {
 		fps->fps_version++;
 		list_add_tail(&fpo->fpo_list, &fps->fps_pool_list);
-- 
1.8.3.1
