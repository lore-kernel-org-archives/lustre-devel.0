From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:23 -0500
Subject: [lustre-devel] [PATCH 07/12] lustre: ldlm: No -EINVAL for canceled
 != unused
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

If any locks are removed from or added to the lru, the
check of "number unused vs number cancelled" may be wrong.
This is fine - do not return an error or print debug in
this case.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7802
Reviewed-on: https://review.whamcloud.com/28560
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 5028db7..11c0b88 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -193,19 +193,9 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		       "dropping all unused locks from namespace %s\n",
 		       ldlm_ns_name(ns));
 		if (ns_connect_lru_resize(ns)) {
-			int canceled, unused  = ns->ns_nr_unused;
-
-			/* Try to cancel all @ns_nr_unused locks. */
-			canceled = ldlm_cancel_lru(ns, unused, 0,
-						   LDLM_LRU_FLAG_PASSED |
-						   LDLM_LRU_FLAG_CLEANUP);
-			if (canceled < unused) {
-				CDEBUG(D_DLMTRACE,
-				       "not all requested locks are canceled, requested: %d, canceled: %d\n",
-				       unused,
-				       canceled);
-				return -EINVAL;
-			}
+			ldlm_cancel_lru(ns, ns->ns_nr_unused, 0,
+					LDLM_LRU_FLAG_PASSED |
+					LDLM_LRU_FLAG_CLEANUP);
 		} else {
 			tmp = ns->ns_max_unused;
 			ns->ns_max_unused = 0;
-- 
1.8.3.1
