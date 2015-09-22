From: Anton Gerasimov <anton.gerasimov@openmailbox.org>
Date: Wed, 23 Sep 2015 01:24:21 +0300
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: add shared variables to
	the header
Message-ID: <20150922222414.GA2777@linux-0hv4.site>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch adds declarations for variables used in several files
across the ptlrpc module to the local header.

Signed-off-by: Anton Gerasimov <anton.gerasimov@openmailbox.org>
---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h | 6 ++++++
 1 file changed, 6 insertions(+)

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
 
-- 
2.5.1
