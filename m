From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 12 Apr 2016 21:11:09 -0400
Subject: [lustre-devel] [PATCH 2/2] staging/lustre/llite: suppress non
	active IO error message
In-Reply-To: <1460509869-3288664-1-git-send-email-green@linuxhacker.ru>
References: <1460509869-3288664-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1460509869-3288664-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bobi Jam <bobijam.xu@intel.com>

Current CLIO does not support fadvise, suppress the error message.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reviewed-on: http://review.whamcloud.com/9658
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4717
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index fee319c..4ddf8b3 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -111,16 +111,9 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	vio = vvp_env_io(env);
 	io = vio->vui_cl.cis_io;
 	lcc->lcc_io = io;
-	if (!io) {
-		struct inode *inode = file_inode(file);
-
-		CERROR("%s: " DFID " no active IO, please file a ticket.\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)));
-		dump_stack();
-
+	if (!io)
 		result = -EIO;
-	}
+
 	if (result == 0 && vmpage) {
 		struct cl_page   *page;
 
-- 
2.1.0
