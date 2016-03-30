From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:44 -0400
Subject: [lustre-devel] [PATCH v2 23/46] staging/lustre/llite: make sure we
	do cl_page_clip on the last page
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Dongyang <dongyang.li@anu.edu.au>, Oleg Drokin <green@linuxhacker.ru>

From: Li Dongyang <dongyang.li@anu.edu.au>

When we are doing a partial IO on both first and last page,
the logic currently only call cl_page_clip on the first page, which
will end up with a incorrect i_size.

Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Reviewed-on: http://review.whamcloud.com/11630
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5552
Reviewed-by: Ian Costello <costello.ian@gmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Li Xi <pkuelelixi@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index e44ef21..1d2fc3b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -599,12 +599,14 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 		page = cl_page_list_first(plist);
 		if (plist->pl_nr == 1) {
 			cl_page_clip(env, page, from, to);
-		} else if (from > 0) {
-			cl_page_clip(env, page, from, PAGE_SIZE);
 		} else {
-		page = cl_page_list_last(plist);
-		cl_page_clip(env, page, 0, to);
-	}
+			if (from > 0)
+				cl_page_clip(env, page, from, PAGE_SIZE);
+			if (to != PAGE_SIZE) {
+				page = cl_page_list_last(plist);
+				cl_page_clip(env, page, 0, to);
+			}
+		}
 	}
 
 	cl_2queue_init(queue);
-- 
2.1.0
