From: Ben Evans <Ben.Evans@terascala.com>
Date: Tue, 19 Apr 2011 09:47:18 -0400
Subject: [Lustre-devel] MDS threading model?
In-Reply-To: <041F3601-F6F7-4F07-A22E-1E7AD4162542@whamcloud.com>
References: <2B947DB7-D404-4E77-B066-2FBCBBD90C0B@whamcloud.com><73AED5C780AE05478241DB067651A92102000E75@XYUS-EX22.xyus.xyratex.com><73AED5C780AE05478241DB067651A9210237844F@XYUS-EX22.xyus.xyratex.com>
	<041F3601-F6F7-4F07-A22E-1E7AD4162542@whamcloud.com>
Message-ID: <2C7DE72B9BD00F44BAECA5B0CBB8739501135AB2@hermes.terascala.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A couple of things regarding the Terascala work:

 

One is that the parent-dir lock change for file creates has been taken
care of in 2.1 using a much cleaner approach than I used.

 

I'd take a look at LU-170, but whamcloud's servers seem to be down for
me at the moment.  I'll try again later.

 

As to the OSTs, yes, more OSTs will solve the problem, but not every
installation has the budget for hundreds or thousands of OSTs, and I'd
like to see metadata performance be equal for everyone.   My current
understanding is that the OSTs start really hurting for performance when
an OST has around 32 objects (1 million files/dir) this fits very well
with ext issues (and ldiskfs) with very large numbers of files in a
directory.

 

From: lustre-devel-bounces@lists.lustre.org
[mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Liang Zhen
Sent: Tuesday, April 19, 2011 12:01 AM
To: Nathan Rutman
Cc: Alexander Zarochentsev; Nikita Danilov; Lustre Development Mailing
List
Subject: Re: [Lustre-devel] MDS threading model?

 

 

On Apr 19, 2011, at 6:41 AM, Nathan Rutman wrote:





Liang, 

we're happy to share all of our Lustre architecture and feature plans,
and I'm also optimistic about the way the community has really come
together at LUG.  

 

Our plans for metadata improvements had a bit of a different tack, but
it may be that with your SMP improvements there's not much more to be
gained in the MDS threading model. (We're actually going to detailed
investigation of your patches to see if it's worthwhile to spend more
effort here.)  We actually had two ideas for MDS threading improvements
- one was along your lines.  The other is a plan to move all the MDT
ldiskfs calls from each RPC off into a single queue, instead of making
the calls from separate threads.  The queue would be processed by a
single dedicated MDT thread.  If our investigation shows there's still a
lot of 

 

 

Personally, I think having a dedicated thread in MDT layer is not very
good for a few reasons:

- low layer MDD could send RPC, it's dangerous to have the single thread
sending RPC

- one single thread can be overloaded easily and be performance
bottleneck.

 

Actually I've tried with similar way months ago, the patch is in my
branch too(lustre/mdd/mdd_sched.c), although it's a little different:

- it's designed to drive any change operations to ldiskfs (handling
transactions), I called it "MDD transaction handler"

- just like other stack layer, each CPU partition has a requests queue,
and a small threads pool to process these requests, of course threads
number is much fewer then MDT service threads

- "MDD transaction handler" will only process creation/removal on my
branch, but it's very easy to expand to other operations.

 

Although testing results (I don't have those data anymore, but I still
can remember those graphs) shows that we gained somehow improvements of
shared directory, but we got regression in other tests (i.e: many target
directory tests).

It's quite understandable that we see improvements of shared directory,
otherwise all hundreds or thousands of MDT threads can be serialized on
the single inode semaphore of the shared directory, which is very bad
and kill the performance, it's also understandable that we saw
regression of many target directories tests performance (i.e: uniq
directory of mdtest), the patch will add one more thread context switch
which increase overhead & latency, and overall more threads on runq,
which is bad for system performance. 

 

So I did some changes to the patch a few months ago: only deliver high
contention operations (on parent directory) to MDD transaction
schedulers, by adding a small LRU cache on each CPU partition in MDD,
this will help on "many target directories" case. 

 

However, I will probably drop this idea totally for some reasons:

-  we already got enough threads on server, more threads will overkill
performance

-  it's hard to decide how many threads we should have in MDD (at least,
I'm sure one thread is not enough)

-  we have to be very careful to not send RPC in MDD threads because
it's unsafe

-  it conflicted with our other ongoing projects, and make code more
complex.

-  the most important reason is: it benefit us too little.

   . for shared directory case, pdirop patch in ldiskfs can help much
much more than this change (Fan Yong has already presented results on
LUG)

   . although I've made some efforts, but still, it will add some
regression to many target directories performance

 

based on these reasons, I might remove this patch from my branch soon.

 





improvement to be gained beyond your patches, we will probably start
working on a prototype for this to see if it helps.

 

Another interesting thing that came out of LUG here besides your
presentation was the Terascala work, which really highlighted for me
that not all metadata ops are created equal: create rates have a heavy
dependence on the OSTs, and that metadata ops performance isn't
necessarily a metadata server problem!  It wasn't clear to me if Oleg
was saying that they had resolved the OST precreate performance
limitations in Lustre 2.1 or if there is still more work to be done
there.  (One was a bug limiting the precreates to a small number (looks
like WC LU-170 <http://jira.whamcloud.com/browse/LU-170>  just landed
for 2.1?), the other is the large growth of directory entries in the
OST's 32 object dirs. (bugno?))

 

 

yes, the precreate patch has already been landed on 2.1.

32 object dirs could be issue if there is very few OSSs, however, I
think it's probably fine in big cluster with tens or hundreds of OSSs,
because MDS should almost always has enough precreated objects. Also, I
think if we have those "CPU partition" patches in my branch on OSS,  it
can provide good enough performance even we only have 32 object dirs,
although I agree 32 is a little low value. 

 

Regards

Liang

 





 

 

 

On Apr 15, 2011, at 2:21 AM, Nikita Danilov wrote:





Hi Nathan, Peter,

 

I received an interesting message from Liang Zhen, which he kindly
permitted me to share. The source is at
http://git.whamcloud.com/?p=fs%2Flustre-dev.git;a=shortlog;h=refs%2Fhead
s%2Fliang%2Fb_smp
<http://git.whamcloud.com/?p=fs/lustre-dev.git;a=shortlog;h=refs/heads/l
iang/b_smp> .

 

Thank you,

Nikita.

 

Begin forwarded message:





Hello Nikita,

How are you doing!
It's great to see Xyratex sharing this white paper:
http://www.xyratex.com/pdfs/whitepapers/Xyratex_white_paper_Lustre_Archi
tecture_Priorities_Overview_1-0.pdf

it makes me feel the community is stronger than ever, :-), I'm also very
interesting in the section " MDS threading model" in the white paper,
because I'm working a similar thing for a while, however, I can't see
too much detail from the white paper, would it be possible for you to
share the idea with me? I will totally understand if you can't, thanks
anyway.

Here is what I'm doing on server side threading model now, it's probably
totally different thing with what's in the white paper of Xyratex, but I
just want to make sure there is no rework, also, any suggestion would be
appreciated:
- divide server resource into several subsets at all stack level: CPUs,
memory pools, threads pools, message queues.....
- each subset is a processing unit which can process a request
standalone, unless there is conflict on target resource
- lifetime of request will be localized on the same processing unit as
possible as we can
- by this way, we can dramatically reduce data migration, thread
migration, lock contention between CPUs, and boost performance of
metadata request processing.
- as you can see from above, most server side threads are binding on a
few CPUs (not like before, no affinity except OST IO threads)
- massive number of threads will overkill performance, so limit total
number of threads is another key issue, and it's important to support
dynamically grow/shrink thread pool
- ptlrpc service will start more rational number of threads (not like
now, user can have thousands threads on MDS easily)
- we grow number of threads only if some threads in pool are
long-blocked
- ptlrpc service will kill some threads automatically if there are too
many active threads and they are not long-blocked.

Again, it's definitely OK if you can't share those information with me,
business is business, :-)

Thanks
Liang

 

 

______________________________________________________________________
This email may contain privileged or confidential information, which
should only be used for the purpose for which it was sent by Xyratex. No
further rights or licenses are granted to use such information. If you
are not the intended recipient of this message, please notify the sender
by return and delete it. You may not use, copy, disclose or rely on the
information contained in it.
 
Internet email is susceptible to data corruption, interception and
unauthorised amendment for which Xyratex does not accept liability.
While we have taken reasonable precautions to ensure that this email is
free of viruses, Xyratex does not accept liability for the presence of
any computer viruses in this email, nor for any losses caused as a
result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales,
Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in
Bermuda, Xyratex International Inc, registered in California, Xyratex
(Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co
Ltd registered in The People's Republic of China and Xyratex Japan
Limited registered in Japan.
______________________________________________________________________
 
 

 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110419/954f1b34/attachment.htm>
