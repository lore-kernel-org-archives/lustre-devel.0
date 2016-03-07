From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:22 -0500
Subject: [lustre-devel] [PATCH v2 7/9] staging: lustre: change test to
	assert in LNetGetId
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-8-git-send-email-jsimmons@infradead.org>
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
index a666d49..6c7579e 100644
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
