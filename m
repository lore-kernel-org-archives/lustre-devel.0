From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 23 Aug 2016 17:11:39 -0400
Subject: [lustre-devel] [PATCH 5/8] staging/lustre/llite: Fix suspicious
	dereference of pointer 'vma->vm_file'
In-Reply-To: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
References: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471986702-682922-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Remove useless LASSERT(vma->vm_file) because of if it's NULL it
will crash early in file_inode(vma->vm_file).

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-on: http://review.whamcloud.com/21171
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8372
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 9d03e79..37f82ed 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -429,7 +429,6 @@ static void ll_vm_open(struct vm_area_struct *vma)
 	struct inode *inode    = file_inode(vma->vm_file);
 	struct vvp_object *vob = cl_inode2vvp(inode);
 
-	LASSERT(vma->vm_file);
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
 	atomic_inc(&vob->vob_mmap_cnt);
 }
@@ -442,7 +441,6 @@ static void ll_vm_close(struct vm_area_struct *vma)
 	struct inode      *inode = file_inode(vma->vm_file);
 	struct vvp_object *vob   = cl_inode2vvp(inode);
 
-	LASSERT(vma->vm_file);
 	atomic_dec(&vob->vob_mmap_cnt);
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
 }
-- 
2.7.4
