From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 7 Jun 2018 23:24:56 +0000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <MWHPR11MB2029D262448ACF23E0275C11D4640@MWHPR11MB2029.namprd11.prod.outlook.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <16129B94-CF52-4E5E-9A5A-2EC0E01BEEE0@intel.com>
 <MWHPR11MB2029D262448ACF23E0275C11D4640@MWHPR11MB2029.namprd11.prod.outlook.com>
Message-ID: <51E547E3-5876-4AE0-9226-FDE082213650@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 7, 2018, at 16:53, Doug Oucharek <doucharek@cray.com> wrote:
> 
> Does this mean we would be pushing patches to Gerrit rather than having to email them out?  I believe for the test system to work automatically, the answer is yes.

I'm not an expert with Gerrit configuration, so I'm not sure if there is an
email-to-change gateway plugin for it or not.  I believe it can be configured
to send the full patch in emails.  I get an email for every patch submitted,
but I configure it to only deliver the commit message and not the whole patch.

Since everyone is using Git anyway, using "git push" to submit patches to Gerrit
for review (and forwards them to the list, if that is what people want) isn't
more effort than "git send-email" to send them to the list directly.

I think any branch which just takes patches without adequate testing in a
variety of configurations (e.g. DNE, ZFS/ldiskfs, TCP/IB, quota, recovery,
version interop, failover, etc.) is just going to accumulate small or large
breakages and will not be usable in production.

James can probably tell you how many times "simple" patches were landed into
the upstream kernel that ended up breaking something because they weren't
tested.  I don't expect everyone to be able to test all of those configurations
themselves, which is why it is good to have automated testing to do this for
every patch that is submitted.

I'd be *thrilled* if more organizations/developers provided automated testing
of patches (e.g. PPC, ARM, Cray networking, etc.), so it isn't like I'm trying
to monopolize the testing (far from it).  However, the reality is that there
*is* no other automated testing environment beyond what we have with the
existing Jenkins/Gerrit/autotest/Maloo infrastructure we have today.  It is
imperfect for sure, but a gigantic leap beyond not having anything at all.

Cheers, Andreas

> From: Dilger, Andreas <andreas.dilger@intel.com>
> Sent: Thursday, June 7, 2018 5:46:26 PM
> To: NeilBrown
> Cc: lustre-devel
> Subject: Re: [lustre-devel] A new drivers/staging/lustre
>  
> On Jun 6, 2018, at 20:29, NeilBrown <neilb@suse.com> wrote:
> > Greg's patch to remove lustre has now landed in this staging-next tree,
> > so I suspect it will get to Linus before too long.  So I have to find a
> > new place to work on lustre.
> > 
> > I've added 2 branches to
> >   git://git.neil.brown.name/linux
> > 
> > lustre:
> >   is based on Greg's patch that removes lustre, and starts with a
> >   revert of the patch, followed by a merge of v4.17.
> >   I plan to merge each release and RC from Linus, and also
> >   add lustre patches that I think are "ready".  That will usually mean
> >   they have been posted to this list at least a week earlier, and
> >   have not had a credible negative response (Acks and Reviewed-by
> >   would be nice).
> >   I plan to update this branch about once a week, and to never rebase
> >   it.
> > 
> > lustre-testing:
> >   is based on 'lustre' and has most of my current lustre-related work.
> >   It includes assorted patches that are not specifically for lustre
> >   (rhashtables mostly at the moment).  Patches will move from here
> >   to 'lustre' or to mainline when they are ready.
> >   I plan to update this branch on most days that I work on Lustre,
> >   and expect it to rebase frequently.
> 
> We also have a clone of Greg's staging branch on our Gerrit server,
> which could be replaced with a "vanilla" upstream kernel clone that
> holds a copy of the for-upstream Lustre tree.
> 
> One benefit of hosting the tree on the Gerrit server is that it is
> much easier to get automated testing of the patches (a lot or a little)
> to ensure that the code doesn't break anything obvious.
> 
> > I'm happy to review and, if acceptable, apply patches from other
> > developers.  I have fairly high standards, but if I don't accept your
> > patch I'll explain why and possible help fix it.
> > I'm happy to accept enhancements and new features, but these need
> > to be of a quality that would be accepted upstream.
> > I'm only interested in client-side code at present - nothing that is
> > only used on the server.  I do want to include server-side eventually,
> > but I need some focus for now.
> > 
> > I hope to get to a stage where the code is of suitable quality that I
> > can submit it to Linux as a new filesystem.  I hope that will happen
> > this year.
> 
> I think one major drawback of starting with the from-staging version of
> the code is that this is significantly behind the out-of-tree master
> code and would need a lot of effort to catch up.
> 
> I think the only way we are going to make this work is if the cleanups
> go into the same repo as the ongoing development.  Otherwise, we'll be
> back in the same situation as we are now where there are two different
> versions of the code and we need to move patches back and forth between
> them.
> 
> On the plus side, this will avoid code drift, and the extra efforts of
> porting patches back and forth.  On the minus side, it means (on some
> fronts) that the code will regress from what is upstream, because we
> don't have all of the trivial whitespace cleanups and other drive-by
> kernel newbie patches that went into the upstream client.  However, it
> does mean that those cleanups would now become part of the single code
> tree and not be lost again in the future.
> 
> This would also mean some restructuring of the current Lustre tree so
> that it could build as a drop-in at linux/fs/lustre but that is probably
> a good idea for the long term in any case.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
> 
> 
> 
> 
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
