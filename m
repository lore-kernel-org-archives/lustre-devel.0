From: Rick Matthews <Richard.Matthews@Sun.COM>
Date: Fri, 08 Feb 2008 05:52:12 -0600
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <C892277475E7FB4F90BC212EEE14CA8365B674@U-SANTORIN.dif.dam.intra.cea.fr>
References: <47AB2FA7.10205@Sun.COM>
	<C892277475E7FB4F90BC212EEE14CA8365B674@U-SANTORIN.dif.dam.intra.cea.fr>
Message-ID: <47AC426C.8060902@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

JC.LAFOUCRIERE at CEA.FR wrote:

Thanks for allowing me to participate.
> Hello
>
> thank you for your review, I add some comments in the following
>
> Page 1, 1, Define coordinator (space coordinator?),
>         define agent, (condense Part II intro, page 14)
>         (for me, MDT, MGS and OST)
> These are defined in the arch wiki pages
>   
Thank you, I still haven't got to them yet...but plan to.
> Page 10, 
>         4.2, 2) Implies only one copy per "version"...bad idea
> Different versions correspond to different files in the external storage. We take the more recent.
> Not sure I understand your remark
>   
A basic mantra of SAM-QFS and other data retention systems is that one 
image of the data is vulnerable (a tape breaks,
or is otherwise overwritten). While the archival system can be 
responsible for making multiple identical images, it
can still represent a single point of failure. Note: I am using version 
to represent a point in time image of the files data,
and copy to represent an image of that version. (See LOCKSS for 
additional references on copies).
> Page 13, Lustre object mtime may not be good enough. There are several
>         mechanisms (like touch) to manipulate mtime, which makes it
>         unusable as a last written time.
> If a user make a touch in the past this change the mtime and can hide previous writes.
> If we want to keep real write time we need to add a new time field in Lustre backend
> (may be ZFS has it) 
>   
What the archival system needs to know is that the copy previously made 
(or a first copy need to be made),
which seems to be triggered by a user (not archive or other - like 
restore) write operation.
> Page 19, Special Path, does this boil down to invisible I/O?
> The path is /mnt_mount/.lustre/fid/FID_NUMBER. When a file is open through this path a 
> flag is carried to the OSS to avoid copy in trigger (this used to fill the file)
>
> Page 23, 2.3 and 2.4, I'm assuming that lists of tuples can be processed
>         in any order.
> yes
>
> Issues:
>         The Space manager is likely the most important piece. There is no
>         detail on it. This is where archive and other policy is enforced.
> The space manager is based on changelogs/feed Lustre feature which are very new (draft HLD has just been
> published). This is why it not described at this time.
>   
OK...also consider using change logs as a trigger for need of a new 
archive version (not copy). Alleviates the mtime issue above.
>         The described HSM seems to follow the "copy out" when space needed,
>         then purge, model. This function (a Space Manager function) is contrary
>         to SAM, and a shortfall of many HSMs.
> no spacemanger is doing pre-migration and when free space is needed, it only has to make punc
>   
OK, so who schedules the pre-migration to the archive system?
>         Coordination between agents seems important. For example,
>         if agents requested new copy-outs on objects striped on
>         10 different stores, ordering them on tape seems difficult.
> Tape access optimization has to be made by the archival system. We try to put as few external storage knowledge
> as possible in Lustre to be external storage independant.
>   
The isolation between archive system and file system is (to me) a good 
idea. I'd just like you to
consider that the recall (stage-in) events can be optimized. At least, 
make sure the archive system
is allowed to reorder as needed (hence the async - list of tuples in any 
order - question above).
Think of other association between files to live storage as 1) a 
pre-stage operation, or 2)
a disk cache pre-fetch operation. I hope I'm using understandable words ;>)
>         What is the backup story for Lustre? How does that play with
>         the HSM?
> HSM do not backup the namespace. It has to be done with a separate tool like a MDT scannner.
> The copy tool can use the FID2PATH() function to save the object pathname with the file.
>
>   
One point here is that an HSM + namespace/metadata backup + unarchived 
data capture can be used to be a
nearly continuous backup operation with a relatively tiny backup window.

-- 
---------------------------------------------------------------------
Rick Matthews                           email: Rick.Matthews at sun.com
Sun Microsystems, Inc.                  phone:+1(651) 554-1518
1270 Eagan Industrial Road              phone(internal): 54418
Suite 160                               fax:  +1(651) 554-1540
Eagan, MN 55121-1231 USA                main: +1(651) 554-1500		
---------------------------------------------------------------------
