Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 71350C76196
	for <lustre-devel@archiver.kernel.org>; Mon, 10 Apr 2023 14:19:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PwB1m65ZSz1y6b;
	Mon, 10 Apr 2023 07:19:40 -0700 (PDT)
Received: from proofpoint8.lanl.gov (proofpoint8.lanl.gov [204.121.3.47])
 (using TLSv1.2 with cipher AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PwB1j4H1qz1wMp
 for <lustre-devel@lists.lustre.org>; Mon, 10 Apr 2023 07:19:37 -0700 (PDT)
Received: from pps.filterd (proofpoint8.lanl.gov [127.0.0.1])
 by proofpoint8.lanl.gov (8.17.1.19/8.17.1.19) with ESMTP id 33AAxpvI000389
 for <lustre-devel@lists.lustre.org>; Mon, 10 Apr 2023 08:19:36 -0600
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=lanl.gov;
 h=from : to : subject :
 date : message-id : content-type : mime-version; s=lanl;
 bh=uc3HSuEW5FqToVXs8IvOLj4TBULosQxL3Hdqe1++7vU=;
 b=IbXgLDim/ii0SMHD9hOHSJXhvivD7hxI2DZPflkJUuGXdG4bMtY2nGuOy4jDta0icowB
 +IkdbZRvj0rXqAtaCKKwPkB+HnJg4Ag36/GlQMHRfTTZYzGRt8Gxivj1W+BDh8lIURYH
 MISG3T6j/1zCBA9DHhida4y9Z+TwlwlYgDCGEVV5CGfx3k2g/YGbVErQZ3J+N8ZYMuA1
 pXTDWj8O+TAiFzb9gf/7SNAhoZ2u/FMY6I9K+dCdH0RnxeRZNhOD1kURgFwzGv+IohfS
 SYZ6Y1JbABn1blMzIIGn3dGpCm0NGa8W70dK6Vh6C1obB1rkECZxqQ/028O0gQOrOg1C GA== 
Received: from mailrelay2.lanl.gov (mailrelay2.lanl.gov [128.165.4.103])
 by proofpoint8.lanl.gov (PPS) with ESMTP id 3pu522hewk-1
 for <lustre-devel@lists.lustre.org>; Mon, 10 Apr 2023 08:19:36 -0600
Received: from localhost (localhost [127.0.0.1])
 by mailrelay2.lanl.gov (Postfix) with ESMTP id 718081008E1E
 for <lustre-devel@lists.lustre.org>; Mon, 10 Apr 2023 08:19:36 -0600 (MDT)
X-NIE-2-Virus-Scanner: amavisd-new at mailrelay2.lanl.gov
Received: from EXG16-P-MBX05.win.lanl.gov (exg16-p-mbx05.win.lanl.gov
 [128.165.106.185])
 by mailrelay2.lanl.gov (Postfix) with ESMTP id 5ED171008E1B
 for <lustre-devel@lists.lustre.org>; Mon, 10 Apr 2023 08:19:36 -0600 (MDT)
Received: from EXG16-P-MBX06.win.lanl.gov (128.165.106.186) by
 EXG16-P-MBX05.win.lanl.gov (128.165.106.185) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.23; Mon, 10 Apr 2023 08:19:36 -0600
Received: from EXG16-P-MBX06.win.lanl.gov ([fe80::7dd9:e3e8:7a3f:fda9]) by
 EXG16-P-MBX06.win.lanl.gov ([fe80::7dd9:e3e8:7a3f:fda9%5]) with mapi id
 15.01.2507.023; Mon, 10 Apr 2023 08:19:36 -0600
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: lctl debug_kernel: usability improvements?
Thread-Index: AQHZa7H/0aa5cHT1N02J/Lsdl9C7bg==
Date: Mon, 10 Apr 2023 14:19:36 +0000
Message-ID: <15ba99f9ed8842009d3f8ebb1a494b53@lanl.gov>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [128.165.106.172]
MIME-Version: 1.0
X-Proofpoint-ORIG-GUID: MoIPfW9bWuIffzVxYn8x6TQgIO2P7GHo
X-Proofpoint-GUID: MoIPfW9bWuIffzVxYn8x6TQgIO2P7GHo
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.254,Aquarius:18.0.942,Hydra:6.0.573,FMLib:17.11.170.22
 definitions=2023-04-10_10,2023-04-06_03,2023-02-09_01
X-Proofpoint-Spam-Reason: safe
Subject: [lustre-devel] lctl debug_kernel: usability improvements?
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
Content-Type: multipart/mixed; boundary="===============0512148616062449154=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0512148616062449154==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_15ba99f9ed8842009d3f8ebb1a494b53lanlgov_"

--_000_15ba99f9ed8842009d3f8ebb1a494b53lanlgov_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

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

--_000_15ba99f9ed8842009d3f8ebb1a494b53lanlgov_
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
<div id=3D"divtagdefaultwrapper" dir=3D"ltr" style=3D"font-size: 12pt; colo=
r: rgb(0, 0, 0); font-family: Calibri, Helvetica, sans-serif, &quot;EmojiFo=
nt&quot;, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, NotoCo=
lorEmoji, &quot;Segoe UI Symbol&quot;, &quot;Android Emoji&quot;, EmojiSymb=
ols;">
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
</body>
</html>

--_000_15ba99f9ed8842009d3f8ebb1a494b53lanlgov_--

--===============0512148616062449154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0512148616062449154==--
