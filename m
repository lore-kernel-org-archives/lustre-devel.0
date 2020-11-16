From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:54 -0500
Subject: [lustre-devel] [PATCH 21/28] lustre: llite: Avoid eternel retry
 loops with MAP_POPULATE
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

Kernels 5.4+ have an infinite retry loop from MAP_POPULATE mmap
option. Use the FAULT_FLAG_RETRY_NOWAIT to instruct filemap_fault
to not drop the mmap_sem so if the call fails, we could use
the slow path and break the loop from forming.
(Idea by Neil Brown)

WC-bug-id: https://jira.whamcloud.com/browse/LU-13182
Lustre-commit: bb50c62c6f4cdd ("LU-13182 llite: Avoid eternel retry loops with MAP_POPULATE")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40221
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index f77b8f9..f0be7ba 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -288,18 +288,24 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	if (ll_sbi_has_fast_read(ll_i2sbi(file_inode(vma->vm_file)))) {
 		/* do fast fault */
+		bool has_retry = vmf->flags & FAULT_FLAG_RETRY_NOWAIT;
+
+		/* To avoid loops, instruct downstream to not drop mmap_sem */
+		vmf->flags |= FAULT_FLAG_RETRY_NOWAIT;
 		ll_cl_add(vma->vm_file, env, NULL, LCC_MMAP);
 		fault_ret = filemap_fault(vmf);
 		ll_cl_remove(vma->vm_file, env);
+		if (has_retry)
+			vmf->flags &= ~FAULT_FLAG_RETRY_NOWAIT;
 
 		/*
 		 * - If there is no error, then the page was found in cache and
 		 *   uptodate;
 		 * - If VM_FAULT_RETRY is set, the page existed but failed to
-		 *   lock. It will return to kernel and retry;
+		 *   lock. We will try slow path to avoid loops.
 		 * - Otherwise, it should try normal fault under DLM lock.
 		 */
-		if ((fault_ret & VM_FAULT_RETRY) ||
+		if (!(fault_ret & VM_FAULT_RETRY) &&
 		    !(fault_ret & VM_FAULT_ERROR)) {
 			result = 0;
 			goto out;
-- 
1.8.3.1
