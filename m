From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:15 -0400
Subject: [lustre-devel] [PATCH 016/124] staging: lustre: fix comparison
	between signed and unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Cleanup in general headers.
* use size_t in cfs_size_round*()
* make unsigned index and len in lustre_cfg_*()
* make iteration variable the same type as comparing value
* make unsigned pages counters

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5417
Reviewed-on: http://review.whamcloud.com/11327
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   12 ++++----
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |   26 +++++++++----------
 drivers/staging/lustre/lustre/include/lustre_lmv.h |    4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   10 ++++---
 drivers/staging/lustre/lustre/include/obd.h        |   20 +++++++-------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    9 ++++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 +-
 8 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d401ae1..e0e1a5d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -310,13 +310,13 @@ do {							    \
 
 #define MKSTR(ptr) ((ptr)) ? (ptr) : ""
 
-static inline int cfs_size_round4(int val)
+static inline size_t cfs_size_round4(int val)
 {
 	return (val + 3) & (~0x3);
 }
 
 #ifndef HAVE_CFS_SIZE_ROUND
-static inline int cfs_size_round(int val)
+static inline size_t cfs_size_round(int val)
 {
 	return (val + 7) & (~0x7);
 }
@@ -324,17 +324,17 @@ static inline int cfs_size_round(int val)
 #define HAVE_CFS_SIZE_ROUND
 #endif
 
-static inline int cfs_size_round16(int val)
+static inline size_t cfs_size_round16(int val)
 {
 	return (val + 0xf) & (~0xf);
 }
 
-static inline int cfs_size_round32(int val)
+static inline size_t cfs_size_round32(int val)
 {
 	return (val + 0x1f) & (~0x1f);
 }
 
-static inline int cfs_size_round0(int val)
+static inline size_t cfs_size_round0(int val)
 {
 	if (!val)
 		return 0;
@@ -343,7 +343,7 @@ static inline int cfs_size_round0(int val)
 
 static inline size_t cfs_round_strlen(char *fset)
 {
-	return (size_t)cfs_size_round((int)strlen(fset) + 1);
+	return cfs_size_round((int)strlen(fset) + 1);
 }
 
 #define LOGL(var, len, ptr)				       \
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 795d446..b1a8ca5 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -499,7 +499,7 @@ static inline __u64 lprocfs_stats_collector(struct lprocfs_stats *stats,
 					    int idx,
 					    enum lprocfs_fields_flags field)
 {
-	int	      i;
+	unsigned int i;
 	unsigned int  num_cpu;
 	unsigned long flags	= 0;
 	__u64	      ret	= 0;
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 95a0be1..8eb394e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -151,13 +151,11 @@ static inline void lustre_cfg_bufs_reset(struct lustre_cfg_bufs *bufs, char *nam
 		lustre_cfg_bufs_set_string(bufs, 0, name);
 }
 
-static inline void *lustre_cfg_buf(struct lustre_cfg *lcfg, int index)
+static inline void *lustre_cfg_buf(struct lustre_cfg *lcfg, __u32 index)
 {
-	int i;
-	int offset;
-	int bufcount;
-
-	LASSERT(index >= 0);
+	__u32 i;
+	size_t offset;
+	__u32 bufcount;
 
 	bufcount = lcfg->lcfg_bufcount;
 	if (index >= bufcount)
@@ -172,7 +170,7 @@ static inline void *lustre_cfg_buf(struct lustre_cfg *lcfg, int index)
 static inline void lustre_cfg_bufs_init(struct lustre_cfg_bufs *bufs,
 					struct lustre_cfg *lcfg)
 {
-	int i;
+	__u32 i;
 
 	bufs->lcfg_bufcount = lcfg->lcfg_bufcount;
 	for (i = 0; i < bufs->lcfg_bufcount; i++) {
@@ -181,7 +179,7 @@ static inline void lustre_cfg_bufs_init(struct lustre_cfg_bufs *bufs,
 	}
 }
 
-static inline char *lustre_cfg_string(struct lustre_cfg *lcfg, int index)
+static inline char *lustre_cfg_string(struct lustre_cfg *lcfg, __u32 index)
 {
 	char *s;
 
@@ -197,8 +195,8 @@ static inline char *lustre_cfg_string(struct lustre_cfg *lcfg, int index)
 	 * of data.  Try to use the padding first though.
 	 */
 	if (s[lcfg->lcfg_buflens[index] - 1] != '\0') {
-		int last = min((int)lcfg->lcfg_buflens[index],
-			       cfs_size_round(lcfg->lcfg_buflens[index]) - 1);
+		size_t last = min((size_t)lcfg->lcfg_buflens[index],
+				  cfs_size_round(lcfg->lcfg_buflens[index]) - 1);
 		char lost = s[last];
 
 		s[last] = '\0';
@@ -210,10 +208,10 @@ static inline char *lustre_cfg_string(struct lustre_cfg *lcfg, int index)
 	return s;
 }
 
-static inline int lustre_cfg_len(__u32 bufcount, __u32 *buflens)
+static inline __u32 lustre_cfg_len(__u32 bufcount, __u32 *buflens)
 {
-	int i;
-	int len;
+	__u32 i;
+	__u32 len;
 
 	len = LCFG_HDR_SIZE(bufcount);
 	for (i = 0; i < bufcount; i++)
@@ -254,7 +252,7 @@ static inline void lustre_cfg_free(struct lustre_cfg *lcfg)
 	return;
 }
 
-static inline int lustre_cfg_sanity_check(void *buf, int len)
+static inline int lustre_cfg_sanity_check(void *buf, size_t len)
 {
 	struct lustre_cfg *lcfg = (struct lustre_cfg *)buf;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 085e596..5a2fc30 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -55,7 +55,7 @@ struct lmv_stripe_md {
 static inline bool
 lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 {
-	int idx;
+	__u32 idx;
 
 	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
 	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
@@ -92,7 +92,7 @@ static inline void lmv_free_memmd(struct lmv_stripe_md *lsm)
 static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 				  const struct lmv_mds_md_v1 *lmv_src)
 {
-	int i;
+	__u32 i;
 
 	lmv_dst->lmv_magic = le32_to_cpu(lmv_src->lmv_magic);
 	lmv_dst->lmv_stripe_count = le32_to_cpu(lmv_src->lmv_stripe_count);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 6d82998..531c628 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1631,7 +1631,7 @@ static inline bool ptlrpc_nrs_req_can_move(struct ptlrpc_request *req)
 /**
  * Returns 1 if request buffer at offset \a index was already swabbed
  */
-static inline int lustre_req_swabbed(struct ptlrpc_request *req, int index)
+static inline int lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
 	return req->rq_req_swab_mask & (1 << index);
@@ -1640,7 +1640,7 @@ static inline int lustre_req_swabbed(struct ptlrpc_request *req, int index)
 /**
  * Returns 1 if request reply buffer@offset \a index was already swabbed
  */
-static inline int lustre_rep_swabbed(struct ptlrpc_request *req, int index)
+static inline int lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
 	return req->rq_rep_swab_mask & (1 << index);
@@ -1665,7 +1665,8 @@ static inline int ptlrpc_rep_need_swab(struct ptlrpc_request *req)
 /**
  * Mark request buffer@offset \a index that it was already swabbed
  */
-static inline void lustre_set_req_swabbed(struct ptlrpc_request *req, int index)
+static inline void lustre_set_req_swabbed(struct ptlrpc_request *req,
+					  size_t index)
 {
 	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
 	LASSERT((req->rq_req_swab_mask & (1 << index)) == 0);
@@ -1675,7 +1676,8 @@ static inline void lustre_set_req_swabbed(struct ptlrpc_request *req, int index)
 /**
  * Mark request reply buffer@offset \a index that it was already swabbed
  */
-static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req, int index)
+static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
+					  size_t index)
 {
 	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
 	LASSERT((req->rq_rep_swab_mask & (1 << index)) == 0);
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f55e679..37a3acb 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -222,11 +222,11 @@ struct client_obd {
 	struct sptlrpc_flavor    cl_flvr_mgc;   /* fixed flavor of mgc->mgs */
 
 	/* the grant values are protected by loi_list_lock below */
-	long		     cl_dirty_pages;	/* all _dirty_ in pahges */
-	long		     cl_dirty_max_pages;/* allowed w/o rpc */
-	long		     cl_dirty_transit; /* dirty synchronous */
-	long		     cl_avail_grant;   /* bytes of credit for ost */
-	long		     cl_lost_grant;    /* lost credits (trunc) */
+	unsigned long		 cl_dirty_pages;	/* all _dirty_ in pahges */
+	unsigned long		 cl_dirty_max_pages;	/* allowed w/o rpc */
+	unsigned long		 cl_dirty_transit;	/* dirty synchronous */
+	unsigned long		 cl_avail_grant;	/* bytes of credit for ost */
+	unsigned long		 cl_lost_grant;		/* lost credits (trunc) */
 
 	/* since we allocate grant by blocks, we don't know how many grant will
 	 * be used to add a page into cache. As a solution, we reserve maximum
@@ -268,13 +268,13 @@ struct client_obd {
 	struct list_head	       cl_loi_hp_ready_list;
 	struct list_head	       cl_loi_write_list;
 	struct list_head	       cl_loi_read_list;
-	int		      cl_r_in_flight;
-	int		      cl_w_in_flight;
+	__u32			 cl_r_in_flight;
+	__u32			 cl_w_in_flight;
 	/* just a sum of the loi/lop pending numbers to be exported by sysfs */
 	atomic_t	     cl_pending_w_pages;
 	atomic_t	     cl_pending_r_pages;
 	__u32			 cl_max_pages_per_rpc;
-	int		      cl_max_rpcs_in_flight;
+	__u32			 cl_max_rpcs_in_flight;
 	struct obd_histogram     cl_read_rpc_hist;
 	struct obd_histogram     cl_write_rpc_hist;
 	struct obd_histogram     cl_read_page_hist;
@@ -1183,8 +1183,8 @@ static inline void client_adjust_max_dirty(struct client_obd *cli)
 		cli->cl_dirty_max_pages =
 			(OSC_MAX_DIRTY_DEFAULT * 1024 * 1024) >> PAGE_SHIFT;
 	else {
-		long dirty_max = cli->cl_max_rpcs_in_flight *
-				 cli->cl_max_pages_per_rpc;
+		unsigned long dirty_max = cli->cl_max_rpcs_in_flight *
+					  cli->cl_max_pages_per_rpc;
 
 		if (dirty_max > cli->cl_dirty_max_pages)
 			cli->cl_dirty_max_pages = dirty_max;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e44b4fa..5cca2b6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -823,9 +823,10 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		       cli->cl_dirty_pages, cli->cl_dirty_max_pages);
 		oa->o_undirty = 0;
 	} else {
-		long max_in_flight = (cli->cl_max_pages_per_rpc <<
-				      PAGE_SHIFT) *
-				     (cli->cl_max_rpcs_in_flight + 1);
+		unsigned long max_in_flight;
+
+		max_in_flight = (cli->cl_max_pages_per_rpc << PAGE_SHIFT) *
+				(cli->cl_max_rpcs_in_flight + 1);
 		oa->o_undirty = max(cli->cl_dirty_max_pages << PAGE_SHIFT,
 				    max_in_flight);
 	}
@@ -2048,7 +2049,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 	spin_unlock(&cli->cl_loi_list_lock);
 
-	DEBUG_REQ(D_INODE, req, "%d pages, aa %p. now %dr/%dw in flight",
+	DEBUG_REQ(D_INODE, req, "%d pages, aa %p. now %ur/%dw in flight",
 		  page_count, aa, cli->cl_r_in_flight,
 		  cli->cl_w_in_flight);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 102f0aa..03fd5d7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1734,7 +1734,7 @@ EXPORT_SYMBOL(lustre_swab_mgs_target_info);
 
 void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 {
-	int i;
+	__u8 i;
 
 	__swab64s(&entry->mne_version);
 	__swab32s(&entry->mne_instance);
@@ -1823,7 +1823,7 @@ static void lustre_swab_fiemap_extent(struct ll_fiemap_extent *fm_extent)
 
 void lustre_swab_fiemap(struct ll_user_fiemap *fiemap)
 {
-	int i;
+	__u32 i;
 
 	__swab64s(&fiemap->fm_start);
 	__swab64s(&fiemap->fm_length);
-- 
1.7.1
