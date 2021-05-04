Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,T_KAM_HTML_FONT_INVALID
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9170CC433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 20:17:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1613461003
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 20:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1613461003
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2572121F9C2;
	Tue,  4 May 2021 13:17:30 -0700 (PDT)
Received: from NAM11-CO1-obe.outbound.protection.outlook.com
 (mail-co1nam11on2071.outbound.protection.outlook.com [40.107.220.71])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F29DD21F967
 for <lustre-devel@lists.lustre.org>; Tue,  4 May 2021 13:17:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CSCEgiMuWEjWNIDSv3QZ9c8yNWeAm1xI9F5KnKE03PpgaA1K2FhILGQVvJcyfpLy0ZH75mpMO7fAncOqPTu7e31SIlG/HjlFkk9CA2gW9NLVuPassIlX/TIQCYHdkWDpzPW4Ky1pYOyneB7vYUmhbk1HSqpicRIlVxvOnZAG1+wMnXs5GH3+OgOTYx8MzUX+4A0GK4kS2DwtlGNJ/Yl/zsGohuWkFGhC0UMiuz2YYp8QdIu5z8gxRNYpVRWVSKhKF30nZUpz3keoVL/5MmNx6gvVYH/UcK/wi2e0Ezb7w2PBT/bW4yIwfg8E9JDDKQ9Iqfz5Nz8oCseqmLhi3uJbMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M8cbsnGxyIOA8/tmTooLwgAUsLqnocuwo9ek0ZXi1nE=;
 b=ieyaDu2j55X0tQILfzWJtPheYhdZwIaEn8gmXEb1Dbc1EcTGg5YaYcptD+FtHKbW+uZi8P7su25L/ecl0XhSgWbHZrVuKkvRorSSV0JHCOBoJC3KfOUgrreEF89hhaSLw388vWMsZtJg1xn356awb/ow7BszuWW6EgdVXJ9v8aMb6GWwH4pye9JTJO2TZjk51+FJLzCUvRq827QqWPVmgcOBa0oMpfR/5ByVABNbjlXwx/oeTmgjnDjiuISxq/FWy6dcO+8Z6Eg5HVh0VyKr5/iRR5aMUW6VGIWJaaZ80xMlD/v6gug/n5czKAAfneh8j466Ow7kzvOJ0pW6I5V8xA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M8cbsnGxyIOA8/tmTooLwgAUsLqnocuwo9ek0ZXi1nE=;
 b=xSvr3OMm0KV0Tv7G0k9/20PiIeBcisNrYshVZm2MQkPEpszm2Kht2vi+LsTDYWD/AlBV0WcZfWjg5uSpAxmOqA8BdGbaWJY2kmvUAPUdWGAYKrQmJiJaj70X29mMYlkXMN6x9IYLcBHhEciNU/oeHcLwg4r5CTFYnh/5eaxPOwg=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by MN2PR19MB3664.namprd19.prod.outlook.com (2603:10b6:208:191::16)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4108.24; Tue, 4 May
 2021 20:17:06 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::b545:eb54:b507:5d2f]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::b545:eb54:b507:5d2f%3]) with mapi id 15.20.4087.044; Tue, 4 May 2021
 20:17:06 +0000
To: Saisha Kamat <skamat1@uncc.edu>
Thread-Topic: [lustre-devel] Reading extended attributes from a Lustre
 filesystem image.
Thread-Index: AQHXQPdCUTKI8JAH6U6DVpxnue4HRKrTwvkA
Date: Tue, 4 May 2021 20:17:06 +0000
Message-ID: <FEA12F9C-FE26-481F-8DB2-2EE448BC1160@ddn.com>
References: <CACyzrcQCUg7RDj9nwa8c8njt9M-wUBB-RgNkTtNkx_zoXsEz5g@mail.gmail.com>
In-Reply-To: <CACyzrcQCUg7RDj9nwa8c8njt9M-wUBB-RgNkTtNkx_zoXsEz5g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: uncc.edu; dkim=none (message not signed)
 header.d=none;uncc.edu; dmarc=none action=none header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fafb23ee-9190-4c51-a6aa-08d90f3996d9
x-ms-traffictypediagnostic: MN2PR19MB3664:
x-microsoft-antispam-prvs: <MN2PR19MB366417C67FAF9A8022D77FB2A75A9@MN2PR19MB3664.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: aEOM6GJa+O2w0Ez5xB6RL/ojlyuNTb5Mu2Ex8wPge8U97n+D9FjpP2c9yEP525F7MXwQpmQtimzGLGWKQJrqCfvCPwcVLM9HHk8hPjKyeC/KlgWzQXS1sSc5eno31PsFJzeonlWgDH5+bOTL6tgzDL0FMpLBHRDx11g42zIEfnXA3j7eDpBA6wbNrSPCko5z4qx8C91Z8eyNwd6Vr8ofr78TDQmoXtfmz6eYEi2jMiDxplTWjW532ECIzSbcN73eCgyMRFJuoVfjM0Um9B5vfJhhju9EhefIjv4GIcBf5S1brz6csqSxs9r34Vuu/d9sFqnGo98uFrx4MOEW8SfGseQ1AbuYEMxO/3ldxswIA3aBdV+e2eL83EuDMA4OFvrq13Pi6909U5yVtdA54oqRoI3lgflsY0Es+vCCdqlz8nCeFvI/bsXCXfK9w2WGjnG/c9H4ipfdkQ8XuzVI2WULtvkLYgEn/raqxf48A/GZjnAret/ujn4RwWqPFi1ANduzpEaZ/v2wQpbqcg1hzPbNCWA/tA8bLd3GEo6QsPy85E+bkzWBALUvhHV0Q/cHmi/uSRw+e/z3Ytq2hrd+PSLz0QHJHPRwHJGGC9jvEcJBAJK9e3ZRjLQf2YvDK8InxxP57FhwCAL2praOxutRPhPEwaxjNsJuVrjQ4EfN5qx5jg0akdrSYnEpNhjPdJx/efg6M0ysO6ZN13yxYPcY3sfyK29+jSSHbuk8HK6FmrPDNCI=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(39840400004)(376002)(346002)(396003)(366004)(136003)(86362001)(4326008)(166002)(8676002)(83380400001)(316002)(9686003)(6512007)(36756003)(33656002)(53546011)(26005)(64756008)(66446008)(66476007)(91956017)(6916009)(76116006)(66946007)(38100700002)(5660300002)(2906002)(66556008)(71200400001)(122000001)(8936002)(186003)(966005)(478600001)(6506007)(6486002)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?TZhsqtqaMW0vslOgPJgS8nCkdTC0Uv344e8aSJRCuBi82FcjzzXzzHx97Q9P?=
 =?us-ascii?Q?HIvwZRcfgDUILQAmSAH3c9AtzytFEA6xdnGRiX5m62DHMymupCth7PrZ6FXP?=
 =?us-ascii?Q?sWg5W0gxCy40wvAZBWnkbdofukjPLq3hTG6n/ag3h2CD7ZNSAP9WAMi766qC?=
 =?us-ascii?Q?uuvVSL9YhvZDfaP/ntmmfSUMPiXSDrPmsqS8Lilibfu4re1KZAAwct2N4PMr?=
 =?us-ascii?Q?KcF0nuUVv5rR1MTXAeYyh0EKLoiLm0f8EdMwJM3IjqYMIDgFNHOu8ymtnAs7?=
 =?us-ascii?Q?Tji2n1+phfWI5+ZnzlZi39fH+P5twTTJWIwxboxfGncLXjBmVSnYUQar0+Nh?=
 =?us-ascii?Q?Bfvbo0yhfgqr4U2y1dLcVzSyDe5yBX3zS82CE25lAT/K0o8m+a+uddn1bPtj?=
 =?us-ascii?Q?ZrsYCSrQmEmAr7a5iBZRqL9C8ErkPIgs0EiCZuDH6sLvqdQ1UHx9DJyTBr9L?=
 =?us-ascii?Q?rvMJFaVTkovsGlsyCOhhvc6tjLXngWkF6n55Ac6B9mjRlRktw+Jd7j3xWi1g?=
 =?us-ascii?Q?nKPfWD5M2Kz9ySmM1cTkQ0Po0OfvLLE9D77qU1OkG+lKvKSyESSwd3lyv95B?=
 =?us-ascii?Q?bQlxNWGitjUO9Otyuev4HeoQWvrsWBD0rhMCeLKB+5W9RSAwAByA9bmEah7v?=
 =?us-ascii?Q?kMNGPiJuMnVs54qtnGHqJZt/Cy81TW61NUjlvWjD7le/UjS+H0cjCI8NOSy+?=
 =?us-ascii?Q?tmjzQ/Er6/v92rZYrw8JTYrmFAcSPaxUWp1KGMQX6Iw+m9kKvHqYfGKygme0?=
 =?us-ascii?Q?YPZ+x35IjS102a3pR4qn3Frm16AORwwHyDm88SIpPd19bCr+5+6pHCocJaOx?=
 =?us-ascii?Q?hEktgsTs3CjkIrzjgWTEcmLuLiOmD1ZqY0Ns5CuS5HzdYjaiA7M/xXsbHaBx?=
 =?us-ascii?Q?7KY9BujlqN5DokIKZTx+5fefyBObwLU8cY60q29TA/tCPTRKI6snX4erKePa?=
 =?us-ascii?Q?8AqilV93sKLJIyaqIT+TIe3Yx4Zy9hXtbaRMBu17Z0aeUBNHLyI0ZKq+ez59?=
 =?us-ascii?Q?o0oh8NccNGi3yNt6doJLcf1P+P0DsojMp12Rs+miJR/gfvXj/a7JWCg52j4b?=
 =?us-ascii?Q?gke3ZqXgVOYCnGtB6doUgA/rfdkAUHcQ5xFSeHc79WIUO3s8AZxy+o/HtsWs?=
 =?us-ascii?Q?BDK9pep5wPvrdiiR8hxvxLIA8g4F/+Q1iN7P8ahCLQxrPw3p/TIo8cNZSyuT?=
 =?us-ascii?Q?UxyPNfXP/WA1A4ML4ZSi6znZ2eB/h9ZXfF5EHv5s1P3dcuuoPDjmpGor1SHF?=
 =?us-ascii?Q?6Jk8nZ0mEHZvBm480VdVeW5Tzs0cLn5qDWFGLwSUrB6L8X8FlJ5bU+Y2sWiG?=
 =?us-ascii?Q?IZJ2vpKIsdOvkzC2E6+jfexB?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fafb23ee-9190-4c51-a6aa-08d90f3996d9
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 May 2021 20:17:06.6545 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 3xLE4X2XPxEkyZFbm8ZSOTI/2/PFs0Z6bQJwTeADNYfIuRE6sCL5cOLEva91ve1x
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3664
Subject: Re: [lustre-devel] Reading extended attributes from a Lustre
 filesystem image.
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7899607252687744805=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7899607252687744805==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_FEA12F9CFE26481F8DB22EE448BC1160ddncom_"

--_000_FEA12F9CFE26481F8DB22EE448BC1160ddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On May 1, 2021, at 16:25, Saisha Kamat via lustre-devel <lustre-devel@lists=
.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

I am a Ph.D student at UNCC and our team is working on the Lustre filesyste=
m. I am reading extended attributes of the ldiskfs for every inode. I have =
used this source https://wiki.lustre.org/PFL2_High_Level_Design to interpre=
t the layout in which the extended attributes are stored.

For the Lustre image we are using, there are 605 inodes out of which 253 ha=
ve extended attributes. The count of lma is also 253, which is correct. How=
ever the only 22 inodes seem to have linkEA attributes and 2 inodes have lo=
vEA attributes. The count for linkEA and lovEA is seems to be really small =
compared to the count for lma.
I am wondering if there is an updated document on the layout of extended at=
tributes for the ldiskfs inodes.

link EA and lov EA are only added to "real" files visible in the filesystem=
 namespace (under "ROOT/" in the MDT), while lma may also be added to inter=
nal files in order to be able to recover them if the directory structure ge=
ts corrupted.  The link EA is on both files and directories, while lov EA i=
s typically only on regular files (though it can appear on directories as a=
 "template" for how to create files within that directory).  In this case, =
it just sounds like your MDT is mostly empty, and only has a handful of fil=
es in it.  It may also be possible that the regular files are created with =
"mknod(S_IFREG)" or "open(O_CREAT|O_LOV_DELAY_CREATE)" which will not trigg=
er the creation of a layout (lov EA) on the file.

You could probably just format a new test filesystem ("cd lustre/tests; sh =
llmount.sh" will use temporary files in /tmp for testing purposes, or as de=
scribed in lustre/tests/cfg/local.sh or other config file as referenced by =
"$NAME" in the environment), then run your scan on the "empty" MDT image, a=
nd then create a few files in the client mountpoint to see how this is work=
ing.

Note that instead of interpreting the on-disk layout format yourself (which=
 grows increasingly complex with newer features like PFL, FLR, DoM, etc.) y=
ou could use llapi_layout_get_by_xattr(), which can take an xattr read from=
 disk and convert it to a common in-memory format that the llapi_layout_*()=
 functions can process.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_FEA12F9CFE26481F8DB22EE448BC1160ddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <DCCF91F2BAE7114E8397BE3EDCE2BA37@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On May 1, 2021, at 16:25, Saisha Kamat via lustre-devel &lt;<a href=3D"mail=
to:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lustre.org<=
/a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D""><span id=3D"gmail-docs-internal-guid-f49b40a4-7=
fff-1bb1-77c1-e72fb3e8dcc7" class=3D"">
<div style=3D"line-height: 1.656; margin-top: 0pt; margin-bottom: 0pt;" cla=
ss=3D""><br class=3D"">
</div>
<div style=3D"line-height: 1.656; margin-top: 0pt; margin-bottom: 0pt;" cla=
ss=3D""><span style=3D"font-size: 11pt; font-family: Arial; background-colo=
r: transparent; font-variant-numeric: normal; font-variant-east-asian: norm=
al; vertical-align: baseline; white-space: pre-wrap;" class=3D"">I
 am a Ph.D student at UNCC and our team is working on the Lustre filesystem=
. I am reading extended attributes of the ldiskfs for every inode. I have u=
sed this source
</span><a href=3D"https://wiki.lustre.org/PFL2_High_Level_Design" style=3D"=
text-decoration-line:none" class=3D""><span style=3D"font-size:11pt;font-fa=
mily:Arial;background-color:transparent;font-variant-numeric:normal;font-va=
riant-east-asian:normal;text-decoration-line:underline;vertical-align:basel=
ine;white-space:pre-wrap" class=3D"">https://wiki.lustre.org/PFL2_High_Leve=
l_Design</span></a><span style=3D"font-size: 11pt; font-family: Arial; back=
ground-color: transparent; font-variant-numeric: normal; font-variant-east-=
asian: normal; vertical-align: baseline; white-space: pre-wrap;" class=3D""=
>
 to interpret the layout in which the extended attributes are stored.&nbsp;=
</span></div>
<div style=3D"line-height: 1.656; margin-top: 0pt; margin-bottom: 0pt;" cla=
ss=3D""><span style=3D"font-size: 11pt; font-family: Arial; background-colo=
r: transparent; font-variant-numeric: normal; font-variant-east-asian: norm=
al; vertical-align: baseline; white-space: pre-wrap;" class=3D""><br class=
=3D"">
</span></div>
<div style=3D"line-height: 1.656; margin-top: 0pt; margin-bottom: 0pt;" cla=
ss=3D""><span style=3D"font-size: 11pt; font-family: Arial; background-colo=
r: transparent; font-variant-numeric: normal; font-variant-east-asian: norm=
al; vertical-align: baseline; white-space: pre-wrap;" class=3D"">For
 the Lustre image we are using, there are 605 inodes out of which 253 have =
extended attributes. The count of lma is also 253, which is correct. Howeve=
r the only 22 inodes seem to have linkEA attributes and 2 inodes have lovEA=
 attributes. The count for linkEA
 and lovEA is seems to be really small compared to the count for lma.</span=
></div>
<div style=3D"line-height: 1.656; margin-top: 0pt; margin-bottom: 0pt;" cla=
ss=3D""><span style=3D"font-size: 11pt; font-family: Arial; background-colo=
r: transparent; font-variant-numeric: normal; font-variant-east-asian: norm=
al; vertical-align: baseline; white-space: pre-wrap;" class=3D"">I
 am wondering if there is an updated document on the layout of extended att=
ributes for the ldiskfs inodes.</span></div>
</span></div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>link EA and lov EA are only added to &quot;real&quot; files visible in=
 the filesystem namespace (under &quot;ROOT/&quot; in the MDT), while lma m=
ay also be added to internal files in order to be able to recover them if t=
he directory structure gets corrupted. &nbsp;The link EA
 is on both files and directories, while lov EA is typically only on regula=
r files (though it can appear on directories as a &quot;template&quot; for =
how to create files within that directory). &nbsp;In this case, it just sou=
nds like your MDT is mostly empty, and only has
 a handful of files in it. &nbsp;It may also be possible that the regular f=
iles are created with &quot;mknod(S_IFREG)&quot; or &quot;open(O_CREAT|O_LO=
V_DELAY_CREATE)&quot; which will not trigger the creation of a layout (lov =
EA) on the file.</div>
<div><br class=3D"">
</div>
<div>You could probably just format a new test filesystem (&quot;cd lustre/=
tests; sh llmount.sh&quot; will use temporary files in /tmp for testing pur=
poses, or as described in lustre/tests/cfg/local.sh or other config file as=
 referenced by &quot;$NAME&quot; in the environment),
 then run your scan on the &quot;empty&quot; MDT image, and then create a f=
ew files in the client mountpoint to see how this is working.</div>
<div><br class=3D"">
</div>
<div>Note that instead of interpreting the on-disk layout format yourself (=
which grows increasingly complex with newer features like PFL, FLR, DoM, et=
c.) you could use llapi_layout_get_by_xattr(), which can take an xattr read=
 from disk and convert it to a common
 in-memory format that the llapi_layout_*() functions can process.</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Principal Lustre Architect</div>
<div>Whamcloud</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
</div>
</div>
</div>
</div>
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</body>
</html>

--_000_FEA12F9CFE26481F8DB22EE448BC1160ddncom_--

--===============7899607252687744805==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7899607252687744805==--
