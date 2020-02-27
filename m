From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:26 -0500
Subject: [lustre-devel] [PATCH 458/622] lustre: lustre: remove
 imp_no_timeout field
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-459-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set and never used.  Remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: b9dd17681bfa ("LU-6142 lustre: remove imp_no_timeout field")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35877
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index ff171d1..c2f98e6 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -273,8 +273,7 @@ struct obd_import {
 	spinlock_t			imp_lock;
 
 	/* flags */
-	unsigned long			imp_no_timeout:1, /* timeouts are disabled */
-					imp_invalid:1,    /* evicted */
+	unsigned long			imp_invalid:1,    /* evicted */
 					/* administratively disabled */
 					imp_deactive:1,
 					/* try to recover the import */
-- 
1.8.3.1
