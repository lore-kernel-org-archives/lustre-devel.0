From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:06 -0500
Subject: [lustre-devel] [PATCH 558/622] lustre: obdclass: remove assertion
 for imp_refcount
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-559-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

After calling obd_zombie_import_add(), obd_import could
be freed by obd_zombie before we check imp_refcount with
LASSERT_ATOMIC_GE_LT. It's a use after free and could
crash the box.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12965
Lustre-commit: dd71e74fecf4 ("LU-12965 obdclass: remove assertion for imp_refcount")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/36743
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index bceb055..a31e9ce 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -945,9 +945,6 @@ void class_import_put(struct obd_import *imp)
 		CDEBUG(D_INFO, "final put import %p\n", imp);
 		obd_zombie_import_add(imp);
 	}
-
-	/* catch possible import put race */
-	LASSERT_ATOMIC_GE_LT(&imp->imp_refcount, 0, LI_POISON);
 }
 EXPORT_SYMBOL(class_import_put);
 
-- 
1.8.3.1
