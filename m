From: James Simmons <jsimmons@infradead.org>
Date: Fri,  4 Mar 2016 21:09:48 -0500
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: change test to asser
	in LNetGetId
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457143790-19422-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The ln_refcount test was changed into an assert.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7395985..4843980 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2090,9 +2090,7 @@ LNetGetId(unsigned int index, lnet_process_id_t *id)
 	int cpt;
 	int rc = -ENOENT;
 
-	/* LNetNI initilization failed? */
-	if (!the_lnet.ln_refcount)
-		return rc;
+	LASSERT(the_lnet.ln_refcount > 0);
 
 	cpt = lnet_net_lock_current();
 
-- 
1.7.1
