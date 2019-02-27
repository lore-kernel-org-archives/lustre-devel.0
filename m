From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Feb 2019 12:17:41 +1100
Subject: [lustre-devel] [PATCH 27/37] lustre: discard lu_ref
In-Reply-To: <alpine.LFD.2.21.1902242027340.1485@casper.infradead.org>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494627.24125.13508435808475179343.stgit@noble.brown>
 <alpine.LFD.2.21.1902242027340.1485@casper.infradead.org>
Message-ID: <87h8cqt4ga.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Feb 24 2019, James Simmons wrote:

>> struct lu_ref is always an empty structure, and the functions
>> which manipulate it do nothing.
>> So this is not being tested and so cannot be trusted.
>> So remove all these calls and field declarations.
>
> Or we can make lu_ref really work and always test with it :-)

We could ... though a lot of the code has been removed already, I was
just finishing the job.

How useful is this stuff?
Has it actually helped to find any bugs?
Does it do any run-time checks, or it is just
there to help you pull apart a crash-dump?

I think there is a real cost in having these extra linkages.  I'd like
to be clear what the benefit is.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190227/07a96103/attachment.sig>
