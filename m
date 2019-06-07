From: Shaun Tancheff <shaun@tancheff.com>
Date: Thu, 6 Jun 2019 22:54:19 -0500
Subject: [lustre-devel] [PATCH] Place a memory barrier around cp_state
 changes
In-Reply-To: <87wohyw6ug.fsf@notabene.neil.brown.name>
References: <20190606223110.15725-1-stancheff@cray.com>
 <87wohyw6ug.fsf@notabene.neil.brown.name>
Message-ID: <CAJ48U8VMUh-SbFB+jeo3BfQaPaWTd+93Ro9dH64Zr3TD2vvPBw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 6, 2019 at 7:57 PM NeilBrown <neilb@suse.com> wrote:
>
> On Thu, Jun 06 2019, Shaun Tancheff wrote:
>
> > Ensure all uses of cl_page->cp_state are smp-safe.
> >
> > LBUG Output:
> > In __cl_page_state_set()
> > ..
> >   old = page->cp_state;
> >   PASSERT(env, page, allowed_transitions[old][state]);
> > ..
> > Asserted with the following:
> >   page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e2 8cc0]
>
> What do all these fields mean?  Or where is this printed?
> The closest I can find is in cl_page_header_print() which uses the
> format string:
>
>                    "page@%p[%d %p %d %d %p]\n",
>
> But that only has 5 fields in the [], while the output you provided has
> 6.
>

Sorry for the confusion, here is my (long) explanation with source snippets:

The LBUG in full

LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e28cc0]
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
vvp-page at ffff80be1fcd6650(0:0) vm at ffff7e02fa0e60c0 5000000000001029 4:0
ffff80be1fcd6600 1049548 lru
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
lov-page at ffff80be1fcd6690, comp index: 0, gen: 0
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
osc-page at ffff80be1fcd66c8 1049548: 1< 0x845fed 2 0 - - > 2< 4298948608 0
4096 0x0 0x420 |           (null) ffff809e473708e8 ffff80be199c1e40 > 3< 0
0 0 > 4< 5 13 64 0 + | - - - - > 5< - - - - | 0 - | 0 - ->
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0()) end
page at ffff80be1fcd6600
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
allowed_transitions[old][state]
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0()) ASSERTION( 0 )
failed:
LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0()) LBUG

The source snippet around L342
...
   339
   340          ENTRY;
   341          old = page->cp_state;
   342          PASSERT(env, page, allowed_transitions[old][state]);
   343          CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old,
state);
   344          PASSERT(env, page, page->cp_state == old);
   345          PASSERT(env, page, equi(state == CPS_OWNED, page->cp_owner
!= NULL));
   346
   347          cs_pagestate_dec(page->cp_obj, page->cp_state);
   348          cs_pagestate_inc(page->cp_obj, state);

The PASSERT macro ...
...
# define PASSERT(env, page, expr)                                       \
  do {                                                                    \
          if (unlikely(!(expr))) {                                      \
                  CL_PAGE_DEBUG(D_ERROR, (env), (page), #expr "\n");    \
                  LASSERT(0);                                           \
          }                                                             \
  } while (0)
#else /* !LIBCFS_DEBUG */
...

/**
 * Helper macro, dumping detailed information about \a page into a log.
 */
#define CL_PAGE_DEBUG(mask, env, page, format, ...)                     \
do {                                                                    \
        if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {                   \
                LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);        \
                cl_page_print(env, &msgdata, lu_cdebug_printer, page);  \
                CDEBUG(mask, format , ## __VA_ARGS__);                  \
        }                                                               \
} while (0)

Almost there
...
  1062  /**
  1063   * Prints human readable representation of \a pg to the \a f.
  1064   */
  1065  void cl_page_print(const struct lu_env *env, void *cookie,
  1066                     lu_printer_t printer, const struct cl_page *pg)
  1067  {
  1068          const struct cl_page_slice *slice;
  1069          int result = 0;
  1070
  1071          cl_page_header_print(env, cookie, printer, pg);
  1072          list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
  1073                  if (slice->cpl_ops->cpo_print != NULL)
  1074                          result = (*slice->cpl_ops->cpo_print)(env,
slice,
  1075
cookie, printer);

Finally the 'good stuff'
...
  1051  void cl_page_header_print(const struct lu_env *env, void *cookie,
  1052                            lu_printer_t printer, const struct
cl_page *pg)
  1053  {
  1054          (*printer)(env, cookie,
  1055                     "page@%p[%d %p %d %d %p]\n",
  1056                     pg, atomic_read(&pg->cp_ref), pg->cp_obj,
  1057                     pg->cp_state, pg->cp_type,
  1058                     pg->cp_owner);
  1059  }
...

Given the above along with the first line from the LBUG ....

LustreError: 86407:0:(cl_page.c:342:cl_page_state_set0())
page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e28cc0]

Implies the following:

pg == ffff80be1fcd6600
pg->cp_ref == 3
pg->cp_obj == ffff80be1fca5cc0
pg->cp_state == 0 (state == CPS_CACHED)
pg->cp_type == 1
pg->cp_owner == ffff809e60e28cc0

Also known caller was cl_page_assume+0xdc/0x3e0 [obdclass] (from the
backtrace)
So we know the on-stack / register value of state == CPS_OWNED

The backtrace:
...
 dump_backtrace+0x0/0x248
 show_stack+0x24/0x30
 dump_stack+0xbc/0xf4
 libcfs_call_trace+0xec/0x120 [libcfs]
 lbug_with_loc+0x4c/0xb8 [libcfs]
 cl_page_state_set0+0x2b4/0x6e0 [obdclass]
 cl_page_assume+0xdc/0x3e0 [obdclass]
 ll_io_read_page+0x144c/0x1de0 [lustre]
 ll_write_begin+0x3d4/0xee8 [lustre]

and the contents of cl_page_assume

   596  void cl_page_assume(const struct lu_env *env,
   597                      struct cl_io *io, struct cl_page *pg)
   598  {
   599          const struct cl_page_slice *slice;
   600
   601          PINVRNT(env, pg, cl_object_same(pg->cp_obj, io->ci_obj));
   602
   603          ENTRY;
   604          io = cl_io_top(io);
   605
   606          list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
   607                  if (slice->cpl_ops->cpo_assume != NULL)
   608                          (*slice->cpl_ops->cpo_assume)(env, slice,
io);
   609          }
   610
   611          PASSERT(env, pg, pg->cp_owner == NULL);
   612          pg->cp_owner = cl_io_top(io);
   613          cl_page_owner_set(pg);
   614          cl_page_state_set(env, pg, CPS_OWNED);
   615          EXIT;
   616  }

While I believe my conclusion to be correct I am certainly open to being
dead wrong.



On Thu, Jun 6, 2019 at 7:57 PM NeilBrown <neilb@suse.com> wrote:

> On Thu, Jun 06 2019, Shaun Tancheff wrote:
>
> > Ensure all uses of cl_page->cp_state are smp-safe.
> >
> > LBUG Output:
> > In __cl_page_state_set()
> > ..
> >   old = page->cp_state;
> >   PASSERT(env, page, allowed_transitions[old][state]);
> > ..
> > Asserted with the following:
> >   page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e2 8cc0]
>
> What do all these fields mean?  Or where is this printed?
> The closest I can find is in cl_page_header_print() which uses the
> format string:
>
>                    "page@%p[%d %p %d %d %p]\n",
>
> But that only has 5 fields in the [], while the output you provided has
> 6.
>
> >
> > However cp_state 0 (CPS_CACHED) to 1 (CPS_OWNED) is a valid transition
> > leading to the conclusion that cp_state became 0 during the
> > assertion.
>
> Where is the evidence that this was the transition that was happening?
> If it was in some part of the LBUG output that wasn't quoted - then
> please fix that by quoting the entire LBUG output.
>
> We need to understand which change happened at this time to cause the
> race.
> Then we need to explain why the added barriers actually close the race
> window.
>
> If these barrier do actually fix a race, then there is something *very*
> wrong.
> The comments say that changes to cp_state are protected by the page lock
> on the corresponding VM page.
> Locking and unlocking a VM page entails sufficient barriers that changes
> made while one thread holds the lock will be visible to another
> thread once it also gets the lock.
>
>
True, but a page lock is just a bit on the page flags. And we absolutely
wait on I/O while the
page is 'locked' so a ping-pong (our task *can* sleep) is entirely
reasonable, as far as
I understand anyway. Since there is multiple state-changes during a single
page lock/unlock
there is a race, however rare and unlikely, and it's arch specific based on
what I understand
of the memory barrier rules.

So the only possible explanation for a race as you suspect, is if the
> vmpage *isn't* locked when something changes cp_state, and that would be
> bad.
>
> Thanks,
> NeilBrown
>
>
> >
> > Signed-off-by: Shaun Tancheff <stancheff@cray.com>
> > ---
> >  fs/lustre/include/cl_object.h   | 11 +++++++++++
> >  fs/lustre/llite/rw26.c          |  2 +-
> >  fs/lustre/llite/vvp_page.c      |  6 +++---
> >  fs/lustre/obdclass/cl_page.c    | 34 +++++++++++++++++++--------------
> >  fs/lustre/obdecho/echo_client.c |  2 +-
> >  fs/lustre/osc/osc_cache.c       | 18 +++++++++--------
> >  6 files changed, 46 insertions(+), 27 deletions(-)
> >
> > diff --git a/fs/lustre/include/cl_object.h
> b/fs/lustre/include/cl_object.h
> > index 691c2f5da53a..d6e1f6f05f50 100644
> > --- a/fs/lustre/include/cl_object.h
> > +++ b/fs/lustre/include/cl_object.h
> > @@ -752,6 +752,17 @@ struct cl_page {
> >       struct cl_sync_io               *cp_sync_io;
> >  };
> >
> > +static inline enum cl_page_state cl_page_state_get(const struct cl_page
> *pg)
> > +{
> > +     /*
> > +      * Paired with smp_store_release in cl_page_state_set_trust
> > +      * and ensures that we see the most recent value of cp_state
> > +      * even when the last modification was not performed on the
> > +      * current processor
> > +      */
> > +     return smp_load_acquire(&pg->cp_state);
> > +}
> > +
> >  /**
> >   * Per-layer part of cl_page.
> >   *
> > diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
> > index e4ce3b6f5772..364dec208ccd 100644
> > --- a/fs/lustre/llite/rw26.c
> > +++ b/fs/lustre/llite/rw26.c
> > @@ -200,7 +200,7 @@ static ssize_t ll_direct_IO_seg(const struct lu_env
> *env, struct cl_io *io,
> >
> >               rc = cl_page_own(env, io, clp);
> >               if (rc) {
> > -                     LASSERT(clp->cp_state == CPS_FREEING);
> > +                     LASSERT(cl_page_state_get(clp) == CPS_FREEING);
> >                       cl_page_put(env, clp);
> >                       break;
> >               }
> > diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
> > index 590e5f5e43c9..38b8c488d765 100644
> > --- a/fs/lustre/llite/vvp_page.c
> > +++ b/fs/lustre/llite/vvp_page.c
> > @@ -323,18 +323,18 @@ static int vvp_page_make_ready(const struct lu_env
> *env,
> >
> >       lock_page(vmpage);
> >       if (clear_page_dirty_for_io(vmpage)) {
> > -             LASSERT(pg->cp_state == CPS_CACHED);
> > +             LASSERT(cl_page_state_get(pg) == CPS_CACHED);
> >               /* This actually clears the dirty bit in the radix tree. */
> >               set_page_writeback(vmpage);
> >               CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
> > -     } else if (pg->cp_state == CPS_PAGEOUT) {
> > +     } else if (cl_page_state_get(pg) == CPS_PAGEOUT) {
> >               /* is it possible for osc_flush_async_page() to already
> >                * make it ready?
> >                */
> >               result = -EALREADY;
> >       } else {
> >               CL_PAGE_DEBUG(D_ERROR, env, pg, "Unexpecting page state
> %d.\n",
> > -                           pg->cp_state);
> > +                           cl_page_state_get(pg));
> >               LBUG();
> >       }
> >       unlock_page(vmpage);
> > diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
> > index 349f19e014e0..da4429b82932 100644
> > --- a/fs/lustre/obdclass/cl_page.c
> > +++ b/fs/lustre/obdclass/cl_page.c
> > @@ -97,7 +97,7 @@ static void cl_page_free(const struct lu_env *env,
> struct cl_page *page)
> >
> >       PASSERT(env, page, list_empty(&page->cp_batch));
> >       PASSERT(env, page, !page->cp_owner);
> > -     PASSERT(env, page, page->cp_state == CPS_FREEING);
> > +     PASSERT(env, page, cl_page_state_get(page) == CPS_FREEING);
> >
> >       while ((slice = list_first_entry_or_null(&page->cp_layers,
> >                                                struct cl_page_slice,
> > @@ -119,8 +119,14 @@ static void cl_page_free(const struct lu_env *env,
> struct cl_page *page)
> >  static inline void cl_page_state_set_trust(struct cl_page *page,
> >                                          enum cl_page_state state)
> >  {
> > -     /* bypass const. */
> > -     *(enum cl_page_state *)&page->cp_state = state;
> > +     /*
> > +      * Paired with smp_load_acquire in cl_page_state_get
> > +      * and ensures that we see the most recent value of cp_state
> > +      * is available even when the next access is not performed on the
> > +      * current processor.
> > +      * Note we also cast away const as the only modifier of cp_state.
> > +      */
> > +     smp_store_release((enum cl_page_state *)&page->cp_state, state);
> >  }
> >
> >  struct cl_page *cl_page_alloc(const struct lu_env *env,
> > @@ -270,10 +276,10 @@ static void __cl_page_state_set(const struct
> lu_env *env,
> >               }
> >       };
> >
> > -     old = page->cp_state;
> > +     old = cl_page_state_get(page);
> >       PASSERT(env, page, allowed_transitions[old][state]);
> >       CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old, state);
> > -     PASSERT(env, page, page->cp_state == old);
> > +     PASSERT(env, page, cl_page_state_get(page) == old);
> >       PASSERT(env, page, equi(state == CPS_OWNED, page->cp_owner));
> >       cl_page_state_set_trust(page, state);
> >  }
> > @@ -313,7 +319,7 @@ void cl_page_put(const struct lu_env *env, struct
> cl_page *page)
> >                      refcount_read(&page->cp_ref));
> >
> >       if (refcount_dec_and_test(&page->cp_ref)) {
> > -             LASSERT(page->cp_state == CPS_FREEING);
> > +             LASSERT(cl_page_state_get(page) == CPS_FREEING);
> >
> >               LASSERT(refcount_read(&page->cp_ref) == 0);
> >               PASSERT(env, page, !page->cp_owner);
> > @@ -378,7 +384,7 @@ void __cl_page_disown(const struct lu_env *env,
> >       const struct cl_page_slice *slice;
> >       enum cl_page_state state;
> >
> > -     state = pg->cp_state;
> > +     state = cl_page_state_get(pg);
> >       cl_page_owner_clear(pg);
> >
> >       if (state == CPS_OWNED)
> > @@ -402,7 +408,7 @@ int cl_page_is_owned(const struct cl_page *pg, const
> struct cl_io *io)
> >       struct cl_io *top = cl_io_top((struct cl_io *)io);
> >
> >       LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
> > -     return pg->cp_state == CPS_OWNED && pg->cp_owner == top;
> > +     return cl_page_state_get(pg) == CPS_OWNED && pg->cp_owner == top;
> >  }
> >  EXPORT_SYMBOL(cl_page_is_owned);
> >
> > @@ -434,7 +440,7 @@ static int __cl_page_own(const struct lu_env *env,
> struct cl_io *io,
> >
> >       io = cl_io_top(io);
> >
> > -     if (pg->cp_state == CPS_FREEING) {
> > +     if (cl_page_state_get(pg) == CPS_FREEING) {
> >               result = -ENOENT;
> >               goto out;
> >       }
> > @@ -453,7 +459,7 @@ static int __cl_page_own(const struct lu_env *env,
> struct cl_io *io,
> >               PASSERT(env, pg, !pg->cp_owner);
> >               pg->cp_owner = cl_io_top(io);
> >               cl_page_owner_set(pg);
> > -             if (pg->cp_state != CPS_FREEING) {
> > +             if (cl_page_state_get(pg) != CPS_FREEING) {
> >                       cl_page_state_set(env, pg, CPS_OWNED);
> >               } else {
> >                       __cl_page_disown(env, io, pg);
> > @@ -593,7 +599,7 @@ static void __cl_page_delete(const struct lu_env
> *env, struct cl_page *pg)
> >  {
> >       const struct cl_page_slice *slice;
> >
> > -     PASSERT(env, pg, pg->cp_state != CPS_FREEING);
> > +     PASSERT(env, pg, cl_page_state_get(pg) != CPS_FREEING);
> >
> >       /*
> >        * Sever all ways to obtain new pointers to @pg.
> > @@ -756,7 +762,7 @@ void cl_page_completion(const struct lu_env *env,
> >       const struct cl_page_slice *slice;
> >
> >       PASSERT(env, pg, crt < CRT_NR);
> > -     PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
> > +     PASSERT(env, pg, cl_page_state_get(pg) == cl_req_type_state(crt));
> >
> >       CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
> >
> > @@ -805,7 +811,7 @@ int cl_page_make_ready(const struct lu_env *env,
> struct cl_page *pg,
> >       }
> >
> >       if (result >= 0) {
> > -             PASSERT(env, pg, pg->cp_state == CPS_CACHED);
> > +             PASSERT(env, pg, cl_page_state_get(pg) == CPS_CACHED);
> >               cl_page_io_start(env, pg, crt);
> >               result = 0;
> >       }
> > @@ -870,7 +876,7 @@ void cl_page_header_print(const struct lu_env *env,
> void *cookie,
> >       (*printer)(env, cookie,
> >                  "page@%p[%d %p %d %d %p]\n",
> >                  pg, refcount_read(&pg->cp_ref), pg->cp_obj,
> > -                pg->cp_state, pg->cp_type,
> > +                cl_page_state_get(pg), pg->cp_type,
> >                  pg->cp_owner);
> >  }
> >  EXPORT_SYMBOL(cl_page_header_print);
> > diff --git a/fs/lustre/obdecho/echo_client.c
> b/fs/lustre/obdecho/echo_client.c
> > index 317123fd27cb..d879f109e641 100644
> > --- a/fs/lustre/obdecho/echo_client.c
> > +++ b/fs/lustre/obdecho/echo_client.c
> > @@ -1046,7 +1046,7 @@ static int cl_echo_object_brw(struct echo_object
> *eco, int rw, u64 offset,
> >
> >               rc = cl_page_own(env, io, clp);
> >               if (rc) {
> > -                     LASSERT(clp->cp_state == CPS_FREEING);
> > +                     LASSERT(cl_page_state_get(clp) == CPS_FREEING);
> >                       cl_page_put(env, clp);
> >                       break;
> >               }
> > diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
> > index f8fddbfe6a7e..75984b98b229 100644
> > --- a/fs/lustre/osc/osc_cache.c
> > +++ b/fs/lustre/osc/osc_cache.c
> > @@ -1045,7 +1045,7 @@ static int osc_extent_truncate(struct osc_extent
> *ext, pgoff_t trunc_index,
> >                       cl_page_discard(env, io, page);
> >                       cl_page_disown(env, io, page);
> >               } else {
> > -                     LASSERT(page->cp_state == CPS_FREEING);
> > +                     LASSERT(cl_page_state_get(page) == CPS_FREEING);
> >                       LASSERT(0);
> >               }
> >
> > @@ -1356,10 +1356,12 @@ static int osc_completion(const struct lu_env
> *env, struct osc_async_page *oap,
> >       int srvlock;
> >
> >       cmd &= ~OBD_BRW_NOQUOTA;
> > -     LASSERTF(equi(page->cp_state == CPS_PAGEIN, cmd == OBD_BRW_READ),
> > -              "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
> > -     LASSERTF(equi(page->cp_state == CPS_PAGEOUT, cmd == OBD_BRW_WRITE),
> > -              "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
> > +     LASSERTF(equi(cl_page_state_get(page) == CPS_PAGEIN,
> > +                   cmd == OBD_BRW_READ),
> > +              "cp_state:%u, cmd:%d\n", cl_page_state_get(page), cmd);
> > +     LASSERTF(equi(cl_page_state_get(page) == CPS_PAGEOUT,
> > +                   cmd == OBD_BRW_WRITE),
> > +              "cp_state:%u, cmd:%d\n", cl_page_state_get(page), cmd);
> >       LASSERT(opg->ops_transfer_pinned);
> >
> >       crt = cmd == OBD_BRW_READ ? CRT_READ : CRT_WRITE;
> > @@ -3061,7 +3063,7 @@ bool osc_page_gang_lookup(const struct lu_env
> *env, struct cl_io *io,
> >
> >                       page = ops->ops_cl.cpl_page;
> >                       LASSERT(page->cp_type == CPT_CACHEABLE);
> > -                     if (page->cp_state == CPS_FREEING)
> > +                     if (cl_page_state_get(page) == CPS_FREEING)
> >                               continue;
> >
> >                       cl_page_get(page);
> > @@ -3142,7 +3144,7 @@ static bool check_and_discard_cb(const struct
> lu_env *env, struct cl_io *io,
> >                       cl_page_discard(env, io, page);
> >                       cl_page_disown(env, io, page);
> >               } else {
> > -                     LASSERT(page->cp_state == CPS_FREEING);
> > +                     LASSERT(cl_page_state_get(page) == CPS_FREEING);
> >               }
> >       }
> >
> > @@ -3169,7 +3171,7 @@ static bool discard_cb(const struct lu_env *env,
> struct cl_io *io,
> >               cl_page_discard(env, io, page);
> >               cl_page_disown(env, io, page);
> >       } else {
> > -             LASSERT(page->cp_state == CPS_FREEING);
> > +             LASSERT(cl_page_state_get(page) == CPS_FREEING);
> >       }
> >
> >       return true;
> > --
> > 2.17.1
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190606/6bdc81e1/attachment-0001.html>
