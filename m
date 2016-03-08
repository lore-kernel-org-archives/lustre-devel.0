From: James Simmons <jsimmons@infradead.org>
Date: Tue,  8 Mar 2016 17:35:28 -0500
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: add help section of
	Kconfig config LNET
In-Reply-To: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
References: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457476529-27708-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Include a help section for Kconfig LNET.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/Kconfig |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index 9c85091..980ce44 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -1,6 +1,12 @@
 config LNET
-	tristate "Lustre networking subsystem"
+	tristate "Lustre networking subsystem (LNet)"
 	depends on LUSTRE_FS
+	help
+	  The Lustre network layer, also known as LNet, is a networking abstaction
+	  level API that was initially created to allow Lustre Filesystem to utilize
+	  very different networks like tcp and ib verbs in a uniform way. In the
+	  case of Lustre routers only the LNet layer is required. Lately other
+	  projects are also looking into using LNet as their networking API as well.
 
 config LNET_MAX_PAYLOAD
 	int "Lustre lnet max transfer payload (default 1MB)"
-- 
1.7.1
