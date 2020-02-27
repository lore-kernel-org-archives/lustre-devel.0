From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:46 -0500
Subject: [lustre-devel] [PATCH 178/622] lustre: update version to 2.11.99
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-179-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With nearly all of the the missing patches from the
lustre 2.12 version merged upstream its time to update
the upstream clients version.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_ver.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_ver.h b/include/uapi/linux/lustre/lustre_ver.h
index d7c53c5..8ceb57d 100644
--- a/include/uapi/linux/lustre/lustre_ver.h
+++ b/include/uapi/linux/lustre/lustre_ver.h
@@ -2,10 +2,10 @@
 #define _LUSTRE_VER_H_
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 10
+#define LUSTRE_MINOR 11
 #define LUSTRE_PATCH 99
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.10.99"
+#define LUSTRE_VERSION_STRING "2.11.99"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.8.3.1
