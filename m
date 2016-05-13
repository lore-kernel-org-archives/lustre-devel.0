From: George Spelvin <linux@horizon.com>
Date: 13 May 2016 16:25:07 -0400
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <alpine.LFD.2.20.1605132027210.5961@casper.infradead.org>
Message-ID: <20160513202507.26286.qmail@ns.horizon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> Looking at our code I see our duplication is cfs_hash_u32_hash and
> cfs_hash_u64_hash which could be replaced by the standard linux functions.
> Am I missing anything else?

The question is, why were they copied in the first place?

The <linux/hash.h> functions are for in-memory hash tables and *not*
guaranteed stable. between boots.  They could depend on kernel version,
architecture, kernel configuration, and boot-time feature detection.

I thought the reason for the copy might have been to make a stable hash
that could e.g. be sent between hosts.

(em28xx_hash_mem() in drivers/media/usb/em28xx/em28xx-i2c.c is an example
of this.  It's a copy of hash_mem() from <linux/sunrpc/svcauth.h>.))

If there's no reason for the duplication, then yes, merge them.

>> Since Lustre was the single biggest culprit (about 25% of that patch),
>> I was planning on sending a broken-out patch.

> I expect this is not all the changes needed. Do you have a newer patch or 
> should I run with this patch?  Also I will look into replace the 
> cfs_hash_u[32|64]_* code with standard linux hash code.

I don't have anything newer ATM.  I agree there's probably more; if
nothing else I didn't check the copied hash functions at all.  What I
posted was just what I noticed during a search through the kernel for
all users of the functions I was planning on changing.
