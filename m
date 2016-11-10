From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:58 -0500
Subject: [lustre-devel] [PATCH 28/35] staging: lustre: osc: Remove remains
	of osc_ast_guard
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Oleg Drokin <oleg.drokin@intel.com>

osc_ast_guard has been removed by the clio simplification.
Remove the last lock class definition.

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7148
Reviewed-on: http://review.whamcloud.com/16392
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_dev.c     |    2 --
 drivers/staging/lustre/lustre/osc/osc_request.c |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 89f288b..c5d62ae 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -88,8 +88,6 @@ struct lu_kmem_descr osc_caches[] = {
 	}
 };
 
-struct lock_class_key osc_ast_guard_class;
-
 /*****************************************************************************
  *
  * Type conversions.
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c1f5e24..3d5cae9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2789,7 +2789,6 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 };
 
 extern struct lu_kmem_descr osc_caches[];
-extern struct lock_class_key osc_ast_guard_class;
 
 static int __init osc_init(void)
 {
-- 
1.7.1
