From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:45 -0400
Subject: [lustre-devel] [PATCH 19/24] staging: lustre: selftest: convert
	lstcon_tsb_hdr_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_tsb_hdr_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |    5 +++--
 drivers/staging/lustre/lnet/selftest/console.c |    2 +-
 drivers/staging/lustre/lnet/selftest/console.h |    8 ++++----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3aae59b..be94b9c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -650,7 +650,7 @@ lstcon_dbgrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **c
 
 int
 lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
-		   lstcon_tsb_hdr_t *tsb, struct lstcon_rpc **crpc)
+		   struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc)
 {
 	lstcon_batch_t *batch;
 	srpc_batch_reqst_t *brq;
@@ -1135,7 +1135,8 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 		case LST_TRANS_TSBCLIQRY:
 		case LST_TRANS_TSBSRVQRY:
 			rc = lstcon_batrpc_prep(nd, transop, feats,
-						(lstcon_tsb_hdr_t *)arg, &rpc);
+						(struct lstcon_tsb_hdr *)arg,
+						&rpc);
 			break;
 		case LST_TRANS_STATQRY:
 			rc = lstcon_statrpc_prep(nd, feats, &rpc);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 47338f5..41f732b 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1406,7 +1406,7 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 	struct lstcon_rpc_trans *trans;
 	struct list_head *translist;
 	struct list_head *ndlist;
-	lstcon_tsb_hdr_t *hdr;
+	struct lstcon_tsb_hdr *hdr;
 	lstcon_batch_t *batch;
 	lstcon_test_t *test = NULL;
 	int transop;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 74bfcd8..427bc9b 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -84,13 +84,13 @@ struct lstcon_group {
 #define LST_BATCH_IDLE	  0xB0	    /* idle batch */
 #define LST_BATCH_RUNNING 0xB1	    /* running batch */
 
-typedef struct lstcon_tsb_hdr {
+struct lstcon_tsb_hdr {
 	lst_bid_t	 tsb_id;	 /* batch ID */
 	int		 tsb_index;	 /* test index */
-} lstcon_tsb_hdr_t;
+};
 
 typedef struct {
-	lstcon_tsb_hdr_t bat_hdr;	  /* test_batch header */
+	struct lstcon_tsb_hdr	bat_hdr;	/* test_batch header */
 	struct list_head bat_link;	  /* chain on session's batches list */
 	int		 bat_ntest;	  /* # of test */
 	int		 bat_state;	  /* state of the batch */
@@ -109,7 +109,7 @@ typedef struct {
 } lstcon_batch_t; /* (tests ) batch descriptor */
 
 typedef struct lstcon_test {
-	lstcon_tsb_hdr_t tes_hdr;	 /* test batch header */
+	struct lstcon_tsb_hdr	tes_hdr;	/* test batch header */
 	struct list_head tes_link;	 /* chain on batch's tests list */
 	lstcon_batch_t	 *tes_batch;	 /* pointer to batch */
 
-- 
1.7.1
