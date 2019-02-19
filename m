From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 10/37] lustre: kernelcomm: pass correct gfp_t
 to kmalloc.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494542.24125.3526135915611952378.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Passing 0 as the gfp_t for kmalloc() is not meaningful, and
could change behaviour.
Use an explicit GFP_KERNEL instead.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 925ba52c53b4..09d0b1ab8d1c 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -133,7 +133,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 		return -EBADF;
 
 	/* freed in group_rem */
-	reg = kmalloc(sizeof(*reg) + data_len, 0);
+	reg = kmalloc(sizeof(*reg) + data_len, GFP_KERNEL);
 	if (!reg)
 		return -ENOMEM;
 
