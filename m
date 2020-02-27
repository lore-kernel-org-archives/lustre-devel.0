From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:52 -0500
Subject: [lustre-devel] [PATCH 604/622] lnet: fix small race in unloading
 klnd modules.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-605-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Reference counting of klnd modules is handled by the module itself.
Currently, it is possible for a module to be completely unloaded
between the time when the module called module_put(), and when
it subsequently returns from the function that makes that call.
During this time there may be one or two instructions to execute,
and if the module is unmapped before they are executed, an
exception will result.

The module unload will call lnet_unregister_lnd() which takes
the_lnet.ln_lnd_mutex, so module unload cannot complete while
that is held.  lnd_startup is called with this mutex held to
avoid any races, but lnd_shutdown is not.  Adding that
protection will close the race.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: c087091cd901 ("LU-12678 lnet: fix small race in unloading klnd modules.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36853
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0ca8bef..5df39aa 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1983,7 +1983,14 @@ static void lnet_push_target_fini(void)
 		islo = ni->ni_net->net_lnd->lnd_type == LOLND;
 
 		LASSERT(!in_interrupt());
+		/* Holding the mutex makes it safe for lnd_shutdown
+		 * to call module_put(). Module unload cannot finish
+		 * until lnet_unregister_lnd() completes, and that
+		 * requires the mutex.
+		 */
+		mutex_lock(&the_lnet.ln_lnd_mutex);
 		net->net_lnd->lnd_shutdown(ni);
+		mutex_unlock(&the_lnet.ln_lnd_mutex);
 
 		if (!islo)
 			CDEBUG(D_LNI, "Removed LNI %s\n",
-- 
1.8.3.1
