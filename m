From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 10/32] lustre: lnet: discard LNET_MD_IOVEC
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230957.26912.3452184304224483587.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This flag is never set, so discard it.
lnet_md memory descriptors are either a single virtual
address, or a list of bvec.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   13 +-------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   31 ++------------------
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |    2 +
 4 files changed, 7 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index e60c446fbb27..c6a9a5fb3c96 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -200,7 +200,7 @@ lnet_md_alloc(struct lnet_md *umd)
 		niov = umd->length;
 		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
 	} else {
-		niov = umd->options & LNET_MD_IOVEC ? umd->length : 1;
+		niov = 1;
 		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
 	}
 
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 9f912503a24c..e66f8861ecf0 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -416,11 +416,6 @@ struct lnet_md {
 	 * the number of entries in the array. The length can't be bigger
 	 * than LNET_MAX_IOV. The struct bio_vec is used to describe page-based
 	 * fragments that are not necessarily mapped in virtual memory.
-	 * - LNET_MD_IOVEC bit set: The start field points to the starting
-	 * address of an array of struct iovec and the length field specifies
-	 * the number of entries in the array. The length can't be bigger
-	 * than LNET_MAX_IOV. The struct iovec is used to describe fragments
-	 * that have virtual addresses.
 	 * - Otherwise: The memory region is contiguous. The start field
 	 * specifies the starting address for the memory region and the
 	 * length field specifies its length.
@@ -475,14 +470,12 @@ struct lnet_md {
 	 *   The data sent in the REPLY serves as an implicit acknowledgment.
 	 * - LNET_MD_KIOV: The start and length fields specify an array of
 	 *   struct bio_vec.
-	 * - LNET_MD_IOVEC: The start and length fields specify an array of
-	 *   struct iovec.
 	 * - LNET_MD_MAX_SIZE: The max_size field is valid.
 	 * - LNET_MD_BULK_HANDLE: The bulk_handle field is valid.
 	 *
 	 * Note:
-	 * - LNET_MD_KIOV or LNET_MD_IOVEC allows for a scatter/gather
-	 *   capability for memory descriptors. They can't be both set.
+	 * - LNET_MD_KIOV allows for a scatter/gather
+	 *   capability for memory descriptors.
 	 * - When LNET_MD_MAX_SIZE is set, the total length of the memory
 	 *   region (i.e. sum of all fragment lengths) must not be less than
 	 *   \a max_size.
@@ -535,8 +528,6 @@ struct lnet_md {
 /** See lnet_md::options. */
 #define LNET_MD_ACK_DISABLE	(1 << 5)
 /** See lnet_md::options. */
-#define LNET_MD_IOVEC		(1 << 6)
-/** See lnet_md::options. */
 #define LNET_MD_MAX_SIZE	(1 << 7)
 /** See lnet_md::options. */
 #define LNET_MD_KIOV		(1 << 8)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 33a59fb93414..acc6b239d391 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -190,32 +190,7 @@ lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 	lmd->md_flags = (unlink == LNET_UNLINK) ? LNET_MD_FLAG_AUTO_UNLINK : 0;
 	lmd->md_bulk_handle = umd->bulk_handle;
 
-	if (umd->options & LNET_MD_IOVEC) {
-		if (umd->options & LNET_MD_KIOV) /* Can't specify both */
-			return -EINVAL;
-
-		niov = umd->length;
-		lmd->md_niov = umd->length;
-		memcpy(lmd->md_iov.iov, umd->start,
-		       niov * sizeof(lmd->md_iov.iov[0]));
-
-		for (i = 0; i < (int)niov; i++) {
-			/* We take the base address on trust */
-			/* invalid length */
-			if (lmd->md_iov.iov[i].iov_len <= 0)
-				return -EINVAL;
-
-			total_length += lmd->md_iov.iov[i].iov_len;
-		}
-
-		lmd->md_length = total_length;
-
-		if ((umd->options & LNET_MD_MAX_SIZE) && /* use max size */
-		    (umd->max_size < 0 ||
-		     umd->max_size > total_length)) /* illegal max_size */
-			return -EINVAL;
-
-	} else if (umd->options & LNET_MD_KIOV) {
+	if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
 		lmd->md_niov = umd->length;
 		memcpy(lmd->md_iov.kiov, umd->start,
@@ -302,7 +277,7 @@ lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd)
 	 */
 	umd->start = lmd->md_start;
 	umd->length = !(lmd->md_options &
-		      (LNET_MD_IOVEC | LNET_MD_KIOV)) ?
+			LNET_MD_KIOV) ?
 		      lmd->md_length : lmd->md_niov;
 	umd->threshold = lmd->md_threshold;
 	umd->max_size = lmd->md_max_size;
@@ -320,7 +295,7 @@ lnet_md_validate(struct lnet_md *umd)
 		return -EINVAL;
 	}
 
-	if ((umd->options & (LNET_MD_KIOV | LNET_MD_IOVEC)) &&
+	if ((umd->options & LNET_MD_KIOV) &&
 	    umd->length > LNET_MAX_IOV) {
 		CERROR("Invalid option: too many fragments %u, %d max\n",
 		       umd->length, LNET_MAX_IOV);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 6efa37ba7ded..feef72801640 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -50,7 +50,7 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 
 	LASSERT(mdidx < desc->bd_md_max_brw);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
-	LASSERT(!(md->options & (LNET_MD_IOVEC | LNET_MD_KIOV)));
+	LASSERT(!(md->options & LNET_MD_KIOV));
 
 	md->length = max(0, desc->bd_iov_count - mdidx * LNET_MAX_IOV);
 	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
