From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 03/17] staging: lustre: LNET excludes USERIO
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760832.27689.17304570282712555631.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

LNET_MINOR and USERIO_MINOR are the same value, so
they cannot both be used in the same kernel.
Until this is resolved, don't allow them to be built
together.  This saves automatic testing from noticing this
known problem.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index ad049e6f24e4..fe4b24acf075 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -1,6 +1,6 @@
 config LNET
 	tristate "Lustre networking subsystem (LNet)"
-	depends on INET
+	depends on INET && !USERIO
 	help
 	  The Lustre network layer, also known as LNet, is a networking abstaction
 	  level API that was initially created to allow Lustre Filesystem to utilize
