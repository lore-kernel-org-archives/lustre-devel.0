From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:50 -0400
Subject: [lustre-devel] [PATCH 01/22] staging: lustre: llite: initialize
 xattr->xe_namelen
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

When the allocation of xattr->xe_name was moved to kstrdup()
setting xattr->xe_namelen was dropped. This field is used
in several parts of the xattr cache code so it broke xattr
handling. Initialize xattr->xe_namelen when allocating
xattr->xe_name succeeds. Also change the debugging statement
to really report the xattr name instead of its length which
wasn't event being set.

Fixes: b3dd8957c23a ("staging: lustre: lustre: llite: Use kstrdup"
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr_cache.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 4dc799d..ef66949 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -121,10 +121,12 @@ static int ll_xattr_cache_add(struct list_head *cache,
 
 	xattr->xe_name = kstrdup(xattr_name, GFP_NOFS);
 	if (!xattr->xe_name) {
-		CDEBUG(D_CACHE, "failed to alloc xattr name %u\n",
-		       xattr->xe_namelen);
+		CDEBUG(D_CACHE, "failed to alloc xattr name %s\n",
+		       xattr_name);
 		goto err_name;
 	}
+	xattr->xe_namelen = strlen(xattr_name) + 1;
+
 	xattr->xe_value = kmemdup(xattr_val, xattr_val_len, GFP_NOFS);
 	if (!xattr->xe_value)
 		goto err_value;
-- 
1.8.3.1
