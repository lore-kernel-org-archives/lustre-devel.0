From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 01/15] staging: lustre: lnet-lib: opencode
 some alloc/free functions.
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799021.6200.6628779311633006988.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These functions just call LIBCFS_ALLOC() which in-turn
calls kvmalloc().
In none of these cases is the 'vmalloc' option needed.

LIBCFS_ALLOC also produces a warning if NULL is returned,
but that can be provided with CONFIG_SLAB_DEBUG.

LIBCFS_ALLOC zeros the memory, so we need to use
__GFP_ZERO too.

So with one exception where the alloc function is not trivial,
open-code the alloc and free functions using kmalloc and kfree.

Note that the 'size' used in lnet_md_alloc() is limited and less than
a page because LNET_MAX_IOV is 256, so kvmalloc is not needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   63 --------------------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 +
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    8 +--
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   10 ++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   18 +++---
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    2 -
 8 files changed, 28 insertions(+), 89 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c1626726fa05..df4c72507a15 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -181,21 +181,6 @@ lnet_net_lock_current(void)
 
 #define MAX_PORTALS		64
 
-static inline struct lnet_eq *
-lnet_eq_alloc(void)
-{
-	struct lnet_eq *eq;
-
-	LIBCFS_ALLOC(eq, sizeof(*eq));
-	return eq;
-}
-
-static inline void
-lnet_eq_free(struct lnet_eq *eq)
-{
-	LIBCFS_FREE(eq, sizeof(*eq));
-}
-
 static inline struct lnet_libmd *
 lnet_md_alloc(struct lnet_md *umd)
 {
@@ -211,7 +196,7 @@ lnet_md_alloc(struct lnet_md *umd)
 		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
 	}
 
-	LIBCFS_ALLOC(md, size);
+	md = kzalloc(size, GFP_NOFS);
 
 	if (md) {
 		/* Set here in case of early free */
@@ -223,52 +208,6 @@ lnet_md_alloc(struct lnet_md *umd)
 	return md;
 }
 
-static inline void
-lnet_md_free(struct lnet_libmd *md)
-{
-	unsigned int size;
-
-	if (md->md_options & LNET_MD_KIOV)
-		size = offsetof(struct lnet_libmd, md_iov.kiov[md->md_niov]);
-	else
-		size = offsetof(struct lnet_libmd, md_iov.iov[md->md_niov]);
-
-	LIBCFS_FREE(md, size);
-}
-
-static inline struct lnet_me *
-lnet_me_alloc(void)
-{
-	struct lnet_me *me;
-
-	LIBCFS_ALLOC(me, sizeof(*me));
-	return me;
-}
-
-static inline void
-lnet_me_free(struct lnet_me *me)
-{
-	LIBCFS_FREE(me, sizeof(*me));
-}
-
-static inline struct lnet_msg *
-lnet_msg_alloc(void)
-{
-	struct lnet_msg *msg;
-
-	LIBCFS_ALLOC(msg, sizeof(*msg));
-
-	/* no need to zero, LIBCFS_ALLOC does for us */
-	return msg;
-}
-
-static inline void
-lnet_msg_free(struct lnet_msg *msg)
-{
-	LASSERT(!msg->msg_onactivelist);
-	LIBCFS_FREE(msg, sizeof(*msg));
-}
-
 struct lnet_libhandle *lnet_res_lh_lookup(struct lnet_res_container *rec,
 					  __u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7caff290c146..30d0999118c7 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -384,10 +384,10 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 
 		list_del_init(e);
 		if (rec->rec_type == LNET_COOKIE_TYPE_EQ) {
-			lnet_eq_free(list_entry(e, struct lnet_eq, eq_list));
+			kfree(list_entry(e, struct lnet_eq, eq_list));
 
 		} else if (rec->rec_type == LNET_COOKIE_TYPE_MD) {
-			lnet_md_free(list_entry(e, struct lnet_libmd, md_list));
+			kfree(list_entry(e, struct lnet_libmd, md_list));
 
 		} else { /* NB: Active MEs should be attached on portals */
 			LBUG();
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index daf744277003..7a4d1f7a693e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -90,7 +90,7 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	if (!count && callback == LNET_EQ_HANDLER_NONE)
 		return -EINVAL;
 
-	eq = lnet_eq_alloc();
+	eq = kzalloc(sizeof(*eq), GFP_NOFS);
 	if (!eq)
 		return -ENOMEM;
 
@@ -138,7 +138,7 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	if (eq->eq_refs)
 		cfs_percpt_free(eq->eq_refs);
 
-	lnet_eq_free(eq);
+	kfree(eq);
 	return -ENOMEM;
 }
 EXPORT_SYMBOL(LNetEQAlloc);
@@ -197,7 +197,7 @@ LNetEQFree(struct lnet_handle_eq eqh)
 
 	lnet_res_lh_invalidate(&eq->eq_lh);
 	list_del(&eq->eq_list);
-	lnet_eq_free(eq);
+	kfree(eq);
  out:
 	lnet_eq_wait_unlock();
 	lnet_res_unlock(LNET_LOCK_EX);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index ac5b9593d597..8a22514aaf71 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -81,7 +81,7 @@ lnet_md_unlink(struct lnet_libmd *md)
 
 	LASSERT(!list_empty(&md->md_list));
 	list_del_init(&md->md_list);
-	lnet_md_free(md);
+	kfree(md);
 }
 
 static int
@@ -173,7 +173,7 @@ lnet_md_link(struct lnet_libmd *md, struct lnet_handle_eq eq_handle, int cpt)
 	/*
 	 * NB we are passed an allocated, but inactive md.
 	 * if we return success, caller may lnet_md_unlink() it.
-	 * otherwise caller may only lnet_md_free() it.
+	 * otherwise caller may only kfree() it.
 	 */
 	/*
 	 * This implementation doesn't know how to create START events or
@@ -329,7 +329,7 @@ LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
 out_unlock:
 	lnet_res_unlock(cpt);
 out_free:
-	lnet_md_free(md);
+	kfree(md);
 	return rc;
 }
 EXPORT_SYMBOL(LNetMDAttach);
@@ -390,7 +390,7 @@ LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
 out_unlock:
 	lnet_res_unlock(cpt);
 out_free:
-	lnet_md_free(md);
+	kfree(md);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index dd5d3cf6d3e2..672e37bdd045 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -90,7 +90,7 @@ LNetMEAttach(unsigned int portal,
 	if (!mtable) /* can't match portal type */
 		return -EPERM;
 
-	me = lnet_me_alloc();
+	me = kzalloc(sizeof(*me), GFP_NOFS);
 	if (!me)
 		return -ENOMEM;
 
@@ -157,7 +157,7 @@ LNetMEInsert(struct lnet_handle_me current_meh,
 	if (pos == LNET_INS_LOCAL)
 		return -EPERM;
 
-	new_me = lnet_me_alloc();
+	new_me = kzalloc(sizeof(*new_me), GFP_NOFS);
 	if (!new_me)
 		return -ENOMEM;
 
@@ -167,7 +167,7 @@ LNetMEInsert(struct lnet_handle_me current_meh,
 
 	current_me = lnet_handle2me(&current_meh);
 	if (!current_me) {
-		lnet_me_free(new_me);
+		kfree(new_me);
 
 		lnet_res_unlock(cpt);
 		return -ENOENT;
@@ -178,7 +178,7 @@ LNetMEInsert(struct lnet_handle_me current_meh,
 	ptl = the_lnet.ln_portals[current_me->me_portal];
 	if (lnet_ptl_is_unique(ptl)) {
 		/* nosense to insertion on unique portal */
-		lnet_me_free(new_me);
+		kfree(new_me);
 		lnet_res_unlock(cpt);
 		return -EPERM;
 	}
@@ -270,5 +270,5 @@ lnet_me_unlink(struct lnet_me *me)
 	}
 
 	lnet_res_lh_invalidate(&me->me_lh);
-	lnet_me_free(me);
+	kfree(me);
 }
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 68d16ffec980..137e3ab970dc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1769,7 +1769,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 		goto drop;
 	}
 
-	msg = lnet_msg_alloc();
+	msg = kzalloc(sizeof(*msg), GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
@@ -1777,7 +1777,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 		goto drop;
 	}
 
-	/* msg zeroed in lnet_msg_alloc;
+	/* msg zeroed by kzalloc()
 	 * i.e. flags all clear, pointers NULL etc
 	 */
 	msg->msg_type = type;
@@ -1812,7 +1812,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type), rc);
-		lnet_msg_free(msg);
+		kfree(msg);
 		if (rc == -ESHUTDOWN)
 			/* We are shutting down. Don't do anything more */
 			return 0;
@@ -2010,7 +2010,7 @@ LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 		return -EIO;
 	}
 
-	msg = lnet_msg_alloc();
+	msg = kzalloc(sizeof(*msg), GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping PUT to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
@@ -2031,7 +2031,7 @@ LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 			       md->md_me->me_portal);
 		lnet_res_unlock(cpt);
 
-		lnet_msg_free(msg);
+		kfree(msg);
 		return -ENOENT;
 	}
 
@@ -2086,7 +2086,7 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
 	 * CAVEAT EMPTOR: 'getmsg' is the original GET, which is freed when
 	 * lnet_finalize() is called on it, so the LND must call this first
 	 */
-	struct lnet_msg *msg = lnet_msg_alloc();
+	struct lnet_msg *msg = kzalloc(sizeof(*msg), GFP_NOFS);
 	struct lnet_libmd *getmd = getmsg->msg_md;
 	struct lnet_process_id peer_id = getmsg->msg_target;
 	int cpt;
@@ -2147,7 +2147,7 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
 	lnet_net_unlock(cpt);
 
 	if (msg)
-		lnet_msg_free(msg);
+		kfree(msg);
 
 	return NULL;
 }
@@ -2215,7 +2215,7 @@ LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
 		return -EIO;
 	}
 
-	msg = lnet_msg_alloc();
+	msg = kzalloc(sizeof(*msg), GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping GET to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
@@ -2236,7 +2236,7 @@ LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
 
 		lnet_res_unlock(cpt);
 
-		lnet_msg_free(msg);
+		kfree(msg);
 		return -ENOENT;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index c72ef05b2420..ff6c43323fb5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -433,7 +433,7 @@ lnet_complete_msg_locked(struct lnet_msg *msg, int cpt)
 	}
 
 	lnet_msg_decommit(msg, cpt, status);
-	lnet_msg_free(msg);
+	kfree(msg);
 	return 0;
 }
 
@@ -466,7 +466,7 @@ lnet_finalize(struct lnet_ni *ni, struct lnet_msg *msg, int status)
 	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
 		/* not committed to network yet */
 		LASSERT(!msg->msg_onactivelist);
-		lnet_msg_free(msg);
+		kfree(msg);
 		return;
 	}
 
@@ -546,7 +546,7 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 		LASSERT(msg->msg_onactivelist);
 		msg->msg_onactivelist = 0;
 		list_del(&msg->msg_activelist);
-		lnet_msg_free(msg);
+		kfree(msg);
 		count++;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 8ae93bf6fd1b..519cfebaaa88 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -771,7 +771,7 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
 						struct lnet_me, me_list);
 				CERROR("Active ME %p on exit\n", me);
 				list_del(&me->me_list);
-				lnet_me_free(me);
+				kfree(me);
 			}
 		}
 		/* the extra entry is for MEs with ignore bits */
