From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:53 -0400
Subject: [lustre-devel] [PATCH 03/14] staging: lustre: llite: add simple
	comment about lustre.lov xattrs
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Simple comment added to ll_xattr_set.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24851
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index fb53942..f201021 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -261,6 +261,7 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), xattr %s\n",
 	       PFID(ll_inode2fid(inode)), inode, name);
 
+	/* lustre/trusted.lov.xxx would be passed through xattr API */
 	if (!strcmp(name, "lov")) {
 		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
 						       LPROC_LL_SETXATTR;
-- 
1.8.3.1
