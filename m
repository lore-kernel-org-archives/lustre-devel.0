From: Patrick Farrell <paf@cray.com>
Date: Thu, 7 Jun 2018 13:25:03 +0000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>,
 <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
Message-ID: <DM3PR1101MB1213BB514F8D6E25F725BB1DCB640@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Doug,

Another thought about the core reason.

Commitment to this.  The existing code state (weird, abandoned 2.4.something code) and merge rules seemingly made it impossible to shift development in this direction in any meaningful way, so perhaps it's chicken and egg...  but as long as Lustre is released and developed primarily out of tree, I can't see this working.  Would it just be a "sync everything but still do releases" approach?  Is that viable?  Etc.

Thoughts appreciated.

- Patrick


________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Doug Oucharek <doucharek@cray.com>
Sent: Thursday, June 7, 2018 8:07:44 AM
To: NeilBrown
Cc: Oleg Drokin; lustre-devel
Subject: Re: [lustre-devel] A new drivers/staging/lustre

What is the focus of landings in this tree?  There are two things needing to be done for an upstream Lustre:


  *   Get the source code to meet the Linux guidelines so it is acceptable to be in mainline.
  *   Get the binary product to have all the features and bug fixes that are in the Intel community tree so end users are interested in using the upstream version (users are unlikely to use a version of Lustre which is not current).

For the now-deleted staging area, we were supposed to be focusing on the first item but were submitting patches for the second item (syncing with Intel tree).  In my opinion, this is the core reason for never being able to get out of staging and getting deleted.

There are some very big (as in code size) features missing from upstream.  For example, Multi-Rail.  When should that be pushed relative to code cleanups?

Doug

On Jun 7, 2018, at 4:58 AM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

On Thu, Jun 07 2018, James Simmons wrote:

Greg's patch to remove lustre has now landed in this staging-next tree,
so I suspect it will get to Linus before too long.  So I have to find a
new place to work on lustre.

I've added 2 branches to
  git://git.neil.brown.name/linux

lustre:
  is based on Greg's patch that removes lustre, and starts with a
  revert of the patch, followed by a merge of v4.17.
  I plan to merge each release and RC from Linus, and also
  add lustre patches that I think are "ready".  That will usually mean
  they have been posted to this list at least a week earlier, and
  have not had a credible negative response (Acks and Reviewed-by
  would be nice).
  I plan to update this branch about once a week, and to never rebase
  it.

I know Oleg also started to play with a tree but I don't know if he can
keep it up like you can. I added the parties interested so they can bless
this tree if they want. Mainly Oleg wanted to see what breaks when moving
to fs directory and the proper UAPI headers directory as well.

I'm certainly happy to contribute to a different tree instead, if
someone else is working towards getting lustre code suitable for
upstream.  I created a tree myself because I find that saying "we should"
is not nearly as effective as saying "I have".


Please be patience with me. I normally do this work on the weekend. I put
it into my test bed and try it out. Getting reviews can at times be
challenging to get. Hopefully people at Cray and Intel are willing to
step in for this as well. Patrick from Cray has been most helpful.

lustre-testing:
  is based on 'lustre' and has most of my current lustre-related work.
  It includes assorted patches that are not specifically for lustre
  (rhashtables mostly at the moment).  Patches will move from here
  to 'lustre' or to mainline when they are ready.
  I plan to update this branch on most days that I work on Lustre,
  and expect it to rebase frequently.

I had question about that. Some things in Lustre could in theory be merged
into the linux kernel proper. Can that be done still?

What things?

If it measurably benefits the kernel proper, then I suspect it might be
worth submitting.  Things can go direct without going though staging -
they just have to be of good quality with good justification (and
sometimes lots of patience).


I'm happy to review and, if acceptable, apply patches from other
developers.  I have fairly high standards, but if I don't accept your
patch I'll explain why and possible help fix it.

Also long as you talk to me :-) I'm an easy person to work with. If I
refuse a patch with do the same. I might sometimes seem irrational
but I have valid reasons. Well at least in my head.

We need to really layout the roadmap.

I have very little faith in road maps - I prefer to make steps.  Once we
have made all the steps, we can look back and see what the map looked
like in retrospect.

The most I'm interested in is "client first, then server".
But feel free to propose something - it is helps you then it could be
useful.


I'm happy to accept enhancements and new features, but these need
to be of a quality that would be accepted upstream.

Absolutely. This should be music to some peoples ears.

I'm only interested in client-side code at present - nothing that is
only used on the server.  I do want to include server-side eventually,
but I need some focus for now.

Make sense. Anyways the backend file systems used are ldiskfs which is
a heavily modified ext4 filesystem and ZFS on the server side. I doubt
the kernel would accept ZFS backend suppport and the changes Lustre
does to ext4 have been mostly merged but a few pieces are missing.
So pushing the server code at this point wouldn't benefit us.

I hope to get to a stage where the code is of suitable quality that I
can submit it to Linux as a new filesystem.  I hope that will happen
this year.

Are you thinking going back into staging or straight to the fs tree

Greg has said he doesn't want it in staging.  So no, I'm not thinking of
anything going to staging.  I'm thinking of getting enough of a client
in reasonable shape that people can review it without feeling sick or
getting angry.

Thanks,
NeilBrown



I hope we can continue to work together to make all this happen.
(That's enough hope for now, time to get back to code).
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180607/8f0662bb/attachment-0001.html>
