From: Andreas Dilger <adilger@sun.com>
Date: Mon, 02 Jun 2008 11:09:37 -0600
Subject: [Lustre-devel] Re-direction inodes
In-Reply-To: <C4696703.566A%peter.braam@sun.com>
References: <C4696703.566A%peter.braam@sun.com>
Message-ID: <20080602170937.GI2961@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 02, 2008  08:59 +0900, Peter J. Braam wrote:
> I have a need in doing an architecture for a customer of a Lustre client
> feature to have different data/page caches associated with an inode,
> depending on the user that accesses it.    So when a file is read, user A
> will read different data from user B (assume the same for writes, but I
> think this is a read-only feature).

Initially when I read this, I thought you were only trying to keep the
client-side cache separate, which could be done by adding the UID into
the inode lookup function for ll_test_inode() and treating these files
separately in the client-side cache.  That would be useful to avoid e.g.
user A reading "securefile" into memory, and user B being able to access
it from cache due to client-local access permissions allowing it.

> I remember that in the Coda file system we could easily re-direct I/O to
> another inode using almost standard features in the VFS/page caches.  Is
> this still the case?  Would this work for the purpose I describe above?

On later reading, it seems you want to have completely independent
file contents for each user, but they share the same pathname.  In some
filesystems it is possible to encode part of the pathname somewhat like:

	/home///$UID///file

but I think you are proposing a completely transparent mapping of content:

alice> cat /etc/passwd
alice:x:1000:1000:Alice:/home/alice:/bin/bash

bob> cat /etc/passwd
bob:x:1001:1001:Bob:/home/bob:/bin/bash

correct?

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
