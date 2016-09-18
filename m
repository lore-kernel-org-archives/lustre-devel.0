From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:17 -0400
Subject: [lustre-devel] [PATCH 078/124] staging: lustre: llog: prevent
	out-of-bound index
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-79-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

llog_process_thread() can be called from llog_cat_process_cb with an
index already out of bound, leading to the following crash:

LustreError: 3773:0:(llog.c:310:llog_process_thread())
  ASSERTION(index <= last_index + 1 ) failed:
LustreError: 3773:0:(llog.c:310:llog_process_thread()) LBUG

 #0 [ffff8801144bf900] machine_kexec at ffffffff81038f3b
 #1 [ffff8801144bf960] crash_kexec at ffffffff810c5d82
 #2 [ffff8801144bfa30] panic at ffffffff8152798a
 #3 [ffff8801144bfab0] lbug_with_loc at ffffffffa02f8eeb [libcfs]
 #4 [ffff8801144bfad0] llog_process_thread at ffffffffa0413fff [obdclass]
 #5 [ffff8801144bfb80] llog_process_or_fork at ffffffffa041585f [obdclass]
 #6 [ffff8801144bfbd0] llog_cat_process_cb at ffffffffa0418612 [obdclass]
 #7 [ffff8801144bfc30] llog_process_thread at ffffffffa0413c22 [obdclass]
 #8 [ffff8801144bfce0] llog_process_or_fork at ffffffffa041585f [obdclass]
 #9 [ffff8801144bfd30] llog_cat_process_or_fork at ffffffffa0416b9d [obdclass]

If index is too big, simply return success.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5635
Reviewed-on: http://review.whamcloud.com/12161
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 119372c..43797f1 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -235,6 +235,10 @@ static int llog_process_thread(void *arg)
 	else
 		last_index = LLOG_BITMAP_BYTES * 8 - 1;
 
+	/* Record is not in this buffer. */
+	if (index > last_index)
+		goto out;
+
 	while (rc == 0) {
 		struct llog_rec_hdr *rec;
 
-- 
1.7.1
