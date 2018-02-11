From: NeilBrown <neilb@suse.com>
Date: Mon, 12 Feb 2018 10:44:23 +1100
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
 <87o9kylux7.fsf@notabene.neil.brown.name>
 <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
Message-ID: <87h8qnrt0o.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Feb 08 2018, Oleg Drokin wrote:

>> On Feb 8, 2018, at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Thu, Feb 08 2018, Oleg Drokin wrote:
>> 
>>>> On Feb 8, 2018, at 8:39 PM, NeilBrown <neilb@suse.com> wrote:
>>>> 
>>>> On Tue, Aug 16 2016, James Simmons wrote:
>>> 
>>> my that?s an old patch
>>> 
>>>> 
>> ...
>>>> 
>>>> Whoever converted it to "!strcmp()" inverted the condition.  This is a
>>>> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
>>>> 
>>>> This causes many tests in the 'sanity' test suite to return
>>>> -ENOMEM (that had me puzzled for a while!!).
>>> 
>>> huh? I am not seeing anything of the sort and I was running sanity
>>> all the time until a recent pause (but going to resume).
>> 
>> That does surprised me - I reproduce it every time.
>> I have two VMs running a SLE12-SP2 kernel with patches from
>> lustre-release applied.  These are servers. They have 2 3G virtual disks
>> each.
>> I have two over VMs running current mainline.  These are clients.
>> 
>> I guess your 'recent pause' included between v4.15-rc1 (8e55b6fd0660)
>> and v4.15-rc6 (a93639090a27) - a full month when lustre wouldn't work at
>> all :-(
>
> More than that, but I am pretty sure James Simmons is running tests all the time too
> (he has a different config, I only have tcp).
>
>>>> This seems to suggest that no-one has been testing the mainline linux
>>>> lustre.
>>>> It also seems to suggest that there is a good chance that there
>>>> are other bugs that have crept in while no-one has really been caring.
>>>> Given that the sanity test suite doesn't complete for me, but just
>>>> hangs (in test_27z I think), that seems particularly likely.
>>> 
>>> Works for me, here?s a run from earlier today on 4.15.0:
>> 
>> Well that's encouraging .. I haven't looked into this one yet - I'm not
>> even sure where to start.
>
> m? debug logs for example (greatly neutered in staging tree, but still useful)?
> try lctl dk and see what?s in there.

Debug logs seem to tell me that some message is being sent to a server
and a reply is being received, but that request we are waiting on
doesn't make progress.  I plan to dig in and learn more about how lustre
rpc works so I have a better changes of interpreted those debug logs.


>
>>> Instead the plan was to clean up the staging client into acceptable state,
>>> move it out of staging, bring in all the missing features and then
>>> drop the client (more or less) from the lustre-release.
>> 
>> That sounds like a great plan.  Any idea why it didn't happen?
>
> Because meeting open-ended demands is hard and certain demands sound like
> ?throw away your X and rewrite it from scratch" (e.g. everything IB-related).

My narrow perspective on IB - from when rdma support was added to the
NFS server - is that it is broken by design and impossible to do
"right".  So different people could easily have different ideas on how
to make the best of a bad lot.
I might try to have a look.

>
> Certain things that sound useless (like the debug subsystem in Lustre)
> is very useful when you have a 10k nodes in a cluster and need to selectively
> pull stuff from a run to debug a complicated cross-node interaction.
> I asked NFS people how do they do it and they don?t have anything that scales
> and usually involves reducing the problem to a much smaller set of nodes first.

the "rpcdebug" stuff that Linux/nfs has is sometimes useful, but some parts
are changing to tracepoints and some parts have remained, which is a
little confusing.

The fact that lustre tracing seems to *always* log everything so that if
something goes wrong you can extract that last few meg(?) of logs seems
really useful.

I discovered - thanks to James -
 https://jira.hpdd.intel.com/browse/LU-8980
 Add tracepoint support to Lustre

which is "closed", but I cannot find any trace of tracepoints in
drivers/staging or in lustre-release.  Maybe I'm confused.
I suspect tracepoints is a good way to go.

>
>> It seems there is a lot of upstream work mixed in with the clean up, and
>> I don't think that really helps anyone.
>
> I don?t understand what you mean here.

Just that I thought that the main point of drivers/staging is to get the
code into a mergable state, and if feature addition happens at the same
time, then priorities get blurred and goals don't get reached.

>
>> Is it at all realistic that the client might be removed from
>> lustre-release?  That might be a good goal to work towards.
>
> Assuming we can bring the whole functionality over - sure.
>
> Of course there?d still be some separate development place and we would
> need to create patches (new features?) for like SuSE and other distros
> and for testing of server features, I guess, but that could just that -
> a side branch somewhere I hope.

Of course - code doesn't go upstream until it is ready.  Lots of
development happens elsewhere.
Of course distros like SUSE would generally rather ship code that was
"ready" and so like to see it upstream.  There is usually room for
negotiation.

>
> It?s not that we are super glad to chase every kernel vendors put out,
> of course it would be much easier if the kernels already included
> a very functional Lustre client.
>
>>>> Might it make sense to instead start cleaning up the code in
>>>> lustre-release so as to make it meet the upstream kernel standards.
>>>> Then when the time is right, the kernel code can be moved *out* of
>>>> lustre-release and *in* to linux.  Then development can continue in
>>>> Linux (just like it does with other Linux filesystems).
>>> 
>>> While we can be cleaning lustre in lustre-release, there are some things
>>> we cannot do as easily, e.g. decoupling Lustre client from the server.
>>> Also it would not attract any reviews from all the janitor or
>>> (more importantly) Al Viro and other people with a sharp eyes.
>>> 
>>>> An added bonus of this is that there is an obvious path to getting
>>>> server support in mainline Linux.  The current situation of client-only
>>>> support seems weird given how interdependent the two are.
>>> 
>>> Given the pushback Lustre client was given I have no hope Lustre server
>>> will get into mainline in my lifetime.
>> 
>> Even if it is horrible it would be nice to have it in staging... I guess
>> the changes required to ext4 prohibit that... I don't suppose it can be
>> made to work with mainline ext4 in a reduced-functionality-and-performance
>> way??
>
> We support unpatched ZFS as a server too! ;)

So that that mean you would expect lustre-server to work with unpatched
ext4? In that case I won't give up hope of seeing the server in mainline
in my lifetime.  Client first though.

> (and if somebody invests the time into it, there was some half-baked btrfs
> backend too I think).
> That said nobody here believes in any success of pushing Lustre server into
> mainline.
> It would just be easier to push the whole server into userspace (And there
> was a project like this in the past, now abandoned because it was mostly
> targeting Solaris anyway).
>
>> I think it would be a lot easier to motivate forward progress if there
>> were a credible end goal of everything being in mainline.
>> 
>>> 
>>>> What do others think?  Is there any chance that the current lustre in
>>>> Linux will ever be more than a poor second-cousin to the external
>>>> lustre-release.  If there isn't, should we just discard it now and move
>>>> on?
>>> 
>>> 
>>> I think many useful cleanups and fixes came from the staging tree at
>>> the very least.
>>> The biggest problem with it all is that we are in staging tree so
>>> we cannot bring it to parity much. And we are in staging tree because
>>> there?s a whole bunch of ?cleanups? requested that take a lot of effort
>>> (in both implementing them and then in finding other ways of achieving
>>> things that were done in old ways before).
>> 
>> Do you have a list of requested cleanups?  I would find that to be
>> useful.
>
> As Greg would tell you, ?if you don?t know what needs to be done,
> let?s just remove the whole thing from staging now?.

Of course, but I don't expect that I will see the same things that
others see.  And if people have gone to the trouble to provide feedback,
it seems polite to record that feed back for all to see.

>
> I assume you saw drivers/staging/lustre/TODO already, it?s only partially done.

Yes - it isn't very detailed though.  Maybe I'll flesh it out with some
of the things you have said.

>
> We had a bunch of other requests from various people ranging from wholesale
> removal of various parts to making sure there?s no checkpatch warnings
> (Turned out rather hard to do, even though we greatly pared the
> numbers).

checkpatch is a useful guide, but an awful master.

% find drivers/staging/lustre/ -name '*.[ch]' | while read a; do
   ./scripts/checkpatch.pl --max-line-length=10000 --no-summary -f $a
   done|grep '^ERROR' | sort | uniq -c


     17 ERROR: Macros with complex values should be enclosed in parentheses
      2 ERROR: Macros with multiple statements should be enclosed in a do - while loop
     12 ERROR: No #include in ...include/uapi/... should use a uapi/ path prefix
      1 ERROR: space required before the open brace '{'
      8 ERROR: that open brace { should be on the previous line
      1 ERROR: trailing statements should be on next line
      1 ERROR: trailing whitespace

Thanks isn't too bad - obviously nearly there with checkpatch.
Lots more warnings - some might be interesting.

wholesale removal - like the prng, the workqueues, and the
ll_wait_event() macro?  I can do that :-)


>
> I have some patches to make Lustre a lot more monolithic too.

Yes, it annoys me that I cannot build without modules.  I took some
steps towards fixing that and went off down a rabbit hole..
Should be fairly easy.

> People want us to remove our indirections hell so the code is more readable
> (I have some patches that need to be freshened up some that help here a bit,
> but the work is huge.)

But indirections solve all problems :-)

>
> Other requests come out as some of the prior ones get completed due to
> ?you need o finish current level of cleanups so that we can see what other
> cleanups are needed, the current code is too bad to see everything? pretty much.

Thanks a lot for your helpful reply.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180212/42b47340/attachment.sig>
