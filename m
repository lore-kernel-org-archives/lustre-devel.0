From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:40 -0500
Subject: [lustre-devel] [PATCH 472/622] lustre: osc: remove oe_next_page
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-473-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

As the comment says, this field is unused.  So remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: d1b08c58b43e ("LU-6142 osc: remove oe_next_page")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35890
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 044185d..de7ccd6 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -946,11 +946,6 @@ struct osc_extent {
 	unsigned int		oe_nr_pages;
 	/* list of pending oap pages. Pages in this list are NOT sorted. */
 	struct list_head	oe_pages;
-	/* Since an extent has to be written out in atomic, this is used to
-	 * remember the next page need to be locked to write this extent out.
-	 * Not used right now.
-	 */
-	struct osc_page		*oe_next_page;
 	/* start and end index of this extent, include start and end
 	 * themselves. Page offset here is the page index of osc_pages.
 	 * oe_start is used as keyword for red-black tree.
-- 
1.8.3.1
