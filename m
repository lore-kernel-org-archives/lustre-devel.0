From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:11 -0500
Subject: [lustre-devel] [PATCH 43/60] staging: lustre: obd: remove
	OBD_NOTIFY_CREATE
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

None of the obd_notify() handlers listen for the OBD_NOTIFY_CREATE
event, so remove it and its sole use in lov_add_target().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8403
Reviewed-on: https://review.whamcloud.com/21420
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h | 2 --
 drivers/staging/lustre/lustre/lov/lov_obd.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ab47078..4ce8506 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -475,8 +475,6 @@ struct niobuf_local {
  * Events signalled through obd_notify() upcall-chain.
  */
 enum obd_notify_event {
-	/* target added */
-	OBD_NOTIFY_CREATE,
 	/* Device connect start */
 	OBD_NOTIFY_CONNECT,
 	/* Device activated */
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 63b0645..b3161fb 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -592,8 +592,6 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	CDEBUG(D_CONFIG, "idx=%d ltd_gen=%d ld_tgt_count=%d\n",
 	       index, tgt->ltd_gen, lov->desc.ld_tgt_count);
 
-	rc = obd_notify(obd, tgt_obd, OBD_NOTIFY_CREATE, &index);
-
 	if (lov->lov_connects == 0) {
 		/* lov_connect hasn't been called yet. We'll do the
 		 * lov_connect_obd on this target when that fn first runs,
-- 
1.8.3.1
