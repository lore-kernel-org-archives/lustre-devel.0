From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 16/24] lustre: remove redefinition of
 module_init().
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669064.10587.7203081913142739014.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As lustre has only recently support building
as non-modules, this code must be very old.
If there is a dependency ordering, this is not
the way to handle it - random numbers should
be generated when filesystem is activated, not
when the module is loaded.
So just remove this code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 6d659b696b5f..f555391d5ae3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -39,14 +39,4 @@
 #include <linux/cred.h>
 #include <linux/module.h>
 
-/*
- * OBD need working random driver, thus all our
- * initialization routines must be called after device
- * driver initialization
- */
-#ifndef MODULE
-#undef module_init
-#define module_init(a)     late_initcall(a)
-#endif
-
 #endif /* _LUSTRE_COMPAT_H */
