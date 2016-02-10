From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:22 -0500
Subject: [lustre-devel] [PATCH 5/5] staging/lustre: Remove unused
	LUSTRE_VERSION_ALLOWED_OFFSET define
In-Reply-To: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
References: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455127222-2557752-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

LUSTRE_VERSION_ALLOWED_OFFSET is only used on the server to disallow
connection of old userspace clients.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_ver.h | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_ver.h b/drivers/staging/lustre/lustre/include/lustre_ver.h
index 01205b8..64559a1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ver.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ver.h
@@ -11,13 +11,10 @@
 					    LUSTRE_MINOR, LUSTRE_PATCH, \
 					    LUSTRE_FIX)
 
-/* liblustre clients are only allowed to connect if their LUSTRE_FIX mismatches
- * by this amount (set in lustre/autoconf/lustre-version.ac). */
-#define LUSTRE_VERSION_ALLOWED_OFFSET OBD_OCD_VERSION(0, 0, 1, 32)
-
-/* If lustre version of client and servers it connects to differs by more
+/*
+ * If lustre version of client and servers it connects to differs by more
  * than this amount, client would issue a warning.
- * (set in lustre/autoconf/lustre-version.ac) */
+ */
 #define LUSTRE_VERSION_OFFSET_WARN OBD_OCD_VERSION(0, 4, 0, 0)
 
 #endif
-- 
2.1.0
