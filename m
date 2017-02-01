From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  1 Feb 2017 17:52:38 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: shut up clang warnings on
	CLASSERT()
Message-ID: <20170201165314.2588373-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "John L. Hammond" <john.hammond@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

lustre uses a fake switch() statement as a compile-time assert, but unfortunately
each use of that causes a warning when building with clang:

drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2907:2: warning: no case matching constant switch condition '42'
drivers/staging/lustre/lnet/klnds/socklnd/../../../include/linux/libcfs/libcfs_private.h:294:36: note: expanded from macro 'CLASSERT'
 #define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)

Adding a 'default:' label in there shuts up the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index aab15d8112a4..2d5435029185 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -291,7 +291,7 @@ do {							    \
  *       value  after  conversion...
  *
  */
-#define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
+#define CLASSERT(cond) do {switch (42) {case (cond): case 0: default: break; } } while (0)
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
-- 
2.9.0
