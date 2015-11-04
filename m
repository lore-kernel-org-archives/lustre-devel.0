From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:40:01 -0500
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: Fix possible NULL
	pointer dereference in lprocfs_status.c
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

The imp->imp_connection really could be NULL, we better check for it
before dereferencing it in taht call to libcfs_nid2str_r.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6507
Reviewed-on: http://review.whamcloud.com/14808
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 2de3c1b..dda5ad1 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -665,15 +665,18 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		seq_printf(m, "%s%s", j ? ", " : "", nidstr);
 		j++;
 	}
-	libcfs_nid2str_r(imp->imp_connection->c_peer.nid,
-			 nidstr, sizeof(nidstr));
+	if (imp->imp_connection != NULL)
+		libcfs_nid2str_r(imp->imp_connection->c_peer.nid,
+				 nidstr, sizeof(nidstr));
+	else
+		strncpy(nidstr, "<none>", sizeof(nidstr));
 	seq_printf(m,
 		      "]\n"
 		      "       current_connection: %s\n"
 		      "       connection_attempts: %u\n"
 		      "       generation: %u\n"
 		      "       in-progress_invalidations: %u\n",
-		      imp->imp_connection == NULL ? "<none>" : nidstr,
+		      nidstr,
 		      imp->imp_conn_cnt,
 		      imp->imp_generation,
 		      atomic_read(&imp->imp_inval_count));
-- 
1.7.1
