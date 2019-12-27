From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 27 Dec 2019 16:04:25 +0000
Subject: [lustre-devel] Lustre upstreaming status.
In-Reply-To: <87sglgg9ub.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87sglgg9ub.fsf@notabene.neil.brown.name>
Message-ID: <844DFA02-C483-4708-AAD8-6647F68A48EB@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks for that.

My understanding is that the only sustainable plan at long term is for linux lustre client to be the same code that OpenSFS master branch
- without backward compat ifdef and similar
- without server specific code.

We need to avoid managing a kind of fork because it will too difficult to maintain both branches. IPV6 support in LNET should be at least half accepted in OpenSFS branch before going too far on that front.

Aur?lien

?Le 19/12/2019 06:32, ? lustre-devel au nom de NeilBrown ? <lustre-devel-bounces at lists.lustre.org au nom de neilb@suse.de> a ?crit :

    
    Hi all,
     At the LUG in Houston, I said that I hoped to submit something upstream
     by the end of 2019.  Clearly that isn't going to happen now.
    
     The main reason that caused me to not even try is IPv6 support.
     It became apparent to me that LNet would not be accepted until it has
     working IPv6 support, and that doesn't exist yet.
     I hope to put some development time into IPv6, and to have something
     that works and is worth reviewing by the end of January 2020.
    
     The other issue is that development has progressed slowly because
     there is no spare review bandwidth.  James has contributed a lot, and
     others have helped, but reviewing patches for two code streams (OpenSFS
     and Linux-upstream) turns out to be too much to ask for.
     So I've decided to take a different approach.  From now on I'm not
     going to wait for reviews for patches going into my linux-lustre tree.
     Part of my justification for this is that historically, review hasn't
     really provided much promise of correctness.  Patches go missing.
     Random lines from patches go missing.  Errors creep in in other ways.
    
     Instead, I am developing a tool which will compare OpenSFS lustre
     and Linux-lustre and report relevant differences.  I have a prototype
     working, and it is helping me to find missing patches and parts of
     patches in both trees.
    
     I will continue to submit patches to gerrit to bring OpenSFS closer to
     my linux tree when that is needed, and will apply patches from OpenSFS
     to my tree without extra review when that it needed.
    
     When the time comes to submit upstream, I plan to present the tool so
     that other developers can confirm that what I am submitting is
     functionally equivalent to OpenSFS, and so that we can ensure the
     equivalence remains.
    
     Consequently my "lustre" branch will jump forward to v5.4 soon,
     probably tomorrow, and will remain close to mainline.
     I will also be growing my list of outstanding OpenSFS patches
     (currently about 100, many of which haven't been submitted to gerrit
     yet) and will hope to get those reviewed.  Any changes that result from
     the review will be detected by my comparison script when the patch
     lands, and I'll update linux-lustre to match.
    
     My new goal for upstream submission is the end of Q1-2020.  This is
     probably a bit optimistic, but gives me a suitable focus.
    
    NeilBrown
    
