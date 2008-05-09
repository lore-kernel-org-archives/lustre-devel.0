From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 08 May 2008 22:55:56 -0600
Subject: [Lustre-devel] Wide area use of Lustre and client caches
Message-ID: <C449357C.4160%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

During the LUG I was approached by a customer who wants to use a Lustre file
system at the far end of a WAN link.  Since the situation may be of general
interest, I thought I would post a short report of the discussion here.

His use pattern was interesting ? a number of Windows clients must be
browsing files stored in Lustre in this remote location.  It was expected
that the files would be fairly large, would be viewed by multiple clients,
and that few or no modifications would be made.

After some discussion we proposed a solution that involved a deployment as
follows:

1. A single Lustre client with lots of RAM.  The settings on the client
would be (1) that the memory available for caching by lustre is large (2)
that the number of locks that can be held by this client is fairly large (3)
that this client uses the ?open cache?.
2. A samba server on this Lustre client.

With the settings above, we can expect that many of the files can be cached
in the Lustre client, hence after the initial read, I/O would be local in
the remote site.  With the open file cache enabled, even the open and close
traffic will not go to the servers, but can be handled by the client.   We
think that this will lead to a very good solution, that can work today.

A refinement is possible, that requires some development.  There is a
feature in the Linux kernel to use a disk partition as a cache for a file
system ? it is called cachefs.   This requires a few hooks in Lustre to
store chunks of files that are transferred to the client into this cache,
and cache invalidation calls to remove them.  It allows us to achieve the
same performance as with the solution above, except that the disk will be a
bit slower than memory, but it can also be much larger.

We are eagerly awaiting the results of testing this configuration!

- peter -
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080508/480a7bd2/attachment.htm>
