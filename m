From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 15 Apr 2008 21:20:41 -0600
Subject: [Lustre-devel] pCIFS file layout questions
Message-ID: <C42ACCA9.379D%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Matt -

I finally had time to read your document about pCIFS and CTDB more carefully
and I now understand the problems you are trying to address better.

I still want to ask a few questions, to check that my understanding is more
or less correct and make some suggestions.

Regards,

Peter

A. The CIFS client recovery is unclear to me.  If a Samba node disappears
(a)  does the client know to try to re-establish the connection? I think
this is based on a timeout (b) if a request was sent from the client to the
servers, how can the client re-construct the reply or know that the server
never executed the request?  My claim is that the CIFS protocol is not
strong enough to shield the applications from errors and the recovery is an
approximate recovery, of the type ?things started to work again?.

B. On the Samba CTDB nodes, how does the clustering software interact with
software that monitors the functioning of the cluster file system?  For
example, if Samba gets errors doing I/O to Lustre how is a failover
initiated?

C. Now focus on the ?Lustre clients on the OSS approach? (which customers
want ? they don?t want extra Lustre clients)  My thought is that with pCIFS
we in fact do not want to use CTDB in the normal manner on the OSS nodes at
all.  We do want it for metadata nodes.    Assuming that Samba is reasonably
fast (we will discover this over the coming weeks) there is one optimal
Lustre node to read/write data from, namely the OSS node that holds the
data.  If that node fails for whatever reason, Lustre/heartbeat will create
a new node mountain the target and heartbeat can arrange the IP takeover.
So all we need is a Samba server that fails over from the old OSS to the new
OSS.  Every other solution would cause OSS-to-OSS cross talk.  Is this
correct?

D. Finally another question to verify my understanding.  If we take a normal
CTDB setup, then many clients can open the SAME file CONCURRENTLY for I/O
provided they use a windows share mode that allows this?  But in Samba (and
probably in CIFS) there is no re-direction protocol that we can use to tell
an unmodified client to use different Samba servers to fetch different parts
of the file.

E. Some architectural thoughts.

I believe that if clients read unique pieces of files, the CTDB model
without pCIFS is highly sub-optimal.  pCIFS which can force clients to do
I/O with the right node is much preferable.  However, there are some
extremely interesting exceptions to the rule.  I want to illustrate my
thoughts.

If each client reads its own file (this is called the ?file per process? I/O
model in HPC) CTDB without pCIFS is most unfortunate (with the current
Lustre data model, which would recommend to store such a file on one node).
The chance that the client has connected to the correct client node is small
and almost always we will needlessly pull or push the data from the Samba
node to the OSS node that has the data.

For an HPC job where all nodes read a single file fully (another very common
scenario), the CTDB model D works out great.  The Samba nodes all act as a
read cache.  The OSS to OSS transfer is not so expensive in this case, the
overhead is more or less  #OSS nodes / #clients, typically 1-5%.

But for writing things are completely different.

In many (almost all in fact) HPC jobs when files are written they are
written they are written as disjoint pieces, so if Lustre was more clever
and we used it with CTDB, it could accept data from all writers and write it
into the local OSS and simply tell the MDS what the layout of the file
should be.  This could also be applied to Lustre without CIFS exports:
clients that don?t run on an OSS and write to a file would be told to do all
writes through a certain OSS, nicely load balanced over all OSSs.

There are many implementations that can lead to the layout management in the
previous paragraph.  One is to start using a single lock manager for an
entire file (not a per-oss lock manager for stripes) and to let the lock
manager build the layout based on the extents it is seeing in requests.
This is possible provided the cluster has a liveness mechanism.  A second
implementation is a hierarchical protocol where the OSS negotiates layouts
with the MDS as it goes along (and performs re-directs if the I/O must go
somewhere else).
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080415/b64b66b8/attachment.htm>
