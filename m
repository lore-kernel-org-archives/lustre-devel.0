From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:33 -0500
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: handle error returned
	from wait_event_timeout seltest timer
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The function wait_event_timeout can fail and return an error. Handle
this case in stt_timer_main().

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/timer.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index 8be5252..ef8a8a7 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -170,20 +170,22 @@ stt_check_timers(unsigned long *last)
 static int
 stt_timer_main(void *arg)
 {
+	int rc = 0;
+
 	cfs_block_allsigs();
 
 	while (!stt_data.stt_shuttingdown) {
 		stt_check_timers(&stt_data.stt_prev_slot);
 
-		wait_event_timeout(stt_data.stt_waitq,
-				   stt_data.stt_shuttingdown,
-				   cfs_time_seconds(STTIMER_SLOTTIME));
+		rc = wait_event_timeout(stt_data.stt_waitq,
+					stt_data.stt_shuttingdown,
+					cfs_time_seconds(STTIMER_SLOTTIME));
 	}
 
 	spin_lock(&stt_data.stt_lock);
 	stt_data.stt_nthreads--;
 	spin_unlock(&stt_data.stt_lock);
-	return 0;
+	return rc;
 }
 
 static int
-- 
1.7.1
