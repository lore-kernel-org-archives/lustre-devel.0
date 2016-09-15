From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Thu, 15 Sep 2016 23:45:17 +0800
Subject: [lustre-devel] [PATCH v2] staging: lustre: clean function
	declarations in class_obd.c up
Message-ID: <1473954317-27343-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, john.hammond@intel.com, shraddha.6596@gmail.com, di.wang@intel.com, ksenija.stanojevic@gmail.com, mike.rapoport@gmail.com, andrew.perepechko@seagate.com, kirill.shutemov@linux.intel.com, lustre-devel@lists.lustre.org
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 2 warnings when building kernel with W=1:

drivers/staging/lustre/lustre/obdclass/linux/linux-module.c:413:5: warning: no previous prototype for 'class_procfs_init' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/obdclass/linux/linux-module.c:449:5: warning: no previous prototype for 'class_procfs_clean' [-Wmissing-prototypes]

In fact, both functions are declared in
drivers/staging/lustre/lustre/obdclass/class_obd.c,but should be
declared in a header file, thus can be recognized in other file.

So this patch moves the declarations into
drivers/staging/lustre/lustre/include/obd_class.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  | 2 ++
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 3 ---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 9702ad4..324c70d 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1716,6 +1716,8 @@ void class_exit_uuidlist(void);
 extern char obd_jobid_node[];
 extern struct miscdevice obd_psdev;
 extern spinlock_t obd_types_lock;
+int class_procfs_init(void);
+int class_procfs_clean(void);
 
 /* prng.c */
 #define ll_generate_random_uuid(uuid_out) cfs_get_random_bytes(uuid_out, sizeof(class_uuid_t))
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 6700167..710039a 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -446,9 +446,6 @@ static int obd_init_checks(void)
 	return ret;
 }
 
-extern int class_procfs_init(void);
-extern int class_procfs_clean(void);
-
 static int __init obdclass_init(void)
 {
 	int i, err;
-- 
2.7.4
