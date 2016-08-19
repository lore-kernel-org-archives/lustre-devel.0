From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:28 -0400
Subject: [lustre-devel] [PATCH 4/7] staging: lustre: mdt: add
	OBD_CONNECT_DIR_STRIPE flag
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add OBD_CONNECT_DIR_STRIPE to tell if the client supports
striped dir, so only new client (>= 2.6) can access striped
directory.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4843
Reviewed-on: http://review.whamcloud.com/10773
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    3 ++-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 ++
 4 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 9545451..c57231b 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1291,6 +1291,7 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 							 */
 #define OBD_CONNECT_LFSCK	0x40000000000000ULL/* support online LFSCK */
 #define OBD_CONNECT_UNLINK_CLOSE 0x100000000000000ULL/* close file in unlink */
+#define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 64c8a2b..49ed3df 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -190,7 +190,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_MAX_EASIZE |
 				  OBD_CONNECT_FLOCK_DEAD |
 				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
-				  OBD_CONNECT_OPEN_BY_FID;
+				  OBD_CONNECT_OPEN_BY_FID |
+				  OBD_CONNECT_DIR_STRIPE;
 
 	if (sbi->ll_flags & LL_SBI_SOM_PREVIEW)
 		data->ocd_connect_flags |= OBD_CONNECT_SOM;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 45e3c4a..3d6da74 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -101,6 +101,8 @@ static const char * const obd_connect_names[] = {
 	"unknown",
 	"unlink_close",
 	"unknown",
+	"dir_stripe",
+	"unknown",
 	NULL
 };
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index b428528..3748f71 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1075,6 +1075,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_LFSCK);
 	LASSERTF(OBD_CONNECT_UNLINK_CLOSE == 0x100000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_UNLINK_CLOSE);
+	LASSERTF(OBD_CONNECT_DIR_STRIPE == 0x400000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_DIR_STRIPE);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.7.1
