From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:04 -0500
Subject: [lustre-devel] [PATCH 256/622] lustre: llite: ll_fault fixes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-257-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Various error conditions in the fault path can cause us to
not return a page in vm_fault.  Check if it's present
before accessing it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11403
Lustre-commit: a8f4d1e5fd79 ("LU-11403 llite: ll_fault fixes")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34247
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 236d1d2..37ce508 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -378,7 +378,8 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 		return VM_FAULT_SIGBUS;
 restart:
 	result = __ll_fault(vmf->vma, vmf);
-	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
+	if (vmf->page &&
+	    !(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
 		struct page *vmpage = vmf->page;
 
 		/* check if this page has been truncated */
-- 
1.8.3.1
