Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DC93BC4332F
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Nov 2022 07:31:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4N2wRb6d0Fz1wg3;
	Thu,  3 Nov 2022 00:31:23 -0700 (PDT)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com
 [207.171.190.10])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4N2wRX6HrWz1wY0
 for <lustre-devel@lists.lustre.org>; Thu,  3 Nov 2022 00:31:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1667460681; x=1698996681;
 h=from:to:subject:date:message-id:mime-version;
 bh=+Rc+kzwQZe5Ke/tzLmir2N6k/DYOfF2bFYjGlf23hNo=;
 b=NxHAvvUxwzt/gQXQTQi7tJHljbSiJjsW4zlG946/MbsEepFh+cWnYixI
 4SFgQpaq0A5JokCujRHcKsVg7EKQjsHZUMD0iDj8SqHM83d0vM0WR9z5N
 7o5zF9JSBhlxuV3eHznTOSMBf391ln7aY7hViYLKatQE79LvhEIzc/Ah1 w=;
X-IronPort-AV: E=Sophos;i="5.95,235,1661817600"; 
 d="scan'208,217";a="238116798"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO
 email-inbound-relay-pdx-2c-m6i4x-5eae960a.us-west-2.amazon.com) ([10.43.8.6])
 by smtp-border-fw-33001.sea14.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Nov 2022 07:31:15 +0000
Received: from EX13D25EUA004.ant.amazon.com
 (pdx1-ws-svc-p6-lb9-vlan2.pdx.amazon.com [10.236.137.194])
 by email-inbound-relay-pdx-2c-m6i4x-5eae960a.us-west-2.amazon.com (Postfix)
 with ESMTPS id 838724190B
 for <lustre-devel@lists.lustre.org>; Thu,  3 Nov 2022 07:31:13 +0000 (UTC)
Received: from EX19D007EUA002.ant.amazon.com (10.252.50.68) by
 EX13D25EUA004.ant.amazon.com (10.43.165.12) with Microsoft SMTP Server (TLS)
 id 15.0.1497.42; Thu, 3 Nov 2022 07:31:12 +0000
Received: from EX19D007EUA004.ant.amazon.com (10.252.50.76) by
 EX19D007EUA002.ant.amazon.com (10.252.50.68) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.15; Thu, 3 Nov 2022 07:31:12 +0000
Received: from EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9]) by
 EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9%3]) with
 mapi id 15.02.1118.015; Thu, 3 Nov 2022 07:31:12 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: lnet selftest using large NIDs (16 byte)
Thread-Index: AdjvVAHzu75XE12hS7CpdeYTg+J+nA==
Date: Thu, 3 Nov 2022 07:31:12 +0000
Message-ID: <05a465d4c9e2418ca719e7329fdfc7b2@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.85.143.175]
MIME-Version: 1.0
Subject: [lustre-devel] lnet selftest using large NIDs (16 byte)
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
From: "Yitschak, Yehuda via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Yitschak, Yehuda" <yehuday@amazon.com>
Content-Type: multipart/mixed; boundary="===============0156795246859022992=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0156795246859022992==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_05a465d4c9e2418ca719e7329fdfc7b2amazoncom_"

--_000_05a465d4c9e2418ca719e7329fdfc7b2amazoncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello

I am working on a PoC for a new LND which need to use a 16 bytes NID addres=
s
I am currently facing issues adding a 16byte NID to Lnet selftest since it =
only handles 4 byte NIDs

Are there any patches or WIP to add 16 byte NID support to LST ?

Regards

Yehuda

--_000_05a465d4c9e2418ca719e7329fdfc7b2amazoncom_
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
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 72.0pt 72.0pt 72.0pt;}
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
<p class=3D"MsoNormal">Hello <br>
<br>
I am working on a PoC for a new LND which need to use a 16 bytes NID addres=
s<br>
I am currently facing issues adding a 16byte NID to Lnet selftest since it =
only handles 4 byte NIDs<br>
<br>
Are there any patches or WIP to add 16 byte NID support to LST ? <br>
<br>
Regards<br>
<br>
Yehuda <o:p></o:p></p>
</div>
</body>
</html>

--_000_05a465d4c9e2418ca719e7329fdfc7b2amazoncom_--

--===============0156795246859022992==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0156795246859022992==--
