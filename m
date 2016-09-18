From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:31 -0400
Subject: [lustre-devel] [PATCH 092/124] staging: lustre: ptlrpc: fix
	comparison between signed and unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-93-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change return type and size argiments of lustre_msg_hdr_size(),
lustre_msg_buf{len,count}() and req_capsule_*_size() to __u32.
Change type of req_format->rf_idx and req_format->rf_fields.nr
to size_t. Also return zero for incorrect message magic instead
of -EINVAL. This will be more robust because of few of them after
LASSERTF(0, "...") and will not be returned. In the rest places
it return zero size instead of huge number after implicit
unsigned conversion.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12475
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   34 ++++----
 .../lustre/lustre/include/lustre_req_layout.h      |   20 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   83 ++++++++++----------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   62 +++++++--------
 5 files changed, 101 insertions(+), 102 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 531c628..21e2267 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2616,9 +2616,9 @@ int ptlrpc_reconnect_import(struct obd_import *imp);
  * @{
  */
 int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			 int index);
+			 u32 index);
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
-			    int index);
+			    u32 index);
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
 int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len);
 
@@ -2637,27 +2637,27 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 		      unsigned int newlen, int move_data);
 void lustre_free_reply_state(struct ptlrpc_reply_state *rs);
 int __lustre_unpack_msg(struct lustre_msg *m, int len);
-int lustre_msg_hdr_size(__u32 magic, int count);
-int lustre_msg_size(__u32 magic, int count, __u32 *lengths);
-int lustre_msg_size_v2(int count, __u32 *lengths);
-int lustre_packed_msg_size(struct lustre_msg *msg);
-int lustre_msg_early_size(void);
-void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, int n, int min_size);
-void *lustre_msg_buf(struct lustre_msg *m, int n, int minlen);
-int lustre_msg_buflen(struct lustre_msg *m, int n);
-int lustre_msg_bufcount(struct lustre_msg *m);
-char *lustre_msg_string(struct lustre_msg *m, int n, int max_len);
+u32 lustre_msg_hdr_size(__u32 magic, u32 count);
+u32 lustre_msg_size(__u32 magic, int count, __u32 *lengths);
+u32 lustre_msg_size_v2(int count, __u32 *lengths);
+u32 lustre_packed_msg_size(struct lustre_msg *msg);
+u32 lustre_msg_early_size(void);
+void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size);
+void *lustre_msg_buf(struct lustre_msg *m, u32 n, u32 minlen);
+u32 lustre_msg_buflen(struct lustre_msg *m, u32 n);
+u32 lustre_msg_bufcount(struct lustre_msg *m);
+char *lustre_msg_string(struct lustre_msg *m, u32 n, u32 max_len);
 __u32 lustre_msghdr_get_flags(struct lustre_msg *msg);
 void lustre_msghdr_set_flags(struct lustre_msg *msg, __u32 flags);
 __u32 lustre_msg_get_flags(struct lustre_msg *msg);
-void lustre_msg_add_flags(struct lustre_msg *msg, int flags);
-void lustre_msg_set_flags(struct lustre_msg *msg, int flags);
-void lustre_msg_clear_flags(struct lustre_msg *msg, int flags);
+void lustre_msg_add_flags(struct lustre_msg *msg, u32 flags);
+void lustre_msg_set_flags(struct lustre_msg *msg, u32 flags);
+void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags);
 __u32 lustre_msg_get_op_flags(struct lustre_msg *msg);
-void lustre_msg_add_op_flags(struct lustre_msg *msg, int flags);
+void lustre_msg_add_op_flags(struct lustre_msg *msg, u32 flags);
 struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg);
 __u32 lustre_msg_get_type(struct lustre_msg *msg);
-void lustre_msg_add_version(struct lustre_msg *msg, int version);
+void lustre_msg_add_version(struct lustre_msg *msg, u32 version);
 __u32 lustre_msg_get_opc(struct lustre_msg *msg);
 __u64 lustre_msg_get_last_committed(struct lustre_msg *msg);
 __u64 *lustre_msg_get_versions(struct lustre_msg *msg);
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index ca0e683..a13558e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -76,7 +76,8 @@ void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
 void req_capsule_fini(struct req_capsule *pill);
 
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt);
-int req_capsule_filled_sizes(struct req_capsule *pill, enum req_location loc);
+size_t req_capsule_filled_sizes(struct req_capsule *pill,
+				enum req_location loc);
 int  req_capsule_server_pack(struct req_capsule *pill);
 
 void *req_capsule_client_get(struct req_capsule *pill,
@@ -86,27 +87,27 @@ void *req_capsule_client_swab_get(struct req_capsule *pill,
 				  void *swabber);
 void *req_capsule_client_sized_get(struct req_capsule *pill,
 				   const struct req_msg_field *field,
-				   int len);
+				   u32 len);
 void *req_capsule_server_get(struct req_capsule *pill,
 			     const struct req_msg_field *field);
 void *req_capsule_server_sized_get(struct req_capsule *pill,
 				   const struct req_msg_field *field,
-				   int len);
+				   u32 len);
 void *req_capsule_server_swab_get(struct req_capsule *pill,
 				  const struct req_msg_field *field,
 				  void *swabber);
 void *req_capsule_server_sized_swab_get(struct req_capsule *pill,
 					const struct req_msg_field *field,
-					int len, void *swabber);
+					u32 len, void *swabber);
 
 void req_capsule_set_size(struct req_capsule *pill,
 			  const struct req_msg_field *field,
-			  enum req_location loc, int size);
-int req_capsule_get_size(const struct req_capsule *pill,
+			  enum req_location loc, u32 size);
+u32 req_capsule_get_size(const struct req_capsule *pill,
 			 const struct req_msg_field *field,
 			 enum req_location loc);
-int req_capsule_msg_size(struct req_capsule *pill, enum req_location loc);
-int req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
+u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc);
+u32 req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
 			 enum req_location loc);
 void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt);
 
@@ -115,8 +116,7 @@ int req_capsule_has_field(const struct req_capsule *pill,
 			  enum req_location loc);
 void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
-			unsigned int newlen,
-			enum req_location loc);
+			u32 newlen, enum req_location loc);
 int  req_layout_init(void);
 void req_layout_fini(void);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 582de52..35ba6f1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -561,7 +561,7 @@ static inline int ldlm_capsule_handles_avail(struct req_capsule *pill,
 					     enum req_location loc,
 					     int off)
 {
-	int size = req_capsule_msg_size(pill, loc);
+	u32 size = req_capsule_msg_size(pill, loc);
 
 	return ldlm_req_handles_avail(size, off);
 }
@@ -570,7 +570,7 @@ static inline int ldlm_format_handles_avail(struct obd_import *imp,
 					    const struct req_format *fmt,
 					    enum req_location loc, int off)
 {
-	int size = req_capsule_fmt_size(imp->imp_msg_magic, fmt, loc);
+	u32 size = req_capsule_fmt_size(imp->imp_msg_magic, fmt, loc);
 
 	return ldlm_req_handles_avail(size, off);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 101ac87..839ef3e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1113,9 +1113,9 @@ EXPORT_SYMBOL(RMF_SWAP_LAYOUTS);
 
 struct req_format {
 	const char *rf_name;
-	int rf_idx;
+	size_t rf_idx;
 	struct {
-		int nr;
+		size_t nr;
 		const struct req_msg_field **d;
 	} rf_fields[RCL_NR];
 };
@@ -1555,9 +1555,9 @@ EXPORT_SYMBOL(RQF_OST_GET_INFO_FIEMAP);
  */
 int req_layout_init(void)
 {
-	int i;
-	int j;
-	int k;
+	size_t i;
+	size_t j;
+	size_t k;
 	struct req_format *rf = NULL;
 
 	for (i = 0; i < ARRAY_SIZE(req_formats); ++i) {
@@ -1599,7 +1599,7 @@ EXPORT_SYMBOL(req_layout_fini);
  */
 static void req_capsule_init_area(struct req_capsule *pill)
 {
-	int i;
+	size_t i;
 
 	for (i = 0; i < ARRAY_SIZE(pill->rc_area[RCL_CLIENT]); i++) {
 		pill->rc_area[RCL_CLIENT][i] = -1;
@@ -1650,8 +1650,7 @@ EXPORT_SYMBOL(req_capsule_fini);
 
 static int __req_format_is_sane(const struct req_format *fmt)
 {
-	return
-		0 <= fmt->rf_idx && fmt->rf_idx < ARRAY_SIZE(req_formats) &&
+	return fmt->rf_idx < ARRAY_SIZE(req_formats) &&
 		req_formats[fmt->rf_idx] == fmt;
 }
 
@@ -1685,11 +1684,11 @@ EXPORT_SYMBOL(req_capsule_set);
  * variable-sized fields.  The field sizes come from the declared \a rmf_size
  * field of a \a pill's \a rc_fmt's RMF's.
  */
-int req_capsule_filled_sizes(struct req_capsule *pill,
-			     enum req_location loc)
+size_t req_capsule_filled_sizes(struct req_capsule *pill,
+				enum req_location loc)
 {
 	const struct req_format *fmt = pill->rc_fmt;
-	int i;
+	size_t i;
 
 	for (i = 0; i < fmt->rf_fields[loc].nr; ++i) {
 		if (pill->rc_area[loc][i] == -1) {
@@ -1744,11 +1743,11 @@ EXPORT_SYMBOL(req_capsule_server_pack);
  * Returns the PTLRPC request or reply (\a loc) buffer offset of a \a pill
  * corresponding to the given RMF (\a field).
  */
-static int __req_capsule_offset(const struct req_capsule *pill,
+static u32 __req_capsule_offset(const struct req_capsule *pill,
 				const struct req_msg_field *field,
 				enum req_location loc)
 {
-	int offset;
+	u32 offset;
 
 	offset = field->rmf_offset[pill->rc_fmt->rf_idx][loc];
 	LASSERTF(offset > 0, "%s:%s, off=%d, loc=%d\n", pill->rc_fmt->rf_name,
@@ -1852,10 +1851,10 @@ static void *__req_capsule_get(struct req_capsule *pill,
 	const struct req_format *fmt;
 	struct lustre_msg *msg;
 	void *value;
-	int len;
-	int offset;
+	u32 len;
+	u32 offset;
 
-	void *(*getter)(struct lustre_msg *m, int n, int minlen);
+	void *(*getter)(struct lustre_msg *m, u32 n, u32 minlen);
 
 	static const char *rcl_names[RCL_NR] = {
 		[RCL_CLIENT] = "client",
@@ -1882,20 +1881,20 @@ static void *__req_capsule_get(struct req_capsule *pill,
 		 */
 		len = lustre_msg_buflen(msg, offset);
 		if ((len % field->rmf_size) != 0) {
-			CERROR("%s: array field size mismatch %d modulo %d != 0 (%d)\n",
+			CERROR("%s: array field size mismatch %d modulo %u != 0 (%d)\n",
 			       field->rmf_name, len, field->rmf_size, loc);
 			return NULL;
 		}
 	} else if (pill->rc_area[loc][offset] != -1) {
 		len = pill->rc_area[loc][offset];
 	} else {
-		len = max(field->rmf_size, 0);
+		len = max_t(typeof(field->rmf_size), field->rmf_size, 0);
 	}
 	value = getter(msg, offset, len);
 
 	if (!value) {
 		DEBUG_REQ(D_ERROR, pill->rc_req,
-			  "Wrong buffer for field `%s' (%d of %d) in format `%s': %d vs. %d (%s)\n",
+			  "Wrong buffer for field `%s' (%u of %u) in format `%s': %u vs. %u (%s)\n",
 			  field->rmf_name, offset, lustre_msg_bufcount(msg),
 			  fmt->rf_name, lustre_msg_buflen(msg, offset), len,
 			  rcl_names[loc]);
@@ -1941,7 +1940,7 @@ EXPORT_SYMBOL(req_capsule_client_swab_get);
  */
 void *req_capsule_client_sized_get(struct req_capsule *pill,
 				   const struct req_msg_field *field,
-				   int len)
+				   u32 len)
 {
 	req_capsule_set_size(pill, field, RCL_CLIENT, len);
 	return __req_capsule_get(pill, field, RCL_CLIENT, NULL, 0);
@@ -1982,7 +1981,7 @@ EXPORT_SYMBOL(req_capsule_server_swab_get);
  */
 void *req_capsule_server_sized_get(struct req_capsule *pill,
 				   const struct req_msg_field *field,
-				   int len)
+				   u32 len)
 {
 	req_capsule_set_size(pill, field, RCL_SERVER, len);
 	return __req_capsule_get(pill, field, RCL_SERVER, NULL, 0);
@@ -1991,7 +1990,7 @@ EXPORT_SYMBOL(req_capsule_server_sized_get);
 
 void *req_capsule_server_sized_swab_get(struct req_capsule *pill,
 					const struct req_msg_field *field,
-					int len, void *swabber)
+					u32 len, void *swabber)
 {
 	req_capsule_set_size(pill, field, RCL_SERVER, len);
 	return __req_capsule_get(pill, field, RCL_SERVER, swabber, 0);
@@ -2007,23 +2006,25 @@ EXPORT_SYMBOL(req_capsule_server_sized_swab_get);
  */
 void req_capsule_set_size(struct req_capsule *pill,
 			  const struct req_msg_field *field,
-			  enum req_location loc, int size)
+			  enum req_location loc, u32 size)
 {
 	LASSERT(loc == RCL_SERVER || loc == RCL_CLIENT);
 
-	if ((size != field->rmf_size) &&
+	if ((size != (u32)field->rmf_size) &&
 	    (field->rmf_size != -1) &&
 	    !(field->rmf_flags & RMF_F_NO_SIZE_CHECK) &&
 	    (size > 0)) {
+		u32 rmf_size = (u32)field->rmf_size;
+
 		if ((field->rmf_flags & RMF_F_STRUCT_ARRAY) &&
-		    (size % field->rmf_size != 0)) {
-			CERROR("%s: array field size mismatch %d %% %d != 0 (%d)\n",
-			       field->rmf_name, size, field->rmf_size, loc);
+		    (size % rmf_size != 0)) {
+			CERROR("%s: array field size mismatch %u %% %u != 0 (%d)\n",
+			       field->rmf_name, size, rmf_size, loc);
 			LBUG();
 		} else if (!(field->rmf_flags & RMF_F_STRUCT_ARRAY) &&
-		    size < field->rmf_size) {
-			CERROR("%s: field size mismatch %d != %d (%d)\n",
-			       field->rmf_name, size, field->rmf_size, loc);
+			   size < rmf_size) {
+			CERROR("%s: field size mismatch %u != %u (%d)\n",
+			       field->rmf_name, size, rmf_size, loc);
 			LBUG();
 		}
 	}
@@ -2040,7 +2041,7 @@ EXPORT_SYMBOL(req_capsule_set_size);
  * actually sets the size in pill.rc_area[loc][offset], but this function
  * returns the message buflen[offset], maybe we should use another name.
  */
-int req_capsule_get_size(const struct req_capsule *pill,
+u32 req_capsule_get_size(const struct req_capsule *pill,
 			 const struct req_msg_field *field,
 			 enum req_location loc)
 {
@@ -2058,7 +2059,7 @@ EXPORT_SYMBOL(req_capsule_get_size);
  *
  * See also req_capsule_set_size().
  */
-int req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
+u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
 {
 	return lustre_msg_size(pill->rc_req->rq_import->imp_msg_magic,
 			       pill->rc_fmt->rf_fields[loc].nr,
@@ -2073,10 +2074,11 @@ int req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
  * This function should not be used for formats which contain variable size
  * fields.
  */
-int req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
+u32 req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
 			 enum req_location loc)
 {
-	int size, i = 0;
+	size_t i = 0;
+	u32 size;
 
 	/*
 	 * This function should probably LASSERT() that fmt has no fields with
@@ -2086,7 +2088,7 @@ int req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
 	 * we do.
 	 */
 	size = lustre_msg_hdr_size(magic, fmt->rf_fields[loc].nr);
-	if (size < 0)
+	if (!size)
 		return size;
 
 	for (; i < fmt->rf_fields[loc].nr; ++i)
@@ -2118,7 +2120,7 @@ int req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
 void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 {
 	int i;
-	int j;
+	size_t j;
 
 	const struct req_format *old;
 
@@ -2176,7 +2178,7 @@ static int req_capsule_field_present(const struct req_capsule *pill,
 				     const struct req_msg_field *field,
 				     enum req_location loc)
 {
-	int offset;
+	u32 offset;
 
 	LASSERT(loc == RCL_SERVER || loc == RCL_CLIENT);
 	LASSERT(req_capsule_has_field(pill, field, loc));
@@ -2193,12 +2195,11 @@ static int req_capsule_field_present(const struct req_capsule *pill,
  */
 void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
-			unsigned int newlen,
-			enum req_location loc)
+			u32 newlen, enum req_location loc)
 {
 	const struct req_format *fmt;
 	struct lustre_msg *msg;
-	int len;
+	u32 len;
 	int offset;
 
 	fmt = pill->rc_fmt;
@@ -2211,7 +2212,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 
 	msg = __req_msg(pill, loc);
 	len = lustre_msg_buflen(msg, offset);
-	LASSERTF(newlen <= len, "%s:%s, oldlen=%d, newlen=%d\n",
+	LASSERTF(newlen <= len, "%s:%s, oldlen=%u, newlen=%u\n",
 		 fmt->rf_name, field->rmf_name, len, newlen);
 
 	if (loc == RCL_CLIENT)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 87027c5..a1ea0c2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -50,26 +50,26 @@
 
 #include "ptlrpc_internal.h"
 
-static inline int lustre_msg_hdr_size_v2(int count)
+static inline u32 lustre_msg_hdr_size_v2(u32 count)
 {
 	return cfs_size_round(offsetof(struct lustre_msg_v2,
 				       lm_buflens[count]));
 }
 
-int lustre_msg_hdr_size(__u32 magic, int count)
+u32 lustre_msg_hdr_size(__u32 magic, u32 count)
 {
 	switch (magic) {
 	case LUSTRE_MSG_MAGIC_V2:
 		return lustre_msg_hdr_size_v2(count);
 	default:
 		LASSERTF(0, "incorrect message magic: %08x\n", magic);
-		return -EINVAL;
+		return 0;
 	}
 }
 EXPORT_SYMBOL(lustre_msg_hdr_size);
 
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
-			    int index)
+			    u32 index)
 {
 	if (inout)
 		lustre_set_req_swabbed(req, index);
@@ -79,7 +79,7 @@ void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 EXPORT_SYMBOL(ptlrpc_buf_set_swabbed);
 
 int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			 int index)
+			 u32 index)
 {
 	if (inout)
 		return (ptlrpc_req_need_swab(req) &&
@@ -91,9 +91,9 @@ int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 EXPORT_SYMBOL(ptlrpc_buf_need_swab);
 
 /* early reply size */
-int lustre_msg_early_size(void)
+u32 lustre_msg_early_size(void)
 {
-	static int size;
+	static u32 size;
 
 	if (!size) {
 		/* Always reply old ptlrpc_body_v2 to keep interoperability
@@ -111,9 +111,9 @@ int lustre_msg_early_size(void)
 }
 EXPORT_SYMBOL(lustre_msg_early_size);
 
-int lustre_msg_size_v2(int count, __u32 *lengths)
+u32 lustre_msg_size_v2(int count, __u32 *lengths)
 {
-	int size;
+	u32 size;
 	int i;
 
 	size = lustre_msg_hdr_size_v2(count);
@@ -131,7 +131,7 @@ EXPORT_SYMBOL(lustre_msg_size_v2);
  *       target then the first buffer will be stripped because the ptlrpc
  *       data is part of the lustre_msg_v1 header. b=14043
  */
-int lustre_msg_size(__u32 magic, int count, __u32 *lens)
+u32 lustre_msg_size(__u32 magic, int count, __u32 *lens)
 {
 	__u32 size[] = { sizeof(struct ptlrpc_body) };
 
@@ -148,7 +148,7 @@ int lustre_msg_size(__u32 magic, int count, __u32 *lens)
 		return lustre_msg_size_v2(count, lens);
 	default:
 		LASSERTF(0, "incorrect message magic: %08x\n", magic);
-		return -EINVAL;
+		return 0;
 	}
 }
 EXPORT_SYMBOL(lustre_msg_size);
@@ -156,7 +156,7 @@ EXPORT_SYMBOL(lustre_msg_size);
 /* This is used to determine the size of a buffer that was already packed
  * and will correctly handle the different message formats.
  */
-int lustre_packed_msg_size(struct lustre_msg *msg)
+u32 lustre_packed_msg_size(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -378,11 +378,9 @@ int lustre_pack_reply(struct ptlrpc_request *req, int count, __u32 *lens,
 }
 EXPORT_SYMBOL(lustre_pack_reply);
 
-void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, int n, int min_size)
+void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size)
 {
-	int i, offset, buflen, bufcount;
-
-	LASSERT(n >= 0);
+	u32 i, offset, buflen, bufcount;
 
 	bufcount = m->lm_bufcount;
 	if (unlikely(n >= bufcount)) {
@@ -406,7 +404,7 @@ void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, int n, int min_size)
 	return (char *)m + offset;
 }
 
-void *lustre_msg_buf(struct lustre_msg *m, int n, int min_size)
+void *lustre_msg_buf(struct lustre_msg *m, u32 n, u32 min_size)
 {
 	switch (m->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -419,7 +417,7 @@ void *lustre_msg_buf(struct lustre_msg *m, int n, int min_size)
 }
 EXPORT_SYMBOL(lustre_msg_buf);
 
-static int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, int segment,
+static int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, u32 segment,
 				unsigned int newlen, int move_data)
 {
 	char *tail = NULL, *newpos;
@@ -647,7 +645,7 @@ int lustre_unpack_rep_ptlrpc_body(struct ptlrpc_request *req, int offset)
 	}
 }
 
-static inline int lustre_msg_buflen_v2(struct lustre_msg_v2 *m, int n)
+static inline u32 lustre_msg_buflen_v2(struct lustre_msg_v2 *m, u32 n)
 {
 	if (n >= m->lm_bufcount)
 		return 0;
@@ -662,14 +660,14 @@ static inline int lustre_msg_buflen_v2(struct lustre_msg_v2 *m, int n)
  *
  * returns zero for non-existent message indices
  */
-int lustre_msg_buflen(struct lustre_msg *m, int n)
+u32 lustre_msg_buflen(struct lustre_msg *m, u32 n)
 {
 	switch (m->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
 		return lustre_msg_buflen_v2(m, n);
 	default:
 		CERROR("incorrect message magic: %08x\n", m->lm_magic);
-		return -EINVAL;
+		return 0;
 	}
 }
 EXPORT_SYMBOL(lustre_msg_buflen);
@@ -677,23 +675,23 @@ EXPORT_SYMBOL(lustre_msg_buflen);
 /* NB return the bufcount for lustre_msg_v2 format, so if message is packed
  * in V1 format, the result is one bigger. (add struct ptlrpc_body).
  */
-int lustre_msg_bufcount(struct lustre_msg *m)
+u32 lustre_msg_bufcount(struct lustre_msg *m)
 {
 	switch (m->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
 		return m->lm_bufcount;
 	default:
 		CERROR("incorrect message magic: %08x\n", m->lm_magic);
-		return -EINVAL;
+		return 0;
 	}
 }
 EXPORT_SYMBOL(lustre_msg_bufcount);
 
-char *lustre_msg_string(struct lustre_msg *m, int index, int max_len)
+char *lustre_msg_string(struct lustre_msg *m, u32 index, u32 max_len)
 {
 	/* max_len == 0 means the string should fill the buffer */
 	char *str;
-	int slen, blen;
+	u32 slen, blen;
 
 	switch (m->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -734,8 +732,8 @@ char *lustre_msg_string(struct lustre_msg *m, int index, int max_len)
 EXPORT_SYMBOL(lustre_msg_string);
 
 /* Wrap up the normal fixed length cases */
-static inline void *__lustre_swab_buf(struct lustre_msg *msg, int index,
-				      int min_size, void *swabber)
+static inline void *__lustre_swab_buf(struct lustre_msg *msg, u32 index,
+				      u32 min_size, void *swabber)
 {
 	void *ptr = NULL;
 
@@ -804,7 +802,7 @@ __u32 lustre_msg_get_flags(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_flags);
 
-void lustre_msg_add_flags(struct lustre_msg *msg, int flags)
+void lustre_msg_add_flags(struct lustre_msg *msg, u32 flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -820,7 +818,7 @@ void lustre_msg_add_flags(struct lustre_msg *msg, int flags)
 }
 EXPORT_SYMBOL(lustre_msg_add_flags);
 
-void lustre_msg_set_flags(struct lustre_msg *msg, int flags)
+void lustre_msg_set_flags(struct lustre_msg *msg, u32 flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -836,7 +834,7 @@ void lustre_msg_set_flags(struct lustre_msg *msg, int flags)
 }
 EXPORT_SYMBOL(lustre_msg_set_flags);
 
-void lustre_msg_clear_flags(struct lustre_msg *msg, int flags)
+void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -870,7 +868,7 @@ __u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_op_flags);
 
-void lustre_msg_add_op_flags(struct lustre_msg *msg, int flags)
+void lustre_msg_add_op_flags(struct lustre_msg *msg, u32 flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -924,7 +922,7 @@ __u32 lustre_msg_get_type(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_type);
 
-void lustre_msg_add_version(struct lustre_msg *msg, int version)
+void lustre_msg_add_version(struct lustre_msg *msg, u32 version)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
-- 
1.7.1
