Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76D98C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2835061222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2835061222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 18DBF21FE6B;
	Wed, 14 Apr 2021 21:03:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3D21632F632
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9A38D100F35E;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 995BB9188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:21 -0400
Message-Id: <1618459361-17909-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/49] lustre: ptlrpc: rename cfs_binheap to
 simply binheap
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

As the binheap code is no longer part of libcfs, the cfs_ prefix is
misleading.  As this code is local to one module and doesn't conflict
with anything global, there is no need for a prefix at all.  So change
cfs_binheap to binheap.

This patch was prepare using 'sed', then fixing a few text-alignment
issues caused by the loss of those 4 characters.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14289
Lustre-commit: 8587508f5ddd7b8 ("LU-14289 ptlrpc: rename cfs_binheap to simply binheap")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41375
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_nrs.h       |  6 +--
 fs/lustre/include/lustre_nrs_delay.h |  2 +-
 fs/lustre/ptlrpc/heap.c              | 98 ++++++++++++++++++------------------
 fs/lustre/ptlrpc/heap.h              | 72 +++++++++++++-------------
 fs/lustre/ptlrpc/nrs_delay.c         | 31 ++++++------
 5 files changed, 104 insertions(+), 105 deletions(-)

diff --git a/fs/lustre/include/lustre_nrs.h b/fs/lustre/include/lustre_nrs.h
index 0fc9e94..7e0a840 100644
--- a/fs/lustre/include/lustre_nrs.h
+++ b/fs/lustre/include/lustre_nrs.h
@@ -675,9 +675,9 @@ enum {
  * Binary heap node.
  *
  * Objects of this type are embedded into objects of the ordered set that is to
- * be maintained by a \e struct cfs_binheap instance.
+ * be maintained by a \e struct binheap instance.
  */
-struct cfs_binheap_node {
+struct binheap_node {
 	/** Index into the binary tree */
 	unsigned int	chn_index;
 };
@@ -707,7 +707,7 @@ struct ptlrpc_nrs_request {
 	unsigned int			nr_enqueued:1;
 	unsigned int			nr_started:1;
 	unsigned int			nr_finalized:1;
-	struct cfs_binheap_node		nr_node;
+	struct binheap_node		nr_node;
 
 	/**
 	 * Policy-specific fields, used for determining a request's scheduling
diff --git a/fs/lustre/include/lustre_nrs_delay.h b/fs/lustre/include/lustre_nrs_delay.h
index 01f0725..52c3885 100644
--- a/fs/lustre/include/lustre_nrs_delay.h
+++ b/fs/lustre/include/lustre_nrs_delay.h
@@ -48,7 +48,7 @@ struct nrs_delay_data {
 	 * Delayed requests are stored in this binheap until they are
 	 * removed for handling.
 	 */
-	struct cfs_binheap		*delay_binheap;
+	struct binheap			*delay_binheap;
 
 	/**
 	 * Minimum service time
diff --git a/fs/lustre/ptlrpc/heap.c b/fs/lustre/ptlrpc/heap.c
index 92f8a2e..0c5e29d 100644
--- a/fs/lustre/ptlrpc/heap.c
+++ b/fs/lustre/ptlrpc/heap.c
@@ -60,7 +60,7 @@
 
 /**
  * Grows the capacity of a binary heap so that it can handle a larger number of
- * \e struct cfs_binheap_node objects.
+ * \e struct binheap_node objects.
  *
  * \param[in] h The binary heap
  *
@@ -68,10 +68,10 @@
  * \retval -ENOMEM OOM error
  */
 static int
-cfs_binheap_grow(struct cfs_binheap *h)
+binheap_grow(struct binheap *h)
 {
-	struct cfs_binheap_node ***frag1 = NULL;
-	struct cfs_binheap_node  **frag2;
+	struct binheap_node ***frag1 = NULL;
+	struct binheap_node  **frag2;
 	int hwm = h->cbh_hwm;
 
 	/* need a whole new chunk of pointers */
@@ -164,12 +164,12 @@
  * \retval valid-pointer A newly-created and initialized binary heap object
  * \retval NULL		 error
  */
-struct cfs_binheap *
-cfs_binheap_create(struct cfs_binheap_ops *ops, unsigned int flags,
+struct binheap *
+binheap_create(struct binheap_ops *ops, unsigned int flags,
 		   unsigned int count, void *arg, struct cfs_cpt_table *cptab,
 		   int cptid)
 {
-	struct cfs_binheap *h;
+	struct binheap *h;
 
 	LASSERT(ops);
 	LASSERT(ops->hop_compare);
@@ -194,8 +194,8 @@ struct cfs_binheap *
 	h->cbh_cptid	  = cptid;
 
 	while (h->cbh_hwm < count) { /* preallocate */
-		if (cfs_binheap_grow(h) != 0) {
-			cfs_binheap_destroy(h);
+		if (binheap_grow(h) != 0) {
+			binheap_destroy(h);
 			return NULL;
 		}
 	}
@@ -204,7 +204,7 @@ struct cfs_binheap *
 
 	return h;
 }
-EXPORT_SYMBOL(cfs_binheap_create);
+EXPORT_SYMBOL(binheap_create);
 
 /**
  * Releases all resources associated with a binary heap instance.
@@ -215,7 +215,7 @@ struct cfs_binheap *
  * \param[in] h The binary heap object
  */
 void
-cfs_binheap_destroy(struct cfs_binheap *h)
+binheap_destroy(struct binheap *h)
 {
 	int idx0;
 	int idx1;
@@ -255,7 +255,7 @@ struct cfs_binheap *
 
 	kfree(h);
 }
-EXPORT_SYMBOL(cfs_binheap_destroy);
+EXPORT_SYMBOL(binheap_destroy);
 
 /**
  * Obtains a double pointer to a heap element, given its index into the binary
@@ -266,8 +266,8 @@ struct cfs_binheap *
  *
  * \retval valid-pointer A double pointer to a heap pointer entry
  */
-static struct cfs_binheap_node **
-cfs_binheap_pointer(struct cfs_binheap *h, unsigned int idx)
+static struct binheap_node **
+binheap_pointer(struct binheap *h, unsigned int idx)
 {
 	if (idx < CBH_SIZE)
 		return &(h->cbh_elements1[idx]);
@@ -291,15 +291,15 @@ struct cfs_binheap *
  * \retval valid-pointer The requested heap node
  * \retval NULL		 Supplied index is out of bounds
  */
-struct cfs_binheap_node *
-cfs_binheap_find(struct cfs_binheap *h, unsigned int idx)
+struct binheap_node *
+binheap_find(struct binheap *h, unsigned int idx)
 {
 	if (idx >= h->cbh_nelements)
 		return NULL;
 
-	return *cfs_binheap_pointer(h, idx);
+	return *binheap_pointer(h, idx);
 }
-EXPORT_SYMBOL(cfs_binheap_find);
+EXPORT_SYMBOL(binheap_find);
 
 /**
  * Moves a node upwards, towards the root of the binary tree.
@@ -311,21 +311,21 @@ struct cfs_binheap_node *
  * \retval 0 The position of \a e in the tree was not changed
  */
 static int
-cfs_binheap_bubble(struct cfs_binheap *h, struct cfs_binheap_node *e)
+binheap_bubble(struct binheap *h, struct binheap_node *e)
 {
 	unsigned int	     cur_idx = e->chn_index;
-	struct cfs_binheap_node **cur_ptr;
+	struct binheap_node **cur_ptr;
 	unsigned int	     parent_idx;
-	struct cfs_binheap_node **parent_ptr;
+	struct binheap_node **parent_ptr;
 	int		     did_sth = 0;
 
-	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	cur_ptr = binheap_pointer(h, cur_idx);
 	LASSERT(*cur_ptr == e);
 
 	while (cur_idx > 0) {
 		parent_idx = (cur_idx - 1) >> 1;
 
-		parent_ptr = cfs_binheap_pointer(h, parent_idx);
+		parent_ptr = binheap_pointer(h, parent_idx);
 		LASSERT((*parent_ptr)->chn_index == parent_idx);
 
 		if (h->cbh_ops->hop_compare(*parent_ptr, e))
@@ -354,21 +354,21 @@ struct cfs_binheap_node *
  * \retval 0 The position of \a e in the tree was not changed
  */
 static int
-cfs_binheap_sink(struct cfs_binheap *h, struct cfs_binheap_node *e)
+binheap_sink(struct binheap *h, struct binheap_node *e)
 {
 	unsigned int	     n = h->cbh_nelements;
 	unsigned int	     child_idx;
-	struct cfs_binheap_node **child_ptr;
-	struct cfs_binheap_node  *child;
+	struct binheap_node **child_ptr;
+	struct binheap_node  *child;
 	unsigned int	     child2_idx;
-	struct cfs_binheap_node **child2_ptr;
-	struct cfs_binheap_node  *child2;
+	struct binheap_node **child2_ptr;
+	struct binheap_node  *child2;
 	unsigned int	     cur_idx;
-	struct cfs_binheap_node **cur_ptr;
+	struct binheap_node **cur_ptr;
 	int		     did_sth = 0;
 
 	cur_idx = e->chn_index;
-	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	cur_ptr = binheap_pointer(h, cur_idx);
 	LASSERT(*cur_ptr == e);
 
 	while (cur_idx < n) {
@@ -376,12 +376,12 @@ struct cfs_binheap_node *
 		if (child_idx >= n)
 			break;
 
-		child_ptr = cfs_binheap_pointer(h, child_idx);
+		child_ptr = binheap_pointer(h, child_idx);
 		child = *child_ptr;
 
 		child2_idx = child_idx + 1;
 		if (child2_idx < n) {
-			child2_ptr = cfs_binheap_pointer(h, child2_idx);
+			child2_ptr = binheap_pointer(h, child2_idx);
 			child2 = *child2_ptr;
 
 			if (h->cbh_ops->hop_compare(child2, child)) {
@@ -419,14 +419,14 @@ struct cfs_binheap_node *
  * \retval != 0 error
  */
 int
-cfs_binheap_insert(struct cfs_binheap *h, struct cfs_binheap_node *e)
+binheap_insert(struct binheap *h, struct binheap_node *e)
 {
-	struct cfs_binheap_node **new_ptr;
+	struct binheap_node **new_ptr;
 	unsigned int	     new_idx = h->cbh_nelements;
 	int		     rc;
 
 	if (new_idx == h->cbh_hwm) {
-		rc = cfs_binheap_grow(h);
+		rc = binheap_grow(h);
 		if (rc != 0)
 			return rc;
 	}
@@ -438,15 +438,15 @@ struct cfs_binheap_node *
 	}
 
 	e->chn_index = new_idx;
-	new_ptr = cfs_binheap_pointer(h, new_idx);
+	new_ptr = binheap_pointer(h, new_idx);
 	h->cbh_nelements++;
 	*new_ptr = e;
 
-	cfs_binheap_bubble(h, e);
+	binheap_bubble(h, e);
 
 	return 0;
 }
-EXPORT_SYMBOL(cfs_binheap_insert);
+EXPORT_SYMBOL(binheap_insert);
 
 /**
  * Removes a node from the binary heap.
@@ -455,34 +455,34 @@ struct cfs_binheap_node *
  * \param[in] e The node
  */
 void
-cfs_binheap_remove(struct cfs_binheap *h, struct cfs_binheap_node *e)
+binheap_remove(struct binheap *h, struct binheap_node *e)
 {
 	unsigned int	     n = h->cbh_nelements;
 	unsigned int	     cur_idx = e->chn_index;
-	struct cfs_binheap_node **cur_ptr;
-	struct cfs_binheap_node  *last;
+	struct binheap_node **cur_ptr;
+	struct binheap_node  *last;
 
 	LASSERT(cur_idx != CBH_POISON);
 	LASSERT(cur_idx < n);
 
-	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	cur_ptr = binheap_pointer(h, cur_idx);
 	LASSERT(*cur_ptr == e);
 
 	n--;
-	last = *cfs_binheap_pointer(h, n);
+	last = *binheap_pointer(h, n);
 	h->cbh_nelements = n;
 	if (last == e)
 		return;
 
 	last->chn_index = cur_idx;
 	*cur_ptr = last;
-	cfs_binheap_relocate(h, *cur_ptr);
+	binheap_relocate(h, *cur_ptr);
 
 	e->chn_index = CBH_POISON;
 	if (h->cbh_ops->hop_exit)
 		h->cbh_ops->hop_exit(h, e);
 }
-EXPORT_SYMBOL(cfs_binheap_remove);
+EXPORT_SYMBOL(binheap_remove);
 
 /**
  * Relocate a node in the binary heap.
@@ -493,10 +493,10 @@ struct cfs_binheap_node *
  * \param[in] e The node
  */
 void
-cfs_binheap_relocate(struct cfs_binheap *h, struct cfs_binheap_node *e)
+binheap_relocate(struct binheap *h, struct binheap_node *e)
 {
-	if (!cfs_binheap_bubble(h, e))
-		cfs_binheap_sink(h, e);
+	if (!binheap_bubble(h, e))
+		binheap_sink(h, e);
 }
-EXPORT_SYMBOL(cfs_binheap_relocate);
+EXPORT_SYMBOL(binheap_relocate);
 /** @} heap */
diff --git a/fs/lustre/ptlrpc/heap.h b/fs/lustre/ptlrpc/heap.h
index 3972917..bc8fb19 100644
--- a/fs/lustre/ptlrpc/heap.h
+++ b/fs/lustre/ptlrpc/heap.h
@@ -40,9 +40,9 @@
  * the tree (as this is an implementation of a min-heap) to be removed by users
  * for consumption.
  *
- * Users of the heap should embed a \e struct cfs_binheap_node object instance
+ * Users of the heap should embed a \e struct binheap_node object instance
  * on every object of the set that they wish the binary heap instance to handle,
- * and (at a minimum) provide a struct cfs_binheap_ops::hop_compare()
+ * and (at a minimum) provide a struct binheap_ops::hop_compare()
  * implementation which is used by the heap as the binary predicate during its
  * internal sorting operations.
  *
@@ -57,7 +57,7 @@
 #define CBH_SHIFT	9
 #define CBH_SIZE	(1 << CBH_SHIFT)		/* # ptrs per level */
 #define CBH_MASK	(CBH_SIZE - 1)
-#define CBH_NOB		(CBH_SIZE * sizeof(struct cfs_binheap_node *))
+#define CBH_NOB		(CBH_SIZE * sizeof(struct binheap_node *))
 
 #define CBH_POISON	0xdeadbeef
 
@@ -68,12 +68,12 @@ enum {
 	CBH_FLAG_ATOMIC_GROW	= 1,
 };
 
-struct cfs_binheap;
+struct binheap;
 
 /**
  * Binary heap operations.
  */
-struct cfs_binheap_ops {
+struct binheap_ops {
 	/**
 	 * Called right before inserting a node into the binary heap.
 	 *
@@ -85,8 +85,8 @@ struct cfs_binheap_ops {
 	 * \retval 0 success
 	 * \retval != 0 error
 	 */
-	int		(*hop_enter)(struct cfs_binheap *h,
-				     struct cfs_binheap_node *e);
+	int		(*hop_enter)(struct binheap *h,
+				     struct binheap_node *e);
 	/**
 	 * Called right after removing a node from the binary heap.
 	 *
@@ -95,8 +95,8 @@ struct cfs_binheap_ops {
 	 * \param[in] h The heap
 	 * \param[in] e The node
 	 */
-	void		(*hop_exit)(struct cfs_binheap *h,
-				    struct cfs_binheap_node *e);
+	void		(*hop_exit)(struct binheap *h,
+				    struct binheap_node *e);
 	/**
 	 * A binary predicate which is called during internal heap sorting
 	 * operations, and used in order to determine the relevant ordering of
@@ -110,25 +110,25 @@ struct cfs_binheap_ops {
 	 * \retval 0 Node a > node b
 	 * \retval 1 Node a < node b
 	 *
-	 * \see cfs_binheap_bubble()
+	 * \see binheap_bubble()
 	 * \see cfs_biheap_sink()
 	 */
-	int		(*hop_compare)(struct cfs_binheap_node *a,
-				       struct cfs_binheap_node *b);
+	int		(*hop_compare)(struct binheap_node *a,
+				       struct binheap_node *b);
 };
 
 /**
  * Binary heap object.
  *
- * Sorts elements of type \e struct cfs_binheap_node
+ * Sorts elements of type \e struct binheap_node
  */
-struct cfs_binheap {
+struct binheap {
 	/** Triple indirect */
-	struct cfs_binheap_node  ****cbh_elements3;
+	struct binheap_node  ****cbh_elements3;
 	/** double indirect */
-	struct cfs_binheap_node   ***cbh_elements2;
+	struct binheap_node   ***cbh_elements2;
 	/** single indirect */
-	struct cfs_binheap_node    **cbh_elements1;
+	struct binheap_node    **cbh_elements1;
 	/** # elements referenced */
 	unsigned int		cbh_nelements;
 	/** high water mark */
@@ -136,51 +136,51 @@ struct cfs_binheap {
 	/** user flags */
 	unsigned int		cbh_flags;
 	/** operations table */
-	struct cfs_binheap_ops *cbh_ops;
+	struct binheap_ops *cbh_ops;
 	/** private data */
 	void		       *cbh_private;
 	/** associated CPT table */
 	struct cfs_cpt_table   *cbh_cptab;
-	/** associated CPT id of this struct cfs_binheap::cbh_cptab */
+	/** associated CPT id of this struct binheap::cbh_cptab */
 	int			cbh_cptid;
 };
 
-void cfs_binheap_destroy(struct cfs_binheap *h);
-struct cfs_binheap *
-cfs_binheap_create(struct cfs_binheap_ops *ops, unsigned int flags,
+void binheap_destroy(struct binheap *h);
+struct binheap *
+binheap_create(struct binheap_ops *ops, unsigned int flags,
 		   unsigned int count, void *arg, struct cfs_cpt_table *cptab,
 		   int cptid);
-struct cfs_binheap_node *
-cfs_binheap_find(struct cfs_binheap *h, unsigned int idx);
-int cfs_binheap_insert(struct cfs_binheap *h, struct cfs_binheap_node *e);
-void cfs_binheap_remove(struct cfs_binheap *h, struct cfs_binheap_node *e);
-void cfs_binheap_relocate(struct cfs_binheap *h, struct cfs_binheap_node *e);
+struct binheap_node *
+binheap_find(struct binheap *h, unsigned int idx);
+int binheap_insert(struct binheap *h, struct binheap_node *e);
+void binheap_remove(struct binheap *h, struct binheap_node *e);
+void binheap_relocate(struct binheap *h, struct binheap_node *e);
 
 static inline int
-cfs_binheap_size(struct cfs_binheap *h)
+binheap_size(struct binheap *h)
 {
 	return h->cbh_nelements;
 }
 
 static inline int
-cfs_binheap_is_empty(struct cfs_binheap *h)
+binheap_is_empty(struct binheap *h)
 {
 	return h->cbh_nelements == 0;
 }
 
-static inline struct cfs_binheap_node *
-cfs_binheap_root(struct cfs_binheap *h)
+static inline struct binheap_node *
+binheap_root(struct binheap *h)
 {
-	return cfs_binheap_find(h, 0);
+	return binheap_find(h, 0);
 }
 
-static inline struct cfs_binheap_node *
-cfs_binheap_remove_root(struct cfs_binheap *h)
+static inline struct binheap_node *
+binheap_remove_root(struct binheap *h)
 {
-	struct cfs_binheap_node *e = cfs_binheap_find(h, 0);
+	struct binheap_node *e = binheap_find(h, 0);
 
 	if (e != NULL)
-		cfs_binheap_remove(h, e);
+		binheap_remove(h, e);
 	return e;
 }
 
diff --git a/fs/lustre/ptlrpc/nrs_delay.c b/fs/lustre/ptlrpc/nrs_delay.c
index 8ff8e8d..5b4c2a9 100644
--- a/fs/lustre/ptlrpc/nrs_delay.c
+++ b/fs/lustre/ptlrpc/nrs_delay.c
@@ -77,8 +77,8 @@
  * \retval 0 start_time(e1) > start_time(e2)
  * \retval 1 start_time(e1) <= start_time(e2)
  */
-static int delay_req_compare(struct cfs_binheap_node *e1,
-			     struct cfs_binheap_node *e2)
+static int delay_req_compare(struct binheap_node *e1,
+			     struct binheap_node *e2)
 {
 	struct ptlrpc_nrs_request *nrq1;
 	struct ptlrpc_nrs_request *nrq2;
@@ -90,7 +90,7 @@ static int delay_req_compare(struct cfs_binheap_node *e1,
 	       nrq2->nr_u.delay.req_start_time;
 }
 
-static struct cfs_binheap_ops nrs_delay_heap_ops = {
+static struct binheap_ops nrs_delay_heap_ops = {
 	.hop_enter	= NULL,
 	.hop_exit	= NULL,
 	.hop_compare	= delay_req_compare,
@@ -119,12 +119,11 @@ static int nrs_delay_start(struct ptlrpc_nrs_policy *policy)
 	if (!delay_data)
 		return -ENOMEM;
 
-	delay_data->delay_binheap = cfs_binheap_create(&nrs_delay_heap_ops,
-						       CBH_FLAG_ATOMIC_GROW,
-						       4096, NULL,
-						       nrs_pol2cptab(policy),
-						       nrs_pol2cptid(policy));
-
+	delay_data->delay_binheap = binheap_create(&nrs_delay_heap_ops,
+						   CBH_FLAG_ATOMIC_GROW,
+						   4096, NULL,
+						   nrs_pol2cptab(policy),
+						   nrs_pol2cptid(policy));
 	if (!delay_data->delay_binheap) {
 		kfree(delay_data);
 		return -ENOMEM;
@@ -154,9 +153,9 @@ static void nrs_delay_stop(struct ptlrpc_nrs_policy *policy)
 
 	LASSERT(delay_data);
 	LASSERT(delay_data->delay_binheap);
-	LASSERT(cfs_binheap_is_empty(delay_data->delay_binheap));
+	LASSERT(binheap_is_empty(delay_data->delay_binheap));
 
-	cfs_binheap_destroy(delay_data->delay_binheap);
+	binheap_destroy(delay_data->delay_binheap);
 
 	kfree(delay_data);
 }
@@ -212,10 +211,10 @@ struct ptlrpc_nrs_request *nrs_delay_req_get(struct ptlrpc_nrs_policy *policy,
 					     bool peek, bool force)
 {
 	struct nrs_delay_data *delay_data = policy->pol_private;
-	struct cfs_binheap_node *node;
+	struct binheap_node *node;
 	struct ptlrpc_nrs_request *nrq;
 
-	node = cfs_binheap_root(delay_data->delay_binheap);
+	node = binheap_root(delay_data->delay_binheap);
 	nrq = unlikely(!node) ? NULL :
 	      container_of(node, struct ptlrpc_nrs_request, nr_node);
 
@@ -224,7 +223,7 @@ struct ptlrpc_nrs_request *nrs_delay_req_get(struct ptlrpc_nrs_policy *policy,
 		    ktime_get_real_seconds() < nrq->nr_u.delay.req_start_time)
 			nrq = NULL;
 		else if (likely(!peek))
-			cfs_binheap_remove(delay_data->delay_binheap,
+			binheap_remove(delay_data->delay_binheap,
 					   &nrq->nr_node);
 	}
 
@@ -262,7 +261,7 @@ static int nrs_delay_req_add(struct ptlrpc_nrs_policy *policy,
 					 prandom_u32_max(delay_data->max_delay - delay_data->min_delay + 1) +
 					 delay_data->min_delay;
 
-	return cfs_binheap_insert(delay_data->delay_binheap, &nrq->nr_node);
+	return binheap_insert(delay_data->delay_binheap, &nrq->nr_node);
 }
 
 /**
@@ -276,7 +275,7 @@ static void nrs_delay_req_del(struct ptlrpc_nrs_policy *policy,
 {
 	struct nrs_delay_data *delay_data = policy->pol_private;
 
-	cfs_binheap_remove(delay_data->delay_binheap, &nrq->nr_node);
+	binheap_remove(delay_data->delay_binheap, &nrq->nr_node);
 }
 
 /**
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
