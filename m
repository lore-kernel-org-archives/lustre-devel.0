From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:18 -0400
Subject: [lustre-devel] [PATCH 39/42] lustre: update version to 2.13.56
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

New tag 2.13.56

Signed-off-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_ver.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_ver.h b/include/uapi/linux/lustre/lustre_ver.h
index f206b6c..8d2f2e8 100644
--- a/include/uapi/linux/lustre/lustre_ver.h
+++ b/include/uapi/linux/lustre/lustre_ver.h
@@ -3,9 +3,9 @@
 
 #define LUSTRE_MAJOR 2
 #define LUSTRE_MINOR 13
-#define LUSTRE_PATCH 55
+#define LUSTRE_PATCH 56
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.13.55"
+#define LUSTRE_VERSION_STRING "2.13.56"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.8.3.1
