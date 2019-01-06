From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:26 -0500
Subject: [lustre-devel] [PATCH v2 31/33] lustre: lov: call
 cl_object_attr_get under cl_attr lock
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mike Pershin <mpershin@whamcloud.com>

cl_object_attr_get() must be called under cl_object_attr_lock
get. There is place in lov_getstripe where it is called
without that lock.

Signed-off-by: Mike Pershin <mpershin@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10232
Reviewed-on: https://review.whamcloud.com/30052
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index ef3c040..089e556 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -397,7 +397,9 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 
 			attr.cat_size = 0;
 			cl_obj = cl_object_top(&obj->lo_cl);
+			cl_object_attr_lock(cl_obj);
 			cl_object_attr_get(env, cl_obj, &attr);
+			cl_object_attr_unlock(cl_obj);
 
 			/* return the last instantiated component if file size
 			 * is non-zero, otherwise, return the last component.
-- 
1.8.3.1
