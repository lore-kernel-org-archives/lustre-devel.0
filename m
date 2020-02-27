From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:24 -0500
Subject: [lustre-devel] [PATCH 216/622] lustre: llite: ll_fault should fail
 for insane file offsets
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-217-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Zarochentsev <c17826@cray.com>

A page fault for a mmapped lustre file at offset large than
2^63 cause Lustre client to hang due to wrong page index
calculations from signed loff_t.
There is no need to do such calclulations but perform
page offset sanity checks in ll_fault().

Cray-bug-id: LUS-1392
WC-bug-id: https://jira.whamcloud.com/browse/LU-8299
Lustre-commit: ada3b33b52cd ("LU-8299 llite: ll_fault should fail for insane file offsets")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/34242
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 14080b6..236d1d2 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -373,6 +373,9 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
 			   LPROC_LL_FAULT, 1);
 
+	/* make sure offset is not a negative number */
+	if (vmf->pgoff > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
+		return VM_FAULT_SIGBUS;
 restart:
 	result = __ll_fault(vmf->vma, vmf);
 	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
-- 
1.8.3.1
