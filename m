From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:48 -0500
Subject: [lustre-devel] [PATCH 600/622] lustre: handle: remove locking from
 class_handle2object()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-601-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

There is limited value in this locking and test on h_in.

If the lookup could have run in parallel with
class_handle_unhash_nolock() and seen "h_in == 0", then it could
equally well have run moments earlier and not seen it - no locking
would prevent that, so the caller much be prepared to have
an object returned which has already been unhashed by the time it
sees the object.

In other words, any interlock between unhash and lookup must be
provided at a higher level than where this code is trying
to handle it.

The locking *does* prevent the refcount from being incremented if the
object has already been removed from the list.  As the final reference
is always dropped after that removal, it indirectly stops the refcount
from being incremented after the final reference is dropped.
This can be more directly achieved by using refcount_inc_not_zero().

So remove the locking, and replace it with refcount_inc_not_zero().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: e2458a94a6a2 ("LU-12542 handle: remove locking from class_handle2object()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/35861
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lustre_handles.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 6989a60..acee2db 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -149,15 +149,12 @@ void *class_handle2object(u64 cookie, const char *owner)
 		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
-		spin_lock(&h->h_lock);
-		if (likely(h->h_in != 0)) {
-			refcount_inc(&h->h_ref);
+		if (refcount_inc_not_zero(&h->h_ref)) {
 			CDEBUG(D_INFO, "GET %s %p refcount=%d\n",
 			       h->h_owner, h,
 			       refcount_read(&h->h_ref));
 			retval = h;
 		}
-		spin_unlock(&h->h_lock);
 		break;
 	}
 	rcu_read_unlock();
-- 
1.8.3.1
