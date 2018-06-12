From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Jun 2018 01:12:15 +0100 (BST)
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <C50F2EA9-AD25-480A-8A05-2541206BA17F@intel.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
 <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
 <87h8memg4k.fsf@notabene.neil.brown.name>
 <C50F2EA9-AD25-480A-8A05-2541206BA17F@intel.com>
Message-ID: <alpine.LFD.2.21.1806081606001.13085@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > On Thu, Jun 07 2018, Doug Oucharek wrote:
> > 
> >> What is the focus of landings in this tree?  There are two things needing to be done for an upstream Lustre:
> >> 
> >> 
> >>  *   Get the source code to meet the Linux guidelines so it is acceptable to be in mainline.
> >>  *   Get the binary product to have all the features and bug fixes that are in the Intel community tree so end users are interested in using the upstream version (users are unlikely to use a version of Lustre which is not current).
> >> 
> >> For the now-deleted staging area, we were supposed to be focusing on the first item but were submitting patches for the second item (syncing with Intel tree).  In my opinion, this is the core reason for never being able to get out of staging and getting deleted.
> > 
> > My (undoubtedly biased) perspective on the history of lustre in staging
> > goes like this:
> > There are two things needed for some out-of-tree code to get into
> > mainline Linux:  the code needs to be integrated and the community needs
> > to be integrated (or a new sub-community needs to form).
> > In the case of lustre, the code was never really integrated because the
> > community never really tried to integrate.
> 
> One of the issues here was that the group (not Intel) that submitted the
> Lustre code to the staging tree promptly abandoned it for a couple of
> years after they submitted it upstream, after promising the community
> that they were in it for the long run.  That put the upstream integration
> behind the eight-ball from the start.

The leason from this is that the upstream efforts can not be placed on an
single organization's efforts. It has to be a group effort. Before Neil
showed up I was the only person working on the upstream efforts for some
time. I came under pressure to abandon this effort but since I do this
on the weekends in my free time it doesn't impact my normal job duties.
So I managed to get away with this work. It does help that actually
useful by products from this effort shows up in the general lustre
community which in turn benefits my employeer. I bet for EMC the burden
was to much and since no one supported them they abandon this work.
The main reason people abandon things in life is feeling unsupported.
Even if all you do is act as a cheerleader it can have a big impact
on the people doing the work. At one time I felt the same way with the 
upstream client which I shared with Peter Jones. Peter pointed out that he 
knows sites that do use the upstream client. Since then my focus has been 
aimed at supporting those users. With my focus is on the users so if 
companies join or don't join in is not important to me.

> > Yes, the current code needs to be improved, bugs need to be fixed, and
> > features need to be added.  The order in which these is done is not the
> > most important things - if it were, Greg would have never accepted any
> > new features.  However he *did* accept them, but tried to remind the
> > lustre developers that there was other work to do.
> > 
> > Working together in one (single) community requires give-and-take.
> > Greg's behaviour as just described seems to be evidence of
> > give-and-take.  I think he kicked lustre out of staging because he
> > concluded that he was never going to get the matching give-and-take in
> > return.

Based on the emails sent I see no one understood the work I was doing for 
the last 2 years. I guess that is my fault for not having general 
discussion emails on the efforts. Mind you at first I tried to send 
non patch emails to the staging mailing list but they always were 
filtered out so I gave up. Also no one every talked to me about what the
cleanups should be. So I have always worked on what I know is a problem.
Mainly things reported by users and also things reported back to Oleg
from the VFS developers. That is how the roadmap came into being that
I discussed at developer's day for LUG.

First of all the upstream client is NOT at a 2.4 version. Its close to 
a 2.9 version. In fact its newer then the default lustre client Cray ships
with (2.7). Second I haven't pushed features for over a year. The first
year I did spend syncing the tree up to 2.8+ version which got us to a
point where people were willing to try it. 

After that it became this constant smash the bugs for the last year. The 
port to sysfs and the 64 bit time work was incorrect and lead to all kinds 
of regressions. Also the xattr which lustre heavly depends on was broken. 
Nearly all xattr bugs are fixed. I nearly have resolved most of the 64
bit time and sysfs bugs. Still haven't push them yet but that is next. 
So my focus is reduce all the regression to a manageable level. I really
didn't want to see a lustre client out of staging that was a complete 
piece of 'bleep'.

The client feature wise is nearly 2.9 but many bug fixes from 2.10 and
above have been merged to the upstream code. The gap is much smaller than
you realize. So the upstream client is strange hybrid. 

> > So to answer your opening question, my focus for this tree is to train
> > any lustre developers who wish to engage about how to be part of the
> > Linux community.  As I've already said - I will accept features but I
> > prefer cleanups first.  I don't want to try to explain further than that
> > because it will be too hypothetical and unhelpful.  We - the Linux
> > community - don't work in hypotheticals.  We work with concrete objects
> > like patches.  So send me a patch and I will tell you what I think of
> > that specific patch.  It is up to you to generalise what I say to other
> > patches.  It might also be up to you to argue your case and tell me why
> > I'm wrong.  I'll be patient (because good upstream maintainers are) but
> > patience doesn't last forever (for Greg, it lasted about 5 years - I
> > hope mine won't be tried to that extent).
> 
> Like I said in my other email, I think having another fork of the Lustre
> tree, especially one that is starting from two-year-old code is likely to
> fail, because there will be twice as much effort spent to maintain the two
> trees.  I'd rather see the cleanups and features go hand-in-hand into the
> same tree.  I'd be thrilled to have more reviews done on the features before
> they are landed, but we can't just stop all feature development for a year
> or two (or five) while the code is merged into the upstream kernel.

I don't think having another tree is such a big issue. As I pointed out
earlier Cray carries their own lustre client. Also Livermore Labs 
has their own special Choas lustre tree. Lastly we do backports to LTS
version of lustre all the time.

I'm really against using the out of tree for this kernel cleanup for a
few reasons. The gap between upstream and master is less than you think.
Outside the features landed the majority of the patches landed to the 
OpenSFS/Intel branch is my work to sync both the upstream client and the 
Intel community branch. Next from personal experinece it takes a very very
long time to land cleanup patches for the Intel branch. It normally takes
3 release cycles to complete any work which means we are looking at least
1.5 years to finish meeting upstream requirements. Now going in the other
direction in a few months we could reach parity with the out of tree
source. Especially since the gap is much smaller now. I ready to close
the gap.
