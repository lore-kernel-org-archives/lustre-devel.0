From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:51 -0500
Subject: [lustre-devel] [PATCH 183/622] lustre: llite: Fix style issues for
 lcommon_misc.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-184-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/llite/lcommon_misc.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: aac46ee4f871 ("LU-6142 llite: Fix style issues for lcommon_misc.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33810
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lcommon_misc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index 48503d6..d833a16 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -41,14 +41,17 @@
 
 #include "llite_internal.h"
 
-/* Initialize the default and maximum LOV EA and cookie sizes.  This allows
+/*
+ * Initialize the default and maximum LOV EA and cookie sizes.  This allows
  * us to make MDS RPCs with large enough reply buffers to hold the
  * maximum-sized (= maximum striped) EA and cookie without having to
  * calculate this (via a call into the LOV + OSCs) each time we make an RPC.
  */
 static int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 {
-	u32 val_size, max_easize, def_easize;
+	u32 val_size;
+	u32 max_easize;
+	u32 def_easize;
 	int rc;
 
 	val_size = sizeof(max_easize);
@@ -83,9 +86,9 @@ int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
 		  enum obd_notify_event ev, void *owner)
 {
 	struct lustre_client_ocd *lco;
-	struct client_obd	*cli;
+	struct client_obd *cli;
 	u64 flags;
-	int   result;
+	int result;
 
 	if (!strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME) &&
 	    watched->obd_set_up && !watched->obd_stopping) {
@@ -117,13 +120,13 @@ int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		     struct ll_grouplock *lg)
 {
-	struct lu_env	  *env;
-	struct cl_io	   *io;
-	struct cl_lock	 *lock;
-	struct cl_lock_descr   *descr;
-	u32		   enqflags;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct cl_lock *lock;
+	struct cl_lock_descr *descr;
+	u32 enqflags;
 	u16 refcheck;
-	int		     rc;
+	int rc;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
-- 
1.8.3.1
