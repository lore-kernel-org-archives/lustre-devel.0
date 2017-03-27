From: Andreas Dilger <adilger@dilger.ca>
Date: Sun, 26 Mar 2017 19:12:28 -0600
Subject: [lustre-devel] [RFC] Proposal to add a new mount option
	'norootwrite'
In-Reply-To: <a03b58c7-e160-c55c-36f5-d0537f8d8987@nasa.gov>
References: <a03b58c7-e160-c55c-36f5-d0537f8d8987@nasa.gov>
Message-ID: <6682A67D-F0FB-4B0A-9D05-64AA4DC6686F@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

[Limit discussion to lustre-devel, since this is Lustre-specific]

On Mar 23, 2017, at 5:25 PM, Jay Lan <jay.j.lan@nasa.gov> wrote:
> NASA Ames manages a large collection of tightly integrated Linux based systems. 100's of server nodes for Lustre, 10's of NFS servers, and >10,000 compute nodes and 10's of other role specifics systems, many of which mount several different network based filesystems. Some of these filesystems are far too large to effectively backup (e.g. >20PB), because of cost or data turnover rates. Being Linux, there are many interrelated scripts and configuration management tools running with root level privileges on all of the systems.
> 
> There are significant risks associated with user data loss caused by unintended root write privilege. Some of these scenarios include:
> 1) admin typing incorrect command, or in the wrong window
> 2) errant root script
> 3) system configuration management tools (e.g. bcfg2), running in ways or on systems that remove data as part of configuration management.
> 
> Over the years, we have been bitten by all of these. A recent event with bcfg2 has motivated us to develop a mechanism to protect against this class of problems. Specifically, against root removing user data on network mounted filesystems.
> 
> After discussing internally, we find that there are a large number of our systems where root should not be able to unlink remotely mounted files, but root does need to be able to scan directories and read files. Root squash to nobody does not meet the needs we have in managing systems, which includes administrators debugging complex large scale problems across multiple systems.
> 
> We developed prototype code in the VFS layer that effectively prevents root from writing or updating directories or files on network mounted filesystems, as a mount option, called norootwrite. This can then be individually configured for each filesystem we want to protect. This has been developed/tested on NFS, Lustre and a locally mounted ext3 filesystem.
> 
> Some consideration was also given to potentially limit a client mount privileged by developing an /etc/exports like permission to prevent certain hosts or ip ranges from mounting without norootwrite, but this quickly ramped up the implementation complexity, so we rejected that.
> This is considered a weakness. Specifically, a remote system could unintentionally mount without norootwrite and then remove user data. I think a complete implementation should include this.

Note that this sounds like something that could be implemented fairly easily
in the Lustre "nodemap" infrastructure that IU developed for UID/GID mapping
and landed in the Lustre 2.9 release.  Nodemap is useful for other server-side
enforcement mechanisms, such as root squash, and I suspect it wouldn't be hard
to add in a check to only disallow unlink by root users.  That would avoid the
need to even mount clients with "-o norootwrite" at all - it would be a policy
implemented on the MDS by the admin, regardless of whether the client machine
was configured this way or not.  It would still be possible to whitelist some
client machines to allow root unlinking of files if needed.

Cheers, Andreas

> Features of Norootwrite in our prototype are
> 1. You need to enable norootwrite option for it to work. 'Rootwrite' is the default.
> 
> 2. With 'norootwrite' enabled, root is treated like a normal user on write permission.
> 
> 3. The norootwrite option can be added to /etc/fstab entries.
> 
> 4. It can also be enabled/disabled on the fly via 'mount -o remount' specifying norootwrite or rootwrite.
> 
> In addition to a kernel patch, mount commands need to be taught to understand this new mount option: /bin/mount, /sbin/mount.nfs, and /sbin/mount.lustre.
> 
> The prototype was developed in SLES11 SP4. I am working on a version for SLES12 SP2 for more testing. Obviously, we don't want to carry these patches indefinitely and are looking for guidance from the community on whether something like this could land mainline or be changed in some way to be more acceptable than the current form.
> 
> Comments are very appreciated. A kernel patch against the latest upstream kernel release will be posted here after we concluded testing.
> 


Cheers, Andreas





-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 195 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170326/b69e2ff7/attachment.pgp>
