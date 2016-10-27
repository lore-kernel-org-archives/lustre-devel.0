From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:38 -0400
Subject: [lustre-devel] [PATCH 04/29] staging: lustre: obdclass: variable
	llog chunk size
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Do not use fix LLOG_CHUNK_SIZE (8192 bytes), and
it will get the llog_chunk_size from llog_log_hdr.
Accordingly llog header will be variable too, so
we can enlarge the bitmap in the header, then
have more records in each llog file.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6602
Reviewed-on: http://review.whamcloud.com/14883
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   39 ++++++++++++----
 drivers/staging/lustre/lustre/include/lustre_log.h |    6 +++
 drivers/staging/lustre/lustre/obdclass/llog.c      |   48 +++++++++++--------
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    1 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    8 ++-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   20 ++++++--
 6 files changed, 84 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 5d2f845..e542ce6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3122,13 +3122,6 @@ struct llog_gen_rec {
 	struct llog_rec_tail	lgr_tail;
 };
 
-/* On-disk header structure of each log object, stored in little endian order */
-#define LLOG_CHUNK_SIZE	 8192
-#define LLOG_HEADER_SIZE	(96)
-#define LLOG_BITMAP_BYTES       (LLOG_CHUNK_SIZE - LLOG_HEADER_SIZE)
-
-#define LLOG_MIN_REC_SIZE       (24) /* round(llog_rec_hdr + llog_rec_tail) */
-
 /* flags for the logs */
 enum llog_flag {
 	LLOG_F_ZAP_WHEN_EMPTY	= 0x1,
@@ -3139,6 +3132,15 @@ enum llog_flag {
 	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID,
 };
 
+/* On-disk header structure of each log object, stored in little endian order */
+#define LLOG_MIN_CHUNK_SIZE	8192
+#define LLOG_HEADER_SIZE	(96)	/* sizeof (llog_log_hdr) +
+					 * sizeof(llh_tail) - sizeof(llh_bitmap)
+					 */
+#define LLOG_BITMAP_BYTES	(LLOG_MIN_CHUNK_SIZE - LLOG_HEADER_SIZE)
+#define LLOG_MIN_REC_SIZE	(24)	/* round(llog_rec_hdr + llog_rec_tail) */
+
+/* flags for the logs */
 struct llog_log_hdr {
 	struct llog_rec_hdr     llh_hdr;
 	__s64		   llh_timestamp;
@@ -3150,13 +3152,30 @@ struct llog_log_hdr {
 	/* for a catalog the first plain slot is next to it */
 	struct obd_uuid	 llh_tgtuuid;
 	__u32		   llh_reserved[LLOG_HEADER_SIZE / sizeof(__u32) - 23];
+	/* These fields must always be at the end of the llog_log_hdr.
+	 * Note: llh_bitmap size is variable because llog chunk size could be
+	 * bigger than LLOG_MIN_CHUNK_SIZE, i.e. sizeof(llog_log_hdr) > 8192
+	 * bytes, and the real size is stored in llh_hdr.lrh_len, which means
+	 * llh_tail should only be referred by LLOG_HDR_TAIL().
+	 * But this structure is also used by client/server llog interface
+	 * (see llog_client.c), it will be kept in its original way to avoid
+	 * compatibility issue.
+	 */
 	__u32		   llh_bitmap[LLOG_BITMAP_BYTES / sizeof(__u32)];
 	struct llog_rec_tail    llh_tail;
 } __packed;
 
-#define LLOG_BITMAP_SIZE(llh)  (__u32)((llh->llh_hdr.lrh_len -		\
-					llh->llh_bitmap_offset -	\
-					sizeof(llh->llh_tail)) * 8)
+#undef LLOG_HEADER_SIZE
+#undef LLOG_BITMAP_BYTES
+
+#define LLOG_HDR_BITMAP_SIZE(llh) (__u32)((llh->llh_hdr.lrh_len -	\
+					   llh->llh_bitmap_offset -	\
+					   sizeof(llh->llh_tail)) * 8)
+#define LLOG_HDR_BITMAP(llh)	(__u32 *)((char *)(llh) +		\
+					  (llh)->llh_bitmap_offset)
+#define LLOG_HDR_TAIL(llh)	((struct llog_rec_tail *)((char *)llh + \
+							 llh->llh_hdr.lrh_len - \
+							 sizeof(llh->llh_tail)))
 
 /** log cookies are used to reference a specific log file and a record
  * therein
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 995b266..35e37eb 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -214,6 +214,7 @@ struct llog_handle {
 	spinlock_t		 lgh_hdr_lock; /* protect lgh_hdr data */
 	struct llog_logid	 lgh_id; /* id of this log */
 	struct llog_log_hdr	*lgh_hdr;
+	size_t			 lgh_hdr_size;
 	int			 lgh_last_idx;
 	int			 lgh_cur_idx; /* used during llog_process */
 	__u64			 lgh_cur_offset; /* used during llog_process */
@@ -244,6 +245,11 @@ struct llog_ctxt {
 	struct mutex		 loc_mutex; /* protect loc_imp */
 	atomic_t	     loc_refcount;
 	long		     loc_flags; /* flags, see above defines */
+	/*
+	 * llog chunk size, and llog record size can not be bigger than
+	 * loc_chunk_size
+	 */
+	__u32			loc_chunk_size;
 };
 
 #define LLOG_PROC_BREAK 0x0001
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 43797f1..5c9447e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -80,8 +80,7 @@ static void llog_free_handle(struct llog_handle *loghandle)
 		LASSERT(list_empty(&loghandle->u.phd.phd_entry));
 	else if (loghandle->lgh_hdr->llh_flags & LLOG_F_IS_CAT)
 		LASSERT(list_empty(&loghandle->u.chd.chd_head));
-	LASSERT(sizeof(*loghandle->lgh_hdr) == LLOG_CHUNK_SIZE);
-	kfree(loghandle->lgh_hdr);
+	kvfree(loghandle->lgh_hdr);
 out:
 	kfree(loghandle);
 }
@@ -116,19 +115,21 @@ static int llog_read_header(const struct lu_env *env,
 	if (rc == LLOG_EEMPTY) {
 		struct llog_log_hdr *llh = handle->lgh_hdr;
 
+		/* lrh_len should be initialized in llog_init_handle */
 		handle->lgh_last_idx = 0; /* header is record with index 0 */
 		llh->llh_count = 1;	 /* for the header record */
 		llh->llh_hdr.lrh_type = LLOG_HDR_MAGIC;
-		llh->llh_hdr.lrh_len = LLOG_CHUNK_SIZE;
-		llh->llh_tail.lrt_len = LLOG_CHUNK_SIZE;
+		LASSERT(handle->lgh_ctxt->loc_chunk_size >= LLOG_MIN_CHUNK_SIZE);
+		llh->llh_hdr.lrh_len = handle->lgh_ctxt->loc_chunk_size;
 		llh->llh_hdr.lrh_index = 0;
-		llh->llh_tail.lrt_index = 0;
 		llh->llh_timestamp = ktime_get_real_seconds();
 		if (uuid)
 			memcpy(&llh->llh_tgtuuid, uuid,
 			       sizeof(llh->llh_tgtuuid));
 		llh->llh_bitmap_offset = offsetof(typeof(*llh), llh_bitmap);
-		ext2_set_bit(0, llh->llh_bitmap);
+		ext2_set_bit(0, LLOG_HDR_BITMAP(llh));
+		LLOG_HDR_TAIL(llh)->lrt_len = llh->llh_hdr.lrh_len;
+		LLOG_HDR_TAIL(llh)->lrt_index = llh->llh_hdr.lrh_index;
 		rc = 0;
 	}
 	return rc;
@@ -137,16 +138,19 @@ static int llog_read_header(const struct lu_env *env,
 int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		     int flags, struct obd_uuid *uuid)
 {
+	int chunk_size = handle->lgh_ctxt->loc_chunk_size;
 	enum llog_flag fmt = flags & LLOG_F_EXT_MASK;
 	struct llog_log_hdr	*llh;
 	int			 rc;
 
 	LASSERT(!handle->lgh_hdr);
 
-	llh = kzalloc(sizeof(*llh), GFP_NOFS);
+	LASSERT(chunk_size >= LLOG_MIN_CHUNK_SIZE);
+	llh = libcfs_kvzalloc(sizeof(*llh), GFP_NOFS);
 	if (!llh)
 		return -ENOMEM;
 	handle->lgh_hdr = llh;
+	handle->lgh_hdr_size = chunk_size;
 	/* first assign flags to use llog_client_ops */
 	llh->llh_flags = flags;
 	rc = llog_read_header(env, handle, uuid);
@@ -198,7 +202,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 	llh->llh_flags |= fmt;
 out:
 	if (rc) {
-		kfree(llh);
+		kvfree(llh);
 		handle->lgh_hdr = NULL;
 	}
 	return rc;
@@ -212,15 +216,20 @@ static int llog_process_thread(void *arg)
 	struct llog_log_hdr		*llh = loghandle->lgh_hdr;
 	struct llog_process_cat_data	*cd  = lpi->lpi_catdata;
 	char				*buf;
-	__u64				 cur_offset = LLOG_CHUNK_SIZE;
+	__u64				 cur_offset;
 	__u64				 last_offset;
+	int chunk_size;
 	int				 rc = 0, index = 1, last_index;
 	int				 saved_index = 0;
 	int				 last_called_index = 0;
 
-	LASSERT(llh);
+	if (!llh)
+		return -EINVAL;
+
+	cur_offset = llh->llh_hdr.lrh_len;
+	chunk_size = llh->llh_hdr.lrh_len;
 
-	buf = kzalloc(LLOG_CHUNK_SIZE, GFP_NOFS);
+	buf = libcfs_kvzalloc(chunk_size, GFP_NOFS);
 	if (!buf) {
 		lpi->lpi_rc = -ENOMEM;
 		return 0;
@@ -233,7 +242,7 @@ static int llog_process_thread(void *arg)
 	if (cd && cd->lpcd_last_idx)
 		last_index = cd->lpcd_last_idx;
 	else
-		last_index = LLOG_BITMAP_BYTES * 8 - 1;
+		last_index = LLOG_HDR_BITMAP_SIZE(llh) - 1;
 
 	/* Record is not in this buffer. */
 	if (index > last_index)
@@ -244,7 +253,7 @@ static int llog_process_thread(void *arg)
 
 		/* skip records not set in bitmap */
 		while (index <= last_index &&
-		       !ext2_test_bit(index, llh->llh_bitmap))
+		       !ext2_test_bit(index, LLOG_HDR_BITMAP(llh)))
 			++index;
 
 		LASSERT(index <= last_index + 1);
@@ -255,10 +264,10 @@ static int llog_process_thread(void *arg)
 		       index, last_index);
 
 		/* get the buf with our target record; avoid old garbage */
-		memset(buf, 0, LLOG_CHUNK_SIZE);
+		memset(buf, 0, chunk_size);
 		last_offset = cur_offset;
 		rc = llog_next_block(lpi->lpi_env, loghandle, &saved_index,
-				     index, &cur_offset, buf, LLOG_CHUNK_SIZE);
+				     index, &cur_offset, buf, chunk_size);
 		if (rc)
 			goto out;
 
@@ -267,7 +276,7 @@ static int llog_process_thread(void *arg)
 		 * swabbing is done at the beginning of the loop.
 		 */
 		for (rec = (struct llog_rec_hdr *)buf;
-		     (char *)rec < buf + LLOG_CHUNK_SIZE;
+		     (char *)rec < buf + chunk_size;
 		     rec = llog_rec_hdr_next(rec)) {
 			CDEBUG(D_OTHER, "processing rec 0x%p type %#x\n",
 			       rec, rec->lrh_type);
@@ -285,8 +294,7 @@ static int llog_process_thread(void *arg)
 					goto repeat;
 				goto out; /* no more records */
 			}
-			if (rec->lrh_len == 0 ||
-			    rec->lrh_len > LLOG_CHUNK_SIZE) {
+			if (!rec->lrh_len || rec->lrh_len > chunk_size) {
 				CWARN("invalid length %d in llog record for index %d/%d\n",
 				      rec->lrh_len,
 				      rec->lrh_index, index);
@@ -303,14 +311,14 @@ static int llog_process_thread(void *arg)
 			CDEBUG(D_OTHER,
 			       "lrh_index: %d lrh_len: %d (%d remains)\n",
 			       rec->lrh_index, rec->lrh_len,
-			       (int)(buf + LLOG_CHUNK_SIZE - (char *)rec));
+			       (int)(buf + chunk_size - (char *)rec));
 
 			loghandle->lgh_cur_idx = rec->lrh_index;
 			loghandle->lgh_cur_offset = (char *)rec - (char *)buf +
 						    last_offset;
 
 			/* if set, process the callback on this record */
-			if (ext2_test_bit(index, llh->llh_bitmap)) {
+			if (ext2_test_bit(index, LLOG_HDR_BITMAP(llh))) {
 				rc = lpi->lpi_cb(lpi->lpi_env, loghandle, rec,
 						 lpi->lpi_cbdata);
 				last_called_index = index;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index a4277d6..8574ad4 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -158,6 +158,7 @@ int llog_setup(const struct lu_env *env, struct obd_device *obd,
 	mutex_init(&ctxt->loc_mutex);
 	ctxt->loc_exp = class_export_get(disk_obd->obd_self_export);
 	ctxt->loc_flags = LLOG_CTXT_FLAG_UNINITIALIZED;
+	ctxt->loc_chunk_size = LLOG_MIN_CHUNK_SIZE;
 
 	rc = llog_group_set_ctxt(olg, ctxt, index);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 8c4c1b3..7869092 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -244,7 +244,7 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		__swab32s(&llh->llh_flags);
 		__swab32s(&llh->llh_size);
 		__swab32s(&llh->llh_cat_idx);
-		tail = &llh->llh_tail;
+		tail = LLOG_HDR_TAIL(llh);
 		break;
 	}
 	case LLOG_LOGID_MAGIC:
@@ -290,8 +290,10 @@ static void print_llog_hdr(struct llog_log_hdr *h)
 	CDEBUG(D_OTHER, "\tllh_flags: %#x\n", h->llh_flags);
 	CDEBUG(D_OTHER, "\tllh_size: %#x\n", h->llh_size);
 	CDEBUG(D_OTHER, "\tllh_cat_idx: %#x\n", h->llh_cat_idx);
-	CDEBUG(D_OTHER, "\tllh_tail.lrt_index: %#x\n", h->llh_tail.lrt_index);
-	CDEBUG(D_OTHER, "\tllh_tail.lrt_len: %#x\n", h->llh_tail.lrt_len);
+	CDEBUG(D_OTHER, "\tllh_tail.lrt_index: %#x\n",
+	       LLOG_HDR_TAIL(h)->lrt_index);
+	CDEBUG(D_OTHER, "\tllh_tail.lrt_len: %#x\n",
+	       LLOG_HDR_TAIL(h)->lrt_len);
 }
 
 void lustre_swab_llog_hdr(struct llog_log_hdr *h)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 0f55c01..110d9f5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -287,8 +287,13 @@ static int llog_client_read_header(const struct lu_env *env,
 		goto out;
 	}
 
-	memcpy(handle->lgh_hdr, hdr, sizeof(*hdr));
-	handle->lgh_last_idx = handle->lgh_hdr->llh_tail.lrt_index;
+	if (handle->lgh_hdr_size < hdr->llh_hdr.lrh_len) {
+		rc = -EFAULT;
+		goto out;
+	}
+
+	memcpy(handle->lgh_hdr, hdr, hdr->llh_hdr.lrh_len);
+	handle->lgh_last_idx = LLOG_HDR_TAIL(handle->lgh_hdr)->lrt_index;
 
 	/* sanity checks */
 	llh_hdr = &handle->lgh_hdr->llh_hdr;
@@ -296,9 +301,14 @@ static int llog_client_read_header(const struct lu_env *env,
 		CERROR("bad log header magic: %#x (expecting %#x)\n",
 		       llh_hdr->lrh_type, LLOG_HDR_MAGIC);
 		rc = -EIO;
-	} else if (llh_hdr->lrh_len != LLOG_CHUNK_SIZE) {
-		CERROR("incorrectly sized log header: %#x (expecting %#x)\n",
-		       llh_hdr->lrh_len, LLOG_CHUNK_SIZE);
+	} else if (llh_hdr->lrh_len !=
+		   LLOG_HDR_TAIL(handle->lgh_hdr)->lrt_len ||
+		   (llh_hdr->lrh_len & (llh_hdr->lrh_len - 1)) ||
+		   llh_hdr->lrh_len < LLOG_MIN_CHUNK_SIZE ||
+		   llh_hdr->lrh_len > handle->lgh_hdr_size) {
+		CERROR("incorrectly sized log header: %#x (expecting %#x) (power of two > 8192)\n",
+		       llh_hdr->lrh_len,
+		       LLOG_HDR_TAIL(handle->lgh_hdr)->lrt_len);
 		CERROR("you may need to re-run lconf --write_conf.\n");
 		rc = -EIO;
 	}
-- 
1.7.1
