From: Matthew Wilcox <willy@infradead.org>
Date: Mon, 23 Apr 2018 12:15:31 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: Change return type to
 vm_fault_t
In-Reply-To: <CAFqt6zbFzUYdvndDy6tcvvsbtpvYrUq5XNSfdB4rmuWy=oLh=Q@mail.gmail.com>
References: <20180421221723.GA3054@jordon-HP-15-Notebook-PC>
 <20180422032052.GH14610@bombadil.infradead.org>
 <CAFqt6zaomQW5K_OeYUJjbbv2p8=fMRCuBJVvghyskgMVdPQDdQ@mail.gmail.com>
 <20180423173547.GB13383@bombadil.infradead.org>
 <CAFqt6zbFzUYdvndDy6tcvvsbtpvYrUq5XNSfdB4rmuWy=oLh=Q@mail.gmail.com>
Message-ID: <20180423191531.GD13383@bombadil.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Apr 23, 2018 at 11:38:17PM +0530, Souptick Joarder wrote:
> On Mon, Apr 23, 2018 at 11:05 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > I think you need to check your setup ... I get this:
> >
> > drivers/staging/lustre/lustre/llite/llite_mmap.c:277:31: warning: incorrect type in return expression (different base types)
> > drivers/staging/lustre/lustre/llite/llite_mmap.c:277:31:    expected restricted vm_fault_t
> > drivers/staging/lustre/lustre/llite/llite_mmap.c:277:31:    got long
> 
> What I am trying is -
> after applying the patch in 4.17-rc1, enable the configuration
> for this driver and do "make c=1/2 -j8"
> 
> Let me verify again.

Yep, but you need to add the sparse annotations to make vm_fault_t a
separate type.  In case you've lost that patch ...

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..9ac6d2eb633f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1174,52 +1175,6 @@ static inline void clear_page_pfmemalloc(struct page *page)
 	page->index = 0;
 }
 
-/*
- * Different kinds of faults, as returned by handle_mm_fault().
- * Used to decide whether a process gets delivered SIGBUS or
- * just gets major/minor fault counters bumped up.
- */
-
-#define VM_FAULT_OOM	0x0001
-#define VM_FAULT_SIGBUS	0x0002
-#define VM_FAULT_MAJOR	0x0004
-#define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
-#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
-#define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
-#define VM_FAULT_SIGSEGV 0x0040
-
-#define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
-#define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
-#define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
-#define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
-#define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
-#define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
-					 * and needs fsync() to complete (for
-					 * synchronous page faults in DAX) */
-
-#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
-			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
-			 VM_FAULT_FALLBACK)
-
-#define VM_FAULT_RESULT_TRACE \
-	{ VM_FAULT_OOM,			"OOM" }, \
-	{ VM_FAULT_SIGBUS,		"SIGBUS" }, \
-	{ VM_FAULT_MAJOR,		"MAJOR" }, \
-	{ VM_FAULT_WRITE,		"WRITE" }, \
-	{ VM_FAULT_HWPOISON,		"HWPOISON" }, \
-	{ VM_FAULT_HWPOISON_LARGE,	"HWPOISON_LARGE" }, \
-	{ VM_FAULT_SIGSEGV,		"SIGSEGV" }, \
-	{ VM_FAULT_NOPAGE,		"NOPAGE" }, \
-	{ VM_FAULT_LOCKED,		"LOCKED" }, \
-	{ VM_FAULT_RETRY,		"RETRY" }, \
-	{ VM_FAULT_FALLBACK,		"FALLBACK" }, \
-	{ VM_FAULT_DONE_COW,		"DONE_COW" }, \
-	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" }
-
-/* Encode hstate index for a hwpoisoned large page */
-#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
-#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
-
 /*
  * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.
  */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b9591d..5265f425fe88 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -610,6 +610,54 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
 
 struct vm_fault;
 
+/*
+ * Different kinds of faults, as returned from fault handlers.
+ * Used to decide whether a process gets delivered SIGBUS or
+ * just gets major/minor fault counters bumped up.
+ */
+typedef __bitwise unsigned int vm_fault_t;
+enum {
+	VM_FAULT_OOM		= (__force vm_fault_t)0x000001,	/* Out Of Memory */
+	VM_FAULT_SIGBUS		= (__force vm_fault_t)0x000002,	/* Bad access */
+	VM_FAULT_MAJOR		= (__force vm_fault_t)0x000004,	/* Page read from storage */
+	VM_FAULT_WRITE		= (__force vm_fault_t)0x000008,	/* Special case for get_user_pages */
+	VM_FAULT_HWPOISON	= (__force vm_fault_t)0x000010,	/* Hit poisoned small page */
+	VM_FAULT_HWPOISON_LARGE = (__force vm_fault_t)0x000020,	/* Hit poisoned large page. Index encoded in upper bits */
+	VM_FAULT_SIGSEGV	= (__force vm_fault_t)0x000040,
+	VM_FAULT_NOPAGE		= (__force vm_fault_t)0x000100,	/* ->fault installed the pte, not return page */
+	VM_FAULT_LOCKED		= (__force vm_fault_t)0x000200,	/* ->fault locked the returned page */
+	VM_FAULT_RETRY		= (__force vm_fault_t)0x000400,	/* ->fault blocked, must retry */
+	VM_FAULT_FALLBACK	= (__force vm_fault_t)0x000800,	/* huge page fault failed, fall back to small */
+	VM_FAULT_DONE_COW	= (__force vm_fault_t)0x001000,	/* ->fault has fully handled COW */
+	VM_FAULT_NEEDDSYNC	= (__force vm_fault_t)0x002000,	/* ->fault did not modify page tables
+					 * and needs fsync() to complete (for
+					 * synchronous page faults in DAX) */
+	VM_FAULT_HINDEX_MASK	= (__force vm_fault_t)0x0f0000,
+};
+
+/* Encode hstate index for a hwpoisoned large page */
+#define VM_FAULT_SET_HINDEX(x) ((x) << 16)
+#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
+
+#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
+			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
+			 VM_FAULT_FALLBACK)
+
+#define VM_FAULT_RESULT_TRACE \
+	{ VM_FAULT_OOM,			"OOM" }, \
+	{ VM_FAULT_SIGBUS,		"SIGBUS" }, \
+	{ VM_FAULT_MAJOR,		"MAJOR" }, \
+	{ VM_FAULT_WRITE,		"WRITE" }, \
+	{ VM_FAULT_HWPOISON,		"HWPOISON" }, \
+	{ VM_FAULT_HWPOISON_LARGE,	"HWPOISON_LARGE" }, \
+	{ VM_FAULT_SIGSEGV,		"SIGSEGV" }, \
+	{ VM_FAULT_NOPAGE,		"NOPAGE" }, \
+	{ VM_FAULT_LOCKED,		"LOCKED" }, \
+	{ VM_FAULT_RETRY,		"RETRY" }, \
+	{ VM_FAULT_FALLBACK,		"FALLBACK" }, \
+	{ VM_FAULT_DONE_COW,		"DONE_COW" }, \
+	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" }
+
 struct vm_special_mapping {
 	const char *name;	/* The name, e.g. "[vdso]". */
 
