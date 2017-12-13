From: Patrick Farrell <paf@cray.com>
Date: Wed, 13 Dec 2017 03:33:26 +0000
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: discard
 LASSERT_CHECKED
In-Reply-To: <151313495511.27582.5936753382372514332.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>,
 <151313495511.27582.5936753382372514332.stgit@noble>
Message-ID: <BN6PR1101MB21324C5DC6B6CF85ACD8EF00CB350@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks, Neil - lots of small but nice cleanups.

Full series acked.
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Tuesday, December 12, 2017 9:15:55 PM
To: Oleg Drokin; James Simmons; Andreas Dilger; Greg Kroah-Hartman
Cc: linux-kernel at vger.kernel.org; lustre-devel at lists.lustre.org
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: discard LASSERT_CHECKED

This macro isn't used, and comment is about some earlier version
of the lustre code that never reached the mainline kernel.
Just discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 31403667be6b..940200ee632e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -43,13 +43,6 @@
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif

-/*
- * When this is on, LASSERT macro includes check for assignment used instead
- * of equality check, but doesn't have unlikely(). Turn this on from time to
- * time to make test-builds. This shouldn't be on for production release.
- */
-#define LASSERT_CHECKED (0)
-
 #define LASSERTF(cond, fmt, ...)                                        \
 do {                                                                    \
         if (unlikely(!(cond))) {                                        \


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171213/66cb4495/attachment.html>
