From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:50 -0500
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: report minimum of two
	buffers for LNet selftest load test
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The minimum number reserve buffer for lnet selftest load test is two
not one.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/framework.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index ed2f7e9..54ad6d8 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -588,7 +588,7 @@ sfw_load_test(struct sfw_test_instance *tsi)
 
 	CDEBUG(D_NET, "Reserved %d buffers for test %s\n",
 	       nbuf * (srpc_serv_is_framework(svc) ?
-		       1 : cfs_cpt_number(cfs_cpt_table)), svc->sv_name);
+		       2 : cfs_cpt_number(cfs_cpt_table)), svc->sv_name);
 	return 0;
 }
 
-- 
1.7.1
