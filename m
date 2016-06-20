From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:50 -0400
Subject: [lustre-devel] [PATCH v2 27/29] staging/lustre/osc: glimpse lock
	should match only with granted locks
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <andriy.skulysh@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Andriy Skulysh <andriy.skulysh@seagate.com>

A deadlock is possible during ccc_prep_size()->ldlm_lock_match() vs
cl_io_lock() which is waiting for a matched lock and conflicts with
already taken lock before ccc_prep_size().

It is better to send an additional lock request to avoid deadlock.

Seagate-bug-id: MRP-3312
Signed-off-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Reviewed-on: http://review.whamcloud.com/18738
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7829
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_request.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 9334349..536b868 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2246,7 +2246,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	struct lustre_handle lockh = { 0 };
 	struct ptlrpc_request *req = NULL;
 	int intent = *flags & LDLM_FL_HAS_INTENT;
-	__u64 match_lvb = agl ? 0 : LDLM_FL_LVB_READY;
+	__u64 match_flags = *flags;
 	enum ldlm_mode mode;
 	int rc;
 
@@ -2281,7 +2281,11 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
-	mode = ldlm_lock_match(obd->obd_namespace, *flags | match_lvb, res_id,
+	if (agl == 0)
+		match_flags |= LDLM_FL_LVB_READY;
+	if (intent != 0)
+		match_flags |= LDLM_FL_BLOCK_GRANTED;
+	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
 			       einfo->ei_type, policy, mode, &lockh, 0);
 	if (mode) {
 		struct ldlm_lock *matched;
-- 
2.7.4
