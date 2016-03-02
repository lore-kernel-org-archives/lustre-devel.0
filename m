From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:58 -0500
Subject: [lustre-devel] [PATCH 15/27] staging: lustre: fix framework.c
	issues found by Klocwork Insight tool
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <dmitry.eremin@intel.com>

The functions sfw_test_buffers() and sfw_unload_test() from LNet
selftest both assume sfw_test_instance_t being passed in is never
null. This is corrected here.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9386
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 3bbc720..e4a9724 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -541,10 +541,16 @@ sfw_test_rpc_fini(srpc_client_rpc_t *rpc)
 static inline int
 sfw_test_buffers(sfw_test_instance_t *tsi)
 {
-	struct sfw_test_case *tsc = sfw_find_test_case(tsi->tsi_service);
-	struct srpc_service *svc = tsc->tsc_srv_service;
+	struct sfw_test_case *tsc;
+	struct srpc_service *svc;
 	int nbuf;
 
+	LASSERT(tsi);
+	tsc = sfw_find_test_case(tsi->tsi_service);
+	LASSERT(tsc);
+	svc = tsc->tsc_srv_service;
+	LASSERT(svc);
+
 	nbuf = min(svc->sv_wi_total, tsi->tsi_loop) / svc->sv_ncpts;
 	return max(SFW_TEST_WI_MIN, nbuf + SFW_TEST_WI_EXTRA);
 }
@@ -591,8 +597,10 @@ sfw_load_test(struct sfw_test_instance *tsi)
 static void
 sfw_unload_test(struct sfw_test_instance *tsi)
 {
-	struct sfw_test_case *tsc = sfw_find_test_case(tsi->tsi_service);
+	struct sfw_test_case *tsc;
 
+	LASSERT(tsi);
+	tsc = sfw_find_test_case(tsi->tsi_service);
 	LASSERT(tsc);
 
 	if (tsi->tsi_is_client)
-- 
1.7.1
