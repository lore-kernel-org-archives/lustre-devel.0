From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Mon, 09 Jan 2017 14:07:38 +0100
Subject: [lustre-devel] Design proposal for client-side compression
Message-ID: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,?

a couple of months ago we started the IPCC-L project about compression
within Lustre [0]. Currently we are focusing on client-side compression
and I would like to present you our plans and discuss them. Any
comments are very welcome.

General design:?

The feature will introduce transparent compression within the Lustre
filesystem on the client and server side (in the future).
Due to existing infrastructure for compressed blocks within the ZFS
backend filesystem, at first, only ZFS will be supported. ldiskfs as
backend is not principally discarded, though it requires wide-ranging
changes of its infrastructure which might follow once the workflow is
proven. All communication between the MDS and any other components
remains uncompressed. That means, metadata will not be compressed at
any time.

The client will compress the data per stripe, while every stripe is
divided into chunks based on the ZFS record size. Those chunks can be
compressed independently and in parallel.
To be able to decompress the data later we need to store the algorithm
type and the original chunk size. We want to store it per chunk/record
for several reasons. When decompressing, we need to know the required
buffer size for the uncompressed piece of data. Moreover, later it will
be possible to have different chunk sizes within one stripe and use
different algorithms for every chunk. The storing of that additional
metadata is up to ZFS and will not affect the MDS.?

The compressed stripes will go to the Lustre server including the
metadata within the RPC. The server, at first, will just pass the data
to ZFS. ZFS for its part will make use of its internal data structure,
which already handles compressed blocks. The pre-compressed blocks will
be stored within the trees like they have been compressed by ZFS
itself. We expect ZFS then to achieve better read-ahead performance as
if storing the data like common data blocks (which would produce
"holes" within the file). Since ZFS has knowledge about the original
data bounds, it can iterate over the records like they were logically
contiguous.

Implementation details:?

We need to make changes on the Lustre client, server, RPC protocol and
ZFS backend.

Client:?

We thought to introduce the changes close to GSS within the PtlRPC
layer.
In the future, the infrastructure might be reused for client-side
encryption also. All the infrastructure changes are independent from
specific compression algorithms, except for the requirement that the
data size does not grow. It will be possible to change the algorithms;
the missing libraries would be deployed and built together with Lustre
code if the specific kernel does not support them.?
There is a wrapping layer sptlrpc (standing for security ptlrpc?).
Analogously, we could introduce a cptlrpc (for compression) or just put
both together in a tptlrpc (transform) layer.

We would also like to reuse the bd_enc_vec structures for compressed
bulk data. What do you think about that?

RPC:?

We would extend the niobuf_remote structure with the logical size and
the algorithm type. Each compressed record would be a separate niobuf.
We first had the idea to reuse the free bits of the flavor flag to mask
the algorithm type, though we need it per niobuf, but the flavor is per
RPC. The read/write RPC with patched niobufs arrives at the server and
it can then get the data in the correct amount to pass it through to
ZFS.?


ZFS:

Newest ZFS features include compressed send and receive operations to
stream data in compressed form and save CPU efforts. During the course
of these changes, the ZFS-to-Lustre interface will be extended by
additional parameters lsize and the algorithm type needed for
decompression. lsize is the logical size which is the original,
uncompressed, user written data size. In contrast the physical size is
the actual compressed data size.
The current interface will coexist and is not going to be fully
exchanged by the extended one to save the ability to write/read data
unaffected by compression. Those changes affect at least the two I/O
paths "dmu_write" and "dmu_assign_arcbuf".?

At first, the use of ZFS?s internal compression will be skipped and
possible only with disabled Lustre compression. Though a possible
feature is to enable ZFS to decompress the data so that one could
access data without Lustre.


[0]?https://software.intel.com/articles/intel-parallel-computing-center
-at-university-of-hamburg-scientific-computing


Best regards,
Anna


--?
Anna Fuchs
https://wr.informatik.uni-hamburg.de/people/anna_fuchs
