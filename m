From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Fri, 15 Feb 2008 20:50:27 +0300
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B335B6.5010703@sun.com>
References: <47B335B6.5010703@sun.com>
Message-ID: <200802152050.28398.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

On 13 February 2008 21:23:50 Nathaniel Rutman wrote:
> The design of various new features in Lustre call for global
> (filesystem wide) databases, accessible from
> clients or other servers:
> A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool
> policies (all .jpg files to pool #1)
> B. filesets - fileset policies (log creates on fileset #1 to feed
> "foo") C. HSM - (aureleien - what was the use case here?)
>
> We've already implemented at least 2 of these:
> D. Fid Location Database - (is this done?)
> E. configuration parameters - stored in MGS llogs

?ould be the same (file?) interface used for anything Lustre-specific 
under /proc? Anyway we need a /proc replacement for use-level lustre 
servers.

> Rather than continue 1-off implementations, I think it's time we came
> up with a consistent,
> global, generic database mechanism for A-C as well as other future
> uses. Needs to be:
> 1. Fast. We need to cache database entries locally, which also means
> having them under locks.
>     a. local caching
>     b. locks
> 2. Generic.  Store any kind of data, not limited to 8k page
> boundaries, etc. 3. Transactional.  Power loss doesn't lead to
> inconsistent state. 4. Recoverable. Client changes are replayed if
> need be.
> 5. Remotely accessible, from a client or other servers.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

Thanks,
Zam.
