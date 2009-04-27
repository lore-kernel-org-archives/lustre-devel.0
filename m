From: Andreas Dilger <adilger@sun.com>
Date: Mon, 27 Apr 2009 15:27:14 -0600
Subject: [Lustre-devel] CMD + OST FID range mapping
In-Reply-To: <49F56A52.4030808@sun.com>
References: <200904250507.n3P57ttg021967@lustre.sun.com>
	<20090427081443.GE3209@webber.adilger.int> <49F56A52.4030808@sun.com>
Message-ID: <20090427212714.GF3209@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 27, 2009  12:18 +0400, Alex Zhuravlev wrote:
> btw, I looked at interoperability page on the wiki, but haven't understood
> exact encoding of group:objid in fid structure. could you explain it, please?

It isn't documented on the wiki yet.  My proposal is for FID-on-OST to
pass the 64-bit SEQ number in the 64-bit o_gr field (similar to how we
pass the MDS number there today), the main difference being that the
SEQ number is a proper sequence number and assigned to a specific MDT-OST
pair instead of being the same MDT index on all OSTs.  Since FID-on-OST
is only needed for CMD we do not need to implement this immediately.
For existing objects we would use the l_ost_idx + l_object_id

Likely, we would assign a large range of SEQ numbers to each OST, and
then sub-assign those to the MDTs as needed (exactly the way MDTs assign
individual SEQ numbers to clients) so that the FLDB remains contiguous
for the majority of uses.

Note there isn't a big problem with migrating SEQ numbers between OSTs
because these numbers are not exposed to userspace in any manner that
requires them to remain constant (unlink filesystem inode numbers and
tar/nfs/etc).  That means for normal file migrations/rebalancing we
can just assign new object numbers during the migration and rewrite the
LOV EA layout.

If we are doing whole-OST content migration we could consider copying
the objects and migrating entire sequence numbers, but Eric pointed out
to me we would likely want to do space balancing at that point anyways,
so it might make sense to always just allocate new OST objects for
any migration.  We don't need to scan the filesystem to find the files
referencing these objects, because the OST objects contain backpointers
to the inodes that they are part of.

For on-the-wire usage, we can keep the OID in the low 32 bits of the
obdo.o_id field, and the high 32-bit of the obdo.o_id is the VER field
from the FID.  That said, since we would need to special-case the
seq/oid/ver mapping to the lock resource ids for "FID" vs "IDIF" values,
it could go either way.

For existing objects (group == 0) we can use the l_ost_idx + l_object_id
to locate it (as stored in the lov_mds_md today) and treat o_gr == 0
specially to indicate an IDIF OST FID, just as the MDT treats IGIF FIDs
differently when generating a lock resource value to maintain compatibility.

There is also the unused l_ost_gen for each OST object in the LOV EA which
could be used to distinguish the "ver" field of the FID if we wanted it
to remain separate from the o_id on disk.


In summary for objects (note VER is flexible and could fit in a few
places until we had an obdo_v2 and/or LOV_V4 that held a proper FID):

		SEQ				OID		VER
lu_fid:		seq:64				oid:32		ver:32
IDIF:		seq:31 1: ost_idx:16 o_id_hi:16	o_id_lo:32	0:
obdo (wire):	o_gr:64				o_id:32		o_id:32_hi
LOVEA(disk):	o_gr:64				o_id:32		o_id:32_hi

The IDIF would only be used if we need to represent an old objid as a FID
(e.g. if we exported it for an OST changelog, or in a obdo_v2 or LOV_V4).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
