From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Fri, 09 May 2008 10:25:10 -0400
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <C449357C.4160%peter.braam@sun.com>
References: <C449357C.4160%peter.braam@sun.com>
Message-ID: <1210343110.23307.203.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2008-05-08 at 22:55 -0600, Peter Braam wrote:
> 
> His use pattern was interesting ? a number of Windows clients must be
> browsing files stored in Lustre in this remote location.  It was
> expected that the files would be fairly large, would be viewed by
> multiple clients, and that few or no modifications would be made.

Even still it's useful during implementation to think of the use case of
that remote client having read a file and caching and holding a read
lock on that file, say 1GB in size, and then another client wanting to
update say, 1KB in the middle of the file.  It would be beneficial for
that 1GB file to have a small (but still practical) stripe size so that
the amount of cache that needs to be thrown away to accommodate the
write is relatively small.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080509/554406bd/attachment.pgp>
