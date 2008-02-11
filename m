From: Andreas Dilger <adilger@sun.com>
Date: Mon, 11 Feb 2008 11:18:50 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47AC7B75.30603@cea.fr>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
Message-ID: <20080211181850.GA6552@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 08, 2008  16:55 +0100, Aurelien Degremont wrote:
> But the touch could be problematic. Lustre gurus, is there another time 
> field we could use instead ? Should we add a 
> "last-modification-field-which-ignore-touch" ? Is this really a problem 
> is we use display a "touched" time ? In this case, we display what the 
> user set on the file, we suppose he did it in purpose.

There was work done in ext4/ldiskfs to add a 64-bit "version" field to
the on-disk inode, for use by lustre and NFSv4.  In the ldiskfs case
Lustre was free to store any information in this field it wanted.  The
planned use for this field is for "version based recovery" and it has
the semantic that it is an increasing (though not necessarily sequential)
version number that tracks any change to the file.  This is stored in
each inode on the MDT and each object on the OSTs.

In ZFS I believe there is also a "last modified transaction group" (txg)
number stored with each dnode that could be used in a similar manner.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
