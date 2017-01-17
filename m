From: Xiong, Jinshan <jinshan.xiong@intel.com>
Date: Tue, 17 Jan 2017 19:51:11 +0000
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1484223328.3937.60.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
Message-ID: <B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Anna,

Please see inserted lines.

On Jan 12, 2017, at 4:15 AM, Anna Fuchs <anna.fuchs at informatik.uni-hamburg.de<mailto:anna.fuchs@informatik.uni-hamburg.de>> wrote:

Hello all,

thank you for the responses.


Jinshan,


I assume the purpose of this proposal is to fully utilize the CPU
cycles on the client nodes to compress and decompress data, because
there are much more client nodes than server nodes. After data is
compressed, it will need less network bandwidth to transfer it to
server and write them back to storage.

Yes, that is our goal for the moment.

cool. This should be a good approach.



There would be more changes to implement this feature:
1. I guess dmu_read() needs change as well to transfer compressed
data back to client, otherwise how it would improve readahead
performance. Please let me know if I overlooked something;

Sure, I might have shortened my explanation too much. The read path
will be affected for providing compressed data and record-wise
"metadata" back to the client. The client will then decompress it.

2. read-modify-write on client chunks - if only partial chunk is
modified on the client side, the OSC will have to read the chunk
back, uncompress it, and modify the data in chunk, and compress it
again to get ready for write back. We may have to maintain a separate
chunk cache on the OSC layer;

We keep the rmw problem in mind and will definitely need to work on
optimization once the basic functionality is done. When compressing
only sub-stripes (record size), we already hope to reduce the
performance loss since we do not need to transfer and decompress the
whole stripe anymore.
We would want to keep the compressed data within bd_enc_vec and
uncompressed in the normal vector. The space for that vector is
allocated in sptlrpc_enc_pool_get_pages. Are those not cached? Could
you give me some hints for the approach and what to look at? Is it a
right place at all?

I don?t think sptlrpc page pool will cache any data. However, it?s the right place to do compress in the sptlrpc layer, you just extend the sptlrpc for a new flavor.

With that being said, we?re going to have two options to support partial block write:

1. In the OSC I/O engine, it only submits ZFS block size aligned plain data to ptlrpc layer and it does compress in the new flavor of sptlrpc. When partial blocks are written, the OSC will have to issue read RPC if the corresponding data belonging to the same block are not cached;

2. Or we can just disable this optimization that means plain data will be issued to the sever for partial block written. It only do compress for full blocks.

I feel the option 2 would be much simpler but needs some requirements to the workload to take full advantage, e.g. if applications are writing bulk and sequential data.

Though, the naive prototype I am currently working on is very memory
intensive anyway (additional buffers, many copies). There is much work
for me until I can dive into optimizations...


3. the OST should grant LDLM lock to align with ZFS block size
otherwise it will be very complex if the OSC has to request locks to
do RMW;

I am not very familiar with the locking in Lustre yet.
You mean, once we want to modify part of the data on OST, we want to
have a lock for the complete chunk (record), right? Currently, Lustre
can do byte-range locks, instead we wanted record-ranged in this case?

Right now Lustre aligns BRW lock by the page size on the client side. Please check the code and comments in function ldlm_extent_internal_policy_fixup(). Since client doesn?t provide the page size to server explicitly, the code just guess it by the req_end.

In the new code with this feature supported, the LDLM lock should be aligned to MAX(zfs_block_size, req_align).



4. OSD-ZFS can dynamically extend the block size by the write
pattern, so we need to disable it to accommodate this feature;

We thought to set the sizes from Lustre (client or later server) and
force ZFS to use them. ZFS itself will not be able to change any
layouts.

Sounds good to me. There is a work in progress to support setting block size from client side in LU-8591.


Matt,


a possible feature is to enable ZFS to decompress the data

I would recommend that you plan to integrate this compression with
ZFS from the beginning, by using compression formats that ZFS already
supports (e.g. lz4), or by adding support in ZFS for the algorithm
you will use for Lustre.  This will provide better flexibility and
compatibility.

We currently experiment with lz4 fast, which our students try to submit
to the linux kernel. The ZFS patch for that will hopefully follow soon.
We thought it would be nice to have the opportunity to use some brand
new algorithms on the client within Lustre even if they are not yet
supported by ZFS. Though it is great that the ZFS community is open to
integrate new features so we probably could completely match our needs.

That?ll be cool. I think ZFS community should be open to accept new algorithm. Please make a patch and submit it to https://github.com/zfsonlinux/zfs/issues



Also, I agree with what Jinshan said below.  Assuming that you want
to do compressed read as well, you will need to add a compressed read
function to the DMU.  For compressed send/receive we only added
compressed write to the DMU, because zfs send reads directly from the
ARC (which can do compressed read).

We are working on it right now, the functionality should be similar to
the write case or do I miss some fundamental issues?

It should be similar to write case, i.e., to bypass the layer of dmu buffer.

Jinshan



Best regards,
Anna

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170117/ba32431b/attachment-0001.htm>
