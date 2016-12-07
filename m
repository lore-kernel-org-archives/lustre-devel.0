From: James Simmons <jsimmons@infradead.org>
Date: Wed,  7 Dec 2016 17:55:17 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: make
	brw_inject_one_error() static
Message-ID: <1481151317-17688-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

It's not used anywhere outside of brw_test.c file.
Highlighted by sparse.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 67b460f..b9ac34e 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -136,7 +136,7 @@
 	return 0;
 }
 
-int brw_inject_one_error(void)
+static int brw_inject_one_error(void)
 {
 	struct timespec64 ts;
 
-- 
1.8.3.1
