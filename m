From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 24 May 2019 16:28:28 +0000
Subject: [lustre-devel] lnet ip2nets option broken in master?
Message-ID: <B4B45E3C-B0AF-4EC9-AD05-FB61CF6ACE62@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I'm doing several tests with LNET and I realized lnet module option 'ip2nets' does not work anymore.
I git-bisected the regression down to:

commit f5991afd8779fe747778e28e998277a10242a57d
Author: NeilBrown <neilb@suse.com>
Date:   Mon Jan 7 14:23:19 2019 -0500

    LU-11838 lnet: change lnet_ipaddr_enumerate() to use for_each_netdev()


Am I doing something wrong? Is that already known and there is some patchs around for it?

Funny thing is that the normal way to use it does not work, but if I specify IP address in the reverse order, it works. (Could be just a side effect/red herring)

Ie: ip2nets="tcp2(eth0) 172.32.47.137".  -> ERROR (correct IP)
ip2net="tcp2(eth0) 137.47.32.172" -> OK

I was not able to understand the bug.

If it makes sense, I can open a ticket.

Aur?lien
