From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:37 -0400
Subject: [lustre-devel] [PATCH 138/151] lustre: update version to 2.10.99
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-139-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With all of the the missing patches from the
lustre 2.11 version merged upstream its time to update
the upstream clients version.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_ver.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_ver.h b/include/uapi/linux/lustre/lustre_ver.h
index e7a2eda..d7c53c5 100644
--- a/include/uapi/linux/lustre/lustre_ver.h
+++ b/include/uapi/linux/lustre/lustre_ver.h
@@ -2,10 +2,10 @@
 #define _LUSTRE_VER_H_
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 9
+#define LUSTRE_MINOR 10
 #define LUSTRE_PATCH 99
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.9.99"
+#define LUSTRE_VERSION_STRING "2.10.99"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.8.3.1
