From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:41 -0500
Subject: [lustre-devel] [PATCH 03/19] staging: lustre: libcfs: use static
	const char const * for a suffixes array
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Change the static const array libcfs_debug_subsystems
to use static const char const * as pointed out by
checkpatch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 9fe4227..f95764c 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -228,7 +228,8 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 static const char *
 libcfs_debug_subsys2str(int subsys)
 {
-	static const char *libcfs_debug_subsystems[] = LIBCFS_DEBUG_SUBSYS_NAMES;
+	static const char * const libcfs_debug_subsystems[] =
+		LIBCFS_DEBUG_SUBSYS_NAMES;
 
 	if (subsys >= ARRAY_SIZE(libcfs_debug_subsystems))
 		return NULL;
@@ -240,7 +241,8 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 static const char *
 libcfs_debug_dbg2str(int debug)
 {
-	static const char *libcfs_debug_masks[] = LIBCFS_DEBUG_MASKS_NAMES;
+	static const char * const libcfs_debug_masks[] =
+		LIBCFS_DEBUG_MASKS_NAMES;
 
 	if (debug >= ARRAY_SIZE(libcfs_debug_masks))
 		return NULL;
-- 
1.7.1
