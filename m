From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:47 -0500
Subject: [lustre-devel] [PATCH 09/19] staging: lustre: lnet: fill in real
	lnet_md_t
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

While checkpatch reported an alignment issue
its just ugly to fill in a data structure being
passed to a function. Instead fill in a lnet_md_t
on the stack and pass that to LNetMDBind.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/router.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 063ad55..8afa0ab 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -903,6 +903,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	lnet_rc_data_t *rcd = NULL;
 	lnet_ping_info_t *pi;
+	lnet_md_t md;
 	int rc;
 	int i;
 
@@ -925,15 +926,15 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 	rcd->rcd_pinginfo = pi;
 
+	md.start = pi;
+	md.user_ptr = rcd;
+	md.length = LNET_PINGINFO_SIZE;
+	md.threshold = LNET_MD_THRESH_INF;
+	md.options = LNET_MD_TRUNCATE;
+	md.eq_handle = the_lnet.ln_rc_eqh;
+
 	LASSERT(!LNetHandleIsInvalid(the_lnet.ln_rc_eqh));
-	rc = LNetMDBind((lnet_md_t){.start     = pi,
-				    .user_ptr  = rcd,
-				    .length    = LNET_PINGINFO_SIZE,
-				    .threshold = LNET_MD_THRESH_INF,
-				    .options   = LNET_MD_TRUNCATE,
-				    .eq_handle = the_lnet.ln_rc_eqh},
-			LNET_UNLINK,
-			&rcd->rcd_mdh);
+	rc = LNetMDBind(md, LNET_UNLINK, &rcd->rcd_mdh);
 	if (rc < 0) {
 		CERROR("Can't bind MD: %d\n", rc);
 		goto out;
-- 
1.7.1
