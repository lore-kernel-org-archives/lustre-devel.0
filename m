From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:53 -0400
Subject: [lustre-devel] [PATCH 2/9] staging: lustre: osc: Allow lock to be
	canceled at ENQ time
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander_boyko@xyratex.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander_boyko@xyratex.com>

A cl_lock can be canceled when it's in CLS_ENQUEUED state.
We can't unuse this kind of lock in lov_lock_unuse() because
it will bring this lock into CLS_NEW state and then confuse
osc_lock_upcall().

Add a regression test case by Alexander Boyko.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Alexander Boyko <alexander_boyko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3889
Reviewed-on: http://review.whamcloud.com/8405
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_support.h | 1 +
 drivers/staging/lustre/lustre/osc/osc_request.c     | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 1358af1..60034d3 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -321,6 +321,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LDLM_AGL_DELAY	  0x31a
 #define OBD_FAIL_LDLM_AGL_NOLOCK	 0x31b
 #define OBD_FAIL_LDLM_OST_LVB		 0x31c
+#define OBD_FAIL_LDLM_ENQUEUE_HANG	 0x31d
 
 /* LOCKLESS IO */
 #define OBD_FAIL_LDLM_SET_CONTENTION     0x385
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index df06f4f..47417f8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2201,6 +2201,9 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	 */
 	ldlm_lock_addref(lockh, mode);
 
+	/* Let cl_lock_state_wait fail with -ERESTARTSYS to unuse sublocks. */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
+
 	/* Let CP AST to grant the lock first. */
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
-- 
2.7.4
