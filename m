From: Patrick Farrell <paf@cray.com>
Date: Mon, 10 Dec 2018 00:57:22 +0000
Subject: [lustre-devel] [PATCH 3/4] lustre: use bit-locking in
 echo_client.
In-Reply-To: <154440277667.29887.4836855598151465010.stgit@noble>
References: <154440246926.29887.1667505755325904791.stgit@noble>,
 <154440277667.29887.4836855598151465010.stgit@noble>
Message-ID: <MWHPR11MB14888CB144E203DFE229518BCBA50@MWHPR11MB1488.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Neil,

So the semantics and behavior for a single bit bit lock and a mutex are the same?  All the scheduler stuff, optimistic spin, etc?  It may not matter here (probably not) but it makes me curious...

- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Sunday, December 9, 2018 6:46:16 PM
To: James Simmons; Oleg Drokin; Andreas Dilger
Cc: Lustre Development List
Subject: [lustre-devel] [PATCH 3/4] lustre: use bit-locking in echo_client.

The ep_lock used by echo client causes lockdep to complain.
Multiple locks of the same class are taken concurrently which
appear to lockdep to be prone to deadlocking, and can fill up
lockdep's fixed size stack for locks.

Ass ep_lock is taken on multiple pages always in ascending page order,
deadlocks don't happen, so this is a false-positive.

The function of the ep_lock is the same as thats for page_lock(),
which is implemented as a bit-lock using wait_on_bit().  lockdep
cannot see these locks, and doesn't really need to.

So convert ep_lock to a simple bit-lock using wait_on_bit for
waiting.  This provides similar functionality, matches how page_lock()
works, and avoids lockdep problems.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    |   29 +++++++++++++-------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 1ddb4a6dd8f3..887df7ce6b5c 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -78,7 +78,7 @@ struct echo_object_conf {

 struct echo_page {
         struct cl_page_slice   ep_cl;
-       struct mutex            ep_lock;
+       unsigned long           ep_lock;
 };

 struct echo_lock {
@@ -217,10 +217,13 @@ static int echo_page_own(const struct lu_env *env,
 {
         struct echo_page *ep = cl2echo_page(slice);

-       if (!nonblock)
-               mutex_lock(&ep->ep_lock);
-       else if (!mutex_trylock(&ep->ep_lock))
-               return -EAGAIN;
+       if (nonblock) {
+               if (test_and_set_bit(0, &ep->ep_lock))
+                       return -EAGAIN;
+       } else {
+               while (test_and_set_bit(0, &ep->ep_lock))
+                       wait_on_bit(&ep->ep_lock, 0, TASK_UNINTERRUPTIBLE);
+       }
         return 0;
 }

@@ -230,8 +233,8 @@ static void echo_page_disown(const struct lu_env *env,
 {
         struct echo_page *ep = cl2echo_page(slice);

-       LASSERT(mutex_is_locked(&ep->ep_lock));
-       mutex_unlock(&ep->ep_lock);
+       LASSERT(test_bit(0, &ep->ep_lock));
+       clear_and_wake_up_bit(0, &ep->ep_lock);
 }

 static void echo_page_discard(const struct lu_env *env,
@@ -244,7 +247,7 @@ static void echo_page_discard(const struct lu_env *env,
 static int echo_page_is_vmlocked(const struct lu_env *env,
                                  const struct cl_page_slice *slice)
 {
-       if (mutex_is_locked(&cl2echo_page(slice)->ep_lock))
+       if (test_bit(0, &cl2echo_page(slice)->ep_lock))
                 return -EBUSY;
         return -ENODATA;
 }
@@ -279,7 +282,7 @@ static int echo_page_print(const struct lu_env *env,
         struct echo_page *ep = cl2echo_page(slice);

         (*printer)(env, cookie, LUSTRE_ECHO_CLIENT_NAME "-page@%p %d vm@%p\n",
-                  ep, mutex_is_locked(&ep->ep_lock),
+                  ep, test_bit(0, &ep->ep_lock),
                    slice->cpl_page->cp_vmpage);
         return 0;
 }
@@ -339,7 +342,13 @@ static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
         struct echo_object *eco = cl2echo_obj(obj);

         get_page(page->cp_vmpage);
-       mutex_init(&ep->ep_lock);
+       /*
+        * ep_lock is similar to the lock_page() lock, and
+        * cannot usefully be monitored by lockdep.
+        * So just a bit in an "unsigned long" and use the
+        * wait_on_bit() interface to wait for the bit to be clera.
+        */
+       ep->ep_lock = 0;
         cl_page_slice_add(page, &ep->ep_cl, obj, index, &echo_page_ops);
         atomic_inc(&eco->eo_npages);
         return 0;


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181210/21dda56c/attachment.html>
