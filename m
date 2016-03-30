From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:23 -0400
Subject: [lustre-devel] [PATCH v2 02/46] staging/lustre: Get rid of
	CFS_PAGE_MASK
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

CFS_PAGE_MASK is the same as PAGE_MASK, so get rid of it.

We are replacing it with PAGE_MASK instead of PAGE_CACHE_MASK
because PAGE_CACHE_* stuff is apparently going away.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |  1 -
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |  2 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 ++--
 drivers/staging/lustre/lustre/llite/rw26.c         |  8 ++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  6 +++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  6 +++---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  4 ++--
 drivers/staging/lustre/lustre/osc/osc_request.c    | 24 +++++++++++-----------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  2 +-
 13 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index 0f2fd79..448379b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -57,7 +57,6 @@
 #include "../libcfs_cpu.h"
 #endif
 
-#define CFS_PAGE_MASK		   (~((__u64)PAGE_CACHE_SIZE-1))
 #define page_index(p)       ((p)->index)
 
 #define memory_pressure_get() (current->flags & PF_MEMALLOC)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 0715101..84f9b7b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -227,7 +227,7 @@ int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *hdesc,
 	struct scatterlist sl;
 
 	sg_init_table(&sl, 1);
-	sg_set_page(&sl, page, len, offset & ~CFS_PAGE_MASK);
+	sg_set_page(&sl, page, len, offset & ~PAGE_MASK);
 
 	ahash_request_set_crypt(req, &sl, NULL, sl.length);
 	return crypto_ahash_update(req);
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index b33c356..1988cee 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -457,7 +457,7 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 
 	if (!(reqstmsg->msg_ses_feats & LST_FEAT_BULK_LEN)) {
 		/* compat with old version */
-		if (reqst->brw_len & ~CFS_PAGE_MASK) {
+		if (reqst->brw_len & ~PAGE_MASK) {
 			reply->brw_status = EINVAL;
 			return 0;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 69445a9..baccf93 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -57,10 +57,10 @@ void policy_from_vma(ldlm_policy_data_t *policy,
 		     struct vm_area_struct *vma, unsigned long addr,
 		     size_t count)
 {
-	policy->l_extent.start = ((addr - vma->vm_start) & CFS_PAGE_MASK) +
+	policy->l_extent.start = ((addr - vma->vm_start) & PAGE_MASK) +
 				 (vma->vm_pgoff << PAGE_CACHE_SHIFT);
 	policy->l_extent.end = (policy->l_extent.start + count - 1) |
-			       ~CFS_PAGE_MASK;
+			       ~PAGE_MASK;
 }
 
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 7a5db67..3d7e64e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -376,7 +376,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 		return -EBADF;
 
 	/* FIXME: io smaller than PAGE_SIZE is broken on ia64 ??? */
-	if ((file_offset & ~CFS_PAGE_MASK) || (count & ~CFS_PAGE_MASK))
+	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
 
 	CDEBUG(D_VFSTRACE,
@@ -386,7 +386,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	       MAX_DIO_SIZE >> PAGE_CACHE_SHIFT);
 
 	/* Check that all user buffers are aligned as well */
-	if (iov_iter_alignment(iter) & ~CFS_PAGE_MASK)
+	if (iov_iter_alignment(iter) & ~PAGE_MASK)
 		return -EINVAL;
 
 	env = cl_env_get(&refcheck);
@@ -435,8 +435,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			    size > (PAGE_CACHE_SIZE / sizeof(*pages)) *
 				   PAGE_CACHE_SIZE) {
 				size = ((((size / 2) - 1) |
-					 ~CFS_PAGE_MASK) + 1) &
-					CFS_PAGE_MASK;
+					 ~PAGE_MASK) + 1) &
+					PAGE_MASK;
 				CDEBUG(D_VFSTRACE, "DIO size now %lu\n",
 				       size);
 				continue;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index fb0c26e..984699a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -234,8 +234,8 @@ static int vvp_mmap_locks(const struct lu_env *env,
 		if (count == 0)
 			continue;
 
-		count += addr & (~CFS_PAGE_MASK);
-		addr &= CFS_PAGE_MASK;
+		count += addr & (~PAGE_MASK);
+		addr &= PAGE_MASK;
 
 		down_read(&mm->mmap_sem);
 		while ((vma = our_vma(mm, addr, count)) != NULL) {
@@ -1043,7 +1043,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 				to = PAGE_CACHE_SIZE;
 				need_clip = false;
 			} else if (last_index == pg->cp_index) {
-				int size_to = i_size_read(inode) & ~CFS_PAGE_MASK;
+				int size_to = i_size_read(inode) & ~PAGE_MASK;
 
 				if (to < size_to)
 					to = size_to;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0f776cf..e3a7216 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2071,7 +2071,7 @@ static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
 			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
 
 			/* Check if we've reached the end of the CFS_PAGE. */
-			if (!((unsigned long)dp & ~CFS_PAGE_MASK))
+			if (!((unsigned long)dp & ~PAGE_MASK))
 				break;
 
 			/* Save the hash and flags of this lu_dirpage. */
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 1a938e1..d9844ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -461,7 +461,7 @@ static int obd_init_checks(void)
 		CWARN("LPD64 wrong length! strlen(%s)=%d != 2\n", buf, len);
 		ret = -EINVAL;
 	}
-	if ((u64val & ~CFS_PAGE_MASK) >= PAGE_CACHE_SIZE) {
+	if ((u64val & ~PAGE_MASK) >= PAGE_CACHE_SIZE) {
 		CWARN("mask failed: u64val %llu >= %llu\n", u64val,
 		      (__u64)PAGE_CACHE_SIZE);
 		ret = -EINVAL;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 64ffe24..33ce0c8 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1119,7 +1119,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	int rc;
 	int i;
 
-	LASSERT((offset & ~CFS_PAGE_MASK) == 0);
+	LASSERT((offset & ~PAGE_MASK) == 0);
 	LASSERT(ed->ed_next);
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -1387,7 +1387,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	LASSERT(rw == OBD_BRW_WRITE || rw == OBD_BRW_READ);
 
 	if (count <= 0 ||
-	    (count & (~CFS_PAGE_MASK)) != 0)
+	    (count & (~PAGE_MASK)) != 0)
 		return -EINVAL;
 
 	/* XXX think again with misaligned I/O */
@@ -1470,7 +1470,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	u64 npages, tot_pages;
 	int i, ret = 0, brw_flags = 0;
 
-	if (count <= 0 || (count & (~CFS_PAGE_MASK)) != 0)
+	if (count <= 0 || (count & (~PAGE_MASK)) != 0)
 		return -EINVAL;
 
 	npages = batch >> PAGE_CACHE_SHIFT;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6336311..3cfd2b0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -877,7 +877,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		 * span a whole chunk on the OST side, or our accounting goes
 		 * wrong.  Should match the code in filter_grant_check.
 		 */
-		int offset = oap->oap_page_off & ~CFS_PAGE_MASK;
+		int offset = oap->oap_page_off & ~PAGE_MASK;
 		int count = oap->oap_count + (offset & (blocksize - 1));
 		int end = (offset + oap->oap_count) & (blocksize - 1);
 
@@ -2238,7 +2238,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 
 	oap->oap_page = page;
 	oap->oap_obj_off = offset;
-	LASSERT(!(offset & ~CFS_PAGE_MASK));
+	LASSERT(!(offset & ~PAGE_MASK));
 
 	if (!client_is_remote(exp) && capable(CFS_CAP_SYS_RESOURCE))
 		oap->oap_brw_flags = OBD_BRW_NOQUOTA;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ec0287f..850d5dd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1082,7 +1082,7 @@ static void handle_short_read(int nob_read, u32 page_count,
 		if (pga[i]->count > nob_read) {
 			/* EOF inside this page */
 			ptr = kmap(pga[i]->pg) +
-				(pga[i]->off & ~CFS_PAGE_MASK);
+				(pga[i]->off & ~PAGE_MASK);
 			memset(ptr + nob_read, 0, pga[i]->count - nob_read);
 			kunmap(pga[i]->pg);
 			page_count--;
@@ -1097,7 +1097,7 @@ static void handle_short_read(int nob_read, u32 page_count,
 
 	/* zero remaining pages */
 	while (page_count-- > 0) {
-		ptr = kmap(pga[i]->pg) + (pga[i]->off & ~CFS_PAGE_MASK);
+		ptr = kmap(pga[i]->pg) + (pga[i]->off & ~PAGE_MASK);
 		memset(ptr, 0, pga[i]->count);
 		kunmap(pga[i]->pg);
 		i++;
@@ -1188,20 +1188,20 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 		if (i == 0 && opc == OST_READ &&
 		    OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE)) {
 			unsigned char *ptr = kmap(pga[i]->pg);
-			int off = pga[i]->off & ~CFS_PAGE_MASK;
+			int off = pga[i]->off & ~PAGE_MASK;
 
 			memcpy(ptr + off, "bad1", min(4, nob));
 			kunmap(pga[i]->pg);
 		}
 		cfs_crypto_hash_update_page(hdesc, pga[i]->pg,
-					    pga[i]->off & ~CFS_PAGE_MASK,
+					    pga[i]->off & ~PAGE_MASK,
 				  count);
 		CDEBUG(D_PAGE,
 		       "page %p map %p index %lu flags %lx count %u priv %0lx: off %d\n",
 		       pga[i]->pg, pga[i]->pg->mapping, pga[i]->pg->index,
 		       (long)pga[i]->pg->flags, page_count(pga[i]->pg),
 		       page_private(pga[i]->pg),
-		       (int)(pga[i]->off & ~CFS_PAGE_MASK));
+		       (int)(pga[i]->off & ~PAGE_MASK));
 
 		nob -= pga[i]->count;
 		pg_count--;
@@ -1309,7 +1309,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	pg_prev = pga[0];
 	for (requested_nob = i = 0; i < page_count; i++, niobuf++) {
 		struct brw_page *pg = pga[i];
-		int poff = pg->off & ~CFS_PAGE_MASK;
+		int poff = pg->off & ~PAGE_MASK;
 
 		LASSERT(pg->count > 0);
 		/* make sure there is no gap in the middle of page array */
@@ -2227,8 +2227,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	/* Filesystem lock extents are extended to page boundaries so that
 	 * dealing with the page cache is a little smoother.
 	 */
-	policy->l_extent.start -= policy->l_extent.start & ~CFS_PAGE_MASK;
-	policy->l_extent.end |= ~CFS_PAGE_MASK;
+	policy->l_extent.start -= policy->l_extent.start & ~PAGE_MASK;
+	policy->l_extent.end |= ~PAGE_MASK;
 
 	/*
 	 * kms is not valid when either object is completely fresh (so that no
@@ -2378,8 +2378,8 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	/* Filesystem lock extents are extended to page boundaries so that
 	 * dealing with the page cache is a little smoother
 	 */
-	policy->l_extent.start -= policy->l_extent.start & ~CFS_PAGE_MASK;
-	policy->l_extent.end |= ~CFS_PAGE_MASK;
+	policy->l_extent.start -= policy->l_extent.start & ~PAGE_MASK;
+	policy->l_extent.end |= ~PAGE_MASK;
 
 	/* Next, search for already existing extent locks that will cover us */
 	/* If we're trying to read, we also search for an existing PW lock.  The
@@ -2784,7 +2784,7 @@ out:
 			goto skip_locking;
 
 		policy.l_extent.start = fm_key->fiemap.fm_start &
-						CFS_PAGE_MASK;
+						PAGE_MASK;
 
 		if (OBD_OBJECT_EOF - fm_key->fiemap.fm_length <=
 		    fm_key->fiemap.fm_start + PAGE_CACHE_SIZE - 1)
@@ -2792,7 +2792,7 @@ out:
 		else
 			policy.l_extent.end = (fm_key->fiemap.fm_start +
 				fm_key->fiemap.fm_length +
-				PAGE_CACHE_SIZE - 1) & CFS_PAGE_MASK;
+				PAGE_CACHE_SIZE - 1) & PAGE_MASK;
 
 		ostid_build_res_name(&fm_key->oa.o_oi, &res_id);
 		mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 54a0c1f..33d1411 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -527,7 +527,7 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
 		cfs_crypto_hash_update_page(hdesc, desc->bd_iov[i].kiov_page,
-				  desc->bd_iov[i].kiov_offset & ~CFS_PAGE_MASK,
+				  desc->bd_iov[i].kiov_offset & ~PAGE_MASK,
 				  desc->bd_iov[i].kiov_len);
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 6276bf5..37c9f4c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -162,7 +162,7 @@ static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 			continue;
 
 		ptr = kmap(desc->bd_iov[i].kiov_page);
-		off = desc->bd_iov[i].kiov_offset & ~CFS_PAGE_MASK;
+		off = desc->bd_iov[i].kiov_offset & ~PAGE_MASK;
 		ptr[off] ^= 0x1;
 		kunmap(desc->bd_iov[i].kiov_page);
 		return;
-- 
2.1.0
