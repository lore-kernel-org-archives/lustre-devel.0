From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Thu, 16 Feb 2017 15:15:36 +0100
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1484749185.3965.114.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
Message-ID: <1487254536.4777.51.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,?

I would like to update you about my progress on the project.?
Unfortunately, I can not publish a complete design of the feature,
since it changes very much during the development.?

First the work related to the client changes:?

I had to discard my approach to introduce the changes within the
sptlrpc layer for the moment. Compression of the data affects
especially the resulting number of pages and therefore number and size
of niobufs, size and structure of the descriptor and request, size of
the bulk kiov, checksums and in the end the async arguments. Actually
it affects everything, that is set within the?osc_brw_prep_request
function in osc_request.c. When entering the sptlrpc layer, most of
that parameters are already set and I would need to update everything.
That causes double work and requires a lot of code duplication from the
osc module.?

My current dirty prototype invokes compression just at the beginning of
that function, before niocount is calculated. I need to have a separate
bunch of pages to store compressed data so that I would not overwrite
the content of the original pages, which may be exposed to the
userspace process.?
The original pages would be freed and the compressed pages processed
for the request and finally also freed.?

I also reconsidered the idea to do compression niobuf-wise. Due to the
file layout, compression should be done record-wise. Since a niobuf is
a technical requirement for the pages to be contiguous, a record (e.g.
128KB) is a logical unit. In my understanding, it can happen, that one
record contains of several niobufs whenever we do not have enough
contiguous pages for a complete record. For that reason, I would like
to leave the niobuf structure as is it and introduce a record structure
on top of it. That record structure will hold the logical(uncompressed)
and physical(compressed) data sizes and the algorithm used for
compression. Initially we wanted to extend the niobuf struct by those
fields. I think that change would affect the RPC request structure very
much since the first Lustre message fields will not be followed by an
array of niobufs, but by an array of records, which can contain an
array of niobufs.?
On the server/storage side, the different niobufs must be then
associated with the same record and provided to ZFS.?

Server changes:?

Since we work on the Lustre/ZFS interface, we think it would be the
best to let Lustre compose the header information for every record
(psize and algorithm, maybe also the checksum in the future). We will
store these values at the beginning of every record in 4 Bytes each.?
Currently, when ZFS does compression itself, the compressed size is
stored only within the compressed data. Some algorithms get it when
starting the decompression, for lz4 it is stored at the beginning. With
our approach, we would unify the record-metadata for any algorithm, but
at the moment it would not be accessible by ZFS without changes to ZFS
structures.?

ZFS will also hold an extra variable whether the data is compressed at
all. When reading and the data is compressed, it is up to Lustre to get
the original size and algorithm, to decompress the data and put it into
page structure.?


Any comments or ideas are very welcome!?

Regards,
Anna
