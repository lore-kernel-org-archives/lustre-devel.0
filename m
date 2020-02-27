From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:39 -0500
Subject: [lustre-devel] [PATCH 231/622] lustre: mdc: return DOM size on open
 resend
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-232-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

DOM size is returned along with DOM lock always, but it is
not true with open resend. Fix was server side but we did update
a mdc debug message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11835
Lustre-commit: bc3ef43d36b5 ("LU-11835 mdt: return DOM size on open resend")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34044
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 9898b6a..55de559 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -742,7 +742,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 		body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 		if (!(body->mbo_valid & OBD_MD_DOM_SIZE)) {
-			LDLM_ERROR(lock, "%s: DoM lock without size.\n",
+			LDLM_ERROR(lock, "%s: DoM lock without size.",
 				   exp->exp_obd->obd_name);
 			rc = -EPROTO;
 			goto out_lock;
-- 
1.8.3.1
