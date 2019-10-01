From: NeilBrown <neilb@suse.de>
Date: Tue, 01 Oct 2019 17:01:15 +1000
Subject: [lustre-devel] [PATCH 000/151] lustre: update to 2.11 support
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87imp96jb8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 30 2019, James Simmons wrote:

> This patchset covers 3 areas. The fix 6 patches resolves critical
> bugs in the linux client. Mainly for handling of LNet with secondary
> IP aliases as well as an RCU issue reported with debugging enabled.
> This consoldation of IP handling makes any kernel API changes in the
> future easier to handle.
>
> The last 9 patches cover patches in the lustre-testing that landed
> to the OpenSFS branch.
>
> The rest of the patches cover all the patches missing from the
> Lustre 2.11 release. I have done extentsive testing of these
> patches (sanity, sanity-pfl, sanity-dom, sanity-pfl). Only
> regression I saw was sanity-flr 200 which needs to be investiaged.
> So we are in very good shape.

Thanks a lot for these James!
Though I only received up to 133/151 - are 18 missing, or was there a
miscount??

I've applied them on top of my "lustre" branch, then rebased everything
in my lustre-testing and lustre-backports (upto about 2.12.2) branches
on top of that - and checked that it all compiles.
I fixed the issues that I mentioned separately that I found in a few of
your patches, and also a couple of issues that I found in some of mine
(it is *so* helpful having two people working on this, we can catch each
others slip-ups).

I've pushed it all to github on a branch "lustre/lustre-XX" because I
couldn't think of a good name.
I'll review the differences between it and lustre-backport, and then
probably rename lustre-XX to lustre-backport - after I find out the
story about those missing 18 patches.

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191001/9fe18df8/attachment.sig>
