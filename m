From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:47 -0400
Subject: [lustre-devel] [PATCH 13/29] staging: lustre: llite: report back to
	user bad stripe count
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If the user is requesting a stripe count larger than what
is supported in the file system then report back to the
user an error as well as what is the largest possible
striping.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6602
Reviewed-on: http://review.whamcloud.com/15162
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index fb367ae..64a32d5 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1195,6 +1195,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lmv_user_md *tmp = NULL;
 		union lmv_mds_md *lmm = NULL;
 		u64 valid = 0;
+		int max_stripe_count;
 		int stripe_count;
 		int mdt_index;
 		int lum_size;
@@ -1206,6 +1207,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (copy_from_user(&lum, ulmv, sizeof(*ulmv)))
 			return -EFAULT;
 
+		max_stripe_count = lum.lum_stripe_count;
 		/*
 		 * lum_magic will indicate which stripe the ioctl will like
 		 * to get, LMV_MAGIC_V1 is for normal LMV stripe, LMV_USER_MAGIC
@@ -1240,6 +1242,16 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		stripe_count = lmv_mds_md_stripe_count_get(lmm);
+		if (max_stripe_count < stripe_count) {
+			lum.lum_stripe_count = stripe_count;
+			if (copy_to_user(ulmv, &lum, sizeof(lum))) {
+				rc = -EFAULT;
+				goto finish_req;
+			}
+			rc = -E2BIG;
+			goto finish_req;
+		}
+
 		lum_size = lmv_user_md_size(stripe_count, LMV_MAGIC_V1);
 		tmp = kzalloc(lum_size, GFP_NOFS);
 		if (!tmp) {
-- 
1.7.1
