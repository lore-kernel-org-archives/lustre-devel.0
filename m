From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Jun 2016 23:53:11 -0400
Subject: [lustre-devel] [PATCH 2/4] staging/lustre: Keep logical
	continuations on the previous line
In-Reply-To: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
References: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466308393-1183295-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Emoly Liu <emoly.liu@intel.com>

This patch fixes all checkpatch occurences of
"CHECK: Logical continuations should be on the previous line"
in Lustre code.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c     | 9 ++++-----
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 4 ++--
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 38c507f..d6b61bc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -255,14 +255,13 @@ reprocess:
 			 * overflow and underflow.
 			 */
 			if ((new->l_policy_data.l_flock.start >
-			     (lock->l_policy_data.l_flock.end + 1))
-			    && (lock->l_policy_data.l_flock.end !=
-				OBD_OBJECT_EOF))
+			     (lock->l_policy_data.l_flock.end + 1)) &&
+			    (lock->l_policy_data.l_flock.end != OBD_OBJECT_EOF))
 				continue;
 
 			if ((new->l_policy_data.l_flock.end <
-			     (lock->l_policy_data.l_flock.start - 1))
-			    && (lock->l_policy_data.l_flock.start != 0))
+			     (lock->l_policy_data.l_flock.start - 1)) &&
+			    (lock->l_policy_data.l_flock.start != 0))
 				break;
 
 			if (new->l_policy_data.l_flock.start <
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 694c58e..f1c41a1 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1017,8 +1017,8 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 		/* Search proc entries */
 		while (lvars[j].name) {
 			var = &lvars[j];
-			if (!class_match_param(key, var->name, NULL)
-			    && keylen == strlen(var->name)) {
+			if (!class_match_param(key, var->name, NULL) &&
+			    keylen == strlen(var->name)) {
 				matched++;
 				rc = -EROFS;
 				if (var->fops && var->fops->write) {
-- 
2.7.4
