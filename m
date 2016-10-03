From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:34 -0400
Subject: [lustre-devel] [PATCH 38/41] staging: lustre: mdc: add max modify
	RPCs in flight variable
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

This patch introduces the maximum modify RPCs in flight variable of
a mdc client obd device. Its value is set from connection flag and
and connection data. It can later be tuned through the
max_mod_rpcs_in_flight procfs file.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
Reviewed-on: http://review.whamcloud.com/14153
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |    7 +++
 drivers/staging/lustre/lustre/include/obd_class.h |    1 +
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c     |   38 ++++++++++++++
 drivers/staging/lustre/lustre/mdc/mdc_request.c   |    4 ++
 drivers/staging/lustre/lustre/obdclass/genops.c   |   57 +++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/import.c     |   11 ++++
 6 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5fa5838..a977388 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -318,6 +318,13 @@ struct client_obd {
 	struct mdc_rpc_lock     *cl_rpc_lock;
 	struct mdc_rpc_lock     *cl_close_lock;
 
+	/* modify rpcs in flight
+	 * currently used for metadata only
+	 */
+	spinlock_t		 cl_mod_rpcs_lock;
+	u16			 cl_max_mod_rpcs_in_flight;
+
+
 	/* mgc datastruct */
 	atomic_t	     cl_mgc_refcount;
 	struct obd_export       *cl_mgc_mgsexp;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index e6ae4a0..7d8f062 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -100,6 +100,7 @@ int obd_get_request_slot(struct client_obd *cli);
 void obd_put_request_slot(struct client_obd *cli);
 __u32 obd_get_max_rpcs_in_flight(struct client_obd *cli);
 int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max);
+int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max);
 
 struct llog_handle;
 struct llog_rec_hdr;
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index fca9450..5fdee9e 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -73,6 +73,43 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_rpcs_in_flight);
 
+static ssize_t max_mod_rpcs_in_flight_show(struct kobject *kobj,
+					   struct attribute *attr,
+					   char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+	u16 max;
+	int len;
+
+	max = dev->u.cli.cl_max_mod_rpcs_in_flight;
+	len = sprintf(buf, "%hu\n", max);
+
+	return len;
+}
+
+static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
+					    struct attribute *attr,
+					    const char *buffer,
+					    size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+	u16 val;
+	int rc;
+
+	rc = kstrtou16(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	rc = obd_set_max_mod_rpcs_in_flight(&dev->u.cli, val);
+	if (rc)
+		count = rc;
+
+	return count;
+}
+LUSTRE_RW_ATTR(max_mod_rpcs_in_flight);
+
 LPROC_SEQ_FOPS_WR_ONLY(mdc, ping);
 
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
@@ -117,6 +154,7 @@ static struct lprocfs_vars lprocfs_mdc_obd_vars[] = {
 
 static struct attribute *mdc_attrs[] = {
 	&lustre_attr_max_rpcs_in_flight.attr,
+	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
 	NULL,
 };
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index ac04bf3..af373af 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2634,8 +2634,12 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	if (rc) {
 		mdc_cleanup(obd);
 		CERROR("failed to setup llogging subsystems\n");
+		return rc;
 	}
 
+	spin_lock_init(&cli->cl_mod_rpcs_lock);
+	cli->cl_max_mod_rpcs_in_flight = OBD_MAX_RIF_DEFAULT - 1;
+
 	return rc;
 
 err_close_lock:
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index cf8bb2a..62e6636 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1408,13 +1408,33 @@ EXPORT_SYMBOL(obd_get_max_rpcs_in_flight);
 int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max)
 {
 	struct obd_request_slot_waiter *orsw;
+	const char *typ_name;
 	__u32 old;
 	int diff;
+	int rc;
 	int i;
 
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
 
+	typ_name = cli->cl_import->imp_obd->obd_type->typ_name;
+	if (!strcmp(typ_name, LUSTRE_MDC_NAME)) {
+		/*
+		 * adjust max_mod_rpcs_in_flight to ensure it is always
+		 * strictly lower that max_rpcs_in_flight
+		 */
+		if (max < 2) {
+			CERROR("%s: cannot set max_rpcs_in_flight to 1 because it must be higher than max_mod_rpcs_in_flight value\n",
+			       cli->cl_import->imp_obd->obd_name);
+			return -ERANGE;
+		}
+		if (max <= cli->cl_max_mod_rpcs_in_flight) {
+			rc = obd_set_max_mod_rpcs_in_flight(cli, max - 1);
+			if (rc)
+				return rc;
+		}
+	}
+
 	spin_lock(&cli->cl_loi_list_lock);
 	old = cli->cl_max_rpcs_in_flight;
 	cli->cl_max_rpcs_in_flight = max;
@@ -1436,3 +1456,40 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max)
 	return 0;
 }
 EXPORT_SYMBOL(obd_set_max_rpcs_in_flight);
+
+int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, __u16 max)
+{
+	struct obd_connect_data *ocd;
+	u16 maxmodrpcs;
+
+	if (max > OBD_MAX_RIF_MAX || max < 1)
+		return -ERANGE;
+
+	/* cannot exceed or equal max_rpcs_in_flight */
+	if (max >= cli->cl_max_rpcs_in_flight) {
+		CERROR("%s: can't set max_mod_rpcs_in_flight to a value (%hu) higher or equal to max_rpcs_in_flight value (%u)\n",
+		       cli->cl_import->imp_obd->obd_name,
+		       max, cli->cl_max_rpcs_in_flight);
+		return -ERANGE;
+	}
+
+	/* cannot exceed max modify RPCs in flight supported by the server */
+	ocd = &cli->cl_import->imp_connect_data;
+	if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS)
+		maxmodrpcs = ocd->ocd_maxmodrpcs;
+	else
+		maxmodrpcs = 1;
+	if (max > maxmodrpcs) {
+		CERROR("%s: can't set max_mod_rpcs_in_flight to a value (%hu) higher than max_mod_rpcs_per_client value (%hu) returned by the server at connection\n",
+		       cli->cl_import->imp_obd->obd_name,
+		       max, maxmodrpcs);
+		return -ERANGE;
+	}
+
+	cli->cl_max_mod_rpcs_in_flight = max;
+
+	/* will have to wakeup waiters if max has been increased */
+
+	return 0;
+}
+EXPORT_SYMBOL(obd_set_max_mod_rpcs_in_flight);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 2bdaf2b..46ba5a4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -858,6 +858,17 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	client_adjust_max_dirty(cli);
 
 	/*
+	 * Update client max modify RPCs in flight with value returned
+	 * by the server
+	 */
+	if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS)
+		cli->cl_max_mod_rpcs_in_flight = min(
+					cli->cl_max_mod_rpcs_in_flight,
+					ocd->ocd_maxmodrpcs);
+	else
+		cli->cl_max_mod_rpcs_in_flight = 1;
+
+	/*
 	 * Reset ns_connect_flags only for initial connect. It might be
 	 * changed in while using FS and if we reset it in reconnect
 	 * this leads to losing user settings done before such as
-- 
1.7.1
