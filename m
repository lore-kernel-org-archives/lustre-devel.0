From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:14 -0400
Subject: [lustre-devel] [PATCH 05/12] staging: lustre: obd: cleanup client
	import if client_obd_setup fails
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Swapnil Pimpale <spimpale@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Swapnil Pimpale <spimpale@ddn.com>

client_obd_setup() allocates an obd_import which should be cleaned up
if there is any failure afterwards in callers of client_obd_setup().
This patch fixes the bug in osc_setup(), mgc_setup(), mdc_setup() and
lwp_setup(). The fix is to call obd_cleanup_client_import() before
calling client_obd_cleanup() in case of an error.

Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3810
Reviewed-on: http://review.whamcloud.com/7561
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 932aef2..00c93f3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -439,6 +439,7 @@ int client_obd_cleanup(struct obd_device *obddev)
 	ldlm_namespace_free_post(obddev->obd_namespace);
 	obddev->obd_namespace = NULL;
 
+	obd_cleanup_client_import(obddev);
 	LASSERT(!obddev->u.cli.cl_import);
 
 	ldlm_put_ref();
-- 
2.7.4
