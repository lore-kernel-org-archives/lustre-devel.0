From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:07 -0400
Subject: [lustre-devel] [PATCH 10/15] lustre: introduce lnet_copy_{k,
	}iov2iter(), kill lnet_copy_{k, }iov2{k, }iov()
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>, James Simmons <jsimmons@infradead.org>, Oleg Drokin <green@linuxhacker.ru>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  57 +---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  36 +--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 309 ++++-----------------
 drivers/staging/lustre/lnet/lnet/lo.c              |  33 +--
 4 files changed, 80 insertions(+), 355 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 1c5418e..a59c5e99c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -613,65 +613,12 @@ int lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		      int src_niov, const lnet_kiov_t *src,
 		      unsigned int offset, unsigned int len);
 
-void lnet_copy_iov2iov(unsigned int ndiov, const struct kvec *diov,
-		       unsigned int doffset,
+void lnet_copy_iov2iter(struct iov_iter *to,
 			unsigned int nsiov, const struct kvec *siov,
 			unsigned int soffset, unsigned int nob);
-void lnet_copy_kiov2iov(unsigned int niov, const struct kvec *iov,
-			unsigned int iovoffset,
+void lnet_copy_kiov2iter(struct iov_iter *to,
 			 unsigned int nkiov, const lnet_kiov_t *kiov,
 			 unsigned int kiovoffset, unsigned int nob);
-void lnet_copy_iov2kiov(unsigned int nkiov, const lnet_kiov_t *kiov,
-			unsigned int kiovoffset,
-			 unsigned int niov, const struct kvec *iov,
-			 unsigned int iovoffset, unsigned int nob);
-void lnet_copy_kiov2kiov(unsigned int ndkiov, const lnet_kiov_t *dkiov,
-			 unsigned int doffset,
-			  unsigned int nskiov, const lnet_kiov_t *skiov,
-			  unsigned int soffset, unsigned int nob);
-
-static inline void
-lnet_copy_iov2flat(int dlen, void *dest, unsigned int doffset,
-		   unsigned int nsiov, const struct kvec *siov, unsigned int soffset,
-		   unsigned int nob)
-{
-	struct kvec diov = {/*.iov_base = */ dest, /*.iov_len = */ dlen};
-
-	lnet_copy_iov2iov(1, &diov, doffset,
-			  nsiov, siov, soffset, nob);
-}
-
-static inline void
-lnet_copy_kiov2flat(int dlen, void *dest, unsigned int doffset,
-		    unsigned int nsiov, const lnet_kiov_t *skiov,
-		    unsigned int soffset, unsigned int nob)
-{
-	struct kvec diov = {/* .iov_base = */ dest, /* .iov_len = */ dlen};
-
-	lnet_copy_kiov2iov(1, &diov, doffset,
-			   nsiov, skiov, soffset, nob);
-}
-
-static inline void
-lnet_copy_flat2iov(unsigned int ndiov, const struct kvec *diov, unsigned int doffset,
-		   int slen, void *src, unsigned int soffset, unsigned int nob)
-{
-	struct kvec siov = {/*.iov_base = */ src, /*.iov_len = */slen};
-
-	lnet_copy_iov2iov(ndiov, diov, doffset,
-			  1, &siov, soffset, nob);
-}
-
-static inline void
-lnet_copy_flat2kiov(unsigned int ndiov, const lnet_kiov_t *dkiov,
-		    unsigned int doffset, int slen, void *src,
-		    unsigned int soffset, unsigned int nob)
-{
-	struct kvec siov = {/* .iov_base = */ src, /* .iov_len = */ slen};
-
-	lnet_copy_iov2kiov(ndiov, dkiov, doffset,
-			   1, &siov, soffset, nob);
-}
 
 void lnet_me_unlink(lnet_me_t *me);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 1b20ae8..ceb8863 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1499,6 +1499,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
+	struct iov_iter from;
 	struct kib_msg *ibmsg;
 	struct kib_rdma_desc  *rd;
 	struct kib_tx *tx;
@@ -1518,6 +1519,17 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	/* payload is either all vaddrs or all pages */
 	LASSERT(!(payload_kiov && payload_iov));
 
+	if (payload_kiov)
+		iov_iter_bvec(&from, ITER_BVEC | WRITE,
+			      payload_kiov, payload_niov,
+			      payload_nob + payload_offset);
+	else
+		iov_iter_kvec(&from, ITER_KVEC | WRITE,
+			      payload_iov, payload_niov,
+			      payload_nob + payload_offset);
+
+	iov_iter_advance(&from, payload_offset);
+
 	switch (type) {
 	default:
 		LBUG();
@@ -1637,17 +1649,8 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	ibmsg = tx->tx_msg;
 	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
 
-	if (payload_kiov)
-		lnet_copy_kiov2flat(IBLND_MSG_SIZE, ibmsg,
-				    offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-				    payload_niov, payload_kiov,
-				    payload_offset, payload_nob);
-	else
-		lnet_copy_iov2flat(IBLND_MSG_SIZE, ibmsg,
-				   offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-				   payload_niov, payload_iov,
-				   payload_offset, payload_nob);
-
+	copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
+		       &from);
 	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
 	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
 
@@ -1747,16 +1750,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 			break;
 		}
 
-		if (to->type & ITER_BVEC)
-			lnet_copy_flat2kiov(to->nr_segs, to->bvec, to->iov_offset,
-					    IBLND_MSG_SIZE, rxmsg,
-					    offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-					    iov_iter_count(to));
-		else
-			lnet_copy_flat2iov(to->nr_segs, to->kvec, to->iov_offset,
-					   IBLND_MSG_SIZE, rxmsg,
-					   offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-					   iov_iter_count(to));
+		copy_to_iter(&rxmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE, to);
 		lnet_finalize(ni, lntmsg, 0);
 		break;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7387731..8c201b1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -166,25 +166,17 @@ lnet_iov_nob(unsigned int niov, struct kvec *iov)
 EXPORT_SYMBOL(lnet_iov_nob);
 
 void
-lnet_copy_iov2iov(unsigned int ndiov, const struct kvec *diov, unsigned int doffset,
+lnet_copy_iov2iter(struct iov_iter *to,
 		  unsigned int nsiov, const struct kvec *siov, unsigned int soffset,
 		  unsigned int nob)
 {
 	/* NB diov, siov are READ-ONLY */
-	unsigned int this_nob;
+	const char *s;
+	size_t left;
 
 	if (!nob)
 		return;
 
-	/* skip complete frags before 'doffset' */
-	LASSERT(ndiov > 0);
-	while (doffset >= diov->iov_len) {
-		doffset -= diov->iov_len;
-		diov++;
-		ndiov--;
-		LASSERT(ndiov > 0);
-	}
-
 	/* skip complete frags before 'soffset' */
 	LASSERT(nsiov > 0);
 	while (soffset >= siov->iov_len) {
@@ -194,35 +186,63 @@ lnet_copy_iov2iov(unsigned int ndiov, const struct kvec *diov, unsigned int doff
 		LASSERT(nsiov > 0);
 	}
 
+	s = (char *)siov->iov_base + soffset;
+	left = siov->iov_len - soffset;
 	do {
-		LASSERT(ndiov > 0);
+		size_t n, copy = left;
 		LASSERT(nsiov > 0);
-		this_nob = min(diov->iov_len - doffset,
-			       siov->iov_len - soffset);
-		this_nob = min(this_nob, nob);
 
-		memcpy((char *)diov->iov_base + doffset,
-		       (char *)siov->iov_base + soffset, this_nob);
-		nob -= this_nob;
+		if (copy > nob)
+			copy = nob;
+		n = copy_to_iter(s, copy, to);
+		if (n != copy)
+			return;
+		nob -= n;
 
-		if (diov->iov_len > doffset + this_nob) {
-			doffset += this_nob;
-		} else {
-			diov++;
-			ndiov--;
-			doffset = 0;
-		}
+		siov++;
+		s = (char *)siov->iov_base;
+		left = siov->iov_len;
+		nsiov--;
+	} while (nob > 0);
+}
+EXPORT_SYMBOL(lnet_copy_iov2iter);
 
-		if (siov->iov_len > soffset + this_nob) {
-			soffset += this_nob;
-		} else {
-			siov++;
-			nsiov--;
-			soffset = 0;
-		}
+void
+lnet_copy_kiov2iter(struct iov_iter *to,
+		    unsigned int nsiov, const lnet_kiov_t *siov, unsigned int soffset,
+		    unsigned int nob)
+{
+	if (!nob)
+		return;
+
+	LASSERT(!in_interrupt());
+
+	LASSERT(nsiov > 0);
+	while (soffset >= siov->bv_len) {
+		soffset -= siov->bv_len;
+		siov++;
+		nsiov--;
+		LASSERT(nsiov > 0);
+	}
+
+	do {
+		size_t copy = siov->bv_len - soffset, n;
+		LASSERT(nsiov > 0);
+
+		if (copy > nob)
+			copy = nob;
+		n = copy_page_to_iter(siov->bv_page,
+				      siov->bv_offset + soffset,
+				      copy, to);
+		if (n != copy)
+			return;
+		nob -= n;
+		siov++;
+		nsiov--;
+		soffset = 0;
 	} while (nob > 0);
 }
-EXPORT_SYMBOL(lnet_copy_iov2iov);
+EXPORT_SYMBOL(lnet_copy_kiov2iter);
 
 int
 lnet_extract_iov(int dst_niov, struct kvec *dst,
@@ -286,229 +306,6 @@ lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
 }
 EXPORT_SYMBOL(lnet_kiov_nob);
 
-void
-lnet_copy_kiov2kiov(unsigned int ndiov, const lnet_kiov_t *diov, unsigned int doffset,
-		    unsigned int nsiov, const lnet_kiov_t *siov, unsigned int soffset,
-		    unsigned int nob)
-{
-	/* NB diov, siov are READ-ONLY */
-	unsigned int this_nob;
-	char *daddr = NULL;
-	char *saddr = NULL;
-
-	if (!nob)
-		return;
-
-	LASSERT(!in_interrupt());
-
-	LASSERT(ndiov > 0);
-	while (doffset >= diov->bv_len) {
-		doffset -= diov->bv_len;
-		diov++;
-		ndiov--;
-		LASSERT(ndiov > 0);
-	}
-
-	LASSERT(nsiov > 0);
-	while (soffset >= siov->bv_len) {
-		soffset -= siov->bv_len;
-		siov++;
-		nsiov--;
-		LASSERT(nsiov > 0);
-	}
-
-	do {
-		LASSERT(ndiov > 0);
-		LASSERT(nsiov > 0);
-		this_nob = min(diov->bv_len - doffset,
-			       siov->bv_len - soffset);
-		this_nob = min(this_nob, nob);
-
-		if (!daddr)
-			daddr = ((char *)kmap(diov->bv_page)) +
-				diov->bv_offset + doffset;
-		if (!saddr)
-			saddr = ((char *)kmap(siov->bv_page)) +
-				siov->bv_offset + soffset;
-
-		/*
-		 * Vanishing risk of kmap deadlock when mapping 2 pages.
-		 * However in practice at least one of the kiovs will be mapped
-		 * kernel pages and the map/unmap will be NOOPs
-		 */
-		memcpy(daddr, saddr, this_nob);
-		nob -= this_nob;
-
-		if (diov->bv_len > doffset + this_nob) {
-			daddr += this_nob;
-			doffset += this_nob;
-		} else {
-			kunmap(diov->bv_page);
-			daddr = NULL;
-			diov++;
-			ndiov--;
-			doffset = 0;
-		}
-
-		if (siov->bv_len > soffset + this_nob) {
-			saddr += this_nob;
-			soffset += this_nob;
-		} else {
-			kunmap(siov->bv_page);
-			saddr = NULL;
-			siov++;
-			nsiov--;
-			soffset = 0;
-		}
-	} while (nob > 0);
-
-	if (daddr)
-		kunmap(diov->bv_page);
-	if (saddr)
-		kunmap(siov->bv_page);
-}
-EXPORT_SYMBOL(lnet_copy_kiov2kiov);
-
-void
-lnet_copy_kiov2iov(unsigned int niov, const struct kvec *iov, unsigned int iovoffset,
-		   unsigned int nkiov, const lnet_kiov_t *kiov,
-		   unsigned int kiovoffset, unsigned int nob)
-{
-	/* NB iov, kiov are READ-ONLY */
-	unsigned int this_nob;
-	char *addr = NULL;
-
-	if (!nob)
-		return;
-
-	LASSERT(!in_interrupt());
-
-	LASSERT(niov > 0);
-	while (iovoffset >= iov->iov_len) {
-		iovoffset -= iov->iov_len;
-		iov++;
-		niov--;
-		LASSERT(niov > 0);
-	}
-
-	LASSERT(nkiov > 0);
-	while (kiovoffset >= kiov->bv_len) {
-		kiovoffset -= kiov->bv_len;
-		kiov++;
-		nkiov--;
-		LASSERT(nkiov > 0);
-	}
-
-	do {
-		LASSERT(niov > 0);
-		LASSERT(nkiov > 0);
-		this_nob = min(iov->iov_len - iovoffset,
-			       (__kernel_size_t)kiov->bv_len - kiovoffset);
-		this_nob = min(this_nob, nob);
-
-		if (!addr)
-			addr = ((char *)kmap(kiov->bv_page)) +
-				kiov->bv_offset + kiovoffset;
-
-		memcpy((char *)iov->iov_base + iovoffset, addr, this_nob);
-		nob -= this_nob;
-
-		if (iov->iov_len > iovoffset + this_nob) {
-			iovoffset += this_nob;
-		} else {
-			iov++;
-			niov--;
-			iovoffset = 0;
-		}
-
-		if (kiov->bv_len > kiovoffset + this_nob) {
-			addr += this_nob;
-			kiovoffset += this_nob;
-		} else {
-			kunmap(kiov->bv_page);
-			addr = NULL;
-			kiov++;
-			nkiov--;
-			kiovoffset = 0;
-		}
-
-	} while (nob > 0);
-
-	if (addr)
-		kunmap(kiov->bv_page);
-}
-EXPORT_SYMBOL(lnet_copy_kiov2iov);
-
-void
-lnet_copy_iov2kiov(unsigned int nkiov, const lnet_kiov_t *kiov,
-		   unsigned int kiovoffset, unsigned int niov,
-		   const struct kvec *iov, unsigned int iovoffset,
-		   unsigned int nob)
-{
-	/* NB kiov, iov are READ-ONLY */
-	unsigned int this_nob;
-	char *addr = NULL;
-
-	if (!nob)
-		return;
-
-	LASSERT(!in_interrupt());
-
-	LASSERT(nkiov > 0);
-	while (kiovoffset >= kiov->bv_len) {
-		kiovoffset -= kiov->bv_len;
-		kiov++;
-		nkiov--;
-		LASSERT(nkiov > 0);
-	}
-
-	LASSERT(niov > 0);
-	while (iovoffset >= iov->iov_len) {
-		iovoffset -= iov->iov_len;
-		iov++;
-		niov--;
-		LASSERT(niov > 0);
-	}
-
-	do {
-		LASSERT(nkiov > 0);
-		LASSERT(niov > 0);
-		this_nob = min((__kernel_size_t)kiov->bv_len - kiovoffset,
-			       iov->iov_len - iovoffset);
-		this_nob = min(this_nob, nob);
-
-		if (!addr)
-			addr = ((char *)kmap(kiov->bv_page)) +
-				kiov->bv_offset + kiovoffset;
-
-		memcpy(addr, (char *)iov->iov_base + iovoffset, this_nob);
-		nob -= this_nob;
-
-		if (kiov->bv_len > kiovoffset + this_nob) {
-			addr += this_nob;
-			kiovoffset += this_nob;
-		} else {
-			kunmap(kiov->bv_page);
-			addr = NULL;
-			kiov++;
-			nkiov--;
-			kiovoffset = 0;
-		}
-
-		if (iov->iov_len > iovoffset + this_nob) {
-			iovoffset += this_nob;
-		} else {
-			iov++;
-			niov--;
-			iovoffset = 0;
-		}
-	} while (nob > 0);
-
-	if (addr)
-		kunmap(kiov->bv_page);
-}
-EXPORT_SYMBOL(lnet_copy_iov2kiov);
-
 int
 lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		  int src_niov, const lnet_kiov_t *src,
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 131f84d..1cbb639 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -47,29 +47,16 @@ lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
 	lnet_msg_t *sendmsg = private;
 
 	if (lntmsg) {		   /* not discarding */
-		if (sendmsg->msg_iov) {
-			if (to->type & ITER_KVEC)
-				lnet_copy_iov2iov(to->nr_segs, to->kvec, to->iov_offset,
-						  sendmsg->msg_niov,
-						  sendmsg->msg_iov,
-						  sendmsg->msg_offset, iov_iter_count(to));
-			else
-				lnet_copy_iov2kiov(to->nr_segs, to->bvec, to->iov_offset,
-						   sendmsg->msg_niov,
-						   sendmsg->msg_iov,
-						   sendmsg->msg_offset, iov_iter_count(to));
-		} else {
-			if (to->type & ITER_KVEC)
-				lnet_copy_kiov2iov(to->nr_segs, to->kvec, to->iov_offset,
-						   sendmsg->msg_niov,
-						   sendmsg->msg_kiov,
-						   sendmsg->msg_offset, iov_iter_count(to));
-			else
-				lnet_copy_kiov2kiov(to->nr_segs, to->bvec, to->iov_offset,
-						    sendmsg->msg_niov,
-						    sendmsg->msg_kiov,
-						    sendmsg->msg_offset, iov_iter_count(to));
-		}
+		if (sendmsg->msg_iov)
+			lnet_copy_iov2iter(to,
+					   sendmsg->msg_niov,
+					   sendmsg->msg_iov,
+					   sendmsg->msg_offset, iov_iter_count(to));
+		else
+			lnet_copy_kiov2iter(to,
+					    sendmsg->msg_niov,
+					    sendmsg->msg_kiov,
+					    sendmsg->msg_offset, iov_iter_count(to));
 
 		lnet_finalize(ni, lntmsg, 0);
 	}
-- 
2.7.4
