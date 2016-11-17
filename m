From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:44 -0500
Subject: [lustre-devel] [PATCH 06/19] staging: lustre: lnet: fix misspelled
	word destroy
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Fix misspelling of destroy in LNet core.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 4daf828..b2ba10d 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1551,16 +1551,16 @@ void lnet_lib_exit(void)
 
 		rc = lnet_check_routes();
 		if (rc)
-			goto err_destory_routes;
+			goto err_destroy_routes;
 
 		rc = lnet_rtrpools_alloc(im_a_router);
 		if (rc)
-			goto err_destory_routes;
+			goto err_destroy_routes;
 	}
 
 	rc = lnet_acceptor_start();
 	if (rc)
-		goto err_destory_routes;
+		goto err_destroy_routes;
 
 	the_lnet.ln_refcount = 1;
 	/* Now I may use my own API functions... */
@@ -1587,7 +1587,7 @@ void lnet_lib_exit(void)
 err_acceptor_stop:
 	the_lnet.ln_refcount = 0;
 	lnet_acceptor_stop();
-err_destory_routes:
+err_destroy_routes:
 	if (!the_lnet.ln_nis_from_mod_params)
 		lnet_destroy_routes();
 err_shutdown_lndnis:
-- 
1.7.1
