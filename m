From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:18 -0400
Subject: [lustre-devel] [PATCH 079/124] staging: lustre: mgc: add nid
	iteration
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-80-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander.boyko@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander.boyko@seagate.com>

mgc_apply_recover_logs use only first nid from entry,
this could be the problem for a cluster with several network
address for a one node.

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5950
Xyratex-bug-id: MRP-2255
Reviewed-on: http://review.whamcloud.com/12829
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Ann Koehler <amk@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2191ca1..23374ca 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1159,7 +1159,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 	while (datalen > 0) {
 		int   entry_len = sizeof(*entry);
-		int   is_ost;
+		int is_ost, i;
 		struct obd_device *obd;
 		char *obdname;
 		char *cname;
@@ -1265,11 +1265,17 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 			continue;
 		}
 
-		/* TODO: iterate all nids to find one */
+		/* iterate all nids to find one */
 		/* find uuid by nid */
-		rc = client_import_find_conn(obd->u.cli.cl_import,
-					     entry->u.nids[0],
-					     (struct obd_uuid *)uuid);
+		rc = -ENOENT;
+		for (i = 0; i < entry->mne_nid_count; i++) {
+			rc = client_import_find_conn(obd->u.cli.cl_import,
+						     entry->u.nids[0],
+						     (struct obd_uuid *)uuid);
+			if (!rc)
+				break;
+		}
+
 		up_read(&obd->u.cli.cl_sem);
 		if (rc < 0) {
 			CERROR("mgc: cannot find uuid by nid %s\n",
-- 
1.7.1
