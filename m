From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:39:03 -0400
Subject: [lustre-devel] [PATCH 124/124] staging: lustre: update version to
	2.6.99
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-125-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

With all of the the missing patches from the
lustre 2.7 version merged upstream its time to update
the upstream clients version.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_ver.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_ver.h b/drivers/staging/lustre/lustre/include/lustre_ver.h
index 414075f..19c9135 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ver.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ver.h
@@ -2,10 +2,10 @@
 #define _LUSTRE_VER_H_
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 5
-#define LUSTRE_PATCH 60
+#define LUSTRE_MINOR 6
+#define LUSTRE_PATCH 99
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.5.99"
+#define LUSTRE_VERSION_STRING "2.6.99"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.7.1
