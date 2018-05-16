From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:36 +0200
Subject: [lustre-devel] [PATCH 02/14] fs: make the filemap_page_mkwrite
 prototype consistent
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-3-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

!CONFIG_MMU version didn't agree with the rest of the kernel..

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..cf21ced98eff 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2748,7 +2748,7 @@ int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
 	return generic_file_mmap(file, vma);
 }
 #else
-int filemap_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf)
 {
 	return -ENOSYS;
 }
-- 
2.17.0
