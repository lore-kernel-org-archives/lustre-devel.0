From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 13 May 2016 20:35:03 +0000
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <20160513202507.26286.qmail@ns.horizon.com>
References: <20160513202507.26286.qmail@ns.horizon.com>
Message-ID: <73B34265-39B4-4273-B1F4-0F209232008F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On May 13, 2016, at 4:25 PM, George Spelvin wrote:

>> Looking at our code I see our duplication is cfs_hash_u32_hash and
>> cfs_hash_u64_hash which could be replaced by the standard linux functions.
>> Am I missing anything else?
> 
> The question is, why were they copied in the first place?
> 
> The <linux/hash.h> functions are for in-memory hash tables and *not*
> guaranteed stable. between boots.  They could depend on kernel version,
> architecture, kernel configuration, and boot-time feature detection.
> 
> I thought the reason for the copy might have been to make a stable hash
> that could e.g. be sent between hosts.

they were copied because of other platforms. There used to be a
userspace library, a mac port and so on. That's why we have this
(now trimmed down) compatibility layer that we are chipping at.
the hashes are purely node-local and are not sent over the wire.

Thanks!

Bye,
    Oleg
