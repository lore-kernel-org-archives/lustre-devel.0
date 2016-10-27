From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:43 -0400
Subject: [lustre-devel] [PATCH 09/29] staging: lustre: dne: setdirstripe
	should fail if not supported
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

If MDS doesn't support striped directory, creating striped directory
from a userland utility such as 'lfs setdirstripe' should fail.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6661
Reviewed-on: http://review.whamcloud.com/15123
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 929c32c..6e744a5 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -419,6 +419,10 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 	       PFID(ll_inode2fid(parent)), parent, dirname,
 	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
 
+	if (lump->lum_stripe_count > 1 &&
+	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_DIR_STRIPE))
+		return -EINVAL;
+
 	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC))
 		lustre_swab_lmv_user_md(lump);
 
-- 
1.7.1
