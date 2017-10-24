From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Oct 2017 09:35:48 +1100
Subject: [lustre-devel] [PATCH 0/6] dcache/namei fixes for lustre
In-Reply-To: <alpine.LFD.2.20.1710240229440.24440@casper.infradead.org>
References: <150164273003.13199.7841976922211510658.stgit@noble>
 <alpine.LFD.2.20.1708200354030.5810@casper.infradead.org>
 <87k1zqfy95.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.20.1710240229440.24440@casper.infradead.org>
Message-ID: <87a80gdvi3.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Oct 24 2017, James Simmons wrote:

>> >> This series is a revised version of two patches I sent
>> >> previously (one of which was sadly broken).
>> >> That patch has been broken into multiple parts for easy
>> >> review.  The other is included unchanged as the last of
>> >> this series.
>> >> 
>> >> I was drawn to look at this code due to the tests on
>> >> DCACHE_DISCONNECTED which are often wrong, and it turns out
>> >> they are used wrongly in lustre too.  Fixing one led to some
>> >> clean-up.  Fixing the other is straight forward.
>> >> 
>> >> A particular change here from the previous posting is
>> >> the first patch which tests for DCACHE_PAR_LOOKUP in ll_dcompare().
>> >> Without this patch, two threads can be looking up the same
>> >> name in a given directory in parallel.  This parallelism lead
>> >> to my concerns about needing improved locking in ll_splice_alias().
>> >> Instead of improving the locking, I now avoid the need for it
>> >> by fixing ll_dcompare.
>> >> 
>> >> This code passes basic "smoke tests".
>> >> 
>> >> Note that the cast to "struct dentry *" in the first patch is because
>> >> we have a "const struct dentry *" but d_in_lookup() requires a
>> >> pointer to a non-const structure.  I'll send a separate patch to
>> >> change d_in_lookup().
>> >
>> > To let you know this patch has been under going testing and we have a
>> > ticket open to track the progess:
>> >
>> > https://jira.hpdd.intel.com/browse/LU-9868
>> >
>> > Your patch did reveal that a piece of a fix landed earlier is missing :-(
>> > So currently the client can oops. I will send the fix shortly but this
>> > work will have to rebased after. As soon as we can get some cycles we will
>> > figure out what is going on. Thanks for helping out.
>> 
>> Hi,
>>  what happened about this?  I had a look around the ticket and couldn't
>>  find anything about an oops.  If there is still a problem I'd be very
>>  happy to help work out what it is - but I don't know where to look.
>
> The oops is specific to the in kernel client. Some where along the way the
> calls to ll_d_init() were removed from ll_splice_alias(). It was unnoticed
> until your patch came along. I do have a fix that I will be pushing to 
> the next staging tree very shortly.

ll_d_init() doesn't need to be called from anywhere.  It is called by
__d_alloc (dentry->d_op->d_init) whenever a dentry is allocated.  That
is all that is needed.

>
> I have been testing the patch series and for me I don't see any issue. Our 
> test suite is reporting failures with this patch which I'm attempting to 
> figure out how to reproduce locally on my test system. Once I have a 
> reproducer I can send it to you. 

Can I see the failure report?  Or the oops?

I cannot find anything at the jira.hpdd.intel.com link you gave, or the
review.whamcloud.com that is linked from there.
Maybe it is behind testing.hpdd.intel.com that I need a login for (I've
registered and am waiting) ....


Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171025/34fdaf47/attachment.sig>
