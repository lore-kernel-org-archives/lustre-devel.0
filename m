From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 23:51:09 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: really make lustre
	dependent on LNet
Message-ID: <1457995886-1592279-1-git-send-email-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

A patch intended to add a dependency on LNET for lustre didn't
actually do that and instead allowed configurations that contain
lustre with lnet but without IPv4 support that subsequently
fail to link:

warning: (LUSTRE_FS) selects LNET which has unmet direct dependencies (STAGING && INET && m && MODULES)
ERROR: "kernel_sendmsg" [drivers/staging/lustre/lnet/lnet/lnet.ko] undefined!
ERROR: "sock_create_lite" [drivers/staging/lustre/lnet/lnet/lnet.ko] undefined!
ERROR: "sock_release" [drivers/staging/lustre/lnet/lnet/lnet.ko] undefined!
ERROR: "release_sock" [drivers/staging/lustre/lnet/klnds/socklnd/ksocklnd.ko] undefined!
ERROR: "kernel_sendmsg" [drivers/staging/lustre/lnet/klnds/socklnd/ksocklnd.ko] undefined!
ERROR: "tcp_sendpage" [drivers/staging/lustre/lnet/klnds/socklnd/ksocklnd.ko] undefined!

This adds the one-line change that was evidently missing from the
commit, doing what was intended there to have a correct set of dependencies.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b08bb6bb5af5 ("staging: lustre: make lustre dependent on LNet")
---
 drivers/staging/lustre/lustre/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index a09b51ce8265..8ac7cd4d6fdb 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -1,7 +1,7 @@
 config LUSTRE_FS
 	tristate "Lustre file system client support"
 	depends on m && !MIPS && !XTENSA && !SUPERH
-	select LNET
+	depends on LNET
 	select CRYPTO
 	select CRYPTO_CRC32
 	select CRYPTO_CRC32_PCLMUL if X86
-- 
2.7.0
