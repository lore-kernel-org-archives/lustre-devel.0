From: Andreas Dilger <adilger@sun.com>
Date: Mon, 22 Mar 2010 22:22:22 -0600
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <4BA7F8B3.8050104@sun.com>
References: <4BA7F8B3.8050104@sun.com>
Message-ID: <A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-03-22, at 17:09, Tom.Wang wrote:
> In CMD, one directory can be striped to several MDTs according to the
> hash value of each entry (calculated by its name). Suppose we have N
> MDTs and hash range is 0 to MAX_HASH. First server will keep records
> with hashes [ 0 ... MAX_HASH / N  - 1], second one with hashes  
> [MAX_HASH
> / N ... 2 * MAX_HASH / N] and so on.  Currently, it uses the same hash
> policy with the one used on disk(ldiskfs/ext3 hash), so when reading
> striped directory, the entries from different stripe objects can be
> mapped on client side cache simply, actually this page cache is only
> maintained in llite layer. But this bonding of CMD split-dir protocal
> with on-disk hash seems not good, and it even brings more problems  
> when
> porting MDT to kdmu.
>
> This dir-entry page cache should be moved to mdc layer, and each  
> stripe
> object will have its own page cache. It will need 2 lookups for  
> locating
> an entry in the page cache, first locating the stripe
> objects(ll_stripe_offset will be added in ll_file_data to indicate the
> stripe offset), then got the page by offset(f_pos) inside the
> stripe_object. The entry page cache can even be organized as the favor
> of different purposes, for example readdir-plus, dir-extent lock.  
> Idealy
> we can reuse the cl_page on mdc layer, but that might need object
> layering on metadata stack. In the first step probably register some
> page callback for mdc to manage the page cache.


Tom, could you please explain the proposed mechanism for hashing in  
this scheme?    Will there be one hash function at the LMV level to  
select the dirstripe, and a second one at the MDC level?  Does this  
imply that the client still needs to know the hashing scheme used by  
the backing storage?  At least this allows a different hash per  
dirstripe, which is important for DMU because the hash seed is  
different for each directory.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
