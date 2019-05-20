From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:02 -0400
Subject: [lustre-devel] [PATCH v2 20/29] lustre: portals_handle: remove
 locking from class_handle2object()
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There can be no value in this locking and test on h_in.

If the lookup could have run in parallel with
class_handle_unhash_nolock() and seen "h_in == 0", then it could
equally well have run moments earlier and not seen it - no locking
would prevent that, so the caller much be prepared to have
an object returned which has already been unhashed by the time it
sees the object.

In other words, an interlock between unhash and lookup must be
provided at a higher level than where this code is trying
to handle it.

So remove this pointless code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/lustre_handles.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 00d8a89..d8bab07 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -149,15 +149,11 @@ void *class_handle2object(u64 cookie, const char *owner)
 		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
-		spin_lock(&h->h_lock);
-		if (likely(h->h_in != 0)) {
-			refcount_inc(&h->h_ref);
-			CDEBUG(D_INFO, "GET %s %p refcount=%d\n",
-			       h->h_owner, h,
-			       refcount_read(&h->h_ref));
-			retval = h;
-		}
-		spin_unlock(&h->h_lock);
+		refcount_inc(&h->h_ref);
+		CDEBUG(D_INFO, "GET %s %p refcount=%d\n",
+		       h->h_owner, h,
+		       refcount_read(&h->h_ref));
+		retval = h;
 		break;
 	}
 	rcu_read_unlock();
-- 
1.8.3.1
