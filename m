From: Degremont, Aurelien <degremoa@amazon.com>
Date: Tue, 28 May 2019 13:05:21 +0000
Subject: [lustre-devel] lnet ip2nets option broken in master?
In-Reply-To: <D300DDCA-C5D1-4D61-90D1-4E216A97133C@whamcloud.com>
References: <EC55F7D4-BCB6-4A02-84FD-3CB4F46A487F@cray.com>
 <E4BEE47A-0CEF-40D9-B965-F232467FB03B@amazon.com>
 <D300DDCA-C5D1-4D61-90D1-4E216A97133C@whamcloud.com>
Message-ID: <30F0593A-13C8-4246-84BF-E16F27B2259A@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



?Le 27/05/2019 20:03, ? Andreas Dilger ? <adilger@whamcloud.com> a ?crit :

    
    On 5/24/19, 11:28 AM, "Degremont, Aurelien" <degremoa@amazon.com> wrote:
    > 
    >        I'm doing several tests with LNET and I realized lnet module option 'ip2nets' does not work anymore.
    >        I git-bisected the regression down to:
    > 
    >        commit f5991afd8779fe747778e28e998277a10242a57d
    >        Author: NeilBrown <neilb@suse.com>
    >        Date:   Mon Jan 7 14:23:19 2019 -0500
    > 
    >            LU-11838 lnet: change lnet_ipaddr_enumerate() to use for_each_netdev()
    > 
    > 
    >        Am I doing something wrong? Is that already known and there is some patchs around for it?
    > 
    >        Funny thing is that the normal way to use it does not work, but if I specify IP address in the reverse order, it works. (Could be just a side effect/red herring)
    > 
    >        Ie: ip2nets="tcp2(eth0) 172.32.47.137".  -> ERROR (correct IP)
    >        ip2net="tcp2(eth0) 137.47.32.172" -> OK
    > 
    >        I was not able to understand the bug.
    > 
    >        If it makes sense, I can open a ticket.
    > 
    >        Aur?lien
    
    My non-LNet-experienced thinking is that the network layer expects the IP addresses to be in big-endian always, and Lustre is supplying them in little-endian?  Maybe they just need a "htons(addr)" before calling for_each_netdev()?
    

Looking a bit more closely at the code, it looks like that's the problem. The IP addr is stored in a __be32 which needs to be converted for Intel platforms (at least). Not sure if ifa_local needs to be converted with ntohl() though. There is probably a more specialized function to convert this field.

Aur?lien    
