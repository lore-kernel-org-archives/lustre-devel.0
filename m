From: NeilBrown <neilb@suse.com>
Date: Fri, 20 Oct 2017 11:39:50 +1100
Subject: [lustre-devel] [PATCH 0/6] dcache/namei fixes for lustre
In-Reply-To: <alpine.LFD.2.20.1708200354030.5810@casper.infradead.org>
References: <150164273003.13199.7841976922211510658.stgit@noble>
 <alpine.LFD.2.20.1708200354030.5810@casper.infradead.org>
Message-ID: <87k1zqfy95.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Aug 20 2017, James Simmons wrote:

>> This series is a revised version of two patches I sent
>> previously (one of which was sadly broken).
>> That patch has been broken into multiple parts for easy
>> review.  The other is included unchanged as the last of
>> this series.
>> 
>> I was drawn to look at this code due to the tests on
>> DCACHE_DISCONNECTED which are often wrong, and it turns out
>> they are used wrongly in lustre too.  Fixing one led to some
>> clean-up.  Fixing the other is straight forward.
>> 
>> A particular change here from the previous posting is
>> the first patch which tests for DCACHE_PAR_LOOKUP in ll_dcompare().
>> Without this patch, two threads can be looking up the same
>> name in a given directory in parallel.  This parallelism lead
>> to my concerns about needing improved locking in ll_splice_alias().
>> Instead of improving the locking, I now avoid the need for it
>> by fixing ll_dcompare.
>> 
>> This code passes basic "smoke tests".
>> 
>> Note that the cast to "struct dentry *" in the first patch is because
>> we have a "const struct dentry *" but d_in_lookup() requires a
>> pointer to a non-const structure.  I'll send a separate patch to
>> change d_in_lookup().
>
> To let you know this patch has been under going testing and we have a
> ticket open to track the progess:
>
> https://jira.hpdd.intel.com/browse/LU-9868
>
> Your patch did reveal that a piece of a fix landed earlier is missing :-(
> So currently the client can oops. I will send the fix shortly but this
> work will have to rebased after. As soon as we can get some cycles we will
> figure out what is going on. Thanks for helping out.

Hi,
 what happened about this?  I had a look around the ticket and couldn't
 find anything about an oops.  If there is still a problem I'd be very
 happy to help work out what it is - but I don't know where to look.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171020/cf8c2e9e/attachment.sig>
