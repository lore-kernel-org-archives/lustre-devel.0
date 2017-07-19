From: Patrick Farrell <paf@cray.com>
Date: Wed, 19 Jul 2017 01:54:27 +0000
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: ldlm: tidy list
 walking in ldlm_flock()
In-Reply-To: <150042040763.20736.17969183285195201575.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>,
	<150042040763.20736.17969183285195201575.stgit@noble>
Message-ID: <BN6PR1101MB2132359E48C9904D3E305EE7CBA60@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Neil,

Minor...
"order might not be a lock" looks like it should say "or"?

- Patrick
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Tuesday, July 18, 2017 6:26:47 PM
To: Oleg Drokin; Greg Kroah-Hartman; Andreas Dilger
Cc: Linux Kernel Mailing List; Lustre Development List
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: ldlm: tidy list walking in ldlm_flock()

Use list_for_each_entry variants to
avoid the explicit list_entry() calls.
This allows us to use list_for_each_entry_safe_from()
instread of adding a local list-walking macro.

Also improve some comments so that it is more obvious
that the locks are sorted per-owner and that we need
to find the insertion point.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   45 ++++++++++-------------
 1 file changed, 19 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 9a888e1ce923..58227728a002 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -59,17 +59,6 @@
 #include <linux/list.h>
 #include "ldlm_internal.h"

-/**
- * list_for_remaining_safe - iterate over the remaining entries in a list
- *           and safeguard against removal of a list entry.
- * \param pos   the &struct list_head to use as a loop counter. pos MUST
- *           have been initialized prior to using it in this macro.
- * \param n     another &struct list_head to use as temporary storage
- * \param head  the head for your list.
- */
-#define list_for_remaining_safe(pos, n, head) \
-       for (n = pos->next; pos != (head); pos = n, n = pos->next)
-
 static inline int
 ldlm_same_flock_owner(struct ldlm_lock *lock, struct ldlm_lock *new)
 {
@@ -125,8 +114,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 {
         struct ldlm_resource *res = req->l_resource;
         struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-       struct list_head *tmp;
-       struct list_head *ownlocks = NULL;
+       struct ldlm_lock *tmp;
+       struct ldlm_lock *ownlocks = NULL;
         struct ldlm_lock *lock = NULL;
         struct ldlm_lock *new = req;
         struct ldlm_lock *new2 = NULL;
@@ -151,23 +140,23 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
         /* This loop determines where this processes locks start
          * in the resource lr_granted list.
          */
-       list_for_each(tmp, &res->lr_granted) {
-               lock = list_entry(tmp, struct ldlm_lock,
-                                 l_res_link);
+       list_for_each_entry(lock, &res->lr_granted, l_res_link) {
                 if (ldlm_same_flock_owner(lock, req)) {
-                       ownlocks = tmp;
+                       ownlocks = lock;
                         break;
                 }
         }

-       /* Scan the locks owned by this process that overlap this request.
+       /* Scan the locks owned by this process to find the insertion point
+        * (as locks are ordered), and to handle overlaps.
          * We may have to merge or split existing locks.
          */
-       if (!ownlocks)
-               ownlocks = &res->lr_granted;
-
-       list_for_remaining_safe(ownlocks, tmp, &res->lr_granted) {
-               lock = list_entry(ownlocks, struct ldlm_lock, l_res_link);
+       if (ownlocks)
+               lock = ownlocks;
+       else
+               lock = list_entry(&res->lr_granted,
+                                 struct ldlm_lock, l_res_link);
+       list_for_each_entry_safe_from(lock, tmp, &res->lr_granted, l_res_link) {

                 if (!ldlm_same_flock_owner(lock, new))
                         break;
@@ -295,7 +284,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
                                                  lock->l_granted_mode);

                 /* insert new2 at lock */
-               ldlm_resource_add_lock(res, ownlocks, new2);
+               ldlm_resource_add_lock(res, &lock->l_res_link, new2);
                 LDLM_LOCK_RELEASE(new2);
                 break;
         }
@@ -309,8 +298,12 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)

         if (!added) {
                 list_del_init(&req->l_res_link);
-               /* insert new lock before ownlocks in list. */
-               ldlm_resource_add_lock(res, ownlocks, req);
+               /* insert new lock before "lock", which might be
+                * the next lock for this owner, or might be the first
+                * lock for the next owner, order might not be a lock
+                * at all, but instead points at the head of the list
+                */
+               ldlm_resource_add_lock(res, &lock->l_res_link, req);
         }

         /* In case we're reprocessing the requested lock we can't destroy


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170719/087655cb/attachment-0001.htm>
