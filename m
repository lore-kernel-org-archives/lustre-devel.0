From: Olaf Weber <olaf@sgi.com>
Date: Fri, 22 Jan 2016 15:31:14 +0100
Subject: [lustre-devel] Multi-rail networking for Lustre
In-Reply-To: <CAJ2e-W1rGCimMaEmdG3h2+PLJvcggZBV6j8sV+hfb04Q2qkvEg@mail.gmail.com>
References: <5620CE13.8020706@sgi.com>
	<CAAqp6i1mJf3i+6e7_s2FNy9FmQNJQD3v85EHw9ECTA_GUvEgJg@mail.gmail.com>
	<569E5BCA.5030705@sgi.com>
	<CAJ2e-W2hVPfq1fT_43tAWM1eE7Ue8qD3RsswBXr+Fzwv39kyCQ@mail.gmail.com>
	<569FDCC0.90004@sgi.com>
	<CAJ2e-W0cFuzNDda4fWm-Sd=wmyjYnRyXx9PSLWGAHX5KQO1PGQ@mail.gmail.com>
	<569FF198.5040207@sgi.com>
	<CAJ2e-W3x-O8pWkg8vT40D2g6hbworabsc8MraqGZPw1QSbCFdg@mail.gmail.com>
	<56A10B37.60709@sgi.com>
	<CAJ2e-W2q2JPBuye6gLfPYYqU1vk8YgBqE4=_u7Jdsu-vt8JdCw@mail.gmail.com>
	<56A13FDB.2050902@sgi.com>
	<CAJ2e-W1rGCimMaEmdG3h2+PLJvcggZBV6j8sV+hfb04Q2qkvEg@mail.gmail.com>
Message-ID: <56A23D32.9080508@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 22-01-16 10:08, Alexey Lyashkov wrote:
>
>
> On Thu, Jan 21, 2016 at 11:30 PM, Olaf Weber <olaf@sgi.com
> <mailto:olaf@sgi.com>> wrote:
>
>     On 21-01-16 20:16, Alexey Lyashkov wrote:

[...]

> In lustre terms each mount point is separated client. It have own cache, own
> structures, and completely separated each from an other.
> One exceptions it's ldlm cache which live on global object id space.

Another exception is flock deadlock detection, which is always a global 
operation. This is why ldlm_flock_deadlock() inspects c_peer.nid.

[...]

> All lustre stack operate with UUID, and it have none differences when it
> UUID live. We may migrate service / client from one network address to
> another, without logical reconnect. It's my main objections against you ideas.
> If none have a several addresses LNet should be responsible to reliability
> delivery a one-way requests. which is logically connect to PtlRPC. If node
> will be need to use different routing and different NID's for communication
> - it's should be hide in LNet, and LNet should provide as high api as possible.

The basic idea behind the multi-rail design is that LNet figures out how to 
send a message to a peer. But the user of LNet can provide a hint to 
indicate that for a specific message a specific path is preferred.

One of our goals is to keep changes to the LNet API small.

>         I expect you know about situation when one DNS name have several
>         addresses
>         like several 'A' records in dns zone file.
>
>
>     Sure, but when one name points to several machines, it does not help me
>     balance traffic over the interfaces of just one machine.
>
>
> Simple balance may be DNS based - just round robin, as we have now on IB /
> sock lnd. it isn't balance?
 > If you talk about more serious you should start from good flow control
 > between nodes. Probably Ideas from RIP and LACK protocols will help.

There is bonding/balancing in socklnd. There is none in o2iblnd.

[...]

>     A PtlRPC RPC has structure. The first LNetPut() transmits just the
>     header information. Then one or more LNetPut() or LNetGet() messages are
>     done to transmit the rest of the request. Then the response follows,
>     which also consists of several LNetPut() or LNetGet() messages.
>
> It's wrong. Looks you mix an RPC and bulk transfers.

Difference in terminology: I tend to think of an RPC as a request/response 
pair (if there is a response), and these in turn include all traffic related 
to the RPC, including any bulk transfers.

[...]

>     The lustre_uuid_to_peer() function enumerates all NIDs associated with
>     the UUID. This includes the primary NID, but also includes the other
>     NIDs. So we find a preferred peer NID based on that. Then we modify the
>     code like this:
>
> Why PtlRPC should be know that low level details? Currently we have a
> problems - when one of destination NID's is unreachable and transfer
> initiator need a full ptlrpc reconnect to resend to different NID. But as
> you should be have a resend

Within LNet a resend can be triggered from lnet_finalize() after a failed 
attempt to send the message has been decommitted. (Otherwise multiple send 
attempts will need to be tracked at the same time.)

>     The call of LNetPrimaryNID() gives the primary peer NID for the peer
>     NID. For this to work a handful of calls to LNetPrimaryNID() must be
>     added. After that it is up to LNet to find the best route.
>
>
> Per our's comment PrimaryNID will changed after we will find a best, did you
> think it loop usefull if you replace loop result at anycases ?
> from other view ptlrpc_uuid_to_peer called only in few cases, all other time
> ptlrpc have a cache a results in ptlrpc connection info.

The main benefit of the loop becomes detecting whether the node is sending 
to itself, in which case the loopback interface must be used. Though I do 
worry about degenerate or bad configurations where not all the IP addresses 
belong to the same node.

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696796
                            Veldzigt 2b       Fax:    +31(0)30-6696799
Sr Software Engineer       3454 PW de Meern  Vnet:   955-6796
Storage Software           The Netherlands   Email:  olaf at sgi.com
