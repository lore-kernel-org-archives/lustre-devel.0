From: Andreas Dilger <adilger@sun.com>
Date: Tue, 23 Mar 2010 12:23:02 -0600
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
	<4BA8A60C.4000504@sun.com>
	<8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
Message-ID: <AB4A89B7-B642-42D2-A5B4-6A5CDF5AAEC2@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikita,

On 2010-03-23, at 10:15, Nikita Danilov wrote:
> On 23 March 2010 14:29, Tom.Wang <Tom.Wang@sun.com> wrote:
>>
>> LMV will use new hash function to select stripe object (mdc), which  
>> could be
>> independent with the one used in the storage.  In mdc level, it  
>> just need to map the entries of each dir stripe object in the  
>> cache, we can index the cache in anyway as we want, probably hash  
>> order (as the server storage) is a good choice, because client can  
>> easily find and cancel the pages by the hash in later dir-extent  
>> lock. Note: Even in this case, client does not need to know server  
>> hash scheme at all, since server will set the hash-offset of these  
>> pages, client just need to put these pages on the cache by hash- 
>> offset.
>>
>> Currently, the cache will only be touched by readdir.  If the cache  
>> will be
>> used by readdir-plus later, i.e. we need locate the entry by name,  
>> then client must use the same hash as the server storage, but  
>> server will tell client which hash function it use.  Yes, different  
>> hash per dirstripe should not be a problem here.
>
> If I understand correctly, the scheme has an advantage of cleaner
> solution for readdir scalability than "hash adjust" hack of CMD3 (see
> comment in lmv/lmv_obd.c:lmv_readpage()).

Yes, I saw this for the first time just a few days ago and had to  
shield my eyes :-).

> The problem, to remind, is that if a number of clients readdir the  
> same split directory, they all hammer the same servers one after  
> another, negating the advantages of meta-data clustering. The  
> solution is to cyclically shift hash space by an offset depending on  
> the client, so that clients load servers uniformly. With 2-level  
> hashing, this shifting can be done entirely within new LMV hash  
> function.


Sure.  Even without the 2-level hashing I wondered why the readdir  
pages weren't simply pre-fetched from a random MDT index (N %  
nstripes) by each client into its cache.

One question is whether it is important for applications to get  
entries back from readdir in a consistent order between invocations,  
which would imply that N should be persistent across calls (e.g.  
NID).  If it is important for the application to get the entries in  
the same order, it would mean higher latency on some clients to return  
the first page, but thereafter the clients would all be pre-fetching  
round-robin.  In aggregate it would speed up performance, however, by  
distributing the RPC traffic more evenly, and also by starting the  
disk IO on all of the MDTs concurrently instead of in series.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
