From: James Vanns <james.vanns@framestore.com>
Date: Mon, 13 May 2013 14:19:38 +0100 (BST)
Subject: [Lustre-devel] Export over NFS sets rsize to 1MB?
In-Reply-To: <1212911910.19338063.1368451002112.JavaMail.root@framestore.com>
Message-ID: <1975652007.19339235.1368451178426.JavaMail.root@framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello dev list. Apologies for a post to perhaps the wrong group but I'm having a
bit of difficulty locating any document or wiki describing how and/or where the
preferred read and write block size for NFS exports of a Lustre filesystem are
set to 1MB?

Basically we have two Lustre filesystems exported over NFSv3. Our lustre block size
is 4k and the max r/w size is 1MB. Without any special rsize/wsize options set for
the export the default one suggested to clients (MOUNT->FSINFO RPC) as the preferred
size is set to 1MB. How does Lustre figure this out? Other non-Lustre exports are generally
much less; 4, 8, 16 or 32 kilobytes.

Any hints would be appreciated. Documentation or code paths welcome as are annotated /proc locations.

Thanks,

Jim

PS. This is Lustre 1.8.8 on Linux 2.6.32

-- 
Jim Vanns
Senior Software Developer
Framestore
