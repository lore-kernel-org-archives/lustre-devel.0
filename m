From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 05/32] lustre: ptlrpc: drop support for KVEC
 bulk descriptors.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230902.26912.12508689063251333121.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All ptlrpc bulk descriptors created are KIOV, none are KVEC.
So don't bother passing PTLRPC_BULK_BUF_KIOV through to
ptlrpc_new_bulk(), just assume it.

This is a first step to removing the KVEC support, which is
unnecessary duplication.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   21 +++++---------------
 5 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 591c4edaa10e..a01ab99a2b5c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1212,7 +1212,7 @@ struct ptlrpc_bulk_desc {
 	spinlock_t			bd_lock;
 	/** Import generation when request for this bulk was sent */
 	int				bd_import_generation;
-	/** {put,get}{source,sink}{kvec,kiov} */
+	/** {put,get}{source,sink}kiov} */
 	enum ptlrpc_bulk_op_type	bd_type;
 	/** LNet portal for this bulk */
 	u32				bd_portal;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 6f933b511366..451e6c94c7e8 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -915,7 +915,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 	ptlrpc_at_set_req_timeout(req);
 
 	desc = ptlrpc_prep_bulk_imp(req, npages, 1,
-				    PTLRPC_BULK_PUT_SINK | PTLRPC_BULK_BUF_KIOV,
+				    PTLRPC_BULK_PUT_SINK,
 				    MDS_BULK_PORTAL,
 				    &ptlrpc_bulk_kiov_pin_ops);
 	if (!desc) {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 6daadf24b894..a805705f357e 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1387,7 +1387,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 
 	/* allocate bulk transfer descriptor */
 	desc = ptlrpc_prep_bulk_imp(req, nrpages, 1,
-				    PTLRPC_BULK_PUT_SINK | PTLRPC_BULK_BUF_KIOV,
+				    PTLRPC_BULK_PUT_SINK,
 				    MGS_BULK_PORTAL,
 				    &ptlrpc_bulk_kiov_pin_ops);
 	if (!desc) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 9484b9a90483..88302ff795ae 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1171,7 +1171,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		req, page_count,
 		cli->cl_import->imp_connect_data.ocd_brw_size >> LNET_MTU_BITS,
 		(opc == OST_WRITE ? PTLRPC_BULK_GET_SOURCE :
-		 PTLRPC_BULK_PUT_SINK) | PTLRPC_BULK_BUF_KIOV, OST_BULK_PORTAL,
+		 PTLRPC_BULK_PUT_SINK), OST_BULK_PORTAL,
 		&ptlrpc_bulk_kiov_pin_ops);
 
 	if (!desc) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a602fa4e5340..53f49c6408cc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -145,32 +145,21 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	struct ptlrpc_bulk_desc *desc;
 	int i;
 
-	/* ensure that only one of KIOV or IOVEC is set but not both */
-	LASSERT((ptlrpc_is_bulk_desc_kiov(type) && ops->add_kiov_frag) ||
-		(ptlrpc_is_bulk_desc_kvec(type) && ops->add_iov_frag));
-
 	desc = kzalloc(sizeof(*desc), GFP_NOFS);
 	if (!desc)
 		return NULL;
 
-	if (type & PTLRPC_BULK_BUF_KIOV) {
-		GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
-					 GFP_NOFS);
-		if (!GET_KIOV(desc))
-			goto free_desc;
-	} else {
-		GET_KVEC(desc) = kcalloc(nfrags, sizeof(*GET_KVEC(desc)),
-					 GFP_NOFS);
-		if (!GET_KVEC(desc))
-			goto free_desc;
-	}
+	GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
+				 GFP_NOFS);
+	if (!GET_KIOV(desc))
+		goto free_desc;
 
 	spin_lock_init(&desc->bd_lock);
 	init_waitqueue_head(&desc->bd_waitq);
 	desc->bd_max_iov = nfrags;
 	desc->bd_iov_count = 0;
 	desc->bd_portal = portal;
-	desc->bd_type = type;
+	desc->bd_type = type | PTLRPC_BULK_BUF_KIOV;
 	desc->bd_md_count = 0;
 	desc->bd_frag_ops = ops;
 	LASSERT(max_brw > 0);
