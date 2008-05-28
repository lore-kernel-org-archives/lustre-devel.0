From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 28 May 2008 22:07:13 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.47971.504225.694251@gargle.gargle.HOWL>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
	<18493.47971.504225.694251@gargle.gargle.HOWL>
Message-ID: <1212008833.14599.84.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Qui, 2008-05-29 at 00:06 +0400, Nikita Danilov wrote:

> Well... that's just renaming uid and gid into opaqueid0 and
> opaqueid1. :-)


It may be simple for POSIX uids/gids, but maybe not for CIFS user ids
(but since there is a mapping table it may be also be simple, I'm not
sure).
I think it would make sense to give it a list of opaque ids, instead of
just opaqueid0 and opaqueid1 (maybe a file could belong to multiple
groups or maybe we can think of other creative ideas in the future..).


> So on one hand we have to add a couple of parameters to all dmu entry
> points that can allocate disk space. On the other hand we have
> something
> like
> 
> typedef void (*dmu_alloc_callback_t)(objset_t *os, uint64_t objid,
> long bytes);
> 
> void dmu_alloc_callback_register(objset_t *os, dmu_alloc_callback_t
> cb);
> 
> with dmu calling registered call-back when blocks are actually
> allocated
> to the object. Advantage of the later interface is that dmu implements
> only mechanism, and policy ("user quotas" and "group quotas") is left
> to
> the upper layers to implement.


I don't see why that would be an advantage over what we had planned to
do.
The plan we discussed with the ZFS team was to make the DMU do space
accounting internally by opaque ids, so the quota policy/enforcement
would still be left to the upper layers to implement.


> If quota management and storage are
> completely encapsulated within dmu, then dmu has to provide full quota
> control interface too, and that interface has to be exported from osd
> upward. For one thing, implementation of this interface is going to take
> a lot of time.


Again, the plan was for the DMU to do only space accounting, the actual
quota management and enforcement would be implemented in Lustre.



>  > For things that requires knowledge of DMU internals (like space
>  > accounting, spacemaps, ...) it shouldn't be the DMU consumer that has to
>  > write during the txg sync phase, it should be the DMU because only the
>  > DMU should know about its internals.
> 
> I don't quite understand this argument. DMU already has an interface to
> capture a buffer into a transaction and to modify it within this
> transaction. An interface to modify a buffer after transaction was
> closed, but before it is committed is no more "internal" than the first
> one. It is just places more restrictions on what consumer is allowed to
> do with the buffer.


What I mean is that IMO a consumer of a filesystem shouldn't have to
know intimate details of how the filesystem (in this case, the DMU)
works.
For instance, so far Lustre had no idea that transactions are actually
grouped into transaction groups and it had no idea about transaction
group states.

Allowing modification of buffers by an upper layer when a transaction
group is already syncing is not a very elegant way to solve this IMHO
(compared with our previous plan).. :-)

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/c1d8c970/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/c1d8c970/attachment.gif>
