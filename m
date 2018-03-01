From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 17/17] Revert "staging: Disable lustre file
 system for MIPS, SH, and XTENSA"
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708565.7628.14283641203455668904.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This reverts commit 16f1eeb660bd2bfd223704ee6350706b39c55a7a.

The reason for this patch was that lustre used copy_from_user_page.
Commit 76133e66b141 ("staging/lustre: Replace jobid acquiring with per
node setting") removed that usage.
So the arch restrictions can go.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/Kconfig |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index c669c8fa0cc6..ccb78a945995 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -1,6 +1,5 @@
 config LUSTRE_FS
 	tristate "Lustre file system client support"
-	depends on !MIPS && !XTENSA && !SUPERH
 	depends on LNET
 	select CRYPTO
 	select CRYPTO_CRC32
