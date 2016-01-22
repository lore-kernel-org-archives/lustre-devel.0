From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Fri, 22 Jan 2016 12:08:49 +0300
Subject: [lustre-devel] Multi-rail networking for Lustre
In-Reply-To: <56A13FDB.2050902@sgi.com>
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
Message-ID: <CAJ2e-W1rGCimMaEmdG3h2+PLJvcggZBV6j8sV+hfb04Q2qkvEg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 21, 2016 at 11:30 PM, Olaf Weber <olaf@sgi.com> wrote:

> On 21-01-16 20:16, Alexey Lyashkov wrote:
>
>>
>>         why uuid can't be used as we have already such type of identifier
>>         for the peer?
>>
>>
>>     Rechecking the code to see how UUIDs are generated and where they are
>>     used, as far as I can tell Lustre doesn't have true per-peer UUIDs.
>>
>>
>>     A client doesn't identify itself by UUID to the servers. Instead it
>>     identifies a mount of a lustre filesystem by UUID. If it mounts two
>>     filesystems it will use different UUIDs for each.
>>
>> Client is identify by UUID. if server want to send something to client -
>> it
>> uses an export and client uuid.
>> none NID's uses in that case. if you check code again - you will don't see
>> any NID's until ptlrpc_send_reply issued. So it's single function where
>> NID
>> from connection present.
>>
>
> The UUID does not identify a client. The UUID identifies a client+mount.
> If the client mounts more than one filesystem, there will be different UUID
> for each mount on that client.
>
> In lustre terms each mount point is separated client. It have own cache,
own structures, and completely separated each from an other.
One exceptions it's ldlm cache which live on global object id space.



> At PtlRPC level, these are different connections. At LNet level, the same
> set of NIDs is used. It is that LNet level that I work on.
>
>



>     And the UUID used for servers is derived from the first NID of the list
>>     of NIDs for that server. If the same server shows up in multiple lists
>>     (for different objects) with the NIDs in different orders, then
>>     different UUIDs will be generated.
>>
>>
>> really?
>> LustreError: 137-5: lustre-OST0000_UUID: not available for connect from
>> 0 at lo
>> (no target). If you are running an HA pair check that the target is
>> mounted
>> on the other server.
>>
>> where is NID present at UUID from that message ?
>>
>
> The NID 'req->rq_peer.nid' is translated to '0 at lo' in this message.
>

I say about NID substring in UUID message, it's not exist for long time.


>
> The "lustre-OST0000_UUID" is more interesting. Note that it identifies an
> OST, as opposed to an OSS. Which is the point I am trying to make: this
> UUID identifies an OST; it does not identify an OSS.


All lustre stack operate with UUID, and it have none differences when it
UUID live. We may migrate service / client from one network address to
another, without logical reconnect. It's my main objections against you
ideas.
If none have a several addresses LNet should be responsible to reliability
delivery a one-way requests. which is logically connect to PtlRPC. If node
will be need to use different routing and different NID's for communication
- it's should be hide in LNet, and LNet should provide as high api as
possible.




>
>
>>
>> I expect you know about situation when one DNS name have several addresses
>> like several 'A' records in dns zone file.
>>
>
> Sure, but when one name points to several machines, it does not help me
> balance traffic over the interfaces of just one machine.


Simple balance may be DNS based - just round robin, as we have now on IB /
sock lnd. it isn't balance?
If you talk about more serious you should start from good flow control
between nodes. Probably Ideas from RIP and LACK protocols will help.





>
>
>     I want something that identifies the machine -- as opposed to a single
>>     interface on the machine -- so that LNet can make an intelligent
>> choice
>>     between the interfaces. And I want PtlRPC to supply hints as to which
>>     interface it expects to be best: PtlRPC is the one layer that knows
>>     which Get and Put calls are part of the same RPC, which is required to
>>     be able to generate these hints.
>>
>>
>> It have none differences how you will deliver a reply to same XID. I may
>> construct a network when request will send with IB but reply will accept
>> via
>> TCP and it's will work. how PtlRPC will help in that case? how one side
>> will
>> know which path is better for different ?
>> Why you think moving low level network knowleage to high level of ptlrpc
>> will good?
>> it's totally different levels - LNet must response to routing and finding
>> "which is best", but PtlRPC connect from two one-way messages into
>> request-reply protocol with high level processing.
>>
>
> A PtlRPC RPC has structure. The first LNetPut() transmits just the header
> information. Then one or more LNetPut() or LNetGet() messages are done to
> transmit the rest of the request. Then the response follows, which also
> consists of several LNetPut() or LNetGet() messages.
>
It's wrong. Looks you mix an RPC and bulk transfers.

in RPC case - it's logical connect from two one-way messages. Each send via
single LNetPut call (first from Client side, second from server side). It's
have a connected via ME (XID) data on LNet layer.
PtlRPC register an ME entry and send that information as part of request
message to the server. Server take that info from request and post send
with pointing to that ME (XID), none else.

but if you talk about bulk transfer - situation slightly different. Client
send an XID to server and mark ME / MD as remote controlled.
in that case server may call LNetGet/LNetPut to transfer a data from client
based on XID (XID range in multi bulk case).
but again - it's just connection on XID / ME / match bits (different name
for one object).





> The key word is "heuristic": have a server assume that traffic related to
> a request should prefer to use the source NID of that request. This is a
> simple way for a node that cares about these things to have a server do the
> right thing, without requiring that the server know how the internals of
> how the node is put together.
>
> For some reason you seem hung up on the idea that it does not matter which
> interfaces are used by network traffic. Our experience at SGI is that it
> does matter on big computers. Therefore we take it into account in the
> design. Therefore there is this apparent layer violation in the design.
>
> Memory place



>                      And there is also a catch, because there are cases
>>         where PtlRPC
>>                      has a valid interest in declaring not just that it
>>         wants to talk
>>                      to a node, but also that it wants to talk to a
>> specific
>>         NID on
>>                      that node.
>>
>>
>>                  None valid scenario for it. Looks you think PtlRPC is
>> good
>>         place for
>>                  routing
>>                  information if think it correct.
>>
>>
>>              For this case I'm thinking in particular of memory and CPU
>>         locality in
>>              big systems. (Think of a big system as itself being built
>> from
>>         nodes
>>              connected by a network.)
>>
>>         I don't say something about memory and CPU. I say about network
>> routing.
>>         PtlRPC choose a new connection and it connection have a
>>         source<>destination
>>         NIDs relation inside, so each new LNetPut will use that NID's to
>>         send info
>>         to such UUID. it's say some of network routing code is on PtlRPC
>> but
>>         should
>>         be on LNet layer. Where CPU and Memory is?
>>
>>
>>     The thread that initiates an RPC runs on a specific CPU, and may well
>> be
>>     bound there by a cpuset. This is common practice on big systems. The
>>     memory buffers involved in the RPC live on a specific part of the
>>     system, and are closer to some CPUs and some interfaces than others.
>>     That's where CPU and memory locality comes in, from my perspective.
>>
>> I mean about network distance, but you are connect local and non local
>> memory to that discussions.
>> Why? local and non local memory problem is outside of Multi rail problem.
>>
>
> For me, at SGI, local and non local memory is an integral part of the
> multi rail problem.


Multi rail (bounding) may work without any knowledge about local and non
local memory?
I think so. as it's just a network transport. So local and non local memory
is different problem and good to separate it in different design, to make
each design as simple as possible. It will help with developing a code,
testing and integrating.



>
>
> int ptlrpc_uuid_to_peer (struct obd_uuid *uuid,
>>                           lnet_process_id_t *peer, lnet_nid_t *self)
>> {
>>          int               best_dist = 0;
>>          __u32             best_order = 0;
>>          int               count = 0;
>>          int               rc = -ENOENT;
>>          int               portals_compatibility;
>>          int               dist;
>>          __u32             order;
>>          lnet_nid_t        dst_nid;
>>          lnet_nid_t        src_nid;
>>
>>          portals_compatibility = LNetCtl(IOC_LIBCFS_PORTALS_COMPATIBILITY,
>> NULL);
>>
>>          peer->pid = LNET_PID_LUSTRE;
>>
>>          /* Choose the matching UUID that's closest */
>>          while (lustre_uuid_to_peer(uuid->uuid, &dst_nid, count++) == 0) {
>>                  dist = LNetDist(dst_nid, &src_nid, &order);
>>                  if (dist < 0)
>>                          continue;
>>
>> this code will don't work for you if you introduce a some abstract NID, as
>> PtlRPC will not able to find best distance.
>>
>
> The lustre_uuid_to_peer() function enumerates all NIDs associated with the
> UUID. This includes the primary NID, but also includes the other NIDs. So
> we find a preferred peer NID based on that. Then we modify the code like
> this:
>
Why PtlRPC should be know that low level details? Currently we have a
problems - when one of destination NID's is unreachable and transfer
initiator need a full ptlrpc reconnect to resend to different NID. But as
you should be have a resend


>
> The call of LNetPrimaryNID() gives the primary peer NID for the peer NID.
> For this to work a handful of calls to LNetPrimaryNID() must be added.
> After that it is up to LNet to find the best route.
>

Per our's comment PrimaryNID will changed after we will find a best, did
you think it loop usefull if you replace loop result at anycases ?
from other view ptlrpc_uuid_to_peer called only in few cases, all other
time ptlrpc have a cache a results in ptlrpc connection info.



>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160122/dd976904/attachment-0001.htm>
