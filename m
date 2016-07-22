From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:57 -0400
Subject: [lustre-devel] [PATCH 04/58] staging: lustre: llite: cache
	directory striping information
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Cache directory striping information that the clients receive
from the metadata servers.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   15 +++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 27d3f77..baa208f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -173,6 +173,8 @@ struct ll_inode_info {
 			 * -- I am the owner of dir statahead.
 			 */
 			pid_t			   d_opendir_pid;
+			/* directory stripe information */
+			struct lmv_stripe_md		*d_lmv_md;
 		} d;
 
 #define lli_readdir_mutex       u.d.d_readdir_mutex
@@ -180,6 +182,7 @@ struct ll_inode_info {
 #define lli_sai		 u.d.d_sai
 #define lli_sa_lock	     u.d.d_sa_lock
 #define lli_opendir_pid	 u.d.d_opendir_pid
+#define lli_lmv_md		u.d.d_lmv_md
 
 		/* for non-directory */
 		struct {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 75d568f..eb715be 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2090,11 +2090,22 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
+	if (S_ISDIR(i1->i_mode))
+		op_data->op_mea1 = ll_i2info(i1)->lli_lmv_md;
 
-	if (i2)
+	if (i2) {
 		op_data->op_fid2 = *ll_inode2fid(i2);
-	else
+		if (S_ISDIR(i2->i_mode))
+			op_data->op_mea2 = ll_i2info(i2)->lli_lmv_md;
+	} else {
 		fid_zero(&op_data->op_fid2);
+	}
+
+	if (ll_i2sbi(i1)->ll_flags & LL_SBI_64BIT_HASH)
+		op_data->op_cli_flags |= CLI_HASH64;
+
+	if (ll_need_32bit_api(ll_i2sbi(i1)))
+		op_data->op_cli_flags |= CLI_API32;
 
 	op_data->op_name = name;
 	op_data->op_namelen = namelen;
-- 
1.7.1
