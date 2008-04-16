From: Matt Wu <Qiang.Wu@Sun.COM>
Date: Wed, 16 Apr 2008 21:57:38 +0800
Subject: [Lustre-devel] pCIFS file layout questions
In-Reply-To: <C42ACCA9.379D%peter.braam@sun.com>
References: <C42ACCA9.379D%peter.braam@sun.com>
Message-ID: <480605D2.3090902@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

> A. The CIFS client recovery is unclear to me.  If a Samba node 
> disappears (a)  does the client know to try to re-establish the 
> connection? I think this is based on a timeout (b) if a request was sent 
> from the client to the servers, how can the client re-construct the 
> reply or know that the server never executed the request?  My claim is 
> that the CIFS protocol is not strong enough to shield the applications 
> from errors and the recovery is an approximate recovery, of the type 
> ?things started to work again?.

The original request will be canceled if it timeouts or connection
is broken. Windows CIFS client won't re-send this request. But it
will try to reconnect when there comes new requests from user.

There are two scenarios:

1, network is broken when windows CIFS client sends request packet

    in this case the client will try to reconnect and then resend
    the request package to server. if even the reconnection couldn't
    work, it just fails the request.

2, network is broken when client thread waits on reply

    the original request will be canceled with a network error code
    returned to user.

When the request is failed, pCIFS can detect the failure and then
retry it once more or try another CIFS server. pCIFS re-send is
being done above CIFS protocol and it relies on windows CIFS client
driver to reconnect in case the failed request is to be sent to the
same server.

> B. On the Samba CTDB nodes, how does the clustering software interact 
> with software that monitors the functioning of the cluster file system? 
>  For example, if Samba gets errors doing I/O to Lustre how is a failover 
> initiated?
> 

The recovery master node uses a timer to detect all other CTDB nodes.
Once there's a node down, the recovery master will issue a recovery
process to re-assign the dead node's ip and clients connections to
another node.

When a Samba process (Samba process acts as a CTDB client) crashes,
the CTDB will get acknowledged from the closure of unix-socket, but
here it only clean up all the client context since it might be a
normal quiting. Then CTDB's monitor process will discover the fact
that nothing is servicing on Samba port and then change node status
to trigger a recovery process.


> C. Now focus on the ?Lustre clients on the OSS approach? (which 
> customers want ? they don?t want extra Lustre clients)  My thought is 
> that with pCIFS we in fact do not want to use CTDB in the normal manner 
> on the OSS nodes at all.  We do want it for metadata nodes.    Assuming 
> that Samba is reasonably fast (we will discover this over the coming 
> weeks) there is one optimal Lustre node to read/write data from, namely 
> the OSS node that holds the data.  If that node fails for whatever 
> reason, Lustre/heartbeat will create a new node mountain the target and 
> heartbeat can arrange the IP takeover.  So all we need is a Samba server 
> that fails over from the old OSS to the new OSS.  Every other solution 
> would cause OSS-to-OSS cross talk.  Is this correct?
> 

yes. Both pCIFS re-send and CTDB takeover will migrate client's requests
to another OSS node. After the stand-by OSS node starts, new requests can
be sent to this node and thus to be processed as normally.


> D. Finally another question to verify my understanding.  If we take a 
> normal CTDB setup, then many clients can open the SAME file CONCURRENTLY 
> for I/O provided they use a windows share mode that allows this?  But in 
> Samba (and probably in CIFS) there is no re-direction protocol that we 
> can use to tell an unmodified client to use different Samba servers to 
> fetch different parts of the file.

We can let Samba ignore the share modes to grant exclusive requests. Let
Lustre clients harmonize their concurrent access. This issue is addressed
in HLD/ctdb_share_conflict.lyx

> E. Some architectural thoughts.
> 
> I believe that if clients read unique pieces of files, the CTDB model 
> without pCIFS is highly sub-optimal.  pCIFS which can force clients to 
> do I/O with the right node is much preferable.  However, there are some 
> extremely interesting exceptions to the rule.  I want to illustrate my 
> thoughts.
> 
> If each client reads its own file (this is called the ?file per process? 
> I/O model in HPC) CTDB without pCIFS is most unfortunate (with the 
> current Lustre data model, which would recommend to store such a file on 
> one node).  The chance that the client has connected to the correct 
> client node is small and almost always we will needlessly pull or push 
> the data from the Samba node to the OSS node that has the data.
> 

This case we could also redirect metadata operations though these
operations will finally be done by the MDS node. But the OSS/client
node could cache everything.

> For an HPC job where all nodes read a single file fully (another very 
> common scenario), the CTDB model D works out great.  The Samba nodes all 
> act as a read cache.  The OSS to OSS transfer is not so expensive in 
> this case, the overhead is more or less  #OSS nodes / #clients, 
> typically 1-5%.
> 
> But for writing things are completely different.  
> 
> In many (almost all in fact) HPC jobs when files are written they are 
> written they are written as disjoint pieces, so if Lustre was more 
> clever and we used it with CTDB, it could accept data from all writers 
> and write it into the local OSS and simply tell the MDS what the layout 
> of the file should be.  This could also be applied to Lustre without 
> CIFS exports: clients that don?t run on an OSS and write to a file would 
> be told to do all writes through a certain OSS, nicely load balanced 
> over all OSSs.  
> 
> There are many implementations that can lead to the layout management in 
> the previous paragraph.  One is to start using a single lock manager for 
> an entire file (not a per-oss lock manager for stripes) and to let the 
> lock manager build the layout based on the extents it is seeing in 
> requests.  This is possible provided the cluster has a liveness 
> mechanism.  A second implementation is a hierarchical protocol where the 
> OSS negotiates layouts with the MDS as it goes along (and performs 
> re-directs if the I/O must go somewhere else).

That's like something enhanced join-file (current pCIFS doesn't support
join file). One lock manager can ease file size/extents operations but
all these locks are invisible to pCIFS. When writing to file end, we
need send a "SET_LENGTH" request to lock manager to alloc the necessary
extent on a spare OSS target.

Regards,
Matt
