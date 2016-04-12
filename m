From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:11 -0400
Subject: [lustre-devel] [PATCH v2 11/16] staging: lustre: osc:
	osc_extent_wait() shouldn't be interruptible
In-Reply-To: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
References: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460492056-31792-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Otherwise it will hit the assertion at cl_lock.c:

 cl_lock.c:1967:discard_cb())
  ASSERTION( (!(page->cp_type == CPT_CACHEABLE) ||
  (!PageWriteback(cl_page_vmpage(env, page)))) ) failed:

This is because in osc_lock_flush() we have to make sure the IO
is finished before discarding the pages.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2779
Reviewed-on: http://review.whamcloud.com/5419
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index a5743b4..9723197 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -965,7 +965,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 			"%s: wait ext to %d timedout, recovery in progress?\n",
 			osc_export(obj)->exp_obd->obd_name, state);
 
-		lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+		lwi = LWI_INTR(NULL, NULL);
 		rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state),
 				  &lwi);
 	}
-- 
1.7.1
