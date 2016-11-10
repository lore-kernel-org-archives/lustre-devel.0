From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:53 -0500
Subject: [lustre-devel] [PATCH 23/35] staging: lustre: ldlm: improve lock
	timeout messages
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In ldlm_expired_completion_wait() remove the useless LCONSOLE_WARN()
message and upgrade the LDLM_DEBUG() statement to LDLM_ERROR().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7296
Reviewed-on: http://review.whamcloud.com/16824
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 6a96f2c..836789f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -93,11 +93,7 @@ static int ldlm_expired_completion_wait(void *data)
 	if (!lock->l_conn_export) {
 		static unsigned long next_dump, last_dump;
 
-		LCONSOLE_WARN("lock timed out (enqueued at %lld, %llds ago)\n",
-			      (s64)lock->l_last_activity,
-			      (s64)(ktime_get_real_seconds() -
-				    lock->l_last_activity));
-		LDLM_DEBUG(lock, "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
+		LDLM_ERROR(lock, "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
 			   (s64)lock->l_last_activity,
 			   (s64)(ktime_get_real_seconds() -
 				 lock->l_last_activity));
-- 
1.7.1
