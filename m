From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 19 Jul 2019 15:44:47 +0000
Subject: [lustre-devel] sanity-hsm and libtool
In-Reply-To: <alpine.LFD.2.21.1907191611160.17024@casper.infradead.org>
References: <B0E37F29-E0D1-4432-A6DB-712D27E078CB@amazon.com>
 <alpine.LFD.2.21.1907191611160.17024@casper.infradead.org>
Message-ID: <B264B956-FB39-46EF-A72D-0214B316833F@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



?Le 19/07/2019 17:21, ? James Simmons ? <jsimmons@infradead.org> a ?crit :

    
    > Hi!
    > 
    >  
    > 
    > I'm trying to run sanity-hsm.sh tests in my lustre source directory as I'm used to.
    > 
    > Since libtool patch was landed, tools like lhsmtool_posix are executed through a wrapper and appear in process list as 'lt-lhsmtool_posix'.
    > 
    > Some tests try to find and kill them, relying on command like:
    > 
    >  
    > 
    > "ps -C $HSMTOOL"
    > 
    >  
    > 
    > Even if run through "libtool execute ps -C $HSMTOOL" (as it is in the source right now) this command does not catch the proper process and
    > so fail the test.
    > 
    >  
    > 
    > I'm wondering what the proper way to run the test suite to have it working and how this is working in Maloo?
    > 
    > I'm doing:
    > 
    >  
    > 
    > git clone
    > 
    > autogen
    > 
    > configure
    > 
    > make
    > 
    > sudo REFORMAT=: ./lustre/tests/sanity-hsm.sh
    > 
    >  
    > 
    >  
    > 
    >  
    > 
    > By the way, when hsm helper functions were moved from sanity-hsm.sh to test-framework.sh (f172b1168, for PCC), some of them were just
    > copied and not moved. So there are several duplicates between these 2 files. I think that's not on purpose?
    
    What version of lustre are you testing with? Their was a patch landed to 
    handle this.
    
    LU-11742 test: have libtool execute the test binaries
    
    which is lustre commit f9e5224fbb60bb8b44753b7be10cb06108627f89. This has 
    been back ported to 2.12 LTS. Can you see if your lustre tree has this 
    fix. 
    
    See https://www.gnu.org/software/libtool/manual/html_node/Debugging-executables.html
    for details about using libtool against the binary wrappers. 

I'm running master.
That's exactly the patch which is giving me issue.
I can run sanity-hsm successfully prior to this patch, not after.

Aur?lien
