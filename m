From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:36:59 -0400
Subject: [lustre-devel] [PATCH 02/15] lustre: simplify the living hell out
	of ksocknal_lib_recv_kiov()
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>

From: Al Viro <viro@zeniv.linux.org.uk>

... by using ITER_BVEC recvmsg

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  6 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        | 98 ++--------------------
 2 files changed, 12 insertions(+), 92 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a56632b..d5efb42 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -86,8 +86,10 @@ struct ksock_sched {				/* per scheduler state */
 	int                     kss_nconns;     /* # connections assigned to
 						 * this scheduler */
 	struct ksock_sched_info *kss_info;	/* owner of it */
-	struct page             *kss_rx_scratch_pgs[LNET_MAX_IOV];
-	struct kvec             kss_scratch_iov[LNET_MAX_IOV];
+	union {
+		struct bio_vec          kss_scratch_bvec[LNET_MAX_IOV];
+		struct kvec             kss_scratch_iov[LNET_MAX_IOV];
+	};
 };
 
 struct ksock_sched_info {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 6a17757..8479b53 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -259,67 +259,11 @@ ksocknal_lib_recv_iov(struct ksock_conn *conn)
 	return rc;
 }
 
-static void
-ksocknal_lib_kiov_vunmap(void *addr)
-{
-	if (!addr)
-		return;
-
-	vunmap(addr);
-}
-
-static void *
-ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
-		       struct kvec *iov, struct page **pages)
-{
-	void *addr;
-	int nob;
-	int i;
-
-	if (!*ksocknal_tunables.ksnd_zc_recv || !pages)
-		return NULL;
-
-	LASSERT(niov <= LNET_MAX_IOV);
-
-	if (niov < 2 ||
-	    niov < *ksocknal_tunables.ksnd_zc_recv_min_nfrags)
-		return NULL;
-
-	for (nob = i = 0; i < niov; i++) {
-		if ((kiov[i].kiov_offset && i > 0) ||
-		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_SIZE && i < niov - 1))
-			return NULL;
-
-		pages[i] = kiov[i].kiov_page;
-		nob += kiov[i].kiov_len;
-	}
-
-	addr = vmap(pages, niov, VM_MAP, PAGE_KERNEL);
-	if (!addr)
-		return NULL;
-
-	iov->iov_base = addr + kiov[0].kiov_offset;
-	iov->iov_len = nob;
-
-	return addr;
-}
-
 int
 ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 {
-#if SOCKNAL_SINGLE_FRAG_RX || !SOCKNAL_RISK_KMAP_DEADLOCK
-	struct kvec scratch;
-	struct kvec *scratchiov = &scratch;
-	struct page **pages = NULL;
-	unsigned int niov = 1;
-#else
-#ifdef CONFIG_HIGHMEM
-#warning "XXX risk of kmap deadlock on multiple frags..."
-#endif
-	struct kvec *scratchiov = conn->ksnc_scheduler->kss_scratch_iov;
-	struct page **pages = conn->ksnc_scheduler->kss_rx_scratch_pgs;
+	struct bio_vec *bv = conn->ksnc_scheduler->kss_scratch_bvec;
 	unsigned int niov = conn->ksnc_rx_nkiov;
-#endif
 	lnet_kiov_t   *kiov = conn->ksnc_rx_kiov;
 	struct msghdr msg = {
 		.msg_flags = 0
@@ -328,44 +272,26 @@ ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 	int i;
 	int rc;
 	void *base;
-	void *addr;
 	int sum;
 	int fragnob;
 	int n;
 
-	/*
-	 * NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone.
-	 */
-	addr = ksocknal_lib_kiov_vmap(kiov, niov, scratchiov, pages);
-	if (addr) {
-		nob = scratchiov[0].iov_len;
-		n = 1;
-
-	} else {
-		for (nob = i = 0; i < niov; i++) {
-			nob += scratchiov[i].iov_len = kiov[i].kiov_len;
-			scratchiov[i].iov_base = kmap(kiov[i].kiov_page) +
-						 kiov[i].kiov_offset;
-		}
-		n = niov;
+	for (nob = i = 0; i < niov; i++) {
+		nob += bv[i].bv_len = kiov[i].kiov_len;
+		bv[i].bv_page = kiov[i].kiov_page;
+		bv[i].bv_offset = kiov[i].kiov_offset;
 	}
+	n = niov;
 
 	LASSERT(nob <= conn->ksnc_rx_nob_wanted);
 
-	rc = kernel_recvmsg(conn->ksnc_sock, &msg, (struct kvec *)scratchiov,
-			    n, nob, MSG_DONTWAIT);
+	iov_iter_bvec(&msg.msg_iter, READ | ITER_BVEC, bv, n, nob);
+	rc = sock_recvmsg(conn->ksnc_sock, &msg, MSG_DONTWAIT);
 
 	if (conn->ksnc_msg.ksm_csum) {
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
 			LASSERT(i < niov);
 
-			/*
-			 * Dang! have to kmap again because I have nowhere to
-			 * stash the mapped address.  But by doing it while the
-			 * page is still mapped, the kernel just bumps the map
-			 * count and returns me the address it stashed.
-			 */
 			base = kmap(kiov[i].kiov_page) + kiov[i].kiov_offset;
 			fragnob = kiov[i].kiov_len;
 			if (fragnob > sum)
@@ -377,14 +303,6 @@ ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 			kunmap(kiov[i].kiov_page);
 		}
 	}
-
-	if (addr) {
-		ksocknal_lib_kiov_vunmap(addr);
-	} else {
-		for (i = 0; i < niov; i++)
-			kunmap(kiov[i].kiov_page);
-	}
-
 	return rc;
 }
 
-- 
2.7.4
