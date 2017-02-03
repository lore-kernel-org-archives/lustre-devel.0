From: Jan Kara <jack@suse.cz>
Date: Fri,  3 Feb 2017 16:07:29 +0100
Subject: [lustre-devel] [PATCH] mm: Avoid returning VM_FAULT_RETRY from
	->page_mkwrite handlers
Message-ID: <20170203150729.15863-1-jack@suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
from ->page_mkwrite is completely unhandled by the mm code and results
in locking and writeably mapping the page which definitely is not what
the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
results in bailing out from the fault code, the CPU then retries the
access, and we fault again effectively doing what the handler wanted.

CC: lustre-devel at lists.lustre.org
CC: cluster-devel at redhat.com
Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c | 4 +---
 include/linux/buffer_head.h                      | 4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index ee01f20d8b11..9afa6bec3e6f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -390,15 +390,13 @@ static int ll_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		result = VM_FAULT_LOCKED;
 		break;
 	case -ENODATA:
+	case -EAGAIN:
 	case -EFAULT:
 		result = VM_FAULT_NOPAGE;
 		break;
 	case -ENOMEM:
 		result = VM_FAULT_OOM;
 		break;
-	case -EAGAIN:
-		result = VM_FAULT_RETRY;
-		break;
 	default:
 		result = VM_FAULT_SIGBUS;
 		break;
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index d67ab83823ad..79591c3660cc 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -243,12 +243,10 @@ static inline int block_page_mkwrite_return(int err)
 {
 	if (err == 0)
 		return VM_FAULT_LOCKED;
-	if (err == -EFAULT)
+	if (err == -EFAULT || err == -EAGAIN)
 		return VM_FAULT_NOPAGE;
 	if (err == -ENOMEM)
 		return VM_FAULT_OOM;
-	if (err == -EAGAIN)
-		return VM_FAULT_RETRY;
 	/* -ENOSPC, -EDQUOT, -EIO ... */
 	return VM_FAULT_SIGBUS;
 }
-- 
2.10.2
