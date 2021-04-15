Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F795C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 202D661249
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202D661249
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5BC7B32CC08;
	Wed, 14 Apr 2021 21:03:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9BA8632F607
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 955BE100F35C;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 92CC49188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:19 -0400
Message-Id: <1618459361-17909-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/49] lustre: ptlrpc: Add a binary heap
 implementation
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
Cc: Nikitas Angelinas <nikitas_angelinas@xyratex.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Nikitas Angelinas <nikitas_angelinas@xyratex.com>

The heap can be used to build and maintain sorted arrays and lists,
and prioritized queues of large numbers of elements, with minimal
insertion and removal time. The first user for the data structure are
NRS policies, which use it to maintain prioritized queues of RPCs at
PTLRPC services.

There is no 'search' operation, but the data type aims to be useful
in cases where performing searches on the data set is not required,
and instead the lowest priority element is usually removed from the
data set for consumption.

WC-bug-id: https://jira.whamcloud.com/browse/LU-398
Lustre-commit: 2070cf5996a140 ("LU-398 libcfs: Add libcfs heap, a binary heap implementation")
Original-author: Eric Barton <eeb@whamcloud.com>
Original-author: Liang Zhen <liang@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: Nikitas Angelinas <nikitas_angelinas@xyratex.com>
Oracle-bug-id: b=13634
Xyratex-bug-id: MRP-73
Reviewed-on: http://review.whamcloud.com/4412
Reviewed-by: Liang Zhen <liang@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_nrs.h     |  10 +
 fs/lustre/ptlrpc/Makefile          |   3 +-
 fs/lustre/ptlrpc/heap.c            | 502 +++++++++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/heap.h            | 189 ++++++++++++++
 fs/lustre/ptlrpc/ptlrpc_internal.h |   1 +
 5 files changed, 704 insertions(+), 1 deletion(-)
 create mode 100644 fs/lustre/ptlrpc/heap.c
 create mode 100644 fs/lustre/ptlrpc/heap.h

diff --git a/fs/lustre/include/lustre_nrs.h b/fs/lustre/include/lustre_nrs.h
index f57756a..f15fb03 100644
--- a/fs/lustre/include/lustre_nrs.h
+++ b/fs/lustre/include/lustre_nrs.h
@@ -671,6 +671,16 @@ enum {
 };
 
 #include <lustre_nrs_fifo.h>
+/**
+ * Binary heap node.
+ *
+ * Objects of this type are embedded into objects of the ordered set that is to
+ * be maintained by a \e struct cfs_binheap instance.
+ */
+struct cfs_binheap_node {
+	/** Index into the binary tree */
+	unsigned int	chn_index;
+};
 
 /**
  * NRS request
diff --git a/fs/lustre/ptlrpc/Makefile b/fs/lustre/ptlrpc/Makefile
index b989146..adffb231 100644
--- a/fs/lustre/ptlrpc/Makefile
+++ b/fs/lustre/ptlrpc/Makefile
@@ -15,7 +15,8 @@ ptlrpc_objs += events.o ptlrpc_module.o service.o pinger.o
 ptlrpc_objs += llog_net.o llog_client.o import.o ptlrpcd.o
 ptlrpc_objs += pers.o lproc_ptlrpc.o wiretest.o layout.o
 ptlrpc_objs += sec.o sec_bulk.o sec_gc.o sec_config.o
-ptlrpc_objs += sec_null.o sec_plain.o nrs.o nrs_fifo.o
+ptlrpc_objs += sec_null.o sec_plain.o
+ptlrpc_objs += heap.o nrs.o nrs_fifo.o
 
 ptlrpc-y := $(ldlm_objs) $(ptlrpc_objs) sec_lproc.o
 ptlrpc-$(CONFIG_LUSTRE_TRANSLATE_ERRNOS) += errno.o
diff --git a/fs/lustre/ptlrpc/heap.c b/fs/lustre/ptlrpc/heap.c
new file mode 100644
index 0000000..92f8a2e
--- /dev/null
+++ b/fs/lustre/ptlrpc/heap.c
@@ -0,0 +1,502 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2 for more details.  A copy is
+ * included in the COPYING file that accompanied this code.
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2011 Intel Corporation
+ */
+/*
+ * fs/lustre/ptlrpc/heap.c
+ *
+ * Author: Eric Barton	<eeb@whamcloud.com>
+ *	   Liang Zhen	<liang@whamcloud.com>
+ */
+/** \addtogroup heap
+ *
+ * @{
+ */
+
+#define DEBUG_SUBSYSTEM S_RPC
+
+#include <linux/libcfs/libcfs_cpu.h>
+#include <lustre_net.h>
+#include "heap.h"
+
+#define CBH_ALLOC(ptr, h)						      \
+do {									      \
+	if (h->cbh_cptab) {						      \
+		if ((h)->cbh_flags & CBH_FLAG_ATOMIC_GROW) {		      \
+			ptr = kzalloc_node(CBH_NOB, GFP_ATOMIC,		      \
+					   cfs_cpt_spread_node(h->cbh_cptab,  \
+							       h->cbh_cptid));\
+		} else {						      \
+			ptr = kzalloc_node(CBH_NOB, GFP_KERNEL,		      \
+					   cfs_cpt_spread_node(h->cbh_cptab,  \
+							       h->cbh_cptid));\
+		}							      \
+	} else {							      \
+		if ((h)->cbh_flags & CBH_FLAG_ATOMIC_GROW)		      \
+			ptr = kzalloc(CBH_NOB, GFP_ATOMIC);		      \
+		else							      \
+			ptr = kzalloc(CBH_NOB, GFP_KERNEL);		      \
+	}								      \
+} while (0)
+
+#define CBH_FREE(ptr)	kfree(ptr)
+
+/**
+ * Grows the capacity of a binary heap so that it can handle a larger number of
+ * \e struct cfs_binheap_node objects.
+ *
+ * \param[in] h The binary heap
+ *
+ * \retval 0	   Successfully grew the heap
+ * \retval -ENOMEM OOM error
+ */
+static int
+cfs_binheap_grow(struct cfs_binheap *h)
+{
+	struct cfs_binheap_node ***frag1 = NULL;
+	struct cfs_binheap_node  **frag2;
+	int hwm = h->cbh_hwm;
+
+	/* need a whole new chunk of pointers */
+	LASSERT((h->cbh_hwm & CBH_MASK) == 0);
+
+	if (hwm == 0) {
+		/* first use of single indirect */
+		CBH_ALLOC(h->cbh_elements1, h);
+		if (!h->cbh_elements1)
+			return -ENOMEM;
+
+		goto out;
+	}
+
+	hwm -= CBH_SIZE;
+	if (hwm < CBH_SIZE * CBH_SIZE) {
+		/* not filled double indirect */
+		CBH_ALLOC(frag2, h);
+		if (!frag2)
+			return -ENOMEM;
+
+		if (hwm == 0) {
+			/* first use of double indirect */
+			CBH_ALLOC(h->cbh_elements2, h);
+			if (!h->cbh_elements2) {
+				CBH_FREE(frag2);
+				return -ENOMEM;
+			}
+		}
+
+		h->cbh_elements2[hwm >> CBH_SHIFT] = frag2;
+		goto out;
+	}
+
+	hwm -= CBH_SIZE * CBH_SIZE;
+#if (CBH_SHIFT * 3 < 32)
+	if (hwm >= CBH_SIZE * CBH_SIZE * CBH_SIZE) {
+		/* filled triple indirect */
+		return -ENOMEM;
+	}
+#endif
+	CBH_ALLOC(frag2, h);
+	if (!frag2)
+		return -ENOMEM;
+
+	if (((hwm >> CBH_SHIFT) & CBH_MASK) == 0) {
+		/* first use of this 2nd level index */
+		CBH_ALLOC(frag1, h);
+		if (!frag1) {
+			CBH_FREE(frag2);
+			return -ENOMEM;
+		}
+	}
+
+	if (hwm == 0) {
+		/* first use of triple indirect */
+		CBH_ALLOC(h->cbh_elements3, h);
+		if (!h->cbh_elements3) {
+			CBH_FREE(frag2);
+			CBH_FREE(frag1);
+			return -ENOMEM;
+		}
+	}
+
+	if (frag1) {
+		LASSERT(!h->cbh_elements3[hwm >> (2 * CBH_SHIFT)]);
+		h->cbh_elements3[hwm >> (2 * CBH_SHIFT)] = frag1;
+	} else {
+		frag1 = h->cbh_elements3[hwm >> (2 * CBH_SHIFT)];
+		LASSERT(frag1);
+	}
+
+	frag1[(hwm >> CBH_SHIFT) & CBH_MASK] = frag2;
+
+ out:
+	h->cbh_hwm += CBH_SIZE;
+	return 0;
+}
+
+/**
+ * Creates and initializes a binary heap instance.
+ *
+ * \param[in] ops   The operations to be used
+ * \param[in] flags The heap flags
+ * \parm[in]  count The initial heap capacity in # of elements
+ * \param[in] arg   An optional private argument
+ * \param[in] cptab The CPT table this heap instance will operate over
+ * \param[in] cptid The CPT id of \a cptab this heap instance will operate over
+ *
+ * \retval valid-pointer A newly-created and initialized binary heap object
+ * \retval NULL		 error
+ */
+struct cfs_binheap *
+cfs_binheap_create(struct cfs_binheap_ops *ops, unsigned int flags,
+		   unsigned int count, void *arg, struct cfs_cpt_table *cptab,
+		   int cptid)
+{
+	struct cfs_binheap *h;
+
+	LASSERT(ops);
+	LASSERT(ops->hop_compare);
+	if (cptab) {
+		LASSERT(cptid == CFS_CPT_ANY ||
+		       (cptid >= 0 && cptid < cfs_cpt_number(cptab)));
+
+		h = kzalloc_node(sizeof(*h), GFP_KERNEL,
+				 cfs_cpt_spread_node(cptab, cptid));
+	} else {
+		h = kzalloc(sizeof(*h), GFP_KERNEL);
+	}
+	if (!h)
+		return NULL;
+
+	h->cbh_ops	  = ops;
+	h->cbh_nelements  = 0;
+	h->cbh_hwm	  = 0;
+	h->cbh_private	  = arg;
+	h->cbh_flags	  = flags & (~CBH_FLAG_ATOMIC_GROW);
+	h->cbh_cptab	  = cptab;
+	h->cbh_cptid	  = cptid;
+
+	while (h->cbh_hwm < count) { /* preallocate */
+		if (cfs_binheap_grow(h) != 0) {
+			cfs_binheap_destroy(h);
+			return NULL;
+		}
+	}
+
+	h->cbh_flags |= flags & CBH_FLAG_ATOMIC_GROW;
+
+	return h;
+}
+EXPORT_SYMBOL(cfs_binheap_create);
+
+/**
+ * Releases all resources associated with a binary heap instance.
+ *
+ * Deallocates memory for all indirection levels and the binary heap object
+ * itself.
+ *
+ * \param[in] h The binary heap object
+ */
+void
+cfs_binheap_destroy(struct cfs_binheap *h)
+{
+	int idx0;
+	int idx1;
+	int n;
+
+	LASSERT(h);
+
+	n = h->cbh_hwm;
+
+	if (n > 0) {
+		CBH_FREE(h->cbh_elements1);
+		n -= CBH_SIZE;
+	}
+
+	if (n > 0) {
+		for (idx0 = 0; idx0 < CBH_SIZE && n > 0; idx0++) {
+			CBH_FREE(h->cbh_elements2[idx0]);
+			n -= CBH_SIZE;
+		}
+
+		CBH_FREE(h->cbh_elements2);
+	}
+
+	if (n > 0) {
+		for (idx0 = 0; idx0 < CBH_SIZE && n > 0; idx0++) {
+
+			for (idx1 = 0; idx1 < CBH_SIZE && n > 0; idx1++) {
+				CBH_FREE(h->cbh_elements3[idx0][idx1]);
+				n -= CBH_SIZE;
+			}
+
+			CBH_FREE(h->cbh_elements3[idx0]);
+		}
+
+		CBH_FREE(h->cbh_elements3);
+	}
+
+	kfree(h);
+}
+EXPORT_SYMBOL(cfs_binheap_destroy);
+
+/**
+ * Obtains a double pointer to a heap element, given its index into the binary
+ * tree.
+ *
+ * \param[in] h	  The binary heap instance
+ * \param[in] idx The requested node's index
+ *
+ * \retval valid-pointer A double pointer to a heap pointer entry
+ */
+static struct cfs_binheap_node **
+cfs_binheap_pointer(struct cfs_binheap *h, unsigned int idx)
+{
+	if (idx < CBH_SIZE)
+		return &(h->cbh_elements1[idx]);
+
+	idx -= CBH_SIZE;
+	if (idx < CBH_SIZE * CBH_SIZE)
+		return &(h->cbh_elements2[idx >> CBH_SHIFT][idx & CBH_MASK]);
+
+	idx -= CBH_SIZE * CBH_SIZE;
+	return &(h->cbh_elements3[idx >> (2 * CBH_SHIFT)]
+				 [(idx >> CBH_SHIFT) & CBH_MASK]
+				 [idx & CBH_MASK]);
+}
+
+/**
+ * Obtains a pointer to a heap element, given its index into the binary tree.
+ *
+ * \param[in] h	  The binary heap
+ * \param[in] idx The requested node's index
+ *
+ * \retval valid-pointer The requested heap node
+ * \retval NULL		 Supplied index is out of bounds
+ */
+struct cfs_binheap_node *
+cfs_binheap_find(struct cfs_binheap *h, unsigned int idx)
+{
+	if (idx >= h->cbh_nelements)
+		return NULL;
+
+	return *cfs_binheap_pointer(h, idx);
+}
+EXPORT_SYMBOL(cfs_binheap_find);
+
+/**
+ * Moves a node upwards, towards the root of the binary tree.
+ *
+ * \param[in] h The heap
+ * \param[in] e The node
+ *
+ * \retval 1 The position of \a e in the tree was changed at least once
+ * \retval 0 The position of \a e in the tree was not changed
+ */
+static int
+cfs_binheap_bubble(struct cfs_binheap *h, struct cfs_binheap_node *e)
+{
+	unsigned int	     cur_idx = e->chn_index;
+	struct cfs_binheap_node **cur_ptr;
+	unsigned int	     parent_idx;
+	struct cfs_binheap_node **parent_ptr;
+	int		     did_sth = 0;
+
+	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	LASSERT(*cur_ptr == e);
+
+	while (cur_idx > 0) {
+		parent_idx = (cur_idx - 1) >> 1;
+
+		parent_ptr = cfs_binheap_pointer(h, parent_idx);
+		LASSERT((*parent_ptr)->chn_index == parent_idx);
+
+		if (h->cbh_ops->hop_compare(*parent_ptr, e))
+			break;
+
+		(*parent_ptr)->chn_index = cur_idx;
+		*cur_ptr = *parent_ptr;
+		cur_ptr = parent_ptr;
+		cur_idx = parent_idx;
+		did_sth = 1;
+	}
+
+	e->chn_index = cur_idx;
+	*cur_ptr = e;
+
+	return did_sth;
+}
+
+/**
+ * Moves a node downwards, towards the last level of the binary tree.
+ *
+ * \param[in] h The heap
+ * \param[in] e The node
+ *
+ * \retval 1 The position of \a e in the tree was changed at least once
+ * \retval 0 The position of \a e in the tree was not changed
+ */
+static int
+cfs_binheap_sink(struct cfs_binheap *h, struct cfs_binheap_node *e)
+{
+	unsigned int	     n = h->cbh_nelements;
+	unsigned int	     child_idx;
+	struct cfs_binheap_node **child_ptr;
+	struct cfs_binheap_node  *child;
+	unsigned int	     child2_idx;
+	struct cfs_binheap_node **child2_ptr;
+	struct cfs_binheap_node  *child2;
+	unsigned int	     cur_idx;
+	struct cfs_binheap_node **cur_ptr;
+	int		     did_sth = 0;
+
+	cur_idx = e->chn_index;
+	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	LASSERT(*cur_ptr == e);
+
+	while (cur_idx < n) {
+		child_idx = (cur_idx << 1) + 1;
+		if (child_idx >= n)
+			break;
+
+		child_ptr = cfs_binheap_pointer(h, child_idx);
+		child = *child_ptr;
+
+		child2_idx = child_idx + 1;
+		if (child2_idx < n) {
+			child2_ptr = cfs_binheap_pointer(h, child2_idx);
+			child2 = *child2_ptr;
+
+			if (h->cbh_ops->hop_compare(child2, child)) {
+				child_idx = child2_idx;
+				child_ptr = child2_ptr;
+				child = child2;
+			}
+		}
+
+		LASSERT(child->chn_index == child_idx);
+
+		if (h->cbh_ops->hop_compare(e, child))
+			break;
+
+		child->chn_index = cur_idx;
+		*cur_ptr = child;
+		cur_ptr = child_ptr;
+		cur_idx = child_idx;
+		did_sth = 1;
+	}
+
+	e->chn_index = cur_idx;
+	*cur_ptr = e;
+
+	return did_sth;
+}
+
+/**
+ * Sort-inserts a node into the binary heap.
+ *
+ * \param[in] h The heap
+ * \param[in] e The node
+ *
+ * \retval 0	Element inserted successfully
+ * \retval != 0 error
+ */
+int
+cfs_binheap_insert(struct cfs_binheap *h, struct cfs_binheap_node *e)
+{
+	struct cfs_binheap_node **new_ptr;
+	unsigned int	     new_idx = h->cbh_nelements;
+	int		     rc;
+
+	if (new_idx == h->cbh_hwm) {
+		rc = cfs_binheap_grow(h);
+		if (rc != 0)
+			return rc;
+	}
+
+	if (h->cbh_ops->hop_enter) {
+		rc = h->cbh_ops->hop_enter(h, e);
+		if (rc != 0)
+			return rc;
+	}
+
+	e->chn_index = new_idx;
+	new_ptr = cfs_binheap_pointer(h, new_idx);
+	h->cbh_nelements++;
+	*new_ptr = e;
+
+	cfs_binheap_bubble(h, e);
+
+	return 0;
+}
+EXPORT_SYMBOL(cfs_binheap_insert);
+
+/**
+ * Removes a node from the binary heap.
+ *
+ * \param[in] h The heap
+ * \param[in] e The node
+ */
+void
+cfs_binheap_remove(struct cfs_binheap *h, struct cfs_binheap_node *e)
+{
+	unsigned int	     n = h->cbh_nelements;
+	unsigned int	     cur_idx = e->chn_index;
+	struct cfs_binheap_node **cur_ptr;
+	struct cfs_binheap_node  *last;
+
+	LASSERT(cur_idx != CBH_POISON);
+	LASSERT(cur_idx < n);
+
+	cur_ptr = cfs_binheap_pointer(h, cur_idx);
+	LASSERT(*cur_ptr == e);
+
+	n--;
+	last = *cfs_binheap_pointer(h, n);
+	h->cbh_nelements = n;
+	if (last == e)
+		return;
+
+	last->chn_index = cur_idx;
+	*cur_ptr = last;
+	cfs_binheap_relocate(h, *cur_ptr);
+
+	e->chn_index = CBH_POISON;
+	if (h->cbh_ops->hop_exit)
+		h->cbh_ops->hop_exit(h, e);
+}
+EXPORT_SYMBOL(cfs_binheap_remove);
+
+/**
+ * Relocate a node in the binary heap.
+ * Should be called whenever a node's values
+ * which affects its ranking are changed.
+ *
+ * \param[in] h The heap
+ * \param[in] e The node
+ */
+void
+cfs_binheap_relocate(struct cfs_binheap *h, struct cfs_binheap_node *e)
+{
+	if (!cfs_binheap_bubble(h, e))
+		cfs_binheap_sink(h, e);
+}
+EXPORT_SYMBOL(cfs_binheap_relocate);
+/** @} heap */
diff --git a/fs/lustre/ptlrpc/heap.h b/fs/lustre/ptlrpc/heap.h
new file mode 100644
index 0000000..3972917
--- /dev/null
+++ b/fs/lustre/ptlrpc/heap.h
@@ -0,0 +1,189 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2 for more details.  A copy is
+ * included in the COPYING file that accompanied this code.
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2011 Intel Corporation
+ */
+/*
+ * libcfs/include/libcfs/heap.h
+ *
+ * Author: Eric Barton	<eeb@whamcloud.com>
+ *	   Liang Zhen	<liang@whamcloud.com>
+ */
+
+#ifndef __LIBCFS_HEAP_H__
+#define __LIBCFS_HEAP_H__
+
+/** \defgroup heap Binary heap
+ *
+ * The binary heap is a scalable data structure created using a binary tree. It
+ * is capable of maintaining large sets of elements sorted usually by one or
+ * more element properties, but really based on anything that can be used as a
+ * binary predicate in order to determine the relevant ordering of any two nodes
+ * that belong to the set. There is no search operation, rather the intention is
+ * for the element of the lowest priority which will always be at the root of
+ * the tree (as this is an implementation of a min-heap) to be removed by users
+ * for consumption.
+ *
+ * Users of the heap should embed a \e struct cfs_binheap_node object instance
+ * on every object of the set that they wish the binary heap instance to handle,
+ * and (at a minimum) provide a struct cfs_binheap_ops::hop_compare()
+ * implementation which is used by the heap as the binary predicate during its
+ * internal sorting operations.
+ *
+ * The current implementation enforces no locking scheme, and so assumes the
+ * user caters for locking between calls to insert, delete and lookup
+ * operations. Since the only consumer for the data structure at this point
+ * are NRS policies, and these operate on a per-CPT basis, binary heap instances
+ * are tied to a specific CPT.
+ * @{
+ */
+
+#define CBH_SHIFT	9
+#define CBH_SIZE	(1 << CBH_SHIFT)		/* # ptrs per level */
+#define CBH_MASK	(CBH_SIZE - 1)
+#define CBH_NOB		(CBH_SIZE * sizeof(struct cfs_binheap_node *))
+
+#define CBH_POISON	0xdeadbeef
+
+/**
+ * Binary heap flags.
+ */
+enum {
+	CBH_FLAG_ATOMIC_GROW	= 1,
+};
+
+struct cfs_binheap;
+
+/**
+ * Binary heap operations.
+ */
+struct cfs_binheap_ops {
+	/**
+	 * Called right before inserting a node into the binary heap.
+	 *
+	 * Implementing this operation is optional.
+	 *
+	 * \param[in] h The heap
+	 * \param[in] e The node
+	 *
+	 * \retval 0 success
+	 * \retval != 0 error
+	 */
+	int		(*hop_enter)(struct cfs_binheap *h,
+				     struct cfs_binheap_node *e);
+	/**
+	 * Called right after removing a node from the binary heap.
+	 *
+	 * Implementing this operation is optional.
+	 *
+	 * \param[in] h The heap
+	 * \param[in] e The node
+	 */
+	void		(*hop_exit)(struct cfs_binheap *h,
+				    struct cfs_binheap_node *e);
+	/**
+	 * A binary predicate which is called during internal heap sorting
+	 * operations, and used in order to determine the relevant ordering of
+	 * two heap nodes.
+	 *
+	 * Implementing this operation is mandatory.
+	 *
+	 * \param[in] a The first heap node
+	 * \param[in] b The second heap node
+	 *
+	 * \retval 0 Node a > node b
+	 * \retval 1 Node a < node b
+	 *
+	 * \see cfs_binheap_bubble()
+	 * \see cfs_biheap_sink()
+	 */
+	int		(*hop_compare)(struct cfs_binheap_node *a,
+				       struct cfs_binheap_node *b);
+};
+
+/**
+ * Binary heap object.
+ *
+ * Sorts elements of type \e struct cfs_binheap_node
+ */
+struct cfs_binheap {
+	/** Triple indirect */
+	struct cfs_binheap_node  ****cbh_elements3;
+	/** double indirect */
+	struct cfs_binheap_node   ***cbh_elements2;
+	/** single indirect */
+	struct cfs_binheap_node    **cbh_elements1;
+	/** # elements referenced */
+	unsigned int		cbh_nelements;
+	/** high water mark */
+	unsigned int		cbh_hwm;
+	/** user flags */
+	unsigned int		cbh_flags;
+	/** operations table */
+	struct cfs_binheap_ops *cbh_ops;
+	/** private data */
+	void		       *cbh_private;
+	/** associated CPT table */
+	struct cfs_cpt_table   *cbh_cptab;
+	/** associated CPT id of this struct cfs_binheap::cbh_cptab */
+	int			cbh_cptid;
+};
+
+void cfs_binheap_destroy(struct cfs_binheap *h);
+struct cfs_binheap *
+cfs_binheap_create(struct cfs_binheap_ops *ops, unsigned int flags,
+		   unsigned int count, void *arg, struct cfs_cpt_table *cptab,
+		   int cptid);
+struct cfs_binheap_node *
+cfs_binheap_find(struct cfs_binheap *h, unsigned int idx);
+int cfs_binheap_insert(struct cfs_binheap *h, struct cfs_binheap_node *e);
+void cfs_binheap_remove(struct cfs_binheap *h, struct cfs_binheap_node *e);
+void cfs_binheap_relocate(struct cfs_binheap *h, struct cfs_binheap_node *e);
+
+static inline int
+cfs_binheap_size(struct cfs_binheap *h)
+{
+	return h->cbh_nelements;
+}
+
+static inline int
+cfs_binheap_is_empty(struct cfs_binheap *h)
+{
+	return h->cbh_nelements == 0;
+}
+
+static inline struct cfs_binheap_node *
+cfs_binheap_root(struct cfs_binheap *h)
+{
+	return cfs_binheap_find(h, 0);
+}
+
+static inline struct cfs_binheap_node *
+cfs_binheap_remove_root(struct cfs_binheap *h)
+{
+	struct cfs_binheap_node *e = cfs_binheap_find(h, 0);
+
+	if (e != NULL)
+		cfs_binheap_remove(h, e);
+	return e;
+}
+
+/** @} heap */
+
+#endif /* __LIBCFS_HEAP_H__ */
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 83995cc..190c2b1 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -37,6 +37,7 @@
 #define PTLRPC_INTERNAL_H
 
 #include "../ldlm/ldlm_internal.h"
+#include "heap.h"
 
 struct ldlm_namespace;
 struct obd_import;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
