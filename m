From: Joe Perches <joe@perches.com>
Date: Mon, 15 Aug 2016 12:33:24 -0700
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: Remove .. paths from
	'#include "' uses
In-Reply-To: <cover.1471289489.git.joe@perches.com>
References: <cover.1471289489.git.joe@perches.com>
Message-ID: <36f2e33a8da757493db665511d86785f184983cc.1471289489.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

Make the include paths a bit easier to find and more
compatible to a future move out of the staging tree.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h         |  6 +++---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h         |  8 ++++----
 drivers/staging/lustre/lnet/libcfs/debug.c                  |  2 +-
 drivers/staging/lustre/lnet/libcfs/fail.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c             |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c            |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c             |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c          |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c        |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c     |  4 ++--
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c    |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c      |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c        |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c     |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c       |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c  |  2 +-
 drivers/staging/lustre/lnet/libcfs/module.c                 | 10 +++++-----
 drivers/staging/lustre/lnet/libcfs/prng.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c              |  2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h              |  2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c               |  2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c                   |  4 ++--
 drivers/staging/lustre/lnet/lnet/config.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c                  |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c                  |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c               |  4 ++--
 drivers/staging/lustre/lnet/lnet/lo.c                       |  2 +-
 drivers/staging/lustre/lnet/lnet/module.c                   |  4 ++--
 drivers/staging/lustre/lnet/lnet/net_fault.c                |  4 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c               |  4 ++--
 drivers/staging/lustre/lnet/lnet/peer.c                     |  4 ++--
 drivers/staging/lustre/lnet/lnet/router.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c              |  4 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c               |  6 +++---
 drivers/staging/lustre/lnet/selftest/conrpc.c               |  4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.h               |  8 ++++----
 drivers/staging/lustre/lnet/selftest/console.c              |  4 ++--
 drivers/staging/lustre/lnet/selftest/console.h              |  8 ++++----
 drivers/staging/lustre/lnet/selftest/rpc.h                  |  2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h             | 10 +++++-----
 drivers/staging/lustre/lustre/fid/fid_internal.h            |  2 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c                 |  2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c             |  2 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c               |  2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c               |  2 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h            |  2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c             |  2 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c               |  2 +-
 drivers/staging/lustre/lustre/include/interval_tree.h       |  2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_lite.h   |  2 +-
 drivers/staging/lustre/lustre/include/lu_object.h           |  2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h   |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_disk.h         |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_fid.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_handles.h      |  2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h          |  6 +++---
 drivers/staging/lustre/lustre/include/obd_cksum.h           |  4 ++--
 drivers/staging/lustre/lustre/include/obd_support.h         |  2 +-
 drivers/staging/lustre/lustre/ldlm/l_lock.c                 |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c            |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c               |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c              |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c             |  2 +-
 drivers/staging/lustre/lustre/llite/glimpse.c               |  2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c            |  2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c            |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c                    |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c                  |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c            |  2 +-
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c                  |  2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c               |  2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                 |  2 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c              |  2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c                |  2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c             |  2 +-
 drivers/staging/lustre/lustre/mgc/mgc_internal.h            |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c          |  4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_page.c            |  2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c          |  2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c          |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lu_ref.c             |  2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c          |  2 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c               |  2 +-
 drivers/staging/lustre/lustre/obdecho/echo_client.c         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c                |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/errno.c                |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c               |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c          |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c                  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c         |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c              |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c              |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c                  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c           |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c               |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c            |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c              |  2 +-
 114 files changed, 153 insertions(+), 153 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 078a0c3..3a28797 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -63,9 +63,9 @@
 
 #define DEBUG_SUBSYSTEM S_LND
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnet.h"
-#include "../../../include/linux/lnet/lib-lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
 /* # scheduler loops before reschedule */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a56632b..b143ed4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -46,10 +46,10 @@
 #include <net/sock.h>
 #include <net/tcp.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnet.h"
-#include "../../../include/linux/lnet/lib-lnet.h"
-#include "../../../include/linux/lnet/socklnd.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/socklnd.h"
 
 /* assume one thread for each connection type */
 #define SOCKNAL_NSCHEDS		3
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 42b15a7..2561c5f 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -37,7 +37,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "tracefile.h"
 
 static char debug_file_name[1024];
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 9288ee0..d1eb232 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -29,7 +29,7 @@
  * Lustre is a trademark of Oracle Corporation, Inc.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 unsigned long cfs_fail_loc;
 EXPORT_SYMBOL(cfs_fail_loc);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 23283b6..b28dea9 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -105,7 +105,7 @@
 #include <linux/seq_file.h>
 #include <linux/log2.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 33352af..e5d3aac 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -30,7 +30,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /** Global CPU partition table */
 struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 83543f9..fe3c0cd 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -27,7 +27,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /** destroy cpu-partition lock, see libcfs_private.h for more detail */
 void
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index d0e81bb..9cc293a 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -28,7 +28,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 struct cfs_var_array {
 	unsigned int		va_count;	/* # of buffers */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index fc697cd..f76ceb2 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -36,7 +36,7 @@
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index b52518c5..f0c706a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -31,7 +31,7 @@
 
 #include <linux/cpu.h>
 #include <linux/sched.h>
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #ifdef CONFIG_SMP
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 5c0116a..d575c5a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -29,8 +29,8 @@
 
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/libcfs/libcfs_crypto.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs_crypto.h"
 #include "linux-crypto.h"
 
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
index 3e22cad..d1e05a6 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
@@ -44,7 +44,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /*
  * Implementation of cfs_curproc API (see portals/include/libcfs/curproc.h)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 435b784..39ac92e 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -51,7 +51,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../tracefile.h"
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
index a6a76a6..2186aed 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
@@ -29,7 +29,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 void *libcfs_kvzalloc(size_t size, gfp_t flags)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 38308f8..d83a347 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #define LNET_MINOR 240
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 291d286..771f573 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -36,7 +36,7 @@
 #include <linux/fs_struct.h>
 #include <linux/sched.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #if defined(CONFIG_KGDB)
 #include <linux/kgdb.h>
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 8b551d27..9ac79e2 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -33,7 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #define LUSTRE_TRACEFILE_PRIVATE
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../tracefile.h"
 
 /* percents to share the total debug memory for each type */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 86b4d25..e197263 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -50,13 +50,13 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <asm/div64.h>
 
-#include "../../include/linux/libcfs/libcfs_crypto.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
-#include "../../include/linux/lnet/lnet.h"
+#include "linux/libcfs/libcfs_crypto.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-dlc.h"
+#include "linux/lnet/lnet.h"
 #include "tracefile.h"
 
 static struct dentry *lnet_debugfs_root;
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
index a9bdb28..8719494 100644
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ b/drivers/staging/lustre/lnet/libcfs/prng.c
@@ -35,7 +35,7 @@
  * algorithm recommended by Marsaglia
 */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /*
  * From: George Marsaglia <geo@stat.fsu.edu>
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 1c7efdf..6f245ea 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -39,7 +39,7 @@
 #define LUSTRE_TRACEFILE_PRIVATE
 #include "tracefile.h"
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /* XXX move things up to the top, comment */
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index d878676..6016012 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -33,7 +33,7 @@
 #ifndef __LIBCFS_TRACEFILE_H__
 #define __LIBCFS_TRACEFILE_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index e98c818..4f6bb5a 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #define CFS_WS_NAME_LEN	 16
 
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 8c50c99..12c90a9 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -33,7 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/completion.h>
 #include <net/sock.h>
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 static int   accept_port    = 988;
 static int   accept_backlog = 127;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 346db89..a2420be 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -34,8 +34,8 @@
 #include <linux/log2.h>
 #include <linux/ktime.h>
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-dlc.h"
 
 #define D_LNI D_CONSOLE
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index a72afdf..ef7c9c0 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -31,7 +31,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 struct lnet_text_buf {	    /* tmp struct for parsing routes */
 	struct list_head ltb_list;	/* stash on lists */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index d05c6cc..7a02aa4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -35,7 +35,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 /**
  * Create an event queue that has room for \a count number of events.
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 1834bf7..408f58e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 /* must be called with lnet_res_lock held */
 void
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index b430046..5087065 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 /**
  * Create and attach a match entry to the match list of \a portal. The new
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index e6d3b80..46da43b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 static int local_nid_dist_zero = 1;
 module_param(local_nid_dist_zero, int, 0444);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 910e106..fff14ce 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 void
 lnet_build_unlink_event(lnet_libmd_t *md, lnet_event_t *ev)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3947e8b..a186871 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -31,7 +31,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 /* NB: add /proc interfaces in upcoming patches */
 int portal_rotor = LNET_PTL_ROTOR_HASH_RT;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 891fd59..eabc999 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -40,8 +40,8 @@
 #include <linux/syscalls.h>
 #include <net/sock.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lib-lnet.h"
 
 static int
 kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 08402712..f6c198e 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -29,7 +29,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 static int
 lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 4ffbd3e..7b489f5 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -31,8 +31,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-dlc.h"
 
 static int config_on_load;
 module_param(config_on_load, int, 0444);
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index e4aceb7..d9d51c9 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -35,8 +35,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lnetctl.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lnetctl.h"
 
 #define LNET_MSG_MASK		(LNET_PUT_BIT | LNET_ACK_BIT | \
 				 LNET_GET_BIT | LNET_REPLY_BIT)
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index a6d7a61..de61fd3 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -36,8 +36,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index e806191..d84be85 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -34,8 +34,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-dlc.h"
 
 int
 lnet_peer_tables_create(void)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 0635432..a9e9fc5 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -19,7 +19,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/completion.h>
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-lnet.h"
 
 #define LNET_NRB_TINY_MIN	512	/* min value for each CPT */
 #define LNET_NRB_TINY		(LNET_NRB_TINY_MIN * 4)
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 65f65a3..aaa8f69 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -18,8 +18,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lib-lnet.h"
 
 /*
  * This is really lnet_proc.c. You might need to update sanity test 215
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index b786f8b..29cac38 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -36,9 +36,9 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lnetst.h"
 #include "console.h"
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 1be3cad..5a9a406 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -36,8 +36,8 @@
  * Author: Liang Zhen <liang@whamcloud.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lib-lnet.h"
 #include "timer.h"
 #include "conrpc.h"
 #include "console.h"
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 7ec6fc9..7004980e 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -39,10 +39,10 @@
 #ifndef __LST_CONRPC_H__
 #define __LST_CONRPC_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
+#include "linux/lnet/lib-types.h"
+#include "linux/lnet/lnetst.h"
 #include "rpc.h"
 #include "selftest.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 4c33621..4d4fcaf 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -36,8 +36,8 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lib-lnet.h"
 #include "console.h"
 #include "conrpc.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 78b1477..669f7cd 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -39,10 +39,10 @@
 #ifndef __LST_CONSOLE_H__
 #define __LST_CONSOLE_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
+#include "linux/lnet/lib-types.h"
+#include "linux/lnet/lnetst.h"
 #include "selftest.h"
 #include "conrpc.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 4ab2ee2..c0653e4 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -33,7 +33,7 @@
 #ifndef __SELFTEST_RPC_H__
 #define __SELFTEST_RPC_H__
 
-#include "../../include/linux/lnet/lnetst.h"
+#include "linux/lnet/lnetst.h"
 
 /*
  * LST wired structures
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index d033ac0..f7958e8 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -38,11 +38,11 @@
 
 #define LNET_ONLY
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnet.h"
+#include "linux/lnet/lib-lnet.h"
+#include "linux/lnet/lib-types.h"
+#include "linux/lnet/lnetst.h"
 
 #include "rpc.h"
 #include "timer.h"
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index 5c53773..5753464 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -37,7 +37,7 @@
 #define __FID_INTERNAL_H
 
 #include "../include/lustre/lustre_idl.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 /* Functions used internally in module. */
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 99ae7eb..d13777b 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 #include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_fid.h"
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 454744d..46519b0 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 81b7ca9..e436b04 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 0100a93..cc791ec 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index f0efe5b..a0a9e1a 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -39,7 +39,7 @@
 
 #include "../include/lustre/lustre_idl.h"
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre_req_layout.h"
 #include "../include/lustre_fld.h"
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index e59d626..1d7f4bd 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 61ac420..c47cf0a 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/module.h>
 
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index 4a15228..5559e3c 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -36,7 +36,7 @@
 #ifndef _INTERVAL_H__
 #define _INTERVAL_H__
 
-#include "../../include/linux/libcfs/libcfs.h"	/* LASSERT. */
+#include "linux/libcfs/libcfs.h"	/* LASSERT. */
 
 struct interval_node {
 	struct interval_node   *in_left;
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
index d18e8a7..0ab8cf2 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
@@ -45,7 +45,7 @@
 #include "../lustre_ha.h"
 
 #include <linux/rbtree.h>
-#include "../../include/linux/lustre_compat25.h"
+#include "linux/lustre_compat25.h"
 #include <linux/pagemap.h>
 
 /* lprocfs.c */
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 6e25c1b..c4e117b 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -34,7 +34,7 @@
 #define __LUSTRE_LU_OBJECT_H
 
 #include <stdarg.h>
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 #include "lu_ref.h"
 
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 051864c..27521e0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -87,8 +87,8 @@
 #ifndef _LUSTRE_IDL_H_
 #define _LUSTRE_IDL_H_
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/types.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/types.h"
 
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 8886458..901abfe 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -44,8 +44,8 @@
  * @{
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/types.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/types.h"
 #include <linux/backing-dev.h>
 
 /****************** persistent mount data *********************/
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 743671a..1cdc5c4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -148,7 +148,7 @@
  *  Even so, the MDT and OST resources are also in different LDLM namespaces.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 
 struct lu_env;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 932410d..be5325b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -39,7 +39,7 @@
  */
 
 #include "lustre/lustre_idl.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 struct lu_client_fld;
 struct lu_server_fld;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 1a63a6b..b76b073 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -44,7 +44,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 struct portals_handle_ops {
 	void (*hop_addref)(void *object);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 06958f2..5ad534c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -45,7 +45,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/types.h>
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_ver.h"
 #include "lustre_cfg.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index fa62b95..cdeb3bc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -48,7 +48,7 @@
 #include <linux/dcache.h>
 #include "lustre_intent.h"
 #include "lustre_handles.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "obd_class.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_lib.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 4104bd9..5d4816d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -44,7 +44,7 @@
  */
 
 #include "lustre_handles.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_lib.h"
 #include "lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d5debd6..320bcd2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -50,9 +50,9 @@
  * @{
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/nidstr.h"
-#include "../../include/linux/lnet/api.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/nidstr.h"
+#include "linux/lnet/api.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_ha.h"
 #include "lustre_sec.h"
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index a8a81e6..1ba7ccc 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -30,8 +30,8 @@
 
 #ifndef __OBD_CKSUM
 #define __OBD_CKSUM
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/libcfs/libcfs_crypto.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs_crypto.h"
 #include "lustre/lustre_idl.h"
 
 static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 845e64a..9d97d8c 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -34,7 +34,7 @@
 #define _OBD_SUPPORT
 
 #include <linux/slab.h>
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "linux/lustre_compat25.h"
 #include "lprocfs_status.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index ea8840c..8271695 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -31,7 +31,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_lib.h"
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index f5023d9..c7c2c0e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -46,7 +46,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre_dlm.h"
 #include "../include/obd_support.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 7c832aa..20e2197 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/obd.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a5993f7..f1c1ea0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre_intent.h"
 #include "../include/obd_class.h"
 #include "ldlm_internal.h"
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 821939f..3079729 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre_dlm.h"
 #include "../include/obd_class.h"
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 92004a0..6aa466a 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -36,7 +36,7 @@
  *   Author: Oleg Drokin <oleg.drokin@sun.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 396e4e4f..edc9e37 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 # include <linux/fs.h>
 # include <linux/sched.h>
 # include <linux/mm.h>
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 66ee5db..eef6e18 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -45,7 +45,7 @@
 
 #include "../include/lustre_lite.h"
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
+#include "linux/lustre_compat25.h"
 
 static const struct vm_operations_struct ll_file_vm_ops;
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 87393c4..721c37c 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -53,7 +53,7 @@
 #include "../include/lustre_lite.h"
 #include "../include/obd_cksum.h"
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
+#include "linux/lustre_compat25.h"
 
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index d98c7ac..9ac284b 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -53,7 +53,7 @@
 
 #include "../include/lustre_lite.h"
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
+#include "linux/lustre_compat25.h"
 
 /**
  * Implements Linux VM address_space::invalidatepage() method. This method is
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 2c520b0..97820fc 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "../include/lustre_lite.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 9740568..3c77ae9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -42,7 +42,7 @@
 #ifndef LOV_CL_INTERNAL_H
 #define LOV_CL_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "../include/cl_object.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 5053dea..4d9e506 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include <asm/div64.h>
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_idl.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index b9c9086..2a3e755 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9b92d55..2bd3aba 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -38,7 +38,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
 #include "../include/lustre_lib.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index ecca74f..ab1f7e1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 4c2d217..ddc257b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 4099b51..543f462 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_idl.h"
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index f146f75..fbe1390 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -33,7 +33,7 @@
 #ifndef _MGC_INTERNAL_H
 #define _MGC_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 91a5806..58dda55 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -46,13 +46,13 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 /* class_put_type() */
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
 #include <linux/list.h>
-#include "../../include/linux/libcfs/libcfs_hash.h"	/* for cfs_hash stuff */
+#include "linux/libcfs/libcfs_hash.h"	/* for cfs_hash stuff */
 #include "../include/cl_object.h"
 #include "cl_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index db2dc6b..01a87a2 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index d9d2a19..a46c7d1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -35,7 +35,7 @@
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
-#include "../../include/linux/lnet/lnetctl.h"
+#include "linux/lnet/lnetctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lprocfs_status.h"
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 33342bf..7f51e3b 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -60,8 +60,8 @@
 #include <linux/seq_file.h>
 #include <linux/kobject.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnetctl.h"
+#include "linux/libcfs/libcfs.h"
+#include "linux/lnet/lnetctl.h"
 #include "../../include/obd_support.h"
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 9b03059..2ac4914 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -40,12 +40,12 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 # include <linux/module.h>
 
 /* hash_long() */
-#include "../../include/linux/libcfs/libcfs_hash.h"
+#include "linux/libcfs/libcfs_hash.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_disk.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index e9f6040..e9d3a4e 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index aa84a50e..fed49a5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -41,7 +41,7 @@
 #define PRINT_CMD CDEBUG
 
 #include "../include/obd.h"
-#include "../include/linux/lustre_compat25.h"
+#include "linux/lustre_compat25.h"
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_user.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index abd9b1a..6855352 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -34,7 +34,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 5b29c4a..b21b6d3 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -31,7 +31,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_ECHO
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "../include/obd_support.h"
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c8c3f1c..8a52e5f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -42,7 +42,7 @@
 #ifndef OSC_CL_INTERNAL_H
 #define OSC_CL_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 /* osc_build_res_name() */
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 717d3ff..0b62bb9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 /* fid_build_reg_res_name() */
 #include "../include/lustre_fid.h"
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 536b868..9976248 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_net.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
index 73f8374..6a5f4ce 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/errno.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/errno.c
@@ -25,7 +25,7 @@
  * Copyright (c) 2013, Intel Corporation.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "../include/lustre/lustre_errno.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index b1ce725..adf8903 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 # ifdef __mips64__
 #  include <linux/kernel.h>
 # endif
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 0f55c01..2b9232b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index bccdace..89f6b18 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -42,7 +42,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index d88faf6..3c80881 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -40,7 +40,7 @@
 #include "../include/obd_class.h"
 #include "../include/lustre_net.h"
 #include "../include/lprocfs_status.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index b123a93..0167bde 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -45,7 +45,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index b514f18..740ff30 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 0a374b6..9f45ad5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -51,7 +51,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/lustre_net.h"
 #include "../include/lustre_lib.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 718b3a8..78df690 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -35,7 +35,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
 #include "../include/lustre_ha.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index dbd819f..26d3695 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/crypto.h>
 #include <linux/key.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 5f4d797..3b291d4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
 #include "../include/obd_cksum.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index c140354..7d280dc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/crypto.h>
 #include <linux/key.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 9b9801e..e5ade1b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index 07273f5..478c26b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -34,7 +34,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include "linux/libcfs/libcfs.h"
 #include <linux/crypto.h>
 
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 4788c49..c1bde34 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -35,7 +35,7 @@
 #include "../include/obd_class.h"
 #include "../include/lustre_net.h"
 #include "../include/lu_object.h"
-#include "../../include/linux/lnet/types.h"
+#include "linux/lnet/types.h"
 #include "ptlrpc_internal.h"
 
 /* The following are visible and mutable through /sys/module/ptlrpc */
-- 
2.8.0.rc4.16.g56331f8
