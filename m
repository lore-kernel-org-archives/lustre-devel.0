From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Wed, 18 Jan 2017 15:19:45 +0100
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
Message-ID: <1484749185.3965.114.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,?

thanks again.?

> I don?t think sptlrpc page pool will cache any data. 

Ok, I will look at the caching within OSC in more detail.

> However, it?s the right place to do compress in the sptlrpc layer,
> you just extend the sptlrpc for a new flavor.

Well, during my master's thesis, I have already tried to introduce
compression in form of a new flavor for GSS. Unfortunately, I had huge
problems to get GSS to work at all (later 2.7 or first of 2.8
versions). The plain or null flavors for testing didn't work and any
other approach required Kerberos (which I also couldn't make work :( ).
Probably I just missed something, but it led me to the idea to make it
close to, but yet independent from GSS.

As far I understood, currently only the RPC but not the data is handled
by GSS on the client side??
And from what I have seen, when using GSS, the number of niobufs within
the RPC is restricted to 1; for compression we would need more. Also,
the flavor is set per RPC, we need it per niobuf. Though it might be
just implementation details, wouldn't you currently prefer to keep it
separate to avoid mixing up bugs from our new feature and changes to
GSS? Currently I try my change within?sptlrpc_cli_wrap_bulk in sec.c
just before wrapping the bulks with GSS mechanisms.?

> 
> With that being said, we?re going to have two options to support
> partial block write:
> 
> 1. In the OSC I/O engine, it only submits ZFS block size aligned
> plain data to ptlrpc layer and it does compress in the new flavor of
> sptlrpc. When partial blocks are written, the OSC will have to issue
> read RPC if the corresponding data belonging to the same block are
> not cached;
> 
> 2. Or we can just disable this optimization that means plain data
> will be issued to the sever for partial block written. It only do
> compress for full blocks.
> 
> I feel the option 2 would be much simpler but needs some requirements
> to the workload to take full advantage, e.g. if applications are
> writing bulk and sequential data.

Sounds good. In my thesis I have already spent some thoughts to the RMW
issues. In some cases it might be the best to let the server decompress
the specific data chunks (which is planned in the future anyway) and
skip compression for partial writes.?

> 
> Right now Lustre aligns BRW lock by the page size on the client side.
> Please check the code and comments in function
> ldlm_extent_internal_policy_fixup(). Since client doesn?t provide the
> page size to server explicitly, the code just guess it by the
> req_end.
> 
> In the new code with this feature supported, the LDLM lock should be
> aligned to MAX(zfs_block_size, req_align).

> 
> Sounds good to me. There is a work in progress to support setting
> block size from client side in LU-8591.

Thanks for the hints!

> > > ?
> > > Also, I agree with what Jinshan said below.??Assuming that you
> > > want
> > > to do compressed read as well, you will need to add a compressed
> > > read
> > > function to the DMU.??For compressed send/receive we only added
> > > compressed write to the DMU, because zfs send reads directly from
> > > the
> > > ARC (which can do compressed read).
> > ?
> > We are working on it right now, the functionality should be similar
> > to
> > the write case or do I miss some fundamental issues??
> 
> It should be similar to write case, i.e., to bypass the layer of dmu
> buffer.

Our first approach for read is currently the following:?
Once compression is enabled, for OSTs we call the modified dmu_read
with the logical (uncompressed) data size. ZFS notices, the requested
data is compressed and delivers the physical (compressed) data size,
the used algorithm and the actual data of size psize. Lustre gets the
psize somehow together with the data. Psize would be used to ensure
that the "received" amount of data, which differs from requested
logical size, is correct.?

Bypass the dbufs - you mean to transfer the data directly from ARC to
the client?


> Jinshan
Be
> > 
> st regards,
Anna
