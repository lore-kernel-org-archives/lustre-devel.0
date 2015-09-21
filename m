From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:37 +0200
Subject: [lustre-devel] [PATCH 05/38] staging: lustre: fix handling
 lustre_posix_acl_xattr_filter result
In-Reply-To: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Message-ID: <1442842450-29769-6-git-send-email-a.hajda@samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The function can return negative value.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 362a87d..dddc1ff 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -175,11 +175,12 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 			}
 			ee_free(ee);
 		} else if (rce->rce_ops == RMT_RSETFACL) {
-			size = lustre_posix_acl_xattr_filter(
+			rc = lustre_posix_acl_xattr_filter(
 						(posix_acl_xattr_header *)value,
 						size, &new_value);
-			if (unlikely(size < 0))
-				return size;
+			if (unlikely(rc < 0))
+				return rc;
+			size = rc;
 
 			pv = (const char *)new_value;
 		} else
-- 
1.9.1
