From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Fri, 05 Jun 2009 16:57:46 +0800
Subject: [Lustre-devel] faking LNET scale
In-Reply-To: <4A255D88.10409@cray.com>
References: <49E8B7E9.5080101@cray.com> <49E8CB7A.1090106@sun.com>
	<4A255D88.10409@cray.com>
Message-ID: <4A28DE0A.5050406@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nic,
For incoming requests, I think we can share the same network aliases 
with outgoing messsages (i.e: lnet_t::ln_local_nets in my previous 
mail), matching on the aliases list could be embedded in 
lnet_ptlcompat_match{net,nid} and lnet_net2ni_locked so we don't need 
worry about changing code everywhere.

Regards
Liang

Nicholas Henke wrote:
> Liang Zhen wrote:
>> Nic,
>> It's very late night for me now, my head is not clear enough for me 
>> to make sure whether I'm saying something crazy, :)
>> LNet always thinks target is remote network(needs router) if it can't 
>> find a NI with same network ID, for example, if local NI is (ptl0) 
>> and caller wants to send message to (ptl1), then LNet will:
>> 1. Try to find local  NI for ptl1, and failed then:
>> 2. try to find if ptl1 is a remote network and whether there is 
>> router for this network (ptl1)
>>
>> So if you want your server has only one NI instance and can talk with 
>> a set of different networks, and at the same time, it can talk with 
>> other remote networks via routers,  I would suggest:
>> 1. create a new command, for example: lctl add_local_net ptl0 
>> ptl[1-N], which means LNet should allow NI(ptl0) accessing networks( 
>> ptl[1-N] as local networks.
>> 2. add a new structure in LNet, i.e:
>> struct  {
>>      struct list_head ln_list;
>>    __u32                ln_net;
>>     lnet_ni_t          *ln_localni;
>>     ......
>> }lnet_localnet_t;
>> As you see, it's very like current structure lnet_remotenet_t, which 
>> is pending on lnet_t::ln_remote_nets; we can create a 
>> lnet_locallnet_t object and add it to global list (i.e: 
>> lnet_t::ln_local_nets) by the command we mentioned above: lctl 
>> add_local_net
>> 3. once upper layer caller sending message, lnet_send() should check 
>> lnet_t::ln_local_nets firstly (before thinking it's a remote network 
>> and checking on lnet_t::ln_remote_nets), if it is on 
>> lnet_t::ln_local_netsthen we can take the local NI. on 
>> lnet_locanet_t::ln_localni;
>> 4. We need add a new flag for LND, only LND with the flag can support 
>> command lctl add_local_net.
>> 5. make the LND wouldn't reject messages from different networks.
>> again, hope I'm answering what you are asking, :)
>
> This is almost working - I'm running into one problem: lnet_accept 
> wants to match the ni->ni_nid against the requested NID. It is failing 
> as the nets don't match (ptl1 vs ptl0).
>
> It looks like there are a fair number of places like this, most using 
> lnet_ptlcompat_match{net,nid}.
>
> How should I handle those? Add another clause like ptlcompat (like 
> ln_aliases) and if that is set (we have aliases set), do a search to 
> find the alias and see if there is an alias that would allow 
> NIDNET(lnet_net) == NIDNET(ptl_net)?
>
> Is there a cleaner way?
>
> Nic
