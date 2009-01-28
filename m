From: Peter J. Braam <peter.braam@gmail.com>
Date: Wed, 28 Jan 2009 11:39:28 -0700
Subject: [Lustre-devel] subtree locks
Message-ID: <7bb097cc0901281039u1008aab6i29f0b09f0bef7764@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I want to point out that only subtree locks allow memory usage on the server
to scale with the number of clients instead of the number of files in the
file system.  For HPC usage this is not important, but in many other cases
it very much is.

Sooner or later, without subtree locks, the MDS will run out of memory too
soon using individual file locks or encounter too much overhead in lock
scanning operations.

Listening to the discussion I think you are betting on "later" rather than
"sooner" and that may be the right decision for now.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090128/789e8630/attachment.htm>
