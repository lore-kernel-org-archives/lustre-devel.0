From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 16 Apr 2008 08:37:04 -0700
Subject: [Lustre-devel] Failover & Force export for the DMU
Message-ID: <C42B6B30.37C3%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

?Force export? for the DMU serves a similar purpose as a feature we added
for block devices in Linux in relation to exports.  When failover is
initiated, the OSS/MDS servers stop sending replies and requests that are
still being processed interact with the block devices in a model where the
devices discard write commands WITHOUT returning errors.  This is different
from merely declaring the device READONLY in which case errors are returned.
The latter is a default feature in  the Linux kernel, what we did is a patch
(but could be a mapper module).

The thinking behind this approach was (many years ago) that this avoids
exposing the server layers to errors (caused by writes to read only devices)
from the block devices which might cause the server to panic, thereby taking
out other targets inadvertently.

However,  the approach is flawed.  It is (theoretically, but not so likely)
possible for the server to write something, believe it has been done, and
read it back getting the wrong data (because it wasn?t written), and still
panic.

So I would like to suggest that for the DMU we do this differently and rely
on a normal read only device.  So, the server, during recovery, will be
using standard read only devices (and similar under the DMU).  If the file
system or DMU returns errors because writes cannot be performed for requests
that are in progress during the failover event, then these errors should be
handled gracefully (without panics).  Note that the errors will never reach
the client, not over the network and not through reply reconstruction,
because failover was initiated before they happened.

The hacked feature retains value because it can generate an artificially
large amount of rollback data, which is useful for testing the replay
recovery mechanisms in Lustre.  However, with DMU snapshots this can easily
be simulated in a different manner.

Nikita, Alex ? I think the key issue here is that the error handling in the
new servers that you have written needs to be resilient enough to handle
this.  Can you think about it?

Ricardo ? for the DMU all you need to do is make sure you can quickly turn a
device read only below the DMU and the DMU can handle that (its like doing
?mount ?o remount, ro?).

Regards

Peter

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080416/965dd99f/attachment.htm>
