From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Sat, 18 Apr 2009 02:33:30 +0800
Subject: [Lustre-devel] faking LNET scale
In-Reply-To: <49E8B7E9.5080101@cray.com>
References: <49E8B7E9.5080101@cray.com>
Message-ID: <49E8CB7A.1090106@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic,
It's very late night for me now, my head is not clear enough for me to 
make sure whether I'm saying something crazy, :)
LNet always thinks target is remote network(needs router) if it can't 
find a NI with same network ID, for example, if local NI is (ptl0) and 
caller wants to send message to (ptl1), then LNet will:
1. Try to find local  NI for ptl1, and failed then:
2. try to find if ptl1 is a remote network and whether there is router 
for this network (ptl1)

So if you want your server has only one NI instance and can talk with a 
set of different networks, and at the same time, it can talk with other 
remote networks via routers,  I would suggest:
1. create a new command, for example: lctl add_local_net ptl0 ptl[1-N], 
which means LNet should allow NI(ptl0) accessing networks( ptl[1-N] as 
local networks.
2. add a new structure in LNet, i.e:
struct  {
      struct list_head ln_list;
    __u32                ln_net;
     lnet_ni_t          *ln_localni;
     ......
}lnet_localnet_t;
As you see, it's very like current structure lnet_remotenet_t, which is 
pending on lnet_t::ln_remote_nets; we can create a lnet_locallnet_t 
object and add it to global list (i.e: lnet_t::ln_local_nets) by the 
command we mentioned above: lctl add_local_net
3. once upper layer caller sending message, lnet_send() should check 
lnet_t::ln_local_nets firstly (before thinking it's a remote network and 
checking on lnet_t::ln_remote_nets), if it is on 
lnet_t::ln_local_netsthen we can take the local NI. on 
lnet_locanet_t::ln_localni;
4. We need add a new flag for LND, only LND with the flag can support 
command lctl add_local_net.
5. make the LND wouldn't reject messages from different networks.
again, hope I'm answering what you are asking, :)

Regards
Liang

Nicholas Henke wrote:
> Greetings -
>
> 	I was looking into ways to simulate scale at the LNET level. It would allow us 
> to test the LNDs better with less hardware, not to mention things like LNet 
> SelfTest and friends.
>
> 	With the work in bug 15332 to add multiple nets per NIC, it seemed fairly close 
> that we could use that to generate multiple LND connections from a single NIC. 
> Ideally we'd have a server or router that would have just one LND instance 
> (ptl0) and the client nodes with multiple interfaces (ptl1, ptl2, ...). This 
> would increase the load on those server nodes to something interesting.
>
> However, to do this either hacking up lnet_ptlcompat_matchXXX to look at another 
> flag besides the_lnet.ln_ptlcompat or some other way of allowing a server with a 
> single NET (ptl0) to accept requests from a variety of nets (ptl1, ptl2, etc). 
> One cannot use multiple interfaces for the same net type with ln_ptlcompat enabled.
>
> 	Is there a better way to do this ? What would be the least abusive of th e rules ?
>
> Cheers,
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
