From: Michael Kluge <Michael.Kluge@tu-dresden.de>
Date: Thu, 17 Jun 2010 16:02:09 +0200
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <B25C28C7-7D9C-4BAC-9218-A9CAEB0C21E6@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de> <4BDF2999.2000207@oracle.com>
	<4BEFBB07.4030403@tu-dresden.de> <1274788995.2261.110.camel@radar>
	<4BFC7177.9000808@oracle.com> <1275058473.21591.14.camel@radar>
	<4BFFA456.7030502@oracle.com>
	<C671351E-110C-4D2C-B216-4E8BE23A943A@oracle.com>
	<1FF3D25F-3369-462E-9651-62D56319612A@tu-dresden.de>
	<D29ED098-3DEB-4AF4-AA68-B52B4E2BF5EA@oracle.com>
	<4C04F3F0.9040708@oracle.com>
	<001601cb01a3$546c93d0$fd45bb70$%barton@oracle.com>
	<4C04F94A.2050908@oracle.com>
	<7B05EBAF-67C5-4EE1-B1EC-CB1C554BEA3E@oracle.com>
	<4DBE6FF1-62B0-484C-81F8-B231E332BFB5@tu-dresden.de>
	<1BFD6845-6D5A-459F-8164-4F75FD759060@tu-dresden.de>
	<B25C28C7-7D9C-4BAC-9218-A9CAEB0C21E6@oracle.com>
Message-ID: <1276783329.499.322.camel@radar>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hmm. Ok. Is there a way to figure out what type of file I have if I have
nothing like the (most probably incomplete) file itself? Whether it is a
client or a server log and which NID the node has had? Right now the
code is executing a not-so-easy mapping algorithm over all files to
figure this out. The way to distinguish between client and server was to
look at those lines which I expected to see only on the server (the
"incoming req at .....").

Michael

Am Mittwoch, den 16.06.2010, 08:50 -0600 schrieb Andreas Dilger: 
> On 2010-06-16, at 02:46, Michael Kluge wrote:
> > thanks for the trace files. Every single file contains log entries like:
> > 
> > line: 00000100:00100000:2.0F:1275433209.964416:0:7924:0:(events.c:285:request_in_callback())               incoming req at ffff8101b32f5400 x1337373369608379 msgsize 296
> > 
> > Are in the tarball 684 server logs? Or am I wrong with the assumption that the lines with an "incoming req@" can only show up on the servers?
> 
> Clients can receive requests from the server for things like lock cancellations, so this line will appear in both client and server logs.  We don't have a test system with 684 servers...
> 
> > Am 01.06.2010 um 21:39 schrieb Michael Kluge:
> > 
> >>> On 2010-06-01, at 06:12, di.wang wrote:
> >>>> Michael, I do not think you need all the trace logs from the clients. right?
> >>> 
> >>> Actually, I think he does want trace logs from all of the clients.
> >> 
> >> Yes, 600 is a good number. Vampir can easily handle this. If possible, I'd like to have all server traces as well to include this information. Right now I am only putting these RPC's in the trace where all 5 events (client send,server recv/start/done,client done) are present. I see the "client send/done" events in the OSS log as well, probably it is talking to the MDS or MGS. Events that are incomplete are being ignored but counted in "dumped events" counter. But that could be changed.
> >> 
> >> 
> >> Michael
> >> 
> >>>> I had thought the current target is to make sure vampire can handle
> >>>> the trace from "big" enough clusters.
> >>>> 
> >>>> Actually, I am not sure whether vampire(with this trace analyse) should 
> >>>> work in this way as we do now?  i.e. running job exclusively on the cluster, get rpctrace log, then get graph by vampire?
> >>>> 
> >>>> Or I miss sth here? Michale, could you please explain a bit? What is 
> >>>> your idea how vampire could help the end users? or the target here is 
> >>>> just helping the developers and sysadmin to understand the system?
> >>> 
> >>> My thoughts on this in the past were that it should be possible to use ONLY the client logs to plot syscall latencies (using client VFSTRACE lines) and the RPC latencies (using client RPCTRACE lines) and locking (using DLMTRACE lines).  Some code rework would be needed to allow regular users to run "lctl dk", and it would filter out the lines specific to their own processes.  This would allow regular users to collect and analyze their application without assistance or coordination from the sysadmin.
> >>> 
> >>> In order to allow regular users to trace such information, the VFSTRACE calls should report the UID of the process doing the system call, which would immediately map to a PID.  The PID can be used to track the majority of the debug entries, but not always those done in another thread (e.g. ptlrpcd).  The RPCTRACE messages also contain the PID, so that would be helpful, but it would mean that there has to be a parser/filter in the kernel to ensure users cannot access trace information that is not their own.  That would be a significant undertaking, I think.
> >>> 
> >>> In the meantime, for testing purposes and initial usage (with sysadmin assistance) the full debug log can be extracted from the kernel and filtered in userspace as needed.
> >>> 
> >>>>>> -----Original Message-----
> >>>>>> From: di.wang [mailto:di.wang at oracle.com]
> >>>>>> Sent: 01 June 2010 12:50 PM
> >>>>>> To: Robert Read
> >>>>>> Cc: Michael Kluge; Eric Barton; Galen M. Shipman
> >>>>>> Subject: Re: [Lustre-devel] Lustre RPC visualization
> >>>>>> 
> >>>>>> Hello,
> >>>>>> 
> >>>>>> IMHO, just run IOR with whatever parameters, and get rpctrace
> >>>>>> log(probably only enable rpctrace) from 1 OST and some of clients
> >>>>>> (probably 2 is enough).
> >>>>>> Note: please make sure these 2 clients did communicate the OST during
> >>>>>> the IOR.
> >>>>>> 
> >>>>>> Michael, I do not think you need all the trace logs from the clients. right?
> >>>>>> 
> >>>>>> Robert
> >>>>>> 
> >>>>>> If there are available time slots for this test on Hyperion, who can
> >>>>>> help to get these logs?
> >>>>>> 
> >>>>>> Thanks
> >>>>>> Wangdi
> >>>>>> 
> >>>>>> Robert Read wrote:
> >>>>>> 
> >>>>>>> What should I run then? Do have scripts to capture this?
> >>>>>>> 
> >>>>>>> robert
> >>>>>>> 
> >>>>>>> On May 31, 2010, at 2:39 , Michael Kluge wrote:
> >>>>>>> 
> >>>>>>> 
> >>>>>>>> Hi Robert,
> >>>>>>>> 
> >>>>>>>> 600 is a nice number. Plus the traces from the server an I am happy.
> >>>>>>>> 
> >>>>>>>> 
> >>>>>>>> Michael
> >>>>>>>> 
> >>>>>>>> Am 28.05.2010 um 17:53 schrieb Robert Read:
> >>>>>>>> 
> >>>>>>>> 
> >>>>>>>>> On May 28, 2010, at 4:09 , di.wang wrote:
> >>>>>>>>> 
> >>>>>>>>> 
> >>>>>>>>>> Hello, Michael
> >>>>>>>>>> 
> >>>>>>>>>> 
> >>>>>>>>>>> One good news: The Feature that Vampir can show something like a heat
> >>>>>>>>>>> map (Eric asked about this) comes back with the release at ISC. It is
> >>>>>>>>>>> now called "performance radar". It can produce a heat map for a
> >>>>>>>>>>> counter
> >>>>>>>>>>> and does some other things as well. I could send a picture around, but
> >>>>>>>>>>> need at first an bigger trace (more hosts generating traces in
> >>>>>>>>>>> parallel).
> >>>>>>>>>>> 
> >>>>>>>>>>> 
> >>>>>>>>>> Right now I do not have big clusters available to generate the trace.
> >>>>>>>>>> I will see what I can do here.
> >>>>>>>>>> 
> >>>>>>>>> If ~600 clients is big enough we could generate that on Hyperion.
> >>>>>>>>> 
> >>>>>>>>> robert
> >>>>>>>>> 
> >>>>>>>>> 
> >>>>>>>>>> Thanks
> >>>>>>>>>> WangDi
> >>>>>>>>>> 
> >>>>>>>>>>> 
> >>>>>>>>>>> 
> >>>>>>>>>>>>> 
> >>>>>>>>>>> ------------------------------------------------------------------------
> >>>>>>>>>>> 
> >>>>>>>>>>> _______________________________________________
> >>>>>>>>>>> Lustre-devel mailing list
> >>>>>>>>>>> Lustre-devel at lists.lustre.org <mailto:Lustre-devel@lists.lustre.org>
> >>>>>>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>>>>>>>>>> 
> >>>>>>>>>>> 
> >>>>>>>>> 
> >>>>>>>> --
> >>>>>>>> 
> >>>>>>>> Michael Kluge, M.Sc.
> >>>>>>>> 
> >>>>>>>> Technische Universit?t Dresden
> >>>>>>>> Center for Information Services and
> >>>>>>>> High Performance Computing (ZIH)
> >>>>>>>> D-01062 Dresden
> >>>>>>>> Germany
> >>>>>>>> 
> >>>>>>>> Contact:
> >>>>>>>> Willersbau, Room WIL A 208
> >>>>>>>> Phone:  (+49) 351 463-34217
> >>>>>>>> Fax:    (+49) 351 463-37773
> >>>>>>>> e-mail: michael.kluge at tu-dresden.de <mailto:michael.kluge@tu-dresden.de>
> >>>>>>>> WWW:    http://www.tu-dresden.de/zih
> >>>>>>>> 
> >>>>>>>> 
> >>>>> 
> >>>>> 
> >>>>> _______________________________________________
> >>>>> Lustre-devel mailing list
> >>>>> Lustre-devel at lists.lustre.org
> >>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>>>> 
> >>>> 
> >>>> _______________________________________________
> >>>> Lustre-devel mailing list
> >>>> Lustre-devel at lists.lustre.org
> >>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>> 
> >>> 
> >>> Cheers, Andreas
> >>> --
> >>> Andreas Dilger
> >>> Lustre Technical Lead
> >>> Oracle Corporation Canada Inc.
> >>> 
> >>> _______________________________________________
> >>> Lustre-devel mailing list
> >>> Lustre-devel at lists.lustre.org
> >>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>> 
> >> 
> >> 
> >> -- 
> >> 
> >> Michael Kluge, M.Sc.
> >> 
> >> Technische Universit?t Dresden
> >> Center for Information Services and
> >> High Performance Computing (ZIH)
> >> D-01062 Dresden
> >> Germany
> >> 
> >> Contact:
> >> Willersbau, Room WIL A 208
> >> Phone:  (+49) 351 463-34217
> >> Fax:    (+49) 351 463-37773
> >> e-mail: michael.kluge at tu-dresden.de
> >> WWW:    http://www.tu-dresden.de/zih
> >> 
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> > 
> > 
> > -- 
> > 
> > Michael Kluge, M.Sc.
> > 
> > Technische Universit?t Dresden
> > Center for Information Services and
> > High Performance Computing (ZIH)
> > D-01062 Dresden
> > Germany
> > 
> > Contact:
> > Willersbau, Room WIL A 208
> > Phone:  (+49) 351 463-34217
> > Fax:    (+49) 351 463-37773
> > e-mail: michael.kluge at tu-dresden.de
> > WWW:    http://www.tu-dresden.de/zih
> > 
> 
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
> 
> 

-- 

Michael Kluge, M.Sc.

Technische Universit?t Dresden
Center for Information Services and
High Performance Computing (ZIH)
D-01062 Dresden
Germany

Contact:
Willersbau, Room A 208
Phone:  (+49) 351 463-34217
Fax:    (+49) 351 463-37773
e-mail: michael.kluge at tu-dresden.de
WWW:    http://www.tu-dresden.de/zih
-------------- next part --------------
A non-text attachment was scrubbed...
Name: smime.p7s
Type: application/x-pkcs7-signature
Size: 5997 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100617/5402077b/attachment.bin>
