From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:50 -0400
Subject: [lustre-devel] [PATCH 16/29] staging: lustre: mdc: deactive MDT
	permanently
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add active proc entry for MDC, and mark MDC to
be inactive once the MDC is deactivated.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6586
Reviewed-on: http://review.whamcloud.com/14747
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c   |    1 +
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c |   37 +++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7a8d1c8..12e8b1e 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -62,6 +62,7 @@ static void lmv_activate_target(struct lmv_obd *lmv,
 
 	tgt->ltd_active = activate;
 	lmv->desc.ld_active_tgt_count += (activate ? 1 : -1);
+	tgt->ltd_exp->exp_obd->obd_inactive = !activate;
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index c89003a..9021c46 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -36,6 +36,42 @@
 #include "../include/lprocfs_status.h"
 #include "mdc_internal.h"
 
+static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
+			   char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+
+	return sprintf(buf, "%u\n", !dev->u.cli.cl_import->imp_deactive);
+}
+
+static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
+			    const char *buffer, size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	if (val < 0 || val > 1)
+		return -ERANGE;
+
+	/* opposite senses */
+	if (dev->u.cli.cl_import->imp_deactive == val) {
+		rc = ptlrpc_set_import_active(dev->u.cli.cl_import, val);
+		if (rc)
+			count = rc;
+	} else {
+		CDEBUG(D_CONFIG, "activate %lu: ignoring repeat request\n", val);
+	}
+	return count;
+}
+LUSTRE_RW_ATTR(active);
+
 static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 				       struct attribute *attr,
 				       char *buf)
@@ -176,6 +212,7 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 };
 
 static struct attribute *mdc_attrs[] = {
+	&lustre_attr_active.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
-- 
1.7.1
