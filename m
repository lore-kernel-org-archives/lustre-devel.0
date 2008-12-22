From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 22 Dec 2008 21:57:41 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <494FD020.70909@sun.com>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com>
Message-ID: <18767.58149.550264.505562@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev writes:
 > global epochs depend on DLM as a transport to refresh epochs. at least the idea, AFAIU,
 > is to use LDLM RPC to carry epoch protocol. otherwise it'd need separate RPC. I'm just

Any message is used as a transport for epochs, including any reply
from a server. So a typical scenario would be


client                server
   epoch = 8            epoch = 9

   LOCK --------------->   
        <-------------- REPLY
   epoch = 9
                        <----- some other message with epoch = 10 from somewhere
                        epoch = 10
   ....

   REINT --------------->
         <-------------- REPLY
   epoch = 10

                        <----- some other message with epoch = 11 from somewhere
                        epoch = 11

   REINT --------------->
         <-------------- REPLY
   epoch = 11

etc. Note, that nothing prevents server from increasing its local epoch
before replying to every reintegration (this was mentioned in the
original document as an "extreme case"). With this policy there is never
more than one reintegration on a given client in a given epoch, and we
can indeed implement stability algorithm without clients.

 > saying that there are case, probably important, when such explicit RPC will be needed,
 > probably in nearly-sync manner. I think this is also additional complexity.

DLM plays no special role in the epochs mechanism. All that it is used
for is to guarantee that conflicting operations are executed in the
proper order (i.e., an epoch of dependent operation is never less than
an epoch of an operation it depends on), but this is what DLM is for,
and this has be guaranteed anyway.

 > 
 > >  > the problem is that with out-of-order epochs sent to different servers client can't
 > >  > use notion of "last_committed" anymore.
 > > 
 > > What do you mean by "out of order" here?
 > 
 > epoch N+1 can be committed by mds1 before epoch N is committed by mds2. each such
 > epoch is to be tracked separately and "last_committed" can't be used I think.

last_committed can be and have to be used. When a client reintegrated
operation OP = (U(0), ..., U(N)), it counts this operation as `volatile'
until all N servers reported (through the usual last_committed
mechanism, as it is used by Lustre currently) that all updates have
committed.

 > 
 > you meant "from sc" direction. but before that client has to track local committness
 > of each epoch to servers.

Yes, and it can use last_committed of each server to do this.

 > 
 > thanks, Alex

Nikita.
