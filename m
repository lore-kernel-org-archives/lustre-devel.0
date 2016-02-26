From: James Simmons <jsimmons@infradead.org>
Date: Fri, 26 Feb 2016 11:36:02 -0500
Subject: [lustre-devel] [PATCH v3 2/6] staging: lustre: add missing
	MODULE_AUTHOR for LNet selftest module
In-Reply-To: <1456504566-21176-1-git-send-email-jsimmons@infradead.org>
References: <1456504566-21176-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456504566-21176-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

For LNet selftest module the MODULE_AUTHOR was missing.
Add proper OpenSFS authorship. Broken out of patch
http://review.whamcloud.com/16787.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16787
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/module.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index cbb7884..3e48b0a 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -148,6 +148,7 @@ error:
 	return rc;
 }
 
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("LNet Selftest");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("0.9.0");
-- 
1.7.1
