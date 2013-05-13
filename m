From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 13 May 2013 21:58:44 +0000
Subject: [Lustre-devel] Export over NFS sets rsize to 1MB?
In-Reply-To: <1975652007.19339235.1368451178426.JavaMail.root@framestore.com>
Message-ID: <CDB6B2AB.32164%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2013/13/05 7:19 AM, "James Vanns" <james.vanns@framestore.com> wrote:
>Hello dev list. Apologies for a post to perhaps the wrong group but I'm
>having a
>bit of difficulty locating any document or wiki describing how and/or
>where the
>preferred read and write block size for NFS exports of a Lustre
>filesystem are
>set to 1MB?

1MB is the RPC size and "optimal IO size" for Lustre.  This would normally
be exported to applications via the stat(2) "st_blksize" field, though it
is typically 2MB (2x the RPC size in order to allow some pipelining).  I
suspect this is where NFS is getting the value, since it is not passed up
via the statfs(2) call.

>Basically we have two Lustre filesystems exported over NFSv3. Our lustre
>block size
>is 4k and the max r/w size is 1MB. Without any special rsize/wsize
>options set for
>the export the default one suggested to clients (MOUNT->FSINFO RPC) as
>the preferred
>size is set to 1MB. How does Lustre figure this out? Other non-Lustre
>exports are generally much less; 4, 8, 16 or 32 kilobytes.

Taking a quick look at the code, it looks like NFS TCP connections all
have a maximum max_payload of 1MB, but this is limited in a number of
places in the code by the actual read size, and other maxima (for which I
can't easily find the source value).

>Any hints would be appreciated. Documentation or code paths welcome as
>are annotated /proc locations.

To clarify from your question - is this large blocksize causing a
performance problem?  I recall some applications having problems with
stdio "fread()" and friends reading too much data into their buffers if
they are doing random IO.  Ideally stdio shouldn't be reading more than it
needs when doing random IO.

At one time in the past, we derived the st_blksize from the file
stripe_size, but this caused problems with the NFS "Connectathon" or
similar.  It is currently limited by LL_MAX_BLKSIZE_BITS for all files,
but I wouldn't recommend reducing this directly, since it would also
affect "cp" and others that also depend on st_blksize for the "optimal IO
size".  It would be possible to reintroduce the per-file tunable in
ll_update_inode() I think.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
