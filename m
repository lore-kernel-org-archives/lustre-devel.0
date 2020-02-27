From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:00 -0500
Subject: [lustre-devel] [PATCH 552/622] lnet: discard lnd_refcount
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-553-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The lnd_refcount in 'struct lnet_lnd' is never tested (except
in an ASSERT()), so it cannot be needed.  Let's remove it.

Each individual lnd keeps track of how many lnet_ni are
registered for that lnd e.g. ksocklnd has a counter in ksnd_nnets
and o2iblnd has a linked list in kib_devs.
They hold a reference on the module while there are registered
devices, and the lnd is only freed (and the lnd_refcount checked)
when the module is unloaded.  This confirms that lnd_refcount
adds no value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 606299929509 ("LU-12678 lnet: discard lnd_refcount")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36829
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  1 -
 net/lnet/lnet/api-ni.c         | 18 ------------------
 2 files changed, 19 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 4b110eb..e105308 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -246,7 +246,6 @@ struct lnet_test_peer {
 struct lnet_lnd {
 	/* fields managed by portals */
 	struct list_head	lnd_list;	/* stash in the LND table */
-	int			lnd_refcount;	/* # active instances */
 
 	/* fields initialised by the LND */
 	u32			lnd_type;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e66d9dc7..6c913b5 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -758,7 +758,6 @@ static void lnet_assert_wire_constants(void)
 	LASSERT(!lnet_find_lnd_by_type(lnd->lnd_type));
 
 	list_add_tail(&lnd->lnd_list, &the_lnet.ln_lnds);
-	lnd->lnd_refcount = 0;
 
 	CDEBUG(D_NET, "%s LND registered\n", libcfs_lnd2str(lnd->lnd_type));
 
@@ -772,7 +771,6 @@ static void lnet_assert_wire_constants(void)
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
 	LASSERT(lnet_find_lnd_by_type(lnd->lnd_type) == lnd);
-	LASSERT(!lnd->lnd_refcount);
 
 	list_del(&lnd->lnd_list);
 	CDEBUG(D_NET, "%s LND unregistered\n", libcfs_lnd2str(lnd->lnd_type));
@@ -2045,15 +2043,6 @@ static void lnet_push_target_fini(void)
 	/* Do peer table cleanup for this net */
 	lnet_peer_tables_cleanup(net);
 
-	lnet_net_lock(LNET_LOCK_EX);
-	/*
-	 * decrement ref count on lnd only when the entire network goes
-	 * away
-	 */
-	net->net_lnd->lnd_refcount--;
-
-	lnet_net_unlock(LNET_LOCK_EX);
-
 	lnet_net_free(net);
 }
 
@@ -2134,9 +2123,6 @@ static void lnet_push_target_fini(void)
 	if (rc) {
 		LCONSOLE_ERROR_MSG(0x105, "Error %d starting up LNI %s\n",
 				   rc, libcfs_lnd2str(net->net_lnd->lnd_type));
-		lnet_net_lock(LNET_LOCK_EX);
-		net->net_lnd->lnd_refcount--;
-		lnet_net_unlock(LNET_LOCK_EX);
 		goto failed0;
 	}
 
@@ -2247,10 +2233,6 @@ static void lnet_push_target_fini(void)
 			}
 		}
 
-		lnet_net_lock(LNET_LOCK_EX);
-		lnd->lnd_refcount++;
-		lnet_net_unlock(LNET_LOCK_EX);
-
 		net->net_lnd = lnd;
 
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
-- 
1.8.3.1
