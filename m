From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Mon, 11 Feb 2008 15:59:06 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47ACC71C.7050808@sun.com>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
Message-ID: <47B062BA.1070809@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
> 5.1 external storage list - is this to be stored on the MGS device or a 
> separate device?  If the coordinator lives on the MGS, why not it's 
> storage as well?  In any case, it should be possible to co-locate the 
> coordinator on the MGS and used the MGS's storage device, in the same 
> way that the MGS can currently co-locate with the MDT.
> How does the coordinator request activity from an agent?  If the 
> coordinator is the RPC server, then it's up to the agents to make 
> requests; agents aren't listening for RPC requests themselves.

Presently, it is never said that the coordinator will live on the MGS.
The Coordinator constrains are:
  1 - Must receive various migration requests from OST/MDT.
  2 - Should be able to communicate with Agents and asks them migrations.
  3 - Should store configuration and migration logs.

I think #1 and #2 are two differents API. The coordinator is clearly a 
RPC server for the first one. How #2 should be implemented is not so 
clear. What would be be the "Lustre-way" here?

For #3, the few logs that will be backed up here are not huge, and it 
surely could be colocated with another Target, but I'm not sure this 
should be mandatory. This device should be available to several servers, 
for failover like the other Targets. We could imagine having more than 1 
coordinator at long term. I'm not sure it is a good idea to stick it to 
another target.

> 6.3 object ref should include version number.  Also include checksum?

For data coherency? Should we add a explicit checksum for those values 
(stored in an EA) or used a possible backend feature (Can ZFS and 
ldiskfs detect EA value corruption by themselves?) ?

> 2.1Archiving one Lustre file
> There should not be a cache miss when archiving a lustre file; perhaps 
> open-by-fid is intended to bypass atime updates
> so that the file isn't marked as "recently accessed"?
 > Transparent access - should this avoid modification of atime/mtime?

I would say yes.

> 2.2Restoring a file
> "External ID" presumably contains all information required to retrieve 
> the file - tape #, path name, etc?
> Once file is copied back, we should probably restore original ctime, 
> mtime, atime - coordinator is storing this, correct?

External ID is an opaque value manage by the archiving tool. If the HSM 
can store a lot of metadata, only a ref is needed, if not, the tool is 
responsible for storing all the data it needs. Anyway, this is totally 
opaque for Lustre.
I hope the HSMs will not need so many data in this field. HPSS does not 
need so many data, it uses its internal DB to store them. I suppose SAM 
also.

> IV2 - why not multiple purged windows?  Seems like if you're going to 
> purge 1 object out of a file, you might want to purge more.
> Specifically, it will probably be a common case to purge every object of 
> a file from a particular OST.  This is not contiguous in a
> striped file.
> I don't see any reason to purge anything smaller than an entire object 
> on an OST - is there good reason for this? 

Multiple purged window is subtle. If you permit this feature, you could 
technically have, in the worst case, one purged window per byte, and 
this could be very huge to store. Do you think you will do several holes 
in the same file? In which cases?
In fact, the more common case is to totally purge a file which have been 
  migrated on HSM, and it is only an optimisation to keep the start and 
the end of the file on disk, to avoid triggering tons of cache misses 
with commands like "file foo/*" or a tool like Nautilus or Windows 
Explorer browsing the directory.
The purged window is stored by per object, OST object and MDT object.
So, if several objects are purged, each object will store its own purged 
window. But the MDT object describing this file will store a special 
purged window which starts at the smallest unavailable bytes and ends at 
the first available one. The MDT purged window indicates "if you do I/O 
in this range, you're not sure the date are there." or "Outside of this 
area, I guarantee data are present."
Maintain multiple purged windows will be an headache, with no real need 
I think.
Moreover, people have asked for an OST-object based migration, even if I 
think whole file migration will be the most common case.


 > If that's the case, then it
> the OST must keep track of purged objects, not ranges within an existing 
> object.

Objects are not removed, only their datas. All metadata are kept.

> If the MDT is tracking purged areas also, then there's a good potential 
> synergy here with a missing OST --
> If the missing OST's objects are marked as purged, then we can 
> potentially recover them automatically from
> HSM...

What do you call a "missing OST" ? A corrupt one ? A offline one? 
Unavailable?
Where will you copy back the object data ? On another OST object ?
With the purged window on each OST object and MDT and the file stripping 
info, we could easily restore the missing parts.

> 4.2 How is a purge request recovered?  For example, MDT says purge obj1 
> from ost1, ost1 replies "ok", but then dies before it actually
> does the purge.  Reboots, doesn't know anything about purge request now, 
> but MDT has marked it as purged.

The OST asynchronously acknowledges the purge when it is done. The MDT 
marks it purged only when it is really done. I will clarify this.

> V2.1 How long does OST wait for completion?  Is there a timeout?    We 
> probably need a "no timeout if progress is being
> made" kind of function - clients currently do this kind of thing with OSTs.

I'm sure Lustre already has similar mechanisms for optimized timeout in 
this kind of situation we could reused here.
What you describe is a good approach I think.

> V2.2 No need to copy-in purged data on full-object-size writes.

True. We could had such optimization. But this is only useful for small 
files or very widely stripped ones, doesn't it?


Thanks for your comments.

-- 
Aurelien Degremont
CEA
