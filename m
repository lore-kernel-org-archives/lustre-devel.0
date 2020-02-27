From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:26 -0500
Subject: [lustre-devel] [PATCH 518/622] lustre: obd: discard unused enum
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-519-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

The values in this enum are never used - so discard it.

Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/include/obd.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 4ba70c7..5f5a595 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -133,14 +133,6 @@ struct timeout_item {
 #define OSC_MAX_DIRTY_MB_MAX	2048	/* arbitrary, but < MAX_LONG bytes */
 #define OSC_DEFAULT_RESENDS	10
 
-/* possible values for fo_sync_lock_cancel */
-enum {
-	NEVER_SYNC_ON_CANCEL	= 0,
-	BLOCKING_SYNC_ON_CANCEL	= 1,
-	ALWAYS_SYNC_ON_CANCEL	= 2,
-	NUM_SYNC_ON_CANCEL_STATES
-};
-
 enum obd_cl_sem_lock_class {
 	OBD_CLI_SEM_NORMAL,
 	OBD_CLI_SEM_MGC,
-- 
1.8.3.1
