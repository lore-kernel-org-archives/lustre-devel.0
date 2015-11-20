From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:01 -0500
Subject: [lustre-devel] [PATCH 25/40] staging: lustre: missed a few cases of
	using NULL instead of 0
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

It is preferable to use NULL instead of 0 for pointers. This fixes sparse
warnings such as:

lustre/fld/fld_request.c:126:17: warning: Using plain integer as NULL pointer

The second parameter of class_match_param() was changed to a const, to
be able to remove a cast in one user, to prevent splitting a long
line. No other code change.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/12567
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7657f88..89b390a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -902,7 +902,7 @@ lnet_ping_info_setup(lnet_ping_info_t **ppinfo, lnet_handle_md_t *md_handle,
 {
 	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
 	lnet_handle_me_t me_handle;
-	lnet_md_t md = {0};
+	lnet_md_t md = { NULL };
 	int rc, rc2;
 
 	if (set_eq) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4a8c759..2109297 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1941,7 +1941,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		  struct super_block *sb, struct lookup_intent *it)
 {
 	struct ll_sb_info *sbi = NULL;
-	struct lustre_md md;
+	struct lustre_md md = { NULL };
 	int rc;
 
 	LASSERT(*inode || sb);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index c231e0d..db8e12d 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -72,7 +72,7 @@ EXPORT_SYMBOL(class_find_param);
 
 /* returns 0 if this is the first key in the buffer, else 1.
    valp points to first char after key. */
-static int class_match_param(char *buf, char *key, char **valp)
+static int class_match_param(char *buf, const char *key, char **valp)
 {
 	if (!buf)
 		return 1;
@@ -1008,7 +1008,7 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 		/* Search proc entries */
 		while (lvars[j].name) {
 			var = &lvars[j];
-			if (class_match_param(key, (char *)var->name, NULL) == 0
+			if (class_match_param(key, var->name, NULL) == 0
 			    && keylen == strlen(var->name)) {
 				matched++;
 				rc = -EROFS;
-- 
1.7.1
