From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Tue, 23 Mar 2010 22:14:04 +0300
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <AB4A89B7-B642-42D2-A5B4-6A5CDF5AAEC2@sun.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
	<4BA8A60C.4000504@sun.com>
	<8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
	<AB4A89B7-B642-42D2-A5B4-6A5CDF5AAEC2@sun.com>
Message-ID: <8acda98c1003231214i1771bd0q5eae1097cc4daedf@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 23 March 2010 21:23, Andreas Dilger <adilger@sun.com> wrote:
> Hi Nikita,

Hello Andreas,

>
> On 2010-03-23, at 10:15, Nikita Danilov wrote:
>>

[...]

>>
>> If I understand correctly, the scheme has an advantage of cleaner
>> solution for readdir scalability than "hash adjust" hack of CMD3 (see
>> comment in lmv/lmv_obd.c:lmv_readpage()).
>
> Yes, I saw this for the first time just a few days ago and had to shield my
> eyes :-).

Hehe, wild days, happy memories.

>
>> The problem, to remind, is that if a number of clients readdir the same
>> split directory, they all hammer the same servers one after another,
>> negating the advantages of meta-data clustering. The solution is to
>> cyclically shift hash space by an offset depending on the client, so that
>> clients load servers uniformly. With 2-level hashing, this shifting can be
>> done entirely within new LMV hash function.
>
>
> Sure. ?Even without the 2-level hashing I wondered why the readdir pages
> weren't simply pre-fetched from a random MDT index (N % nstripes) by each
> client into its cache.

Do you mean that a client reads from servers in order N, N + 1, ..., N
- 1? Or that all clients read pages from servers in the same order 1,
2, ... nrstripes and in addition every client pre-fetches from servers
N, N + 1, ..., N - 1?

As to the first case, a directory entry hash value is used as a value
of ->d_off field in struct dirent. Historically this field means byte
offset in a directory file and hash adjustment tries to maintain its
monotonicity through readdir iterations.

>
> One question is whether it is important for applications to get entries back
> from readdir in a consistent order between invocations, which would imply
> that N should be persistent across calls (e.g. NID). ?If it is important for
> the application to get the entries in the same order, it would mean higher
> latency on some clients to return the first page, but thereafter the clients
> would all be pre-fetching round-robin. ?In aggregate it would speed up
> performance, however, by distributing the RPC traffic more evenly, and also
> by starting the disk IO on all of the MDTs concurrently instead of in
> series.

POSIX doesn't guarantee readdir repeatability, I am not sure about NT.

>
> Cheers, Andreas

Thank you,
Nikita.
