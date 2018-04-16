From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:10 -0400
Subject: [lustre-devel] [PATCH 21/22] staging: lustre: llite: correct
 removexattr detection
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

In ll_xattr_set_common() detect the removexattr() case correctly by
testing for a NULL value as well as XATTR_REPLACE.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10787
Reviewed-on: https://review.whamcloud.com/
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index e835c8e..1a597a6 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -94,7 +94,11 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	u64 valid;
 	int rc;
 
-	if (flags == XATTR_REPLACE) {
+	/* When setxattr() is called with a size of 0 the value is
+	 * unconditionally replaced by "". When removexattr() is
+	 * called we get a NULL value and XATTR_REPLACE for flags.
+	 */
+	if (!value && flags == XATTR_REPLACE) {
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
 		valid = OBD_MD_FLXATTRRM;
 	} else {
-- 
1.8.3.1
