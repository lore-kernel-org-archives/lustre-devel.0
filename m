From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Jun 2018 01:21:53 +0100 (BST)
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <87po12ncjv.fsf@notabene.neil.brown.name>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806120114020.15735@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> lustre-testing:
> >>    is based on 'lustre' and has most of my current lustre-related work.
> >>    It includes assorted patches that are not specifically for lustre
> >>    (rhashtables mostly at the moment).  Patches will move from here
> >>    to 'lustre' or to mainline when they are ready.
> >>    I plan to update this branch on most days that I work on Lustre,
> >>    and expect it to rebase frequently.
> >
> > I had question about that. Some things in Lustre could in theory be merged
> > into the linux kernel proper. Can that be done still?
> 
> What things?
> 
> If it measurably benefits the kernel proper, then I suspect it might be
> worth submitting.  Things can go direct without going though staging -
> they just have to be of good quality with good justification (and
> sometimes lots of patience).

One piece of work done for Lustre was the ability to submit "units" like
K, M, G for sizes to sysfs files. This was developed before string helpers
was created and the code for Lustre is well very ugly. So I rewrote it
in the style of string helpers and it can be handly for other things as 
well such as module parameters setting. Lustre does have certain features
in it debugging system that can applied to the linux kernel debugging
system. That is more down the road. Their are few others like the crypto
wrapper for alder. I don't see why that can't be mainstream.
 
> >  
> >> I'm happy to review and, if acceptable, apply patches from other
> >> developers.  I have fairly high standards, but if I don't accept your
> >> patch I'll explain why and possible help fix it.
> >
> > Also long as you talk to me :-) I'm an easy person to work with. If I 
> > refuse a patch with do the same. I might sometimes seem irrational 
> > but I have valid reasons. Well at least in my head.
> >
> > We need to really layout the roadmap.
> 
> I have very little faith in road maps - I prefer to make steps.  Once we
> have made all the steps, we can look back and see what the map looked
> like in retrospect.

I was looking to see what you plan to work on. I wanted to avoid 
duplicating work. Some things I know of done already are listed under:

https://jira.hpdd.intel.com/browse/LU-9855
https://jira.hpdd.intel.com/browse/LU-10257
https://jira.hpdd.intel.com/browse/LU-10994

Their are a few others I have to hunt down but these are the major ones.
