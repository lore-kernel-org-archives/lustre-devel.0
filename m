From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:00 -0400
Subject: [lustre-devel] [PATCH 03/15] lustre: don't reinvent struct bio_vec
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/staging/lustre/include/linux/lnet/types.h  | 16 +----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 10 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 16 ++---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        | 42 +++++------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  6 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 84 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router.c          | 10 +--
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 15 ++--
 drivers/staging/lustre/lnet/selftest/framework.c   |  4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  8 +--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 10 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   | 14 ++--
 16 files changed, 115 insertions(+), 136 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index e098b6c..f8be0e2 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -503,21 +503,7 @@ typedef struct {
 /* NB lustre portals uses struct iovec internally! */
 typedef struct iovec lnet_md_iovec_t;
 
-/**
- * A page-based fragment of a MD.
- */
-typedef struct {
-	/** Pointer to the page where the fragment resides */
-	struct page	*kiov_page;
-	/** Length in bytes of the fragment */
-	unsigned int	 kiov_len;
-	/**
-	 * Starting offset of the fragment within the page. Note that the
-	 * end of the fragment must not pass the end of the page; i.e.,
-	 * kiov_len + kiov_offset <= PAGE_SIZE.
-	 */
-	unsigned int	 kiov_offset;
-} lnet_kiov_t;
+typedef struct bio_vec lnet_kiov_t;
 /** @} lnet_md */
 
 /** \addtogroup lnet_eq
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 596a697..9eb1db6 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -717,8 +717,8 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 	LASSERT(nkiov > 0);
 	LASSERT(net);
 
-	while (offset >= kiov->kiov_len) {
-		offset -= kiov->kiov_len;
+	while (offset >= kiov->bv_len) {
+		offset -= kiov->bv_len;
 		nkiov--;
 		kiov++;
 		LASSERT(nkiov > 0);
@@ -728,10 +728,10 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 	do {
 		LASSERT(nkiov > 0);
 
-		fragnob = min((int)(kiov->kiov_len - offset), nob);
+		fragnob = min((int)(kiov->bv_len - offset), nob);
 
-		sg_set_page(sg, kiov->kiov_page, fragnob,
-			    kiov->kiov_offset + offset);
+		sg_set_page(sg, kiov->bv_page, fragnob,
+			    kiov->bv_offset + offset);
 		sg = sg_next(sg);
 		if (!sg) {
 			CERROR("lacking enough sg entries to map tx\n");
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 303576d..1823d7f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -164,13 +164,13 @@ ksocknal_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 	do {
 		LASSERT(tx->tx_nkiov > 0);
 
-		if (nob < (int)kiov->kiov_len) {
-			kiov->kiov_offset += nob;
-			kiov->kiov_len -= nob;
+		if (nob < (int)kiov->bv_len) {
+			kiov->bv_offset += nob;
+			kiov->bv_len -= nob;
 			return rc;
 		}
 
-		nob -= (int)kiov->kiov_len;
+		nob -= (int)kiov->bv_len;
 		tx->tx_kiov = ++kiov;
 		tx->tx_nkiov--;
 	} while (nob);
@@ -326,13 +326,13 @@ ksocknal_recv_kiov(struct ksock_conn *conn)
 	do {
 		LASSERT(conn->ksnc_rx_nkiov > 0);
 
-		if (nob < (int)kiov->kiov_len) {
-			kiov->kiov_offset += nob;
-			kiov->kiov_len -= nob;
+		if (nob < (int)kiov->bv_len) {
+			kiov->bv_offset += nob;
+			kiov->bv_len -= nob;
 			return -EAGAIN;
 		}
 
-		nob -= kiov->kiov_len;
+		nob -= kiov->bv_len;
 		conn->ksnc_rx_kiov = ++kiov;
 		conn->ksnc_rx_nkiov--;
 	} while (nob);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 8479b53..fe7b9f9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -131,13 +131,13 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 	if (tx->tx_msg.ksm_zc_cookies[0]) {
 		/* Zero copy is enabled */
 		struct sock *sk = sock->sk;
-		struct page *page = kiov->kiov_page;
-		int offset = kiov->kiov_offset;
-		int fragsize = kiov->kiov_len;
+		struct page *page = kiov->bv_page;
+		int offset = kiov->bv_offset;
+		int fragsize = kiov->bv_len;
 		int msgflg = MSG_DONTWAIT;
 
 		CDEBUG(D_NET, "page %p + offset %x for %d\n",
-		       page, offset, kiov->kiov_len);
+		       page, offset, kiov->bv_len);
 
 		if (!list_empty(&conn->ksnc_tx_queue) ||
 		    fragsize < tx->tx_resid)
@@ -165,9 +165,9 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 		int i;
 
 		for (nob = i = 0; i < niov; i++) {
-			scratchiov[i].iov_base = kmap(kiov[i].kiov_page) +
-						 kiov[i].kiov_offset;
-			nob += scratchiov[i].iov_len = kiov[i].kiov_len;
+			scratchiov[i].iov_base = kmap(kiov[i].bv_page) +
+						 kiov[i].bv_offset;
+			nob += scratchiov[i].iov_len = kiov[i].bv_len;
 		}
 
 		if (!list_empty(&conn->ksnc_tx_queue) ||
@@ -177,7 +177,7 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 		rc = kernel_sendmsg(sock, &msg, (struct kvec *)scratchiov, niov, nob);
 
 		for (i = 0; i < niov; i++)
-			kunmap(kiov[i].kiov_page);
+			kunmap(kiov[i].bv_page);
 	}
 	return rc;
 }
@@ -262,7 +262,6 @@ ksocknal_lib_recv_iov(struct ksock_conn *conn)
 int
 ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 {
-	struct bio_vec *bv = conn->ksnc_scheduler->kss_scratch_bvec;
 	unsigned int niov = conn->ksnc_rx_nkiov;
 	lnet_kiov_t   *kiov = conn->ksnc_rx_kiov;
 	struct msghdr msg = {
@@ -274,33 +273,28 @@ ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 	void *base;
 	int sum;
 	int fragnob;
-	int n;
 
-	for (nob = i = 0; i < niov; i++) {
-		nob += bv[i].bv_len = kiov[i].kiov_len;
-		bv[i].bv_page = kiov[i].kiov_page;
-		bv[i].bv_offset = kiov[i].kiov_offset;
-	}
-	n = niov;
+	for (nob = i = 0; i < niov; i++)
+		nob += kiov[i].bv_len;
 
 	LASSERT(nob <= conn->ksnc_rx_nob_wanted);
 
-	iov_iter_bvec(&msg.msg_iter, READ | ITER_BVEC, bv, n, nob);
+	iov_iter_bvec(&msg.msg_iter, READ | ITER_BVEC, kiov, niov, nob);
 	rc = sock_recvmsg(conn->ksnc_sock, &msg, MSG_DONTWAIT);
 
 	if (conn->ksnc_msg.ksm_csum) {
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
 			LASSERT(i < niov);
 
-			base = kmap(kiov[i].kiov_page) + kiov[i].kiov_offset;
-			fragnob = kiov[i].kiov_len;
+			base = kmap(kiov[i].bv_page) + kiov[i].bv_offset;
+			fragnob = kiov[i].bv_len;
 			if (fragnob > sum)
 				fragnob = sum;
 
 			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
 							   base, fragnob);
 
-			kunmap(kiov[i].kiov_page);
+			kunmap(kiov[i].bv_page);
 		}
 	}
 	return rc;
@@ -324,12 +318,12 @@ ksocknal_lib_csum_tx(struct ksock_tx *tx)
 
 	if (tx->tx_kiov) {
 		for (i = 0; i < tx->tx_nkiov; i++) {
-			base = kmap(tx->tx_kiov[i].kiov_page) +
-			       tx->tx_kiov[i].kiov_offset;
+			base = kmap(tx->tx_kiov[i].bv_page) +
+			       tx->tx_kiov[i].bv_offset;
 
-			csum = ksocknal_csum(csum, base, tx->tx_kiov[i].kiov_len);
+			csum = ksocknal_csum(csum, base, tx->tx_kiov[i].bv_len);
 
-			kunmap(tx->tx_kiov[i].kiov_page);
+			kunmap(tx->tx_kiov[i].bv_page);
 		}
 	} else {
 		for (i = 1; i < tx->tx_niov; i++)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 1834bf7..e0b2f16 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -134,11 +134,11 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
-			if (lmd->md_iov.kiov[i].kiov_offset +
-			    lmd->md_iov.kiov[i].kiov_len > PAGE_SIZE)
+			if (lmd->md_iov.kiov[i].bv_offset +
+			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE)
 				return -EINVAL; /* invalid length */
 
-			total_length += lmd->md_iov.kiov[i].kiov_len;
+			total_length += lmd->md_iov.kiov[i].bv_len;
 		}
 
 		lmd->md_length = total_length;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index e6d3b80..6a3f2e1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -280,7 +280,7 @@ lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
 
 	LASSERT(!niov || kiov);
 	while (niov-- > 0)
-		nob += (kiov++)->kiov_len;
+		nob += (kiov++)->bv_len;
 
 	return nob;
 }
@@ -302,16 +302,16 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 	LASSERT(!in_interrupt());
 
 	LASSERT(ndiov > 0);
-	while (doffset >= diov->kiov_len) {
-		doffset -= diov->kiov_len;
+	while (doffset >= diov->bv_len) {
+		doffset -= diov->bv_len;
 		diov++;
 		ndiov--;
 		LASSERT(ndiov > 0);
 	}
 
 	LASSERT(nsiov > 0);
-	while (soffset >= siov->kiov_len) {
-		soffset -= siov->kiov_len;
+	while (soffset >= siov->bv_len) {
+		soffset -= siov->bv_len;
 		siov++;
 		nsiov--;
 		LASSERT(nsiov > 0);
@@ -320,16 +320,16 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 	do {
 		LASSERT(ndiov > 0);
 		LASSERT(nsiov > 0);
-		this_nob = min(diov->kiov_len - doffset,
-			       siov->kiov_len - soffset);
+		this_nob = min(diov->bv_len - doffset,
+			       siov->bv_len - soffset);
 		this_nob = min(this_nob, nob);
 
 		if (!daddr)
-			daddr = ((char *)kmap(diov->kiov_page)) +
-				diov->kiov_offset + doffset;
+			daddr = ((char *)kmap(diov->bv_page)) +
+				diov->bv_offset + doffset;
 		if (!saddr)
-			saddr = ((char *)kmap(siov->kiov_page)) +
-				siov->kiov_offset + soffset;
+			saddr = ((char *)kmap(siov->bv_page)) +
+				siov->bv_offset + soffset;
 
 		/*
 		 * Vanishing risk of kmap deadlock when mapping 2 pages.
@@ -339,22 +339,22 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 		memcpy(daddr, saddr, this_nob);
 		nob -= this_nob;
 
-		if (diov->kiov_len > doffset + this_nob) {
+		if (diov->bv_len > doffset + this_nob) {
 			daddr += this_nob;
 			doffset += this_nob;
 		} else {
-			kunmap(diov->kiov_page);
+			kunmap(diov->bv_page);
 			daddr = NULL;
 			diov++;
 			ndiov--;
 			doffset = 0;
 		}
 
-		if (siov->kiov_len > soffset + this_nob) {
+		if (siov->bv_len > soffset + this_nob) {
 			saddr += this_nob;
 			soffset += this_nob;
 		} else {
-			kunmap(siov->kiov_page);
+			kunmap(siov->bv_page);
 			saddr = NULL;
 			siov++;
 			nsiov--;
@@ -363,9 +363,9 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 	} while (nob > 0);
 
 	if (daddr)
-		kunmap(diov->kiov_page);
+		kunmap(diov->bv_page);
 	if (saddr)
-		kunmap(siov->kiov_page);
+		kunmap(siov->bv_page);
 }
 EXPORT_SYMBOL(lnet_copy_kiov2kiov);
 
@@ -392,8 +392,8 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 	}
 
 	LASSERT(nkiov > 0);
-	while (kiovoffset >= kiov->kiov_len) {
-		kiovoffset -= kiov->kiov_len;
+	while (kiovoffset >= kiov->bv_len) {
+		kiovoffset -= kiov->bv_len;
 		kiov++;
 		nkiov--;
 		LASSERT(nkiov > 0);
@@ -403,12 +403,12 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 		LASSERT(niov > 0);
 		LASSERT(nkiov > 0);
 		this_nob = min(iov->iov_len - iovoffset,
-			       (__kernel_size_t)kiov->kiov_len - kiovoffset);
+			       (__kernel_size_t)kiov->bv_len - kiovoffset);
 		this_nob = min(this_nob, nob);
 
 		if (!addr)
-			addr = ((char *)kmap(kiov->kiov_page)) +
-				kiov->kiov_offset + kiovoffset;
+			addr = ((char *)kmap(kiov->bv_page)) +
+				kiov->bv_offset + kiovoffset;
 
 		memcpy((char *)iov->iov_base + iovoffset, addr, this_nob);
 		nob -= this_nob;
@@ -421,11 +421,11 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 			iovoffset = 0;
 		}
 
-		if (kiov->kiov_len > kiovoffset + this_nob) {
+		if (kiov->bv_len > kiovoffset + this_nob) {
 			addr += this_nob;
 			kiovoffset += this_nob;
 		} else {
-			kunmap(kiov->kiov_page);
+			kunmap(kiov->bv_page);
 			addr = NULL;
 			kiov++;
 			nkiov--;
@@ -435,7 +435,7 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 	} while (nob > 0);
 
 	if (addr)
-		kunmap(kiov->kiov_page);
+		kunmap(kiov->bv_page);
 }
 EXPORT_SYMBOL(lnet_copy_kiov2iov);
 
@@ -455,8 +455,8 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 	LASSERT(!in_interrupt());
 
 	LASSERT(nkiov > 0);
-	while (kiovoffset >= kiov->kiov_len) {
-		kiovoffset -= kiov->kiov_len;
+	while (kiovoffset >= kiov->bv_len) {
+		kiovoffset -= kiov->bv_len;
 		kiov++;
 		nkiov--;
 		LASSERT(nkiov > 0);
@@ -473,22 +473,22 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 	do {
 		LASSERT(nkiov > 0);
 		LASSERT(niov > 0);
-		this_nob = min((__kernel_size_t)kiov->kiov_len - kiovoffset,
+		this_nob = min((__kernel_size_t)kiov->bv_len - kiovoffset,
 			       iov->iov_len - iovoffset);
 		this_nob = min(this_nob, nob);
 
 		if (!addr)
-			addr = ((char *)kmap(kiov->kiov_page)) +
-				kiov->kiov_offset + kiovoffset;
+			addr = ((char *)kmap(kiov->bv_page)) +
+				kiov->bv_offset + kiovoffset;
 
 		memcpy(addr, (char *)iov->iov_base + iovoffset, this_nob);
 		nob -= this_nob;
 
-		if (kiov->kiov_len > kiovoffset + this_nob) {
+		if (kiov->bv_len > kiovoffset + this_nob) {
 			addr += this_nob;
 			kiovoffset += this_nob;
 		} else {
-			kunmap(kiov->kiov_page);
+			kunmap(kiov->bv_page);
 			addr = NULL;
 			kiov++;
 			nkiov--;
@@ -505,7 +505,7 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 	} while (nob > 0);
 
 	if (addr)
-		kunmap(kiov->kiov_page);
+		kunmap(kiov->bv_page);
 }
 EXPORT_SYMBOL(lnet_copy_iov2kiov);
 
@@ -526,8 +526,8 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		return 0;		     /* no frags */
 
 	LASSERT(src_niov > 0);
-	while (offset >= src->kiov_len) {      /* skip initial frags */
-		offset -= src->kiov_len;
+	while (offset >= src->bv_len) {      /* skip initial frags */
+		offset -= src->bv_len;
 		src_niov--;
 		src++;
 		LASSERT(src_niov > 0);
@@ -538,19 +538,19 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		LASSERT(src_niov > 0);
 		LASSERT((int)niov <= dst_niov);
 
-		frag_len = src->kiov_len - offset;
-		dst->kiov_page = src->kiov_page;
-		dst->kiov_offset = src->kiov_offset + offset;
+		frag_len = src->bv_len - offset;
+		dst->bv_page = src->bv_page;
+		dst->bv_offset = src->bv_offset + offset;
 
 		if (len <= frag_len) {
-			dst->kiov_len = len;
-			LASSERT(dst->kiov_offset + dst->kiov_len
+			dst->bv_len = len;
+			LASSERT(dst->bv_offset + dst->bv_len
 					<= PAGE_SIZE);
 			return niov;
 		}
 
-		dst->kiov_len = frag_len;
-		LASSERT(dst->kiov_offset + dst->kiov_len <= PAGE_SIZE);
+		dst->bv_len = frag_len;
+		LASSERT(dst->bv_offset + dst->bv_len <= PAGE_SIZE);
 
 		len -= frag_len;
 		dst++;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 0635432..69819c9 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1307,7 +1307,7 @@ lnet_destroy_rtrbuf(lnet_rtrbuf_t *rb, int npages)
 	int sz = offsetof(lnet_rtrbuf_t, rb_kiov[npages]);
 
 	while (--npages >= 0)
-		__free_page(rb->rb_kiov[npages].kiov_page);
+		__free_page(rb->rb_kiov[npages].bv_page);
 
 	LIBCFS_FREE(rb, sz);
 }
@@ -1333,15 +1333,15 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 				GFP_KERNEL | __GFP_ZERO, 0);
 		if (!page) {
 			while (--i >= 0)
-				__free_page(rb->rb_kiov[i].kiov_page);
+				__free_page(rb->rb_kiov[i].bv_page);
 
 			LIBCFS_FREE(rb, sz);
 			return NULL;
 		}
 
-		rb->rb_kiov[i].kiov_len = PAGE_SIZE;
-		rb->rb_kiov[i].kiov_offset = 0;
-		rb->rb_kiov[i].kiov_page = page;
+		rb->rb_kiov[i].bv_len = PAGE_SIZE;
+		rb->rb_kiov[i].bv_offset = 0;
+		rb->rb_kiov[i].bv_page = page;
 	}
 
 	return rb;
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 13d0454..b20c5d3 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -226,7 +226,7 @@ brw_fill_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 	struct page *pg;
 
 	for (i = 0; i < bk->bk_niov; i++) {
-		pg = bk->bk_iovs[i].kiov_page;
+		pg = bk->bk_iovs[i].bv_page;
 		brw_fill_page(pg, pattern, magic);
 	}
 }
@@ -238,7 +238,7 @@ brw_check_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 	struct page *pg;
 
 	for (i = 0; i < bk->bk_niov; i++) {
-		pg = bk->bk_iovs[i].kiov_page;
+		pg = bk->bk_iovs[i].bv_page;
 		if (brw_check_page(pg, pattern, magic)) {
 			CERROR("Bulk page %p (%d/%d) is corrupted!\n",
 			       pg, i, bk->bk_niov);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 1be3cad..55afb53 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -152,10 +152,10 @@ lstcon_rpc_put(struct lstcon_rpc *crpc)
 	LASSERT(list_empty(&crpc->crp_link));
 
 	for (i = 0; i < bulk->bk_niov; i++) {
-		if (!bulk->bk_iovs[i].kiov_page)
+		if (!bulk->bk_iovs[i].bv_page)
 			continue;
 
-		__free_page(bulk->bk_iovs[i].kiov_page);
+		__free_page(bulk->bk_iovs[i].bv_page);
 	}
 
 	srpc_client_rpc_decref(crpc->crp_rpc);
@@ -705,7 +705,7 @@ lstcon_next_id(int idx, int nkiov, lnet_kiov_t *kiov)
 
 	LASSERT(i < nkiov);
 
-	pid = (lnet_process_id_packed_t *)page_address(kiov[i].kiov_page);
+	pid = (lnet_process_id_packed_t *)page_address(kiov[i].bv_page);
 
 	return &pid[idx % SFW_ID_PER_PAGE];
 }
@@ -849,12 +849,11 @@ lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 			      min_t(int, nob, PAGE_SIZE);
 			nob -= len;
 
-			bulk->bk_iovs[i].kiov_offset = 0;
-			bulk->bk_iovs[i].kiov_len = len;
-			bulk->bk_iovs[i].kiov_page =
-				alloc_page(GFP_KERNEL);
+			bulk->bk_iovs[i].bv_offset = 0;
+			bulk->bk_iovs[i].bv_len = len;
+			bulk->bk_iovs[i].bv_page = alloc_page(GFP_KERNEL);
 
-			if (!bulk->bk_iovs[i].kiov_page) {
+			if (!bulk->bk_iovs[i].bv_page) {
 				lstcon_rpc_put(*crpc);
 				return -ENOMEM;
 			}
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index c2f121f..abbd628 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -784,8 +784,8 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 		lnet_process_id_packed_t id;
 		int j;
 
-		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].kiov_page);
-		LASSERT(dests);		/* my pages are within KVM always */
+		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].bv_page);
+		LASSERT(dests);  /* my pages are within KVM always */
 		id = dests[i % SFW_ID_PER_PAGE];
 		if (msg->msg_magic != SRPC_MSG_MAGIC)
 			sfw_unpack_id(id);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 3b26d6e..f5619d8 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -91,9 +91,9 @@ srpc_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i, int nob)
 	LASSERT(nob > 0);
 	LASSERT(i >= 0 && i < bk->bk_niov);
 
-	bk->bk_iovs[i].kiov_offset = 0;
-	bk->bk_iovs[i].kiov_page = pg;
-	bk->bk_iovs[i].kiov_len = nob;
+	bk->bk_iovs[i].bv_offset = 0;
+	bk->bk_iovs[i].bv_page = pg;
+	bk->bk_iovs[i].bv_len = nob;
 	return nob;
 }
 
@@ -106,7 +106,7 @@ srpc_free_bulk(struct srpc_bulk *bk)
 	LASSERT(bk);
 
 	for (i = 0; i < bk->bk_niov; i++) {
-		pg = bk->bk_iovs[i].kiov_page;
+		pg = bk->bk_iovs[i].bv_page;
 		if (!pg)
 			break;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d1a7d6b..bad49e0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1864,7 +1864,7 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(page_count >= 0);
 
 	for (i = 0; i < page_count; i++)
-		dec_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+		dec_zone_page_state(desc->bd_iov[i].bv_page, NR_UNSTABLE_NFS);
 
 	atomic_sub(page_count, &cli->cl_cache->ccc_unstable_nr);
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
@@ -1898,7 +1898,7 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(page_count >= 0);
 
 	for (i = 0; i < page_count; i++)
-		inc_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+		inc_zone_page_state(desc->bd_iov[i].bv_page, NR_UNSTABLE_NFS);
 
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
 	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d4463d7..549c62c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -202,7 +202,7 @@ void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc, int unpin)
 
 	if (unpin) {
 		for (i = 0; i < desc->bd_iov_count; i++)
-			put_page(desc->bd_iov[i].kiov_page);
+			put_page(desc->bd_iov[i].bv_page);
 	}
 
 	kfree(desc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 6c820e9..5b9fb11 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -64,9 +64,9 @@ void ptlrpc_add_bulk_page(struct ptlrpc_bulk_desc *desc, struct page *page,
 {
 	lnet_kiov_t *kiov = &desc->bd_iov[desc->bd_iov_count];
 
-	kiov->kiov_page = page;
-	kiov->kiov_offset = pageoffset;
-	kiov->kiov_len = len;
+	kiov->bv_page = page;
+	kiov->bv_offset = pageoffset;
+	kiov->bv_len = len;
 
 	desc->bd_iov_count++;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 5f4d797..bb00185 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -326,12 +326,12 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	LASSERT(page_pools.epp_pools[p_idx]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		LASSERT(desc->bd_enc_iov[i].kiov_page);
+		LASSERT(desc->bd_enc_iov[i].bv_page);
 		LASSERT(g_idx != 0 || page_pools.epp_pools[p_idx]);
 		LASSERT(!page_pools.epp_pools[p_idx][g_idx]);
 
 		page_pools.epp_pools[p_idx][g_idx] =
-					desc->bd_enc_iov[i].kiov_page;
+					desc->bd_enc_iov[i].bv_page;
 
 		if (++g_idx == PAGES_PER_POOL) {
 			p_idx++;
@@ -522,9 +522,9 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 	hashsize = cfs_crypto_hash_digestsize(cfs_hash_alg_id[alg]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		cfs_crypto_hash_update_page(hdesc, desc->bd_iov[i].kiov_page,
-				  desc->bd_iov[i].kiov_offset & ~PAGE_MASK,
-				  desc->bd_iov[i].kiov_len);
+		cfs_crypto_hash_update_page(hdesc, desc->bd_iov[i].bv_page,
+				  desc->bd_iov[i].bv_offset & ~PAGE_MASK,
+				  desc->bd_iov[i].bv_len);
 	}
 
 	if (hashsize > buflen) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 5c4590b..8322550 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -154,13 +154,13 @@ static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 	unsigned int off, i;
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		if (desc->bd_iov[i].kiov_len == 0)
+		if (desc->bd_iov[i].bv_len == 0)
 			continue;
 
-		ptr = kmap(desc->bd_iov[i].kiov_page);
-		off = desc->bd_iov[i].kiov_offset & ~PAGE_MASK;
+		ptr = kmap(desc->bd_iov[i].bv_page);
+		off = desc->bd_iov[i].bv_offset & ~PAGE_MASK;
 		ptr[off] ^= 0x1;
-		kunmap(desc->bd_iov[i].kiov_page);
+		kunmap(desc->bd_iov[i].bv_page);
 		return;
 	}
 }
@@ -349,11 +349,11 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 
 	/* fix the actual data size */
 	for (i = 0, nob = 0; i < desc->bd_iov_count; i++) {
-		if (desc->bd_iov[i].kiov_len + nob > desc->bd_nob_transferred) {
-			desc->bd_iov[i].kiov_len =
+		if (desc->bd_iov[i].bv_len + nob > desc->bd_nob_transferred) {
+			desc->bd_iov[i].bv_len =
 				desc->bd_nob_transferred - nob;
 		}
-		nob += desc->bd_iov[i].kiov_len;
+		nob += desc->bd_iov[i].bv_len;
 	}
 
 	rc = plain_verify_bulk_csum(desc, req->rq_flvr.u_bulk.hash.hash_alg,
-- 
2.7.4
