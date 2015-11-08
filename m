From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:35:00 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: add libcfs version of
	cfs_strrstr
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Create a kernel side function that does the same
thing as userland strrstr. This is from patch
http://review.whamcloud.com/7666.

Signed-off-by: Fan Yong <fan.yong@intel.com>
ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-3951
Reviewed-on: http://review.whamcloud.com/7666
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    1 +
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |   27 ++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index d8d2e7d..052f684 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -44,6 +44,7 @@
 #define __LIBCFS_STRING_H__
 
 /* libcfs_string.c */
+char *cfs_strrstr(const char *haystack, const char *needle);
 /* string comparison ignoring case */
 int cfs_strncasecmp(const char *s1, const char *s2, size_t n);
 /* Convert a text string to a bitmask */
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 05630f8..4e399ef 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -42,6 +42,33 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
+char *cfs_strrstr(const char *haystack, const char *needle)
+{
+	char *ptr;
+
+	if (unlikely(!haystack || !needle))
+		return NULL;
+
+	if (strlen(needle) == 1)
+		return strrchr(haystack, needle[0]);
+
+	ptr = strstr(haystack, needle);
+	if (ptr) {
+		while (1) {
+			char *tmp;
+
+			tmp = strstr(&ptr[1], needle);
+			if (!tmp)
+				return ptr;
+
+			ptr = tmp;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(cfs_strrstr);
+
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		 int *oldmask, int minmask, int allmask)
-- 
1.7.1
