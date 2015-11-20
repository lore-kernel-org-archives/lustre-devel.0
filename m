From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:50 -0500
Subject: [lustre-devel] [PATCH 14/40] staging: lustre: fix crash due to NULL
	networks string
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

If there is an invalid networks or ip2nets lnet_parse_networks()
gets called with a NULL 'network' string parameter

lnet_parse_networks() needs to sanitize its input string now that
it's being called from multiple places.  Instead, check for
a NULL string everytime the function is called, which reduces the
probability of errors with other code modifications.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5540
Reviewed-on: http://review.whamcloud.com/11626
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    5 +----
 drivers/staging/lustre/lnet/lnet/config.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 165345c..cc87900 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1524,7 +1524,6 @@ LNetNIInit(lnet_pid_t requested_pid)
 	lnet_ping_info_t *pinfo;
 	lnet_handle_md_t md_handle;
 	struct list_head net_head;
-	char *nets;
 
 	INIT_LIST_HEAD(&net_head);
 
@@ -1539,13 +1538,11 @@ LNetNIInit(lnet_pid_t requested_pid)
 		return rc;
 	}
 
-	nets = lnet_get_networks();
-
 	rc = lnet_prepare(requested_pid);
 	if (rc != 0)
 		goto failed0;
 
-	rc = lnet_parse_networks(&net_head, nets);
+	rc = lnet_parse_networks(&net_head, lnet_get_networks());
 	if (rc < 0)
 		goto failed1;
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 1c7ad7c..d1e0217 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -184,7 +184,7 @@ int
 lnet_parse_networks(struct list_head *nilist, char *networks)
 {
 	struct cfs_expr_list *el = NULL;
-	int tokensize = strlen(networks) + 1;
+	int tokensize;
 	char *tokens;
 	char *str;
 	char *tmp;
@@ -192,6 +192,11 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	__u32 net;
 	int nnets = 0;
 
+	if (!networks) {
+		CERROR("networks string is undefined\n");
+		return -EINVAL;
+	}
+
 	if (strlen(networks) > LNET_SINGLE_TEXTBUF_NOB) {
 		/* _WAY_ conservative */
 		LCONSOLE_ERROR_MSG(0x112,
@@ -199,6 +204,8 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		return -EINVAL;
 	}
 
+	tokensize = strlen(networks) + 1;
+
 	LIBCFS_ALLOC(tokens, tokensize);
 	if (tokens == NULL) {
 		CERROR("Can't allocate net tokens\n");
-- 
1.7.1
