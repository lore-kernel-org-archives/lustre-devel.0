From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:06 -0500
Subject: [lustre-devel] [PATCH 28/56] staging/lustre: Remove server-only
	values from enum lu_dirent_attrs
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These values cannot be seen on the client so we probably should
not even be aware of them on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre/lustre_idl.h    | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d2f05e3..eeb0542 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -880,24 +880,8 @@ enum lu_dirent_attrs {
 	LUDA_FID		= 0x0001,
 	LUDA_TYPE		= 0x0002,
 	LUDA_64BITHASH		= 0x0004,
-
-	/* The following attrs are used for MDT internal only,
-	 * not visible to client */
-
-	/* Verify the dirent consistency */
-	LUDA_VERIFY		= 0x8000,
-	/* Only check but not repair the dirent inconsistency */
-	LUDA_VERIFY_DRYRUN	= 0x4000,
-	/* The dirent has been repaired, or to be repaired (dryrun). */
-	LUDA_REPAIR		= 0x2000,
-	/* The system is upgraded, has beed or to be repaired (dryrun). */
-	LUDA_UPGRADE		= 0x1000,
-	/* Ignore this record, go to next directly. */
-	LUDA_IGNORE		= 0x0800,
 };
 
-#define LU_DIRENT_ATTRS_MASK	0xf800
-
 /**
  * Layout of readdir pages, as transmitted on wire.
  */
-- 
2.1.0
