From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 22/30] staging: lustre: remove libcfs_all.h
 includes from lnet/klnd
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731319.24196.11562205247893325846.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Other smaller include files are sufficient.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    1 -
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    1 +
 3 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 7c0e9f66b16a..217503f125bc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -64,7 +64,6 @@
 
 #define DEBUG_SUBSYSTEM S_LND
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index e080aac508ff..4e5c89a692a3 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -47,7 +47,6 @@
 #include <net/sock.h>
 #include <net/tcp.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <linux/lnet/socklnd.h>
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 7941cfa526bc..93a02cd6b6b5 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -31,6 +31,7 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
+#include <linux/highmem.h>
 #include "socklnd.h"
 
 int
