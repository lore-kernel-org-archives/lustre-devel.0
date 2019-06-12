From: Shaun Tancheff <shaun@tancheff.com>
Date: Wed, 12 Jun 2019 11:12:36 -0500
Subject: [lustre-devel] [PATCH] Place a memory barrier around cp_state
 changes
In-Reply-To: <DM6PR19MB25088C918BDC356FA4ABED9DC5EC0@DM6PR19MB2508.namprd19.prod.outlook.com>
References: <20190606223110.15725-1-stancheff@cray.com>
 <87wohyw6ug.fsf@notabene.neil.brown.name>
 <CAJ48U8VMUh-SbFB+jeo3BfQaPaWTd+93Ro9dH64Zr3TD2vvPBw@mail.gmail.com>
 <87o935vtde.fsf@notabene.neil.brown.name>
 <CAJ48U8XVeC4H4+jKZV_+5Rg-iWEPX5Qqs=0KHs9n0d7WwXb_EA@mail.gmail.com>
 <87wohrv41a.fsf@notabene.neil.brown.name>
 <CAJ48U8V6yivzv2MQFksG3W0MTT-yEt4DwPL3J0NWdJbV1gMcBw@mail.gmail.com>
 <DM6PR19MB25088C918BDC356FA4ABED9DC5EC0@DM6PR19MB2508.namprd19.prod.outlook.com>
Message-ID: <CAJ48U8WhRCU02F22R9ewCApAH8jzJQ_s-VsKBQdFe=Oo42UgZQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 12, 2019 at 8:04 AM Patrick Farrell <pfarrell@whamcloud.com>
wrote:

> As an interested observer (thanks to both of you for an interesting
> exchange), Shaun, what?s your plan going forward for the OpenSFS/WC
> branch?  It sounds like you?re thinking you?ll try to emulate what Neil did
> upstream? (which sounds good to me, I always prefer avoiding explicit
> memory barriers if reasonable)  Will you be opening an LU for this one?
>

Yes, I will be opening an LU for this. My plan is to emulate upstream.


> Thanks,
> - Patrick
> ------------------------------
> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Shaun Tancheff <shaun@tancheff.com>
> *Sent:* Tuesday, June 11, 2019 11:36:13 PM
> *To:* NeilBrown
> *Cc:* Bobi Jam; lustre-devel at lists.lustre.org
> *Subject:* Re: [lustre-devel] [PATCH] Place a memory barrier around
> cp_state changes
>
> On Tue, Jun 11, 2019 at 11:09 PM NeilBrown <neilb@suse.com> wrote:
>
> On Mon, Jun 10 2019, Shaun Tancheff wrote:
>
> > On Mon, Jun 10, 2019 at 7:49 PM NeilBrown <neilb@suse.com> wrote:
> >
> >>>
> >> So I can just about see the possibility of the race that you think you
> >> have hit.  But it couldn't happen on x86, as it has strong memory
> >> ordering.
> >>
> >> What CPU architecture did this ASSERT trigger on?
> >>
> >
> > Agree with everything above, unfortunately was aarch64.
>
> Ahh.
> OK, I'm now reasonably convinced that the patch probably fixes the bug.
> It is a shame that there is no standard barrier between the wake_up and
> the wait_event(), but there isn't and we need to work with that.
>
> But I still don't like the patch.... :-(
>
> I have a few problems with it.
>
> Firstly, I generally don't like accessor functions.  They tend to hide
> useful information.
> Rather than cl_page_state_get() I would rather have
>          smp_load_acquire(&pg->cp_state)
>
> where ever it is needed, with a comment explaining why it is needed in
> that particular context.
> Some people seem to like accessor functions - there certainly are a lot
> of them in the kernel - but I don't think they help.
> Having an accessor function that just adds a barrier is, I think,
> particularly ugly as the comment can only be general in nature, and so
> doesn't really help the reader to understand why the barrier is needed.
> But even that isn't completely without precedent.
> "key_read_state()" in include/linux/key.h simply wraps
> smp_load_acquire(), and the comment there doesn't really tell me
> anything useful.
> "inet_sk_state_load" is slightly better it says it is for use in places
> where the socket lock isn't held - and names some of those.
>
>
> Understood and a fair assessment.
>
>
> My second problem is that has "get" in the accessor function name is
> potentially misleading and "get" normally has a matching "put", and
> usually increments a refcount.  Having "read" or "load" in place of
> "get" in the accessor function name would remove my second objection.
>
>
> Yeah, I was trying to balance with the set .. but really I'm not enamored
> with that either :P
>
>
> My third objection is that the bug doesn't exist in the upstream client
> code.  I'm not sure whether this is luck or good management, but either
> way it is gone.
>
>
> This is really good to know. Personally I was itching to refactor the whole
> lot but this gives a me a much better path.
>
>
> cl_sync_io_wait() has been changed to always take csi_waitq.lock.  This
> avoids the need for anchor->csi_barrier, and provides a more robust way
> to ensure that cl_sync_io_note() is completely finished before
> cl_sync_io_wait() completes.
>
> That isn't quite the outcome I was expecting...
>
> I'm sorry if I seem to have been rather harsh on your patch - my
> intention was only to make sure it was the best it could be.
>
> It really needed to have the stack trace and the arch were the LBUG
> happened to be at all complete.
> I would have been nice if it identified the particular code where the
> barrier was needed: between cl_sync_io_note() and cl_sync_io_wait()
> because that mediates and ownership transition that happens while the VM
> page is locked.
>
> The rest are probably just issues of taste.
>
> Thanks,
> NeilBrown
>
>
> Thanks I really appreciate the time need to consider the issue.
> And I agree any patch needs to be as good and tasteful as we can make them.
>
> Regards,
> Shaun
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190612/74f85baf/attachment.html>
