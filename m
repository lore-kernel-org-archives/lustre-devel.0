From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:29 -0400
Subject: [lustre-devel] [PATCH 36/58] staging: lustre: lmv: fix issue found
	by Klocwork Insight tool
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

'plock.cookie' might be used uninitialized in this function.

sscanf format specification '%d' expects type 'int *' for 'd',
but parameter 3 has a different type '__u32*'

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9390
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |    6 ++++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c    |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 2bc1098..51b7048 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -137,8 +137,10 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 		it->it_remote_lock_mode = it->it_lock_mode;
 	}
 
-	it->it_lock_handle = plock.cookie;
-	it->it_lock_mode = pmode;
+	if (pmode) {
+		it->it_lock_handle = plock.cookie;
+		it->it_lock_mode = pmode;
+	}
 
 out_free_op_data:
 	kfree(op_data);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e51ea1f..9e3d35a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1421,7 +1421,7 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 
 		obd_str2uuid(&obd_uuid,  lustre_cfg_buf(lcfg, 1));
 
-		if (sscanf(lustre_cfg_buf(lcfg, 2), "%d", &index) != 1) {
+		if (sscanf(lustre_cfg_buf(lcfg, 2), "%u", &index) != 1) {
 			rc = -EINVAL;
 			goto out;
 		}
-- 
1.7.1
