From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:17 -0400
Subject: [lustre-devel] [PATCH 05/10] lustre: don't declare extern variables
 in C files.
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

'extern' declarations should only appear in .h files.
All these names are declared in .h files as needed,
and these duplicate declarations in .c files can
be removed.

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/35294
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_resource.c   | 2 --
 fs/lustre/ptlrpc/import.c        | 1 -
 fs/lustre/ptlrpc/ptlrpc_module.c | 5 -----
 3 files changed, 8 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 45b2e97..372a290 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -681,8 +681,6 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 }
 EXPORT_SYMBOL(ldlm_namespace_new);
 
-extern struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
-
 /**
  * Cancel and destroy all locks on a resource.
  *
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index d49707a..67a66a5 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1572,7 +1572,6 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 EXPORT_SYMBOL(ptlrpc_disconnect_import);
 
 /* Adaptive Timeout utils */
-extern unsigned int at_min, at_max, at_history;
 
 /*
  *Update at_current with the specified value (bounded by at_min and at_max),
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index f73ba41..6888df9 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -40,11 +40,6 @@
 
 #include "ptlrpc_internal.h"
 
-extern spinlock_t ptlrpc_last_xid_lock;
-#if RS_DEBUG
-extern spinlock_t ptlrpc_rs_debug_lock;
-#endif
-
 DEFINE_MUTEX(ptlrpc_startup);
 static int ptlrpc_active;
 
-- 
1.8.3.1
