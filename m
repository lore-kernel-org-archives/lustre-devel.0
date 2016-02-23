From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:43 -0500
Subject: [lustre-devel] [PATCH 05/56] staging/lustre: Get rid of ost_cmd_t
	typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ost_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0f37b61..50e70fe 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1419,7 +1419,7 @@ enum cksum_type {
  */
 
 /* opcodes */
-typedef enum {
+enum ost_cmd {
 	OST_REPLY      =  0,       /* reply ? */
 	OST_GETATTR    =  1,
 	OST_SETATTR    =  2,
@@ -1440,7 +1440,7 @@ typedef enum {
 	OST_QUOTACTL   = 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
 	OST_LAST_OPC
-} ost_cmd_t;
+};
 #define OST_FIRST_OPC  OST_REPLY
 
 enum obdo_flags {
-- 
2.1.0
