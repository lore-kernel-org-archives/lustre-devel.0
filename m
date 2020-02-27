From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:49 -0500
Subject: [lustre-devel] [PATCH 061/622] lustre: osc: increase default
 max_dirty_mb to 2G
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-62-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

While ideally we want to go away from max_dirty_mb setting
completely and let grants code to take the msot part of it,
Andreas raises a somewhat valid point that for certain
system configurations with high-latency links, system
administrators might want to have ability to limit
amount of dirty pages just for those OSCs to limit amount
of time it might take to flush that dirty data.

So a good compromise is to lift the max_dirty_mb default
value first while we work out the current grant code
deficiencies

WC-bug-id: https://jira.whamcloud.com/browse/LU-10990
Lustre-commit: 92e2b514e06c ("LU-10990 osc: increase default max_dirty_mb to 2G")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32288
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 99577e4..d2bd234 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -127,7 +127,7 @@ struct timeout_item {
 #define OBD_MAX_RIF_DEFAULT	8
 #define OBD_MAX_RIF_MAX		512
 #define OSC_MAX_RIF_MAX		256
-#define OSC_MAX_DIRTY_DEFAULT	(OBD_MAX_RIF_DEFAULT * 4)
+#define OSC_MAX_DIRTY_DEFAULT	2000	/* Arbitrary large value */
 #define OSC_MAX_DIRTY_MB_MAX	2048	/* arbitrary, but < MAX_LONG bytes */
 #define OSC_DEFAULT_RESENDS	10
 
-- 
1.8.3.1
