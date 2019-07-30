From: Degremont, Aurelien <degremoa@amazon.com>
Date: Tue, 30 Jul 2019 16:02:39 +0000
Subject: [lustre-devel] [PATCH 10/11] lustre: ldlm: checkpatch cleanup
In-Reply-To: <alpine.LFD.2.21.1907291958590.18208@casper.infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
 <1563760338-806-11-git-send-email-jsimmons@infradead.org>
 <87tvbdjwa7.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1907240433050.12135@casper.infradead.org>
 <1BDF7232-853F-4B2D-AC0B-AC49E78F6884@amazon.com>
 <alpine.LFD.2.21.1907250246001.19895@casper.infradead.org>
 <ACCFCCDF-B63A-40A9-8992-A8959FD94079@amazon.com>
 <alpine.LFD.2.21.1907291958590.18208@casper.infradead.org>
Message-ID: <F2650047-D57E-490A-B40F-5BC938DDADD4@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi James,

I remember your talk(s) at LUG.
This event-based work is a good thing but I was thinking at even simpler things. Thinking at syscall returned codes.
By example: retcode when mounting a lustre filesystem failed, or retcode when doing I/O or even using lustre CLI tools.
This is much more easier to handle that with a 'case' in your app, checking the retcode instead of deploying a more complex event based system.

Aur?lien

?Le 29/07/2019 21:41, ? James Simmons ? <jsimmons@infradead.org> a ?crit :

    
    > Le 25/07/2019 03:54, ? James Simmons ? <jsimmons@infradead.org> a ?crit :
    > 
    >     
    >     > Le 24/07/2019 05:38, ? lustre-devel au nom de James Simmons ? <lustre-devel-bounces at lists.lustre.org au nom de jsimmons@infradead.org> a ?crit :
    >     >     
    >     >     From checkpatch - "ENOSYS means 'invalid syscall nr' and nothing else"
    >     >     So using ENOSYS is no no. We get away with this because people rarely
    >     >     actually handle each error code individually.
    >     > .
    >     >     
    >     > As a general comment about this, I think we should improve this in the futur. Some people asked me "what's the error code when this or that happens in Lustre?". And I've got no real answer for that.
    >     > Indeed people, most of the time, only checks returned code against 0. That does not help when looking at specific Lustre issues.
    >     
    >     perf probe 'lustre_function%return $retval'
    >     
    >     Does the same thing as lctl set_param debug=+trace except dynamic probes 
    >     can work on any kernel function without code modification!!!
    >     
    > I mean from userspace.
    > When some applications want to adapt its behaviour depending on what is happening in Lustre. 
    
    Ah I see what you mean. Actually I'm working on such a project. See
     
    https://jira.whamcloud.com/browse/LU-10756
    
    I also gave a LUG talk about this work this year. Currently you can do 
    this with sysfs tunables. So if you do a lctl set_param -P on the MGS
    server on the clients an udev event is created. Normally udev rules
    are used to managed these changes but you can write applications that
    responsed to these changes. You just need to use libudev for this type
    of monitoring. This is planned to be expanded to other areas for Lustre
    2.14. One is the import state which a early patch exist for:
    
    https://review.whamcloud.com/#/c/31407
    
    For this work the import state change is reported using udev to systemed.
    The changes seen in this case cover recovery state, evictions, idle etc.
    Bascially any state covered in enum lustre_imp_state from lustre_import.h.
    
    Additionally the sysfs work for LNet will always open new possibilities.
    We will be able to use udev events to report the network health state and
    well as network timeouts etc.
    
    Those are the areas for 2.14. Any others you can think of ? So this kind
    of functionality is being added to Lustre. If Amazon is interested in such
    work I can add you as a reviewer :-)
