From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:22 +0000
Subject: [lustre-devel] [PATCH 10/37] lustre: kernelcomm: pass correct
 gfp_t to kmalloc.
In-Reply-To: <alpine.LFD.2.21.1902241704320.22752@casper.infradead.org>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494542.24125.3526135915611952378.stgit@noble.brown>
 <alpine.LFD.2.21.1902241704320.22752@casper.infradead.org>
Message-ID: <87F7798E-C989-4317-9B42-94FA9D0744A5@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 24, 2019, at 09:05, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>> Passing 0 as the gfp_t for kmalloc() is not meaningful, and
>> could change behaviour.
>> Use an explicit GFP_KERNEL instead.
> 
> Why did it every do this ??????

This is a defect introduced by commit 1b254784381 "LU-1346 libcfs: replace cfs_ memory wrappers".
It replaced cfs_alloc(), which internally supplied the GFP_* mask with kmalloc(), which does not.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
