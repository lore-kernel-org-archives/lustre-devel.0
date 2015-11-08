From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:34:58 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: enum lu_object_header_flags
	comma style fix
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Cleanup the a style issues for the lu_object_header_flags
enum by adding a comma for the last field. This is
broken out of patch http://review.whamcloud.com/6321.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2914
Reviewed-on: http://review.whamcloud.com/6321
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index fa78689..c5a56a8 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -488,7 +488,7 @@ enum lu_object_header_flags {
 	/**
 	 * Mark this object has already been taken out of cache.
 	 */
-	LU_OBJECT_UNHASHED = 1
+	LU_OBJECT_UNHASHED = 1,
 };
 
 enum lu_object_header_attr {
-- 
1.7.1
