From: Andreas Dilger <adilger@sun.com>
Date: Mon, 06 Apr 2009 04:03:45 -0600
Subject: [Lustre-devel] [RFC] two ideas for Meta Data Write Back Cache
In-Reply-To: <200904061339.02850.alexander.zarochentsev@sun.com>
References: <200904061339.02850.alexander.zarochentsev@sun.com>
Message-ID: <20090406100345.GO3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 06, 2009  13:39 +0400, Alexander Zarochentsev wrote:
> There are ideas about WBC client MD stack, WBC protocol and changes 
> needed at server side. They are Global OSD and another idea (let's name 
> it CMD3+) explained in the WBC HLD outline draft.
>  
> Brief descriptions of the ideas:
> 
> GOSD: 
> 
> a portable component (called MDS in Alex's presentation) transates MD 
> operations into OSD operations (updates).
> 
> MDS may be at client side (WBC-client), proxy server or MD server.
> 
> The MDS component is very similar to current MDD (Local MD server) layer 
> in CMD3 server stack. I.e. it works like a local MD server, but the OSD 
> layer below is not local, it is GOSD. 
> 
> It is simple as the local MD server and simplifies MD server stack a 
> lot. Current MD stack processes MD operations at any level of MDT, CMM 
> and MDD. First two levels should understand what is CMD and MDD layer 
> should understand that some MD operations can be partial. It sounds 
> like a unneeded complication. With GOSD those layers will be replaced 
> by only one as simple as MDD layer! (however LDLM locking should be 
> added).

My internal thoughts (in the absence of ever haven taken a close look
at the HEAD MD stack) have always been that we would essentially be
moving the CMM to the client, and have it always connect to remote
MDTs (i.e. no local MDD) if we want to split "operations" into "updates".

I'd always visualized that the MDT accepts "operations" (as it does
today) and CMM is the component that decides what parts of the operation
are local (passed to MDD) and which are remote (passed to MDC).

Maybe the MD stack layering isn't quite as clean as this?

> CMD3+:
> 
> The component running on WBC client is based on MDT excluding transport 
> things. Code reuse is possible.
> 
> The WBC protocol logically is the current MD protocol with the partial 
> MD operations (object create w/o name, for example). Partial operations 

partial operations == updates?

> are already used between MD servers for distributed MD operations. MD 
> operations will be packed into batches.
> 
> Both ideas (GOSD and CMD3+) assume a cache manager at WBC client to do 
> caching & redo-logging of operations.
> 
> I think CMD3+ has minimum impact to current Lustre-2.x design. It is 
> closer to the original goal of just implementation of WBC feature. But 
> the GOSD is an attractive idea and may be potentially better.
> 
> With GOSD I am worrying about making Lustre 2.x unstable for some period 
> of time. It would be good to think about a plan of incremental 
> integration of new stack into existing code.

Wouldn't GOSD just end up being a new ptlrpc interface that exports the
OSD protocol to the network?  This would mean that we need to be able
to have multiple services working on the same OSD (both MDD for classic
clients, and GOSD for WBC clients).  That isn't a terrible idea, because
we have also discussed having both MDT and OST exports of the same OSD
so that we can efficiently store small files directly on the MDT and/or
scale the number of MDTs == OSTs for massive metadata performance.

I'd like to keep this kind of layering in mind also.  Whether it makes
sense to export yet another network protocol to clients, or instead to
add new operations to the existing service handlers so that they can
handle all of the operation types (with efficient passthrough to lower
layers as needed) and be able to multiplex the underlying device
to clients.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
