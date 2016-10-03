From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 3 Oct 2016 20:42:10 +0000
Subject: [lustre-devel] [lustre-discuss] Lustre Client on Fedora 23
In-Reply-To: <711448a1-22cc-12ca-3d5c-6065a2628661@watters.ws>
References: <a8fcbd5e-a6fa-6fb2-4a4f-f7a95df0c0ac@watters.ws>
	<57EC082E.5030605@cray.com>
	<b9197523-3af1-7d33-507f-b4fe6a4e3ad7@watters.ws>
	<9CCD352F-2259-4CE6-AA67-99A7AB8D6944@intel.com>
	<711448a1-22cc-12ca-3d5c-6065a2628661@watters.ws>
Message-ID: <12A06C62-3FDF-4C13-A64A-37D55C3FE75A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is really more of a topic for lustre-devel, so I've CC'd that list and we can move future conversation over there.

This particular issue looks related to changes made by Andreas Gruenbacher (xattr maintainer) that went upstream.  Probably best to follow the commits in "git log drivers/staging/lustre/lustre/llite" and port those patches back to master.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Architect
Intel High Performance Data Division

On 2016/10/03, 11:25, "lustre-discuss on behalf of Michael Watters" <lustre-discuss-bounces at lists.lustre.org on behalf of wattersm@watters.ws> wrote:
>
> Thanks.  It looks like the checkpatch.pl script has already been updated 
> however I did have to change the lustre/osd-ldiskfs/osd_io.c 
> b/lustre/osd-ldiskfs/osd_io.c file which contained two references to the 
> old function names.
>   
> make is now failing with a different error as shown below.
>   
>   CC [M] lustre-release-build/lustre/llite/file.o
>   lustre-release-build/lustre/llite/file.c:3841:14: 
>   error: initialization from incompatible pointer type 
>   [-Werror=incompatible-pointer-types]
>      .setxattr = ll_setxattr,
>                  ^
>   lustre-release-build/lustre/llite/file.c:3841:14: 
>   note: (near initialization for ?ll_file_inode_operations.setxattr?)
>   lustre-release-build/lustre/llite/file.c:3842:14: 
>   error: initialization from incompatible pointer type 
>   [-Werror=incompatible-pointer-types]
>      .getxattr = ll_getxattr,
>                  ^
>   lustre-release-build/lustre/llite/file.c:3842:14: 
>   note: (near initialization for ?ll_file_inode_operations.getxattr?)
>   cc1: all warnings being treated as errors
>   scripts/Makefile.build:289: recipe for target 
>   'lustre-release-build/lustre/llite/file.o' failed
>   
> Any idea how to fix this?
>   
>   
>On 09/30/2016 09:51 PM, Dilger, Andreas wrote:
>> The current Lustre hasn't been updated to the 4.7 kernel yet.  As you
>> see the newer kernel replaced PAGE_CACHE_* with PAGE_*.  A patch to
>> fix that (basically simple search and replace) would be welcome.  You
>> should also add PAGE_CACHE_SHIFT and PAGE_CACHE_SIZE into
>> contrib/scripts/checkpatch.pl::dep_functions so that any future patches
>> trying to add them will be flagged.
>>
>> See http://wiki.lustre.org/Submitting_Changes for details.  I've filed
>> LU-8661 to track patches needed for Linux 4.7 kernels so you can use
>> that for your patch submissions.
>>
>> Cheers, Andreas
