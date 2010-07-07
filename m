From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 7 Jul 2010 00:57:02 -0600
Subject: [Lustre-devel] [Lustre-discuss] Integrity and corruption - can
	file systems be scalable?
In-Reply-To: <AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
	<4C2E57B0.6010408@oracle.com>
	<AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
Message-ID: <C09D6129-7A3D-41F5-9CB0-D9B7D346C19D@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-07-02, at 15:39, Peter Braam wrote:
> I wrote a blog post that pertains to Lustre scalability and data integrity.
> 
> http://braamstorage.blogspot.com

In your blog you write:

> Unfortunately once file system check and repair is required, the scalability of all file systems becomes questionable.  The repair tool needs to iterate over all objects stored in the file system, and this can take unacceptably long on the advanced file systems like ZFS and btrfs just as much as on the more traditional ones like ext4.  
> 
> This shows the shortcoming of the Lustre-ZFS proposal to address scalability.  It merely addresses data integrity.

I agree that ZFS checksums will help detect and recover the data integrity, and we are leveraging this to provide data integrity (as described in "End to End Data Integrity Design" on the Lustre wiki).  However, contrary to your statement, we are not depending on the checksums for checking and fixing the distributed filesystem consistency.

The Integrity design you referenced describes the process for doing the (largely) single-pass parallel consistency checking of the ZFS backing filesystems at the same time as doing the distributed Lustre filesystem consistency check, while the filesystem is active.

In the years since you have been working on Lustre, we have already implemented similar ideas as ChunkFS/TileFS to use back-references for avoiding the need to keep the full filesystem state in memory when doing checks and recovering from corruption.  The OST filesystem inodes contain their own object IDs (for recreating the OST namespace in case of directory corruption, as anyone who's used ll_recover_lost_found_objs can attest), and a back-pointer to the MDT inode FID to be used for fast orphan and layout inconsistency detection.  With 2.0 the MDT inodes will also contain the FID number for reconstructing the object index, should it be corrupted, and also the list of hard links to the inode for doing O(1) path construction and nlink verification.  With CMD the remotely referenced  MDT inodes will have back-pointers to the originating MDT to allow local consistency checking, similar to the shadow inodes proposed for ChunkFS.

As you pointed out, scaling fsck to be able to check a filesystem with 10^12 files within 100h is difficult.  It turns out that the metadata requirements for doing a full check within this time period exceed the metadata requirements specified for normal operation.  It of course isn't possible to do a consistency check of a filesystem without actually checking each of the items in that filesystem, so each one has to be visited at least (and preferably at most) once.  That said, the requirements are not beyond what is capable from the hardware that will be needed to host a filesystem this large in the first place, assuming the local and distributed consistency checking can run in parallel and utilize the full bandwidth of the filesystem.

What is also important to note is that both ZFS and the new lfsck are designed to be able to validate the filesystem continuously as it is being used, so there is no need to take a 100h outage before putting the filesystem back into use.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
