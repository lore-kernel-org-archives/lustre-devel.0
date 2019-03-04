From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 15/28] lustre: portals_handle: remove locking
 from class_handle2object()
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109862.31333.3123977535029863907.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There can be no value in this locking and test on h_in.

If the lookup could have run in parallel with
class_handle_unhash_nolock() and seen "h_in == 0", then it could
equally well have run moments earlier and not seen it - no locking
would prevent that, so the caller much be prepared to have
an object returned which has already been unhashed by the time it
sees the object.

In other words, an interlock between unhash and lookup much be
provided at a higher level than where this code is trying
to handle it.

So remove this pointless code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/obdclass/lustre_handles.c        |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index f41558ccdfcf..45e5eac47292 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -149,15 +149,11 @@ void *class_handle2object(u64 cookie, char *owner)
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
