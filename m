From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:55 -0500
Subject: [lustre-devel] [PATCH v2 72/84] staging/lustre: NEED_QUOTA_DEFS is
	never defined, drop it.
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-73-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre/lustre_user.h   | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 2e9f025..9f026bd 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -552,22 +552,6 @@ enum {
 	RMT_RGETFACL    = 4
 };
 
-#ifdef NEED_QUOTA_DEFS
-#ifndef QIF_BLIMITS
-#define QIF_BLIMITS     1
-#define QIF_SPACE       2
-#define QIF_ILIMITS     4
-#define QIF_INODES      8
-#define QIF_BTIME       16
-#define QIF_ITIME       32
-#define QIF_LIMITS      (QIF_BLIMITS | QIF_ILIMITS)
-#define QIF_USAGE       (QIF_SPACE | QIF_INODES)
-#define QIF_TIMES       (QIF_BTIME | QIF_ITIME)
-#define QIF_ALL	 (QIF_LIMITS | QIF_USAGE | QIF_TIMES)
-#endif
-
-#endif /* !__KERNEL__ */
-
 /* lustre volatile file support
  * file name header: .^L^S^T^R:volatile"
  */
-- 
2.1.0
