From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:43 -0400
Subject: [lustre-devel] [PATCH v2 22/46] staging/lustre/llite: deadlock for
	page write
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-23-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Writing thread already locked page #1, and then wait for the
Writeback bit of page #2;

Ptlrpc thread is composing a write RPC, so it sets Writeback on
page #2 and tries to lock page #1 to make it ready.

Deadlocked.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/9036
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4540
Reviewed-by: wangdi <di.wang@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 50d8289..f87238b 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -512,7 +512,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
-	if (unlikely(!vmpage || PageDirty(vmpage))) {
+	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
 		struct ccc_io *cio = ccc_env_io(env);
 		struct cl_page_list *plist = &cio->u.write.cui_queue;
 
@@ -522,7 +522,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 		 * more grants. It's okay for the dirty page to be the first
 		 * one in commit page list, though.
 		 */
-		if (vmpage && PageDirty(vmpage) && plist->pl_nr > 0) {
+		if (vmpage && plist->pl_nr > 0) {
 			unlock_page(vmpage);
 			page_cache_release(vmpage);
 			vmpage = NULL;
-- 
2.1.0
