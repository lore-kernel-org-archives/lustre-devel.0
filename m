From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:42 -0400
Subject: [lustre-devel] [PATCH v2 21/46] staging/lustre/llite: clip page
	correctly for vvp_io_commit_sync
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

The original code was wrong which clipped page incorrectly for
partial pages started with zero.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/8531
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4201
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index fb6f932..e44ef21 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -595,15 +595,17 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 	if (plist->pl_nr == 0)
 		return 0;
 
-	if (from != 0) {
+	if (from > 0 || to != PAGE_SIZE) {
 		page = cl_page_list_first(plist);
-		cl_page_clip(env, page, from,
-			     plist->pl_nr == 1 ? to : PAGE_SIZE);
-	}
-	if (to != PAGE_SIZE && plist->pl_nr > 1) {
+		if (plist->pl_nr == 1) {
+			cl_page_clip(env, page, from, to);
+		} else if (from > 0) {
+			cl_page_clip(env, page, from, PAGE_SIZE);
+		} else {
 		page = cl_page_list_last(plist);
 		cl_page_clip(env, page, 0, to);
 	}
+	}
 
 	cl_2queue_init(queue);
 	cl_page_list_splice(plist, &queue->c2_qin);
-- 
2.1.0
