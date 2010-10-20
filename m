From: bzzz.tomas at gmail.com <bzzz.tomas@gmail.com>
Date: Wed, 20 Oct 2010 12:11:01 +0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
Message-ID: <4CBEA415.80307@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/20/10 11:55 AM, Andreas Dilger wrote:
> There is a separate proposal that has been underway in the Linux community for some time, to allow a user process to get a file handle (i.e. binary blob returned from a new name_to_handle() syscall) from the kernel for a given pathname, and then later use that file handle in another process to open a file descriptor without re-traversing the path.
>
> I've been thinking this would be very useful for Lustre (and MPI in general), and have tried to steer the Linux development in a direction that would allow this to happen.  Is this in line with what you are investigating?

with FIDs is quite possible and even safe if application can learn it
(using xattr_get or ioctl). then it should be trivial to export FID
namespace on MDS via special .lustre-fids directory?

another idea was to do whole path traversal on MDS within a single RPC.
bug that'd require amount of changes to llite and/or VFS and keep MDS
a bottleneck.

thanks, z
