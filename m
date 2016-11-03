From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:56 -0400
Subject: [lustre-devel] [PATCH 06/14] staging/lustre/llite: drop_caches
	hangs in cl_inode_fini()
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Perepechko <andrew.perepechko@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Andrew Perepechko <andrew.perepechko@seagate.com>

This patch releases cl_pages on error in ll_write_begin()
to avoid memory and object reference leaks. Also, it
reuses per-cpu lu_env in ll_invalidatepage() in the same
way as done in ll_releasepage().

Signed-off-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Seagate-bug-id: MRP-3504
Reviewed-on: http://review.whamcloud.com/22745
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8509
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 36 ++++++++++++++++--------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 1a08a9d..ca45b44 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -71,8 +71,6 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 	struct cl_page   *page;
 	struct cl_object *obj;
 
-	int refcheck;
-
 	LASSERT(PageLocked(vmpage));
 	LASSERT(!PageWriteback(vmpage));
 
@@ -82,21 +80,21 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 	 * happening with locked page too
 	 */
 	if (offset == 0 && length == PAGE_SIZE) {
-		env = cl_env_get(&refcheck);
-		if (!IS_ERR(env)) {
-			inode = vmpage->mapping->host;
-			obj = ll_i2info(inode)->lli_clob;
-			if (obj) {
-				page = cl_vmpage_page(vmpage, obj);
-				if (page) {
-					cl_page_delete(env, page);
-					cl_page_put(env, page);
-				}
-			} else {
-				LASSERT(vmpage->private == 0);
+		/* See the comment in ll_releasepage() */
+		env = cl_env_percpu_get();
+		LASSERT(!IS_ERR(env));
+		inode = vmpage->mapping->host;
+		obj = ll_i2info(inode)->lli_clob;
+		if (obj) {
+			page = cl_vmpage_page(vmpage, obj);
+			if (page) {
+				cl_page_delete(env, page);
+				cl_page_put(env, page);
 			}
-			cl_env_put(env, &refcheck);
+		} else {
+			LASSERT(vmpage->private == 0);
 		}
+		cl_env_percpu_put(env);
 	}
 }
 
@@ -466,9 +464,9 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  struct page **pagep, void **fsdata)
 {
 	struct ll_cl_context *lcc;
-	const struct lu_env  *env;
+	const struct lu_env *env = NULL;
 	struct cl_io   *io;
-	struct cl_page *page;
+	struct cl_page *page = NULL;
 	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
 	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *vmpage = NULL;
@@ -556,6 +554,10 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			unlock_page(vmpage);
 			put_page(vmpage);
 		}
+		if (!IS_ERR_OR_NULL(page)) {
+			lu_ref_del(&page->cp_reference, "cl_io", io);
+			cl_page_put(env, page);
+		}
 	} else {
 		*pagep = vmpage;
 		*fsdata = lcc;
-- 
2.7.4
