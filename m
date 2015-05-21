From: Michael Shuey <shuey@purdue.edu>
Date: Thu, 21 May 2015 14:55:38 -0400
Subject: [lustre-devel] Upstream code format clean-up
In-Reply-To: <27AD9F40-E3E4-425D-9DE7-B86872B0BCCE@intel.com>
References: <7B4D27A9-2E8C-4EB2-8B84-7E3738AEF993@iu.edu>
	<D17A336A.8E136%peter.a.jones@intel.com>
	<9B8BAC92-EA50-4621-8A91-C49A482DBB1B@intel.com>
	<CABqvwjsGGhA3EKfbqDTQrnOaT+JVYOVUt4SOsQnnzDnyZt0FMQ@mail.gmail.com>
	<7B49943B-4D51-4A11-8771-BF219D23658D@intel.com>
	<555CD0F7.40804@iu.edu>
	<CABqvwjuotFEx0u2naM3ZRh_-4WZ_wZrjAJVKWg5v3ARV_doamQ@mail.gmail.com>
	<555E1691.5090709@iu.edu>
	<27AD9F40-E3E4-425D-9DE7-B86872B0BCCE@intel.com>
Message-ID: <CABqvwjveL7uG7D9pP7jXODasCStK5DVtfba9Br=TGo15KHWMGw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

(added lustre-devel, since there's good backstory for others here)

Don't worry if you aren't an expert in C - much of the initial cleanup is
easy.  Just mop up a file, and make sure the kernel still builds again.
There's a good guide on working with the linux-next kernel here:

https://www.kernel.org/doc/man-pages/linux-next.html

I've been following these directions to send an emailed patch series:

https://burzalodowa.wordpress.com/2013/10/05/how-to-send-patches-with-git-send-email/

We should probably keep these cleanups in one big patch series, to ease
upstream adoption.  I suggest branching linux-next (I'm working off the
20150518 tag currently), and committing things as you finish mopping them
up with git commit -s <file>.  That way, git automatically inserts the
"Signed-off-by" line for you.  If you send a patch series over to me, I'll
sign it off as well, and fold it into the series I'm regularly posting.
You can do that with the following:

git format-patch --subject-prefix="PATCH" -o <output dir> -<# commits in
series>
git send-email -<# commits> --subject-prefix="PATCH" --to=<dest email>
<output dir>

BTW, adding --compose to the git send-email line will pop up an editor, to
write an introduction to the series (the [PATCH 0/8] email, introducing the
set).  Be sure your commits include a single-line comment summarizing the
change, a blank line, a more verbose (if needed) comment, another blank
line, and then the Signed-off-by header.  Otherwise the kernel gatekeepers
have trouble merging, and you'll be dinged on syntax.

If I can help in any way, please let me know.

--
Mike Shuey

On Thu, May 21, 2015 at 1:53 PM, Drokin, Oleg <oleg.drokin@intel.com> wrote:

> The procedure is to use git send-email (with --annotation if more than one
> patch) and that would generate the diffstats and other stuff.
>
> On May 21, 2015, at 1:32 PM, Chris Hanna wrote:
>
> > Hi Mike,
> >
> > Great, I'll work on the osc for starters.  I should also warn that I'm
> > not an expert in C, I'm just an admin of an XSEDE resource that isn't in
> > production yet, so I have some free cycles.  I will run checkpatch on
> > anything I build and double-check.  I'll keep my old K&R C book handy
> > for good luck.
> >
> > Is the procedure, like you've done already, to mail Oleg and CC
> > devel at driverdev.osuosl.org, gregkh at linuxfoundation.org,
> > kernel-janitors at vger.kernel.org, linux-kernel at vger.kernel.org and HPDD
> > list with the git stats and full git patch?
> >
> > I can post future mailings to lustre-devel, I'm already subscribed.
> >
> > Thanks,
> >
> > Chris
> >
> > On 5/21/15 11:55 AM, Michael Shuey wrote:
> >> Chris, good to virtually meet you!
> >>
> >> I don't know of anyone (other than myself) submitting cleanup patches
> for
> >> linux-next, though there are a number of patches under LU-6215 and
> LU-6142
> >> in the HPDD tree that do some cleanups.
> >>
> >> I've mostly been focusing on cleaning the lnet part of the tree; if you
> >> wanted to start in on some of the lustre parts, that would be great.
> I've
> >> been breaking the task up into multiple phases:
> >>
> >> 1) clean whitespace - tabs, not spaces, to indent; fix variable
> alignment
> >> in headers, and change variable declaration blocks to use a single space
> >> (between type & variable)
> >>
> >> 2) eliminate obvious dead code
> >>
> >> 3) fix remaining checkpatch.pl issues (underway now)
> >>
> >> 4) (TBD) sync code with HPDD's tree
> >>
> >> If you wanted to start down on lustre/osc and lustre/ptlrpc, that'd be
> >> good.  I'm collecting patches against both the kernel.org tree and the
> HPDD
> >> tree, to propagate dead code removal to HPDD (and largely ignoring
> >> formatting and checkpatch.pl fixes for HPDD right now).  Any patching
> you
> >> can provide would be most appreciated!
> >>
> >> BTW, we should probably spin up a mail thread about this somewhere more
> >> public.  Are you on lustre-devel, and would you mind posting future
> >> coordination emails to the whole list?
> >>
> >> --
> >> Mike Shuey
> >>
> >> On Wed, May 20, 2015 at 2:22 PM, Chris Hanna <hannac@iu.edu> wrote:
> >>
> >>> Greetings!
> >>>
> >>> I should have some time this week to work on this, any suggestions for
> >>> where I could start in Greg's linux-next tree?  Is anyone doing format
> >>> cleanup on '/drivers/staging/lustre/lustre/osc/', for example?  I don't
> >>> want to duplicate something already in process.
> >>>
> >>> Thanks,
> >>> Chris
> >>>
> >>> On 5/15/15 4:02 PM, Drokin, Oleg wrote:
> >>>> Hello!
> >>>>
> >>>> On May 15, 2015, at 10:19 AM, Michael Shuey wrote:
> >>>>
> >>>>> I'm relatively new to kernel.org development, and completely new to
> >>> lustre development - so be warned, I'll have many newbie questions.
> That
> >>> said, I'd very much like to help ensure lustre stays in the upstream
> >>> kernel, and do whatever I can to shift as much development upstream as
> >>> possible.  At the moment, I've been looking at trivial cleanups
> >>> (indentation, dead code removal, etc.) as a means to learn how to send
> >>> patches upstream.  I'm happy to continue this, and begin eliminating
> >>> checkpatch warnings as well.  It's a good learning exercise, and once I
> >>> have a rhythm for submitting patches and testing I can bring in some
> of my
> >>> team and move on to other tasks on the list.
> >>>>> That said, I've got some logistics questions...
> >>>>>
> >>>>> 1) What development mailing lists should I track?
> >>>>>
> >>>>> I follow lustre-discuss and lustre-devel, and hpdd-discuss.  Is there
> >>> an hpdd-devel, where major code shifts are discussed?  Or is discussion
> >>> primarily through developer days, issue trackers, and out-of-band mail
> >>> threads like this?
> >>>> hpdd-disuss is currently the designated place to send patches to.
> >>> lustre-devel is where we'd eventually shift.
> >>>> That said, sadly there are not too much public discussions of things
> >>> frequently because stuff is usually developed by a single company.
> >>>> So most of discussion is happening at developer days and forums like
> >>> opensfs CWG. Also email threads and tickets.
> >>>>> 2) Is there a current "getting started with Lustre dev" guide?
> >>>>>
> >>>>> There's little documentation on lustre.org about managing
> development
> >>> - and what I've found tends to be either very old (e.g., Oracle days)
> or
> >>> incomplete (e.g., developer day slides, where specifics were only
> covered
> >>> in person).  Is there a more current guide?  Or should I bug Morrone
> for an
> >>> account on lustre.org, and build such a guide in his wiki?  I'm happy
> to
> >>> add documentation as well?
> >>>> For community tree lustre )meaning not the in-kernel thing) it's
> >>> https://wiki.hpdd.intel.com/display/PUB/Lustre+Development
> >>>> in particular
> https://wiki.hpdd.intel.com/display/PUB/Submitting+Changes
> >>>>
> >>>>> 2) What's the end goal here, between kernel.org and HPDD trees?
> >>>>>
> >>>>> HPDD and kernel.org maintain two separate trees.  Presumably patches
> >>> should be developed for both, correct?  If so, will parts of the HPDD
> tree
> >>> be going away at any point - to be supplanted by kernel.org?  I know
> Greg
> >>> KH has indicated that development should occur in kernel.org - but
> that
> >>> may not be possible, given the need to support older vendor kernels.
> >>> HPDD's tree isn't really upstream for kernel.org, either - there's a
> >>> number of pieces that can't go in right now.
> >>>>> Where is this going?
> >>>> This is a complicated question, really.
> >>>>
> >>>> Initially EMC rammed this thing in, since supposedly it gives you
> "free"
> >>> update of codebase to support newer kernels.
> >>>> Well, it did not pan out exactly as planned and they bailed out. Now
> we
> >>> get to keep the pieces.
> >>>> Having the client in the tree is indeed good for it being updated for
> >>> in-kernel API changes and stuff.
> >>>> Currently it's a liability, though since we need to maintain
> >>> compatibility with this somewhat old code snapshot and no new features
> >>> could be added.
> >>>> Ideally in the end it would be a fully featured up to date client that
> >>> would be shipped by major distros.
> >>>> Also having this code fully accepted means certain things we'd like
> >>> added to kernel APIs is easier to justify since the main argument of
> "no
> >>> code in kernel uses this" goes away.
> >>>> I feel like we wound not be able to fully drop client support from our
> >>> hpdd tree in any foreseeable future because we need compatibility with
> all
> >>> old distros that don't ship new enough kernel.
> >>>> And then once they all start carrying it, they'd probably won't have
> any
> >>> moedrn features too so there would still be place for a backported
> client
> >>> or something.
> >>>>> 3) How do patches go into HPDD's tree?
> >>>>>
> >>>>> I've found some slides from Andreas; I'm starting to understand what
> >>> role Jenkins, Gerrit, and the HPDD tree play.  How does one get patches
> >>> into this?  git send-email to a list, bug someone for an account on
> Gerrit,
> >>> or what?   Or should I not be looking at the HPDD tree, and only
> staring at
> >>> kernel.org's tree?
> >>>> https://wiki.hpdd.intel.com/display/PUB/Submitting+Changes
> >>>>
> >>>> You'll need to create your own account in gerrit and use that to
> submit
> >>> patches.
> >>>> For upstream kernel work, you should not really be looking into hpdd
> >>> tree much other than submitting same patches to hpdd tree for stuff
> like
> >>> unneeded proc files removal and tools updates.
> >>>> Bye,
> >>>>    Oleg
> >>>
> >
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150521/90eb12df/attachment.htm>
