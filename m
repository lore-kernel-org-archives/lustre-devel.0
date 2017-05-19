From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 19 May 2017 02:14:42 +0000
Subject: [lustre-devel] have df report a more up-to-date view of the
 filesystem
In-Reply-To: <9e5f3b8d-b5f5-ce10-2b35-e6f13b7de532@cea.fr>
References: <9e5f3b8d-b5f5-ce10-2b35-e6f13b7de532@cea.fr>
Message-ID: <A5B44F72-4853-44F6-B453-E919F303AA95@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 17, 2017, at 13:16, quentin.bouget at cea.fr wrote:
> 
> Hi everyone,
> 
> In LU-8940 I describe an issue I am having with df in Lustre's tests. In short, df/statfs can report outdated information about a Lustre filesystem; given enough time, its output gets correct. From what I understand, statfs cannot report an "always up-to-date" view of the filesystem as this would cost too much time and resources.
> 
> I would like to know what you guys think of having Lustre's statfs operation report a view of the filesystem at least as new as when the last sync operation completed?
> 
> My point being that users (and tests) would be able to run df --sync to get up-to-date information (at the cost of a sync operation, and maybe some accounting for statfs).

This isn't really a problem with "df".  The client will cache the statfs information for at most 1s until it refreshes it again.

What it appears is happening (from LU-8940) is that unlinking a bunch of files doesn't delete the files and destroy the objects fast enough for the small test filesystem.  If there is a real system being used then it would likely not have any significant problems seen on these small filesystems.

There are methods in test-framework.sh (e.g. wait_delete_completed()) to handle the free space reporting when the filesystem is full.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
