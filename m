From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 8 Feb 2018 22:50:32 -0500
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87o9kylux7.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
 <87o9kylux7.fsf@notabene.neil.brown.name>
Message-ID: <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Feb 8, 2018, at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Thu, Feb 08 2018, Oleg Drokin wrote:
> 
>>> On Feb 8, 2018, at 8:39 PM, NeilBrown <neilb@suse.com> wrote:
>>> 
>>> On Tue, Aug 16 2016, James Simmons wrote:
>> 
>> my that?s an old patch
>> 
>>> 
> ...
>>> 
>>> Whoever converted it to "!strcmp()" inverted the condition.  This is a
>>> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
>>> 
>>> This causes many tests in the 'sanity' test suite to return
>>> -ENOMEM (that had me puzzled for a while!!).
>> 
>> huh? I am not seeing anything of the sort and I was running sanity
>> all the time until a recent pause (but going to resume).
> 
> That does surprised me - I reproduce it every time.
> I have two VMs running a SLE12-SP2 kernel with patches from
> lustre-release applied.  These are servers. They have 2 3G virtual disks
> each.
> I have two over VMs running current mainline.  These are clients.
> 
> I guess your 'recent pause' included between v4.15-rc1 (8e55b6fd0660)
> and v4.15-rc6 (a93639090a27) - a full month when lustre wouldn't work at
> all :-(

More than that, but I am pretty sure James Simmons is running tests all the time too
(he has a different config, I only have tcp).

>>> This seems to suggest that no-one has been testing the mainline linux
>>> lustre.
>>> It also seems to suggest that there is a good chance that there
>>> are other bugs that have crept in while no-one has really been caring.
>>> Given that the sanity test suite doesn't complete for me, but just
>>> hangs (in test_27z I think), that seems particularly likely.
>> 
>> Works for me, here?s a run from earlier today on 4.15.0:
> 
> Well that's encouraging .. I haven't looked into this one yet - I'm not
> even sure where to start.

m? debug logs for example (greatly neutered in staging tree, but still useful)?
try lctl dk and see what?s in there.

>> Instead the plan was to clean up the staging client into acceptable state,
>> move it out of staging, bring in all the missing features and then
>> drop the client (more or less) from the lustre-release.
> 
> That sounds like a great plan.  Any idea why it didn't happen?

Because meeting open-ended demands is hard and certain demands sound like
?throw away your X and rewrite it from scratch" (e.g. everything IB-related).

Certain things that sound useless (like the debug subsystem in Lustre)
is very useful when you have a 10k nodes in a cluster and need to selectively
pull stuff from a run to debug a complicated cross-node interaction.
I asked NFS people how do they do it and they don?t have anything that scales
and usually involves reducing the problem to a much smaller set of nodes first.

> It seems there is a lot of upstream work mixed in with the clean up, and
> I don't think that really helps anyone.

I don?t understand what you mean here.

> Is it at all realistic that the client might be removed from
> lustre-release?  That might be a good goal to work towards.

Assuming we can bring the whole functionality over - sure.

Of course there?d still be some separate development place and we would
need to create patches (new features?) for like SuSE and other distros
and for testing of server features, I guess, but that could just that -
a side branch somewhere I hope.

It?s not that we are super glad to chase every kernel vendors put out,
of course it would be much easier if the kernels already included
a very functional Lustre client.

>>> Might it make sense to instead start cleaning up the code in
>>> lustre-release so as to make it meet the upstream kernel standards.
>>> Then when the time is right, the kernel code can be moved *out* of
>>> lustre-release and *in* to linux.  Then development can continue in
>>> Linux (just like it does with other Linux filesystems).
>> 
>> While we can be cleaning lustre in lustre-release, there are some things
>> we cannot do as easily, e.g. decoupling Lustre client from the server.
>> Also it would not attract any reviews from all the janitor or
>> (more importantly) Al Viro and other people with a sharp eyes.
>> 
>>> An added bonus of this is that there is an obvious path to getting
>>> server support in mainline Linux.  The current situation of client-only
>>> support seems weird given how interdependent the two are.
>> 
>> Given the pushback Lustre client was given I have no hope Lustre server
>> will get into mainline in my lifetime.
> 
> Even if it is horrible it would be nice to have it in staging... I guess
> the changes required to ext4 prohibit that... I don't suppose it can be
> made to work with mainline ext4 in a reduced-functionality-and-performance
> way??

We support unpatched ZFS as a server too! ;)
(and if somebody invests the time into it, there was some half-baked btrfs
backend too I think).
That said nobody here believes in any success of pushing Lustre server into
mainline.
It would just be easier to push the whole server into userspace (And there
was a project like this in the past, now abandoned because it was mostly
targeting Solaris anyway).

> I think it would be a lot easier to motivate forward progress if there
> were a credible end goal of everything being in mainline.
> 
>> 
>>> What do others think?  Is there any chance that the current lustre in
>>> Linux will ever be more than a poor second-cousin to the external
>>> lustre-release.  If there isn't, should we just discard it now and move
>>> on?
>> 
>> 
>> I think many useful cleanups and fixes came from the staging tree at
>> the very least.
>> The biggest problem with it all is that we are in staging tree so
>> we cannot bring it to parity much. And we are in staging tree because
>> there?s a whole bunch of ?cleanups? requested that take a lot of effort
>> (in both implementing them and then in finding other ways of achieving
>> things that were done in old ways before).
> 
> Do you have a list of requested cleanups?  I would find that to be
> useful.

As Greg would tell you, ?if you don?t know what needs to be done,
let?s just remove the whole thing from staging now?.

I assume you saw drivers/staging/lustre/TODO already, it?s only partially done.

We had a bunch of other requests from various people ranging from wholesale
removal of various parts to making sure there?s no checkpatch warnings
(Turned out rather hard to do, even though we greatly pared the numbers).

I have some patches to make Lustre a lot more monolithic too.
People want us to remove our indirections hell so the code is more readable
(I have some patches that need to be freshened up some that help here a bit,
but the work is huge.)

Other requests come out as some of the prior ones get completed due to
?you need o finish current level of cleanups so that we can see what other
cleanups are needed, the current code is too bad to see everything? pretty much.

Bye,
    Oleg
