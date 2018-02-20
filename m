From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 10/21] staging: lustre: discard lu_buf
 allocation library.
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341787.25814.12742683712598697203.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This library code is unnecessarily generic, but also
not generic enough.  Library code that performs
allocations should always take a gfp_flags argument.

So discard the library and in the one file where it is used,
just use kzalloc or krealloc as needed.
In this context, it is clear that vmalloc is never needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    7 --
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 -
 drivers/staging/lustre/lustre/obdclass/linkea.c    |   16 +++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   70 --------------------
 4 files changed, 12 insertions(+), 83 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 34e35fbff978..35c7b582f36d 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1328,13 +1328,6 @@ struct lu_kmem_descr {
 int  lu_kmem_init(struct lu_kmem_descr *caches);
 void lu_kmem_fini(struct lu_kmem_descr *caches);
 
-void lu_buf_free(struct lu_buf *buf);
-void lu_buf_alloc(struct lu_buf *buf, size_t size);
-void lu_buf_realloc(struct lu_buf *buf, size_t size);
-
-int lu_buf_check_and_grow(struct lu_buf *buf, size_t len);
-struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, size_t len);
-
 extern __u32 lu_context_tags_default;
 extern __u32 lu_session_tags_default;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 07072ab92bb6..efbd551e7842 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2648,7 +2648,7 @@ int ll_getparent(struct file *file, struct getparent __user *arg)
 	}
 
 lb_free:
-	lu_buf_free(&buf);
+	kvfree(buf.lb_buf);
 ldata_free:
 	kfree(ldata);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index fe1638b0916e..74c99ee216bb 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -33,9 +33,11 @@
 
 int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf)
 {
-	ldata->ld_buf = lu_buf_check_and_alloc(buf, PAGE_SIZE);
-	if (!ldata->ld_buf->lb_buf)
+	buf->lb_buf = kzalloc(PAGE_SIZE, GFP_NOFS);
+	if (!buf->lb_buf)
 		return -ENOMEM;
+	buf->lb_len = PAGE_SIZE;
+	ldata->ld_buf = buf;
 	ldata->ld_leh = ldata->ld_buf->lb_buf;
 	ldata->ld_leh->leh_magic = LINK_EA_MAGIC;
 	ldata->ld_leh->leh_len = sizeof(struct link_ea_header);
@@ -158,11 +160,15 @@ int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
 	}
 
 	if (leh->leh_len + reclen > ldata->ld_buf->lb_len) {
-		if (lu_buf_check_and_grow(ldata->ld_buf,
-					  leh->leh_len + reclen) < 0)
+		/* Note: this never happens as MAX_LINKEA_SIZE is 4096, while
+		 * the initial allocation is PAGE_SIZE.
+		 */
+		void *b = krealloc(ldata->ld_buf->lb_buf, leh->leh_len + reclen, GFP_NOFS);
+		if (!b)
 			return -ENOMEM;
 
-		leh = ldata->ld_leh = ldata->ld_buf->lb_buf;
+		ldata->ld_buf->lb_len = leh->leh_len + reclen;
+		leh = ldata->ld_leh = ldata->ld_buf->lb_buf = b;
 	}
 
 	ldata->ld_lee = ldata->ld_buf->lb_buf + leh->leh_len;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 2719abbff85f..cca688175d2d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -2061,73 +2061,3 @@ void lu_kmem_fini(struct lu_kmem_descr *caches)
 	}
 }
 EXPORT_SYMBOL(lu_kmem_fini);
-
-void lu_buf_free(struct lu_buf *buf)
-{
-	LASSERT(buf);
-	if (buf->lb_buf) {
-		LASSERT(buf->lb_len > 0);
-		kvfree(buf->lb_buf);
-		buf->lb_buf = NULL;
-		buf->lb_len = 0;
-	}
-}
-EXPORT_SYMBOL(lu_buf_free);
-
-void lu_buf_alloc(struct lu_buf *buf, size_t size)
-{
-	LASSERT(buf);
-	LASSERT(!buf->lb_buf);
-	LASSERT(!buf->lb_len);
-	buf->lb_buf = libcfs_kvzalloc(size, GFP_NOFS);
-	if (likely(buf->lb_buf))
-		buf->lb_len = size;
-}
-EXPORT_SYMBOL(lu_buf_alloc);
-
-void lu_buf_realloc(struct lu_buf *buf, size_t size)
-{
-	lu_buf_free(buf);
-	lu_buf_alloc(buf, size);
-}
-EXPORT_SYMBOL(lu_buf_realloc);
-
-struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, size_t len)
-{
-	if (!buf->lb_buf && !buf->lb_len)
-		lu_buf_alloc(buf, len);
-
-	if ((len > buf->lb_len) && buf->lb_buf)
-		lu_buf_realloc(buf, len);
-
-	return buf;
-}
-EXPORT_SYMBOL(lu_buf_check_and_alloc);
-
-/**
- * Increase the size of the \a buf.
- * preserves old data in buffer
- * old buffer remains unchanged on error
- * \retval 0 or -ENOMEM
- */
-int lu_buf_check_and_grow(struct lu_buf *buf, size_t len)
-{
-	char *ptr;
-
-	if (len <= buf->lb_len)
-		return 0;
-
-	ptr = libcfs_kvzalloc(len, GFP_NOFS);
-	if (!ptr)
-		return -ENOMEM;
-
-	/* Free the old buf */
-	if (buf->lb_buf) {
-		memcpy(ptr, buf->lb_buf, buf->lb_len);
-		kvfree(buf->lb_buf);
-	}
-
-	buf->lb_buf = ptr;
-	buf->lb_len = len;
-	return 0;
-}
