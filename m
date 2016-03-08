From: James Simmons <jsimmons@infradead.org>
Date: Tue,  8 Mar 2016 17:35:27 -0500
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: fixup kernel Kconfig
	option LNET_MAX_PAYLOAD
In-Reply-To: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
References: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457476529-27708-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

A few errors exist for the Kconfig option LNET_MAX_PAYLOAD. First
mistake is the default size is 1MB not 2MB as it is shown to the
person configuring the kernel. Second the LNET_MAX_PAYLOAD option
is more closely related to LNET than the LUSTRE_FS option.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index 00850ee..9c85091 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -3,8 +3,8 @@ config LNET
 	depends on LUSTRE_FS
 
 config LNET_MAX_PAYLOAD
-	int "Lustre lnet max transfer payload (default 2MB)"
-	depends on LUSTRE_FS
+	int "Lustre lnet max transfer payload (default 1MB)"
+	depends on LNET
 	default "1048576"
 	help
 	  This option defines the maximum size of payload in bytes that lnet
-- 
1.7.1
