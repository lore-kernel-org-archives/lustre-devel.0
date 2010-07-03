From: Dmitry Zogin <dmitry.zoguine@oracle.com>
Date: Fri, 02 Jul 2010 23:37:52 -0400
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <20100702222151.GG15407@oracle.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
	<4C2E57B0.6010408@oracle.com>
	<AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
	<20100702222151.GG15407@oracle.com>
Message-ID: <4C2EB090.5030003@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nicolas Williams wrote:
> On Fri, Jul 02, 2010 at 03:39:42PM -0600, Peter Braam wrote:
>   
>> On Fri, Jul 2, 2010 at 3:18 PM, Dmitry Zogin <dmitry.zoguine@oracle.com>wrote:
>> The post also mentions copy on write checkpoints, and their usefulness has
>> not been proven.  There has been no study about this, and certainly in many
>> cases they are implemented in such a way that bugs in the software can
>> corrupt them.  For example, most volume level copy on write schemes actually
>> copy the old data instead of leaving it in place, which is a vulnerability.
>>  Shadow copies are vulnerable to software bugs, things would get better if
>> there was something similar to page protection for disk blocks.
>>     
>
> Well-delineated transactions are certainly useful.  The reason: you can
> fsck each transaction discretely and incrementally.  That means that you
> know exactly how much work must be done to fsck a priori.  Sure, you
> still have to be confident that N correct transactions == correct
> filesystem, but that's much easier to be confident of than software
> correctness.  (It'd be interesting to apply theorem provers to theorems
> related to on-disk data formats!) 
>
> Another problem, incidentally, is software correctness on the read side.
> It's nice to know that no bugs on the write side will corrupt your
> filesystem, but read-side bugs that cause your data to be unavailable
> are not good either.  The distinction between bugs in the write vs. read
> sides is subtle: recovery from the latter is just a patch away, while
> recovery from the former might require long fscks, or even more manual
> intervention (e.g., writing a better fsck).
>
>   
>> I wrote this post because I'm unconvinced with the barrage of by now
>> endlessly repeated ideas like checkpoints, checksums etc, and the falsehood
>> of the claim that advanced file systems address these issues - they only
>> address some, and leave critical vulnerability.
>>     
>
> I do believe COW transactions + Merkel hash trees are _the_ key aspect
> of the solution.  Because only by making fscks incremental and discrete
> can we get a handle on the amount of time that must be spent waiting for
> fscks to complete.  Without incremental fscks there'd be no hope as
> storage capacity outstrips storage and compute bandwidth.
>
> If you believe that COW, transactional, Merkle trees are an
> anti-solution, or if you believe that they are only a tiny part of the
> solution, please argue that view.  Otherwise I think your use of
> "barrage" here is a bit over the top (nay, a lot over the top).  It's
> one thing to be missing a part of the solution, and it's another to be
> on the wrong track, or missing the largest part of the solution.
> Extraordinary claims and all that...
>   
Well, the hash trees certainly help to achieve data integrity, but at 
the performance cost.
Eventually, the file system becomes fragmented, and moving the data 
around implies more random seeks with Merkle hash trees.
> (And no, manually partitioning storage into discrete "filesystems",
> "filesets", "datasets", whatever, is not a solution; at most it's a
> bandaid.)
>
> Nico
>   

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100702/068ed9a3/attachment.htm>
