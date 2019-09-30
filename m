From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:20 -0400
Subject: [lustre-devel] [PATCH 061/151] lustre: brw: add short io osc/ost
 transfer.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-62-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

There's no need to do target bulk io for small amount of
data, and it requires extra network operations.

For this case we add short i/o.  When the i/o size is less
than or equal to some number of pages (default 3), we
encapsulate the data in the ptlrpc request.

With this patch, 4k direct i/o read latency on a Cray Aries
network (data is on flash on another node on the Aries)
drops from ~280 microseconds to ~200 microseconds.  Write
latency drops from ~370 microseconds to ~350 microseconds
(much more of write latency is waiting for write commit).

This translates to about a 25-30% performance improvement
on 4k direct i/o reads and 4k random reads.  (Write
performance improvement was small to non-existent.)

Improvement was similar with 8k i/o.

Buffered sequential i/o sees no improvement, because it
does not perform small i/os.

Performance data:
        access             = file-per-process
        pattern            = segmented (1 segment)
        ordering in a file = random offsets
        ordering inter file= no tasks offsets
        xfersize           = 4096 bytes
        blocksize          = 100 MiB

nprocs  xfsize  shortio dio     random  Read (MB/s)
1       4k      no      yes     no      15.0
8       4k      no      yes     no      73.4
16      4k      no      yes     no      81.1
1       4k      yes     yes     no      16.5
8       4k      yes     yes     no      95.2
16      4k      yes     yes     no      107.3
1       4k      no      no      yes     15.5
8       4k      no      no      yes     73.4
16      4k      no      no      yes     81.2
1       4k      yes     no      yes     16.8
8       4k      yes     no      yes     95.0
16      4k      yes     no      yes     106.5

Note even when individual i/o performance is not improved,
this change reduces the # of network operations required
for small i/o, which can help on large systems.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1757
Cray-bug-id: LUS-187
Lustre-commit: 70f092a05878 ("LU-1757 LU-1757 brw: add short io osc/ost transfer")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27767
Lustre-commit: 3483e195314b ("LU-1757 brw: Fix short i/o and enable for mdc")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30435
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 32fb31f3bf3d ("LU-8066 osc: move suitable values from procfs to sysfs")
Reviewed-on: https://review.whamcloud.com/30962
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h    |   4 ++
 fs/lustre/include/lustre_export.h     |   7 ++
 fs/lustre/include/lustre_net.h        |  37 +++++++++-
 fs/lustre/include/lustre_osc.h        |  12 ++++
 fs/lustre/include/lustre_req_layout.h |   1 +
 fs/lustre/include/obd.h               |   1 +
 fs/lustre/llite/llite_lib.c           |   6 +-
 fs/lustre/obdclass/lprocfs_status.c   |  55 +++++++++++++++
 fs/lustre/osc/lproc_osc.c             |   3 +
 fs/lustre/osc/osc_page.c              |  48 ++++++++++---
 fs/lustre/osc/osc_request.c           | 129 ++++++++++++++++++++++++++++------
 fs/lustre/ptlrpc/layout.c             |  10 ++-
 12 files changed, 272 insertions(+), 41 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 815ca37..e923673 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -590,6 +590,10 @@ ssize_t max_pages_per_rpc_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf);
 ssize_t max_pages_per_rpc_store(struct kobject *kobj, struct attribute *attr,
 				const char *buffer, size_t count);
+ssize_t short_io_bytes_show(struct kobject *kobj, struct attribute *attr,
+			    char *buf);
+ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
+			     const char *buffer, size_t count);
 
 struct root_squash_info;
 int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index ed0664b..4ac996b 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -245,6 +245,13 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 	return ocd->ocd_connect_flags & OBD_CONNECT_DISP_STRIPE;
 }
 
+static inline bool imp_connect_shortio(struct obd_import *imp)
+{
+	struct obd_connect_data *ocd = &imp->imp_connect_data;
+
+	return ocd->ocd_connect_flags & OBD_CONNECT_SHORTIO;
+}
+
 static inline int exp_connect_lockahead_old(struct obd_export *exp)
 {
 	return !!(exp_connect_flags(exp) & OBD_CONNECT_LOCKAHEAD_OLD);
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 8500db5..200422f 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -273,9 +273,41 @@
 #define MDS_MAXREQSIZE		(5 * 1024)	/* >= 4736 */
 
 /**
+ * OST_IO_MAXREQSIZE ~=
+ *	lustre_msg + ptlrpc_body + obdo + obd_ioobj +
+ *	DT_MAX_BRW_PAGES * niobuf_remote
+ *
+ * - single object with 16 pages is 512 bytes
+ * - OST_IO_MAXREQSIZE must be at least 1 page of cookies plus some spillover
+ * - Must be a multiple of 1024
+ */
+#define _OST_MAXREQSIZE_BASE	(sizeof(struct lustre_msg) + \
+				 sizeof(struct ptlrpc_body) + \
+				 sizeof(struct obdo) + \
+				 sizeof(struct obd_ioobj) + \
+				 sizeof(struct niobuf_remote))
+#define _OST_MAXREQSIZE_SUM	(_OST_MAXREQSIZE_BASE + \
+				 sizeof(struct niobuf_remote) * \
+				 (DT_MAX_BRW_PAGES - 1))
+
+/**
  * FIEMAP request can be 4K+ for now
  */
 #define OST_MAXREQSIZE		(16 * 1024)
+#define OST_IO_MAXREQSIZE	max_t(int, OST_MAXREQSIZE, \
+				      (((_OST_MAXREQSIZE_SUM - 1) | (1024 - 1)) + 1))
+
+/* Safe estimate of free space in standard RPC, provides upper limit for # of
+ * bytes of i/o to pack in RPC (skipping bulk transfer).
+ */
+#define OST_SHORT_IO_SPACE	(OST_IO_MAXREQSIZE - _OST_MAXREQSIZE_BASE)
+
+/* Actual size used for short i/o buffer.  Calculation means this:
+ * At least one page (for large PAGE_SIZE), or 16 KiB, but not more
+ * than the available space aligned to a page boundary.
+ */
+#define OBD_MAX_SHORT_IO_BYTES	(min(max(PAGE_SIZE, 16UL * 1024UL), \
+					 OST_SHORT_IO_SPACE & PAGE_MASK))
 
 /* Macro to hide a typecast. */
 #define ptlrpc_req_async_args(req) ((void *)&req->rq_async_args)
@@ -1758,13 +1790,12 @@ static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 	int rc;
 
 	desc = req->rq_bulk;
+	if (!desc)
+		return 0;
 
 	if (req->rq_bulk_deadline > ktime_get_real_seconds())
 		return 1;
 
-	if (!desc)
-		return 0;
-
 	spin_lock(&desc->bd_lock);
 	rc = desc->bd_md_count;
 	spin_unlock(&desc->bd_lock);
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index c3b8849..895c1cb 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -535,6 +535,18 @@ struct osc_page {
 	unsigned long		ops_submit_time;
 };
 
+struct osc_brw_async_args {
+	struct obdo		*aa_oa;
+	int			aa_requested_nob;
+	int			aa_nio_count;
+	u32			aa_page_count;
+	int			aa_resends;
+	struct brw_page		**aa_ppga;
+	struct client_obd	*aa_cli;
+	struct list_head	aa_oaps;
+	struct list_head	aa_exts;
+};
+
 extern struct kmem_cache *osc_lock_kmem;
 extern struct kmem_cache *osc_object_kmem;
 extern struct kmem_cache *osc_thread_kmem;
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 57ac618..c255648 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -297,6 +297,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_FIEMAP_KEY;
 extern struct req_msg_field RMF_FIEMAP_VAL;
 extern struct req_msg_field RMF_OST_ID;
+extern struct req_msg_field RMF_SHORT_IO;
 
 /* MGS config read message format */
 extern struct req_msg_field RMF_MGS_CONFIG_BODY;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 62a8ea9..2f586cb 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -248,6 +248,7 @@ struct client_obd {
 	atomic_t		cl_pending_r_pages;
 	u32			cl_max_pages_per_rpc;
 	u32			cl_max_rpcs_in_flight;
+	u32			cl_short_io_bytes;
 	struct obd_histogram    cl_read_rpc_hist;
 	struct obd_histogram    cl_write_rpc_hist;
 	struct obd_histogram    cl_read_page_hist;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b48b23e..12a68873 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -205,7 +205,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_BULK_MBITS | OBD_CONNECT_CKSUM |
 				  OBD_CONNECT_SUBTREE	 |
 				  OBD_CONNECT_MULTIMODRPCS |
-				  OBD_CONNECT_GRANT_PARAM | OBD_CONNECT_FLAGS2;
+				  OBD_CONNECT_GRANT_PARAM |
+				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
 	data->ocd_connect_flags2 = 0;
 
@@ -396,7 +397,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_JOBSTATS	| OBD_CONNECT_LVB_TYPE |
 				  OBD_CONNECT_LAYOUTLOCK  |
 				  OBD_CONNECT_PINGLESS	| OBD_CONNECT_LFSCK |
-				  OBD_CONNECT_BULK_MBITS  | OBD_CONNECT_FLAGS2;
+				  OBD_CONNECT_BULK_MBITS  | OBD_CONNECT_SHORTIO |
+				  OBD_CONNECT_FLAGS2;
 
 	/* The client currently advertises support for OBD_CONNECT_LOCKAHEAD_OLD
 	 * so it can interoperate with an older version of lockahead which was
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 1ff12d55..a9617e5 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1868,3 +1868,58 @@ ssize_t max_pages_per_rpc_store(struct kobject *kobj, struct attribute *attr,
 	return count;
 }
 EXPORT_SYMBOL(max_pages_per_rpc_store);
+
+ssize_t short_io_bytes_show(struct kobject *kobj, struct attribute *attr,
+			    char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &dev->u.cli;
+	int rc;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	rc = sprintf(buf, "%d\n", cli->cl_short_io_bytes);
+	spin_unlock(&cli->cl_loi_list_lock);
+	return rc;
+}
+EXPORT_SYMBOL(short_io_bytes_show);
+
+/* Used to catch people who think they're specifying pages. */
+#define MIN_SHORT_IO_BYTES 64
+
+ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
+			     const char *buffer, size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &dev->u.cli;
+	u32 val;
+	int rc;
+
+	rc = lprocfs_climp_check(dev);
+	if (rc)
+		return rc;
+
+	rc = kstrtouint(buffer, 0, &val);
+	if (rc)
+		goto out;
+
+	if (val > OBD_MAX_SHORT_IO_BYTES || val < MIN_SHORT_IO_BYTES) {
+		rc = -ERANGE;
+		goto out;
+	}
+
+	rc = count;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	if (val > (cli->cl_max_pages_per_rpc << PAGE_SHIFT))
+		rc = -ERANGE;
+	else
+		cli->cl_short_io_bytes = val;
+	spin_unlock(&cli->cl_loi_list_lock);
+
+out:
+	up_read(&dev->u.cli.cl_sem);
+	return rc;
+}
+EXPORT_SYMBOL(short_io_bytes_store);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 2a57982..2f122a2 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -573,7 +573,9 @@ static ssize_t destroys_in_flight_show(struct kobject *kobj,
 		       atomic_read(&obd->u.cli.cl_destroy_in_flight));
 }
 LUSTRE_RO_ATTR(destroys_in_flight);
+
 LUSTRE_RW_ATTR(max_pages_per_rpc);
+LUSTRE_RW_ATTR(short_io_bytes);
 
 static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
@@ -807,6 +809,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_max_dirty_mb.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
+	&lustre_attr_short_io_bytes.attr,
 	&lustre_attr_resend_count.attr,
 	&lustre_attr_ost_conn_uuid.attr,
 	NULL,
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 4e41b26..836cb14 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -858,17 +858,28 @@ void osc_lru_unreserve(struct client_obd *cli, unsigned long npages)
  * are likely from the same page zone.
  */
 static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
+					    struct osc_brw_async_args *aa,
 					    int factor)
 {
-	int page_count = desc->bd_iov_count;
+	int page_count;
 	pg_data_t *last = NULL;
 	int count = 0;
 	int i;
 
-	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+	if (desc) {
+		LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
+		page_count = desc->bd_iov_count;
+	} else {
+		page_count = aa->aa_page_count;
+	}
 
 	for (i = 0; i < page_count; i++) {
-		pg_data_t *pgdat = page_pgdat(BD_GET_KIOV(desc, i).bv_page);
+		pg_data_t *pgdat;
+
+		if (desc)
+			pgdat = page_pgdat(BD_GET_KIOV(desc, i).bv_page);
+		else
+			pgdat = page_pgdat(aa->aa_ppga[i]->pg);
 
 		if (likely(pgdat == last)) {
 			++count;
@@ -887,14 +898,16 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 		mod_node_page_state(last, NR_UNSTABLE_NFS, factor * count);
 }
 
-static inline void add_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
+static inline void add_unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
+						struct osc_brw_async_args *aa)
 {
-	unstable_page_accounting(desc, 1);
+	unstable_page_accounting(desc, aa, 1);
 }
 
-static inline void dec_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
+static inline void dec_unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
+						struct osc_brw_async_args *aa)
 {
-	unstable_page_accounting(desc, -1);
+	unstable_page_accounting(desc, aa, -1);
 }
 
 /**
@@ -910,13 +923,20 @@ static inline void dec_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
  */
 void osc_dec_unstable_pages(struct ptlrpc_request *req)
 {
+	struct osc_brw_async_args *aa = (void *)&req->rq_async_args;
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	int page_count = desc->bd_iov_count;
+	int page_count;
 	long unstable_count;
 
+	if (desc)
+		page_count = desc->bd_iov_count;
+	else
+		page_count = aa->aa_page_count;
+
 	LASSERT(page_count >= 0);
-	dec_unstable_page_accounting(desc);
+
+	dec_unstable_page_accounting(desc, aa);
 
 	unstable_count = atomic_long_sub_return(page_count,
 						&cli->cl_unstable_count);
@@ -937,15 +957,21 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
  */
 void osc_inc_unstable_pages(struct ptlrpc_request *req)
 {
+	struct osc_brw_async_args *aa = (void *)&req->rq_async_args;
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	long page_count = desc->bd_iov_count;
+	long page_count;
 
 	/* No unstable page tracking */
 	if (!cli->cl_cache || !cli->cl_cache->ccc_unstable_check)
 		return;
 
-	add_unstable_page_accounting(desc);
+	if (desc)
+		page_count = desc->bd_iov_count;
+	else
+		page_count = aa->aa_page_count;
+
+	add_unstable_page_accounting(desc, aa);
 	atomic_long_add(page_count, &cli->cl_unstable_count);
 	atomic_long_add(page_count, &cli->cl_cache->ccc_unstable_nr);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 33555ed..e164d6a 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -62,18 +62,6 @@
 static unsigned int osc_reqpool_mem_max = 5;
 module_param(osc_reqpool_mem_max, uint, 0444);
 
-struct osc_brw_async_args {
-	struct obdo		*aa_oa;
-	int			aa_requested_nob;
-	int			aa_nio_count;
-	u32			aa_page_count;
-	int			aa_resends;
-	struct brw_page		**aa_ppga;
-	struct client_obd	*aa_cli;
-	struct list_head	aa_oaps;
-	struct list_head	aa_exts;
-};
-
 struct osc_async_args {
 	struct obd_info		*aa_oi;
 };
@@ -1010,7 +998,8 @@ static int check_write_rcs(struct ptlrpc_request *req,
 		}
 	}
 
-	if (req->rq_bulk->bd_nob_transferred != requested_nob) {
+	if (req->rq_bulk &&
+	    req->rq_bulk->bd_nob_transferred != requested_nob) {
 		CERROR("Unexpected # bytes transferred: %d (requested %d)\n",
 		       req->rq_bulk->bd_nob_transferred, requested_nob);
 		return -EPROTO;
@@ -1111,10 +1100,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	struct ost_body	*body;
 	struct obd_ioobj *ioobj;
 	struct niobuf_remote *niobuf;
-	int niocount, i, requested_nob, opc, rc;
+	int niocount, i, requested_nob, opc, rc, short_io_size = 0;
 	struct osc_brw_async_args *aa;
 	struct req_capsule *pill;
 	struct brw_page *pg_prev;
+	void *short_io_buf;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
@@ -1144,6 +1134,20 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	req_capsule_set_size(pill, &RMF_NIOBUF_REMOTE, RCL_CLIENT,
 			     niocount * sizeof(*niobuf));
 
+	for (i = 0; i < page_count; i++)
+		short_io_size += pga[i]->count;
+
+	/* Check if we can do a short io. */
+	if (!(short_io_size <= cli->cl_short_io_bytes && niocount == 1 &&
+	    imp_connect_shortio(cli->cl_import)))
+		short_io_size = 0;
+
+	req_capsule_set_size(pill, &RMF_SHORT_IO, RCL_CLIENT,
+			     opc == OST_READ ? 0 : short_io_size);
+	if (opc == OST_READ)
+		req_capsule_set_size(pill, &RMF_SHORT_IO, RCL_SERVER,
+				     short_io_size);
+
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, opc);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -1152,11 +1156,18 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	osc_set_io_portal(req);
 
 	ptlrpc_at_set_req_timeout(req);
+
 	/* ask ptlrpc not to resend on EINPROGRESS since BRWs have their own
 	 * retry logic
 	 */
 	req->rq_no_retry_einprogress = 1;
 
+	if (short_io_size != 0) {
+		desc = NULL;
+		short_io_buf = NULL;
+		goto no_bulk;
+	}
+
 	desc = ptlrpc_prep_bulk_imp(
 		req, page_count,
 		cli->cl_import->imp_connect_data.ocd_brw_size >> LNET_MTU_BITS,
@@ -1169,7 +1180,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		goto out;
 	}
 	/* NB request now owns desc and will free it when it gets freed */
-
+no_bulk:
 	body = req_capsule_client_get(pill, &RMF_OST_BODY);
 	ioobj = req_capsule_client_get(pill, &RMF_OBD_IOOBJ);
 	niobuf = req_capsule_client_get(pill, &RMF_NIOBUF_REMOTE);
@@ -1185,7 +1196,26 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	 * "max - 1" for old client compatibility sending "0", and also so the
 	 * the actual maximum is a power-of-two number, not one less. LU-1431
 	 */
-	ioobj_max_brw_set(ioobj, desc->bd_md_max_brw);
+	if (desc)
+		ioobj_max_brw_set(ioobj, desc->bd_md_max_brw);
+	else /* short i/o */
+		ioobj_max_brw_set(ioobj, 0);
+
+	if (short_io_size != 0) {
+		if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
+			body->oa.o_valid |= OBD_MD_FLFLAGS;
+			body->oa.o_flags = 0;
+		}
+		body->oa.o_flags |= OBD_FL_SHORT_IO;
+		CDEBUG(D_CACHE, "Using short io for data transfer, size = %d\n",
+		       short_io_size);
+		if (opc == OST_WRITE) {
+			short_io_buf = req_capsule_client_get(pill,
+							      &RMF_SHORT_IO);
+			LASSERT(short_io_buf);
+		}
+	}
+
 	LASSERT(page_count > 0);
 	pg_prev = pga[0];
 	for (requested_nob = i = 0; i < page_count; i++, niobuf++) {
@@ -1210,7 +1240,17 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		LASSERT((pga[0]->flag & OBD_BRW_SRVLOCK) ==
 			(pg->flag & OBD_BRW_SRVLOCK));
 
-		desc->bd_frag_ops->add_kiov_frag(desc, pg->pg, poff, pg->count);
+		if (short_io_size != 0 && opc == OST_WRITE) {
+			unsigned char *ptr = kmap_atomic(pg->pg);
+
+			LASSERT(short_io_size >= requested_nob + pg->count);
+			memcpy(short_io_buf + requested_nob, ptr + poff,
+			       pg->count);
+			kunmap_atomic(ptr);
+		} else if (short_io_size == 0) {
+			desc->bd_frag_ops->add_kiov_frag(desc, pg->pg, poff,
+							 pg->count);
+		}
 		requested_nob += pg->count;
 
 		if (i > 0 && can_merge_pages(pg_prev, pg)) {
@@ -1477,7 +1517,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		}
 		LASSERT(req->rq_bulk->bd_nob == aa->aa_requested_nob);
 
-		if (sptlrpc_cli_unwrap_bulk_write(req, req->rq_bulk))
+		if (req->rq_bulk &&
+		    sptlrpc_cli_unwrap_bulk_write(req, req->rq_bulk))
 			return -EAGAIN;
 
 		if ((aa->aa_oa->o_valid & OBD_MD_FLCKSUM) && client_cksum &&
@@ -1493,8 +1534,14 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	/* The rest of this function executes only for OST_READs */
 
-	/* if unwrap_bulk failed, return -EAGAIN to retry */
-	rc = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk, rc);
+	if (!req->rq_bulk) {
+		rc = req_capsule_get_size(&req->rq_pill, &RMF_SHORT_IO,
+					  RCL_SERVER);
+		LASSERT(rc == req->rq_status);
+	} else {
+		/* if unwrap_bulk failed, return -EAGAIN to retry */
+		rc = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk, rc);
+	}
 	if (rc < 0) {
 		rc = -EAGAIN;
 		goto out;
@@ -1506,12 +1553,42 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		return -EPROTO;
 	}
 
-	if (rc != req->rq_bulk->bd_nob_transferred) {
+	if (req->rq_bulk && rc != req->rq_bulk->bd_nob_transferred) {
 		CERROR("Unexpected rc %d (%d transferred)\n",
 		       rc, req->rq_bulk->bd_nob_transferred);
 		return -EPROTO;
 	}
 
+	if (!req->rq_bulk) {
+		/* short io */
+		int nob, pg_count, i = 0;
+		unsigned char *buf;
+
+		CDEBUG(D_CACHE, "Using short io read, size %d\n", rc);
+		pg_count = aa->aa_page_count;
+		buf = req_capsule_server_sized_get(&req->rq_pill, &RMF_SHORT_IO,
+						   rc);
+		nob = rc;
+
+		while (nob > 0 && pg_count > 0) {
+			int count = aa->aa_ppga[i]->count > nob ?
+				    nob : aa->aa_ppga[i]->count;
+			unsigned char *ptr;
+
+			CDEBUG(D_CACHE, "page %p count %d\n",
+			       aa->aa_ppga[i]->pg, count);
+			ptr = kmap_atomic(aa->aa_ppga[i]->pg);
+			memcpy(ptr + (aa->aa_ppga[i]->off & ~PAGE_MASK), buf,
+			       count);
+			kunmap_atomic((void *) ptr);
+
+			buf += count;
+			nob -= count;
+			i++;
+			pg_count--;
+		}
+	}
+
 	if (rc < aa->aa_requested_nob)
 		handle_short_read(rc, aa->aa_page_count, aa->aa_ppga);
 
@@ -1529,7 +1606,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 						 aa->aa_ppga, OST_READ,
 						 cksum_type);
 
-		if (peer->nid != req->rq_bulk->bd_sender) {
+		if (req->rq_bulk &&
+		    peer->nid != req->rq_bulk->bd_sender) {
 			via = " via ";
 			router = libcfs_nid2str(req->rq_bulk->bd_sender);
 		}
@@ -1705,6 +1783,7 @@ static int brw_interpret(const struct lu_env *env,
 	struct osc_extent *ext;
 	struct osc_extent *tmp;
 	struct client_obd *cli = aa->aa_cli;
+	unsigned long transferred = 0;
 
 	rc = osc_brw_fini_request(req, rc);
 	CDEBUG(D_INODE, "request %p aa %p rc %d\n", req, aa, rc);
@@ -1798,8 +1877,12 @@ static int brw_interpret(const struct lu_env *env,
 	LASSERT(list_empty(&aa->aa_exts));
 	LASSERT(list_empty(&aa->aa_oaps));
 
+	transferred = (!req->rq_bulk ? /* short io */
+		       aa->aa_requested_nob :
+		       req->rq_bulk->bd_nob_transferred);
+
 	osc_release_ppga(aa->aa_ppga, aa->aa_page_count);
-	ptlrpc_lprocfs_brw(req, req->rq_bulk->bd_nob_transferred);
+	ptlrpc_lprocfs_brw(req, transferred);
 
 	spin_lock(&cli->cl_loi_list_lock);
 	/* We need to decrement before osc_ap_completion->osc_wake_cache_waiters
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index da315f7..b6476bc 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -574,12 +574,14 @@
 	&RMF_OST_BODY,
 	&RMF_OBD_IOOBJ,
 	&RMF_NIOBUF_REMOTE,
-	&RMF_CAPA1
+	&RMF_CAPA1,
+	&RMF_SHORT_IO
 };
 
 static const struct req_msg_field *ost_brw_read_server[] = {
 	&RMF_PTLRPC_BODY,
-	&RMF_OST_BODY
+	&RMF_OST_BODY,
+	&RMF_SHORT_IO
 };
 
 static const struct req_msg_field *ost_brw_write_server[] = {
@@ -1102,6 +1104,10 @@ struct req_msg_field RMF_FIEMAP_VAL =
 	DEFINE_MSGF("fiemap", 0, -1, lustre_swab_fiemap, NULL);
 EXPORT_SYMBOL(RMF_FIEMAP_VAL);
 
+struct req_msg_field RMF_SHORT_IO =
+	DEFINE_MSGF("short_io", 0, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_SHORT_IO);
+
 struct req_msg_field RMF_HSM_USER_STATE =
 	DEFINE_MSGF("hsm_user_state", 0, sizeof(struct hsm_user_state),
 		    lustre_swab_hsm_user_state, NULL);
-- 
1.8.3.1
