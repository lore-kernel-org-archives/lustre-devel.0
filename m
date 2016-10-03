From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:07 -0400
Subject: [lustre-devel] [PATCH 11/41] staging: lustre: ptlrpc: Add
	OBD_CONNECT_MULTIMODRPCS flag
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

The new OBD_CONNECT_MULTIMODRPCS connection flag indicates the support
of multiple modify RPCs in parallel. It can be specified by the client
within the connection request and by the server within the connection
reply. The new ocd_maxmodrpcs connection data specifies the maximum modify
RPCs in parallel supported by the server.

To allow the MDS to send the new ocd_maxmodrpcs field, it has been
required to modify RMF_CONNECT_DATA so that its size includes the new
field. This change leads to remove the ocd_connect_data_v1 structure.
Note that the client has been allocating an extra 16*sizeof(__u64) for
the obd_connect_data reply since 2.0 and even in later versions of 1.8)
so there is no problem for the MDS to just send the full reply size.

This patch fixes a bug in __req_capsule_get() since it wasn't checking
RMF_F_NO_SIZE_CHECK when receiving the message. This allows legacy
clients (with version lower that this commit) to send connection
request with ocd_connect_data structure size smaller (actually size is
ocd_connect_data_v1 structure size) than new server ocd_connect_data
structure size.

This patch also fixes a bug in the routine that displays the import's
connect data.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
Reviewed-on: http://review.whamcloud.com/#/c/13960
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   26 ++++---------------
 .../lustre/lustre/obdclass/lprocfs_status.c        |    7 ++++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    5 ++-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    3 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   14 +++++++++-
 5 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4210716..b88807f 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1282,6 +1282,9 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 							 */
 #define OBD_CONNECT_LFSCK	0x40000000000000ULL/* support online LFSCK */
 #define OBD_CONNECT_UNLINK_CLOSE 0x100000000000000ULL/* close file in unlink */
+#define OBD_CONNECT_MULTIMODRPCS 0x200000000000000ULL /* support multiple modify
+						       *  RPCs in parallel
+						       */
 #define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
 
 /* XXX README XXX:
@@ -1313,25 +1316,6 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
  * If we eventually have separate connect data for different types, which we
  * almost certainly will, then perhaps we stick a union in here.
  */
-struct obd_connect_data_v1 {
-	__u64 ocd_connect_flags; /* OBD_CONNECT_* per above */
-	__u32 ocd_version;	 /* lustre release version number */
-	__u32 ocd_grant;	 /* initial cache grant amount (bytes) */
-	__u32 ocd_index;	 /* LOV index to connect to */
-	__u32 ocd_brw_size;	 /* Maximum BRW size in bytes, must be 2^n */
-	__u64 ocd_ibits_known;   /* inode bits this client understands */
-	__u8  ocd_blocksize;     /* log2 of the backend filesystem blocksize */
-	__u8  ocd_inodespace;    /* log2 of the per-inode space consumption */
-	__u16 ocd_grant_extent;  /* per-extent grant overhead, in 1K blocks */
-	__u32 ocd_unused;	/* also fix lustre_swab_connect */
-	__u64 ocd_transno;       /* first transno from client to be replayed */
-	__u32 ocd_group;	 /* MDS group on OST */
-	__u32 ocd_cksum_types;   /* supported checksum algorithms */
-	__u32 ocd_max_easize;    /* How big LOV EA can be on MDS */
-	__u32 ocd_instance;      /* also fix lustre_swab_connect */
-	__u64 ocd_maxbytes;      /* Maximum stripe size in bytes */
-};
-
 struct obd_connect_data {
 	__u64 ocd_connect_flags; /* OBD_CONNECT_* per above */
 	__u32 ocd_version;	 /* lustre release version number */
@@ -1354,7 +1338,9 @@ struct obd_connect_data {
 	 * any field after ocd_maxbytes on the receiver without a valid flag
 	 * may result in out-of-bound memory access and kernel oops.
 	 */
-	__u64 padding1;	  /* added 2.1.0. also fix lustre_swab_connect */
+	__u16 ocd_maxmodrpcs;	/* Maximum modify RPCs in parallel */
+	__u16 padding0;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u32 padding1;		/* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding2;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding3;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding4;	  /* added 2.1.0. also fix lustre_swab_connect */
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 852a5ac..b520c96 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -100,7 +100,7 @@ static const char * const obd_connect_names[] = {
 	"lfsck",
 	"unknown",
 	"unlink_close",
-	"unknown",
+	"multi_mod_rpcs",
 	"dir_stripe",
 	"unknown",
 	NULL
@@ -127,7 +127,7 @@ EXPORT_SYMBOL(obd_connect_flags2str);
 static void obd_connect_data_seqprint(struct seq_file *m,
 				      struct obd_connect_data *ocd)
 {
-	int flags;
+	u64 flags;
 
 	LASSERT(ocd);
 	flags = ocd->ocd_connect_flags;
@@ -172,6 +172,9 @@ static void obd_connect_data_seqprint(struct seq_file *m,
 	if (flags & OBD_CONNECT_MAXBYTES)
 		seq_printf(m, "       max_object_bytes: %llx\n",
 			   ocd->ocd_maxbytes);
+	if (flags & OBD_CONNECT_MULTIMODRPCS)
+		seq_printf(m, "       max_mod_rpcs: %hu\n",
+			   ocd->ocd_maxmodrpcs);
 }
 
 int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 839ef3e..4ea8454 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1874,13 +1874,14 @@ static void *__req_capsule_get(struct req_capsule *pill,
 	getter = (field->rmf_flags & RMF_F_STRING) ?
 		(typeof(getter))lustre_msg_string : lustre_msg_buf;
 
-	if (field->rmf_flags & RMF_F_STRUCT_ARRAY) {
+	if (field->rmf_flags & (RMF_F_STRUCT_ARRAY | RMF_F_NO_SIZE_CHECK)) {
 		/*
 		 * We've already asserted that field->rmf_size > 0 in
 		 * req_layout_init().
 		 */
 		len = lustre_msg_buflen(msg, offset);
-		if ((len % field->rmf_size) != 0) {
+		if (!(field->rmf_flags & RMF_F_NO_SIZE_CHECK) &&
+		    (len % field->rmf_size)) {
 			CERROR("%s: array field size mismatch %d modulo %u != 0 (%d)\n",
 			       field->rmf_name, len, field->rmf_size, loc);
 			return NULL;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 36b86ae..2dc0b79 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1492,6 +1492,9 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 		__swab32s(&ocd->ocd_max_easize);
 	if (ocd->ocd_connect_flags & OBD_CONNECT_MAXBYTES)
 		__swab64s(&ocd->ocd_maxbytes);
+	if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS)
+		__swab16s(&ocd->ocd_maxmodrpcs);
+	CLASSERT(offsetof(typeof(*ocd), padding0));
 	CLASSERT(offsetof(typeof(*ocd), padding1) != 0);
 	CLASSERT(offsetof(typeof(*ocd), padding2) != 0);
 	CLASSERT(offsetof(typeof(*ocd), padding3) != 0);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index cb89bf2..c299099 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -905,9 +905,17 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_connect_data, ocd_maxbytes));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_maxbytes) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_maxbytes));
-	LASSERTF((int)offsetof(struct obd_connect_data, padding1) == 72, "found %lld\n",
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_maxmodrpcs) == 72, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_maxmodrpcs));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_maxmodrpcs) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_maxmodrpcs));
+	LASSERTF((int)offsetof(struct obd_connect_data, padding0) == 74, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, padding0));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding0) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->padding0));
+	LASSERTF((int)offsetof(struct obd_connect_data, padding1) == 76, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_connect_data, padding1));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding1) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding1) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_connect_data *)0)->padding1));
 	LASSERTF((int)offsetof(struct obd_connect_data, padding2) == 80, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_connect_data, padding2));
@@ -1075,6 +1083,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_LFSCK);
 	LASSERTF(OBD_CONNECT_UNLINK_CLOSE == 0x100000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_UNLINK_CLOSE);
+	LASSERTF(OBD_CONNECT_MULTIMODRPCS == 0x200000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_MULTIMODRPCS);
 	LASSERTF(OBD_CONNECT_DIR_STRIPE == 0x400000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_DIR_STRIPE);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
-- 
1.7.1
