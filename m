From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:16 -0400
Subject: [lustre-devel] [PATCH 37/42] lustre: osc: Do ELC on locks with no
 OSC object
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Currently, osc_ldlm_weigh_ast weighs locks with no OSC
object in their ast data as "1", meaning the lock is not
considered for ELC.

This doesn't make much sense, since if there is no OSC
object, it's unlikely there's any data under the lock, so
it's actually a good candidate for ELC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: 36eca1017fe464 ("LU-11518 osc: Do ELC on locks with no OSC object")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34584
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index ed9f0a0..7bfcbfb 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -722,7 +722,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 	unlock_res_and_lock(dlmlock);
 
 	if (!obj) {
-		weight = 1;
+		weight = 0;
 		goto out;
 	}
 
-- 
1.8.3.1
