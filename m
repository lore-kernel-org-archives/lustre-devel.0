From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:55 +1100
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: discard
 LASSERT_CHECKED
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495511.27582.5936753382372514332.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

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
 #define LASSERTF(cond, fmt, ...)					\
 do {									\
 	if (unlikely(!(cond))) {					\
