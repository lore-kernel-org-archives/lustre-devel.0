From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 30 May 2018 23:38:48 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: include linux/highmem.h
 when needed
Message-ID: <20180530213941.772006-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Doug Oucharek <dougso@me.com>, NeilBrown <neilb@suse.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Ingo Molnar <mingo@kernel.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Something in recent linux-next kernels caused linux/highmem.h to
no longer be included implicitly from o2iblnd_cb.c, causing a build
failure:

drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_kvaddr_to_page':
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:549:15: error: 'PKMAP_BASE' undeclared (first use in this function); did you mean 'RTM_BASE'?
  if (vaddr >= PKMAP_BASE &&
               ^~~~~~~~~~
               RTM_BASE
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:549:15: note: each undeclared identifier is reported only once for each function it appears in
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:550:28: error: 'LAST_PKMAP' undeclared (first use in this function); did you mean 'AT_HWCAP'?
      vaddr < (PKMAP_BASE + LAST_PKMAP * PAGE_SIZE)) {
                            ^~~~~~~~~~
                            AT_HWCAP

This adds back an explicit include for the header.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 47eb8b4c28db..65b7a62943ad 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -35,6 +35,7 @@
  * Author: Eric Barton <eric@bartonsoftware.com>
  */
 
+#include <linux/highmem.h>
 #include "o2iblnd.h"
 
 #define MAX_CONN_RACES_BEFORE_ABORT 20
-- 
2.9.0
