Return-Path: <SRS0=CrBs=GM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57CADC433E0
	for <lustre-devel@archiver.kernel.org>; Sat,  9 Jan 2021 15:56:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F1F0C238A1
	for <lustre-devel@archiver.kernel.org>; Sat,  9 Jan 2021 15:56:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1F0C238A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 55AF721CB1A;
	Sat,  9 Jan 2021 07:56:40 -0800 (PST)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12on2074.outbound.protection.outlook.com [40.107.244.74])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1E39721CA99
 for <lustre-devel@lists.lustre.org>; Sat,  9 Jan 2021 07:56:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=HzhIpA1yHsPCCfT9gFghXVowgsbpgZ1z7PgX/k/JphSadzWj5yBGSmXaNV7SdwvheTHbmlzOLLkGvHz78RoumpzHPOFy20/FPXk4tw4F/kIkl1nUnXpI7w+gtigEIGdt3WdBnuo2be3RRjVCzazF8VzQk9KrO6J5m87RG7qyWZ39SnkS7S1iCrUK8c/8holsHVZHfNwJ1VV5P+47P1TibPts+jxQMaect37RwatoqVLQ0nzefX0ExdWctmdiVudWkEdHFId40Qo19FDj1TI2fF3QvyK/EMmJGZqG6rJdMPXbDI2FvYJo4TbIbrM7gLwnWYHwZR0Iu3QyLrJjG6r7CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HYfizj9vnJXl69e+TkWI96Ub2QYNoUsyF8XTYq7wzi4=;
 b=ebUAUngpiDzLbqbPFTnsw8hjc8mzEDCNLanpoUe3tU2Q/QJCu3gGC7blpYPoclEue84A2DaOZF4M+PRDpM2iP/Cm1bC4gbmwY3zm8iI07AZASHBDAsm59DC9Bu9tRBFUmpmsL/io0YVMobCoScWIEWnvYEjCQhhF3x0tHTN16AFaCHEbp8pB0og4JGbzy52lRCDeUZ6eTglPXi0oO1nhffl09gioda9kmEzYurm247P6yegXQJkMeDjzsvMHH3UO/x/0NTU7wxg5H91PmCi3CgmQQTO2QjtDrbukkAXqSBOWxNYG+eH0CrsBktcYryMoaceKGAFJHWSR4gqTkfE9GA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HYfizj9vnJXl69e+TkWI96Ub2QYNoUsyF8XTYq7wzi4=;
 b=z1bSFGJ/Qm4jN/gzna684Xqtht1f/92Lc8do/hUp5g7rnUY7r949fkhPcAQ8cRS6+jWJ1vYWVciXcFJ4AF2SAKV8dK/JnGfb6jPvqyD44vBqaOwdKXjFWXQFHbpYMxg+sDFPZ6c14qiJWGQdjPJHG/YhiPvwGCZrVgUXEYRQJW8=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by MN2PR19MB3646.namprd19.prod.outlook.com (2603:10b6:208:190::14)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3742.6; Sat, 9 Jan
 2021 15:56:36 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3742.012; Sat, 9 Jan 2021
 15:56:36 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Nathan Rutman <nrutman@gmail.com>
Thread-Topic: [lustre-devel] modern precreate
Thread-Index: AQHW5fa4Ly79pQlMTkybsUr4WcJ206ofdBWA
Date: Sat, 9 Jan 2021 15:56:35 +0000
Message-ID: <1576C588-0DD1-4955-BE45-D8E6763076D7@whamcloud.com>
References: <CAA4iDz6+c4Qthf+aEYZf+7gugX_1mqoSucaB1RTrE2DkU6P1VQ@mail.gmail.com>
In-Reply-To: <CAA4iDz6+c4Qthf+aEYZf+7gugX_1mqoSucaB1RTrE2DkU6P1VQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: gmail.com; dkim=none (message not signed)
 header.d=none;gmail.com; dmarc=none action=none header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4ec14a4c-22c5-444f-86ee-08d8b4b724ae
x-ms-traffictypediagnostic: MN2PR19MB3646:
x-microsoft-antispam-prvs: <MN2PR19MB3646FF35E48181EAE06DE602A7AD0@MN2PR19MB3646.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: aFd2rbE0ZaqoM5JcNlsL9rZRNG6KkjMsP7M0bzdOP6dY2FuUJ4CX1qpc1AqGZViG/XKFKOWYzDKC4lsObCv6wsqdDGpI0WGLP0Kv+1W7/qmWR4FG/s4gb6YXdq4MsLbKG3oYYc18HKBa+zRa8CholKpxqi1tIxwzJDQOYNcqwEtIRJkICGGLzt8OGFZKnwze4UytLkDR6zKE6eofFEYlo7mU0bH3yCEPr72h29UzuOh9mv9/We1G9jZvQXTxAaxIqgvVKS9GUMaBXC+jxlQK8yhPCONAMfFWtiruSOXPvezrChh5yi4XWOlXk2xDto9yS4Jb1Ek4NrhtiNvG+k+ZIzVYVL6paADdoMXSWxrYoCqVWwFB+vZopGHmyYhhch0A0MWDdyXWvqPVYYei2BuqMQglldnB+MCVDaVdqSpXz6iSMX7d5/C4TLc3T1UsV4tz1cRTRShUcRRwsukpcfEtS7KFVaUmJRjMtWyMPMgi/QAa3EPJq0CuOnfCWDCM3aOa5HCt/iWT2n26gVPfTY00q31X9/yQcRDNMuSw2FIWRzE=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(346002)(366004)(396003)(39850400004)(136003)(376002)(2616005)(966005)(53546011)(6512007)(83380400001)(71200400001)(6506007)(36756003)(478600001)(8676002)(5660300002)(2906002)(91956017)(4326008)(33656002)(166002)(316002)(6486002)(26005)(6916009)(8936002)(66446008)(186003)(86362001)(66946007)(66556008)(76116006)(66476007)(64756008)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?cfQYH25s4FpuqjclcstrBxbPhtJulnpFPd2/cSW14cSqvMOtErFDdSgADqd2?=
 =?us-ascii?Q?OJo7IqJYTt/tQecdyawP/yu2mcJP9GxniDNweqXSv3TGfoenZJYfBsmOLinN?=
 =?us-ascii?Q?aYAgSXgSohSytLHuS9FRb9qqU8wuZHbvjqbiNXsafGGlbB3jJKaE1ksNaQ+7?=
 =?us-ascii?Q?IBe7yrIqkWvq62DeREXtHBSLRlzN/qIEZISt/s4foy6dh1LDrUWbAbzypIy3?=
 =?us-ascii?Q?ChjJvybfRr0s6bLW7IXrZQi7sQxlSFAmlamI0oRAsWYfM+eOZjDBsjnOmP9l?=
 =?us-ascii?Q?Co/fOcX9UWgS5VWAXpjK4hAHO/NtaRDCv5Vj2H95bXCoxvVV9HIUJHEvUbrx?=
 =?us-ascii?Q?VztDdtbXIzvN6TQn3S0iZ6QtwoAuNNCfXYjgceAqdlfTUbiPv+zWJdLpnmuD?=
 =?us-ascii?Q?ueMHyKj9EWz4zvhCaxaNXQeUOswIJ7MXNSvCPMoOS4/8LNMgN82buWpwFWPT?=
 =?us-ascii?Q?KdoKjTlSq9Gi5kH1RKgoAUiCi7+xt0Qi060HLAmFaSlgAQwuAu6ooPtJ3+fT?=
 =?us-ascii?Q?tTCCP5VOTWAp1nLj7vnQ53UZ450+GbrtlF3y6R/tH4YOrijMXwvNQlnSPGUj?=
 =?us-ascii?Q?KWQ976f9jZa1xIDds7rVH1wfVLYyu1J9MbEke9QMPBY3el4XLUkpytch0m5k?=
 =?us-ascii?Q?Xl+iraYHhLfFMUHiqdKi+xjrS3vKMAahwWakdkappZ+Ixv9oekv/NfSuNpbf?=
 =?us-ascii?Q?um97Bn/GMQb+NWnrFjaoWvdbtrBVbrB3z3EFrhArsbP98v1KJT+wNHVkDquU?=
 =?us-ascii?Q?tiMXLbkocMfFEMlbLsWpwoWwXiMSNTMEJUW0P1Tjv7MeFW4nyzY3EJ4NhMxh?=
 =?us-ascii?Q?M5hu8+ABFYqOFFR4XlR/TjCpXkJNl0zqCI0wNXI+HXQSnUaaVuwlnMOcI+zO?=
 =?us-ascii?Q?mAU945m4zd7/+E3zhcCf7jN35/zzkr2jChQ2bflk7crjyls6V4JpbhAUCP6b?=
 =?us-ascii?Q?bK+I1CXaTpHTtsLt/BC0FbjX6doTbT4769adEax/DlUZNxa5shHAapPcsY32?=
 =?us-ascii?Q?xnTU?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4ec14a4c-22c5-444f-86ee-08d8b4b724ae
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Jan 2021 15:56:35.9378 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 2HBEYSigZhOXJahcKENJI7JdHnGsJ9zpRPeekIbpByn35F1uGDC12HlHd1YXQexL
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3646
Subject: Re: [lustre-devel] modern precreate
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============0727963134895143173=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0727963134895143173==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_1576C5880DD14955BE45D8E6763076D7whamcloudcom_"

--_000_1576C5880DD14955BE45D8E6763076D7whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jan 8, 2021, at 12:44, Nathan Rutman <nrutman@gmail.com<mailto:nrutman@g=
mail.com>> wrote:


Riffing on something Andreas said in a lustre-discuss thread, I'm hoping so=
meone can correct my understanding of how precreate works currently.

Olden days:

MDS would ask each OST for a set of precreated objects via a MDT->OST RPC. =
These have to be cleaned up during recovery, hence a cap. These were used u=
p as MDS assigned them to layouts, and so MDS has to go back and get more, =
even for 0-length files.

Modern days, Lustre 2.5+:

MDT doesn't hold a pool of OST objects but instead takes an OST fid range f=
rom a FLD server instead. Each MD object has a mapping with an eventual OST=
 object by this fid. The OST side just holds a small number of anonymous ob=
jects and assigns the fid to an object when any operation is executed witho=
ut an existing FID->inode mapping on the OST.There is no more precreate RPC=
 necessary, since OSTs maintain their own pool of anonymous objects and onl=
y use them up when data is actually written, and can create more when runni=
ng low. There is no recovery cleanup needed on the OSTs.
In this case, there should be no performance difference between create and =
mknod except for the FLD operation, and the number of OSTs should not matte=
r for create rates.

Is my understanding wrong? It clearly must be, since Andreas is still talki=
ng OST_CREATE rpc and recovery implications, and we do see a performance di=
fference with mknod and creating files with layouts.

The precreate code still works the same as "the land before the time of FID=
s".  Actual objects are still precreated/destroyed on the OSTs. The only di=
fference is that the FID sequences allocated to MDTs allow the OSTs to have=
 different pools of objects for each MDT so that they don't contend/conflic=
t when those MDTs assign the objects to their own inodes.

Having multiple MDTs does "scale" the OST object space, in that there can b=
e more object subdirectories (one per sequence), which improves both the co=
ncurrency and the maximum number of objects.  There has also been work done=
 to increase the maximum number of files per directory in ldiskfs, but that=
 doesn't really improve performance.

The patch https://review.whamcloud.com/38424 "LU-11912<https://jira.whamclo=
ud.com/browse/LU-11912> ofd: reduce LUSTRE_DATA_SEQ_MAX_WIDTH" would create=
 smaller object directory trees, and allow "aging" of old objects to be in =
separate object directory trees from new objects.  That allows old objects =
to drop out of cache (avoiding one-create-per-leaf as the size of the direc=
tory grows very lareg), and keeps fewer "hot" objects densely packed in mem=
ory (allowing many new entries to be packed into a single leaf block).

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_1576C5880DD14955BE45D8E6763076D7whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <207F7E2357D49844B8A66018AE413ED4@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jan 8, 2021, at 12:44, Nathan Rutman &lt;<a href=3D"mailto:nrutman@gmail=
.com" class=3D"">nrutman@gmail.com</a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div dir=3D"ltr" class=3D"">
<pre style=3D"white-space: pre-wrap;" class=3D""><h1 style=3D"white-space:n=
ormal" class=3D""><span style=3D"font-weight:normal" class=3D""><font size=
=3D"2" style=3D"" class=3D""></font></span></h1></pre>
<pre style=3D"white-space:pre-wrap" class=3D""><font style=3D"background-co=
lor:rgb(255,255,255)" face=3D"arial, sans-serif" class=3D"">Riffing on some=
thing Andreas said in a lustre-discuss thread, I'm hoping someone can corre=
ct my understanding of how precreate works currently.</font></pre>
<pre style=3D"white-space:pre-wrap" class=3D""><font style=3D"background-co=
lor:rgb(255,255,255)" face=3D"arial, sans-serif" class=3D"">Olden days: </f=
ont></pre>
<pre style=3D"white-space:pre-wrap" class=3D""><font style=3D"background-co=
lor:rgb(255,255,255)" face=3D"arial, sans-serif" class=3D"">MDS would ask e=
ach OST for a set of precreated objects via a MDT-&gt;OST RPC. These have t=
o be cleaned up during recovery, hence a cap. These were used up as MDS ass=
igned them to layouts, and so MDS has to go back and get more, even for 0-l=
ength files.</font></pre>
<pre style=3D"white-space:pre-wrap" class=3D""><font style=3D"background-co=
lor:rgb(255,255,255)" face=3D"arial, sans-serif" class=3D"">Modern days, Lu=
stre 2.5+:</font></pre>
<pre style=3D"white-space:pre-wrap" class=3D""><span style=3D"box-sizing:in=
herit;font-variant-ligatures:common-ligatures;white-space:normal;background=
-color:rgb(255,255,255)" class=3D""><font style=3D"" face=3D"arial, sans-se=
rif" class=3D"">MDT doesn't hold a pool of OST objects but instead takes an=
 OST fid range from a FLD server instead. Each MD object has a mapping with=
 an eventual OST object by this fid. The OST side just holds a small number=
 of anonymous objects and assigns the fid to an object when any operation i=
s executed without an existing FID-&gt;inode mapping on the OST.</font></sp=
an><span class=3D"gmail-c-mrkdwn__br" style=3D"box-sizing:inherit;display:b=
lock;height:8px;font-variant-ligatures:common-ligatures;white-space:normal"=
></span><font style=3D"background-color:rgb(255,255,255)" face=3D"arial, sa=
ns-serif" class=3D""><span style=3D"box-sizing:inherit;font-variant-ligatur=
es:common-ligatures;white-space:normal" class=3D"">There is no more precrea=
te RPC necessary, since OSTs maintain their own pool of anonymous objects a=
nd only use them up when data is actually written, and can create more when=
 running low. There is no recovery cleanup needed on the OSTs.&nbsp;</span>=
<br style=3D"box-sizing:inherit;font-variant-ligatures:common-ligatures;whi=
te-space:normal" class=3D""><span style=3D"box-sizing:inherit;font-variant-=
ligatures:common-ligatures;white-space:normal" class=3D"">In this case, the=
re should be no performance difference between create and mknod except for =
the FLD operation, and the number of OSTs should not matter for create rate=
s.</span></font></pre>
<pre style=3D"" class=3D""><font face=3D"arial, sans-serif" class=3D""><spa=
n style=3D"font-variant-ligatures:common-ligatures;white-space:normal" clas=
s=3D"">Is my understanding wrong? It clearly must be, since Andreas is stil=
l talking OST_CREATE rpc and recovery implications, and we do see a perform=
ance difference with mknod and creating files with layouts.<br class=3D""><=
/span></font></pre>
</div>
</div>
</blockquote>
</div>
<div>The precreate code still works the same as &quot;the land before the t=
ime of FIDs&quot;. &nbsp;Actual objects are still precreated/destroyed on t=
he OSTs. The only difference is that the FID sequences allocated to MDTs al=
low the OSTs to have different pools of objects
 for each MDT so that they don't contend/conflict when those MDTs assign th=
e objects to their own inodes.</div>
<div><br class=3D"">
</div>
<div>Having multiple MDTs does &quot;scale&quot; the OST object space, in t=
hat there can be more object subdirectories (one per sequence), which impro=
ves both the concurrency and the maximum number of objects. &nbsp;There has=
 also been work done to increase the maximum number
 of files per directory in ldiskfs, but that doesn't really improve perform=
ance.</div>
<div><br class=3D"">
</div>
<div>The patch <a href=3D"https://review.whamcloud.com/38424" class=3D"">ht=
tps://review.whamcloud.com/38424</a>&nbsp;&quot;<a href=3D"https://jira.wha=
mcloud.com/browse/LU-11912" class=3D"">LU-11912</a><span class=3D""><span c=
lass=3D"">&nbsp;ofd: reduce LUSTRE_DATA_SEQ_MAX_WIDTH</span></span><span cl=
ass=3D"">&quot;
 would create smaller object directory trees, and allow &quot;aging&quot; o=
f old objects to be in separate object directory trees from new objects. &n=
bsp;That allows old objects to drop out of cache (avoiding one-create-per-l=
eaf as the size of the directory grows very lareg),
 and keeps fewer &quot;hot&quot; objects densely packed in memory (allowing=
 many new entries to be packed into a single leaf block).</span></div>
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

--_000_1576C5880DD14955BE45D8E6763076D7whamcloudcom_--

--===============0727963134895143173==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0727963134895143173==--
