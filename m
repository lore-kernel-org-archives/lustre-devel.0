From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:15 -0400
Subject: [lustre-devel] [PATCH 06/12] staging: lustre: fid: add a connect
	flag for open by FID
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Add OBD_CONNECT_OPEN_BY_FID for open by FID, if MDS supports this,
for open by FID, it won't retry with name if object with the FID
doesn't exist; while if client supports this, client won't pack
name in open request if FID is known.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3544
Reviewed-on: http://review.whamcloud.com/8093
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 3 +++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c           | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 26819ee..0ef540a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1257,6 +1257,9 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define OBD_CONNECT_PINGLESS	0x4000000000000ULL/* pings not required */
 #define OBD_CONNECT_FLOCK_DEAD	0x8000000000000ULL/* flock deadlock detection */
 #define OBD_CONNECT_DISP_STRIPE 0x10000000000000ULL/*create stripe disposition*/
+#define OBD_CONNECT_OPEN_BY_FID	0x20000000000000ULL	/* open by fid won't pack
+							 * name in request
+							 */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 87555e4..308b6b96 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1069,6 +1069,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_PINGLESS);
 	LASSERTF(OBD_CONNECT_FLOCK_DEAD == 0x8000000000000ULL,
 		 "found 0x%.16llxULL\n", OBD_CONNECT_FLOCK_DEAD);
+	LASSERTF(OBD_CONNECT_OPEN_BY_FID == 0x20000000000000ULL,
+		 "found 0x%.16llxULL\n", OBD_CONNECT_OPEN_BY_FID);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
2.7.4
