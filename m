From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:14 -0400
Subject: [lustre-devel] [PATCH 18/23] lnet: clarify initialization of
 lpni_refcount
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This refcount is not explicitly initialized, so is implicitly
initialized to zero.  This prohibits the use
lnet_peer_ni_addref_locked() for taking the first reference,
so a couple of places open-code the atomic_inc just in case.

There is code in lnet_peer_add_nid() which drops a reference before
accessing the structure.  This isn't actually wrong, but it looks
weird.

lnet_destroy_peer_ni_locked() makes assumptions about the content of
the structure, so it cannot be used on a partially initialized
structure.

All these special cases make the code harder to understand.  This
patch cleans this up:

- lpni_refcount is now initialized to one, so the called for
  lnet_peer_ni_alloc() now owns a reference and must be sure
  to release it.
- lnet_peer_attach_peer_ni() now consumes a reference to
  the lpni.  A pointer returned by lnet_peer_ni_alloc()
  is most often passed to lnet_peer_attach_peer_ni() so
  these to changes largely cancel each other out - not completely
- The two 'atomic_inc' calls are changed to
  'lnet_peer_ni_addref_locked().
- A kfree is replaced by lnet_peer_ni_decref_locked(),
  and that function is improved to cope with lpni_hashlist
  being empty, or ->lpni_net being NULL.
- lnet_peer_add_nid() now holds a reference on the lpni until
  it don't need it any more, then explicity drops it.

This should make no functional change, but should make the code a
little less confusing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 5bcb17cf1d476 ("LU-12678 lnet: clarify initialization of lpni_refcount")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39120
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 48 +++++++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 578591d..81f908e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -125,6 +125,7 @@
 	INIT_LIST_HEAD(&lpni->lpni_recovery);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 	LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
+	atomic_set(&lpni->lpni_refcount, 1);
 
 	spin_lock_init(&lpni->lpni_lock);
 
@@ -152,7 +153,7 @@
 		 * list so it can be easily found and revisited.
 		 */
 		/* FIXME: per-net implementation instead? */
-		atomic_inc(&lpni->lpni_refcount);
+		lnet_peer_ni_addref_locked(lpni);
 		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
 			      &the_lnet.ln_remote_peer_ni_list);
 	}
@@ -1223,9 +1224,9 @@ struct lnet_peer_net *
  * may be attached to a different peer, in which case it will be
  * properly detached first. The whole operation is done atomically.
  *
- * Always returns 0.  This is the last function called from functions
- * that do return an int, so returning 0 here allows the compiler to
- * do a tail call.
+ * This function consumes the reference on lpni and Always returns 0.
+ * This is the last function called from functions that do return an
+ * int, so returning 0 here allows the compiler to do a tail call.
  */
 static int
 lnet_peer_attach_peer_ni(struct lnet_peer *lp,
@@ -1244,8 +1245,7 @@ struct lnet_peer_net *
 		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
 		list_add_tail(&lpni->lpni_hashlist, &ptable->pt_hash[hash]);
 		ptable->pt_version++;
-		/* This is the 1st refcount on lpni. */
-		atomic_inc(&lpni->lpni_refcount);
+		lnet_peer_ni_addref_locked(lpni);
 	}
 
 	/* Detach the peer_ni from an existing peer, if necessary. */
@@ -1293,11 +1293,12 @@ struct lnet_peer_net *
 	spin_unlock(&lp->lp_lock);
 
 	lp->lp_nnis++;
-	lnet_net_unlock(LNET_LOCK_EX);
 
 	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
 	       libcfs_nid2str(lp->lp_primary_nid),
 	       libcfs_nid2str(lpni->lpni_nid), flags);
+	lnet_peer_ni_decref_locked(lpni);
+	lnet_net_unlock(LNET_LOCK_EX);
 
 	return 0;
 }
@@ -1418,17 +1419,16 @@ struct lnet_peer_net *
 		 * it is not connected to this peer and was configured
 		 * by DLC.
 		 */
-		lnet_peer_ni_decref_locked(lpni);
 		if (lpni->lpni_peer_net->lpn_peer == lp)
-			goto out;
+			goto out_free_lpni;
 		if (lnet_peer_ni_is_configured(lpni)) {
 			rc = -EEXIST;
-			goto out;
+			goto out_free_lpni;
 		}
 		/* If this is the primary NID, destroy the peer. */
 		if (lnet_peer_ni_is_primary(lpni)) {
 			struct lnet_peer *rtr_lp =
-			  lpni->lpni_peer_net->lpn_peer;
+				lpni->lpni_peer_net->lpn_peer;
 			int rtr_refcount = rtr_lp->lp_rtr_refcount;
 
 			/* if we're trying to delete a router it means
@@ -1440,17 +1440,18 @@ struct lnet_peer_net *
 				lnet_rtr_transfer_to_peer(rtr_lp, lp);
 			}
 			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
+			lnet_peer_ni_decref_locked(lpni);
 			lpni = lnet_peer_ni_alloc(nid);
 			if (!lpni) {
 				rc = -ENOMEM;
-				goto out;
+				goto out_free_lpni;
 			}
 		}
 	} else {
 		lpni = lnet_peer_ni_alloc(nid);
 		if (!lpni) {
 			rc = -ENOMEM;
-			goto out;
+			goto out_free_lpni;
 		}
 	}
 
@@ -1473,9 +1474,7 @@ struct lnet_peer_net *
 	return lnet_peer_attach_peer_ni(lp, lpn, lpni, flags);
 
 out_free_lpni:
-	/* If the peer_ni was allocated above its peer_net pointer is NULL */
-	if (!lpni->lpni_peer_net)
-		kfree(lpni);
+	lnet_peer_ni_decref_locked(lpni);
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
 	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid),
@@ -1699,18 +1698,21 @@ struct lnet_peer_net *
 	lpni->lpni_peer_net = NULL;
 	lpni->lpni_net = NULL;
 
-	/* remove the peer ni from the zombie list */
-	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
-	spin_lock(&ptable->pt_zombie_lock);
-	list_del_init(&lpni->lpni_hashlist);
-	ptable->pt_zombies--;
-	spin_unlock(&ptable->pt_zombie_lock);
+	if (!list_empty(&lpni->lpni_hashlist)) {
+		/* remove the peer ni from the zombie list */
+		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
+		spin_lock(&ptable->pt_zombie_lock);
+		list_del_init(&lpni->lpni_hashlist);
+		ptable->pt_zombies--;
+		spin_unlock(&ptable->pt_zombie_lock);
+	}
 
 	if (lpni->lpni_pref_nnids > 1)
 		kfree(lpni->lpni_pref.nids);
 	kfree(lpni);
 
-	lnet_peer_net_decref_locked(lpn);
+	if (lpn)
+		lnet_peer_net_decref_locked(lpn);
 }
 
 struct lnet_peer_ni *
-- 
1.8.3.1
