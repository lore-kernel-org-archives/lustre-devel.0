From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:40 -0400
Subject: [lustre-devel] [PATCH 01/42] lustre: ptlrpc: don't require
 CONFIG_CRYPTO_CRC32
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Don't require CONFIG_CRYPTO_CRC32 to build if not configured,
as it may not be available for all kernels and is easily fixed.

Consolidate the early reply code in sec_plain.c to also call
lustre_msg_calc_cksum() to reduce code duplication.

Fixes: 984ea92e22a8 ("lnet: libcfs: make noise to console if CRC32 is missing")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13127
Lustre-commit: 726897c87c42c ("LU-13127 ptlrpc: don't require CONFIG_CRYPTO_CRC32")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39201
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/Kconfig                      |  3 ---
 fs/lustre/include/lustre_net.h         |  2 +-
 fs/lustre/include/obd.h                |  4 ++--
 fs/lustre/include/obd_cksum.h          | 20 ++++++++++----------
 fs/lustre/obdclass/integrity.c         |  8 ++++----
 fs/lustre/obdclass/obd_cksum.c         |  6 +++---
 fs/lustre/osc/osc_request.c            | 10 +++++-----
 fs/lustre/ptlrpc/pack_generic.c        | 13 +++++++++++--
 fs/lustre/ptlrpc/sec_null.c            | 10 +++++-----
 fs/lustre/ptlrpc/sec_plain.c           | 26 ++++----------------------
 include/uapi/linux/lustre/lustre_idl.h |  2 +-
 11 files changed, 46 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/Kconfig b/fs/lustre/Kconfig
index e2a06bb..bb0e4e7 100644
--- a/fs/lustre/Kconfig
+++ b/fs/lustre/Kconfig
@@ -2,9 +2,6 @@ config LUSTRE_FS
 	tristate "Lustre file system client support"
 	depends on LNET
 	select CRYPTO
-	select CRYPTO_CRC32
-	select CRYPTO_CRC32_PCLMUL if X86
-	select CRYPTO_CRC32C
 	select CRYPTO_MD5
 	select CRYPTO_SHA1
 	select CRYPTO_SHA256
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index dd482bc..d199121 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2103,7 +2103,7 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 timeout_t lustre_msg_get_service_timeout(struct lustre_msg *msg);
 char *lustre_msg_get_jobid(struct lustre_msg *msg);
 u32 lustre_msg_get_cksum(struct lustre_msg *msg);
-u32 lustre_msg_calc_cksum(struct lustre_msg *msg);
+u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf);
 void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
 void lustre_msg_set_type(struct lustre_msg *msg, u32 type);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index cd3abfd..c73aebe 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -338,9 +338,9 @@ struct client_obd {
 	/* supported checksum types that are worked out at connect time */
 	u32			cl_supp_cksum_types;
 	/* checksum algorithm to be used */
-	enum cksum_type		cl_cksum_type;
+	enum cksum_types	cl_cksum_type;
 	/* preferred checksum algorithm to be used */
-	enum cksum_type		cl_preferred_cksum_type;
+	enum cksum_types	cl_preferred_cksum_type;
 
 	/* also protected by the poorly named _loi_list_lock lock above */
 	struct osc_async_rc     cl_ar;
diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index c03d0e6..f7d316b 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -36,9 +36,9 @@
 #include <uapi/linux/lustre/lustre_idl.h>
 
 int obd_t10_cksum_speed(const char *obd_name,
-			enum cksum_type cksum_type);
+			enum cksum_types cksum_type);
 
-static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
+static inline unsigned char cksum_obd2cfs(enum cksum_types cksum_type)
 {
 	switch (cksum_type) {
 	case OBD_CKSUM_CRC32:
@@ -54,9 +54,9 @@ static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 	return 0;
 }
 
-u32 obd_cksum_type_pack(const char *obd_name, enum cksum_type cksum_type);
+u32 obd_cksum_type_pack(const char *obd_name, enum cksum_types cksum_type);
 
-static inline enum cksum_type obd_cksum_type_unpack(u32 o_flags)
+static inline enum cksum_types obd_cksum_type_unpack(u32 o_flags)
 {
 	switch (o_flags & OBD_FL_CKSUM_ALL) {
 	case OBD_FL_CKSUM_CRC32C:
@@ -82,9 +82,9 @@ static inline enum cksum_type obd_cksum_type_unpack(u32 o_flags)
  * 1.8 supported ADLER it is base and not depend on hw
  * Client uses all available local algos
  */
-static inline enum cksum_type obd_cksum_types_supported_client(void)
+static inline enum cksum_types obd_cksum_types_supported_client(void)
 {
-	enum cksum_type ret = OBD_CKSUM_ADLER;
+	enum cksum_types ret = OBD_CKSUM_ADLER;
 
 	CDEBUG(D_INFO, "Crypto hash speed: crc %d, crc32c %d, adler %d\n",
 	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)),
@@ -110,9 +110,9 @@ static inline enum cksum_type obd_cksum_types_supported_client(void)
  * not be the fastest or most efficient algorithm on the server.
  */
 static inline
-enum cksum_type obd_cksum_type_select(const char *obd_name,
-				       enum cksum_type cksum_types,
-				       enum cksum_type preferred)
+enum cksum_types obd_cksum_type_select(const char *obd_name,
+				       enum cksum_types cksum_types,
+				       enum cksum_types preferred)
 {
 	u32 flag;
 
@@ -143,7 +143,7 @@ int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
  * If checksum type is one T10 checksum types, init the csum_fn and sector
  * size. Otherwise, init them to NULL/zero.
  */
-static inline void obd_t10_cksum2dif(enum cksum_type cksum_type,
+static inline void obd_t10_cksum2dif(enum cksum_types cksum_type,
 				     obd_dif_csum_fn **fn, int *sector_size)
 {
 	*fn = NULL;
diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index cbb91ed..7a95a11 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -80,7 +80,7 @@ int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
 EXPORT_SYMBOL(obd_page_dif_generate_buffer);
 
 static int __obd_t10_performance_test(const char *obd_name,
-				      enum cksum_type cksum_type,
+				      enum cksum_types cksum_type,
 				      struct page *data_page,
 				      int repeat_number)
 {
@@ -163,7 +163,7 @@ static int __obd_t10_performance_test(const char *obd_name,
 static int obd_t10_cksum_speeds[OBD_T10_CKSUM_MAX];
 
 static enum obd_t10_cksum_type
-obd_t10_cksum2type(enum cksum_type cksum_type)
+obd_t10_cksum2type(enum cksum_types cksum_type)
 {
 	switch (cksum_type) {
 	case OBD_CKSUM_T10IP512:
@@ -205,7 +205,7 @@ static const char *obd_t10_cksum_name(enum obd_t10_cksum_type index)
  * \param[in] cksum_type	checksum type (OBD_CKSUM_T10*)
  */
 static void obd_t10_performance_test(const char *obd_name,
-				     enum cksum_type cksum_type)
+				     enum cksum_types cksum_type)
 {
 	enum obd_t10_cksum_type index = obd_t10_cksum2type(cksum_type);
 	const int buf_len = max(PAGE_SIZE, 1048576UL);
@@ -255,7 +255,7 @@ static void obd_t10_performance_test(const char *obd_name,
 }
 
 int obd_t10_cksum_speed(const char *obd_name,
-			enum cksum_type cksum_type)
+			enum cksum_types cksum_type)
 {
 	enum obd_t10_cksum_type index = obd_t10_cksum2type(cksum_type);
 
diff --git a/fs/lustre/obdclass/obd_cksum.c b/fs/lustre/obdclass/obd_cksum.c
index 601feb7..e109ab71 100644
--- a/fs/lustre/obdclass/obd_cksum.c
+++ b/fs/lustre/obdclass/obd_cksum.c
@@ -30,9 +30,9 @@
 #include <obd_cksum.h>
 
 /* Server uses algos that perform at 50% or better of the Adler */
-enum cksum_type obd_cksum_types_supported_server(const char *obd_name)
+enum cksum_types obd_cksum_types_supported_server(const char *obd_name)
 {
-	enum cksum_type ret = OBD_CKSUM_ADLER;
+	enum cksum_types ret = OBD_CKSUM_ADLER;
 	int base_speed;
 
 	CDEBUG(D_INFO,
@@ -84,7 +84,7 @@ enum cksum_type obd_cksum_types_supported_server(const char *obd_name)
  *
  * In case multiple algorithms are supported the best one is used.
  */
-u32 obd_cksum_type_pack(const char *obd_name, enum cksum_type cksum_type)
+u32 obd_cksum_type_pack(const char *obd_name, enum cksum_types cksum_type)
 {
 	unsigned int performance = 0, tmp;
 	u32 flag = OBD_FL_CKSUM_ADLER;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 3bbe3d9..1e56ca3 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1275,7 +1275,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 
 static int osc_checksum_bulk(int nob, u32 pg_count,
 			     struct brw_page **pga, int opc,
-			     enum cksum_type cksum_type,
+			     enum cksum_types cksum_type,
 			     u32 *cksum)
 {
 	int i = 0;
@@ -1334,7 +1334,7 @@ static int osc_checksum_bulk(int nob, u32 pg_count,
 }
 
 static int osc_checksum_bulk_rw(const char *obd_name,
-				enum cksum_type cksum_type,
+				enum cksum_types cksum_type,
 				int nob, size_t pg_count,
 				struct brw_page **pga, int opc,
 				u32 *check_sum)
@@ -1641,7 +1641,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			/* store cl_cksum_type in a local variable since
 			 * it can be changed via lprocfs
 			 */
-			enum cksum_type cksum_type = cli->cl_cksum_type;
+			enum cksum_types cksum_type = cli->cl_cksum_type;
 
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0)
 				body->oa.o_flags = 0;
@@ -1790,7 +1790,7 @@ static int check_write_checksum(struct obdo *oa,
 	int sector_size = 0;
 	u32 new_cksum;
 	char *msg;
-	enum cksum_type cksum_type;
+	enum cksum_types cksum_type;
 	int rc;
 
 	if (server_cksum == client_cksum) {
@@ -1996,7 +1996,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		u32 server_cksum = body->oa.o_cksum;
 		char *via = "";
 		char *router = "";
-		enum cksum_type cksum_type;
+		enum cksum_types cksum_type;
 		u32 o_flags = body->oa.o_valid & OBD_MD_FLFLAGS ?
 			body->oa.o_flags : 0;
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 55d9814..cbb65ce 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -41,6 +41,10 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
+#ifndef CONFIG_CRYPTO_CRC32
+#include <linux/crc32.h>
+#endif
+
 #include <uapi/linux/lustre/lustre_fiemap.h>
 
 #include <llog_swab.h>
@@ -1229,18 +1233,23 @@ u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 	}
 }
 
-u32 lustre_msg_calc_cksum(struct lustre_msg *msg)
+u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+		struct ptlrpc_body *pb = lustre_msg_buf_v2(msg, buf, 0);
+		u32 len = lustre_msg_buflen(msg, buf);
 		u32 crc;
+#ifdef CONFIG_CRYPTO_CRC32
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32, (unsigned char *)pb,
 				       lustre_msg_buflen(msg,
 							 MSG_PTLRPC_BODY_OFF),
 				       NULL, 0, (unsigned char *)&crc, &hsize);
+#else
+		crc = crc32_le(~(__u32)0, (unsigned char *)pb, len);
+#endif
 		return crc;
 	}
 	default:
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 2eaa788..14058bf 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -100,7 +100,8 @@ int null_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 
 	if (req->rq_early) {
 		cksums = lustre_msg_get_cksum(req->rq_repdata);
-		cksumc = lustre_msg_calc_cksum(req->rq_repmsg);
+		cksumc = lustre_msg_calc_cksum(req->rq_repmsg,
+					       MSG_PTLRPC_BODY_OFF);
 
 		if (cksumc != cksums) {
 			CDEBUG(D_SEC,
@@ -356,18 +357,17 @@ int null_authorize(struct ptlrpc_request *req)
 
 	rs->rs_repbuf->lm_secflvr = SPTLRPC_FLVR_NULL;
 	rs->rs_repdata_len = req->rq_replen;
+	req->rq_reply_off = 0;
 
 	if (likely(req->rq_packed_final)) {
 		if (lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)
 			req->rq_reply_off = lustre_msg_early_size();
-		else
-			req->rq_reply_off = 0;
 	} else {
 		u32 cksum;
 
-		cksum = lustre_msg_calc_cksum(rs->rs_repbuf);
+		cksum = lustre_msg_calc_cksum(rs->rs_repbuf,
+					      MSG_PTLRPC_BODY_OFF);
 		lustre_msg_set_cksum(rs->rs_repbuf, cksum);
-		req->rq_reply_off = 0;
 	}
 
 	return 0;
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index ce72f64..b487968 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -214,7 +214,6 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
 	struct lustre_msg *msg = req->rq_repdata;
 	struct plain_header *phdr;
-	u32 cksum;
 	bool swabbed;
 
 	if (msg->lm_bufcount != PLAIN_PACK_SEGMENTS) {
@@ -248,15 +247,8 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 	}
 
 	if (unlikely(req->rq_early)) {
-		unsigned int hsize = 4;
-
-		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32,
-				       lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF,
-						      0),
-				       lustre_msg_buflen(msg,
-							 PLAIN_PACK_MSG_OFF),
-				       NULL, 0, (unsigned char *)&cksum,
-				       &hsize);
+		u32 cksum = lustre_msg_calc_cksum(msg, PLAIN_PACK_MSG_OFF);
+
 		if (cksum != msg->lm_cksum) {
 			CDEBUG(D_SEC,
 			       "early reply checksum mismatch: %08x != %08x\n",
@@ -863,23 +855,13 @@ int plain_authorize(struct ptlrpc_request *req)
 		phdr->ph_flags |= PLAIN_FL_BULK;
 
 	rs->rs_repdata_len = len;
+	req->rq_reply_off = 0;
 
 	if (likely(req->rq_packed_final)) {
 		if (lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)
 			req->rq_reply_off = plain_at_offset;
-		else
-			req->rq_reply_off = 0;
 	} else {
-		unsigned int hsize = 4;
-
-		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32,
-				       lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF,
-						      0),
-				       lustre_msg_buflen(msg,
-							 PLAIN_PACK_MSG_OFF),
-				       NULL, 0, (unsigned char *)&msg->lm_cksum,
-				       &hsize);
-		req->rq_reply_off = 0;
+		msg->lm_cksum = lustre_msg_calc_cksum(msg, PLAIN_PACK_MSG_OFF);
 	}
 
 	return 0;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2cdc230..fda56d8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -918,7 +918,7 @@ struct obd_connect_data {
  * algorithm and also the OBD_FL_CKSUM* flags, OBD_CKSUM_ALL flag,
  * OBD_FL_CKSUM_ALL flag and potentially OBD_CKSUM_T10_ALL flag.
  */
-enum cksum_type {
+enum cksum_types {
 	OBD_CKSUM_CRC32		= 0x00000001,
 	OBD_CKSUM_ADLER		= 0x00000002,
 	OBD_CKSUM_CRC32C	= 0x00000004,
-- 
1.8.3.1
