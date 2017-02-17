From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 17 Feb 2017 21:36:51 +0000
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <ED57E03F-134B-4A35-9BFC-17900D01A03E@intel.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	<6D3CC4C5-E789-4E2B-8428-2EA20CC7674E@intel.com>
	<F4D55832-DA4A-44A6-99B1-CFEF5827F55B@intel.com>
	<ED57E03F-134B-4A35-9BFC-17900D01A03E@intel.com>
Message-ID: <38CECFD6-E1EB-4292-992C-F9C65A820A84@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 17, 2017, at 14:03, Xiong, Jinshan <jinshan.xiong@intel.com> wrote:
> 
>> 
>> On Feb 17, 2017, at 12:29 PM, Dilger, Andreas <andreas.dilger@intel.com> wrote:
>> 
>> On Feb 17, 2017, at 12:15, Xiong, Jinshan <jinshan.xiong@intel.com> wrote:
>>> 
>>> Hi Anna,
>>> 
>>> Thanks for updating. Please see inserted lines.
>>> 
>>>> On Feb 16, 2017, at 6:15 AM, Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de> wrote:
>>>> 
>>>> Dear all, 
>>>> 
>>>> I would like to update you about my progress on the project. 
>>>> Unfortunately, I can not publish a complete design of the feature,
>>>> since it changes very much during the development. 
>>>> 
>>>> First the work related to the client changes: 
>>>> 
>>>> I had to discard my approach to introduce the changes within the
>>>> sptlrpc layer for the moment. Compression of the data affects
>>>> especially the resulting number of pages and therefore number and size
>>>> of niobufs, size and structure of the descriptor and request, size of
>>>> the bulk kiov, checksums and in the end the async arguments. Actually
>>>> it affects everything, that is set within the osc_brw_prep_request
>>>> function in osc_request.c. When entering the sptlrpc layer, most of
>>>> that parameters are already set and I would need to update everything.
>>>> That causes double work and requires a lot of code duplication from the
>>>> osc module. 
>>>> 
>>>> My current dirty prototype invokes compression just at the beginning of
>>>> that function, before niocount is calculated. I need to have a separate
>>>> bunch of pages to store compressed data so that I would not overwrite
>>>> the content of the original pages, which may be exposed to the
>>>> userspace process. 
>>>> The original pages would be freed and the compressed pages processed
>>>> for the request and finally also freed. 
>>> 
>>> Please remember to reserve some pages as emergency pool to avoid the problem that the system memory is in shortage and it needs some free pages for compression to writeback more pages. We may use the same pool to support partial block so it must be greater than the largest ZFS block size(I prefer to not compress data for partial blocks). 
>>> 
>>> After RPC is issued, the pages contain compressed data will be pinned in memory for a while for recovery reasons. Therefore, when emergency pages are used, you will have to issue the RPC in sync mode, so that the server can commit the write trans into persistent storage and client can use the emergency pages for new RPC immediately.
>>> 
>>>> 
>>>> I also reconsidered the idea to do compression niobuf-wise. Due to the
>>>> file layout, compression should be done record-wise. Since a niobuf is
>>>> a technical requirement for the pages to be contiguous, a record (e.g.
>>>> 128KB) is a logical unit. In my understanding, it can happen, that one
>>>> record contains of several niobufs whenever we do not have enough
>>> 
>>> We use the terminology ?chunk? as the preferred block size on the OST. Let?s use the same terminology ;-)
>>> 
>>>> contiguous pages for a complete record. For that reason, I would like
>>>> to leave the niobuf structure as is it and introduce a record structure
>>>> on top of it. That record structure will hold the logical(uncompressed)
>>>> and physical(compressed) data sizes and the algorithm used for
>>> 
>>> hmm? not sure if this is the right approach. I tend to think the client will talk with the OST at connecting time and negotiate the compress algorithm, and after that they should use the same algorithm. There is no need to carry this information in every single RPC.
>> 
>> I'm not sure I agree.  The benefits of compression may be different on a per-file basis (e.g. .txt vs. .jpg) so there shouldn't be a fixed compression algorithm required for all RPCs.  I could imagine that we don't want to allow a different compression type for each block (which ZFS allows), but one compression type per RPC should be OK.  We do the same for the checksum type.
> 
> The difference between checksum and compression is that different types of checksum should produce the same results, therefore the clients can pick any checksum algorithm at its own discretion.
> 
> As for your example, I think it?s more likely that the OSC will decide to turn off compression for the .jpg file after trying to compress few chunks and figure out there is no benefit by doing that.

Actually, Anna's research group did some testing with dynamic compression at the ZFS level on a per-block basis (which I would love to see submitted upstream to ZFS) so that the node can balance CPU usage vs. compression ratio for each file or potentially each block.  I don't want to bake in a connect-time compression algorithm into the network protocol, even if we don't implement dynamic compression selection at runtime immediately.  I'm sure we can find some space in the RPC for the compression algorithm, or even in a new niobuf_remote if the RPC format is changing anyway.

If there were only a handful of compression algorithms we could encode the compression algorithm into 4 bits of rnb_flags.  I don't _think_ we need to also specify the compression level or other parameters, just the algorithm (e.g. gzip, lz4), but I don't want to be too limiting if the number of compression algorithms continues to grow so a separate 32-bit field with a 32-bit padding would be safer if the protocol is already being changed.  It would also be good to add some padding to obd_ioobj for future use while we are in there.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
