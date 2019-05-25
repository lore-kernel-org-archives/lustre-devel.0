From: Chris Horn <hornc@cray.com>
Date: Sat, 25 May 2019 14:33:02 +0000
Subject: [lustre-devel] lnet ip2nets option broken in master?
Message-ID: <EC55F7D4-BCB6-4A02-84FD-3CB4F46A487F@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aur?lien,

I reported this issue in a comment in LU-11838 (https://jira.whamcloud.com/browse/LU-11838?focusedCommentId=244766&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-244766). James is working on patches to fix it.

FWIW, when testing master I've been reverting the following patches to fix this issue for both socklnd and o2iblnd:

d661c584c6 Revert "LU-11838 lnet: change lnet_ipaddr_enumerate() to use for_each_netdev()"
4c681cf4ee Revert "LU-11838 o2iblnd: get IP address more directly."
f4fe014620 Revert "LU-6399 lnet: socket cleanup"

Chris Horn

?On 5/24/19, 11:28 AM, "lustre-devel on behalf of Degremont, Aurelien" <lustre-devel-bounces at lists.lustre.org on behalf of degremoa@amazon.com> wrote:

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
    
    _______________________________________________
    lustre-devel mailing list
    lustre-devel at lists.lustre.org
    http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
    
