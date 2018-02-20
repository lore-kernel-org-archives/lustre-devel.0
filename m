From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 21/21] staging: lustre: socklnd: simplify
 ksnc_rx_iov_space
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341826.25814.3735688359829435395.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

ksnc_rx_iov_space is currently a union of two arrays,
one of 'struct kvec', the other of 'struct bio_vec'.

The 'struct bio_vec' option is never used.  The
array of kvec is used to read in a packet header, or
to read data that needs to be skipped so as to synchronize
with a packet boundary.
In each case the target memory location is a virtual address,
never a page, so 'struct bio_vec' is never needed.

When we read into a page, different code steps up a separate
array of 'struct bio_vec'.

So remove the bio_vec option, and remove the union ksock_rxiovspace..

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   11 +----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    4 ++--
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index d50ebdf863fa..570f54ed57b1 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -304,15 +304,6 @@ struct ksock_tx {			   /* transmit packet */
 
 /* network zero copy callback descriptor embedded in struct ksock_tx */
 
-/*
- * space for the rx frag descriptors; we either read a single contiguous
- * header, or up to LNET_MAX_IOV frags of payload of either type.
- */
-union ksock_rxiovspace {
-	struct kvec      iov[LNET_MAX_IOV];
-	struct bio_vec	kiov[LNET_MAX_IOV];
-};
-
 #define SOCKNAL_RX_KSM_HEADER   1 /* reading ksock message header */
 #define SOCKNAL_RX_LNET_HEADER  2 /* reading lnet message header */
 #define SOCKNAL_RX_PARSE        3 /* Calling lnet_parse() */
@@ -359,7 +350,7 @@ struct ksock_conn {
 	__u8               ksnc_rx_state;     /* what is being read */
 	int                ksnc_rx_nob_left;  /* # bytes to next hdr/body */
 	struct iov_iter    ksnc_rx_to;		/* copy destination */
-	union ksock_rxiovspace ksnc_rx_iov_space; /* space for frag descriptors */
+	struct kvec        ksnc_rx_iov_space[LNET_MAX_IOV]; /* space for frag descriptors */
 	__u32              ksnc_rx_csum;      /* partial checksum for incoming
 					       * data
 					       */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 6ab002c006ab..036fecbcede8 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -986,7 +986,7 @@ int
 ksocknal_new_packet(struct ksock_conn *conn, int nob_to_skip)
 {
 	static char ksocknal_slop_buffer[4096];
-	struct kvec *kvec = (struct kvec *)&conn->ksnc_rx_iov_space;
+	struct kvec *kvec = conn->ksnc_rx_iov_space;
 
 	int nob;
 	unsigned int niov;
@@ -1059,7 +1059,7 @@ ksocknal_new_packet(struct ksock_conn *conn, int nob_to_skip)
 static int
 ksocknal_process_receive(struct ksock_conn *conn)
 {
-	struct kvec *kvec = (struct kvec *)&conn->ksnc_rx_iov_space;
+	struct kvec *kvec = conn->ksnc_rx_iov_space;
 	struct lnet_hdr *lhdr;
 	struct lnet_process_id *id;
 	int rc;
