From: Alex Zhuravlev <bzzz@sun.com>
Date: Mon, 06 Apr 2009 11:21:48 +0400
Subject: [Lustre-devel] OSD iterator interface
In-Reply-To: <49D51B32.2020404@sun.com>
References: <E14DEA02-826C-4F15-8A22-9FA616EFDBC4@Sun.COM>
	<49D51B32.2020404@sun.com>
Message-ID: <m3tz526ycz.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I agree with what Oleg said. I think there are two-stages processing here:
1) osd should be able to clean "value" from compatibility stuff like inodes
2) mdd should be able to store this value in own buffer in, possible, some
   efficient form

>>>>> di wang (dw) writes:

 dw> Hello,
 dw> In new MDS stack, osd suppose do not understand Directory (IMHO), and
 dw> it only provides
 dw> index API. MDD  will  use  the index API  to fill the dir entries.

 dw> The filldir in current EA index API is just for compatible with old version
 dw> of  MDS.  Maybe we need bulk index API for readdir ?  But Alex should
 dw> know more.

 dw> Thanks
 dw> WangDi

 dw> Oleg Drokin wrote:
 >> Hello!
 >> 
 >> While inspecting patches in bug 17560 it struck me as odd that
 >> we  are fetching the data one entry at a time from the filesystem,
 >> so I  asked a many-entries at a time
 >> approach to be implemented. Now the patch in the bug just fills
 >> the osd buffer with entries (after parsing them) and then actual
 >> user  (e.g. __mdd_readpage)
 >> reparses the osd buffer and copies data to its own. This is a
 >> lot  of wasted processing, copies and then some extra memory usage.
 >> So in my opinion the iterator interface should be reworked to
 >> accept an iterator and a buffer and then __mdd_readdir will pass in
 >> its own
 >> parsing of the data (with possible generalized preparsing from
 >> osd  so that we are fs-neutral) and will directly fill its own
 >> buffer to  the amount it actually needs,
 >> kind of like any kernel filldir functions already work right now.
 >> 
 >> Am I missing something stupid? Are there any objections, would
 >> this break anything?
 >> 
 >> Bye,
 >> Oleg
 >> _______________________________________________
 >> Lustre-devel mailing list
 >> Lustre-devel at lists.lustre.org
 >> http://lists.lustre.org/mailman/listinfo/lustre-devel
 >> 


-- 
thanks, Alex
