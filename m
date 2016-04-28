From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:12 -0400
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: ptlrpc: use unified
	handler for OST requests
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhail Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhail Pershin <mike.pershin@intel.com>

Switch OST/OFD request processing to the unified request
handle.

Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3467
Reviewed-on: http://review.whamcloud.com/7130
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_req_layout.h    |  2 +-
 drivers/staging/lustre/lustre/include/obd_support.h      |  1 +
 drivers/staging/lustre/lustre/ptlrpc/layout.c            | 16 +++++++++++-----
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index b2e67fc..b0bc751 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -199,7 +199,7 @@ extern struct req_format RQF_OST_BRW_READ;
 extern struct req_format RQF_OST_BRW_WRITE;
 extern struct req_format RQF_OST_STATFS;
 extern struct req_format RQF_OST_SET_GRANT_INFO;
-extern struct req_format RQF_OST_GET_INFO_GENERIC;
+extern struct req_format RQF_OST_GET_INFO;
 extern struct req_format RQF_OST_GET_INFO_LAST_ID;
 extern struct req_format RQF_OST_GET_INFO_LAST_FID;
 extern struct req_format RQF_OST_SET_INFO_LAST_FID;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index c7267b7..2aaa343 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -290,6 +290,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OST_ENOINO	      0x229
 #define OBD_FAIL_OST_DQACQ_NET	   0x230
 #define OBD_FAIL_OST_STATFS_EINPROGRESS  0x231
+#define OBD_FAIL_OST_SET_INFO_NET		0x232
 
 #define OBD_FAIL_LDLM		    0x300
 #define OBD_FAIL_LDLM_NAMESPACE_NEW      0x301
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 5b06901..ccc1f3e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -566,7 +566,7 @@ static const struct req_msg_field *ost_get_info_generic_server[] = {
 
 static const struct req_msg_field *ost_get_info_generic_client[] = {
 	&RMF_PTLRPC_BODY,
-	&RMF_SETINFO_KEY
+	&RMF_GETINFO_KEY
 };
 
 static const struct req_msg_field *ost_get_last_id_server[] = {
@@ -574,6 +574,12 @@ static const struct req_msg_field *ost_get_last_id_server[] = {
 	&RMF_OBD_ID
 };
 
+static const struct req_msg_field *ost_get_last_fid_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_GETINFO_KEY,
+	&RMF_FID,
+};
+
 static const struct req_msg_field *ost_get_last_fid_server[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_FID,
@@ -696,7 +702,7 @@ static struct req_format *req_formats[] = {
 	&RQF_OST_BRW_WRITE,
 	&RQF_OST_STATFS,
 	&RQF_OST_SET_GRANT_INFO,
-	&RQF_OST_GET_INFO_GENERIC,
+	&RQF_OST_GET_INFO,
 	&RQF_OST_GET_INFO_LAST_ID,
 	&RQF_OST_GET_INFO_LAST_FID,
 	&RQF_OST_SET_INFO_LAST_FID,
@@ -1519,10 +1525,10 @@ struct req_format RQF_OST_SET_GRANT_INFO =
 			ost_body_only);
 EXPORT_SYMBOL(RQF_OST_SET_GRANT_INFO);
 
-struct req_format RQF_OST_GET_INFO_GENERIC =
+struct req_format RQF_OST_GET_INFO =
 	DEFINE_REQ_FMT0("OST_GET_INFO", ost_get_info_generic_client,
 			ost_get_info_generic_server);
-EXPORT_SYMBOL(RQF_OST_GET_INFO_GENERIC);
+EXPORT_SYMBOL(RQF_OST_GET_INFO);
 
 struct req_format RQF_OST_GET_INFO_LAST_ID =
 	DEFINE_REQ_FMT0("OST_GET_INFO_LAST_ID", ost_get_info_generic_client,
@@ -1530,7 +1536,7 @@ struct req_format RQF_OST_GET_INFO_LAST_ID =
 EXPORT_SYMBOL(RQF_OST_GET_INFO_LAST_ID);
 
 struct req_format RQF_OST_GET_INFO_LAST_FID =
-	DEFINE_REQ_FMT0("OST_GET_INFO_LAST_FID", obd_set_info_client,
+	DEFINE_REQ_FMT0("OST_GET_INFO_LAST_FID", ost_get_last_fid_client,
 			ost_get_last_fid_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_LAST_FID);
 
-- 
2.7.4
