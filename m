From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Fri, 08 Feb 2008 13:18:20 -0800
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47AAE307.9040305@cea.fr>
References: <47AAE307.9040305@cea.fr>
Message-ID: <47ACC71C.7050808@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

DEGREMONT Aurelien wrote:
> Hello
>
> Here is a first draft for comments of the Lustre HSM HLD.
> It is intended to be a support for further analyzes and comments from
> CFS/Sun.
>
> The document covers the main parts of the HSM features but some elements
> are still lacking.
> The policy management and the space manager will be describe later.
>
> Let us know your comments and ideas about it.
>
> Regards,
5.1 external storage list - is this to be stored on the MGS device or a 
separate device?  If the coordinator lives on the MGS, why not it's 
storage as well?  In any case, it should be possible to co-locate the 
coordinator on the MGS and used the MGS's storage device, in the same 
way that the MGS can currently co-locate with the MDT.

6.3 object ref should include version number.  Also include checksum?

How does the coordinator request activity from an agent?  If the 
coordinator is the RPC server, then it's up to the agents to make 
requests; agents aren't listening for RPC requests themselves.

2.1Archiving one Lustre file
There should not be a cache miss when archiving a lustre file; perhaps 
open-by-fid is intended to bypass atime updates
so that the file isn't marked as "recently accessed"?
2.2Restoring a file
"External ID" presumably contains all information required to retrieve 
the file - tape #, path name, etc?
Once file is copied back, we should probably restore original ctime, 
mtime, atime - coordinator is storing this, correct?

IV2 - why not multiple purged windows?  Seems like if you're going to 
purge 1 object out of a file, you might want to purge more.
Specifically, it will probably be a common case to purge every object of 
a file from a particular OST.  This is not contiguous in a
striped file.
I don't see any reason to purge anything smaller than an entire object 
on an OST - is there good reason for this? 
If that's the case, then it the OST must keep track of purged objects, 
not ranges within an existing object.
If the MDT is tracking purged areas also, then there's a good potential 
synergy here with a missing OST --
If the missing OST's objects are marked as purged, then we can 
potentially recover them automatically from
HSM...

4.2 How is a purge request recovered?  For example, MDT says purge obj1 
from ost1, ost1 replies "ok", but then dies before it actually
does the purge.  Reboots, doesn't know anything about purge request now, 
but MDT has marked it as purged. 


Transparent access - should this avoid modification of atime/mtime?
V2.1 How long does OST wait for completion?  Is there a timeout?    We 
probably need a "no timeout if progress is being
made" kind of function - clients currently do this kind of thing with OSTs.
V2.2 No need to copy-in purged data on full-object-size writes.


  Page 13, Lustre object mtime may not be good enough. There are several
        mechanisms (like touch) to manipulate mtime, which makes it
        unusable as a last written time.
  If a user make a touch in the past this change the mtime and can hide 
previous writes.
  If we want to keep real write time we need to add a new time field in 
Lustre backend
  (may be ZFS has it)
If a user touches or otherwise modifies the mtime on purpose, they
presumably know what they are doing.  Besides, we're using the
object version number, not the mtime, to determine whether a file
is up to date.  I think this can be ignored.
