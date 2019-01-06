From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:28 -0500
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With the majority of missing patches and features from the lustre
2.10 release merged upstream its time to update the upstream
client's version.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
index 1428fdd..e7a2eda 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
@@ -2,10 +2,10 @@
 #define _LUSTRE_VER_H_
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 8
+#define LUSTRE_MINOR 9
 #define LUSTRE_PATCH 99
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.8.99"
+#define LUSTRE_VERSION_STRING "2.9.99"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.8.3.1
