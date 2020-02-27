From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:49 -0500
Subject: [lustre-devel] [PATCH 001/622] lustre: always enable special
 debugging, fhandles, and quota support.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre heavily depends on fhandles for its FID handling and needs
quota always enabled.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/lustre/Kconfig b/fs/lustre/Kconfig
index 2ea3f24..2eb7e45 100644
--- a/fs/lustre/Kconfig
+++ b/fs/lustre/Kconfig
@@ -9,6 +9,9 @@ config LUSTRE_FS
 	select CRYPTO_SHA1
 	select CRYPTO_SHA256
 	select CRYPTO_SHA512
+	select DEBUG_FS
+	select FHANDLE
+	select QUOTA
 	depends on MULTIUSER
 	help
 	  This option enables Lustre file system client support. Choose Y
@@ -43,6 +46,7 @@ config LUSTRE_FS_POSIX_ACL
 
 config LUSTRE_DEBUG_EXPENSIVE_CHECK
 	bool "Enable Lustre DEBUG checks"
+	select REFCOUNT_FULL
 	depends on LUSTRE_FS
 	help
 	  This option is mainly for debug purpose. It enables Lustre code to do
-- 
1.8.3.1
