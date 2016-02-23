From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:03 -0500
Subject: [lustre-devel] [PATCH 25/56] staging/lustre: Get rid of C99
	comments in lustre_idl.h
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

lustre_idl.h contains various protocol data. In order to avoid
reusal of values that might have meant something else in the past,
the old no longer used values are commented out, convert the
comments into regular comments from C99 where appropriate.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h        | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4188402..90ff181 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -113,25 +113,25 @@
 
 #define CONNMGR_REQUEST_PORTAL	  1
 #define CONNMGR_REPLY_PORTAL	    2
-//#define OSC_REQUEST_PORTAL	    3
+/*#define OSC_REQUEST_PORTAL	    3 */
 #define OSC_REPLY_PORTAL		4
-//#define OSC_BULK_PORTAL	       5
+/*#define OSC_BULK_PORTAL	       5 */
 #define OST_IO_PORTAL		   6
 #define OST_CREATE_PORTAL	       7
 #define OST_BULK_PORTAL		 8
-//#define MDC_REQUEST_PORTAL	    9
+/*#define MDC_REQUEST_PORTAL	    9 */
 #define MDC_REPLY_PORTAL	       10
-//#define MDC_BULK_PORTAL	      11
+/*#define MDC_BULK_PORTAL	      11 */
 #define MDS_REQUEST_PORTAL	     12
-//#define MDS_REPLY_PORTAL	     13
+/*#define MDS_REPLY_PORTAL	     13 */
 #define MDS_BULK_PORTAL		14
 #define LDLM_CB_REQUEST_PORTAL	 15
 #define LDLM_CB_REPLY_PORTAL	   16
 #define LDLM_CANCEL_REQUEST_PORTAL     17
 #define LDLM_CANCEL_REPLY_PORTAL       18
-//#define PTLBD_REQUEST_PORTAL	   19
-//#define PTLBD_REPLY_PORTAL	     20
-//#define PTLBD_BULK_PORTAL	      21
+/*#define PTLBD_REQUEST_PORTAL	   19 */
+/*#define PTLBD_REPLY_PORTAL	     20 */
+/*#define PTLBD_BULK_PORTAL	      21 */
 #define MDS_SETATTR_PORTAL	     22
 #define MDS_READPAGE_PORTAL	    23
 #define OUT_PORTAL		    24
@@ -1187,7 +1187,7 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define MSG_CONNECT_RECOVERING  0x00000001
 #define MSG_CONNECT_RECONNECT   0x00000002
 #define MSG_CONNECT_REPLAYABLE  0x00000004
-//#define MSG_CONNECT_PEER	0x8
+/*#define MSG_CONNECT_PEER	0x8 */
 #define MSG_CONNECT_LIBCLIENT   0x00000010
 #define MSG_CONNECT_INITIAL     0x00000020
 #define MSG_CONNECT_ASYNC       0x00000040
@@ -2066,7 +2066,7 @@ enum mdt_reint_cmd {
 	REINT_OPEN     = 6,
 	REINT_SETXATTR = 7,
 	REINT_RMENTRY  = 8,
-//      REINT_WRITE    = 9,
+/*      REINT_WRITE    = 9, */
 	REINT_MAX
 };
 
-- 
2.1.0
