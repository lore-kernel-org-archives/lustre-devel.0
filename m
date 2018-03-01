From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 16/17] staging: lustre: allow monolithic
 builds
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708561.7628.11951662173369388423.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Remove restriction the lustre must be built
as modules.  It now works as a monolithic build.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/Kconfig   |    2 +-
 drivers/staging/lustre/lustre/Kconfig |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index 6bcb53d0c6f4..ad049e6f24e4 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -1,6 +1,6 @@
 config LNET
 	tristate "Lustre networking subsystem (LNet)"
-	depends on INET && m
+	depends on INET
 	help
 	  The Lustre network layer, also known as LNet, is a networking abstaction
 	  level API that was initially created to allow Lustre Filesystem to utilize
diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index 90d826946c6a..c669c8fa0cc6 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -1,6 +1,6 @@
 config LUSTRE_FS
 	tristate "Lustre file system client support"
-	depends on m && !MIPS && !XTENSA && !SUPERH
+	depends on !MIPS && !XTENSA && !SUPERH
 	depends on LNET
 	select CRYPTO
 	select CRYPTO_CRC32
