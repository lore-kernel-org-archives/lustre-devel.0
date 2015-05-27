From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 27 May 2015 20:55:27 +0000
Subject: [lustre-devel] Possible minor bug
Message-ID: <D18B8A8A.F359D%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/05/27, 2:03 PM, "Patrick Farrell" <paf at cray.com<mailto:paf@cray.com>> wrote:

While doing some other work, I noticed something I believe is a potential problem in the server side quota code.

Specifically, in qmt_glimpse_lock:

While the resource lock (a spin lock) is held, it does

OBD_ALLOC_PTR(work);

Since allocations can sleep, doesn't this allocation need to be atomic?

So, following the current Lustre convention, it should be:
LIBCFS_ALLOC_ATOMIC(work, sizeof(struct
ldlm_glimpse_work));

You could also use OBD_ALLOC_GFP(work, sizeof(*work), GFP_ATOMIC), which is equivalent, but at least keeps the same paradigm of other allocations in this code.

I have seen no actual bugs from this, but I hit a hang while modifying the equivalent code in ofd_intent_policy for lock ahead, and I think the same hang is theoretically possible here.  My understanding is that, in general, doing allocations while holding a spin lock is not recommended.

Not only not recommended, but not allowed for GFP_NOFS allocations.  Probably if you had CONFIG_DEBUG_SPINLOCK or similar enabled, you would get a warning here due to __might_sleep() in the allocation path.

I'm hoping for other input before I go further - Am I right that this is something which needs fixing?  If so, I'll open an LU and submit a patch.

Yes, please do.

Cheers, Andreas
