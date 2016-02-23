From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:45 -0500
Subject: [lustre-devel] [PATCH 07/56] staging/lustre: Get rid of mds_cmd_t
	typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum mds_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c0b05d4..a72fed0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2018,7 +2018,7 @@ enum quota_cmd {
  */
 
 /* opcodes */
-typedef enum {
+enum mds_cmd {
 	MDS_GETATTR		= 33,
 	MDS_GETATTR_NAME	= 34,
 	MDS_CLOSE		= 35,
@@ -2049,7 +2049,7 @@ typedef enum {
 	MDS_HSM_CT_UNREGISTER	= 60,
 	MDS_SWAP_LAYOUTS	= 61,
 	MDS_LAST_OPC
-} mds_cmd_t;
+};
 
 #define MDS_FIRST_OPC    MDS_GETATTR
 
-- 
2.1.0
