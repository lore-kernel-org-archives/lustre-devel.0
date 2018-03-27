From: NeilBrown <neilb@suse.com>
Date: Wed, 28 Mar 2018 08:58:45 +1100
Subject: [lustre-devel] Current results and status of my upstream work
In-Reply-To: <CABoqRjuYZso1m8B+oVoym3i9krpRUabhBDiahhoBHPw=swM=EA@mail.gmail.com>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87bmgvrsj8.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1802120233260.3291@casper.infradead.org>
 <871sg65bid.fsf@notabene.neil.brown.name>
 <5E5F3507-FAE1-42C3-8509-1CB08DE26F6C@intel.com>
 <CABoqRjuYZso1m8B+oVoym3i9krpRUabhBDiahhoBHPw=swM=EA@mail.gmail.com>
Message-ID: <87muyt41uy.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Mar 27 2018, Jinshan Xiong wrote:

> Yes, what Andreas said is correct. This check is really expensive and has
> never been enabled after the initial development of client I/O code. We
> should get rid of it.

"never" isn't correct.  I always do development with all the LINVRNTs
enabled - it seems like a good idea for catching bugs early.

But if you say this invariant is wrong and should be deleted, then I'll
submit a patch to do that.

Thanks,
NeilBrown


>
> Jinshan
>
> On Mon, Mar 26, 2018 at 11:17 PM, Dilger, Andreas <andreas.dilger@intel.com>
> wrote:
>
>> On Mar 26, 2018, at 23:32, NeilBrown <neilb@suse.com> wrote:
>> >
>> > One failure that I have looked into but haven't posted a patch for yet,
>> > is that sometimes
>> >        LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state ==
>> CIS_LOCKED);
>> > in cl_io_read_ahead() fails.  When it does, the value is CIS_INIT.
>> > Tracing through the code, it seem that CIS_INIT is an easy possibility
>> > since 1e1db2a97be5 ("staging: lustre: clio: Revise read ahead
>> implementation")
>> > However CIS_IO_GOING and CIS_LOCKED do also happen and I cannot see
>> > that patht that leads to those - so I didn't feel that I could
>> > correctly explain the patch.
>> > I currently have:
>> >
>> >       LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED
>> ||
>> >               io->ci_state == CIS_INIT);
>> > Do you have any idea if that is right?
>>
>> It is worthwhile to mention that LINVRNT() doesn't get enabled very often,
>> since this enables some very expensive correctness tests.  This means it is
>> entirely possible that this assertion is incorrect since the referenced
>> commit.
>>
>> Possibly Jinshan can comment?
>>
>> Cheers, Andreas
>> --
>> Andreas Dilger
>> Lustre Principal Architect
>> Intel Corporation
>>
>>
>>
>>
>>
>>
>>
>>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180328/c9047c6e/attachment.sig>
