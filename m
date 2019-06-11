From: Shaun Tancheff <shaun@tancheff.com>
Date: Mon, 10 Jun 2019 23:05:33 -0500
Subject: [lustre-devel] [PATCH] Place a memory barrier around cp_state
 changes
In-Reply-To: <87o935vtde.fsf@notabene.neil.brown.name>
References: <20190606223110.15725-1-stancheff@cray.com>
 <87wohyw6ug.fsf@notabene.neil.brown.name>
 <CAJ48U8VMUh-SbFB+jeo3BfQaPaWTd+93Ro9dH64Zr3TD2vvPBw@mail.gmail.com>
 <87o935vtde.fsf@notabene.neil.brown.name>
Message-ID: <CAJ48U8XVeC4H4+jKZV_+5Rg-iWEPX5Qqs=0KHs9n0d7WwXb_EA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 10, 2019 at 7:49 PM NeilBrown <neilb@suse.com> wrote:

> On Thu, Jun 06 2019, Shaun Tancheff wrote:
>
> > On Thu, Jun 6, 2019 at 7:57 PM NeilBrown <neilb@suse.com> wrote:
> >>
> >> On Thu, Jun 06 2019, Shaun Tancheff wrote:
> >>
> >> > Ensure all uses of cl_page->cp_state are smp-safe.
> >> >
> >> > LBUG Output:
> >> > In __cl_page_state_set()
> >> > ..
> >> >   old = page->cp_state;
> >> >   PASSERT(env, page, allowed_transitions[old][state]);
> >> > ..
> >> > Asserted with the following:
> >> >   page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e2 8cc0]
>
> I now see that this space.....                                 ^^^
> shouldn't be there..
> .....
>
> > Also known caller was cl_page_assume+0xdc/0x3e0 [obdclass] (from the
> > backtrace)
> > So we know the on-stack / register value of state == CPS_OWNED
> >
> > The backtrace:
> > ...
> >  dump_backtrace+0x0/0x248
> >  show_stack+0x24/0x30
> >  dump_stack+0xbc/0xf4
> >  libcfs_call_trace+0xec/0x120 [libcfs]
> >  lbug_with_loc+0x4c/0xb8 [libcfs]
> >  cl_page_state_set0+0x2b4/0x6e0 [obdclass]
> >  cl_page_assume+0xdc/0x3e0 [obdclass]
> >  ll_io_read_page+0x144c/0x1de0 [lustre]
> >  ll_write_begin+0x3d4/0xee8 [lustre]
>
> Thanks for this extra detail.
> I agree that the evidence suggests that page->cp_state changed (to
> CPS_CACHED) during the processing of the PASSERT().
>
> It isn't clear to me though that this problem can be fixed just by
> adding barriers  - particularly if this was on x86_64 as I suspect it
> is.  Intel architecture processors have strongly ordered memory
> semantics.  I'm not entirely sure what that means, but as
> smp_load_acquire() is very nearly a no-op on x86, I doubt that the
> memory barriers you added actually fix anything there.
>

Agree. This occurred on aarch64. I suspect one of the reasons that this has
not
been seen is that the majority of users are x86_64. It appears to be very
rare on
aarch64 but it could also, theoretically, happen on the other relaxed
architectures.


> My understanding (based on a fairly shallow reading of the code) is that
> a partial-page write is being attempted, and the target page was not in
> memory, so it was read in synchronously.
> The fragment of ll_io_read_page happening is:
>
>         if (anchor != NULL && !cl_page_is_owned(page, io)) { /* have sent
> */
>                 rc = cl_sync_io_wait(env, anchor, 0);
>
>                 cl_page_assume(env, io, page);
>
> So cl_sync_io_wait() has just run.  The page was (presumably) previously
> owned by something else.  cl_sync_io_wait() waited for csi_sync_nr
> to drop to zero, which should say it isn't owned any more.
> cl_page_assume() then takes ownership.
> But it seems that the old ownership wasn't quite gone yet.
>
> The VM page remains locked the whole time, so the barriers implicit in
> locking and unlocking a page do not some into play here.
> There is an implicit barrier on the 'store' side when cl_sync_io_note()
> calls atomic_dec_and_test() to decrement csi_sync_nr, but I cannot see
> any implicit barrier on the 'load' side.  If l_wait_event() in
> cl_sync_io_wait() took a spinlock, that would be enough.  But it is
> possible for the wait to complete without any locking.
>
> So I can just about see the possibility of the race that you think you
> have hit.  But it couldn't happen on x86, as it has strong memory
> ordering.
>
> What CPU architecture did this ASSERT trigger on?
>

Agree with everything above, unfortunately was aarch64.


> Thanks,
> NeilBrown
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190610/b613803d/attachment.html>
