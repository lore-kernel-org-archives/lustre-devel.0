From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:21 -0500
Subject: [lustre-devel] [PATCH 4/5] staging/lustre: Update internal client
	version.
In-Reply-To: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
References: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455127222-2557752-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

While initial code drop was corresponding to 2.3.64, lots of
different changes went in since then, and also quite a bunch of fixes,
but almost none of the new features.
Code-wise we are almost at 2.5.0, so let's call it 2.4.60 - this is a
version that was never reached in the actual pre-2.5 development, so
it should be a clear distinction of where we are now.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_ver.h | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_ver.h b/drivers/staging/lustre/lustre/include/lustre_ver.h
index caa4da1..01205b8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ver.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ver.h
@@ -1,14 +1,11 @@
 #ifndef _LUSTRE_VER_H_
 #define _LUSTRE_VER_H_
-/* This file automatically generated from lustre/include/lustre_ver.h.in,
- * based on parameters in lustre/autoconf/lustre-version.ac.
- * Changes made directly to this file will be lost. */
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 3
-#define LUSTRE_PATCH 64
+#define LUSTRE_MINOR 4
+#define LUSTRE_PATCH 60
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.3.64"
+#define LUSTRE_VERSION_STRING "2.4.60"
 
 #define LUSTRE_VERSION_CODE OBD_OCD_VERSION(LUSTRE_MAJOR, \
 					    LUSTRE_MINOR, LUSTRE_PATCH, \
-- 
2.1.0
