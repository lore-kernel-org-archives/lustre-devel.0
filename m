From: Yong Fan <Yong.Fan@Sun.COM>
Date: Fri, 25 Jul 2008 12:34:52 +0800
Subject: [Lustre-devel] statahead feature
In-Reply-To: <4888573F.4010506@sun.com>
References: <4888573F.4010506@sun.com>
Message-ID: <488957EC.1040701@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev ??:
> Hi,
>
> due to some experiments with dcache related code we've been doing with 
> shadow
> and others, it became clear that statahead code is quite complicated. 
> probably
> for no reason. the most hard part to follow is interaction with 
> dcache. the
> feature does number of complex things and make other parts (like 
> ll_lookup_it())
> harder to follow too.
>
> after amount of discussions with people we'd like to share our vision 
> on the
> feature and propose slightly different solution.
>
> we think statahead should do nothing with dcache. it's about inodes 
> and attributes
> only. thus, it would be good to decouple it from dcache. the only 
> thing statahead
> should do is:
> 1) detect statahead is needed (policy, out of the message's scope)
> 2) scan part of directory (probably using readdir(), skip RPCs)
> 3) finds/creates inodes for found fids
> 4) lock these inodes (notice we propose to use inodes as a 
> serialization point
> so that lockless getattr can be used)
> 5) issue getattr RPCs (probably lockless)
> 6) unlock inodes upon getattr's completion
>
> then stat(2) is called, it first has to lookup fid by name. for this 
> we can use
> pagecache just filled with MDS_READDIR. if directory isn't being 
> modified at the
> time, then entries will be there and we can create dentries in the 
> dcache. they
> will be valid till UPDATE lock is cancelled - no even LOOKUP lock is 
> needed.
>
>
> another possible thing for optimization is lockless getattr. given 
> most of supported
> kernel don't pass intent to ->getattr(), it's possible that stat(2) 
> needs two RPCs:
> one in ll_lookup_it() and another in ll_getattr_it() as lock is 
> released between them.
> stat(2) gives no warranty about attributes, it gives a shot of them. 
> attributes can
> change right before userspace application get them. so, why don't we 
> introduce some
> simple mechanism making attributes valid for short time at least for 
> process executed
> lookup. this could help statahead as well, we think.
Lockless getattr RPC for "ls -l" is a good idea. But whether all the 
getattr RPC will be lockless or not?
If not, how to distinguish them from "stat(2)" case? by intent or 
something else?
Statahead is based on forecast, it maybe wrong. We should guarantee the 
proper lock(s) is held even
if the statahead is wrong.

Another optimization (maybe) to be considered is that whether it is 
necessary to start one statahead thread
for each "ls -l" operation or not? As said by Nikita, maybe we can use a 
single thread for all the statahead.


Thanks!
--
Fan Yong
>
> comments? suggestions?
>
> thanks, Alex
>
