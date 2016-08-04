From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:50 -0400
Subject: [lustre-devel] [PATCH 14/32] staging: lustre: llite: set dir LOV
	xattr length variable
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Hongchao Zhang <hongchao.zhang@intel.com>

the LOV xattr of directory could be either lov_user_md_v1
(size is 32) or lov_user_md_v3 (size is 48), then the actual
size of the LOV xattr should be return.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5100
Reviewed-on: http://review.whamcloud.com/10453
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index aa0738b..146da6b 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -379,14 +379,6 @@ static int ll_xattr_get(const struct xattr_handler *handler,
 		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 			return -ENODATA;
 
-		if (size == 0 && S_ISDIR(inode->i_mode)) {
-			/* XXX directory EA is fix for now, optimize to save
-			 * RPC transfer
-			 */
-			rc = sizeof(struct lov_user_md);
-			goto out;
-		}
-
 		lsm = ccc_inode_lsm_get(inode);
 		if (!lsm) {
 			if (S_ISDIR(inode->i_mode)) {
-- 
1.7.1
