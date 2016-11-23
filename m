From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 18:01:17 -0500
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obd: reserve connection
	flag OBD_CONNECT_SUBTREE
In-Reply-To: <1479942080-30166-1-git-send-email-jsimmons@infradead.org>
References: <1479942080-30166-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479942080-30166-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

The connection flag OBD_CONNECT_SUBTREE will be used for the
following the patch: LU-28 mounting of filesystem from MDS
http://review.whamcloud.com/5007

Land the connection flags to master earlier for reserving the
slot to avoid potential conflict with others.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7543
Reviewed-on: http://review.whamcloud.com/17644
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 ++
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 5c1fb6c..eb0dce6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1189,6 +1189,7 @@ struct ptlrpc_body_v2 {
 						       *  RPCs in parallel
 						       */
 #define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
+#define OBD_CONNECT_SUBTREE	 0x800000000000000ULL /* fileset mount */
 /** bulk matchbits is sent within ptlrpc_body */
 #define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index db49992..f78928f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -102,6 +102,7 @@
 	"unlink_close",
 	"multi_mod_rpcs",
 	"dir_stripe",
+	"subtree",
 	"bulk_mbits",
 	"unknown",
 	NULL
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index b239563..5619f11 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1105,6 +1105,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_MULTIMODRPCS);
 	LASSERTF(OBD_CONNECT_DIR_STRIPE == 0x400000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_DIR_STRIPE);
+	LASSERTF(OBD_CONNECT_SUBTREE == 0x800000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_SUBTREE);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.7.1
