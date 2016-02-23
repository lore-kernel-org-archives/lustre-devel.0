From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:42 -0500
Subject: [lustre-devel] [PATCH 04/56] stagig/lustre: Get rid of cksum_type_t
	typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum cksum_type

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h |  4 ++--
 drivers/staging/lustre/lustre/include/obd.h               |  2 +-
 drivers/staging/lustre/lustre/include/obd_cksum.h         | 12 ++++++------
 drivers/staging/lustre/lustre/osc/osc_request.c           | 10 +++++-----
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0e3bac6..0f37b61 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1408,11 +1408,11 @@ void lustre_swab_connect(struct obd_connect_data *ocd);
  * Please update DECLARE_CKSUM_NAME/OBD_CKSUM_ALL in obd.h when adding a new
  * algorithm and also the OBD_FL_CKSUM* flags.
  */
-typedef enum {
+enum cksum_type {
 	OBD_CKSUM_CRC32  = 0x00000001,
 	OBD_CKSUM_ADLER  = 0x00000002,
 	OBD_CKSUM_CRC32C = 0x00000004,
-} cksum_type_t;
+};
 
 /*
  *   OST requests: OBDO & OBD request records
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d6e5a17..09f1a5b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -339,7 +339,7 @@ struct client_obd {
 	/* supported checksum types that are worked out at connect time */
 	__u32		    cl_supp_cksum_types;
 	/* checksum algorithm to be used */
-	cksum_type_t	     cl_cksum_type;
+	enum cksum_type	     cl_cksum_type;
 
 	/* also protected by the poorly named _loi_list_lock lock above */
 	struct osc_async_rc      cl_ar;
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index 01db604..d61b4db 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -37,7 +37,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 
-static inline unsigned char cksum_obd2cfs(cksum_type_t cksum_type)
+static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 {
 	switch (cksum_type) {
 	case OBD_CKSUM_CRC32:
@@ -64,7 +64,7 @@ static inline unsigned char cksum_obd2cfs(cksum_type_t cksum_type)
  * because that is supported by all clients since 1.8
  *
  * In case multiple algorithms are supported the best one is used. */
-static inline u32 cksum_type_pack(cksum_type_t cksum_type)
+static inline u32 cksum_type_pack(enum cksum_type cksum_type)
 {
 	unsigned int    performance = 0, tmp;
 	u32		flag = OBD_FL_CKSUM_ADLER;
@@ -98,7 +98,7 @@ static inline u32 cksum_type_pack(cksum_type_t cksum_type)
 	return flag;
 }
 
-static inline cksum_type_t cksum_type_unpack(u32 o_flags)
+static inline enum cksum_type cksum_type_unpack(u32 o_flags)
 {
 	switch (o_flags & OBD_FL_CKSUM_ALL) {
 	case OBD_FL_CKSUM_CRC32C:
@@ -116,9 +116,9 @@ static inline cksum_type_t cksum_type_unpack(u32 o_flags)
  * 1.8 supported ADLER it is base and not depend on hw
  * Client uses all available local algos
  */
-static inline cksum_type_t cksum_types_supported_client(void)
+static inline enum cksum_type cksum_types_supported_client(void)
 {
-	cksum_type_t ret = OBD_CKSUM_ADLER;
+	enum cksum_type ret = OBD_CKSUM_ADLER;
 
 	CDEBUG(D_INFO, "Crypto hash speed: crc %d, crc32c %d, adler %d\n",
 	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)),
@@ -140,7 +140,7 @@ static inline cksum_type_t cksum_types_supported_client(void)
  * checksum type due to its benchmarking at libcfs module load.
  * Caution is advised, however, since what is fastest on a single client may
  * not be the fastest or most efficient algorithm on the server.  */
-static inline cksum_type_t cksum_type_select(cksum_type_t cksum_types)
+static inline enum cksum_type cksum_type_select(enum cksum_type cksum_types)
 {
 	return cksum_type_unpack(cksum_type_pack(cksum_types));
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 43b11c6..cb9587f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1151,7 +1151,7 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 
 static u32 osc_checksum_bulk(int nob, u32 pg_count,
 			     struct brw_page **pga, int opc,
-			     cksum_type_t cksum_type)
+			     enum cksum_type cksum_type)
 {
 	__u32 cksum;
 	int i = 0;
@@ -1355,7 +1355,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
 			/* store cl_cksum_type in a local variable since
 			 * it can be changed via lprocfs */
-			cksum_type_t cksum_type = cli->cl_cksum_type;
+			enum cksum_type cksum_type = cli->cl_cksum_type;
 
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
 				oa->o_flags &= OBD_FL_LOCAL_MASK;
@@ -1414,11 +1414,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 static int check_write_checksum(struct obdo *oa, const lnet_process_id_t *peer,
 				__u32 client_cksum, __u32 server_cksum, int nob,
 				u32 page_count, struct brw_page **pga,
-				cksum_type_t client_cksum_type)
+				enum cksum_type client_cksum_type)
 {
 	__u32 new_cksum;
 	char *msg;
-	cksum_type_t cksum_type;
+	enum cksum_type cksum_type;
 
 	if (server_cksum == client_cksum) {
 		CDEBUG(D_PAGE, "checksum %x confirmed\n", client_cksum);
@@ -1549,7 +1549,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		__u32 server_cksum = body->oa.o_cksum;
 		char *via = "";
 		char *router = "";
-		cksum_type_t cksum_type;
+		enum cksum_type cksum_type;
 
 		cksum_type = cksum_type_unpack(body->oa.o_valid&OBD_MD_FLFLAGS ?
 					       body->oa.o_flags : 0);
-- 
2.1.0
