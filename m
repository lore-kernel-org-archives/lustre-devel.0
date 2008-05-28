From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 28 May 2008 18:05:38 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.34513.370736.111492@gargle.gargle.HOWL>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
Message-ID: <1211994338.14599.24.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Qua, 2008-05-28 at 20:22 +0400, Nikita Danilov wrote:

> Even doing it internally looks rather involved. The problem, as I
> understand it, is that no new block can be allocated while transaction
> group is in sync state (?)


I'm not sure if you are describing it incorrectly or just using the same
terms for different concepts, but in any case, blocks are allocated
*while* the transaction group is syncing, and due to compression and
online pool configuration changes it is impossible to know the exact
on-disk space a given block will use until the transaction group is
actually syncing.


> so DMU would have to track all users and
> groups whose quota is affected by the current transaction group, and
> before closing the group, to allocate some kind of on-disk table with an
> entry for every updated quota, then to fill these entries later when
> actual disk space is allocated.


Yes, that sounds correct.


> Note that dmu has to know about users and groups to implement quota
> internally, which looks like a pervasive interface change.


No, AFAIK, the consensus we reached with the ZFS team is that, ?since
the DMU does not have any concept of users or groups, it will track
space usage associated with opaque identifiers, so that when we write to
a file we would give it 2 identifiers which, for us, one of them would
map to a user and the other one to a group.


> I absolutely agree that DMU has to do space _accounting_ internally. The
> question is how to store results of this accounting, without bothering
> DMU with higher level concepts such as a user or a group identifier.


I really don't think we should allow the consumer to write to a txg
which is already in the syncing phase, I think the DMU should store the
accounting itself.


> I think that utility of DMU as a universal back-end would improve if it
> were to export an interface allowing its users to update, with certain
> restrictions, on-disk state when transaction group is in sync (i.e.,
> interface similar to one that is internally used for spacemaps).



Hmm.. I'm not sure if that would be very useful, why not write the data
when the txg was open in the first place? ??Maybe you can give a better
example?

For things that requires knowledge of DMU internals (like space
accounting, spacemaps, ...) it shouldn't be the DMU consumer that has to
write during the txg sync phase, it should be the DMU because only the
DMU should know about its internals.

The example you have given (spacemaps) is the worst of all, because
spacemap updates are rather involved. Due to ?COW and to the ZIO
pipeline design, spacemap modifications lead to a chicken-and-egg
problem with transactional updates:

When you modify a space map, you create a ZIO which just before writing
leads to an allocation (due to COW).  But since you need to do an
allocation, you need to change the spacemap again, which leads to
another allocation (and also leads to free the old just-written block),
so you need to update the space map again, and so on and on.. (!)
This is why txgs need to converge and why after a few phases it gives up
freeing blocks, and starts re-using blocks which were freed on the same
txg.

Cheers,
Ricardo

--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/ed189e64/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/ed189e64/attachment.gif>
