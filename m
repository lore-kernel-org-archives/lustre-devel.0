From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:40 -0400
Subject: [lustre-devel] [PATCH 06/29] staging: lustre: ptlrpc: Introduce
	iovec to bulk descriptor
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Added a union to ptlrpc_bulk_desc for KVEC and KIOV buffers.
bd_type has been changed to be a bit mask. Bits are set in
bd_type to specify {put,get}{source,sink}{kvec,kiov}
changed all instances in the code to access the union properly
ASSUMPTION: all current code only works with KIOV and new DNE code
to be added will introduce a different code path that uses IOVEC

As part of the implementation buffer operations are added
as callbacks to be defined by users of ptlrpc.  This enables
buffer users to define how to allocate and release buffers.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5835
Reviewed-on: http://review.whamcloud.com/12525
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  160 ++++++++++++++++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    8 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    8 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    7 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  121 +++++++++++----
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    7 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   31 ++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    9 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   19 ++-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   20 ++-
 12 files changed, 290 insertions(+), 108 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 7302238..67a7095 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -50,6 +50,7 @@
  * @{
  */
 
+#include <linux/uio.h>
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/nidstr.h"
 #include "../../include/linux/lnet/api.h"
@@ -1083,10 +1084,93 @@ struct ptlrpc_bulk_page {
 	struct page     *bp_page;
 };
 
-#define BULK_GET_SOURCE   0
-#define BULK_PUT_SINK     1
-#define BULK_GET_SINK     2
-#define BULK_PUT_SOURCE   3
+enum ptlrpc_bulk_op_type {
+	PTLRPC_BULK_OP_ACTIVE	= 0x00000001,
+	PTLRPC_BULK_OP_PASSIVE	= 0x00000002,
+	PTLRPC_BULK_OP_PUT	= 0x00000004,
+	PTLRPC_BULK_OP_GET	= 0x00000008,
+	PTLRPC_BULK_BUF_KVEC	= 0x00000010,
+	PTLRPC_BULK_BUF_KIOV	= 0x00000020,
+	PTLRPC_BULK_GET_SOURCE	= PTLRPC_BULK_OP_PASSIVE | PTLRPC_BULK_OP_GET,
+	PTLRPC_BULK_PUT_SINK	= PTLRPC_BULK_OP_PASSIVE | PTLRPC_BULK_OP_PUT,
+	PTLRPC_BULK_GET_SINK	= PTLRPC_BULK_OP_ACTIVE | PTLRPC_BULK_OP_GET,
+	PTLRPC_BULK_PUT_SOURCE	= PTLRPC_BULK_OP_ACTIVE | PTLRPC_BULK_OP_PUT,
+};
+
+static inline bool ptlrpc_is_bulk_op_get(enum ptlrpc_bulk_op_type type)
+{
+	return (type & PTLRPC_BULK_OP_GET) == PTLRPC_BULK_OP_GET;
+}
+
+static inline bool ptlrpc_is_bulk_get_source(enum ptlrpc_bulk_op_type type)
+{
+	return (type & PTLRPC_BULK_GET_SOURCE) == PTLRPC_BULK_GET_SOURCE;
+}
+
+static inline bool ptlrpc_is_bulk_put_sink(enum ptlrpc_bulk_op_type type)
+{
+	return (type & PTLRPC_BULK_PUT_SINK) == PTLRPC_BULK_PUT_SINK;
+}
+
+static inline bool ptlrpc_is_bulk_get_sink(enum ptlrpc_bulk_op_type type)
+{
+	return (type & PTLRPC_BULK_GET_SINK) == PTLRPC_BULK_GET_SINK;
+}
+
+static inline bool ptlrpc_is_bulk_put_source(enum ptlrpc_bulk_op_type type)
+{
+	return (type & PTLRPC_BULK_PUT_SOURCE) == PTLRPC_BULK_PUT_SOURCE;
+}
+
+static inline bool ptlrpc_is_bulk_desc_kvec(enum ptlrpc_bulk_op_type type)
+{
+	return ((type & PTLRPC_BULK_BUF_KVEC) | (type & PTLRPC_BULK_BUF_KIOV))
+		== PTLRPC_BULK_BUF_KVEC;
+}
+
+static inline bool ptlrpc_is_bulk_desc_kiov(enum ptlrpc_bulk_op_type type)
+{
+	return ((type & PTLRPC_BULK_BUF_KVEC) | (type & PTLRPC_BULK_BUF_KIOV))
+		== PTLRPC_BULK_BUF_KIOV;
+}
+
+static inline bool ptlrpc_is_bulk_op_active(enum ptlrpc_bulk_op_type type)
+{
+	return ((type & PTLRPC_BULK_OP_ACTIVE) |
+		(type & PTLRPC_BULK_OP_PASSIVE)) == PTLRPC_BULK_OP_ACTIVE;
+}
+
+static inline bool ptlrpc_is_bulk_op_passive(enum ptlrpc_bulk_op_type type)
+{
+	return ((type & PTLRPC_BULK_OP_ACTIVE) |
+		(type & PTLRPC_BULK_OP_PASSIVE)) == PTLRPC_BULK_OP_PASSIVE;
+}
+
+struct ptlrpc_bulk_frag_ops {
+	/**
+	 * Add a page \a page to the bulk descriptor \a desc
+	 * Data to transfer in the page starts at offset \a pageoffset and
+	 * amount of data to transfer from the page is \a len
+	 */
+	void (*add_kiov_frag)(struct ptlrpc_bulk_desc *desc,
+			      struct page *page, int pageoffset, int len);
+
+	/*
+	 * Add a \a fragment to the bulk descriptor \a desc.
+	 * Data to transfer in the fragment is pointed to by \a frag
+	 * The size of the fragment is \a len
+	 */
+	int (*add_iov_frag)(struct ptlrpc_bulk_desc *desc, void *frag, int len);
+
+	/**
+	 * Uninitialize and free bulk descriptor \a desc.
+	 * Works on bulk descriptors both from server and client side.
+	 */
+	void (*release_frags)(struct ptlrpc_bulk_desc *desc);
+};
+
+extern const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops;
+extern const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_nopin_ops;
 
 /**
  * Definition of bulk descriptor.
@@ -1101,14 +1185,14 @@ struct ptlrpc_bulk_page {
 struct ptlrpc_bulk_desc {
 	/** completed with failure */
 	unsigned long bd_failure:1;
-	/** {put,get}{source,sink} */
-	unsigned long bd_type:2;
 	/** client side */
 	unsigned long bd_registered:1;
 	/** For serialization with callback */
 	spinlock_t bd_lock;
 	/** Import generation when request for this bulk was sent */
 	int bd_import_generation;
+	/** {put,get}{source,sink}{kvec,kiov} */
+	enum ptlrpc_bulk_op_type bd_type;
 	/** LNet portal for this bulk */
 	__u32 bd_portal;
 	/** Server side - export this bulk created for */
@@ -1117,6 +1201,7 @@ struct ptlrpc_bulk_desc {
 	struct obd_import *bd_import;
 	/** Back pointer to the request */
 	struct ptlrpc_request *bd_req;
+	struct ptlrpc_bulk_frag_ops *bd_frag_ops;
 	wait_queue_head_t	    bd_waitq;	/* server side only WQ */
 	int		    bd_iov_count;    /* # entries in bd_iov */
 	int		    bd_max_iov;      /* allocated size of bd_iov */
@@ -1132,14 +1217,31 @@ struct ptlrpc_bulk_desc {
 	/** array of associated MDs */
 	lnet_handle_md_t	bd_mds[PTLRPC_BULK_OPS_COUNT];
 
-	/*
-	 * encrypt iov, size is either 0 or bd_iov_count.
-	 */
-	lnet_kiov_t	   *bd_enc_iov;
-
-	lnet_kiov_t	    bd_iov[0];
+	union {
+		struct {
+			/*
+			 * encrypt iov, size is either 0 or bd_iov_count.
+			 */
+			struct bio_vec *bd_enc_vec;
+			struct bio_vec *bd_vec;	/* Array of bio_vecs */
+		} bd_kiov;
+
+		struct {
+			struct kvec *bd_enc_kvec;
+			struct kvec *bd_kvec;	/* Array of kvecs */
+		} bd_kvec;
+	} bd_u;
 };
 
+#define GET_KIOV(desc)			((desc)->bd_u.bd_kiov.bd_vec)
+#define BD_GET_KIOV(desc, i)		((desc)->bd_u.bd_kiov.bd_vec[i])
+#define GET_ENC_KIOV(desc)		((desc)->bd_u.bd_kiov.bd_enc_vec)
+#define BD_GET_ENC_KIOV(desc, i)	((desc)->bd_u.bd_kiov.bd_enc_vec[i])
+#define GET_KVEC(desc)			((desc)->bd_u.bd_kvec.bd_kvec)
+#define BD_GET_KVEC(desc, i)		((desc)->bd_u.bd_kvec.bd_kvec[i])
+#define GET_ENC_KVEC(desc)		((desc)->bd_u.bd_kvec.bd_enc_kvec)
+#define BD_GET_ENC_KVEC(desc, i)	((desc)->bd_u.bd_kvec.bd_enc_kvec[i])
+
 enum {
 	SVC_STOPPED     = 1 << 0,
 	SVC_STOPPING    = 1 << 1,
@@ -1754,21 +1856,17 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 void ptlrpc_req_finished(struct ptlrpc_request *request);
 struct ptlrpc_request *ptlrpc_request_addref(struct ptlrpc_request *req);
 struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
-					      unsigned npages, unsigned max_brw,
-					      unsigned type, unsigned portal);
-void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *bulk, int pin);
-static inline void ptlrpc_free_bulk_pin(struct ptlrpc_bulk_desc *bulk)
-{
-	__ptlrpc_free_bulk(bulk, 1);
-}
-
-static inline void ptlrpc_free_bulk_nopin(struct ptlrpc_bulk_desc *bulk)
-{
-	__ptlrpc_free_bulk(bulk, 0);
-}
-
+					      unsigned int nfrags,
+					      unsigned int max_brw,
+					      unsigned int type,
+					      unsigned int portal,
+					      const struct ptlrpc_bulk_frag_ops *ops);
+
+int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
+			  void *frag, int len);
 void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
-			     struct page *page, int pageoffset, int len, int);
+			     struct page *page, int pageoffset, int len,
+			     int pin);
 static inline void ptlrpc_prep_bulk_page_pin(struct ptlrpc_bulk_desc *desc,
 					     struct page *page, int pageoffset,
 					     int len)
@@ -1783,6 +1881,16 @@ static inline void ptlrpc_prep_bulk_page_nopin(struct ptlrpc_bulk_desc *desc,
 	__ptlrpc_prep_bulk_page(desc, page, pageoffset, len, 0);
 }
 
+void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *bulk);
+
+static inline void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
+{
+	int i;
+
+	for (i = 0; i < desc->bd_iov_count ; i++)
+		put_page(BD_GET_KIOV(desc, i).bv_page);
+}
+
 void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 				      struct obd_import *imp);
 __u64 ptlrpc_next_xid(void);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 5282c67..4c30ab6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -859,8 +859,10 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 	req->rq_request_portal = MDS_READPAGE_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	desc = ptlrpc_prep_bulk_imp(req, npages, 1, BULK_PUT_SINK,
-				    MDS_BULK_PORTAL);
+	desc = ptlrpc_prep_bulk_imp(req, npages, 1,
+				    PTLRPC_BULK_PUT_SINK | PTLRPC_BULK_BUF_KIOV,
+				    MDS_BULK_PORTAL,
+				    &ptlrpc_bulk_kiov_pin_ops);
 	if (!desc) {
 		ptlrpc_request_free(req);
 		return -ENOMEM;
@@ -868,7 +870,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 
 	/* NB req now owns desc and will free it when it gets freed */
 	for (i = 0; i < npages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
+		desc->bd_frag_ops->add_kiov_frag(desc, pages[i], 0, PAGE_SIZE);
 
 	mdc_readdir_pack(req, offset, PAGE_SIZE * npages, fid);
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 7b5ac44..2d6fdd0 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1386,15 +1386,17 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	body->mcb_units  = nrpages;
 
 	/* allocate bulk transfer descriptor */
-	desc = ptlrpc_prep_bulk_imp(req, nrpages, 1, BULK_PUT_SINK,
-				    MGS_BULK_PORTAL);
+	desc = ptlrpc_prep_bulk_imp(req, nrpages, 1,
+				    PTLRPC_BULK_PUT_SINK | PTLRPC_BULK_BUF_KIOV,
+				    MGS_BULK_PORTAL,
+				    &ptlrpc_bulk_kiov_pin_ops);
 	if (!desc) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	for (i = 0; i < nrpages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
+		desc->bd_frag_ops->add_kiov_frag(desc, pages[i], 0, PAGE_SIZE);
 
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 399d36b..2fb0e53 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -776,8 +776,10 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 	int count = 0;
 	int i;
 
+	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+
 	for (i = 0; i < page_count; i++) {
-		pg_data_t *pgdat = page_pgdat(desc->bd_iov[i].bv_page);
+		pg_data_t *pgdat = page_pgdat(BD_GET_KIOV(desc, i).bv_page);
 
 		if (likely(pgdat == last)) {
 			++count;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index efd938a..c570d19 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1030,8 +1030,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	desc = ptlrpc_prep_bulk_imp(req, page_count,
 		cli->cl_import->imp_connect_data.ocd_brw_size >> LNET_MTU_BITS,
-		opc == OST_WRITE ? BULK_GET_SOURCE : BULK_PUT_SINK,
-		OST_BULK_PORTAL);
+		(opc == OST_WRITE ? PTLRPC_BULK_GET_SOURCE :
+		 PTLRPC_BULK_PUT_SINK) | PTLRPC_BULK_BUF_KIOV, OST_BULK_PORTAL,
+		 &ptlrpc_bulk_kiov_pin_ops);
 
 	if (!desc) {
 		rc = -ENOMEM;
@@ -1079,7 +1080,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		LASSERT((pga[0]->flag & OBD_BRW_SRVLOCK) ==
 			(pg->flag & OBD_BRW_SRVLOCK));
 
-		ptlrpc_prep_bulk_page_pin(desc, pg->pg, poff, pg->count);
+		desc->bd_frag_ops->add_kiov_frag(desc, pg->pg, poff, pg->count);
 		requested_nob += pg->count;
 
 		if (i > 0 && can_merge_pages(pg_prev, pg)) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index fa4d3c9..e4a31eb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -43,6 +43,18 @@
 
 #include "ptlrpc_internal.h"
 
+const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops = {
+	.add_kiov_frag	= ptlrpc_prep_bulk_page_pin,
+	.release_frags	= ptlrpc_release_bulk_page_pin,
+};
+EXPORT_SYMBOL(ptlrpc_bulk_kiov_pin_ops);
+
+const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_nopin_ops = {
+	.add_kiov_frag	= ptlrpc_prep_bulk_page_nopin,
+	.release_frags	= NULL,
+};
+EXPORT_SYMBOL(ptlrpc_bulk_kiov_nopin_ops);
+
 static int ptlrpc_send_new_req(struct ptlrpc_request *req);
 static int ptlrpcd_check_work(struct ptlrpc_request *req);
 static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async);
@@ -95,24 +107,43 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
  * Allocate and initialize new bulk descriptor on the sender.
  * Returns pointer to the descriptor or NULL on error.
  */
-struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned npages, unsigned max_brw,
-					 unsigned type, unsigned portal)
+struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
+					 unsigned int max_brw,
+					 enum ptlrpc_bulk_op_type type,
+					 unsigned int portal,
+					 const struct ptlrpc_bulk_frag_ops *ops)
 {
 	struct ptlrpc_bulk_desc *desc;
 	int i;
 
-	desc = kzalloc(offsetof(struct ptlrpc_bulk_desc, bd_iov[npages]),
-		       GFP_NOFS);
+	/* ensure that only one of KIOV or IOVEC is set but not both */
+	LASSERT((ptlrpc_is_bulk_desc_kiov(type) && ops->add_kiov_frag) ||
+		(ptlrpc_is_bulk_desc_kvec(type) && ops->add_iov_frag));
+
+	desc = kzalloc(sizeof(*desc), GFP_NOFS);
 	if (!desc)
 		return NULL;
 
+	if (type & PTLRPC_BULK_BUF_KIOV) {
+		GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
+					 GFP_NOFS);
+		if (!GET_KIOV(desc))
+			goto out;
+	} else {
+		GET_KVEC(desc) = kcalloc(nfrags, sizeof(*GET_KVEC(desc)),
+					 GFP_NOFS);
+		if (!GET_KVEC(desc))
+			goto out;
+	}
+
 	spin_lock_init(&desc->bd_lock);
 	init_waitqueue_head(&desc->bd_waitq);
-	desc->bd_max_iov = npages;
+	desc->bd_max_iov = nfrags;
 	desc->bd_iov_count = 0;
 	desc->bd_portal = portal;
 	desc->bd_type = type;
 	desc->bd_md_count = 0;
+	desc->bd_frag_ops = (struct ptlrpc_bulk_frag_ops *)ops;
 	LASSERT(max_brw > 0);
 	desc->bd_md_max_brw = min(max_brw, PTLRPC_BULK_OPS_COUNT);
 	/*
@@ -123,24 +154,30 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned npages, unsigned max_brw,
 		LNetInvalidateHandle(&desc->bd_mds[i]);
 
 	return desc;
+out:
+	return NULL;
 }
 
 /**
  * Prepare bulk descriptor for specified outgoing request \a req that
- * can fit \a npages * pages. \a type is bulk type. \a portal is where
+ * can fit \a nfrags * pages. \a type is bulk type. \a portal is where
  * the bulk to be sent. Used on client-side.
  * Returns pointer to newly allocated initialized bulk descriptor or NULL on
  * error.
  */
 struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
-					      unsigned npages, unsigned max_brw,
-					      unsigned type, unsigned portal)
+					      unsigned int nfrags,
+					      unsigned int max_brw,
+					      unsigned int type,
+					      unsigned int portal,
+					      const struct ptlrpc_bulk_frag_ops *ops)
 {
 	struct obd_import *imp = req->rq_import;
 	struct ptlrpc_bulk_desc *desc;
 
-	LASSERT(type == BULK_PUT_SINK || type == BULK_GET_SOURCE);
-	desc = ptlrpc_new_bulk(npages, max_brw, type, portal);
+	LASSERT(ptlrpc_is_bulk_op_passive(type));
+
+	desc = ptlrpc_new_bulk(nfrags, max_brw, type, portal, ops);
 	if (!desc)
 		return NULL;
 
@@ -158,56 +195,82 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 }
 EXPORT_SYMBOL(ptlrpc_prep_bulk_imp);
 
-/**
- * Add a page \a page to the bulk descriptor \a desc.
- * Data to transfer in the page starts at offset \a pageoffset and
- * amount of data to transfer from the page is \a len
- */
 void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 			     struct page *page, int pageoffset, int len, int pin)
 {
+	struct bio_vec *kiov;
+
 	LASSERT(desc->bd_iov_count < desc->bd_max_iov);
 	LASSERT(page);
 	LASSERT(pageoffset >= 0);
 	LASSERT(len > 0);
 	LASSERT(pageoffset + len <= PAGE_SIZE);
+	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+
+	kiov = &BD_GET_KIOV(desc, desc->bd_iov_count);
 
 	desc->bd_nob += len;
 
 	if (pin)
 		get_page(page);
 
-	ptlrpc_add_bulk_page(desc, page, pageoffset, len);
+	kiov->bv_page = page;
+	kiov->bv_offset = pageoffset;
+	kiov->bv_len = len;
+
+	desc->bd_iov_count++;
 }
 EXPORT_SYMBOL(__ptlrpc_prep_bulk_page);
 
-/**
- * Uninitialize and free bulk descriptor \a desc.
- * Works on bulk descriptors both from server and client side.
- */
-void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc, int unpin)
+int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
+			  void *frag, int len)
 {
-	int i;
+	struct kvec *iovec;
+
+	LASSERT(desc->bd_iov_count < desc->bd_max_iov);
+	LASSERT(frag);
+	LASSERT(len > 0);
+	LASSERT(ptlrpc_is_bulk_desc_kvec(desc->bd_type));
+
+	iovec = &BD_GET_KVEC(desc, desc->bd_iov_count);
+
+	desc->bd_nob += len;
+
+	iovec->iov_base = frag;
+	iovec->iov_len = len;
 
+	desc->bd_iov_count++;
+
+	return desc->bd_nob;
+}
+EXPORT_SYMBOL(ptlrpc_prep_bulk_frag);
+
+void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
+{
 	LASSERT(desc->bd_iov_count != LI_POISON); /* not freed already */
 	LASSERT(desc->bd_md_count == 0);	 /* network hands off */
 	LASSERT((desc->bd_export != NULL) ^ (desc->bd_import != NULL));
+	LASSERT(desc->bd_frag_ops);
 
-	sptlrpc_enc_pool_put_pages(desc);
+	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type))
+		sptlrpc_enc_pool_put_pages(desc);
 
 	if (desc->bd_export)
 		class_export_put(desc->bd_export);
 	else
 		class_import_put(desc->bd_import);
 
-	if (unpin) {
-		for (i = 0; i < desc->bd_iov_count; i++)
-			put_page(desc->bd_iov[i].bv_page);
-	}
+	if (desc->bd_frag_ops->release_frags)
+		desc->bd_frag_ops->release_frags(desc);
+
+	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type))
+		kfree(GET_KIOV(desc));
+	else
+		kfree(GET_KVEC(desc));
 
 	kfree(desc);
 }
-EXPORT_SYMBOL(__ptlrpc_free_bulk);
+EXPORT_SYMBOL(ptlrpc_free_bulk);
 
 /**
  * Set server timelimit for this req, i.e. how long are we willing to wait
@@ -2266,7 +2329,7 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 		request->rq_import = NULL;
 	}
 	if (request->rq_bulk)
-		ptlrpc_free_bulk_pin(request->rq_bulk);
+		ptlrpc_free_bulk(request->rq_bulk);
 
 	if (request->rq_reqbuf || request->rq_clrbuf)
 		sptlrpc_cli_free_reqbuf(request);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 283dfb2..49f3e63 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -182,9 +182,9 @@ void client_bulk_callback(lnet_event_t *ev)
 	struct ptlrpc_bulk_desc *desc = cbid->cbid_arg;
 	struct ptlrpc_request *req;
 
-	LASSERT((desc->bd_type == BULK_PUT_SINK &&
+	LASSERT((ptlrpc_is_bulk_put_sink(desc->bd_type) &&
 		 ev->type == LNET_EVENT_PUT) ||
-		(desc->bd_type == BULK_GET_SOURCE &&
+		(ptlrpc_is_bulk_get_source(desc->bd_type) &&
 		 ev->type == LNET_EVENT_GET) ||
 		ev->type == LNET_EVENT_UNLINK);
 	LASSERT(ev->unlinked);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 9c93739..c2dd948 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -127,8 +127,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	LASSERT(desc->bd_md_max_brw <= PTLRPC_BULK_OPS_COUNT);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
 	LASSERT(desc->bd_req);
-	LASSERT(desc->bd_type == BULK_PUT_SINK ||
-		desc->bd_type == BULK_GET_SOURCE);
+	LASSERT(ptlrpc_is_bulk_op_passive(desc->bd_type));
 
 	/* cleanup the state of the bulk for it will be reused */
 	if (req->rq_resend || req->rq_send_state == LUSTRE_IMP_REPLAY)
@@ -168,7 +167,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	for (posted_md = 0; posted_md < total_md; posted_md++, xid++) {
 		md.options = PTLRPC_MD_OPTIONS |
-			     ((desc->bd_type == BULK_GET_SOURCE) ?
+			     (ptlrpc_is_bulk_op_get(desc->bd_type) ?
 			      LNET_MD_OP_GET : LNET_MD_OP_PUT);
 		ptlrpc_fill_bulk_md(&md, desc, posted_md);
 
@@ -223,7 +222,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	CDEBUG(D_NET, "Setup %u bulk %s buffers: %u pages %u bytes, xid x%#llx-%#llx, portal %u\n",
 	       desc->bd_md_count,
-	       desc->bd_type == BULK_GET_SOURCE ? "get-source" : "put-sink",
+	       ptlrpc_is_bulk_op_get(desc->bd_type) ? "get-source" : "put-sink",
 	       desc->bd_iov_count, desc->bd_nob,
 	       desc->bd_last_xid, req->rq_xid, desc->bd_portal);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 5b9fb11..94e9fa8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -43,6 +43,8 @@
 void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
 			 int mdidx)
 {
+	int offset = mdidx * LNET_MAX_IOV;
+
 	CLASSERT(PTLRPC_MAX_BRW_PAGES < LI_POISON);
 
 	LASSERT(mdidx < desc->bd_md_max_brw);
@@ -50,23 +52,20 @@ void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
 	LASSERT(!(md->options & (LNET_MD_IOVEC | LNET_MD_KIOV |
 				 LNET_MD_PHYS)));
 
-	md->options |= LNET_MD_KIOV;
 	md->length = max(0, desc->bd_iov_count - mdidx * LNET_MAX_IOV);
 	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
-	if (desc->bd_enc_iov)
-		md->start = &desc->bd_enc_iov[mdidx * LNET_MAX_IOV];
-	else
-		md->start = &desc->bd_iov[mdidx * LNET_MAX_IOV];
-}
-
-void ptlrpc_add_bulk_page(struct ptlrpc_bulk_desc *desc, struct page *page,
-			  int pageoffset, int len)
-{
-	lnet_kiov_t *kiov = &desc->bd_iov[desc->bd_iov_count];
-
-	kiov->bv_page = page;
-	kiov->bv_offset = pageoffset;
-	kiov->bv_len = len;
 
-	desc->bd_iov_count++;
+	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type)) {
+		md->options |= LNET_MD_KIOV;
+		if (GET_ENC_KIOV(desc))
+			md->start = &BD_GET_ENC_KIOV(desc, offset);
+		else
+			md->start = &BD_GET_KIOV(desc, offset);
+	} else {
+		md->options |= LNET_MD_IOVEC;
+		if (GET_ENC_KVEC(desc))
+			md->start = &BD_GET_ENC_KVEC(desc, offset);
+		else
+			md->start = &BD_GET_KVEC(desc, offset);
+	}
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index f14d193..b848c25 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -55,8 +55,11 @@
 /* client.c */
 void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 			       unsigned int service_time);
-struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned npages, unsigned max_brw,
-					 unsigned type, unsigned portal);
+struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
+					 unsigned int max_brw,
+					 enum ptlrpc_bulk_op_type type,
+					 unsigned int portal,
+					 const struct ptlrpc_bulk_frag_ops *ops);
 int ptlrpc_request_cache_init(void);
 void ptlrpc_request_cache_fini(void);
 struct ptlrpc_request *ptlrpc_request_cache_alloc(gfp_t flags);
@@ -226,8 +229,6 @@ struct ptlrpc_nrs_policy *nrs_request_policy(struct ptlrpc_nrs_request *nrq)
 /* pers.c */
 void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
 			 int mdcnt);
-void ptlrpc_add_bulk_page(struct ptlrpc_bulk_desc *desc, struct page *page,
-			  int pageoffset, int len);
 
 /* pack_generic.c */
 struct ptlrpc_reply_state *
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index b2cc5ea..ceb805d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -311,7 +311,9 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	int p_idx, g_idx;
 	int i;
 
-	if (!desc->bd_enc_iov)
+	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+
+	if (!GET_ENC_KIOV(desc))
 		return;
 
 	LASSERT(desc->bd_iov_count > 0);
@@ -326,12 +328,12 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	LASSERT(page_pools.epp_pools[p_idx]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		LASSERT(desc->bd_enc_iov[i].bv_page);
+		LASSERT(BD_GET_ENC_KIOV(desc, i).bv_page);
 		LASSERT(g_idx != 0 || page_pools.epp_pools[p_idx]);
 		LASSERT(!page_pools.epp_pools[p_idx][g_idx]);
 
 		page_pools.epp_pools[p_idx][g_idx] =
-					desc->bd_enc_iov[i].bv_page;
+			BD_GET_ENC_KIOV(desc, i).bv_page;
 
 		if (++g_idx == PAGES_PER_POOL) {
 			p_idx++;
@@ -345,8 +347,8 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 
 	spin_unlock(&page_pools.epp_lock);
 
-	kfree(desc->bd_enc_iov);
-	desc->bd_enc_iov = NULL;
+	kfree(GET_ENC_KIOV(desc));
+	GET_ENC_KIOV(desc) = NULL;
 }
 
 static inline void enc_pools_alloc(void)
@@ -520,10 +522,11 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 	hashsize = cfs_crypto_hash_digestsize(cfs_hash_alg_id[alg]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		cfs_crypto_hash_update_page(hdesc, desc->bd_iov[i].bv_page,
-					    desc->bd_iov[i].bv_offset &
+		cfs_crypto_hash_update_page(hdesc,
+					    BD_GET_KIOV(desc, i).bv_page,
+					    BD_GET_KIOV(desc, i).bv_offset &
 					    ~PAGE_MASK,
-					    desc->bd_iov[i].bv_len);
+					    BD_GET_KIOV(desc, i).bv_len);
 	}
 
 	if (hashsize > buflen) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index cd305bc..c5e7a23 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -153,14 +153,16 @@ static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 	char *ptr;
 	unsigned int off, i;
 
+	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		if (desc->bd_iov[i].bv_len == 0)
+		if (!BD_GET_KIOV(desc, i).bv_len)
 			continue;
 
-		ptr = kmap(desc->bd_iov[i].bv_page);
-		off = desc->bd_iov[i].bv_offset & ~PAGE_MASK;
+		ptr = kmap(BD_GET_KIOV(desc, i).bv_page);
+		off = BD_GET_KIOV(desc, i).bv_offset & ~PAGE_MASK;
 		ptr[off] ^= 0x1;
-		kunmap(desc->bd_iov[i].bv_page);
+		kunmap(BD_GET_KIOV(desc, i).bv_page);
 		return;
 	}
 }
@@ -352,11 +354,11 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 
 	/* fix the actual data size */
 	for (i = 0, nob = 0; i < desc->bd_iov_count; i++) {
-		if (desc->bd_iov[i].bv_len + nob > desc->bd_nob_transferred) {
-			desc->bd_iov[i].bv_len =
-				desc->bd_nob_transferred - nob;
-		}
-		nob += desc->bd_iov[i].bv_len;
+		struct bio_vec bv_desc = BD_GET_KIOV(desc, i);
+
+		if (bv_desc.bv_len + nob > desc->bd_nob_transferred)
+			bv_desc.bv_len = desc->bd_nob_transferred - nob;
+		nob += bv_desc.bv_len;
 	}
 
 	rc = plain_verify_bulk_csum(desc, req->rq_flvr.u_bulk.hash.hash_alg,
-- 
1.7.1
