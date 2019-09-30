From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:58 -0400
Subject: [lustre-devel] [PATCH 099/151] lustre: vvp: Print discarded page
 warning on -EIO
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-100-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

On client eviction, the client sometimes has dirty pages
outstanding, which are then discarded.  The client is
supposed to print an error when this happens,
from vvp_vmpage_error->ll_dirty_page_discard_warn.

However, the client looks for specific errors, and newer
Lustre clients will sometimes return -EIO to I/O requests
on eviction, instead of -EINTR.  Since they can still
return -EINTR, we must add -EIO as a new condition and
keep -EINTR.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8358
Lustre-commit: 5f327f6670d3 ("LU-8358 vvp: Print discarded page warning on -EIO")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/21111
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_page.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index beebea8..78a70b5 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -241,8 +241,8 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage,
 		SetPageError(vmpage);
 		mapping_set_error(inode->i_mapping, ioret);
 
-		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
-		    obj->vob_discard_page_warned == 0) {
+		if ((ioret == -ESHUTDOWN || ioret == -EINTR ||
+		     ioret == -EIO) && obj->vob_discard_page_warned == 0) {
 			obj->vob_discard_page_warned = 1;
 			ll_dirty_page_discard_warn(vmpage, ioret);
 		}
-- 
1.8.3.1
