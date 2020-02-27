From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:00 -0500
Subject: [lustre-devel] [PATCH 132/622] lustre: mgc: don't proccess cld
 during stopping
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-133-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The patch fixes the log processing during stopping. It was general
protection fault at mgc_process_cfg_log() at lsi access. Lsi pointer
was wrong 38323172756f6663, and all cld->cld_cfg.cfg_sb had invalid
data.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10595
Lustre-commit: bda43cbe369a ("LU-10595 mgc: don't proccess cld during stopping")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-6199
Reviewed-on: https://review.whamcloud.com/33190
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_request.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index c114aa8..785461b 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1651,6 +1651,11 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 				goto restart;
 			} else {
 				mutex_lock(&cld->cld_lock);
+				/* unlock/lock mutex, so check stopping again */
+				if (cld->cld_stopping) {
+					mutex_unlock(&cld->cld_lock);
+					return 0;
+				}
 				spin_lock(&config_list_lock);
 				cld->cld_lostlock = 1;
 				spin_unlock(&config_list_lock);
-- 
1.8.3.1
