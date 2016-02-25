From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:52 -0500
Subject: [lustre-devel] [PATCH v2 09/84] staging/lustre: Get rid of
	mds_reint_t, mdt_reint_t typedefs
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace with enum mdt_reint_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a72fed0..bd8b622 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2065,7 +2065,7 @@ typedef enum {
  * Do not exceed 63
  */
 
-typedef enum {
+enum mdt_reint_cmd {
 	REINT_SETATTR  = 1,
 	REINT_CREATE   = 2,
 	REINT_LINK     = 3,
@@ -2076,7 +2076,7 @@ typedef enum {
 	REINT_RMENTRY  = 8,
 //      REINT_WRITE    = 9,
 	REINT_MAX
-} mds_reint_t, mdt_reint_t;
+};
 
 void lustre_swab_generic_32s(__u32 *val);
 
-- 
2.1.0
