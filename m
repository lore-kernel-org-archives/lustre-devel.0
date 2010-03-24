From: Andreas Dilger <adilger@sun.com>
Date: Wed, 24 Mar 2010 16:23:24 -0600
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <8acda98c1003231214i1771bd0q5eae1097cc4daedf@mail.gmail.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
	<4BA8A60C.4000504@sun.com>
	<8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
	<AB4A89B7-B642-42D2-A5B4-6A5CDF5AAEC2@sun.com>
	<8acda98c1003231214i1771bd0q5eae1097cc4daedf@mail.gmail.com>
Message-ID: <CDDB8DAF-F32B-44B6-863C-FF48A4E90BA5@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-03-23, at 13:14, Nikita Danilov wrote:
> On 23 March 2010 21:23, Andreas Dilger <adilger@sun.com> wrote:
>>
>>> The problem, to remind, is that if a number of clients readdir the  
>>> same
>>> split directory, they all hammer the same servers one after another,
>>> negating the advantages of meta-data clustering. The solution is to
>>> cyclically shift hash space by an offset depending on the client,  
>>> so that
>>> clients load servers uniformly. With 2-level hashing, this  
>>> shifting can be
>>> done entirely within new LMV hash function.
>>
>> Sure.  Even without the 2-level hashing I wondered why the readdir  
>> pages
>> weren't simply pre-fetched from a random MDT index (N % nstripes)  
>> by each
>> client into its cache.
>
> Do you mean that a client reads from servers in order N, N + 1, ..., N
> - 1? Or that all clients read pages from servers in the same order 1,
> 2, ... nrstripes and in addition every client pre-fetches from servers
> N, N + 1, ..., N - 1?

What I meant was that each client starts its read on a different  
stripe (e.g. dir_stripe_index = client_nid % num_stripes), and reads(- 
ahead, optionally) chunks in (approximately?) round-robin order from  
the starting index, but it still returns the readdir data back to  
userspace as if it was reading starting at dir_stripe_index = 0.

That implies that, depending on the client NID, the client may buffer  
up to (num_stripes - 1) reads (pages or MB, depending on how much is  
read per RPC) until it gets to the 0th stripe index and can start  
returning entries from that stripe to userspace.  The readahead of  
directory stripes should always be offset from where it is currently  
processing, so that the clients continue to distribute load across  
MDTs even when they are working from cache.

> As to the first case, a directory entry hash value is used as a value
> of ->d_off field in struct dirent. Historically this field means byte
> offset in a directory file and hash adjustment tries to maintain its
> monotonicity through readdir iterations.

Agreed, though in the case of DMU backing storage (or even ldiskfs  
with a different hash function) there will be entries in each page  
read from each MDT that may have overlapping values.  There will need  
to be some way to disambiguate hash X that was read from MDT 0 from  
hash X from MDT 1.

It may be that the prefetching described above will help this.  If the  
client is doing hash-ordered reads from each MDT, it could be merging  
the entries on the client to return to userspace in strict hash order,  
even though the client doesn't know the underlying hash function  
used.  Presumably, with a well-behaved hash function, the entries in  
each stripe are uniformly distributed, so progress will be made  
through all stripes in a relatively uniform manner (i.e. reads will be  
going to all MDTs at about the same rate).

>> One question is whether it is important for applications to get  
>> entries back
>> from readdir in a consistent order between invocations, which would  
>> imply
>> that N should be persistent across calls (e.g. NID).  If it is  
>> important for
>> the application to get the entries in the same order, it would mean  
>> higher
>> latency on some clients to return the first page, but thereafter  
>> the clients
>> would all be pre-fetching round-robin.  In aggregate it would speed  
>> up
>> performance, however, by distributing the RPC traffic more evenly,  
>> and also
>> by starting the disk IO on all of the MDTs concurrently instead of in
>> series.
>
> POSIX doesn't guarantee readdir repeatability, I am not sure about NT.


In SUSv2 I didn't see any mention of entry ordering, per se, though  
telldir() and seekdir() should presumably be repeatable for NFS re- 
export, which implies that the user-visible ordering can't change  
randomly between invocations, and it shouldn't change between clients  
or clustered NFS export would fail.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
