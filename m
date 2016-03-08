From: James Simmons <jsimmons@infradead.org>
Date: Tue,  8 Mar 2016 17:35:29 -0500
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: make lustre dependent
	on LNet
In-Reply-To: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
References: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457476529-27708-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

In the case of lustre routers you only need a functioning
LNet stack. Especially since often the routers are very
light weight and want to avoid any addition software that
would create additional pressures on the system.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/Makefile              |    2 +-
 drivers/staging/lustre/Kconfig        |    4 ++--
 drivers/staging/lustre/lnet/Kconfig   |    2 +-
 drivers/staging/lustre/lustre/Kconfig |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 8242923..c008cfc 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -30,7 +30,7 @@ obj-$(CONFIG_WIMAX_GDM72XX)	+= gdm72xx/
 obj-$(CONFIG_LTE_GDM724X)	+= gdm724x/
 obj-$(CONFIG_FIREWIRE_SERIAL)	+= fwserial/
 obj-$(CONFIG_GOLDFISH)		+= goldfish/
-obj-$(CONFIG_LUSTRE_FS)		+= lustre/
+obj-$(CONFIG_LNET)		+= lustre/
 obj-$(CONFIG_DGNC)			+= dgnc/
 obj-$(CONFIG_MTD_SPINAND_MT29F)	+= mt29f_spinand/
 obj-$(CONFIG_GS_FPGABOOT)	+= gs_fpgaboot/
diff --git a/drivers/staging/lustre/Kconfig b/drivers/staging/lustre/Kconfig
index a224d88..b7d8109 100644
--- a/drivers/staging/lustre/Kconfig
+++ b/drivers/staging/lustre/Kconfig
@@ -1,3 +1,3 @@
-source "drivers/staging/lustre/lustre/Kconfig"
-
 source "drivers/staging/lustre/lnet/Kconfig"
+
+source "drivers/staging/lustre/lustre/Kconfig"
diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index 980ce44..2b59301 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -1,6 +1,6 @@
 config LNET
 	tristate "Lustre networking subsystem (LNet)"
-	depends on LUSTRE_FS
+	depends on INET && m
 	help
 	  The Lustre network layer, also known as LNet, is a networking abstaction
 	  level API that was initially created to allow Lustre Filesystem to utilize
diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index 62c7bba..a09b51c 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -1,6 +1,6 @@
 config LUSTRE_FS
 	tristate "Lustre file system client support"
-	depends on INET && m && !MIPS && !XTENSA && !SUPERH
+	depends on m && !MIPS && !XTENSA && !SUPERH
 	select LNET
 	select CRYPTO
 	select CRYPTO_CRC32
-- 
1.7.1
