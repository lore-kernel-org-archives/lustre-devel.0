From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:49 -0400
Subject: [lustre-devel] [PATCH 150/151] lustre: remove outdated comments
 about ->ap_* functions.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-151-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

->ap_make_ready, ->ap_completion, ap_refresh count all no longer
exist.
So remove these comments.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index e94774b..6e779cf 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -224,14 +224,7 @@ struct client_obd {
 	 */
 	/*
 	 * ->cl_loi_list_lock protects consistency of
-	 * ->cl_loi_{ready,read,write}_list. ->ap_make_ready() and
-	 * ->ap_completion() call-backs are executed under this lock. As we
-	 * cannot guarantee that these call-backs never block on all platforms
-	 * (as a matter of fact they do block on Mac OS X), type of
-	 * ->cl_loi_list_lock is platform dependent: it's a spin-lock on Linux
-	 * and blocking mutex on Mac OS X. (Alternative is to make this lock
-	 * blocking everywhere, but we don't want to slow down fast-path of
-	 * our main platform.)
+	 * ->cl_loi_{ready,read,write}_list.
 	 *
 	 * NB by Jinshan: though field names are still _loi_, but actually
 	 * osc_object{}s are in the list.
-- 
1.8.3.1
