From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 13 Oct 2016 11:52:02 +0300
Subject: [lustre-devel] [patch] Staging: lustre: indent an if statement
Message-ID: <20161013085202.GE16198@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This if statement wasn't intended.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 3199dd4..a102c36 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -335,7 +335,7 @@ int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 		if (obj->co_ops->coo_getstripe) {
 			result = obj->co_ops->coo_getstripe(env, obj, uarg);
 			if (result)
-			break;
+				break;
 		}
 	}
 	return result;
