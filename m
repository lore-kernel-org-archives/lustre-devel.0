From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:21 -0500
Subject: [lustre-devel] [PATCH 453/622] lustre: uapi: fix building fail
 against Power9 little endian
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-454-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gu Zheng <gzheng@ddn.com>

We use "%ll[dux]" for __u64 variable as an input/output modifier,
this may cause building error on some architectures which use "long"
for 64-bit types, for example, Power9 little endian.
Here add necessary typecasting (long long/unsigned long long) to
make the build correct.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12705
Lustre-commit: 4eddf36ac360 ("LU-12705 build: fix building fail against Power9 little endian")
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Reviewed-on: https://review.whamcloud.com/36007
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3016b73..695ceb2 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -512,7 +512,7 @@ struct lu_extent {
 };
 
 #define DEXT "[%#llx, %#llx)"
-#define PEXT(ext) (ext)->e_start, (ext)->e_end
+#define PEXT(ext) (unsigned long long)(ext)->e_start, (unsigned long long)(ext)->e_end
 
 static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
 					    struct lu_extent *e2)
-- 
1.8.3.1
