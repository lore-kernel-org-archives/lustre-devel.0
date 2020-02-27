From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:23 -0500
Subject: [lustre-devel] [PATCH 575/622] lnet: prepare to make lnet_lnd const.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-576-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

Preferred practice is for structs containing function
pointers to be 'const'.  Such structs are generally tempting
attack vectors, and making them const allows linux to place
them in read-only memory, thus reducing the attack surface.

'struct lnet_lnd' is mostly function pointers, but contains
one writable field - a list_head.

Rather than keeping registered lnds in a linked-list, we can place
them in an array indexed by type - type numbers are at most 15 so
this is not a burden.

With these changes, no part of an lnet_lnd is ever modified.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 87a6bd0766da ("LU-12678 lnet: prepare to make lnet_lnd const.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36830
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h   |  6 ++----
 include/uapi/linux/lnet/nidstr.h |  2 ++
 net/lnet/lnet/api-ni.c           | 29 +++++++++++++++--------------
 net/lnet/lnet/lo.c               |  1 -
 4 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 02ac5df..99ed87a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -46,6 +46,7 @@
 #include <uapi/linux/lnet/lnet-types.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
+#include <uapi/linux/lnet/nidstr.h>
 
 /* Max payload size */
 #define LNET_MAX_PAYLOAD	LNET_MTU
@@ -244,9 +245,6 @@ struct lnet_test_peer {
 struct lnet_ni;			/* forward ref */
 
 struct lnet_lnd {
-	/* fields managed by portals */
-	struct list_head	lnd_list;	/* stash in the LND table */
-
 	/* fields initialised by the LND */
 	u32			lnd_type;
 
@@ -1133,7 +1131,7 @@ struct lnet {
 	/* uniquely identifies this ni in this epoch */
 	u64				ln_interface_cookie;
 	/* registered LNDs */
-	struct list_head		ln_lnds;
+	struct lnet_lnd			*ln_lnds[NUM_LNDS];
 
 	/* test protocol compatibility flags */
 	int				ln_testprotocompat;
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 43ec232..958ca8d 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -53,6 +53,8 @@ enum {
 	/*MXLND		= 12, removed v2_7_50_0-34-g8be9e41	*/
 	GNILND		= 13,
 	GNIIPLND	= 14,
+
+	NUM_LNDS
 };
 
 struct list_head;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0020ffd..cd95bdd 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -734,12 +734,12 @@ static void lnet_assert_wire_constants(void)
 	struct lnet_lnd *lnd;
 
 	/* holding lnd mutex */
-	list_for_each_entry(lnd, &the_lnet.ln_lnds, lnd_list) {
-		if (lnd->lnd_type == type)
-			return lnd;
-	}
+	if (type >= NUM_LNDS)
+		return NULL;
+	lnd = the_lnet.ln_lnds[type];
+	LASSERT(!lnd || lnd->lnd_type == type);
 
-	return NULL;
+	return lnd;
 }
 
 unsigned int
@@ -757,7 +757,7 @@ static void lnet_assert_wire_constants(void)
 	LASSERT(libcfs_isknown_lnd(lnd->lnd_type));
 	LASSERT(!lnet_find_lnd_by_type(lnd->lnd_type));
 
-	list_add_tail(&lnd->lnd_list, &the_lnet.ln_lnds);
+	the_lnet.ln_lnds[lnd->lnd_type] = lnd;
 
 	CDEBUG(D_NET, "%s LND registered\n", libcfs_lnd2str(lnd->lnd_type));
 
@@ -772,7 +772,7 @@ static void lnet_assert_wire_constants(void)
 
 	LASSERT(lnet_find_lnd_by_type(lnd->lnd_type) == lnd);
 
-	list_del(&lnd->lnd_list);
+	the_lnet.ln_lnds[lnd->lnd_type] = NULL;
 	CDEBUG(D_NET, "%s LND unregistered\n", libcfs_lnd2str(lnd->lnd_type));
 
 	mutex_unlock(&the_lnet.ln_lnd_mutex);
@@ -2429,7 +2429,6 @@ int lnet_lib_init(void)
 	}
 
 	the_lnet.ln_refcount = 0;
-	INIT_LIST_HEAD(&the_lnet.ln_lnds);
 	INIT_LIST_HEAD(&the_lnet.ln_net_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_msg_resend);
 
@@ -2459,16 +2458,18 @@ int lnet_lib_init(void)
  *
  * \pre lnet_lib_init() called with success.
  * \pre All LNet users called LNetNIFini() for matching LNetNIInit() calls.
+ *
+ * As this happens at module-unload, all lnds must already be unloaded,
+ * so they must already be unregistered.
  */
 void lnet_lib_exit(void)
 {
-	struct lnet_lnd *lnd;
-	LASSERT(!the_lnet.ln_refcount);
+	int i;
 
-	while ((lnd = list_first_entry_or_null(&the_lnet.ln_lnds,
-					       struct lnet_lnd,
-					       lnd_list)) != NULL)
-		lnet_unregister_lnd(lnd);
+	LASSERT(!the_lnet.ln_refcount);
+	lnet_unregister_lnd(&the_lolnd);
+	for (i = 0; i < NUM_LNDS; i++)
+		LASSERT(!the_lnet.ln_lnds[i]);
 	lnet_destroy_locks();
 }
 
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index 350495f..c19a5b5 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -93,7 +93,6 @@
 }
 
 struct lnet_lnd the_lolnd = {
-	.lnd_list	= LIST_HEAD_INIT(the_lolnd.lnd_list),
 	.lnd_type	= LOLND,
 	.lnd_startup	= lolnd_startup,
 	.lnd_shutdown	= lolnd_shutdown,
-- 
1.8.3.1
