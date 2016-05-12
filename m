From: George Spelvin <linux@horizon.com>
Date: 11 May 2016 21:33:22 -0400
Subject: [lustre-devel] Lustre use of hash_long() & cfs_hash_u32_hash()
In-Reply-To: <alpine.LFD.2.20.1605120110580.32203@casper.infradead.org>
Message-ID: <20160512013322.5730.qmail@ns.horizon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thank you very much for the response!

> Thanks for looking into this. Do you have a tree some where we can look
> at for the changes?

Linus committed the most important fix to 4.6-rc7 as
689de1d6ca95b3b5bd8ee446863bf81a4883ea25

I'm following up with additional, less urgent cleanups of kernel hashing.

(Fundamentally, I'm trying to reduce the number of different hash
functions, and find a good balance between execution-time performance
and mixing performance of what remains.)

> Details about this change are at
> 
> https://jira.hpdd.intel.com/browse/LU-143
> 
> and the original patch with those changes are at
> 
> http://review.whamcloud.com/#/c/374

Thanks a lot for the pointers!

> Is this the only code that doesn't make sense or is their more?

I expect there's more; that was just what first jumped out at me.
My primary goal was elsewhere, so once it became clear that Lustre would
be a time-consuming side quest, I gave up and sent that e-mail.

But if Lustre would appreciate more attention, I can take another look.


I did do a pass over the kernel and fixed improper use of the current
<linux/hash.h> functions.  I posted it as

Subject: [RFC PATCH 3/2] (Rant) Fix various hash abuses
https://marc.info/?l=linux-kernel&m=146218484201133

Since Lustre was the single biggest culprit (about 25% of that patch),
I was planning on sending a broken-out patch.
