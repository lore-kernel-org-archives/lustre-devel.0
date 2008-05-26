From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 27 May 2008 07:28:10 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18490.63940.619731.992500@gargle.gargle.HOWL>
Message-ID: <C461688A.5460%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

[please send original message to Lustre devel also]

Hi 


On 5/27/08 1:56 AM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Johann Lombardi writes:
>> Hi all,
>> 
> 
> [...]
> 
>> 
>> * item #2: Supporting quotas with CMD
>> 
>> The quota master is the only one having a global overview of the quota usages
>> and limits. On b1_6, the quota master is the MDS and the quota slaves are the
>> OSSs. The code is designed in theory to support several MDT slaves too, but
>> some
>> shortcuts have been taken and some additional work is needed to support an
>> architecture with 1 quota master (one of the MDT) and several OSTs/MDTs
>> slaves.
> 
> From reading quota hld it is not clear that master has necessary be an
> mdt server. Given that ost's are going to have mdt-like recovery in 2.0
> it seems reasonable to hash uid/gid across all osts, that act as masters
> (additionally, it seems logical to handle disk block allocation on ost's
> rather than mdt's). Or am I missing something here?

Yes - and this being possible was part of the plan originally.


> 
>> 
>> * item #3: Supporting quotas with DMU
>> 
>> ZFS does not support standard Unix quotas. Instead, it relies on fileset
>> quotas.
>> This is a problem because Lustre quotas are set on a per-uid/gid basis.
>> To support ZFS, we are going to have to put OST objects in a dataset matching
>> a
>> dataset on the MDS.
>> We also have to decide what kind of quota interface we want to have at the
>> lustre level (do we still set quotas on uid/gid or do we switch to the
>> dataset
>> framework?). Things get more complicated if we want to support a MDS using
>> ldiskfs and OSSs using ZFS (do we have to support this?).
>> IMHO, in the future, Lustre will want to take advantage of the ZFS space
>> reservation feature and since this also relies on dataset, I think we should
>> adopt the ZFS quota framework at the lustre level too.
>> That being said, my understanding of ZFS quotas is limited to this webpage:
>> http://docs.huihoo.com/opensolaris/solaris-zfs-administration-guide/html/ch05
>> s06.html
>> and I haven't had the time to dig further.
> 
> As per discussion with ZFS team, they are going to implement per-user
> and per-group block quotas in ZFS (inode quotas make little sense for
> ZFS).

Why do they not need file quota - what if someone wants to control file
count?
 
> Going aside, if I were designing quota from the scratch right now, I
> would implement it completely inside of Lustre. All that is needed for
> such an implementation is a set of call-backs that local file-system
> invokes when it allocates/frees blocks (or inodes) for a given
> object. Lustre would use these call-backs to transactionally update
> local quota in its own format. That would save us a lot of hassle we
> have dealing with the changing kernel quota interfaces, uid re-mappings,
> and subtle differences between quota implementations on a different file
> systems.

======> IMPORTANT: get in touch with Jeff Bonwick now, let's get quota
implemented in this way in DMU then.
 
> Additionally, this is better aligned with the way we handle access
> control: MDT implements access control checks completely within MDD,
> without relying on underlying file system.
> 
>> 
> 
> [...]
> 
>> 
>> * issue #2: Quota accuracy
>> 
>> When a slave runs out of its local quota, it sends an acquire request to the
>> quota master. As I said earlier, the quota master is the only one having a
>> global overview of what has been granted to slaves. If the master can satisfy
>> the request, it grants a qunit (can be a number of blocks or inodes) to the
>> slave. The problem is that an OST can return "quota exceeded" (=EDQUOT)
>> whereas
>> another OST is still having quotas. There is currently no callback to claim
>> back the quota space that has been granted to a slave.

Hmm - the slave should release quota.  Arguing about the last qunit of quota
is pointless, we are NOT interested in quota that are absurdly small I
think, they would interfere with performance and the whole architecture of
quota uses qunits to leave performance unaffected.

> 
> What strikes me in this description is how this is similar to DLM. It
> almost looks like quota can be easily implemented as a special type of
> lock, and DLM conflict resolution mechanism with cancellation AST's can
> be used to reclaim quota.

The slave should release.  That doesn't address the issue of all OST's
consistently reporting EDQUOT.  However, doing that in a persistent way has
its own troubles maybe, namely, how would that be released and recovery
after power off on servers.  If not persistent, it would be pointless
because after server reboots, since OSS's with space left would still give
the wrong answer.

Peter


> 
>> 
> 
> [...]
> 
>> 
>> Cheers,
>> Johann
> 
> Nikita.
