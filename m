From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:03 -0400
Subject: [lustre-devel] [PATCH 14/22] staging: lustre: llite: record in
 stats attempted removal of lma/link xattr
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

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
index 4b1e565..3ab7ae0 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -296,7 +296,10 @@ static int ll_xattr_set(const struct xattr_handler *handler,
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
