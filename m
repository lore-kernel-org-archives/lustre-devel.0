From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:19 -0400
Subject: [lustre-devel] [PATCH 09/30] lustre: obd: remove obsolete
 OBD_FL_LOCAL_MASK
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Andreas Dilger reported that the OBD_FL_LOCAL_MASK support has
not been used since commit e62f0a3c5b9 b=21980 cache ll_obdo_cache:
Can't free all objects; which predates the linux client. With the
future landing of patch https://review.whamcloud.com/26463
lustre: quota: add project inherit attributes the handling of the
"local" flags is broken and since it is unused it is better to be
removed entirely.

Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9355
Reviewed-on: https://review.whamcloud.com/26728
Reported-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h |  4 +---
 drivers/staging/lustre/lustre/obdclass/obdo.c                 | 11 -----------
 drivers/staging/lustre/lustre/osc/osc_request.c               |  5 ++---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c               |  1 -
 4 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 58321eb..66b15c7 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -931,15 +931,13 @@ enum obdo_flags {
 	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
 	OBD_FL_FLUSH        = 0x00200000, /* flush pages on the OST */
 	OBD_FL_SHORT_IO     = 0x00400000, /* short io request */
+	/* OBD_FL_LOCAL_MASK = 0xF0000000, was local-only flags until 2.10 */
 
 	/* Note that while these checksum values are currently separate bits,
 	 * in 2.x we can actually allow all values from 1-31 if we wanted.
 	 */
 	OBD_FL_CKSUM_ALL    = OBD_FL_CKSUM_CRC32 | OBD_FL_CKSUM_ADLER |
 			      OBD_FL_CKSUM_CRC32C,
-
-	/* mask for local-only flag, which won't be sent over network */
-	OBD_FL_LOCAL_MASK   = 0xF0000000,
 };
 
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 5b2bfa8..8013c1e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -134,7 +134,6 @@ void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 			  struct obdo *wobdo, const struct obdo *lobdo)
 {
 	*wobdo = *lobdo;
-	wobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
 	if (!ocd)
 		return;
 
@@ -156,17 +155,7 @@ void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
 			  struct obdo *lobdo, const struct obdo *wobdo)
 {
-	u32 local_flags = 0;
-
-	if (lobdo->o_valid & OBD_MD_FLFLAGS)
-		local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
-
 	*lobdo = *wobdo;
-	if (local_flags) {
-		lobdo->o_valid |= OBD_MD_FLFLAGS;
-		lobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
-		lobdo->o_flags |= local_flags;
-	}
 	if (!ocd)
 		return;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 8024b17..5bab8a3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1273,10 +1273,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			 */
 			enum cksum_type cksum_type = cli->cl_cksum_type;
 
-			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
-				oa->o_flags &= OBD_FL_LOCAL_MASK;
+			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0)
 				body->oa.o_flags = 0;
-			}
+
 			body->oa.o_flags |= cksum_type_pack(cksum_type);
 			body->oa.o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
 			body->oa.o_cksum = osc_checksum_bulk(requested_nob,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 09b1298..09aef9a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1344,7 +1344,6 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(OBD_FL_MMAP != 0x00040000);
 	BUILD_BUG_ON(OBD_FL_RECOV_RESEND != 0x00080000);
 	BUILD_BUG_ON(OBD_FL_NOSPC_BLK != 0x00100000);
-	BUILD_BUG_ON(OBD_FL_LOCAL_MASK != 0xf0000000);
 
 	/* Checks for struct lov_ost_data_v1 */
 	LASSERTF((int)sizeof(struct lov_ost_data_v1) == 24, "found %lld\n",
-- 
1.8.3.1
