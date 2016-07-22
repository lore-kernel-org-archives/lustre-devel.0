From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:59 -0400
Subject: [lustre-devel] [PATCH 06/58] staging: lustre: mdc: handle
	IT_READDIR operations
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The readdir operations lock was incomplete. This
patch fills in the missing pieces.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h   |    4 +++-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c |    8 +++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 1575c82..17b8d22 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -801,9 +801,11 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 	/* CREAT needs to be tested before open (both could be set) */
 	if (it->it_op & IT_CREAT)
 		return LCK_CW;
-	else if (it->it_op & (IT_READDIR | IT_GETATTR | IT_OPEN | IT_LOOKUP |
+	else if (it->it_op & (IT_GETATTR | IT_OPEN | IT_LOOKUP |
 			      IT_LAYOUT))
 		return LCK_CR;
+	else if (it->it_op & IT_READDIR)
+		return LCK_PR;
 	else if (it->it_op &  IT_GETXATTR)
 		return LCK_PR;
 	else if (it->it_op &  IT_SETXATTR)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index f48b584..06a1274 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -903,6 +903,9 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	LASSERT(request != LP_POISON);
 	LASSERT(request->rq_repmsg != LP_POISON);
 
+	if (it->it_op & IT_READDIR)
+		return 0;
+
 	if (!it_disposition(it, DISP_IT_EXECD)) {
 		/* The server failed before it even started executing the
 		 * intent, i.e. because it couldn't unpack the request.
@@ -1042,6 +1045,9 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 						  MDS_INODELOCK_LOOKUP |
 						  MDS_INODELOCK_PERM;
 			break;
+		case IT_READDIR:
+			policy.l_inodebits.bits = MDS_INODELOCK_UPDATE;
+			break;
 		case IT_LAYOUT:
 			policy.l_inodebits.bits = MDS_INODELOCK_LAYOUT;
 			break;
@@ -1119,7 +1125,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 	lockh.cookie = 0;
 	if (fid_is_sane(&op_data->op_fid2) &&
-	    (it->it_op & (IT_LOOKUP | IT_GETATTR))) {
+	    (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_READDIR))) {
 		/* We could just return 1 immediately, but since we should only
 		 * be called in revalidate_it if we already have a lock, let's
 		 * verify that.
-- 
1.7.1
