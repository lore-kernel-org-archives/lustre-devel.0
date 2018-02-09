From: NeilBrown <neilb@suse.com>
Date: Fri, 09 Feb 2018 14:10:44 +1100
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
Message-ID: <87o9kylux7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wang di <di.wang@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Feb 08 2018, Oleg Drokin wrote:

>> On Feb 8, 2018, at 8:39 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Tue, Aug 16 2016, James Simmons wrote:
>
> my that?s an old patch
>
>> 
...
>> 
>> Whoever converted it to "!strcmp()" inverted the condition.  This is a
>> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
>> 
>> This causes many tests in the 'sanity' test suite to return
>> -ENOMEM (that had me puzzled for a while!!).
>
> huh? I am not seeing anything of the sort and I was running sanity
> all the time until a recent pause (but going to resume).

That does surprised me - I reproduce it every time.
I have two VMs running a SLE12-SP2 kernel with patches from
lustre-release applied.  These are servers. They have 2 3G virtual disks
each.
I have two over VMs running current mainline.  These are clients.

I guess your 'recent pause' included between v4.15-rc1 (8e55b6fd0660)
and v4.15-rc6 (a93639090a27) - a full month when lustre wouldn't work at
all :-(


>
>> This seems to suggest that no-one has been testing the mainline linux
>> lustre.
>> It also seems to suggest that there is a good chance that there
>> are other bugs that have crept in while no-one has really been caring.
>> Given that the sanity test suite doesn't complete for me, but just
>> hangs (in test_27z I think), that seems particularly likely.
>
> Works for me, here?s a run from earlier today on 4.15.0:

Well that's encouraging .. I haven't looked into this one yet - I'm not
even sure where to start.

>
>> So my real question - to anyone interested in lustre for mainline linux
>> - is: can we actually trust this code at all?
>
> Absolutely. Seems that you just stumbled upon a corner case that was not
> being hit by people that do the testing, so you have something unique about
> your setup, I guess.
>
>> I'm seriously tempted to suggest that we just
>>  rm -r drivers/staging/lustre
>> 
>> drivers/staging is great for letting the community work on code that has
>> been "thrown over the wall" and is not openly developed elsewhere, but
>> that is not the case for lustre.  lustre has (or seems to have) an open
>> development process.  Having on-going development happen both there and
>> in drivers/staging seems a waste of resources.
>
> It is a bit of a waste of resources, but there are some other things here.
> E.g. we cannot have any APIs with no users in the kernel.
> Also some people like to have in-kernel modules coming with their distros
> (there were some users that used staging client on ubuntu as their
> setup).
>
> Instead the plan was to clean up the staging client into acceptable state,
> move it out of staging, bring in all the missing features and then
> drop the client (more or less) from the lustre-release.

That sounds like a great plan.  Any idea why it didn't happen?
It seems there is a lot of upstream work mixed in with the clean up, and
I don't think that really helps anyone.

Is it at all realistic that the client might be removed from
lustre-release?  That might be a good goal to work towards.

>
>> Might it make sense to instead start cleaning up the code in
>> lustre-release so as to make it meet the upstream kernel standards.
>> Then when the time is right, the kernel code can be moved *out* of
>> lustre-release and *in* to linux.  Then development can continue in
>> Linux (just like it does with other Linux filesystems).
>
> While we can be cleaning lustre in lustre-release, there are some things
> we cannot do as easily, e.g. decoupling Lustre client from the server.
> Also it would not attract any reviews from all the janitor or
> (more importantly) Al Viro and other people with a sharp eyes.
>
>> An added bonus of this is that there is an obvious path to getting
>> server support in mainline Linux.  The current situation of client-only
>> support seems weird given how interdependent the two are.
>
> Given the pushback Lustre client was given I have no hope Lustre server
> will get into mainline in my lifetime.

Even if it is horrible it would be nice to have it in staging... I guess
the changes required to ext4 prohibit that... I don't suppose it can be
made to work with mainline ext4 in a reduced-functionality-and-performance
way??

I think it would be a lot easier to motivate forward progress if there
were a credible end goal of everything being in mainline.

>
>> What do others think?  Is there any chance that the current lustre in
>> Linux will ever be more than a poor second-cousin to the external
>> lustre-release.  If there isn't, should we just discard it now and move
>> on?
>
>
> I think many useful cleanups and fixes came from the staging tree at
> the very least.
> The biggest problem with it all is that we are in staging tree so
> we cannot bring it to parity much. And we are in staging tree because
> there?s a whole bunch of ?cleanups? requested that take a lot of effort
> (in both implementing them and then in finding other ways of achieving
> things that were done in old ways before).

Do you have a list of requested cleanups?  I would find that to be
useful.


> I understand that beggars cannot be choosers and while there are people
> that are grandfathered with their atrocities in current kernel tree,
> we must adhere to the shining standards first before having our chance,
> but the standards are not easy to adhere to in an established sizeable
> codebase.
>
> Realistically speaking I suspect if we drop Lustre from staging,
> it?s unlikely there would remain any steam behind the cleanup efforts
> at all.

Thanks for your thoughts,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180209/05bb95ef/attachment.sig>
