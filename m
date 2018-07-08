From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:19 -0400
Subject: [lustre-devel] [PATCH v4 05/14] lustre: libcfs: properly handle
 failure paths in cfs_tracefile_init_arch()
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It is considered poor coding style in the linux kernel to call a
catch all for cleanup in the initialization function. Also their
is no reason to cleanup cfs_trace_console_buffers if they never
been allocated. Lets unroll the error handling.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 3af7722..7c864d0 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -49,9 +49,9 @@
 
 int cfs_tracefile_init_arch(void)
 {
+	struct cfs_trace_cpu_data *tcd;
 	int i;
 	int j;
-	struct cfs_trace_cpu_data *tcd;
 
 	/* initialize trace_data */
 	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
@@ -61,7 +61,7 @@ int cfs_tracefile_init_arch(void)
 				      sizeof(union cfs_trace_data_union),
 				      GFP_KERNEL);
 		if (!cfs_trace_data[i])
-			goto out;
+			goto out_trace_data;
 	}
 
 	/* arch related info initialized */
@@ -79,13 +79,22 @@ int cfs_tracefile_init_arch(void)
 					GFP_KERNEL);
 
 			if (!cfs_trace_console_buffers[i][j])
-				goto out;
+				goto out_buffers;
 		}
 
 	return 0;
 
-out:
-	cfs_tracefile_fini_arch();
+out_buffers:
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+out_trace_data:
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
 	pr_err("lnet: Not enough memory\n");
 	return -ENOMEM;
 }
-- 
1.8.3.1
