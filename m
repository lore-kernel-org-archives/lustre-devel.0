From: Nic Henke <nic@cray.com>
Date: Sat, 18 Apr 2009 07:35:33 -0500
Subject: [Lustre-devel] faking LNET scale
In-Reply-To: <49E8CB7A.1090106@sun.com>
References: <49E8B7E9.5080101@cray.com> <49E8CB7A.1090106@sun.com>
Message-ID: <49E9C915.3080107@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Liang Zhen wrote:
> Nic,
> It's very late night for me now, my head is not clear enough for me to
> make sure whether I'm saying something crazy, :)
Liang,
    Thanks for the notes - at worst this is crazy interesting :-) This
looks very doable - I've not dug into the code to see if there are any
implementation gotchas - but it looks like it should work. I'll let you
know what I come up with.

Cheers,
Nic

> LNet always thinks target is remote network(needs router) if it can't
> find a NI with same network ID, for example, if local NI is (ptl0) and
> caller wants to send message to (ptl1), then LNet will:
> 1. Try to find local  NI for ptl1, and failed then:
> 2. try to find if ptl1 is a remote network and whether there is router
> for this network (ptl1)
>
> So if you want your server has only one NI instance and can talk with
> a set of different networks, and at the same time, it can talk with
> other remote networks via routers,  I would suggest:
> 1. create a new command, for example: lctl add_local_net ptl0
> ptl[1-N], which means LNet should allow NI(ptl0) accessing networks(
> ptl[1-N] as local networks.
> 2. add a new structure in LNet, i.e:
> struct  {
>      struct list_head ln_list;
>    __u32                ln_net;
>     lnet_ni_t          *ln_localni;
>     ......
> }lnet_localnet_t;
> As you see, it's very like current structure lnet_remotenet_t, which
> is pending on lnet_t::ln_remote_nets; we can create a lnet_locallnet_t
> object and add it to global list (i.e: lnet_t::ln_local_nets) by the
> command we mentioned above: lctl add_local_net
> 3. once upper layer caller sending message, lnet_send() should check
> lnet_t::ln_local_nets firstly (before thinking it's a remote network
> and checking on lnet_t::ln_remote_nets), if it is on
> lnet_t::ln_local_netsthen we can take the local NI. on
> lnet_locanet_t::ln_localni;
> 4. We need add a new flag for LND, only LND with the flag can support
> command lctl add_local_net.
> 5. make the LND wouldn't reject messages from different networks.
> again, hope I'm answering what you are asking, :)
>
> Regards
> Liang
