From: Bhumika Goyal <bhumirks@gmail.com>
Date: Fri, 29 Jan 2016 14:14:26 +0530
Subject: [lustre-devel] [PATCH] Staging:lustre:lclient:Remove unused function
Message-ID: <1454057066-16834-1-git-send-email-bhumirks@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Bhumika Goyal <bhumirks@gmail.com>

Discard the function ccc_vmpage_page_transient as it is not used
anywhere in the kernel.
Used grep to find occurences.
Problem found using sparse.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index 34dde7d..4dfeb4e 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -986,17 +986,6 @@ struct inode *ccc_object_inode(const struct cl_object *obj)
 }
 
 /**
- * Returns a pointer to cl_page associated with \a vmpage, without acquiring
- * additional reference to the resulting page. This is an unsafe version of
- * cl_vmpage_page() that can only be used under vmpage lock.
- */
-struct cl_page *ccc_vmpage_page_transient(struct page *vmpage)
-{
-	KLASSERT(PageLocked(vmpage));
-	return (struct cl_page *)vmpage->private;
-}
-
-/**
  * Initialize or update CLIO structures for regular files when new
  * meta-data arrives from the server.
  *
-- 
1.9.1
