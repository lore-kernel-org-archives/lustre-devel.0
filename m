From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:44 -0400
Subject: [lustre-devel] [PATCH 31/80] staging: lustre: llite: avoid a
	deadlock in page write
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

For a partial page write, it will have to issue a READ RPC firstly
to get a full uptodate page. If another page is already locked by
this thread it can easily cause deadlock.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4873
Reviewed-on: http://review.whamcloud.com/9928
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index d98c7ac..c14a1b6 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -506,8 +506,9 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	env = lcc->lcc_env;
 	io  = lcc->lcc_io;
 
-	/* To avoid deadlock, try to lock page first. */
-	vmpage = grab_cache_page_nowait(mapping, index);
+	if (likely(to == PAGE_SIZE)) /* LU-4873 */
+		/* To avoid deadlock, try to lock page first. */
+		vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
 		struct vvp_io *vio = vvp_env_io(env);
 		struct cl_page_list *plist = &vio->u.write.vui_queue;
-- 
1.7.1
