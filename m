From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:59 -0400
Subject: [lustre-devel] [PATCH 09/14] staging: lustre: llite: record in
	stats attempted removal of lma/link xattr
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Keep track of attempted deletions as well as changing of the
lma/link xattrs.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a54be09..5728579 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -297,7 +297,10 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 		return ll_setstripe_ea(dentry, (struct lov_user_md *)value,
 				       size);
 	} else if (!strcmp(name, "lma") || !strcmp(name, "link")) {
-		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
+		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
+						       LPROC_LL_SETXATTR;
+
+		ll_stats_ops_tally(ll_i2sbi(inode), op_type, 1);
 		return 0;
 	}
 
-- 
1.8.3.1
