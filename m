From: NeilBrown <neilb@suse.com>
Date: Fri, 11 Jan 2019 12:11:24 +1100
Subject: [lustre-devel] [PATCH 26/29] lustre: osc_cache: simplify
 osc_page_gang_lookup()
In-Reply-To: <AECE9036-4F2A-4330-A8AD-3105A3D4014C@whamcloud.com>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504269.26726.8061168646539306509.stgit@noble>
 <AECE9036-4F2A-4330-A8AD-3105A3D4014C@whamcloud.com>
Message-ID: <87a7k8gfr7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 10 2019, Andreas Dilger wrote:

> On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
>> 
>> osc_page_gang_lookup() has 4 values that it can receive from a
>> callback, and that it can return to the caller:
>> 	CLP_GANG_OKAY,
>> 	CLP_GANG_RESCHED,
>> 	CLP_GANG_AGAIN,
>> 	CLP_GANG_ABORT
>> 
>> "AGAIN" is never used.
>> "RESCHED" is not needed as a cond_resched() can safely be called at
>> the point this is returned, rather than returning it.
>> That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
>> boolean values.
>> 
>> Internalizing the RESCHED case means the callers don't need to loop
>> themselves.  This simplify calling patterns.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> drivers/staging/lustre/lustre/include/cl_object.h  |    7 ----
>> drivers/staging/lustre/lustre/osc/osc_cache.c      |   40 ++++++++------------
>> .../staging/lustre/lustre/osc/osc_cl_internal.h    |   10 +++--
>> drivers/staging/lustre/lustre/osc/osc_io.c         |    4 +-
>> drivers/staging/lustre/lustre/osc/osc_lock.c       |   27 ++++++--------
>> 5 files changed, 33 insertions(+), 55 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> index 79bcaa212339..e01f3815978c 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> @@ -3069,10 +3065,10 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
>> 		if (nr < OTI_PVEC_SIZE || end_of_region)
>> 			break;
>> 
>> -		if (res == CLP_GANG_OKAY && need_resched())
>> -			res = CLP_GANG_RESCHED;
>> -		if (res != CLP_GANG_OKAY)
>> +		if (!res)
>> 			break;
>> +		if (need_resched())
>> +			cond_resched();
>> 
>> 		spin_lock(&osc->oo_tree_lock);
>> 		tree_lock = true;
>
> The one thing I notice here is that if the CLP_GANG_RESCHED is not
> returned to the caller, it doesn't have the chance to finish the
> work before it is rescheduled:
>
>         do {
>                 res = osc_page_gang_lookup(env, io, osc,
>                                    info->oti_next_index, end, cb, osc);
>                 if (info->oti_next_index > end)
>                         break;
>
>                 if (res == CLP_GANG_RESCHED)
>                         cond_resched();
>         } while (res != CLP_GANG_OKAY);
>
> That means if the thread did a lot of work in osc_page_gang_lookup()
> but is otherwise finished, it will block at the internal cond_resched()
> rather than detecting it is finishing and returning to the caller without
> any reschedule at all.
>
> However, looking into the osc_page_gang_lookup() code more closely, I
> see "end_of_region" would already be set in this case (it is just at
> the start of the context in the above patch hunk) so CLP_GANG_RESCHED
> should never be set in that case.  So it looks OK.

Oh good :-)
Thanks.
I love when a review includes what you saw as well as the "Reviewed-by".

>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
>> index 4cc813d192d9..1eab61d720e2 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_lock.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
>> @@ -630,18 +630,18 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
>> 	return result;
>> }
>> 
>> -static int weigh_cb(const struct lu_env *env, struct cl_io *io,
>> -		    struct osc_page *ops, void *cbdata)
>> +static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
>> +		     struct osc_page *ops, void *cbdata)
>> {
>> 	struct cl_page *page = ops->ops_cl.cpl_page;
>> 
>> 	if (cl_page_is_vmlocked(env, page) ||
>> 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
>> 	   )
>
> This is a bit oddly formatted.  I see in our tree it looks like:
>
>         if (cl_page_is_vmlocked(env, page) || PageDirty(page->cp_vmpage) ||
>             PageWriteback(page->cp_vmpage))
>
> which is more normal.

It has only been this way in OpenSFS since July this year.

Commit b44b1ff8c7fc ("LU-10961 ldlm: don't cancel DoM locks before replay")
made the change without any comment.  I guess we aren't up to that 2.11
yet :-)



>
>> @@ -660,19 +660,14 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
>> 		return result;
>> 
>> 	page_index = cl_index(obj, extent->start);
>> +
>> +	result = osc_page_gang_lookup(env, io, oscobj,
>> +				      page_index,
>> +				      cl_index(obj, extent->end),
>> +				      weigh_cb, (void *)&page_index);
>> 	cl_io_fini(env, io);
>> 
>> -	return result == CLP_GANG_ABORT ? 1 : 0;
>> +	return result ? 1 : 0;
>> }
>
> Per your commit comment above:
>
>> That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
>> boolean values.
>
> So if "ABORT" is now "false", this should be:
>
> 	return !result;
>
> otherwise your return code logic is backward?

Good catch, thanks.
That isn't the only problem there.  "result" - which I change to a bool
- also holds the return value for cl_io_init().  I'm not sur what sort
of value that is, but I don't think I should be changing the type.
So I changed 'result' back to an int and handled failure differently.
I also removed the 'res' variable from osc_Lock_discard_pages(), as it
is now unused.

New version below.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] lustre: osc_cache: simplify osc_page_gang_lookup()

osc_page_gang_lookup() has 4 values that it can receive from a
callback, and that it can return to the caller:
	CLP_GANG_OKAY,
	CLP_GANG_RESCHED,
	CLP_GANG_AGAIN,
	CLP_GANG_ABORT

"AGAIN" is never used.
"RESCHED" is not needed as a cond_resched() can safely be called at
the point this is returned, rather than returning it.
That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
boolean values.

Internalizing the RESCHED case means the callers don't need to loop
themselves.  This simplify calling patterns.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  7 ----
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 39 ++++++++--------------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    | 10 +++---
 drivers/staging/lustre/lustre/osc/osc_io.c         |  4 +--
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 26 ++++++---------
 5 files changed, 32 insertions(+), 54 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 603281567219..41b32b7db515 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2084,14 +2084,7 @@ static inline int cl_object_refc(struct cl_object *clob)
 /** \defgroup cl_page cl_page
  * @{
  */
-enum {
-	CLP_GANG_OKAY = 0,
-	CLP_GANG_RESCHED,
-	CLP_GANG_AGAIN,
-	CLP_GANG_ABORT
-};
 
-/* callback of cl_page_gang_lookup() */
 struct cl_page *cl_page_find(const struct lu_env *env, struct cl_object *obj,
 			     pgoff_t idx, struct page *vmpage,
 			     enum cl_page_type type);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 29fe8ef11af1..de3250a2d1ec 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2989,18 +2989,14 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 /**
  * Returns a list of pages by a given [start, end] of \a obj.
  *
- * \param resched If not NULL, then we give up before hogging CPU for too
- * long and set *resched = 1, in that case caller should implement a retry
- * logic.
- *
  * Gang tree lookup (radix_tree_gang_lookup()) optimization is absolutely
  * crucial in the face of [offset, EOF] locks.
  *
  * Return at least one page in @queue unless there is no covered page.
  */
-int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
-			 struct osc_object *osc, pgoff_t start, pgoff_t end,
-			 osc_page_gang_cbt cb, void *cbdata)
+bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			  struct osc_object *osc, pgoff_t start, pgoff_t end,
+			  osc_page_gang_cbt cb, void *cbdata)
 {
 	struct osc_page *ops;
 	void            **pvec;
@@ -3008,7 +3004,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 	unsigned int    nr;
 	unsigned int    i;
 	unsigned int    j;
-	int             res = CLP_GANG_OKAY;
+	bool            res = true;
 	bool            tree_lock = true;
 
 	idx = start;
@@ -3054,7 +3050,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 		for (i = 0; i < j; ++i) {
 			ops = pvec[i];
-			if (res == CLP_GANG_OKAY)
+			if (res)
 				res = (*cb)(env, io, ops, cbdata);
 
 			page = ops->ops_cl.cpl_page;
@@ -3064,10 +3060,10 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 		if (nr < OTI_PVEC_SIZE || end_of_region)
 			break;
 
-		if (res == CLP_GANG_OKAY && need_resched())
-			res = CLP_GANG_RESCHED;
-		if (res != CLP_GANG_OKAY)
+		if (!res)
 			break;
+		if (need_resched())
+			cond_resched();
 
 		spin_lock(&osc->oo_tree_lock);
 		tree_lock = true;
@@ -3080,7 +3076,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 /**
  * Check if page @page is covered by an extra lock or discard it.
  */
-static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
+static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 				struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
@@ -3116,10 +3112,10 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 	}
 
 	info->oti_next_index = index + 1;
-	return CLP_GANG_OKAY;
+	return true;
 }
 
-static int discard_cb(const struct lu_env *env, struct cl_io *io,
+static bool discard_cb(const struct lu_env *env, struct cl_io *io,
 		      struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
@@ -3140,7 +3136,7 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 		LASSERT(page->cp_state == CPS_FREEING);
 	}
 
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 /**
@@ -3157,7 +3153,6 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_io *io = &info->oti_io;
 	osc_page_gang_cbt cb;
-	int res;
 	int result;
 
 	io->ci_obj = cl_object_top(osc2cl(osc));
@@ -3169,15 +3164,9 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	cb = discard ? discard_cb : check_and_discard_cb;
 	info->oti_fn_index = start;
 	info->oti_next_index = start;
-	do {
-		res = osc_page_gang_lookup(env, io, osc,
-					   info->oti_next_index, end, cb, osc);
-		if (info->oti_next_index > end)
-			break;
 
-		if (res == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (res != CLP_GANG_OKAY);
+	osc_page_gang_lookup(env, io, osc,
+			     info->oti_next_index, end, cb, osc);
 out:
 	cl_io_fini(env, io);
 	return result;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 3af096e0dbdd..c0f58f41513f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -660,11 +660,11 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
 int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 			   pgoff_t start, pgoff_t end, bool discard_pages);
 
-typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
-				 struct osc_page *, void *);
-int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
-			 struct osc_object *osc, pgoff_t start, pgoff_t end,
-			 osc_page_gang_cbt cb, void *cbdata);
+typedef bool (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
+				  struct osc_page *, void *);
+bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			  struct osc_object *osc, pgoff_t start, pgoff_t end,
+			  osc_page_gang_cbt cb, void *cbdata);
 /* @} osc */
 
 #endif /* OSC_CL_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 8cd0813fb4bf..0a7bfe2d4059 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -449,7 +449,7 @@ static int osc_async_upcall(void *a, int rc)
 /**
  * Checks that there are no pages being written in the extent being truncated.
  */
-static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
+static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 			  struct osc_page *ops, void *cbdata)
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
@@ -466,7 +466,7 @@ static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 		CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
 		       ops, osc_index(ops), oap->oap_cmd & OBD_BRW_RWMASK);
 
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 01b6bf7df3b7..1781243f1c66 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -630,18 +630,18 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	return result;
 }
 
-static int weigh_cb(const struct lu_env *env, struct cl_io *io,
-		    struct osc_page *ops, void *cbdata)
+static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
+		     struct osc_page *ops, void *cbdata)
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
 
 	if (cl_page_is_vmlocked(env, page) ||
 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
 	   )
-		return CLP_GANG_ABORT;
+		return false;
 
 	*(pgoff_t *)cbdata = osc_index(ops) + 1;
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 static unsigned long osc_lock_weight(const struct lu_env *env,
@@ -660,19 +660,15 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 		return result;
 
 	page_index = cl_index(obj, extent->start);
-	do {
-		result = osc_page_gang_lookup(env, io, oscobj,
-					      page_index,
-					      cl_index(obj, extent->end),
-					      weigh_cb, (void *)&page_index);
-		if (result == CLP_GANG_ABORT)
-			break;
-		if (result == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (result != CLP_GANG_OKAY);
+
+	if (!osc_page_gang_lookup(env, io, oscobj,
+				 page_index,
+				 cl_index(obj, extent->end),
+				 weigh_cb, (void *)&page_index))
+		result = 1;
 	cl_io_fini(env, io);
 
-	return result == CLP_GANG_ABORT ? 1 : 0;
+	return result;
 }
 
 /**
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190111/448025ea/attachment.sig>
