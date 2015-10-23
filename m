From: Shraddha Barke <shraddha.6596@gmail.com>
Date: Fri, 23 Oct 2015 15:27:57 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: obdclass: Remove unused
	header files
Message-ID: <1445594277-14421-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove unused header files that are already included in 'lu_object.h'
and 'obd.h'

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 1 -
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0d15bd5..549df95 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -55,7 +55,6 @@
 #include "../include/lustre_disk.h"
 #include "../include/lustre_fid.h"
 #include "../include/lu_object.h"
-#include "../include/lu_ref.h"
 #include <linux/list.h>
 
 static void lu_object_free(const struct lu_env *env, struct lu_object *o);
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index 993697b..df2d8b9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -47,4 +47,3 @@
 #include "../include/obd.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
-#include "../include/lu_ref.h"
-- 
2.1.4
