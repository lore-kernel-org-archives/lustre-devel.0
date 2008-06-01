From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 02 Jun 2008 08:59:47 +0900
Subject: [Lustre-devel] Re-direction inodes
Message-ID: <C4696703.566A%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikita -

I have a need in doing an architecture for a customer of a Lustre client
feature to have different data/page caches associated with an inode,
depending on the user that accesses it.    So when a file is read, user A
will read different data from user B (assume the same for writes, but I
think this is a read-only feature).

I remember that in the Coda file system we could easily re-direct I/O to
another inode using almost standard features in the VFS/page caches.  Is
this still the case?  Would this work for the purpose I describe above?

Thanks.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080602/d39b9203/attachment.htm>
