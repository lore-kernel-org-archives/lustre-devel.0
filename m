From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 May 2016 18:28:20 +0100 (BST)
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <20160513202507.26286.qmail@ns.horizon.com>
References: <20160513202507.26286.qmail@ns.horizon.com>
Message-ID: <alpine.LFD.2.20.1605161735250.9721@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Looking at our code I see our duplication is cfs_hash_u32_hash and
> > cfs_hash_u64_hash which could be replaced by the standard linux functions.
> > Am I missing anything else?
> 
> The question is, why were they copied in the first place?
...
> If there's no reason for the duplication, then yes, merge them.

As Oleg pointed out their is no need for the duplication.

> >> Since Lustre was the single biggest culprit (about 25% of that patch),
> >> I was planning on sending a broken-out patch.
> 
> > I expect this is not all the changes needed. Do you have a newer patch or 
> > should I run with this patch?  Also I will look into replace the 
> > cfs_hash_u[32|64]_* code with standard linux hash code.
> 
> I don't have anything newer ATM.  I agree there's probably more; if
> nothing else I didn't check the copied hash functions at all.  What I
> posted was just what I noticed during a search through the kernel for
> all users of the functions I was planning on changing.

I started a patch with your cleanups. So I started to look at replacing
cfs_hash_u[64|32]_hash() with the standard hash_[64|32]() function. 
First I need to explain the code path to make it clear what is going on.
From the top level the code path in which the cfs_hash_uXX_hash might
be called is:

cfs_hash_bd_get() -> cfs_hash_bd_from_key() -> cfs_hash_id()

cfs_hash_id() is defined as:

static inline unsigned
cfs_hash_id(struct cfs_hash *hs, const void *key, unsigned mask)
{
        return hs->hs_ops->hs_hash(hs, key, mask);
}

and hs_hash is 

struct cfs_hash_ops {
        /** return hashed value from @key */
        unsigned (*hs_hash)(struct cfs_hash *hs, const void *key,
                            unsigned mask);
        ...
}

So ops->hs_hash() is filled in by various lustre layers to generate
some hash value. It is these *hs_hash() that some times uses
cfs_hash_u64_hash() and cfs_hash_u32_hash(). An example of this is
in cl_object.c:

struct cfs_hash_ops pool_hash_operations = {
        .hs_hash        = cl_env_hops_hash,
	...
};

which is defined as:

static unsigned cl_env_hops_hash(struct cfs_hash *lh,
                                 const void *key, unsigned mask)
{
#if BITS_PER_LONG == 64
        return cfs_hash_u64_hash((__u64)key, mask);
#else
        return cfs_hash_u32_hash((__u32)key, mask);
#endif
}

If we change to using hash_64() or hash_32() instead this
will change the behavior we currently have.

Now cfs_hash_u64_hash() is defined as

static inline unsigned
cfs_hash_u64_hash(const __u64 key, unsigned mask)
{
        return ((unsigned)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
}

which uses a mask directly. That mask is generated in cfs_hash_id()
with :

unsigned int index = cfs_hash_id(hs, key, (1U << bits) - 1);

So the mask uses the lower bits. We can't change this behavior
since other hp_ops->hs_hash functions that don't use 
cfs_hash_u[64|32]_hash() at all treat this as a mask.

Now for using the standand functions we have for example:

static __always_inline u64 hash_64(u64 val, unsigned int bits)
{
        u64 hash = val;

#if BITS_PER_LONG == 64
        hash = hash * GOLDEN_RATIO_64;
#else
        ....
#endif

        /* High bits are more random, so use them. */
        return hash >> (64 - bits);
}

which generates the mask on the fly using the higher bits.
I can work the code so the mask can be turned into a bit offset
but the mask will still be different. Will this difference
break things?
