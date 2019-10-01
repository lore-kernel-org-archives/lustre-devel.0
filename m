From: James Simmons <jsimmons@infradead.org>
Date: Tue, 1 Oct 2019 19:07:48 +0100 (BST)
Subject: [lustre-devel] [PATCH 000/151] lustre: update to 2.11 support
In-Reply-To: <87imp96jb8.fsf@notabene.neil.brown.name>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <87imp96jb8.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1910011904390.15141@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > This patchset covers 3 areas. The fix 6 patches resolves critical
> > bugs in the linux client. Mainly for handling of LNet with secondary
> > IP aliases as well as an RCU issue reported with debugging enabled.
> > This consoldation of IP handling makes any kernel API changes in the
> > future easier to handle.
> >
> > The last 9 patches cover patches in the lustre-testing that landed
> > to the OpenSFS branch.
> >
> > The rest of the patches cover all the patches missing from the
> > Lustre 2.11 release. I have done extentsive testing of these
> > patches (sanity, sanity-pfl, sanity-dom, sanity-pfl). Only
> > regression I saw was sanity-flr 200 which needs to be investiaged.
> > So we are in very good shape.
> 
> Thanks a lot for these James!
> Though I only received up to 133/151 - are 18 missing, or was there a
> miscount??

Their should be 151 patches. I have had this problem of patches not making
it to my mailbox. That is why I have:

https://patchwork.kernel.org/project/lustre-devel/list

All the patches are there.
 
> I've applied them on top of my "lustre" branch, then rebased everything
> in my lustre-testing and lustre-backports (upto about 2.12.2) branches
> on top of that - and checked that it all compiles.
> I fixed the issues that I mentioned separately that I found in a few of
> your patches, and also a couple of issues that I found in some of mine
> (it is *so* helpful having two people working on this, we can catch each
> others slip-ups).

Yes more eyes are always better :-) Thanks for starting the process!!!

> I've pushed it all to github on a branch "lustre/lustre-XX" because I
> couldn't think of a good name.
> I'll review the differences between it and lustre-backport, and then
> probably rename lustre-XX to lustre-backport - after I find out the
> story about those missing 18 patches.
> 
> Thanks,
> NeilBrown
> 
> 
