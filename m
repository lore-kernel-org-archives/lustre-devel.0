From: Alex Zhuravlev <bzzz@sun.com>
Date: Mon, 06 Apr 2009 14:26:40 +0400
Subject: [Lustre-devel] [RFC] two ideas for Meta Data Write Back Cache
In-Reply-To: <20090406100345.GO3199@webber.adilger.int>
References: <200904061339.02850.alexander.zarochentsev@sun.com>
	<20090406100345.GO3199@webber.adilger.int>
Message-ID: <m3zleu5b8f.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> Andreas Dilger (AD) writes:

 AD> My internal thoughts (in the absence of ever haven taken a close look
 AD> at the HEAD MD stack) have always been that we would essentially be
 AD> moving the CMM to the client, and have it always connect to remote
 AD> MDTs (i.e. no local MDD) if we want to split "operations" into "updates".

 AD> I'd always visualized that the MDT accepts "operations" (as it does
 AD> today) and CMM is the component that decides what parts of the operation
 AD> are local (passed to MDD) and which are remote (passed to MDC).

few thoughts here:
1) in order to organize local cache with all this you'd need to do translate
   once more before md stack (you can't cache create, you can cache directory
   entries and objects). at same time you need local cache to access just made
   changes. translation is already done by MDD. if you don't run MDD locally
   you have to duplicate that code (to some extent) for WBC

2) "create w/o name" (this is what MDT accepts these days) isn't operation,
   it's partial operation. but for partial operations we already have OSD
   - clear, simple and generic. having one more "partial operations" adds
   nothing besides confusion, IMHO

3) local MDD is meaningless with CMD. CMD is distributed thing and I think
   any implementation of CMD using "metadata operations" (even partial,
   in contrast with updates in terms of OSD API) is a hack. exactly like we
   did in CMD1/CMD2 implementing local operations with calls to vfs_create()
   and distributed operations with special entries in fsfilt. instead of all
   this we should just use OSD always and properly.

4) the only rational reason behind current design in CMD3 was that rollback
   reqiured to make remote operations before any local one (to align epoch)
   - but it's very likely we don't this any more. thanks god (some ones will
   understand what i meant ;)

5) running MDD on MDS for WBC clients also adds nothing in terms of functionality
   or clearness, but adds code duplicating OSD

 >> are already used between MD servers for distributed MD operations. MD 
 >> operations will be packed into batches.
 >> 
 >> Both ideas (GOSD and CMD3+) assume a cache manager at WBC client to do 
 >> caching & redo-logging of operations.
 >> 
 >> I think CMD3+ has minimum impact to current Lustre-2.x design. It is 
 >> closer to the original goal of just implementation of WBC feature. But 
 >> the GOSD is an attractive idea and may be potentially better.
 >> 
 >> With GOSD I am worrying about making Lustre 2.x unstable for some period 
 >> of time. It would be good to think about a plan of incremental 
 >> integration of new stack into existing code.

 AD> Wouldn't GOSD just end up being a new ptlrpc interface that exports the
 AD> OSD protocol to the network?  This would mean that we need to be able
 AD> to have multiple services working on the same OSD (both MDD for classic
 AD> clients, and GOSD for WBC clients).  That isn't a terrible idea, because
 AD> we have also discussed having both MDT and OST exports of the same OSD
 AD> so that we can efficiently store small files directly on the MDT and/or
 AD> scale the number of MDTs == OSTs for massive metadata performance.

yes, with gosd you essentially have your object storage exported in terms
of same API as local storage. you can use that to implement remote services
(proxy, wbc).

 AD> I'd like to keep this kind of layering in mind also.  Whether it makes
 AD> sense to export yet another network protocol to clients, or instead to
 AD> add new operations to the existing service handlers so that they can
 AD> handle all of the operation types (with efficient passthrough to lower
 AD> layers as needed) and be able to multiplex the underlying device
 AD> to clients.

I think it's not "another" network protocol. I think it's right low level
protocol.  meaning that instead of having very limited set of partial metadata
operations like "create w/o name", "link w/o inode", etc we may have very
simple, generic protocol allowing us to do anything with remote storage.

for example, the core of replication with this protocol could look like
at one node you log osd operations (optional module inbetween regular disk osd
and upper layers like mdd), then you just send those operations to virtially
any node in the cluster and execute them there - you got things replicated.


-- 
thanks, Alex
