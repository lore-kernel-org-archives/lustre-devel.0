From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:55 +1100
Subject: [lustre-devel] [PATCH 09/12] staging: lustre: libcfs: discard
 MKSTR() macro
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495503.27582.5512761213682609004.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This is only used for tracing when some strings might
be NULL.  NULL strings are not a problem for tracing,
vnsprintf() will report them as "(null)" which is probably
better (easier to parse) than an empty string.

Also remove a nearby comment that doesn't relate to the
(remaining) code at all.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    8 --------
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 +-
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index dee5f650197f..27d40a7589d4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -235,14 +235,6 @@ do {							    \
 /* logical equivalence */
 #define equi(a, b) (!!(a) == !!(b))
 
-/* --------------------------------------------------------------------
- * Light-weight trace
- * Support for temporary event tracing with minimal Heisenberg effect.
- * --------------------------------------------------------------------
- */
-
-#define MKSTR(ptr) ((ptr)) ? (ptr) : ""
-
 #ifndef HAVE_CFS_SIZE_ROUND
 static inline size_t cfs_size_round(int val)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index c0e192ae22a9..997c0f9aafb5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -236,7 +236,7 @@ static int class_attach(struct lustre_cfg *lcfg)
 	uuid = lustre_cfg_string(lcfg, 2);
 
 	CDEBUG(D_IOCTL, "attach type %s name: %s uuid: %s\n",
-	       MKSTR(typename), MKSTR(name), MKSTR(uuid));
+	       typename, name, uuid);
 
 	obd = class_newdev(typename, name);
 	if (IS_ERR(obd)) {
