From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 16 Apr 2008 17:40:36 +0100
Subject: [Lustre-devel] Failover & Force export for the DMU
In-Reply-To: <C42B6B30.37C3%peter.braam@sun.com>
References: <C42B6B30.37C3%peter.braam@sun.com>
Message-ID: <1208364036.15849.133.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Qua, 2008-04-16 at 08:37 -0700, Peter Braam wrote:

> However,  the approach is flawed.  It is (theoretically, but not so
> likely) possible for the server to write something, believe it has
> been done, and read it back getting the wrong data (because it wasn?t
> written), and still panic.


With the DMU there is a similar problem, but its behavior is more sane
and much more interesting. If a write is discarded without the DMU's
knowledge, when the data is read back the checksum will necessarily fail
due to the ZFS design's cleverness of storing the checksum on the block
pointer (in the parent block, which itself has its checksum on its
parent block, and so on up until the uberblock).

So if the checksum fails 2 things can happen:

- If a read is a normal read, the caller will get an ECKSUM error,
propagating the error back to the DMU's consumer (this is what is used
for all data reads).

- If a read if a special "must succeed" read, then the behavior will
depend on the "failmode" property of the pool (explained below).

A "must succeed" read, like the name indicates, is a critical read which
always succeeds (caller is blocked until it does), used in situations
where failure would lead to data loss. It is only used for some metadata
reads.


> So I would like to suggest that for the DMU we do this differently and
> rely on a normal read only device.  So, the server, during recovery,
> will be using standard read only devices (and similar under the DMU).
> If the file system or DMU returns errors because writes cannot be
> performed for requests that are in progress during the failover event,
> then these errors should be handled gracefully (without panics).  Note
> that the errors will never reach the client, not over the network and
> not through reply reconstruction, because failover was initiated
> before they happened.


I agree, but I'm not so sure we should still continue to send read
requests to the storage devices when we are failing over. One of the
reasons the failover could be happening is due to a failure somewhere in
the server -> storage path, and if this is happening we may experience
delays of 30 or 60 seconds for the IOs to timeout, especially if we're
doing synchronous I/O in the ZIO threads like we are doing now.

So I think returning EIO for reads on the backend storage might be more
appropriate during a failover.


> Ricardo ? for the DMU all you need to do is make sure you can quickly
> turn a device read only below the DMU and the DMU can handle that (its
> like doing ?mount ?o remount, ro?).


Well, it's a bit more complicated than that..
If there is a fatal failure to write to the backend devices, the error
will be returned to the ZIO pipeline and the DMU's behavior will again
depend on the "failmode" property of the pool, which can have 3
different values:

- wait mode: I/O is blocked until the administrator corrects the problem
manually. This is useful for regular ZFS pools, because the
administrator has a chance to replace the device that is experiencing IO
failures and therefore prevent any data loss.

- continue mode: (quoting) "Returns EIO to any new write I/O
requests" (in the transaction phase) ".. but allows reads to any of the
remaining healthy devices. Any write requests that have yet to be
committed to disk would be blocked."

- panic mode: in userspace, we do an abort(). This would be a good
solution for Lustre if we didn't have multiple ZFS pools in the same
userspace server, but it's not useful at all in that case.

The big problem here is that neither the "wait" mode nor the "continue"
mode allow a pool with dirty data to be exported if the backend devices
are returning errors in the pwrite() calls (be it EROFS, EIO, or any
other), due to ZFS's insistence on preserving data integrity (which I
think is very well designed).

I have thought a lot about this, and my conclusion is that when
force-exporting a pool we should make the DMU discard all writes to the
backend storage, make reads (even "must succeed" reads) return EIO, and
then go through the normal DMU export process. I believe this is the
only sane way of successfully getting rid of dirty data in the DMU
without any loss of transactional integrity or weird failures, but it
will also require changing the DMU to gracefully handle failures in
"must succeed" reads, which will not be easy..

The consequence for Lustre is that the OSS/MDS servers *must* be able to
handle errors gracefully because the DMU could return a lot of EIOs
during failover.

Cheers,
Ricardo
--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080416/821454ce/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080416/821454ce/attachment.gif>
