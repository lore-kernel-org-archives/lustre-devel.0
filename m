From: Rick Matthews <Richard.Matthews@Sun.COM>
Date: Thu, 07 Feb 2008 10:19:51 -0600
Subject: [Lustre-devel] Lustre HSM HLD draft
Message-ID: <47AB2FA7.10205@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,
  I'm new to this list, so I'll start with apologies. My Lustre 
background is
also limited; a situation I hope to fix.
  As part of the Solaris Software Archiving group, I was asked to review 
the HSM HLD
by my management. That review was sent to Peter Bojanic. He suggested I 
get involved in
the community discussion.
  This is a posting of my original response, based on a copy of the HLD 
which seems to
be the one posted. I've made a couple of minor corrections.

Page 1, 1, Define coordinator (space coordinator?),
        define agent, (condense Part II intro, page 14)
        (for me, MDT, MGS and OST)

Page 8, 3.8, "use" not "used" in second sentence

Page 9, 3.8.2 et.al., "precised" (maybe, explicit or precise)

Page 9, 3.8.4, Lustre ID "if" no path

Page 10, 4.1, 1) When archived? (probably in Space Manager portion)
        SAM-QFS archives well ahead of space need.

        4) External object reference must be unusable, until 5.

        4.2, 2) Implies only one copy per "version"...bad idea

Page 12, 5.3, Last Sentence, This enables, not This ables

        6.1, 100,000 migrations make current migration list operations
                problematic (lets say want to move last migration to
                be next migration).

Page 13, Lustre object mtime may not be good enough. There are several
        mechanisms (like touch) to manipulate mtime, which makes it
        unusable as a last written time.

Page 15, a variant on 1.5, ask for/return last valid byte offset
        (perhaps within a range).

Page 19, Special Path, does this boil down to invisible I/O?

Page 23, 2.3 and 2.4, I'm assuming that lists of tuples can be processed
        in any order.

Page 25, 1, Punch - becomes "sparse" not "spare"

I think this spec needs to be more consistent with its use of data range.
It is confusing as laid out.

Page 26, 3.2 space will be exhausted, or space will be low, not space 
will be
        missing.

Page 28, protection of Lustre extended attributes?

Issues:
        The Space manager is likely the most important piece. There is no
        detail on it. This is where archive and other policy is enforced.

        The described HSM seems to follow the "copy out" when space needed,
        then purge, model. This function (a Space Manager function) is 
contrary
        to SAM, and a shortfall of many HSMs.

        File/object association is an important component of SAM.
        For example, if I access a file in a source tree, I'm likely
        to access the others as well.

        The purge (3.2, Space manager needs to make room) and 4.1
        "needs to be atomic" is a complex operations. Sequencing is
        important.

        Coordination between agents seems important. For example,
        if agents requested new copy-outs on objects striped on
        10 different stores, ordering them on tape seems difficult.

        What is the backup story for Lustre? How does that play with
        the HSM?

-- 
---------------------------------------------------------------------
Rick Matthews                           email: Rick.Matthews at sun.com
Sun Microsystems, Inc.                  phone:+1(651) 554-1518
1270 Eagan Industrial Road              phone(internal): 54418
Suite 160                               fax:  +1(651) 554-1540
Eagan, MN 55121-1231 USA                main: +1(651) 554-1500		
---------------------------------------------------------------------
