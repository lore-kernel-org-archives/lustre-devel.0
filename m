From: George Spelvin <linux@sciencehorizons.net>
Date: 17 May 2016 04:52:22 -0400
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <alpine.LFD.2.20.1605161735250.9721@casper.infradead.org>
Message-ID: <20160517085222.10484.qmail@ns.sciencehorizons.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> If we change to using hash_64() or hash_32() instead this
> will change the behavior we currently have.

There is hash_long for exactly this purpose.
The problem was that Lustre was using hash_long() on values that are 64
bits even on 32-bit platforms.  I wasn't trying to get rid of all
calls to hash_long, just the buggy ones.

hash_32: Hash 32 bits
hash_64: Hash 64 bits
hash_long: Alias for one of the preceding, depending on BITS_PER_LONG.

The thing is to use the correct one for the argument.

> Now cfs_hash_u64_hash() is defined as
>
> static inline unsigned
> cfs_hash_u64_hash(const __u64 key, unsigned mask)
> {
>         return ((unsigned)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
> }
> 
> which uses a mask directly. That mask is generated in cfs_hash_id() with :
> 
> unsigned int index = cfs_hash_id(hs, key, (1U << bits) - 1);
> 
> So the mask uses the lower bits. We can't change this behavior
> since other hp_ops->hs_hash functions that don't use 
> cfs_hash_u[64|32]_hash() at all treat this as a mask.

This is a bit of a problem.  My hash changes won't make it any worse,
but it's a *current* problem that you probably want to fix.

The thing is, a multiply has lower bits of the input affect higher bits
of the output, but there is no propagation at all in the other direction.
(See http://burtleburtle.net/bob/hash/integer.html for a discussion of
"half-avalanche".)

On other words, for a mask which is a power of 2 minus 1,
(hash_64(x) & mask) == (hash_64(x & mask) & mask).

(This is NOT true if the mask has trailing zero bits.)

Given that a typical mask has far less than 64 bits set, you can
see how this will lead to huge numbers of collisions.


There are a few possible solutions depending on the typical
size of mask:

- Since you're returning only 32 bits at most, shift down 32 bits
  before masking.  This still has you ignoring some high-order bits,
  but it improves things a lot.  (One of my pending patches to hash_64()
  does exactly this.)
- bswap() the result.  May still ignore input bits if the mask is less
  than 8 bits, but it's getting decent.
- (Less efficient on some embedded platforms, but none likely to run Lustre
  in the first place): Use the low bits of the *high* word of the product.
  This has high bits of the hash value unaffected by low bits of the
  argument (except by carry propagation, which is unlikely to
  propagate many bits), but gets you what you need.
- Use a totally different hash function like jhash_2words() that
  achieves more mixing (but is slower).
- Change the Lustre code to use the high bits everywhere.

One alternative to jhash_2words() is Thomas Wang's
64-to-32 bit hash from
https://web.archive.org/web/20071223173210/http://www.concentric.net/~Ttwang/tech/inthash.htm

Translated from Java to C, that's:

u32 hash6432shift(u64 key)
{
	key = ~key + (key << 18);	// key = (key << 18) - key - 1;
	key ^= key >> 31;
	key *= 21;		// key = key + (key << 2) + (key << 4);
	key ^= key >> 11;
	key += key << 6;
	key ^= key >> 22;
	return (u32) key;
}

> I can work the code so the mask can be turned into a bit offset
> but the mask will still be different. Will this difference
> break things?

I'm not sure I understand the question.  As long as the hashing is
always done the same way, the details of *how* the hashing is
done are opaque to the rest of the code.

The problem arises if someone assumes a mathematical relationship
between hash_64(x, bits) and hash_64(x, bits+1), such as when
growing or shrinking a dynamic hash table.  

If the calling code "knows" that hash64(x, mask) can be ANDed with
mask/2 to produce the same number as hash64(x, mask/2) then things
will make a mess.
