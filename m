From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:56 -0400
Subject: [lustre-devel] [PATCH 19/45] lustre: llite: clean up
 pcc_layout_wait()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

pcc_layout_wait() contains a pointless while loop (and an unnecessary
blank line) and is a trivial function that is only called once.

So move the code into __pcc_layout_invalidate(), remove the while
loop, and generally tidy up.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: c5a311781fc60 ("LU-10467 llite: clean up pcc_layout_wait()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38403
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/pcc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index e0628b9..391733e 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1968,20 +1968,17 @@ int pcc_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return rc;
 }
 
-static void pcc_layout_wait(struct pcc_inode *pcci)
-{
-	if (atomic_read(&pcci->pcci_active_ios) > 0)
-		CDEBUG(D_CACHE, "Waiting for IO completion: %d\n",
-		       atomic_read(&pcci->pcci_active_ios));
-	wait_event_idle(pcci->pcci_waitq,
-			atomic_read(&pcci->pcci_active_ios) == 0);
-}
-
 static void __pcc_layout_invalidate(struct pcc_inode *pcci)
 {
 	pcci->pcci_type = LU_PCC_NONE;
 	pcc_layout_gen_set(pcci, CL_LAYOUT_GEN_NONE);
-	pcc_layout_wait(pcci);
+	if (atomic_read(&pcci->pcci_active_ios) == 0)
+		return;
+
+	CDEBUG(D_CACHE, "Waiting for IO completion: %d\n",
+	       atomic_read(&pcci->pcci_active_ios));
+	wait_event_idle(pcci->pcci_waitq,
+			atomic_read(&pcci->pcci_active_ios) == 0);
 }
 
 void pcc_layout_invalidate(struct inode *inode)
-- 
1.8.3.1
