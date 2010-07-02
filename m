From: Dmitry Zogin <dmitry.zoguine@oracle.com>
Date: Fri, 02 Jul 2010 16:52:29 -0400
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
Message-ID: <4C2E518D.30802@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Peter,

These are really good questions posted there, but I don't think they are 
Lustre specific. These issues are sort of common to any file systems. 
Some of the mature file systems, like Veritas already solved this by

1. Integrating the Volume management and File system. The file system 
can be spread across many volumes.
2. Dividing the file system into a group of file sets(like data, 
metadata, checkpoints) , and allowing the policies to keep different 
filesets on different volumes.
3. Creating the checkpoints (they are sort of like volume snapshots, but 
they are created inside the file system itself). The checkpoints are 
simply the copy-on-write filesets created instantly inside the fs 
itself. Using copy-on-write techniques allows to save the physical space 
and make the process of the file sets creation instantaneous. They do 
allow to revert back to a certain point instantaneously, as the modified 
blocks are kept aside, and the only thing that has to be done is to 
point back to the old blocks of information.
4. Parallel fsck - if the filesystem consists of the allocation units - 
a sort of the sub- file systems, or cylinder groups,  then the fsck can 
be started in parallel on those units.

Well, the ZFS does solve many of these issues, but in a different way, too.
So, my point is that this probably has to be solved on the backend side 
of the Lustre, rather than inside the Lustre.

Best regards,

Dmitry

Peter Braam wrote:
> I wrote a blog post that pertains to Lustre scalability and data 
> integrity.  You can find it here:
>
> http://braamstorage.blogspot.com
>
> Regards,
>
> Peter
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100702/825eabe5/attachment.htm>
