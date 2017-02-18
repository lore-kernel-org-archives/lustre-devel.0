From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:10 -0500
Subject: [lustre-devel] [PATCH 09/14] staging: lustre: ldlm: reduce ldlm
	pool recalc window
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

Reduce the sleep period from 50 seconds down to
LDLM_POOL_CLI_DEF_RECALC_PERIOD which is 10 seconds.

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3031
Xyratex-bug-id: MRP-395 MRP-1366 MRP-1366
Reviewed-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Reviewed-by: Alexey Lyashkov <Alexey_Lyashkov@xyratex.com>
Reviewed-on: http://review.whamcloud.com/5843
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 8dfb3c8..13fbbed 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -900,8 +900,9 @@ static int ldlm_pools_recalc(enum ldlm_side client)
 {
 	struct ldlm_namespace *ns;
 	struct ldlm_namespace *ns_old = NULL;
+	/* seconds of sleep if no active namespaces */
+	int time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
 	int nr;
-	int time = 50; /* seconds of sleep if no active namespaces */
 
 	/*
 	 * Recalc at least ldlm_namespace_nr_read(client) namespaces.
-- 
1.8.3.1
