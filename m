From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:48 -0400
Subject: [lustre-devel] [PATCH 029/151] lnet: selftest: Use C99 struct
 initializer in framework.c
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes.  The struct initializer in
framework.c is updated to C99 syntax.

C89 positional initializers require values to be placed in the
correct order. This will cause errors if the fields of the struct
definition are reordered or fields are added or removed. C99 named
initializers avoid this problem, and also automatically clear any
values that are not explicitly set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6210
Lustre-commit: 60c9a2d351d4 ("LU-6210 lnet: Use C99 struct initializer in framework.c")
Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-on: https://review.whamcloud.com/28436
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/framework.c | 42 +++++++-----------------------------------
 1 file changed, 7 insertions(+), 35 deletions(-)

diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index 958f627..72892c1 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -1584,41 +1584,13 @@ struct srpc_client_rpc *
 }
 
 static struct srpc_service sfw_services[] = {
-	{
-		/* sv_id */    SRPC_SERVICE_DEBUG,
-		/* sv_name */  "debug",
-		0
-	},
-	{
-		/* sv_id */    SRPC_SERVICE_QUERY_STAT,
-		/* sv_name */  "query stats",
-		0
-	},
-	{
-		/* sv_id */    SRPC_SERVICE_MAKE_SESSION,
-		/* sv_name */  "make session",
-		0
-	},
-	{
-		/* sv_id */    SRPC_SERVICE_REMOVE_SESSION,
-		/* sv_name */  "remove session",
-		0
-	},
-	{
-		/* sv_id */    SRPC_SERVICE_BATCH,
-		/* sv_name */  "batch service",
-		0
-	},
-	{
-		/* sv_id */    SRPC_SERVICE_TEST,
-		/* sv_name */  "test service",
-		0
-	},
-	{
-		/* sv_id */    0,
-		/* sv_name */  NULL,
-		0
-	}
+	{ .sv_id = SRPC_SERVICE_DEBUG,		.sv_name = "debug", },
+	{ .sv_id = SRPC_SERVICE_QUERY_STAT,	.sv_name = "query stats", },
+	{ .sv_id = SRPC_SERVICE_MAKE_SESSION,	.sv_name = "make session", },
+	{ .sv_id = SRPC_SERVICE_REMOVE_SESSION,	.sv_name = "remove session", },
+	{ .sv_id = SRPC_SERVICE_BATCH,		.sv_name = "batch service", },
+	{ .sv_id = SRPC_SERVICE_TEST,		.sv_name = "test service", },
+	{ .sv_id = 0, }
 };
 
 int
-- 
1.8.3.1
