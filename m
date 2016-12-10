From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Dec 2016 13:05:58 -0500
Subject: [lustre-devel] [PATCH v2 2/5] staging: lustre: obdclass: style
	cleanup for obdo related functions
In-Reply-To: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1481393161-22623-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Change the style of lustre_get_wire_obdo and
lustre_set_wire_obdo to conform to linux kernel
standard.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/16917
Reviewed-on: http://review.whamcloud.com/19266
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obdo.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 241e60b..b1dfa16 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -139,7 +139,8 @@ void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 
 	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
 	    fid_seq_is_echo(ostid_seq(&lobdo->o_oi))) {
-		/* Currently OBD_FL_OSTID will only be used when 2.4 echo
+		/*
+		 * Currently OBD_FL_OSTID will only be used when 2.4 echo
 		 * client communicate with pre-2.4 server
 		 */
 		wobdo->o_oi.oi.oi_id = fid_oid(&lobdo->o_oi.oi_fid);
@@ -154,13 +155,13 @@ void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
 			  struct obdo *lobdo, const struct obdo *wobdo)
 {
-	__u32 local_flags = 0;
+	u32 local_flags = 0;
 
 	if (lobdo->o_valid & OBD_MD_FLFLAGS)
 		local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
 
 	*lobdo = *wobdo;
-	if (local_flags != 0) {
+	if (local_flags) {
 		lobdo->o_valid |= OBD_MD_FLFLAGS;
 		lobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
 		lobdo->o_flags |= local_flags;
-- 
1.8.3.1
