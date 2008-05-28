From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Thu, 29 May 2008 00:06:59 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1211994338.14599.24.camel@localhost>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
Message-ID: <18493.47971.504225.694251@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:
 > On Qua, 2008-05-28 at 20:22 +0400, Nikita Danilov wrote:

[...]

 > 
 > I'm not sure if you are describing it incorrectly or just using the same
 > terms for different concepts, but in any case, blocks are allocated
 > *while* the transaction group is syncing, and due to compression and
 > online pool configuration changes it is impossible to know the exact
 > on-disk space a given block will use until the transaction group is
 > actually syncing.

I meant that the table mentioned below cannot grow, while transaction
group is syncing, which means that dmu has to calculate size of the
table in advance.

[...]

 > 
 > > Note that dmu has to know about users and groups to implement quota
 > > internally, which looks like a pervasive interface change.
 > 
 > 
 > No, AFAIK, the consensus we reached with the ZFS team is that, ???since
 > the DMU does not have any concept of users or groups, it will track
 > space usage associated with opaque identifiers, so that when we write to
 > a file we would give it 2 identifiers which, for us, one of them would
 > map to a user and the other one to a group.

Well... that's just renaming uid and gid into opaqueid0 and
opaqueid1. :-)

So on one hand we have to add a couple of parameters to all dmu entry
points that can allocate disk space. On the other hand we have something
like

typedef void (*dmu_alloc_callback_t)(objset_t *os, uint64_t objid, long bytes);

void dmu_alloc_callback_register(objset_t *os, dmu_alloc_callback_t cb);

with dmu calling registered call-back when blocks are actually allocated
to the object. Advantage of the later interface is that dmu implements
only mechanism, and policy ("user quotas" and "group quotas") is left to
the upper layers to implement.

[...]

 > 
 > I really don't think we should allow the consumer to write to a txg
 > which is already in the syncing phase, I think the DMU should store the
 > accounting itself.

One important aspect of lustre quota requirements that wasn't mentioned
so far is that Lustre needs something more than -EDQUOT from the file
system. For example, to integrate quotas with dirty cache grants, server
has to know how much quota is left, to redistribute quota across ost's
it has to modify quota, etc. If quota management and storage are
completely encapsulated within dmu, then dmu has to provide full quota
control interface too, and that interface has to be exported from osd
upward. For one thing, implementation of this interface is going to take
a lot of time.

[...]

 > 
 > For things that requires knowledge of DMU internals (like space
 > accounting, spacemaps, ...) it shouldn't be the DMU consumer that has to
 > write during the txg sync phase, it should be the DMU because only the
 > DMU should know about its internals.

I don't quite understand this argument. DMU already has an interface to
capture a buffer into a transaction and to modify it within this
transaction. An interface to modify a buffer after transaction was
closed, but before it is committed is no more "internal" than the first
one. It is just places more restrictions on what consumer is allowed to
do with the buffer.

 > When you modify a space map, you create a ZIO which just before writing
 > leads to an allocation (due to COW).  But since you need to do an
 > allocation, you need to change the spacemap again, which leads to
 > another allocation (and also leads to free the old just-written block),
 > so you need to update the space map again, and so on and on.. (!)
 > This is why txgs need to converge and why after a few phases it gives up
 > freeing blocks, and starts re-using blocks which were freed on the same
 > txg.

Good heavens. :-)

 > 
 > Cheers,
 > Ricardo

Nikita.
