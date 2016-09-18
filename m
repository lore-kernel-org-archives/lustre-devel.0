From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:25 -0400
Subject: [lustre-devel] [PATCH 086/124] staging: lustre: obdclass: eliminate
	NULL error return
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-87-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bob Glossman <bob.glossman@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bob Glossman <bob.glossman@intel.com>

Always return an ERR_PTR() on errors, never return a NULL,
in lu_object_find_slice().  Also clean up callers who
no longer need special case handling of NULL returns.

Signed-off-by: Bob Glossman <bob.glossman@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5858
Reviewed-on: http://review.whamcloud.com/12554
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 7339c8b..3f1fb28 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -767,13 +767,15 @@ struct lu_object *lu_object_find_slice(const struct lu_env *env,
 	struct lu_object *obj;
 
 	top = lu_object_find(env, dev, f, conf);
-	if (!IS_ERR(top)) {
-		obj = lu_object_locate(top->lo_header, dev->ld_type);
-		if (!obj)
-			lu_object_put(env, top);
-	} else {
-		obj = top;
+	if (IS_ERR(top))
+		return top;
+
+	obj = lu_object_locate(top->lo_header, dev->ld_type);
+	if (unlikely(!obj)) {
+		lu_object_put(env, top);
+		obj = ERR_PTR(-ENOENT);
 	}
+
 	return obj;
 }
 EXPORT_SYMBOL(lu_object_find_slice);
-- 
1.7.1
