From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:13 -0400
Subject: [lustre-devel] [PATCH 32/37] lnet: remove LNetMEUnlink and clean up
 related code
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

LNetMEUnlink is not particularly useful, and exposing it as an LNet
interface only provides the opportunity for it to be misused.

Every successful call to LNetMEAttach() is followed by a call to
LNetMDAttach().  If that call succeeds, the ME is owned by
the MD and the caller mustn't touch it again.
If the call fails, the caller is currently required to call
LNetMEUnlink(), which all callers do, and these are the only places
that LNetMEUnlink() are called.

As LNetMDAttach() knows when it will fail, it can unlink the ME itself
and save the caller the effort.
This allows LNetMEUnlink() to be removed which simplifies
the LNet interface.

LNetMEUnlink() is also used in in ptl_send_rpc() in a situation where
ptl_send_buf() fails.  In this case both the ME and the MD need to be
unlinked, as as they are interconnected, LNetMEUnlink() or
LNetMDUnlink() can equally do the job.  So change it to use
LNetMDUnlink().

LNetMEUnlink() is primarily a call the lnet_me_unlink(). It also
 - has some handling if ->me_md is not NULL, but that is never the
   case
 - takes the lnet_res_lock().  However LNetMDAttach() already
   takes that lock.
So none of this functionality is useful to LNetMDAttach().
On failure, it can call lnet_me_unlink() directly while ensuring
it still has the lock.

This patch:
 - moves the calls to lnet_md_validate() into lnet_md_build()
 - changes LNetMDAttach() to always take the lnet_res_lock(),
   and to call lnet_me_unlink() on failure.
 - removes all calls to LNetMEUnlink() and sometimes simplifies
   surrounding code.
 - changes lnet_md_link() to 'void' as it only ever returns
   '0', and thus simplify error handling in LNetMDAttach()
   and LNetMDBind()

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: e17ee2296c201 ("LU-12678 lnet: remove LNetMEUnlink and clean up related code")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38646
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 12 +++------
 include/linux/lnet/api.h  |  6 ++---
 net/lnet/lnet/api-ni.c    |  5 +---
 net/lnet/lnet/lib-md.c    | 62 +++++++++++++++--------------------------------
 net/lnet/lnet/lib-me.c    | 39 -----------------------------
 net/lnet/selftest/rpc.c   |  1 -
 6 files changed, 26 insertions(+), 99 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 6fb79a2..924b9c4 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -203,7 +203,6 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 			CERROR("%s: LNetMDAttach failed x%llu/%d: rc = %d\n",
 			       desc->bd_import->imp_obd->obd_name, mbits,
 			       posted_md, rc);
-			LNetMEUnlink(me);
 			break;
 		}
 	}
@@ -676,7 +675,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			request->rq_receiving_reply = 0;
 			spin_unlock(&request->rq_lock);
 			rc = -ENOMEM;
-			goto cleanup_me;
+			goto cleanup_bulk;
 		}
 		percpu_ref_get(&ptlrpc_pending);
 
@@ -720,12 +719,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	if (noreply)
 		goto out;
 
-cleanup_me:
-	/* MEUnlink is safe; the PUT didn't even get off the ground, and
-	 * nobody apart from the PUT's target has the right nid+XID to
-	 * access the reply buffer.
-	 */
-	LNetMEUnlink(reply_me);
+	LNetMDUnlink(request->rq_reply_md_h);
+
 	/* UNLINKED callback called synchronously */
 	LASSERT(!request->rq_receiving_reply);
 
@@ -802,7 +797,6 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 
 	CERROR("ptlrpc: LNetMDAttach failed: rc = %d\n", rc);
 	LASSERT(rc == -ENOMEM);
-	LNetMEUnlink(me);
 	rqbd->rqbd_refcount = 0;
 
 	return -ENOMEM;
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 24115eb..95805de 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -90,8 +90,8 @@
  * list is a chain of MEs. Each ME includes a pointer to a memory descriptor
  * and a set of match criteria. The match criteria can be used to reject
  * incoming requests based on process ID or the match bits provided in the
- * request. MEs can be dynamically inserted into a match list by LNetMEAttach()
- * and removed from its list by LNetMEUnlink().
+ * request. MEs can be dynamically inserted into a match list by LNetMEAttach(),
+ * and must then be attached to an MD with LNetMDAttach().
  * @{
  */
 struct lnet_me *
@@ -101,8 +101,6 @@ struct lnet_me *
 	     u64 ignore_bits_in,
 	     enum lnet_unlink unlink_in,
 	     enum lnet_ins_pos pos_in);
-
-void LNetMEUnlink(struct lnet_me *current_in);
 /** @} lnet_me */
 
 /** \defgroup lnet_md Memory descriptors
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 3e69435..5f35468 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1645,14 +1645,12 @@ struct lnet_ping_buffer *
 	rc = LNetMDAttach(me, &md, LNET_RETAIN, ping_mdh);
 	if (rc) {
 		CERROR("Can't attach ping target MD: %d\n", rc);
-		goto fail_unlink_ping_me;
+		goto fail_decref_ping_buffer;
 	}
 	lnet_ping_buffer_addref(*ppbuf);
 
 	return 0;
 
-fail_unlink_ping_me:
-	LNetMEUnlink(me);
 fail_decref_ping_buffer:
 	LASSERT(atomic_read(&(*ppbuf)->pb_refcnt) == 1);
 	lnet_ping_buffer_decref(*ppbuf);
@@ -1855,7 +1853,6 @@ int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 	rc = LNetMDAttach(me, &md, LNET_UNLINK, mdhp);
 	if (rc) {
 		CERROR("Can't attach push MD: %d\n", rc);
-		LNetMEUnlink(me);
 		lnet_ping_buffer_decref(pbuf);
 		pbuf->pb_needs_post = true;
 		return rc;
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index e80dc6f..48249f3 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -123,6 +123,8 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	return cpt;
 }
 
+static int lnet_md_validate(const struct lnet_md *umd);
+
 static struct lnet_libmd *
 lnet_md_build(const struct lnet_md *umd, int unlink)
 {
@@ -132,6 +134,9 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	struct lnet_libmd *lmd;
 	unsigned int size;
 
+	if (lnet_md_validate(umd) != 0)
+		return ERR_PTR(-EINVAL);
+
 	if (umd->options & LNET_MD_KIOV)
 		niov = umd->length;
 	else
@@ -228,15 +233,14 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 }
 
 /* must be called with resource lock held */
-static int
+static void
 lnet_md_link(struct lnet_libmd *md, lnet_handler_t handler, int cpt)
 {
 	struct lnet_res_container *container = the_lnet.ln_md_containers[cpt];
 
 	/*
 	 * NB we are passed an allocated, but inactive md.
-	 * if we return success, caller may lnet_md_unlink() it.
-	 * otherwise caller may only kfree() it.
+	 * Caller may lnet_md_unlink() it, or may lnet_md_free() it.
 	 */
 	/*
 	 * This implementation doesn't know how to create START events or
@@ -255,8 +259,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	LASSERT(list_empty(&md->md_list));
 	list_add(&md->md_list, &container->rec_active);
-
-	return 0;
 }
 
 /* must be called with lnet_res_lock held */
@@ -304,14 +306,11 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  * @handle	On successful returns, a handle to the newly created MD is
  *		saved here. This handle can be used later in LNetMDUnlink().
  *
+ * The ME will either be linked to the new MD, or it will be freed.
+ *
  * Return:	0 on success.
  *		-EINVAL If @umd is not valid.
  *		-ENOMEM If new MD cannot be allocated.
- *		-ENOENT Either @me or @umd.handle does not point to a
- *		valid object. Note that it's OK to supply a NULL @umd.handle
- *		by calling LNetInvalidateHandle() on it.
- *		-EBUSY if the ME pointed to by @me is already associated with
- *		a MD.
  */
 int
 LNetMDAttach(struct lnet_me *me, const struct lnet_md *umd,
@@ -321,33 +320,27 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	LIST_HEAD(drops);
 	struct lnet_libmd *md;
 	int cpt;
-	int rc;
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(umd))
-		return -EINVAL;
+	LASSERT(!me->me_md);
 
 	if (!(umd->options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: no MD_OP set\n");
-		return -EINVAL;
-	}
-
-	md = lnet_md_build(umd, unlink);
-	if (IS_ERR(md))
-		return PTR_ERR(md);
+		md = ERR_PTR(-EINVAL);
+	} else
+		md = lnet_md_build(umd, unlink);
 
 	cpt = me->me_cpt;
-
 	lnet_res_lock(cpt);
 
-	if (me->me_md)
-		rc = -EBUSY;
-	else
-		rc = lnet_md_link(md, umd->handler, cpt);
+	if (IS_ERR(md)) {
+		lnet_me_unlink(me);
+		lnet_res_unlock(cpt);
+		return PTR_ERR(md);
+	}
 
-	if (rc)
-		goto out_unlock;
+	lnet_md_link(md, umd->handler, cpt);
 
 	/*
 	 * attach this MD to portal of ME and check if it matches any
@@ -363,11 +356,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	lnet_recv_delayed_msg_list(&matches);
 
 	return 0;
-
-out_unlock:
-	lnet_res_unlock(cpt);
-	kfree(md);
-	return rc;
 }
 EXPORT_SYMBOL(LNetMDAttach);
 
@@ -383,9 +371,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  * Return:		0 On success.
  *			-EINVAL If @umd is not valid.
  *			-ENOMEM If new MD cannot be allocated.
- *			-ENOENT @umd.handle does not point to a valid EQ.
- *			Note that it's OK to supply a NULL @umd.handle by
- *			calling LNetInvalidateHandle() on it.
  */
 int
 LNetMDBind(const struct lnet_md *umd, enum lnet_unlink unlink,
@@ -397,9 +382,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(umd))
-		return -EINVAL;
-
 	if ((umd->options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: GET|PUT illegal on active MDs\n");
 		return -EINVAL;
@@ -418,17 +400,13 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	cpt = lnet_res_lock_current();
 
-	rc = lnet_md_link(md, umd->handler, cpt);
-	if (rc)
-		goto out_unlock;
+	lnet_md_link(md, umd->handler, cpt);
 
 	lnet_md2handle(handle, md);
 
 	lnet_res_unlock(cpt);
 	return 0;
 
-out_unlock:
-	lnet_res_unlock(cpt);
 out_free:
 	kfree(md);
 
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index 14ab21f..f75f3cb 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -118,45 +118,6 @@ struct lnet_me *
 }
 EXPORT_SYMBOL(LNetMEAttach);
 
-/**
- * Unlink a match entry from its match list.
- *
- * This operation also releases any resources associated with the ME. If a
- * memory descriptor is attached to the ME, then it will be unlinked as well
- * and an unlink event will be generated. It is an error to use the ME handle
- * after calling LNetMEUnlink().
- *
- * @me		The ME to be unlinked.
- *
- * \see LNetMDUnlink() for the discussion on delivering unlink event.
- */
-void
-LNetMEUnlink(struct lnet_me *me)
-{
-	struct lnet_libmd *md;
-	struct lnet_event ev;
-	int cpt;
-
-	LASSERT(the_lnet.ln_refcount > 0);
-
-	cpt = me->me_cpt;
-	lnet_res_lock(cpt);
-
-	md = me->me_md;
-	if (md) {
-		md->md_flags |= LNET_MD_FLAG_ABORTED;
-		if (md->md_handler && !md->md_refcount) {
-			lnet_build_unlink_event(md, &ev);
-			md->md_handler(&ev);
-		}
-	}
-
-	lnet_me_unlink(me);
-
-	lnet_res_unlock(cpt);
-}
-EXPORT_SYMBOL(LNetMEUnlink);
-
 /* call with lnet_res_lock please */
 void
 lnet_me_unlink(struct lnet_me *me)
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index 799ad99..a72e485 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -383,7 +383,6 @@ struct srpc_bulk *
 		CERROR("LNetMDAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 
-		LNetMEUnlink(me);
 		return -ENOMEM;
 	}
 
-- 
1.8.3.1
