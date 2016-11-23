From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 18:01:20 -0500
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obd: reserve connection
	flag OBD_CONNECT_FLAGS2
In-Reply-To: <1479942080-30166-1-git-send-email-jsimmons@infradead.org>
References: <1479942080-30166-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479942080-30166-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

This is a feature for the client and server to use
obd_connect_flags2 to communicate future feature flags. The
client should set this flag whenever any flags in that field
are requested, and the server should mask unsupported features
from this field (assuming it understands OBD_CONNECT_FLAGS2).
When checking if an OBD_CONNECT2_xxxx feature is supported,
the client/server needs to firstly check if OBD_CONNECT_FLAGS2
is supported, since this field is also beyond the end of the
old obd_connect_data.

Land the connection flags to upstream client earlier for reserving
the slot to avoid potential conflict with others.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7543
Reviewed-on: http://review.whamcloud.com/17647
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    3 ++-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    3 ++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   10 ++++++----
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a4020d2..5f42c54 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1194,6 +1194,7 @@ struct ptlrpc_body_v2 {
 /** bulk matchbits is sent within ptlrpc_body */
 #define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
 #define OBD_CONNECT_OBDOPACK	 0x4000000000000000ULL /* compact OUT obdo */
+#define OBD_CONNECT_FLAGS2	 0x8000000000000000ULL /* second flags word */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
@@ -1249,7 +1250,7 @@ struct obd_connect_data {
 	__u16 ocd_maxmodrpcs;	/* Maximum modify RPCs in parallel */
 	__u16 padding0;		/* added 2.1.0. also fix lustre_swab_connect */
 	__u32 padding1;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding2;	  /* added 2.1.0. also fix lustre_swab_connect */
+	__u64 ocd_connect_flags2;
 	__u64 padding3;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding4;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding5;	  /* added 2.1.0. also fix lustre_swab_connect */
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 85b505e..2f2e8fc 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -106,6 +106,7 @@
 	"lock_ahead",
 	"bulk_mbits",
 	"compact_obdo",
+	"second_flags",
 	NULL
 };
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 39c4e18..30c5e91 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1566,7 +1566,8 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 		__swab16s(&ocd->ocd_maxmodrpcs);
 	CLASSERT(offsetof(typeof(*ocd), padding0));
 	CLASSERT(offsetof(typeof(*ocd), padding1) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding2) != 0);
+	if (ocd->ocd_connect_flags & OBD_CONNECT_FLAGS2)
+		__swab64s(&ocd->ocd_connect_flags2);
 	CLASSERT(offsetof(typeof(*ocd), padding3) != 0);
 	CLASSERT(offsetof(typeof(*ocd), padding4) != 0);
 	CLASSERT(offsetof(typeof(*ocd), padding5) != 0);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 04e9471..f50f487 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -935,10 +935,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_connect_data, padding1));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding1) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_connect_data *)0)->padding1));
-	LASSERTF((int)offsetof(struct obd_connect_data, padding2) == 80, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, padding2));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding2) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->padding2));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_connect_flags2) == 80, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_connect_flags2));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_connect_flags2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_connect_flags2));
 	LASSERTF((int)offsetof(struct obd_connect_data, padding3) == 88, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_connect_data, padding3));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding3) == 8, "found %lld\n",
@@ -1111,6 +1111,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_LOCK_AHEAD);
 	LASSERTF(OBD_CONNECT_OBDOPACK == 0x4000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_OBDOPACK);
+	LASSERTF(OBD_CONNECT_FLAGS2 == 0x8000000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_FLAGS2);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.7.1
