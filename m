From: Xiong, Jinshan <jinshan.xiong@intel.com>
Date: Fri, 17 Feb 2017 19:15:26 +0000
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1487254536.4777.51.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
Message-ID: <6D3CC4C5-E789-4E2B-8428-2EA20CC7674E@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Anna,

Thanks for updating. Please see inserted lines.

On Feb 16, 2017, at 6:15 AM, Anna Fuchs <anna.fuchs at informatik.uni-hamburg.de<mailto:anna.fuchs@informatik.uni-hamburg.de>> wrote:

Dear all,

I would like to update you about my progress on the project.
Unfortunately, I can not publish a complete design of the feature,
since it changes very much during the development.

First the work related to the client changes:

I had to discard my approach to introduce the changes within the
sptlrpc layer for the moment. Compression of the data affects
especially the resulting number of pages and therefore number and size
of niobufs, size and structure of the descriptor and request, size of
the bulk kiov, checksums and in the end the async arguments. Actually
it affects everything, that is set within the osc_brw_prep_request
function in osc_request.c. When entering the sptlrpc layer, most of
that parameters are already set and I would need to update everything.
That causes double work and requires a lot of code duplication from the
osc module.

My current dirty prototype invokes compression just at the beginning of
that function, before niocount is calculated. I need to have a separate
bunch of pages to store compressed data so that I would not overwrite
the content of the original pages, which may be exposed to the
userspace process.
The original pages would be freed and the compressed pages processed
for the request and finally also freed.

Please remember to reserve some pages as emergency pool to avoid the problem that the system memory is in shortage and it needs some free pages for compression to writeback more pages. We may use the same pool to support partial block so it must be greater than the largest ZFS block size(I prefer to not compress data for partial blocks).

After RPC is issued, the pages contain compressed data will be pinned in memory for a while for recovery reasons. Therefore, when emergency pages are used, you will have to issue the RPC in sync mode, so that the server can commit the write trans into persistent storage and client can use the emergency pages for new RPC immediately.


I also reconsidered the idea to do compression niobuf-wise. Due to the
file layout, compression should be done record-wise. Since a niobuf is
a technical requirement for the pages to be contiguous, a record (e.g.
128KB) is a logical unit. In my understanding, it can happen, that one
record contains of several niobufs whenever we do not have enough

We use the terminology ?chunk? as the preferred block size on the OST. Let?s use the same terminology ;-)

contiguous pages for a complete record. For that reason, I would like
to leave the niobuf structure as is it and introduce a record structure
on top of it. That record structure will hold the logical(uncompressed)
and physical(compressed) data sizes and the algorithm used for

hmm? not sure if this is the right approach. I tend to think the client will talk with the OST at connecting time and negotiate the compress algorithm, and after that they should use the same algorithm. There is no need to carry this information in every single RPC.

Yes, it?s reasonable to have chunk descriptors in the RPC. When there are multiple compressed chunks packed in one RPC, the exact bufsize for each chunk will be packed as well. Right now, the LNET doesn?t support partial pages inside niobuf(except the first and last page), so clients have to provide enough information in the chunk descriptor so the server can deduce the padding size for each chunk in the niobuf.

compression. Initially we wanted to extend the niobuf struct by those
fields. I think that change would affect the RPC request structure very
much since the first Lustre message fields will not be followed by an
array of niobufs, but by an array of records, which can contain an
array of niobufs.

We just need a new format of RPC. Please take a look at RQF_OST_BRW_{READ,WRITE}. What we need is probably some thing like RQF_OST_COMP_BRW_{READ,WRITE}, which is basically the same thing but with chunk descriptor:

static const struct req_msg_field *ost_comp_brw_client[] = {
        &RMF_PTLRPC_BODY,
        &RMF_OST_BODY,
        &RMF_OBD_IOOBJ,
        &RMF_NIOBUF_REMOTE,
>>>     &RMF_CHUNK_DESCR,
        &RMF_CAPA1
};

On the server/storage side, the different niobufs must be then
associated with the same record and provided to ZFS.

Server changes:

Since we work on the Lustre/ZFS interface, we think it would be the
best to let Lustre compose the header information for every record
(psize and algorithm, maybe also the checksum in the future). We will

I tend to let ZFS do this job especially for checksum otherwise if Lustre provided wrong data it would affect the consistency of ZFS.

store these values at the beginning of every record in 4 Bytes each.
Currently, when ZFS does compression itself, the compressed size is
stored only within the compressed data. Some algorithms get it when
starting the decompression, for lz4 it is stored at the beginning. With
our approach, we would unify the record-metadata for any algorithm, but

Wait, are you suggesting to store record/chunk-metadata into persistent storage?

at the moment it would not be accessible by ZFS without changes to ZFS
structures.

ZFS will also hold an extra variable whether the data is compressed at
all. When reading and the data is compressed, it is up to Lustre to get
the original size and algorithm, to decompress the data and put it into
page structure.

Yes, the server will check the capability of client to decide if to return compressed data.

I don't look into the corresponding code but matt mentioned before this is pretty much the same interface of ZFS send/recv.

Thanks,
Jinshan



Any comments or ideas are very welcome!

Regards,
Anna





_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170217/6eab1133/attachment-0001.htm>
