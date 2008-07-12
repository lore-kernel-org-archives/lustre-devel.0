From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 11 Jul 2008 21:56:07 -0600
Subject: [Lustre-devel] Vector I/O api
Message-ID: <C49D8777.63F0%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Tom -

In a recent call with CERN the request came up to construct a call that can
in parallel transfer an array of extents in a single file to a list of
buffers and vice-versa.  This call should be executed with read-ahead
disabled, it will usually be made when the user is well informed of the I/O
that is about to take place.

Is this easy to get into the Lustre client (using our I/O library)?  Do you
have this already for MPI/IO use?

Thanks.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080711/36e8af3e/attachment.htm>
