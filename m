Return-Path: <SRS0=zT6c=FH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F15CCC433FE
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Dec 2020 17:40:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6F42D206CB
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Dec 2020 17:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F42D206CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=lmco.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1D42C21FDD6;
	Thu,  3 Dec 2020 09:40:25 -0800 (PST)
Received: from mailfo01.lmco.com (mailfo01.lmco.com [192.31.106.12])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 199E521FDD6
 for <lustre-devel@lists.lustre.org>; Thu,  3 Dec 2020 09:40:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=lmco.com;
 h=from : to : subject :
 date : message-id : content-type : mime-version; s=corpgw200619;
 bh=VkTAz/otdK+SYzNXrHmZkvO1AOhbiNIQR/MNE8bwpF0=;
 b=UyX+UDNXGFts4b47lYooKC1CrLzQiLiLlrGFUX0a9m6S9xXgjKgkN5v5PEbS0zxLf9ph
 iSff/tBPJ5/AizgyvdkexJ5kjp/jLWh2Cei2YyUMc9CQ0wDs2C18MZxi+Lx7dVTvfCZ9
 uVOsnNu+VIcRqW8WH32mQLUr9wz7lSUKfTjWNMRouPhpYJzlnVD6QTCmX2XoTn+rlHXr
 6PIDHQhVuWphPVYg+hgo0zrpaONrm0qUTJ1nU3+SDvsujdUeklt5PDvmDc52TgqQmJ7s
 u4ThokX44Yi6p1hfEF0tx6XXmGLmqhdpk5FBUlstE9qupQHn3DpGvrtH4KO2pYGNLSsN EA== 
Received: from lmxpvfgd08w03.us.lmco.com (lmxpvfg08w03.ems.lmco.com
 [172.23.84.50])
 by mailfo01.lmco.com (8.16.0.42/8.16.0.42) with ESMTP id 0B3HeM28030945
 for <lustre-devel@lists.lustre.org>; Thu, 3 Dec 2020 17:40:23 GMT
Received: from lmxpvfgd08w05.us.lmco.com (172.23.84.52) by
 lmxpvfgd08w03.us.lmco.com (172.23.84.50) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256) id
 15.1.1979.3; Thu, 3 Dec 2020 12:40:22 -0500
Received: from lmxpvfgd08w05.us.lmco.com ([172.23.84.52]) by
 lmxpvfgd08w05.us.lmco.com ([172.23.84.52]) with mapi id 15.01.1979.003; Thu,
 3 Dec 2020 12:40:22 -0500
From: "Cable, Sam" <sam.cable@lmco.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: asynchronous I/O in lustre
Thread-Index: AdbJmsC7U25Tlt8OQOGEFy0gvpnHiA==
Date: Thu, 3 Dec 2020 17:40:22 +0000
Message-ID: <2e2b7e84cc5a4f268c68c9ac0204a893@lmco.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [172.23.84.16]
MIME-Version: 1.0
X-LM-Outbound: External 172.23.84.50 cntry=**
 g=RmhtkVPB0PT34DVffHc0vc6wtS1QApQL q=0B3HeM28030945 m=1
X-LM-OBSENDER: sam.cable@lmco.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.312, 18.0.737
 definitions=2020-12-03_10:2020-12-03,
 2020-12-03 signatures=0
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 mlxlogscore=938
 adultscore=0
 bulkscore=0 phishscore=0 suspectscore=0 spamscore=0 mlxscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2009150000 definitions=main-2012030104
Subject: [lustre-devel] asynchronous I/O in lustre
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Content-Type: multipart/mixed; boundary="===============6486764676649826162=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6486764676649826162==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_2e2b7e84cc5a4f268c68c9ac0204a893lmcocom_"

--_000_2e2b7e84cc5a4f268c68c9ac0204a893lmcocom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I am investigating the use of asynchronous I/O in Lustre.  (FWIW, I am new =
to async I/O.  And although I am  a long time user of Lustre file systems, =
I am new to developing specifically in Lustre as well.)  I have a couple of=
 questions.

It is my understanding that Lustre did not support async I/O for a while, b=
ut reintroduced it at some point.  Can anyone tell me in which revision asy=
nc I/O was supported again?

Does Lustre have its own API for asynchronous I/O other than the usual POSI=
X AIO?  If there is a particular API, I would very much appreciate a pointe=
r to it.  I have not been able to find any info on this.

Thanks for your help.

--Sam Cable


--_000_2e2b7e84cc5a4f268c68c9ac0204a893lmcocom_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">I am investigating the use of asynchronous I/O in Lu=
stre.&nbsp; (FWIW, I am new to async I/O.&nbsp; And although I am&nbsp; a l=
ong time user of Lustre file systems, I am new to developing specifically i=
n Lustre as well.)&nbsp; I have a couple of questions.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">It is my understanding that Lustre did not support a=
sync I/O for a while, but reintroduced it at some point.&nbsp; Can anyone t=
ell me in which revision async I/O was supported again?<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Does Lustre have its own API for asynchronous I/O ot=
her than the usual POSIX AIO?&nbsp; If there is a particular API, I would v=
ery much appreciate a pointer to it.&nbsp; I have not been able to find any=
 info on this.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Thanks for your help.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">--Sam Cable<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_2e2b7e84cc5a4f268c68c9ac0204a893lmcocom_--

--===============6486764676649826162==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6486764676649826162==--
