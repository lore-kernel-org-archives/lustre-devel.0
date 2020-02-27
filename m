From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:04 -0500
Subject: [lustre-devel] [PATCH 556/622] lnet: discard LNetMEInsert
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-557-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This function is unused and has never been used.
It is not used by cray-dvs - the other user of LNet.

So discard it.

Lustre-commit: bd5e458cc5fc ("LU-12678 lnet: discard LNetMEInsert")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36858
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/api.h | 10 +-----
 net/lnet/lnet/lib-me.c   | 91 ++----------------------------------------------
 2 files changed, 3 insertions(+), 98 deletions(-)

diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 4b152c8..ac602fc 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -91,7 +91,7 @@
  * and a set of match criteria. The match criteria can be used to reject
  * incoming requests based on process ID or the match bits provided in the
  * request. MEs can be dynamically inserted into a match list by LNetMEAttach()
- * and LNetMEInsert(), and removed from its list by LNetMEUnlink().
+ * and removed from its list by LNetMEUnlink().
  * @{
  */
 int LNetMEAttach(unsigned int portal,
@@ -102,14 +102,6 @@ int LNetMEAttach(unsigned int portal,
 		 enum lnet_ins_pos pos_in,
 		 struct lnet_handle_me *handle_out);
 
-int LNetMEInsert(struct lnet_handle_me current_in,
-		 struct lnet_process_id match_id_in,
-		 u64 match_bits_in,
-		 u64 ignore_bits_in,
-		 enum lnet_unlink unlink_in,
-		 enum lnet_ins_pos position_in,
-		 struct lnet_handle_me *handle_out);
-
 int LNetMEUnlink(struct lnet_handle_me current_in);
 /** @} lnet_me */
 
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index 4fe6991..47cf498 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -63,8 +63,8 @@
  *		appended to the match list. Allowed constants: LNET_INS_BEFORE,
  *		LNET_INS_AFTER.
  * @handle	On successful returns, a handle to the newly created ME object
- *		is saved here. This handle can be used later in LNetMEInsert(),
- *		LNetMEUnlink(), or LNetMDAttach() functions.
+ *		is saved here. This handle can be used later in LNetMEUnlink(),
+ *		or LNetMDAttach() functions.
  *
  * Return:	0 On success.
  *		-EINVAL If @portal is invalid.
@@ -125,93 +125,6 @@
 EXPORT_SYMBOL(LNetMEAttach);
 
 /**
- * Create and a match entry and insert it before or after the ME pointed to by
- * @current_meh. The new ME is empty, i.e. not associated with a memory
- * descriptor. LNetMDAttach() can be used to attach a MD to an empty ME.
- *
- * This function is identical to LNetMEAttach() except for the position
- * where the new ME is inserted.
- *
- * @current_meh		A handle for a ME. The new ME will be inserted
- *			immediately before or immediately after this ME.
- * @match_id		See the discussion for LNetMEAttach().
- * @match_bits
- * @ignore_bits
- * @unlink
- * @pos
- * @handle
- *
- * Return:		0 On success.
- *			-ENOMEM If new ME object cannot be allocated.
- *			-ENOENT If @current_meh does not point to a valid match entry.
- */
-int
-LNetMEInsert(struct lnet_handle_me current_meh,
-	     struct lnet_process_id match_id,
-	     u64 match_bits, u64 ignore_bits,
-	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
-	     struct lnet_handle_me *handle)
-{
-	struct lnet_me *current_me;
-	struct lnet_me *new_me;
-	struct lnet_portal *ptl;
-	int cpt;
-
-	LASSERT(the_lnet.ln_refcount > 0);
-
-	if (pos == LNET_INS_LOCAL)
-		return -EPERM;
-
-	new_me = kzalloc(sizeof(*new_me), GFP_NOFS);
-	if (!new_me)
-		return -ENOMEM;
-
-	cpt = lnet_cpt_of_cookie(current_meh.cookie);
-
-	lnet_res_lock(cpt);
-
-	current_me = lnet_handle2me(&current_meh);
-	if (!current_me) {
-		kfree(new_me);
-
-		lnet_res_unlock(cpt);
-		return -ENOENT;
-	}
-
-	LASSERT(current_me->me_portal < the_lnet.ln_nportals);
-
-	ptl = the_lnet.ln_portals[current_me->me_portal];
-	if (lnet_ptl_is_unique(ptl)) {
-		/* nosense to insertion on unique portal */
-		kfree(new_me);
-		lnet_res_unlock(cpt);
-		return -EPERM;
-	}
-
-	new_me->me_pos = current_me->me_pos;
-	new_me->me_portal = current_me->me_portal;
-	new_me->me_match_id = match_id;
-	new_me->me_match_bits = match_bits;
-	new_me->me_ignore_bits = ignore_bits;
-	new_me->me_unlink = unlink;
-	new_me->me_md = NULL;
-
-	lnet_res_lh_initialize(the_lnet.ln_me_containers[cpt], &new_me->me_lh);
-
-	if (pos == LNET_INS_AFTER)
-		list_add(&new_me->me_list, &current_me->me_list);
-	else
-		list_add_tail(&new_me->me_list, &current_me->me_list);
-
-	lnet_me2handle(handle, new_me);
-
-	lnet_res_unlock(cpt);
-
-	return 0;
-}
-EXPORT_SYMBOL(LNetMEInsert);
-
-/**
  * Unlink a match entry from its match list.
  *
  * This operation also releases any resources associated with the ME. If a
-- 
1.8.3.1
