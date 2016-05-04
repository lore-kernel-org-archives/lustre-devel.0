From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:57 -0400
Subject: [lustre-devel] [PATCH 6/9] staging: lustre: debug: clean up console
	messages
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Clean up overly verbose console error messages, improve others.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1095
Reviewed-on: http://review.whamcloud.com/8617
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 4 +---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 44dd3f3..96c7e9f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -897,10 +897,8 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	cfg->cfg_callback = class_config_llog_handler;
 	/* set up client obds */
 	err = lustre_process_log(sb, profilenm, cfg);
-	if (err < 0) {
-		CERROR("Unable to process log: %d\n", err);
+	if (err < 0)
 		goto out_free;
-	}
 
 	/* Profile set with LCFG_MOUNTOPT so we can find our mdc and osc obds */
 	lprof = class_get_profile(profilenm);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 9474aa9..e0c90ad 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -102,7 +102,7 @@ int lustre_process_log(struct super_block *sb, char *logname,
 		LCONSOLE_ERROR_MSG(0x15b, "%s: The configuration from log '%s' failed from the MGS (%d).  Make sure this client and the MGS are running compatible versions of Lustre.\n",
 				   mgc->obd_name, logname, rc);
 
-	if (rc)
+	else if (rc)
 		LCONSOLE_ERROR_MSG(0x15c, "%s: The configuration from log '%s' failed (%d). This may be the result of communication errors between this node and the MGS, a bad configuration, or other errors. See the syslog for more information.\n",
 				   mgc->obd_name, logname,
 				   rc);
-- 
2.7.4
