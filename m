From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:00 -0400
Subject: [lustre-devel] [PATCH 24/32] staging: lustre: ptlrpc: add
	OBD_CONNECT_UNLINK_CLOSE flag
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Add OBD_CONNECT_UNLINK_CLOSE flag for interop, once this is supported,
client packs file handle in unlink RPC, and MDT will close file before
unlink.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4367
Reviewed-on: http://review.whamcloud.com/10426
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 ++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a9661c0..4a7ccc8 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1290,6 +1290,7 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 							 * name in request
 							 */
 #define OBD_CONNECT_LFSCK	0x40000000000000ULL/* support online LFSCK */
+#define OBD_CONNECT_UNLINK_CLOSE 0x100000000000000ULL/* close file in unlink */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index fbb0851..45e3c4a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -99,6 +99,8 @@ static const char * const obd_connect_names[] = {
 	"open_by_fid",
 	"lfsck",
 	"unknown",
+	"unlink_close",
+	"unknown",
 	NULL
 };
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 60d03dd..2c718e0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1073,6 +1073,8 @@ void lustre_assert_wire_constants(void)
 		 "found 0x%.16llxULL\n", OBD_CONNECT_OPEN_BY_FID);
 	LASSERTF(OBD_CONNECT_LFSCK == 0x40000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_LFSCK);
+	LASSERTF(OBD_CONNECT_UNLINK_CLOSE == 0x100000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_UNLINK_CLOSE);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.7.1
