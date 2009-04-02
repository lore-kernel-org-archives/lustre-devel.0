From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 02 Apr 2009 14:47:23 -0400
Subject: [Lustre-devel] OSD iterator interface
Message-ID: <E14DEA02-826C-4F15-8A22-9FA616EFDBC4@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    While inspecting patches in bug 17560 it struck me as odd that we  
are fetching the data one entry at a time from the filesystem, so I  
asked a many-entries at a time
    approach to be implemented. Now the patch in the bug just fills  
the osd buffer with entries (after parsing them) and then actual user  
(e.g. __mdd_readpage)
    reparses the osd buffer and copies data to its own. This is a lot  
of wasted processing, copies and then some extra memory usage.
    So in my opinion the iterator interface should be reworked to  
accept an iterator and a buffer and then __mdd_readdir will pass in  
its own
    parsing of the data (with possible generalized preparsing from osd  
so that we are fs-neutral) and will directly fill its own buffer to  
the amount it actually needs,
    kind of like any kernel filldir functions already work right now.

    Am I missing something stupid? Are there any objections, would  
this break anything?

Bye,
     Oleg
