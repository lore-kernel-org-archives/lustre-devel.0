From: JC.LAFOUCRIERE at CEA.FR <JC.LAFOUCRIERE@CEA.FR>
Date: Fri, 8 Feb 2008 01:03:19 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
References: <47AB2FA7.10205@Sun.COM>
Message-ID: <C892277475E7FB4F90BC212EEE14CA8365B674@U-SANTORIN.dif.dam.intra.cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

thank you for your review, I add some comments in the following

Page 1, 1, Define coordinator (space coordinator?),
        define agent, (condense Part II intro, page 14)
        (for me, MDT, MGS and OST)
These are defined in the arch wiki pages

Page 10, 
        4.2, 2) Implies only one copy per "version"...bad idea
Different versions correspond to different files in the external storage. We take the more recent.
Not sure I understand your remark

Page 13, Lustre object mtime may not be good enough. There are several
        mechanisms (like touch) to manipulate mtime, which makes it
        unusable as a last written time.
If a user make a touch in the past this change the mtime and can hide previous writes.
If we want to keep real write time we need to add a new time field in Lustre backend
(may be ZFS has it) 

Page 19, Special Path, does this boil down to invisible I/O?
The path is /mnt_mount/.lustre/fid/FID_NUMBER. When a file is open through this path a 
flag is carried to the OSS to avoid copy in trigger (this used to fill the file)

Page 23, 2.3 and 2.4, I'm assuming that lists of tuples can be processed
        in any order.
yes

Issues:
        The Space manager is likely the most important piece. There is no
        detail on it. This is where archive and other policy is enforced.
The space manager is based on changelogs/feed Lustre feature which are very new (draft HLD has just been
published). This is why it not described at this time.

        The described HSM seems to follow the "copy out" when space needed,
        then purge, model. This function (a Space Manager function) is contrary
        to SAM, and a shortfall of many HSMs.
no spacemanger is doing pre-migration and when free space is needed, it only has to make punc

        Coordination between agents seems important. For example,
        if agents requested new copy-outs on objects striped on
        10 different stores, ordering them on tape seems difficult.
Tape access optimization has to be made by the archival system. We try to put as few external storage knowledge
as possible in Lustre to be external storage independant.

        What is the backup story for Lustre? How does that play with
        the HSM?
HSM do not backup the namespace. It has to be done with a separate tool like a MDT scannner.
The copy tool can use the FID2PATH() function to save the object pathname with the file.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080208/ac88ef54/attachment.htm>
