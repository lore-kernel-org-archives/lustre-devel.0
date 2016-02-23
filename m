From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:12 -0500
Subject: [lustre-devel] [PATCH 34/56] staging/lustre: FMODE_READ and
	FMODE_WRITE are always defined in the kernel
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-35-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

So no need to see if they are.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index ad77d33..7b5c132 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2158,11 +2158,6 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
 #define MDS_ATTR_FROM_OPEN  0x4000ULL /* = 16384, called from open path, ie O_TRUNC */
 #define MDS_ATTR_BLOCKS     0x8000ULL /* = 32768 */
 
-#ifndef FMODE_READ
-#define FMODE_READ	       00000001
-#define FMODE_WRITE	      00000002
-#endif
-
 #define MDS_FMODE_CLOSED	 00000000
 #define MDS_FMODE_EXEC	   00000004
 /* IO Epoch is opened on a closed file. */
-- 
2.1.0
