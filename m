From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:02 -0400
Subject: [lustre-devel] [PATCH 003/124] staging: lustre: ldlm: fix a use
	after free in ldlm_resource_get()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

If lvbo initialization has failed then save the return status (from
lr_lvb_len) before putting the resource.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5305
Reviewed-on: http://review.whamcloud.com/11017
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 62d9f6f..912cd68 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1091,6 +1091,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	struct cfs_hash_bd	 bd;
 	__u64		 version;
 	int		      ns_refcount = 0;
+	int rc;
 
 	LASSERT(!parent);
 	LASSERT(ns->ns_rs_hash);
@@ -1140,8 +1141,9 @@ lvbo_init:
 		}
 
 		if (unlikely(res->lr_lvb_len < 0)) {
+			rc = res->lr_lvb_len;
 			ldlm_resource_putref(res);
-			res = ERR_PTR(res->lr_lvb_len);
+			res = ERR_PTR(rc);
 		}
 		return res;
 	}
@@ -1152,8 +1154,6 @@ lvbo_init:
 
 	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
 	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-		int rc;
-
 		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
 		rc = ns->ns_lvbo->lvbo_init(res);
 		if (rc < 0) {
-- 
1.7.1
