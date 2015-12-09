From: Niranjan Dighe <niranjan.dighe@gmail.com>
Date: Wed, 9 Dec 2015 22:38:13 +0530
Subject: [lustre-devel] [PATCH] staging: lustre/lustre/libcfs: Fix type
 mismatch reported by sparse
Message-ID: <20151209170813.GA12216@codebox>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The third argument to function kportal_memhog_alloc is expected to
be gfp_t whereas the actual argument was unsigned int. Fix this by
explicitly typecasting to gfp_t

Signed-off-by: Niranjan Dighe <niranjan.dighe@gmail.com>
---
 drivers/staging/lustre/lustre/libcfs/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 96d9d46..9c79f6e 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -268,7 +268,7 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
 			/* XXX The ioc_flags is not GFP flags now, need to be fixed */
 			err = kportal_memhog_alloc(pfile->private_data,
 						   data->ioc_count,
-						   data->ioc_flags);
+					(__force gfp_t)data->ioc_flags);
 			if (err != 0)
 				kportal_memhog_free(pfile->private_data);
 		}
-- 
1.9.1
