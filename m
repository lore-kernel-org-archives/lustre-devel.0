From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:08 -0500
Subject: [lustre-devel] [PATCH 30/56] staging/lustre: Remove duplicated
	quota defines
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-31-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

QUOTABLOCK_BITS, QUOTABLOCK_SIZE and toqb are only used on the server
and are copied from kernel code anyway.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 12 ------------
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c           |  5 -----
 2 files changed, 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 26f1c43..ccb1b85 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1778,18 +1778,6 @@ void lustre_swab_ost_lvb(struct ost_lvb *lvb);
  *   lquota data structures
  */
 
-#ifndef QUOTABLOCK_BITS
-#define QUOTABLOCK_BITS 10
-#endif
-
-#ifndef QUOTABLOCK_SIZE
-#define QUOTABLOCK_SIZE (1 << QUOTABLOCK_BITS)
-#endif
-
-#ifndef toqb
-#define toqb(x) (((x) + QUOTABLOCK_SIZE - 1) >> QUOTABLOCK_BITS)
-#endif
-
 /* The lquota_id structure is an union of all the possible identifier types that
  * can be used with quota, this includes:
  * - 64-bit user ID
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 3f9acc2..799a85ac 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1507,11 +1507,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(union lquota_id) == 16, "found %lld\n",
 		 (long long)(int)sizeof(union lquota_id));
 
-	LASSERTF(QUOTABLOCK_BITS == 10, "found %lld\n",
-		 (long long)QUOTABLOCK_BITS);
-	LASSERTF(QUOTABLOCK_SIZE == 1024, "found %lld\n",
-		 (long long)QUOTABLOCK_SIZE);
-
 	/* Checks for struct obd_quotactl */
 	LASSERTF((int)sizeof(struct obd_quotactl) == 112, "found %lld\n",
 		 (long long)(int)sizeof(struct obd_quotactl));
-- 
2.1.0
