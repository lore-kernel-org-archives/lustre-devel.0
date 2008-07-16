From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 16 Jul 2008 13:29:31 -0600
Subject: [Lustre-devel] Simplified HSM for Lustre?
Message-ID: <C4A3A83B.6652%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In the discussions Rick and I had we identified a simpler approach for HSM
in Lustre which doesn?t have all the niceties that the Lustre team planned,
but might be achievable in short order.

Nathan Rutman has implemented an event log for the purpose of replication.
Nathan can add ?close? events to this, which are written when a file closes
(or when the size on MDS system recovers file sizes from the OSS?s).  This
is a sufficient indicator that a file that was opened for write should be
archived.  It is not necessary ? we might occasionally re-archive a file
that was not written to while open.

Nathan also has a tool that retrieves the event log from the kernel for
consumption by other agents ? replication and HSM event managers could both
use this.

The second thing we need is restore on demand.  This can be done when
opening a file, instead of doing it when I/O is done to the file.  This
centralizes these events on the MDS and makes the architecture of this a
little simpler for that reason (no initiator to coordinator communication
needed).  Of course the MDS should track if an open file has already been
requested from the HSM to filter events, and it should manage adaptive
timeouts for the opening clients.

e2scan can be used to generate lists of files to be purged.  This is
essentially un-changed from the existing architecture.

Finally we need a mover (possibly HSM specific ? e.g. for ADM we would want
to move from a Lustre client on Linux to an ADM mover node running Solaris).
The mover needs to open files by FID (something that Nathan has implemented
for his replication project) and the mover needs to manage EA?s in the file
system, both when archiving and when restoring files.   This EA management
is also needed when files are migrated or replicated within one file system.

The easiest way is for Lustre to feed events to ADM?s policy manager, since
that is know to do most of the right things already.  To combine Lustre with
other HSM?s this requires some glue.  Yet this glue is not essentially
different from what future initiator / coordinator / agent / space manager
systems would do, and might be a valuable interim deliverable.

We concluded that making this an interim focus for HSM could give Lustre
basic HSM functionality long before the full project is complete, and
perhaps nicely aligned with ADM?s planned release(s) during the coming year.
Our team?s project managers will discuss this.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080716/d1c8bfc0/attachment.htm>
