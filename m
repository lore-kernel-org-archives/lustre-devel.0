Return-Path: <SRS0=RG38=L5=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E86AC07E99
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Jul 2021 13:45:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EAE64613FC
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Jul 2021 13:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAE64613FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=CEA.FR
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 88EA1337021;
	Mon,  5 Jul 2021 06:45:28 -0700 (PDT)
Received: from cirse-smtp-out.extra.cea.fr (cirse-smtp-out.extra.cea.fr
 [132.167.192.148])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F3B20337002
 for <lustre-devel@lists.lustre.org>; Mon,  5 Jul 2021 06:45:25 -0700 (PDT)
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
 by cirse-sys.extra.cea.fr (8.14.7/8.14.7/CEAnet-Internet-out-4.0) with ESMTP
 id 165DjOpC040251
 for <lustre-devel@lists.lustre.org>; Mon, 5 Jul 2021 15:45:24 +0200
Received: from pisaure.intra.cea.fr (localhost [127.0.0.1])
 by localhost (Postfix) with SMTP id EF3C52038DA
 for <lustre-devel@lists.lustre.org>; Mon,  5 Jul 2021 15:45:23 +0200 (CEST)
Received: from muguet2-smtp-out.intra.cea.fr (muguet2-smtp-out.intra.cea.fr
 [132.166.192.13])
 by pisaure.intra.cea.fr (Postfix) with ESMTP id DEC45203852
 for <lustre-devel@lists.lustre.org>; Mon,  5 Jul 2021 15:45:23 +0200 (CEST)
Received: from zia.cdc.esteban.ctsi (out.dam.intra.cea.fr [132.165.76.10])
 by muguet2-sys.intra.cea.fr (8.14.7/8.14.7/CEAnet-Internet-out-4.0) with SMTP
 id 165DjNtL022513
 for <lustre-devel@lists.lustre.org>; Mon, 5 Jul 2021 15:45:23 +0200
Received: (qmail 28368 invoked from network); 5 Jul 2021 13:45:23 -0000
From: "Thomas.LEIBOVICI@CEA.FR" <Thomas.LEIBOVICI@CEA.FR>
To: "'lustre-discuss@lists.lustre.org'" <lustre-discuss@lists.lustre.org>,
 "'lustre-devel@lists.lustre.org'" <lustre-devel@lists.lustre.org>,
 "'lustre-announce@lists.lustre.org'" <lustre-announce@lists.lustre.org>
Thread-Topic: LAD'21: Call for presentations
Thread-Index: Addxo4LSxGczlwCHRhKprATd1PNl8Q==
Date: Mon, 5 Jul 2021 13:45:21 +0000
Message-ID: <280436dbb62c4d45a558ad32012e5789@U-MYKONOS3.dif.dam.intra.cea.fr>
Accept-Language: fr-FR, en-US
Content-Language: fr-FR
MIME-Version: 1.0
Subject: [lustre-devel] LAD'21: Call for presentations
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
Content-Type: multipart/mixed; boundary="===============6579890232056793757=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6579890232056793757==
Content-Language: fr-FR
Content-Type: multipart/related;
	boundary="_004_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_";
	type="multipart/alternative"

--_004_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_
Content-Type: multipart/alternative;
	boundary="_000_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_"

--_000_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

LAD'21 - Lustre Administrators and Developers Workshop
September 28th-30th, 2021
Online webinar + chat platform
We are glad to announce LAD'21!

This event will be a great opportunity for worldwide Lustre administrators =
and developers to gather and exchange their experiences, developments, tool=
s, good practices and more. This year again, it will take place online from=
 September 28th to September 30th, 2021.
Like last year, pre-recorded sessions will be broadcasted twice a day for t=
he various time zones. Additionally, a chat platform will be setup to manag=
e questions/answers and to allow discussions with the speakers and the Lust=
re community.

We are waiting for your participation!

PRESENTATIONS

We invite community members to send proposals for presentation.
Topics of interest include, but are not limited to:

*         feedback/news about a particular Lustre feature;

*         a good Lustre success (/ failure) story;

*         anything in general that affects the Lustre community.

No proceeding is required, just an abstract for a 20-25 min technical prese=
ntation.
Submit your abstract using EasyChair, before September 1st, 2021, using thi=
s submission link:
https://easychair.org/conferences/?conf=3Dlad21

Do not hesitate! Presenters will be rewarded with a great exclusive goodie =
of LAD'21!

More details about abstract submission: https://www.eofs.eu/events/lad21

We hope to read you soon!

Best regards,
The LAD organization team.
WEB PAGE
https://www.eofs.eu/events/lad21

[cid:image001.png@01D771B3.DF0BB4D0]

--_000_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
<!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-priority:99;
	mso-style-link:"Texte de bulles Car";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.TextedebullesCar
	{mso-style-name:"Texte de bulles Car";
	mso-style-priority:99;
	mso-style-link:"Texte de bulles";
	font-family:"Tahoma","sans-serif";}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:70.85pt 70.85pt 70.85pt 70.85pt;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:86266983;
	mso-list-type:hybrid;
	mso-list-template-ids:2054820740 67698689 67698691 67698693 67698689 67698=
691 67698693 67698689 67698691 67698693;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l0:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Courier New";}
@list l0:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Wingdings;}
@list l0:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l0:level5
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Courier New";}
@list l0:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Wingdings;}
@list l0:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l0:level8
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Courier New";}
@list l0:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Wingdings;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><b>LAD'21 - Lustre Administrators and Developers Wor=
kshop<o:p></o:p></b></p>
<p class=3D"MsoNormal"><b><o:p></o:p></b></p>
<p class=3D"MsoNormal"><b>September 28th-30th, 2021<o:p></o:p></b></p>
<p class=3D"MsoNormal"><b>Online webinar &#43; chat platform</b><o:p></o:p>=
</p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">We are glad to announce LAD&#8217;21!<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">This event will be a great opportunity for worldwide=
 Lustre administrators and developers to gather and exchange their experien=
ces, developments, tools, good practices and more. This year again, it will=
 take place online from September
 28th to September 30th, 2021.<o:p></o:p></p>
<p class=3D"MsoNormal">Like last year, pre-recorded sessions will be broadc=
asted twice a day for the various time zones. Additionally, a chat platform=
 will be setup to manage questions/answers and to allow discussions with th=
e speakers and the Lustre community.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">We are waiting for your participation!<o:p></o:p></p=
>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><b>PRESENTATIONS<o:p></o:p></b></p>
<p class=3D"MsoNormal"><b><o:p>&nbsp;</o:p></b></p>
<p class=3D"MsoNormal">We invite community members to send proposals for pr=
esentation.<o:p></o:p></p>
<p class=3D"MsoNormal">Topics of interest include, but are not limited to:<=
o:p></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-18.0pt;mso-list:l0 leve=
l1 lfo1"><![if !supportLists]><span style=3D"font-family:Symbol"><span styl=
e=3D"mso-list:Ignore">&middot;<span style=3D"font:7.0pt &quot;Times New Rom=
an&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>feedback/news about a particular Lustre feat=
ure;<o:p></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-18.0pt;mso-list:l0 leve=
l1 lfo1"><![if !supportLists]><span style=3D"font-family:Symbol"><span styl=
e=3D"mso-list:Ignore">&middot;<span style=3D"font:7.0pt &quot;Times New Rom=
an&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>a good Lustre success (/ failure) story;<o:p=
></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-18.0pt;mso-list:l0 leve=
l1 lfo1"><![if !supportLists]><span style=3D"font-family:Symbol"><span styl=
e=3D"mso-list:Ignore">&middot;<span style=3D"font:7.0pt &quot;Times New Rom=
an&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>anything in general that affects the Lustre =
community.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">No proceeding is required, just an abstract for a 20=
-25 min technical presentation.<br>
Submit your abstract using EasyChair, before September 1st, 2021, using thi=
s submission link:<o:p></o:p></p>
<p class=3D"MsoNormal"><a href=3D"https://easychair.org/conferences/?conf=
=3Dlad21">https://easychair.org/conferences/?conf=3Dlad21</a><o:p></o:p></p=
>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Do not hesitate! Presenters will be rewarded with a =
great exclusive goodie of LAD'21!<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">More details about abstract submission: <a href=3D"h=
ttps://www.eofs.eu/events/lad21">
https://www.eofs.eu/events/lad21</a><o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">We hope to read you soon!<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Best regards,<o:p></o:p></p>
<p class=3D"MsoNormal">The LAD organization team.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal"><b>WEB PAGE<o:p></o:p></b></p>
<p class=3D"MsoNormal"><a href=3D"https://www.eofs.eu/events/lad21">https:/=
/www.eofs.eu/events/lad21</a><o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><img border=3D"0" width=3D"181" height=3D"128" id=3D=
"Image_x0020_3" src=3D"cid:image001.png@01D771B3.DF0BB4D0"><o:p></o:p></p>
</div>
</body>
</html>

--_000_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_--

--_004_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_
Content-Type: image/png; name="image001.png"
Content-Description: image001.png
Content-Disposition: inline; filename="image001.png"; size=31537;
	creation-date="Mon, 05 Jul 2021 13:38:58 GMT";
	modification-date="Mon, 05 Jul 2021 13:38:58 GMT"
Content-ID: <image001.png@01D771B3.DF0BB4D0>
Content-Transfer-Encoding: base64

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
+mc/fY89j2n7bz2y1e5/ZDNW/Q9g9U+Tzejhsj+aOdhUf5DbRSS4hYZC0XocPMFGpephp25bVxwP
OQkT3hRskcDbaXh7tJ3DmsHzfDjeKiCcV/bQoHkdM02M/+XrlhnppR2ZGlvstusvt1uvX243X7dc
+0WICIK5+hdS6LYVC8DMJV9ghIZ2E4Pa3iPgshr5fIGEqN7069Vytm7bihXZc+2et95TPJa03P3m
uz1v0PLsc8/a7a+/3bqwIj0P5nPlVVfa2rVrdenzn/+80r3xjW8saCJQrrrqqipJyfIp1/hjz949
2G6hU1p/+47tRb5Zv+tvuF69CA+C56/+6q/s/m/db29961uL8hYuWqhns8zNWzbbkqUIgHqRv3nY
o+XRxx5FoNQVDtLK38FDBxH/PGgf+rEPFbwmHwoPhdrenQVyhLH35B6IjL3GVDbtbk974cGx3tVX
LMJnsf2jn7jbtuw4Yg88sdW+DZAfxwQQNw2aA+xwqR0niQbpReFstkJ8OHFDQMd4TBLEV6uUrePB
4cG9cGTkG5Cl9CUNTCSzmPEe7mv0FyjjmkbLdHZjQIFLnOygFqM7prG1AyBeAdPicrsOEyEKZKlo
5DCNnTuVIydKyGjO9FGzpAdjurZLbfByrk9PS5cVtaS/5s7rd7FjetTd9Hw6Ojo0gMrnp39fNNPK
RXbx7FWoebdu3VpozkxSLZ+8eP3rX29/+Zd/aW9+85ud1zj4PM2Nq6++WsBnj3TLLbfYrl27vN2i
blXa2UvxfpZZvcdz38INS7AgbFVaLlYft7kjXpvx1uEWTHD7M9XYGT9nG19FgGNL43/00Tfb/kOn
7EGYKPc9uNkOHD5pDeDJrCbssYcIvWFo8GG+KptKNRYbe3yKZknC7CBm2Y5Vrwpt6ohVvXB628Et
adEsnkfhtWG6UiuUAewW7NR5682r7E23rZUvmVq29CGjrGJUEaxJCaPNjEt6QT2YQpfcxd1x01ia
+U1XCRe7Xrm2ds1ae+bpZ+z3f+/3iy6apkUCXKVU86jmj/NzCJY/io1VTp06Zdu2brMf/MEfDO3g
z214coNt3bK1IPaGG264wF7mTQJw967d9qY3vknCe98377NBBMWz27+Ahsht1sxZ6uZJg0wclLdw
wUJ7+KGHbQDLnvbt22fLli7zXUen12Ha71tvuVVmBflRTbto4SLsGjXL/uD3/0C9BM0YCk4V4BdV
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
gUxHPwAAAABJRU5ErkJggg==

--_004_280436dbb62c4d45a558ad32012e5789UMYKONOS3difdamintracea_--

--===============6579890232056793757==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6579890232056793757==--
