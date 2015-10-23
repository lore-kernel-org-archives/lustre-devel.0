From: James Simmons <jsimmons@infradead.org>
Date: Fri, 23 Oct 2015 15:59:13 -0400
Subject: [lustre-devel] [PATCH 1/5] staging:lustre: kg_sem semaphore
	handling is incorrectly
In-Reply-To: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
References: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445630357-27149-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

During the removal of the cfs wrappers the kg_sem semaphore
was handled incorrectly. We need to take a write lock when
writing data to the kkuc_groups. The libcfs_kkuc_group_foreach
needs to only take a read lock. This makes use match the
OpenSFS development branch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/libcfs/kernel_user_comm.c        |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
index d9b7c6b..48df275 100644
--- a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
+++ b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
@@ -184,7 +184,7 @@ int libcfs_kkuc_group_put(int group, void *payload)
 	int		 rc = 0;
 	int one_success = 0;
 
-	down_read(&kg_sem);
+	down_write(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
 		if (reg->kr_fp != NULL) {
 			rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
@@ -196,7 +196,7 @@ int libcfs_kkuc_group_put(int group, void *payload)
 			}
 		}
 	}
-	up_read(&kg_sem);
+	up_write(&kg_sem);
 
 	/* don't return an error if the message has been delivered
 	 * at least to one agent */
@@ -228,12 +228,12 @@ int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
 	if (kkuc_groups[group].next == NULL)
 		return 0;
 
-	down_write(&kg_sem);
+	down_read(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
 		if (reg->kr_fp != NULL)
 			rc = cb_func(reg->kr_data, cb_arg);
 	}
-	up_write(&kg_sem);
+	up_read(&kg_sem);
 
 	return rc;
 }
-- 
1.7.1
