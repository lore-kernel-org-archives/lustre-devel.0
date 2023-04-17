Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E4327C77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:58:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0VVs1Txtz1yDf;
	Mon, 17 Apr 2023 07:56:21 -0700 (PDT)
Received: from proofpoint8.lanl.gov (proofpoint8.lanl.gov [204.121.3.47])
 (using TLSv1.2 with cipher AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0VVp0WCKz1y34
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 07:56:17 -0700 (PDT)
Received: from pps.filterd (proofpoint8.lanl.gov [127.0.0.1])
 by proofpoint8.lanl.gov (8.17.1.19/8.17.1.19) with ESMTP id 33HAsuOB002501
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 08:55:52 -0600
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=lanl.gov;
 h=from : to : subject :
 date : message-id : references : in-reply-to : content-type :
 mime-version; s=lanl; bh=7is4zSPwilRKzWSuot14kiCCbna50FcIlul+iAbt+AE=;
 b=mSSZryDFVdOGg5chXztU3Lv6OixB/j8eTkAQb8tvXM7T9aqQwO4DPo6ZAPFNP+NjRSR9
 bitCIh3yx9R4z20SIo8bE2eo6mywBrMRbRKWNRtaYGmawKMBJxBY1e0zaXYEGghyRoae
 hubtTo9+XAjna9VIw1QLP/Sf34nK0Ymy1rBoZdeQJFFKCO806rXeXRErno66VqhTiP/f
 49esSg2d4wr/EZiLkXX9JbEQT0k2HnHkfbDlxVvN5S7s3DssQRc60GJqABKRO+mgQDJl
 dRU/csDTYQAcJofoCZTB0qv2flTWG+uuho9MP05Fmj/x6ZV3eGVZV7AvmB2EoIEAfbsm IQ== 
Received: from mailrelay1.lanl.gov (mailrelay1.lanl.gov [128.165.4.101])
 by proofpoint8.lanl.gov (PPS) with ESMTP id 3pyrq0qdym-1
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 08:55:51 -0600
Received: from localhost (localhost [127.0.0.1])
 by mailrelay1.lanl.gov (Postfix) with ESMTP id B0AB01015DD5
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 08:55:51 -0600 (MDT)
X-NIE-2-Virus-Scanner: amavisd-new at mailrelay1.lanl.gov
Received: from EXG16-P-MBX07.win.lanl.gov (exg16-p-mbx07.win.lanl.gov
 [128.165.106.187])
 by mailrelay1.lanl.gov (Postfix) with ESMTP id 9C4F11015DCD
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 08:55:51 -0600 (MDT)
Received: from EXG16-P-MBX06.win.lanl.gov (128.165.106.186) by
 EXG16-P-MBX07.win.lanl.gov (128.165.106.187) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.23; Mon, 17 Apr 2023 08:55:51 -0600
Received: from EXG16-P-MBX06.win.lanl.gov ([fe80::c1a8:d98:cab8:a884]) by
 EXG16-P-MBX06.win.lanl.gov ([fe80::c1a8:d98:cab8:a884%5]) with mapi id
 15.01.2507.023; Mon, 17 Apr 2023 08:55:51 -0600
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: lctl debug_kernel: usability improvements?
Thread-Index: AQHZa7H/0aa5cHT1N02J/Lsdl9C7bq8voCik
Date: Mon, 17 Apr 2023 14:55:51 +0000
Message-ID: <f746930fc1fa42fc8da9d04696a66444@lanl.gov>
References: <15ba99f9ed8842009d3f8ebb1a494b53@lanl.gov>
In-Reply-To: <15ba99f9ed8842009d3f8ebb1a494b53@lanl.gov>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [128.165.106.172]
MIME-Version: 1.0
X-Proofpoint-GUID: 78-Z708bs8DSmIUuVQJcRpNEwMOQurg6
X-Proofpoint-ORIG-GUID: 78-Z708bs8DSmIUuVQJcRpNEwMOQurg6
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.254,Aquarius:18.0.942,Hydra:6.0.573,FMLib:17.11.170.22
 definitions=2023-04-17_10,2023-04-17_01,2023-02-09_01
X-Proofpoint-Spam-Reason: safe
Subject: Re: [lustre-devel] lctl debug_kernel: usability improvements?
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
From: "Bertschinger,
 Thomas Andrew Hjorth via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Bertschinger, Thomas Andrew Hjorth" <bertschinger@lanl.gov>
Content-Type: multipart/mixed; boundary="===============7563204839007175441=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7563204839007175441==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_f746930fc1fa42fc8da9d04696a66444lanlgov_"

--_000_f746930fc1fa42fc8da9d04696a66444lanlgov_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

After looking into this more I see there is a fair challenge associated wit=
h this idea. With each CPU (and execution context) having its own distinct =
buffer for messages (struct cfs_trace_cpu_data), the messages are not chron=
ologically sorted in kernel memory. Instead, they are written to a regular =
file in CPU order and then the sorted chronologically in userspace prior to=
 printing.

Implementing a  "/dev/lmsg" device would be challenging with the existing d=
ata structures because sorting would have to happen in kernel space as the =
device responds to reads.

I found this issue: LU-14428 "Convert tracefile to use ring_buffer from lin=
ux" which does not look to be completed, seeing as a ring_buffer is not cur=
rently in use here -- but if this is completed, implementing "/dev/lmsg" wi=
th the same interface as "/dev/kmsg" would be much simpler. (Assuming I und=
erstand correctly that the proposal is a single global ring buffer. Let me =
know if I am mistaken and the proposal is a set of per-CPU ring buffers, be=
cause then the sorting problem is not avoided.)

I reported a new issue LU-16746 "Convert tracefile to export debug logs via=
 character device" for this idea.This can be worked on after LU-14428 is co=
mpleted. If I can be of assistance on LU-14428 by helping with any sub-task=
s, let me know. I am interested in helping with this area of Lustre.

Thanks,

Thomas Bertschinger

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Ber=
tschinger, Thomas Andrew Hjorth via lustre-devel <lustre-devel@lists.lustre=
.org>
Sent: Monday, April 10, 2023 8:19 AM
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] lctl debug_kernel: usability improvements?


Hello,

Recently when using "lctl dk" I have found myself wanting some of the "qual=
ity of life" features that exist in the similar linux tool dmesg. In partic=
ular, having the ability to "follow" the debug log like "dmesg -w" would be=
 very handy IMO.

I've attempted to implement this in userspace with the existing tooling (us=
ing "lctl debug_daemon" to write the encoded log to a file, and "lctl debug=
_file" to decode it) but have run into challenges. I first tried creating a=
 FIFO and had debug_daemon write to it and debug_file read from it. Unfortu=
nately this fails because the kernel thread that writes to this file (trace=
filed in libcfs/libcfs/tracefile.c) repeatedly opens and closes the file, b=
ut after the first close reading the FIFO fails.

My next idea was to have debug_daemon write to a regular file and debug_fil=
e read it like "tail -f". This should work in theory but has disadvantages:=
 the user must remember to delete the file when done (the tool could do thi=
s but not if it exits uncleanly), and also entries could be missed if the f=
ile is deleted while the tool is still running.

I think the cleanest solution is to rework the debug_kernel interface to be=
 like linux's /dev/kmsg. A character device, perhaps named /dev/lmsg, could=
 be created that outputs the buffer contents when read. Implementing "follo=
w" would be trivial with this interface. The existing userspace tools could=
 also easily be updated to use this interface, and it would bring other ben=
efits, for example "lctl dk" not needing to copy the message buffer to a tm=
p file. The disadvantage here is that this could be a significant kernel-si=
de refactor.

I feel the ability to follow Lustre's debug log would be useful to both sys=
admins and developers but want to get some other input. Would this be valua=
ble to anyone? If this would be useful -- and feasible -- I would be happy =
to submit a JIRA ticket and work on a patch but wanted to get some more opi=
nions. I'm not very familiar with the kernel side code yet so I'm not sure =
how complicated this would be.

- Thomas Bertschinger
________________________________

--_000_f746930fc1fa42fc8da9d04696a66444lanlgov_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size: 12pt; color: rgb(0, 0,=
 0); font-family: Calibri, Helvetica, sans-serif, &quot;EmojiFont&quot;, &q=
uot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, NotoColorEmoji, &q=
uot;Segoe UI Symbol&quot;, &quot;Android Emoji&quot;, EmojiSymbols;" dir=3D=
"ltr">
<p></p>
<div>After looking into this more I see there is a fair challenge associate=
d with this idea. With each CPU (and execution context) having its own dist=
inct buffer for messages (struct cfs_trace_cpu_data), the messages are not =
chronologically sorted in kernel
 memory. Instead, they are written to a regular file in CPU order and then =
the sorted chronologically in userspace prior to printing.<br>
<br>
Implementing a&nbsp; &quot;/dev/lmsg&quot; device would be challenging with=
 the existing data structures because sorting would have to happen in kerne=
l space as the device responds to reads.<br>
<br>
I found this issue: LU-14428 &quot;Convert tracefile to use ring_buffer fro=
m linux&quot; which does not look to be completed, seeing as a ring_buffer =
is not currently in use here -- but if this is completed, implementing &quo=
t;/dev/lmsg&quot; with the same interface as &quot;/dev/kmsg&quot;
 would be much simpler. (Assuming I understand correctly that the proposal =
is a single global ring buffer. Let me know if I am mistaken and the propos=
al is a set of per-CPU ring buffers, because then the sorting problem is no=
t avoided.)<br>
<br>
I reported a new issue LU-16746 &quot;Convert tracefile to export debug log=
s via character device&quot; for this idea.This can be worked on after LU-1=
4428 is completed. If I can be of assistance on LU-14428 by helping with an=
y sub-tasks, let me know. I am interested
 in helping with this area of Lustre.<br>
<br>
Thanks,<br>
<br>
Thomas Bertschinger<br>
</div>
<p></p>
<br>
<div style=3D"color: rgb(0, 0, 0);">
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font style=3D"font-size:11pt" face=
=3D"Calibri, sans-serif" color=3D"#000000"><b>From:</b> lustre-devel &lt;lu=
stre-devel-bounces@lists.lustre.org&gt; on behalf of Bertschinger, Thomas A=
ndrew Hjorth via lustre-devel &lt;lustre-devel@lists.lustre.org&gt;<br>
<b>Sent:</b> Monday, April 10, 2023 8:19 AM<br>
<b>To:</b> lustre-devel@lists.lustre.org<br>
<b>Subject:</b> [lustre-devel] lctl debug_kernel: usability improvements?</=
font>
<div>&nbsp;</div>
</div>
<div>
<div id=3D"divtagdefaultwrapper" dir=3D"ltr" style=3D"font-size:12pt; color=
:rgb(0,0,0); font-family:Calibri,Helvetica,sans-serif,&quot;EmojiFont&quot;=
,&quot;Apple Color Emoji&quot;,&quot;Segoe UI Emoji&quot;,NotoColorEmoji,&q=
uot;Segoe UI Symbol&quot;,&quot;Android Emoji&quot;,EmojiSymbols">
<p></p>
<div class=3D"_rp_T4" id=3D"Item.MessagePartBody" style=3D"">
<div class=3D"_rp_U4 ms-font-weight-regular ms-font-color-neutralDark rpHig=
hlightAllClass rpHighlightBodyClass" id=3D"Item.MessageUniqueBody" style=3D=
"font-family:&quot;wf_segoe-ui_normal&quot;,&quot;Segoe UI&quot;,&quot;Sego=
e WP&quot;,Tahoma,Arial,sans-serif,serif,&quot;EmojiFont&quot;">
<div class=3D"rps_d79c">
<div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:10pt"=
>
<div class=3D"PlainText">Hello,<br>
<br>
Recently when using &quot;lctl dk&quot; I have found myself wanting some of=
 the &quot;quality of life&quot; features that exist in the similar linux t=
ool dmesg. In particular, having the ability to &quot;follow&quot; the debu=
g log like &quot;dmesg -w&quot; would be very handy IMO.<br>
<br>
I've attempted to implement this in userspace with the existing tooling (us=
ing &quot;lctl debug_daemon&quot; to write the encoded log to a file, and &=
quot;lctl debug_file&quot; to decode it) but have run into challenges. I fi=
rst tried creating a FIFO and had debug_daemon write
 to it and debug_file read from it. Unfortunately this fails because the ke=
rnel thread that writes to this file (tracefiled in libcfs/libcfs/tracefile=
.c) repeatedly opens and closes the file, but after the first close reading=
 the FIFO fails.</div>
<div class=3D"PlainText"><br>
My next idea was to have debug_daemon write to a regular file and debug_fil=
e read it like &quot;tail -f&quot;. This should work in theory but has disa=
dvantages: the user must remember to delete the file when done (the tool co=
uld do this but not if it exits uncleanly),
 and also entries could be missed if the file is deleted while the tool is =
still running.<br>
<br>
I think the cleanest solution is to rework the debug_kernel interface to be=
 like linux's /dev/kmsg. A character device, perhaps named /dev/lmsg, could=
 be created that outputs the buffer contents when read.&nbsp;<font size=3D"=
2"><span style=3D"font-size:10pt">Implementing
 &quot;follow&quot; would be trivial with this interface. </span></font>The=
 existing userspace tools could also easily be updated to use this interfac=
e, and it would bring other benefits, for example &quot;lctl dk&quot; not n=
eeding to copy the message buffer to a tmp file. The
 disadvantage here is that this could be a significant kernel-side refactor=
.<br>
<br>
I feel the ability to follow Lustre's debug log would be useful to both sys=
admins and developers but want to get some other input. Would this be valua=
ble to anyone? If this would be useful -- and feasible -- I would be happy =
to submit a JIRA ticket and work
 on a patch but wanted to get some more opinions. I'm not very familiar wit=
h the kernel side code yet so I'm not sure how complicated this would be.<b=
r>
<br>
- Thomas Bertschinger</div>
</span></font></div>
</div>
</div>
</div>
</div>
<span class=3D"PersonaPaneLauncher">
<div class=3D"_pe_d _pe_62" tabindex=3D"-1"></div>
</span>
<div class=3D"_rp_Z4"></div>
<div class=3D"_rp_j" tabindex=3D"-1" style=3D"">
<div class=3D"_qc_F ms-bg-color-white _qc_G">
<hr class=3D"_qc_B">
</div>
</div>
<p></p>
</div>
</div>
</div>
</div>
</body>
</html>

--_000_f746930fc1fa42fc8da9d04696a66444lanlgov_--

--===============7563204839007175441==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7563204839007175441==--
