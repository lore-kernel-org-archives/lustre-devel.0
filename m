From: Karthik Nayak <karthik.188@gmail.com>
Date: Fri, 23 Dec 2016 15:42:13 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: selftest: Make
	brw_inject_one_error() static
Message-ID: <20161223154244.29145-1-Karthik.188@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
Cc: lustre-devel@lists.lustre.org, kirill.shutemov@linux.intel.com, liang.zhen@intel.com, gregkh@linuxfoundation.org, jsimmons@infradead.org, andreas.dilger@intel.com, oleg.drokin@intel.com, Karthik Nayak <Karthik.188@gmail.com>

Since the function brw_inject_one_error() is used only within
brw_test.c, make it static. This was reported as a warning by sparse.

Signed-off-by: Karthik Nayak <Karthik.188@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 67b460f..b9ac34e 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -136,7 +136,7 @@ brw_client_init(struct sfw_test_instance *tsi)
 	return 0;
 }
 
-int brw_inject_one_error(void)
+static int brw_inject_one_error(void)
 {
 	struct timespec64 ts;
 
-- 
2.10.2
