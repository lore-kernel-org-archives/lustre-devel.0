From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 22 Sep 2008 07:40:25 +0800
Subject: [Lustre-devel] Doubly indexed tree / changelogs
Message-ID: <C4FCFC69.7CC2%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikita, Nathan -

After some pondering I have come to two conclusions.

To encode filesets, we need a tree that makes two iterations fast:

1. list all filesets that contain a certain object
2. list all objects in a certain fileset

Is there a doubly indexed tree for this?

Secondly, to make the changelogs useful and scalable for filesets we will
need to be able to list all changelog entries associated with a certain
inode efficiently.  I see two ways to do this ? one is an auxiliary
directory file mapping inodes to many changelog entries, the second is to
embed forward and backward pointers in the changelog entries to build a
linked list rooted at the inode (using an EA in the inode pointing to the
first and last element of the list).  Both have some overheads.  What are
your thoughts?

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080922/8c54f19d/attachment.htm>
