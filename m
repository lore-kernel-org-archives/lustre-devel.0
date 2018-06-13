From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Jun 2018 08:31:43 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <alpine.LFD.2.21.1806132244190.12664@casper.infradead.org>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806120112530.15735@casper.infradead.org>
 <87lgbkkemm.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806132244190.12664@casper.infradead.org>
Message-ID: <87efhaiai8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 13 2018, James Simmons wrote:

>> 
>> >> Greg's patch to remove lustre has now landed in this staging-next tree,
>> >> so I suspect it will get to Linus before too long.  So I have to find a
>> >> new place to work on lustre.
>> >> 
>> >> I've added 2 branches to
>> >>    git://git.neil.brown.name/linux
>> >
>> > Its seems to be down. Do you plan to move the tree somewhere else. Perhaps
>> > your github page?
>> 
>> Bother - that's what you get for using Linux to host things (my VM
>> doesn't have heaps of memory and git likes to use a lot, and doesn't
>> always clean up well after itself).
>> 
>> git.neil.brown.name is back, and github.com/neilbrown/linux now
>> has two new branches: lustre/lutre and lustre/lustre-testing
>
> It lives!!! Trying to grab the tree from git.neil.brown.name and still 
> chokes but the github tree works works like a charm. I built and tested
> the tree and it works.

I guess I'm going to have to deprecate using neil.brown.name for git, or
else arrange for a lot more memory. linux.git is getting too big.
It probably works OK if you "git clone --reference=/some/local/linux/tree/.git"
but people don't think to do that.
I'll make sure to keep github up to date.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180614/11f91e72/attachment.sig>
