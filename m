From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:27 -0500
Subject: [lustre-devel] [PATCH 099/622] lustre: osc: serialize access to
 idle_timeout vs cleanup
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-100-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

use lprocfs_climp_check() and up_read() as cl_import
can disappear due to umount.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11175
Lustre-commit: 5874da0b670b ("LU-11175 osc: serialize access to idle_timeout vs cleanup")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32883
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 0a12079..efb4998 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -604,8 +604,15 @@ static ssize_t idle_timeout_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
+	int ret;
 
-	return sprintf(buf, "%u\n", cli->cl_import->imp_idle_timeout);
+	ret = lprocfs_climp_check(obd);
+	if (ret)
+		return ret;
+	ret = sprintf(buf, "%u\n", cli->cl_import->imp_idle_timeout);
+	up_read(&obd->u.cli.cl_sem);
+
+	return ret;
 }
 
 static ssize_t idle_timeout_store(struct kobject *kobj, struct attribute *attr,
@@ -625,6 +632,10 @@ static ssize_t idle_timeout_store(struct kobject *kobj, struct attribute *attr,
 	if (val > CONNECTION_SWITCH_MAX)
 		return -ERANGE;
 
+	rc = lprocfs_climp_check(obd);
+	if (rc)
+		return rc;
+
 	cli->cl_import->imp_idle_timeout = val;
 
 	/* to initiate the connection if it's in IDLE state */
@@ -633,6 +644,7 @@ static ssize_t idle_timeout_store(struct kobject *kobj, struct attribute *attr,
 		if (req)
 			ptlrpc_req_finished(req);
 	}
+	up_read(&obd->u.cli.cl_sem);
 
 	return count;
 }
@@ -645,12 +657,18 @@ static ssize_t idle_connect_store(struct kobject *kobj, struct attribute *attr,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	struct ptlrpc_request *req;
+	int rc;
+
+	rc = lprocfs_climp_check(dev);
+	if (rc)
+		return rc;
 
 	/* to initiate the connection if it's in IDLE state */
 	req = ptlrpc_request_alloc(cli->cl_import, &RQF_OST_STATFS);
 	if (req)
 		ptlrpc_req_finished(req);
 	ptlrpc_pinger_force(cli->cl_import);
+	up_read(&dev->u.cli.cl_sem);
 
 	return count;
 }
-- 
1.8.3.1
