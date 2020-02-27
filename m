From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:04 -0500
Subject: [lustre-devel] [PATCH 136/622] lustre: osc: clarify short_io_bytes
 is maximum value
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-137-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Clarify in the code that the "osc.*.short_io_bytes" parameter is
the maximum IO size to pack into request/reply not the minimum.

Allow short_io to be disabled completely if it is set to zero.

It would be nice to also change the name of the /sysfs functions
in a similar manner but that also changes the /sysfs tunable name
(via LUSTRE_RW_ATTR() macro) and has compatibility implications
for sites that may have changed this value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1757
Lustre-commit: b90812a674f6 ("LU-1757 osc: clarify short_io_bytes is maximum value")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33173
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h             | 2 +-
 fs/lustre/ldlm/ldlm_lib.c           | 2 ++
 fs/lustre/obdclass/lprocfs_status.c | 6 +++---
 fs/lustre/osc/osc_request.c         | 7 +++----
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 7cf9745..2587136 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -252,7 +252,7 @@ struct client_obd {
 	atomic_t		cl_pending_r_pages;
 	u32			cl_max_pages_per_rpc;
 	u32			cl_max_rpcs_in_flight;
-	u32			cl_short_io_bytes;
+	u32			cl_max_short_io_bytes;
 	struct obd_histogram    cl_read_rpc_hist;
 	struct obd_histogram    cl_write_rpc_hist;
 	struct obd_histogram    cl_read_page_hist;
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 838ddb3..5fe5711 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -374,6 +374,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 */
 	cli->cl_max_pages_per_rpc = PTLRPC_MAX_BRW_PAGES;
 
+	cli->cl_max_short_io_bytes = OBD_MAX_SHORT_IO_BYTES;
+
 	/*
 	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
 	 * it will be updated at OSC connection time.
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 747baff..b3dbe85 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1896,7 +1896,7 @@ ssize_t short_io_bytes_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	rc = sprintf(buf, "%d\n", cli->cl_short_io_bytes);
+	rc = sprintf(buf, "%d\n", cli->cl_max_short_io_bytes);
 	spin_unlock(&cli->cl_loi_list_lock);
 	return rc;
 }
@@ -1922,7 +1922,7 @@ ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		goto out;
 
-	if (val > OBD_MAX_SHORT_IO_BYTES || val < MIN_SHORT_IO_BYTES) {
+	if (val && (val < MIN_SHORT_IO_BYTES || val > OBD_MAX_SHORT_IO_BYTES)) {
 		rc = -ERANGE;
 		goto out;
 	}
@@ -1933,7 +1933,7 @@ ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
 	if (val > (cli->cl_max_pages_per_rpc << PAGE_SHIFT))
 		rc = -ERANGE;
 	else
-		cli->cl_short_io_bytes = val;
+		cli->cl_max_short_io_bytes = val;
 	spin_unlock(&cli->cl_loi_list_lock);
 
 out:
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e968360..4524a98 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1321,9 +1321,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	for (i = 0; i < page_count; i++)
 		short_io_size += pga[i]->count;
 
-	/* Check if we can do a short io. */
-	if (!(short_io_size <= cli->cl_short_io_bytes && niocount == 1 &&
-	    imp_connect_shortio(cli->cl_import)))
+	/* Check if read/write is small enough to be a short io. */
+	if (short_io_size > cli->cl_max_short_io_bytes || niocount > 1 ||
+	    !imp_connect_shortio(cli->cl_import))
 		short_io_size = 0;
 
 	req_capsule_set_size(pill, &RMF_SHORT_IO, RCL_CLIENT,
@@ -1762,7 +1762,6 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			CERROR("Unexpected +ve rc %d\n", rc);
 			return -EPROTO;
 		}
-		LASSERT(req->rq_bulk->bd_nob == aa->aa_requested_nob);
 
 		if (req->rq_bulk &&
 		    sptlrpc_cli_unwrap_bulk_write(req, req->rq_bulk))
-- 
1.8.3.1
