From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Nov 2018 18:15:28 +1100
Subject: [lustre-devel] [PATCH 6/9] lustre: obdclass: health_check to report
 unhealthy upon LBUG
In-Reply-To: <154295730810.2850.961218355189474016.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
Message-ID: <154295732803.2850.16198081335816276527.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

When a LBUG has occurred, without panic_on_lbug being set, health_check
/proc file must return an unhealthy state.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7486
Reviewed-on: http://review.whamcloud.com/17981
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
index 6669c235dd51..5fd30a8e2b44 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
@@ -173,8 +173,10 @@ health_check_show(struct kobject *kobj, struct attribute *attr, char *buf)
 	int i;
 	size_t len = 0;
 
-	if (libcfs_catastrophe)
+	if (libcfs_catastrophe) {
 		return sprintf(buf, "LBUG\n");
+		healthy = false;
+	}
 
 	read_lock(&obd_dev_lock);
 	for (i = 0; i < class_devno_max(); i++) {
