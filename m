From: Michael Watters <wattersm@watters.ws>
Date: Tue, 4 Oct 2016 11:41:17 -0400
Subject: [lustre-devel] [lustre-discuss] Lustre Client on Fedora 23
In-Reply-To: <12A06C62-3FDF-4C13-A64A-37D55C3FE75A@intel.com>
References: <a8fcbd5e-a6fa-6fb2-4a4f-f7a95df0c0ac@watters.ws>
	<57EC082E.5030605@cray.com>
	<b9197523-3af1-7d33-507f-b4fe6a4e3ad7@watters.ws>
	<9CCD352F-2259-4CE6-AA67-99A7AB8D6944@intel.com>
	<711448a1-22cc-12ca-3d5c-6065a2628661@watters.ws>
	<12A06C62-3FDF-4C13-A64A-37D55C3FE75A@intel.com>
Message-ID: <a931f284-b345-b349-5d62-3c0bd86ad09d@watters.ws>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks.  I'm using the latest commit from master but unfortunately it 
doesn't compile properly.

make[3]: Entering directory '/usr/src/kernels/4.7.3-100.fc23.x86_64'
   CC [M] /home/projects/lustre-release-build/lustre/fid/fid_request.o
   CC [M] /home/projects/lustre-release-build/lustre/fid/lproc_fid.o
   LD [M]  /home/projects/lustre-release-build/lustre/fid/fid.o
   CC [M] /home/projects/lustre-release-build/lustre/fld/fld_request.o
   CC [M] /home/projects/lustre-release-build/lustre/fld/fld_cache.o
   CC [M] /home/projects/lustre-release-build/lustre/fld/lproc_fld.o
   LD [M]  /home/projects/lustre-release-build/lustre/fld/fld.o
   CC [M] /home/projects/lustre-release-build/lustre/llite/dcache.o
   CC [M]  /home/projects/lustre-release-build/lustre/llite/dir.o
   CC [M]  /home/projects/lustre-release-build/lustre/llite/file.o
/home/projects/lustre-release-build/lustre/llite/file.c:3841:14: error: 
initialization from incompatible pointer type 
[-Werror=incompatible-pointer-types]
   .setxattr = ll_setxattr,
               ^
/home/projects/lustre-release-build/lustre/llite/file.c:3841:14: note: 
(near initialization for ?ll_file_inode_operations.setxattr?)
/home/projects/lustre-release-build/lustre/llite/file.c:3842:14: error: 
initialization from incompatible pointer type 
[-Werror=incompatible-pointer-types]
   .getxattr = ll_getxattr,
               ^
/home/projects/lustre-release-build/lustre/llite/file.c:3842:14: note: 
(near initialization for ?ll_file_inode_operations.getxattr?)
cc1: all warnings being treated as errors

I'm not a C developer so I don't really know how to fix this but it 
looks like ll_setxattr is defined in xattr.c.


On 10/03/2016 04:42 PM, Dilger, Andreas wrote:
> This is really more of a topic for lustre-devel, so I've CC'd that list and we can move future conversation over there.
>
> This particular issue looks related to changes made by Andreas Gruenbacher (xattr maintainer) that went upstream.  Probably best to follow the commits in "git log drivers/staging/lustre/lustre/llite" and port those patches back to master.
>
> Cheers, Andreas
