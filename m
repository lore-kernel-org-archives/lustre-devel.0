From: James Simmons <jsimmons@infradead.org>
Date: Thu, 12 May 2016 01:28:54 +0100 (BST)
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <20160501234312.20601.qmail@ns.horizon.com>
References: <20160501234312.20601.qmail@ns.horizon.com>
Message-ID: <alpine.LFD.2.20.1605120110580.32203@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> I notice you have copies of the <linux/hash.h> functions in libcfs_hash.h,
> and use a mixture of the generic and copied functions in the Lustre code.
> 
> I'm revising the hash_64() function to fix some horrible collision
> problems that Thomas Gleixner found, and I wanted to give you a heads-up.
> 
> If there are cases where you use the generic ones but need
> reproducible outputs, they'll break.
> 
> If there are places where you're using the copied ones and *don't*
> need reproducible outputs, you're getting bad performance. 
> 
> I made a brief attempt to figure out what is used for what, but it's
> too confusing for me.  It's hard to figure out code like:

Thanks for looking into this. Do you have a tree some where we can look
at for the changes?

We opened a ticket to help track the progress for this at

https://jira.hpdd.intel.com/browse/LU-8130

Opening tickets is what gets people to look at these types of changes.
Again thanks for letting us know about these changes.

> static unsigned lu_obj_hop_hash(struct cfs_hash *hs,
>                                 const void *key, unsigned mask)
> {
> 	struct lu_fid  *fid = (struct lu_fid *)key;
> 	__u32	   hash;
> 
> 	hash = fid_flatten32(fid);
> 	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
> 	hash = hash_long(hash, hs->hs_bkt_bits);
> 
> 	/* give me another random factor */
> 	hash -= hash_long((unsigned long)hs, fid_oid(fid) % 11 + 3);
> 
> 	hash <<= hs->hs_cur_bits - hs->hs_bkt_bits;
> 	hash |= (fid_seq(fid) + fid_oid(fid)) & (CFS_HASH_NBKT(hs) - 1);
> 
> 	return hash & mask;
> }
> 
> The whole business of selecting the number of bits of the hash based
> on a mod-11 hash of something else seems quite peculiar.
> 
> Second, hash_long is multiplicative, meaning hash_long(a) - hash_long(b)
> = hash_long(a-b).  The different bit shifts complicate it, but subtracting
> two such values from each other is not a great way to mix.
> 
> Third, you're using the functions strangely.  The first hash_long() takes
> a 32-bit input and would be more efficient on 64-bit platforms if it
> were hash_32.  The second could be hash_ptr(),

Details about this change are at

https://jira.hpdd.intel.com/browse/LU-143

and the original patch with those changes are at

http://review.whamcloud.com/#/c/374

Is this the only code that doesn't make sense or is their more?
Looking at the source tree I see the hash code being used in 

lnet/lnet/api-ni.c
lnet/lnet/lib-ptl.c
lustre/include/lustre_fid.h
lustre/ldlm/ldlm_resource.c
lustre/obdclass/lu_object.c
