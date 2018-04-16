From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:54 -0400
Subject: [lustre-devel] [PATCH 05/22] staging: lustre: llite: handle xattr
 cache refill race
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: "John L. Hammond" <john.hammond@intel.com>

In ll_xattr_cache_refill() if the xattr cache was invalid (and no
request was sent) then return -EAGAIN so that ll_getxattr_common()
caller will fetch the xattr from the MDT.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10132
Reviewed-on: https://review.whamcloud.com/29654
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr_cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 53dfaea..5da69ba0 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -357,7 +357,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
 	if (unlikely(!req)) {
 		CDEBUG(D_CACHE, "cancelled by a parallel getxattr\n");
 		ll_intent_drop_lock(&oit);
-		rc = -EIO;
+		rc = -EAGAIN;
 		goto err_unlock;
 	}
 
-- 
1.8.3.1
