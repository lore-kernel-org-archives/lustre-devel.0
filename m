From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Tue, 23 Mar 2010 07:29:16 -0400
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
Message-ID: <4BA8A60C.4000504@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
Andreas Dilger wrote:
> On 2010-03-22, at 17:09, Tom.Wang wrote:
>   
>> In CMD, one directory can be striped to several MDTs according to the
>> hash value of each entry (calculated by its name). Suppose we have N
>> MDTs and hash range is 0 to MAX_HASH. First server will keep records
>> with hashes [ 0 ... MAX_HASH / N  - 1], second one with hashes  
>> [MAX_HASH
>> / N ... 2 * MAX_HASH / N] and so on.  Currently, it uses the same hash
>> policy with the one used on disk(ldiskfs/ext3 hash), so when reading
>> striped directory, the entries from different stripe objects can be
>> mapped on client side cache simply, actually this page cache is only
>> maintained in llite layer. But this bonding of CMD split-dir protocal
>> with on-disk hash seems not good, and it even brings more problems  
>> when
>> porting MDT to kdmu.
>>
>> This dir-entry page cache should be moved to mdc layer, and each  
>> stripe
>> object will have its own page cache. It will need 2 lookups for  
>> locating
>> an entry in the page cache, first locating the stripe
>> objects(ll_stripe_offset will be added in ll_file_data to indicate the
>> stripe offset), then got the page by offset(f_pos) inside the
>> stripe_object. The entry page cache can even be organized as the favor
>> of different purposes, for example readdir-plus, dir-extent lock.  
>> Idealy
>> we can reuse the cl_page on mdc layer, but that might need object
>> layering on metadata stack. In the first step probably register some
>> page callback for mdc to manage the page cache.
>>     
>
>
> Tom, could you please explain the proposed mechanism for hashing in  
> this scheme?    Will there be one hash function at the LMV level to  
> select the dirstripe, and a second one at the MDC level?Does this  
> imply that the client still needs to know the hashing scheme used by  
> the backing storage?  At least this allows a different hash per  
> dirstripe, which is important for DMU because the hash seed is  
> different for each directory.
>   
Client does not need to know the hash scheme of the backing storage.

LMV will use new hash function to select stripe object (mdc), which 
could be independent with the one
used in the storage.  In mdc level, it just need to map the entries of 
each dir stripe object in the cache,
we can index the cache in anyway as we want, probably hash order (as the 
server storage) is a good choice,
because client can easily find and cancel the pages by the hash in later 
dir-extent lock. Note: Even in this case,
client does not need to know server hash scheme at all, since server 
will set the hash-offset of these pages, client just
need to put these pages on the cache by hash-offset. 

Currently, the cache will only be touched by readdir.  If the cache will 
be used by readdir-plus later, i.e. we need locate
the entry by name, then client must use the same hash as the server 
storage, but server will tell client which hash function
it use.  Yes, different hash per dirstripe should not be a problem here.

Thanks
WangDi

> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
