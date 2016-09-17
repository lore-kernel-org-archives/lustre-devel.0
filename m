From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat, 17 Sep 2016 21:37:03 +0800
Subject: [lustre-devel] [PATCH] staging/lustre: clean function declaration
	in super25.c up
Message-ID: <1474119423-11723-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, arnd@arndb.de, shraddha.6596@gmail.com, mike.rapoport@gmail.com, ksenija.stanojevic@gmail.com, gregoire.pichon@bull.net, john.hammond@intel.com, fan.yong@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 1 warning when building kernel with W=1:
drivers/staging/lustre/lustre/obdclass/obd_config.c:719:6: warning: no previous prototype for 'lustre_register_client_process_config' [-Wmissing-prototypes]

In fact, this function is declared in
drivers/staging/lustre/lustre/llite/super25.c, but should be
moved into a header file, thus can be recognized in other file.

So this patch moves the declaration into
drivers/staging/lustre/lustre/include/lprocfs_status.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h | 3 +++
 drivers/staging/lustre/lustre/llite/super25.c          | 2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index ff35e63..6768ecc 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -363,6 +363,9 @@ static inline void s2dhms(struct dhms *ts, time64_t secs64)
 #define JOBSTATS_PROCNAME_UID		"procname_uid"
 #define JOBSTATS_NODELOCAL		"nodelocal"
 
+/* obd_config.c */
+void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
+
 int lprocfs_write_frac_helper(const char __user *buffer,
 			      unsigned long count, int *val, int mult);
 int lprocfs_read_frac_helper(char *buffer, unsigned long count,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 883084e..24c79c2 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -83,8 +83,6 @@ struct super_operations lustre_super_operations = {
 };
 MODULE_ALIAS_FS("lustre");
 
-void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
-
 static int __init lustre_init(void)
 {
 	lnet_process_id_t lnet_id;
-- 
2.7.4
