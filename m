From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:27 +0530
Subject: [lustre-devel] [PATCH 2/5] Staging: lustre: libcfs: Remove unused
	libcfs_debug_set_level
In-Reply-To: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
References: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450386630-5662-3-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Function libcfs_debug_set_level is defined but not used. Thus
remove it.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/libcfs/debug.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index e56785a..0b38dad 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -557,10 +557,3 @@ int libcfs_debug_mark_buffer(const char *text)
 
 #undef DEBUG_SUBSYSTEM
 #define DEBUG_SUBSYSTEM S_LNET
-
-void libcfs_debug_set_level(unsigned int debug_level)
-{
-	pr_warn("Lustre: Setting portals debug level to %08x\n",
-	       debug_level);
-	libcfs_debug = debug_level;
-}
-- 
2.1.4
