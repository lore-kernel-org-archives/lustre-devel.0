Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B35C4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B2B4661360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org B2B4661360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1722921E07C;
	Sun, 22 Aug 2021 19:28:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0D88021CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2B4A0100BAFA;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1B7CFB6C92; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:36 -0400
Message-Id: <1629685666-4533-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/15] lustre: obdclass: reintroduce lu_ref
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

Previously lu_ref was removed due to the lack of testing. Intel
brought this back to life so reintroduce this debugging feature.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 5c98de856618f30 ("LU-6142 obdclass: resolve lu_ref checkpatch issues")
Reviewed-on: https://review.whamcloud.com/44088
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 6b319185659104b ("LU-8066 obdclass: move lu_ref to debugfs")

Reviewed-on: https://review.whamcloud.com/44311
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/Kconfig           |   9 +
 fs/lustre/include/lu_ref.h  | 104 ++++++++++--
 fs/lustre/obdclass/Makefile |   3 +-
 fs/lustre/obdclass/cl_io.c  |   8 +
 fs/lustre/obdclass/lu_ref.c | 393 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 503 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/Kconfig b/fs/lustre/Kconfig
index bb0e4e7..bcd9d0a 100644
--- a/fs/lustre/Kconfig
+++ b/fs/lustre/Kconfig
@@ -61,6 +61,15 @@ config LUSTRE_DEBUG_EXPENSIVE_CHECK
 
 	  Use with caution. If unsure, say N.
 
+config LUSTRE_DEBUG_LU_REF
+	bool "Enable Lustre lu_ref checks"
+	depends on LUSTRE_DEBUG_EXPENSIVE_CHECK
+	help
+	  lu_ref gives the ability to track references to a given object. It is
+	  quite cpu expensive so its disabled by default.
+
+	  Use with caution. If unsure, say N.
+
 config LUSTRE_TRANSLATE_ERRNOS
 	bool
 	depends on LUSTRE_FS && !X86
diff --git a/fs/lustre/include/lu_ref.h b/fs/lustre/include/lu_ref.h
index 493df95..7b368c2 100644
--- a/fs/lustre/include/lu_ref.h
+++ b/fs/lustre/include/lu_ref.h
@@ -104,12 +104,91 @@
  * @{
  */
 
-/*
- * dummy data structures/functions to pass compile for now.
- * We need to reimplement them with kref.
+#ifdef CONFIG_LUSTRE_DEBUG_LU_REF
+
+/**
+ * Data-structure to keep track of references to a given object. This is used
+ * for debugging.
+ *
+ * lu_ref is embedded into an object which other entities (objects, threads,
+ * etc.) refer to.
  */
-struct lu_ref {};
-struct lu_ref_link {};
+struct lu_ref {
+	/**
+	 * Spin-lock protecting lu_ref::lf_list.
+	 */
+	spinlock_t		lf_guard;
+	/**
+	 * List of all outstanding references (each represented by struct
+	 * lu_ref_link), pointing to this object.
+	 */
+	struct list_head	lf_list;
+	/**
+	 * # of links.
+	 */
+	short			lf_refs;
+	/**
+	 * Flag set when lu_ref_add() failed to allocate lu_ref_link. It is
+	 * used to mask spurious failure of the following lu_ref_del().
+	 */
+	short			lf_failed;
+	/**
+	 * flags - attribute for the lu_ref, for pad and future use.
+	 */
+	short			lf_flags;
+	/**
+	 * Where was I initialized?
+	 */
+	short			lf_line;
+	const char		*lf_func;
+	/**
+	 * Linkage into a global list of all lu_ref's (lu_ref_refs).
+	 */
+	struct list_head	lf_linkage;
+};
+
+struct lu_ref_link {
+	struct lu_ref	*ll_ref;
+	struct list_head ll_linkage;
+	const char	*ll_scope;
+	const void	*ll_source;
+};
+
+void lu_ref_init_loc(struct lu_ref *ref, const char *func, const int line);
+void lu_ref_fini(struct lu_ref *ref);
+#define lu_ref_init(ref) lu_ref_init_loc(ref, __func__, __LINE__)
+
+void lu_ref_add(struct lu_ref *ref, const char *scope, const void *source);
+
+void lu_ref_add_atomic(struct lu_ref *ref, const char *scope,
+		       const void *source);
+
+void lu_ref_add_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope, const void *source);
+
+void lu_ref_del(struct lu_ref *ref, const char *scope, const void *source);
+
+void lu_ref_set_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope, const void *source0, const void *source1);
+
+void lu_ref_del_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope, const void *source);
+
+void lu_ref_print(const struct lu_ref *ref);
+
+void lu_ref_print_all(void);
+
+int lu_ref_global_init(void);
+
+void lu_ref_global_fini(void);
+
+#else /* !CONFIG_LUSTRE_DEBUG_LU_REF */
+
+struct lu_ref {
+};
+
+struct lu_ref_link {
+};
 
 static inline void lu_ref_init(struct lu_ref *ref)
 {
@@ -119,18 +198,16 @@ static inline void lu_ref_fini(struct lu_ref *ref)
 {
 }
 
-static inline struct lu_ref_link *lu_ref_add(struct lu_ref *ref,
-					     const char *scope,
-					     const void *source)
+static inline void lu_ref_add(struct lu_ref *ref,
+			      const char *scope,
+			      const void *source)
 {
-	return NULL;
 }
 
-static inline struct lu_ref_link *lu_ref_add_atomic(struct lu_ref *ref,
-						    const char *scope,
-						    const void *source)
+static inline void lu_ref_add_atomic(struct lu_ref *ref,
+				     const char *scope,
+				     const void *source)
 {
-	return NULL;
 }
 
 static inline void lu_ref_add_at(struct lu_ref *ref,
@@ -172,6 +249,7 @@ static inline void lu_ref_print(const struct lu_ref *ref)
 static inline void lu_ref_print_all(void)
 {
 }
+#endif /* CONFIG_LUSTRE_DEBUG_LU_REF */
 
 /** @} lu */
 
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 1c46ea4..659cdf0 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -6,7 +6,8 @@ obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
-	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
+	      obdo.o obd_config.o obd_mount.o lu_object.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
 	      jobid.o integrity.o obd_cksum.o range_lock.o \
 	      lu_tgt_descs.o lu_tgt_pool.o
+obdclass-$(CONFIG_LUSTRE_DEBUG_LU_REF) += lu_ref.o
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 9a0373f..f33a5f3 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -895,6 +895,14 @@ void cl_page_list_move_head(struct cl_page_list *dst, struct cl_page_list *src,
  */
 void cl_page_list_splice(struct cl_page_list *src, struct cl_page_list *dst)
 {
+#ifdef CONFIG_LUSTRE_DEBUG_LU_REF
+	struct cl_page *page;
+	struct cl_page *tmp;
+
+	cl_page_list_for_each_safe(page, tmp, src)
+		lu_ref_set_at(&page->cp_reference, &page->cp_queue_ref,
+			      "queue", src, dst);
+#endif
 	dst->pl_nr += src->pl_nr;
 	src->pl_nr = 0;
 	list_splice_tail_init(&src->pl_pages, &dst->pl_pages);
diff --git a/fs/lustre/obdclass/lu_ref.c b/fs/lustre/obdclass/lu_ref.c
index fd7ac39..0eb92ce 100644
--- a/fs/lustre/obdclass/lu_ref.c
+++ b/fs/lustre/obdclass/lu_ref.c
@@ -42,3 +42,396 @@
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lu_ref.h>
+
+#ifdef CONFIG_LUSTRE_DEBUG_LU_REF
+/**
+ * Asserts a condition for a given lu_ref. Must be called with
+ * lu_ref::lf_guard held.
+ */
+#define REFASSERT(ref, expr) do {					\
+	struct lu_ref *__tmp = (ref);					\
+									\
+	if (unlikely(!(expr))) {					\
+		lu_ref_print(__tmp);					\
+		spin_unlock(&__tmp->lf_guard);				\
+		lu_ref_print_all();					\
+		LASSERT(0);						\
+		spin_lock(&__tmp->lf_guard);				\
+	}								\
+} while (0)
+
+static struct kmem_cache *lu_ref_link_kmem;
+
+static struct lu_kmem_descr lu_ref_caches[] = {
+	{
+		.ckd_cache = &lu_ref_link_kmem,
+		.ckd_name  = "lu_ref_link_kmem",
+		.ckd_size  = sizeof(struct lu_ref_link)
+	},
+	{
+		.ckd_cache = NULL
+	}
+};
+
+/**
+ * Global list of active (initialized, but not finalized) lu_ref's.
+ *
+ * Protected by lu_ref_refs_guard.
+ */
+static LIST_HEAD(lu_ref_refs);
+static DEFINE_SPINLOCK(lu_ref_refs_guard);
+static struct lu_ref lu_ref_marker = {
+	.lf_guard	= __SPIN_LOCK_UNLOCKED(lu_ref_marker.lf_guard),
+	.lf_list	= LIST_HEAD_INIT(lu_ref_marker.lf_list),
+	.lf_linkage	= LIST_HEAD_INIT(lu_ref_marker.lf_linkage)
+};
+
+void lu_ref_print(const struct lu_ref *ref)
+{
+	struct lu_ref_link *link;
+
+	CERROR("lu_ref: %p %d %d %s:%d\n",
+	       ref, ref->lf_refs, ref->lf_failed, ref->lf_func, ref->lf_line);
+	list_for_each_entry(link, &ref->lf_list, ll_linkage) {
+		CERROR("     link: %s %p\n", link->ll_scope, link->ll_source);
+	}
+}
+
+static int lu_ref_is_marker(const struct lu_ref *ref)
+{
+	return ref == &lu_ref_marker;
+}
+
+void lu_ref_print_all(void)
+{
+	struct lu_ref *ref;
+
+	spin_lock(&lu_ref_refs_guard);
+	list_for_each_entry(ref, &lu_ref_refs, lf_linkage) {
+		if (lu_ref_is_marker(ref))
+			continue;
+
+		spin_lock(&ref->lf_guard);
+		lu_ref_print(ref);
+		spin_unlock(&ref->lf_guard);
+	}
+	spin_unlock(&lu_ref_refs_guard);
+}
+
+void lu_ref_init_loc(struct lu_ref *ref, const char *func, const int line)
+{
+	ref->lf_refs = 0;
+	ref->lf_func = func;
+	ref->lf_line = line;
+	spin_lock_init(&ref->lf_guard);
+	INIT_LIST_HEAD(&ref->lf_list);
+	spin_lock(&lu_ref_refs_guard);
+	list_add(&ref->lf_linkage, &lu_ref_refs);
+	spin_unlock(&lu_ref_refs_guard);
+}
+EXPORT_SYMBOL(lu_ref_init_loc);
+
+void lu_ref_fini(struct lu_ref *ref)
+{
+	spin_lock(&ref->lf_guard);
+	REFASSERT(ref, list_empty(&ref->lf_list));
+	REFASSERT(ref, ref->lf_refs == 0);
+	spin_unlock(&ref->lf_guard);
+	spin_lock(&lu_ref_refs_guard);
+	list_del_init(&ref->lf_linkage);
+	spin_unlock(&lu_ref_refs_guard);
+}
+EXPORT_SYMBOL(lu_ref_fini);
+
+static struct lu_ref_link *lu_ref_add_context(struct lu_ref *ref,
+					      int flags,
+					      const char *scope,
+					      const void *source)
+{
+	struct lu_ref_link *link;
+
+	link = NULL;
+	if (lu_ref_link_kmem) {
+		link = kmem_cache_zalloc(lu_ref_link_kmem, flags);
+		if (link) {
+			link->ll_ref = ref;
+			link->ll_scope = scope;
+			link->ll_source = source;
+			spin_lock(&ref->lf_guard);
+			list_add_tail(&link->ll_linkage, &ref->lf_list);
+			ref->lf_refs++;
+			spin_unlock(&ref->lf_guard);
+		}
+	}
+
+	if (!link) {
+		spin_lock(&ref->lf_guard);
+		ref->lf_failed++;
+		spin_unlock(&ref->lf_guard);
+		link = ERR_PTR(-ENOMEM);
+	}
+
+	return link;
+}
+
+void lu_ref_add(struct lu_ref *ref, const char *scope, const void *source)
+{
+	might_sleep();
+	lu_ref_add_context(ref, GFP_NOFS, scope, source);
+}
+EXPORT_SYMBOL(lu_ref_add);
+
+void lu_ref_add_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope, const void *source)
+{
+	link->ll_ref = ref;
+	link->ll_scope = scope;
+	link->ll_source = source;
+	spin_lock(&ref->lf_guard);
+	list_add_tail(&link->ll_linkage, &ref->lf_list);
+	ref->lf_refs++;
+	spin_unlock(&ref->lf_guard);
+}
+EXPORT_SYMBOL(lu_ref_add_at);
+
+/**
+ * Version of lu_ref_add() to be used in non-blockable contexts.
+ */
+void lu_ref_add_atomic(struct lu_ref *ref, const char *scope,
+		       const void *source)
+{
+	lu_ref_add_context(ref, GFP_ATOMIC, scope, source);
+}
+EXPORT_SYMBOL(lu_ref_add_atomic);
+
+static inline int lu_ref_link_eq(const struct lu_ref_link *link,
+				 const char *scope,
+				 const void *source)
+{
+	return link->ll_source == source && !strcmp(link->ll_scope, scope);
+}
+
+/**
+ * Maximal chain length seen so far.
+ */
+static unsigned int lu_ref_chain_max_length = 127;
+
+/**
+ * Searches for a lu_ref_link with given [scope, source] within given lu_ref.
+ */
+static struct lu_ref_link *lu_ref_find(struct lu_ref *ref, const char *scope,
+				       const void *source)
+{
+	struct lu_ref_link *link;
+	unsigned int iterations;
+
+	iterations = 0;
+	list_for_each_entry(link, &ref->lf_list, ll_linkage) {
+		++iterations;
+		if (lu_ref_link_eq(link, scope, source)) {
+			if (iterations > lu_ref_chain_max_length) {
+				CWARN("Long lu_ref chain %d \"%s\":%p\n",
+				      iterations, scope, source);
+				lu_ref_chain_max_length = iterations * 3 / 2;
+			}
+			return link;
+		}
+	}
+	return NULL;
+}
+
+void lu_ref_del(struct lu_ref *ref, const char *scope, const void *source)
+{
+	struct lu_ref_link *link;
+
+	spin_lock(&ref->lf_guard);
+	link = lu_ref_find(ref, scope, source);
+	if (link) {
+		list_del(&link->ll_linkage);
+		ref->lf_refs--;
+		spin_unlock(&ref->lf_guard);
+		kmem_cache_free(lu_ref_link_kmem, link);
+	} else {
+		REFASSERT(ref, ref->lf_failed > 0);
+		ref->lf_failed--;
+		spin_unlock(&ref->lf_guard);
+	}
+}
+EXPORT_SYMBOL(lu_ref_del);
+
+void lu_ref_set_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope,
+		   const void *source0, const void *source1)
+{
+	spin_lock(&ref->lf_guard);
+	REFASSERT(ref, !IS_ERR_OR_NULL(link));
+	REFASSERT(ref, link->ll_ref == ref);
+	REFASSERT(ref, lu_ref_link_eq(link, scope, source0));
+	link->ll_source = source1;
+	spin_unlock(&ref->lf_guard);
+}
+EXPORT_SYMBOL(lu_ref_set_at);
+
+void lu_ref_del_at(struct lu_ref *ref, struct lu_ref_link *link,
+		   const char *scope, const void *source)
+{
+	spin_lock(&ref->lf_guard);
+	REFASSERT(ref, !IS_ERR_OR_NULL(link));
+	REFASSERT(ref, link->ll_ref == ref);
+	REFASSERT(ref, lu_ref_link_eq(link, scope, source));
+	list_del(&link->ll_linkage);
+	ref->lf_refs--;
+	spin_unlock(&ref->lf_guard);
+}
+EXPORT_SYMBOL(lu_ref_del_at);
+
+static void *lu_ref_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct lu_ref *ref = seq->private;
+
+	spin_lock(&lu_ref_refs_guard);
+	if (list_empty(&ref->lf_linkage))
+		ref = NULL;
+	spin_unlock(&lu_ref_refs_guard);
+
+	return ref;
+}
+
+static void *lu_ref_seq_next(struct seq_file *seq, void *p, loff_t *pos)
+{
+	struct lu_ref *ref = p;
+	struct lu_ref *next;
+
+	LASSERT(seq->private == p);
+	LASSERT(!list_empty(&ref->lf_linkage));
+
+	(*pos)++;
+	spin_lock(&lu_ref_refs_guard);
+	next = list_entry(ref->lf_linkage.next, struct lu_ref, lf_linkage);
+	if (&next->lf_linkage == &lu_ref_refs)
+		p = NULL;
+	else
+		list_move(&ref->lf_linkage, &next->lf_linkage);
+	spin_unlock(&lu_ref_refs_guard);
+
+	return p;
+}
+
+static void lu_ref_seq_stop(struct seq_file *seq, void *p)
+{
+	/* Nothing to do */
+}
+
+
+static int lu_ref_seq_show(struct seq_file *seq, void *p)
+{
+	struct lu_ref *ref  = p;
+	struct lu_ref *next;
+
+	spin_lock(&lu_ref_refs_guard);
+	next = list_entry(ref->lf_linkage.next, struct lu_ref, lf_linkage);
+	if ((&next->lf_linkage == &lu_ref_refs) || lu_ref_is_marker(next)) {
+		spin_unlock(&lu_ref_refs_guard);
+		return 0;
+	}
+
+	/* print the entry */
+	spin_lock(&next->lf_guard);
+	seq_printf(seq, "lu_ref: %p %d %d %s:%d\n",
+		   next, next->lf_refs, next->lf_failed,
+		   next->lf_func, next->lf_line);
+	if (next->lf_refs > 64) {
+		seq_puts(seq, "  too many references, skip\n");
+	} else {
+		struct lu_ref_link *link;
+		int i = 0;
+
+		list_for_each_entry(link, &next->lf_list, ll_linkage)
+			seq_printf(seq, "  #%d link: %s %p\n",
+				   i++, link->ll_scope, link->ll_source);
+	}
+	spin_unlock(&next->lf_guard);
+	spin_unlock(&lu_ref_refs_guard);
+
+	return 0;
+}
+
+static const struct seq_operations lu_ref_seq_ops = {
+	.start	= lu_ref_seq_start,
+	.stop	= lu_ref_seq_stop,
+	.next	= lu_ref_seq_next,
+	.show	= lu_ref_seq_show
+};
+
+static int lu_ref_seq_open(struct inode *inode, struct file *file)
+{
+	struct lu_ref *marker = &lu_ref_marker;
+	int result = 0;
+
+	result = seq_open(file, &lu_ref_seq_ops);
+	if (result == 0) {
+		spin_lock(&lu_ref_refs_guard);
+		if (!list_empty(&marker->lf_linkage))
+			result = -EAGAIN;
+		else
+			list_add(&marker->lf_linkage, &lu_ref_refs);
+		spin_unlock(&lu_ref_refs_guard);
+
+		if (result == 0) {
+			struct seq_file *f = file->private_data;
+
+			f->private = marker;
+		} else {
+			seq_release(inode, file);
+		}
+	}
+
+	return result;
+}
+
+static int lu_ref_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m = file->private_data;
+	struct lu_ref *ref = m->private;
+
+	spin_lock(&lu_ref_refs_guard);
+	list_del_init(&ref->lf_linkage);
+	spin_unlock(&lu_ref_refs_guard);
+
+	return seq_release(inode, file);
+}
+
+static const struct file_operations lu_ref_dump_fops = {
+	.owner		= THIS_MODULE,
+	.open		= lu_ref_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= lu_ref_seq_release
+};
+
+int lu_ref_global_init(void)
+{
+	int result;
+
+	CDEBUG(D_CONSOLE,
+	       "lu_ref tracking is enabled. Performance isn't.\n");
+
+	result = lu_kmem_init(lu_ref_caches);
+	if (result)
+		return result;
+
+	debugfs_create_file("lu_refs", 0444, debugfs_lustre_root,
+			    NULL, &lu_ref_dump_fops);
+
+	return result;
+}
+
+void lu_ref_global_fini(void)
+{
+	/* debugfs file gets cleaned up by debugfs_remove_recursive on
+	 * debugfs_lustre_root
+	 */
+	lu_kmem_fini(lu_ref_caches);
+}
+
+#endif /* CONFIG_LUSTRE_DEBUG_LU_REF */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
