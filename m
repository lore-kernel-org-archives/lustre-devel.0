From: Anton Gerasimov <anton.gerasimov@openmailbox.org>
Date: Thu, 24 Sep 2015 00:02:28 +0300
Subject: [lustre-devel] [PATCHv2 1/3] staging: lustre: moved extern
	declarations to a header
Message-ID: <20150923210146.GA5375@linux-0hv4.site>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch moves declarations of variables used in several files
across the ptlrpc module from source files to a local header.

Signed-off-by: Anton Gerasimov <anton.gerasimov@openmailbox.org>
---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 1 -
 drivers/staging/lustre/lustre/ptlrpc/nrs.c             | 1 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h | 6 ++++++
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c   | 2 --
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 9a10baf..2b88aef 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -420,7 +420,6 @@ LUSTRE_RW_ATTR(threads_max);
  * \addtogoup nrs
  * @{
  */
-extern struct nrs_core nrs_core;
 
 /**
  * Translates \e ptlrpc_nrs_pol_state values to human-readable strings.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index d37cdd5..40696f3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -49,7 +49,6 @@
 
 /* XXX: This is just for liblustre. Remove the #if defined directive when the
  * "cfs_" prefix is dropped from cfs_list_head. */
-extern struct list_head ptlrpc_all_services;
 
 /**
  * NRS core object.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 34c7e28..4e35b14 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -47,6 +47,10 @@ struct ldlm_res_id;
 struct ptlrpc_request_set;
 extern int test_req_buffer_pressure;
 extern struct mutex ptlrpc_all_services_mutex;
+extern struct list_head ptlrpc_all_services;
+
+extern struct mutex ptlrpcd_mutex;
+extern struct mutex pinger_mutex;
 
 int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait);
 /* ptlrpcd.c */
@@ -110,6 +114,8 @@ struct nrs_core {
 
 };
 
+extern struct nrs_core nrs_core;
+
 int ptlrpc_service_nrs_setup(struct ptlrpc_service *svc);
 void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index 9985fb6..d12e95b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -48,8 +48,6 @@ extern spinlock_t ptlrpc_last_xid_lock;
 #if RS_DEBUG
 extern spinlock_t ptlrpc_rs_debug_lock;
 #endif
-extern struct mutex pinger_mutex;
-extern struct mutex ptlrpcd_mutex;
 
 static int __init ptlrpc_init(void)
 {
-- 
2.5.1
