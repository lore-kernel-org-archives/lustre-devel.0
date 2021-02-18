Return-Path: <SRS0=BZfS=HU=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C7CBC433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 18 Feb 2021 11:09:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1A1EB64E4B
	for <lustre-devel@archiver.kernel.org>; Thu, 18 Feb 2021 11:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A1EB64E4B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 76D0F21F3C9;
	Thu, 18 Feb 2021 03:09:42 -0800 (PST)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12on2084.outbound.protection.outlook.com [40.107.237.84])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 720F421F349
 for <lustre-devel@lists.lustre.org>; Thu, 18 Feb 2021 03:09:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ACc2Wm9ATogME/W3Kn+xrQmI7vM6ELgun8LZnReGxOJpEF3id0/eZ1jBwxqk47gliZXSDK/a1qIVeNnsLOZnss2X3AhAsgQv3Mx+xJsH87Q9s/0ooqPeRxHK1I/q5/xhd95KBFW5L7PSWq5Kwy/bHJ5E+6bTSAMyRT90L8684Axm3q75b3wZj5nMmvSyplsurxvDyNZLQA6WecATYOwf57GKa606FZmt5OMwg+T94cCDzt5Q7jlvb7m78sBVAuTXBJaKlSh0RiiNrFPt/EeDAdy8QbCcz2B/zsYjBj7B3Kq50ka9AxH1SSS+hk0N2mw7KNSIWC92eUt1N2q86qau8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cEHTLCB/mSgZUH5GjYA0gBVSTlK0py33vZmddN6J3Ho=;
 b=Jd88SMDHdEIO2Vgo2HPN8ED9gPyfROXxrxcBRMO3PXhKEMGJU68FggoVf29Ud5P3ZhWsiRQStaVrLPsca1BqCYZd5m/hZTX/PlXp8nJ7tFr5oA3EOPaD6kWQiIzkLchk1q9nE9h2VWA/WJkPzIBhU90CcGz6wcfzvsgKp3mO/wqrwQ9ZwS522nB9Kt8yLnyuRTMJl5xtH71UW3XNAoA6wbwVnrv6acSR/JNCLSwnw8iXFh8uwc0B+F33d7vNr8ZphFTtRjx8ZGAzEWFjWkWzMMQBnkltbT5DPjajWcI/YARwX4CoK0Offum6fMR7Sthyhqo95XLEDEzdZKSkPpO8GQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cEHTLCB/mSgZUH5GjYA0gBVSTlK0py33vZmddN6J3Ho=;
 b=jDa3P4NvTnSBIOdzzvtbjrDylhIeFx8P+4DxoQBnRZ6Dg9XdU0BR8/fX0EtpoS47dw/LYimFoyPTHrEn516Z3H30aBsJIDPmqE3ebEM8HWHHS4nU4FPZN2nhZHBzuyV6qjvAehD2ArbXpBOAokfMCOQgmPZQWJlJVbAIa7tpYy4=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by MN2PR19MB3661.namprd19.prod.outlook.com (2603:10b6:208:18b::32)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3846.34; Thu, 18 Feb
 2021 11:09:37 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3846.039; Thu, 18 Feb 2021
 11:09:37 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Christian Kuntz <c.kuntz@opendrives.com>
Thread-Topic: [lustre-devel] Testing 2.14 on Debian + ZFS
Thread-Index: AQHXAZPtWGyYVai4S0uFM1+nKhlprapdye6A
Date: Thu, 18 Feb 2021 11:09:37 +0000
Message-ID: <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>
References: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
In-Reply-To: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: opendrives.com; dkim=none (message not signed)
 header.d=none;opendrives.com; dmarc=none action=none
 header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3b520b0b-5435-4e57-c9c9-08d8d3fdae53
x-ms-traffictypediagnostic: MN2PR19MB3661:
x-microsoft-antispam-prvs: <MN2PR19MB3661DD8BFDB8615A6F8528EAA7859@MN2PR19MB3661.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: UFsgedY2MCFLTI1rTXOA+0FxSkp5518ACLlBsQPqfr3bDLC5BSX5TZtm0WtkW4TBuuQcSS5rl+GGvNGYN8dy0ALahLRUOvlCOmUP3Xm3bdj08mpiPqhL0+wvbgrIiLw4UX47SdBgkNzbfWBzVP2FPeNGZwIMio4euAcTyneZCzmBW/YSANE2IUDjKMB/ilRsB5mcfNqCV/h62Yr2xlNhmUG6PxDtMcIGLpipPCFnZqHqsHJnow0kVE03HvqmOir+zwXH0dSwdLU8Ao9LPN1im4StfYW+/SyqdxaK5WHzcyRyLpEjpI/A2wzFSQiL7UA0QM5iQ/vp61E6ntXHOlgEdhvxAsooCYEqg/oiF4czPj+H41r2LJ+TtMAoBCIdyksZ98GX/e2YS4w0Zcn1dxukDsRbRa44Gp6RK1RNMi8HVmbQID9wjheMWzYY4dnBpLE8YytsL+wwL+FHzQSTjC9+TBBxJMLB7Xwdqrw3n4vjlzqmb6Agk7KYBxe9fPXuG+aweIWAvOFIQ0m+sfeZ2W8vXA6Asc8ZCH6vW/IPEw4QRUcigEjOIooJYv1zrUjISJ18TQLZ2xhhMSl8aYSTlD/RhOodnm2twz4M/fJo5T1si6U=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(376002)(346002)(366004)(39850400004)(136003)(396003)(91956017)(66446008)(71200400001)(6512007)(2906002)(54906003)(86362001)(6486002)(4326008)(316002)(66946007)(186003)(8676002)(36756003)(478600001)(76116006)(83380400001)(8936002)(66556008)(2616005)(6506007)(33656002)(6916009)(64756008)(66476007)(26005)(53546011)(5660300002)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?4H+NaM4cSs9zh2WcqBbW2jPsJkS37ICh5uT/oPKL6+ZXas4f3ftAiZc5Chqb?=
 =?us-ascii?Q?d5qgHkpatfKAt9aZiBTMUPUlNem/rRI9R13/+fybYRd5pdbBKts+63eWQfOX?=
 =?us-ascii?Q?fbO5ZJXT2AltJWNMoC/sP9Z4BN/EDGy9LVItCCnQFszmd4/R1+UkqAzFHIva?=
 =?us-ascii?Q?h8+TtczUG6nVtM4mt6fhNFmGDRrLTfoF4j8rNyWuPCFVHdqfsqCjTR6OAO9x?=
 =?us-ascii?Q?aTRjZjwLJtF0TxCSmqdwkw5rf8VOjsiEnLIw9Wm6wu3Jp+TzMg0ZF3ffuZta?=
 =?us-ascii?Q?Wxy9I5AAJf8OeMAczyeurx9OEi2MBcc++39wDyE65p6NR/wC0g6kc0EuV1Xk?=
 =?us-ascii?Q?xgfAoup03Y/G2an+/sh7eAzYJ50rzNsnk0A6m4A1ujOyHKqmliziJjBG6ZfD?=
 =?us-ascii?Q?+LMYi14vCzwV4XM9RoD7he2ViodAY/Z4mo88YN3XpElgRMeOeH1mwuze94ov?=
 =?us-ascii?Q?yw+n+Ab0IuUUhKRqvhVGyM6RnxB9Jtu8rvMTIl+WVPrwPz3evMUSNhJNfyC7?=
 =?us-ascii?Q?1KtpanGxY+mj03t3jitpbH3I1v6mut8ocW27isWbZF9VNMJyfqo08PBfU+lq?=
 =?us-ascii?Q?OrrRi6GwaEMJugpP5oM+rrAZUT4o3RE1Ov4AYtGboFUVcmM4Q6mhtYCbKm9p?=
 =?us-ascii?Q?gRtqm6XbGiiIseBW2UCxgvn0tdyJNVpfYWmcOQXGZWUP4oUo1tkxq+mjLPUa?=
 =?us-ascii?Q?N1UVbqmQZ3y1KprBynTh6KG0y83rzUdGmd2P2+DmMR5Sl80t/Gs8FwnJAWjg?=
 =?us-ascii?Q?uHUDNDVFaxE7vbPaEQh9TfKxjS07P13EAxeRAsGxO0aE/psn8/8v+ENhMnqp?=
 =?us-ascii?Q?aLxjmY8tQzeVrLMi5LjEzxKWfB8YGYZbLl/sVy4HwRsYKT5jx1Qr9paepGYY?=
 =?us-ascii?Q?VsNRp41BhQ63cgNcXhejCLAHDybdAheAhVWCObIVSEDjuuqgkV6u6jwVsvk1?=
 =?us-ascii?Q?gssAMpft7qep9d46rgJ3rBGqz9RnF1nrMjBut8jXd0OHyr2iczsJ9dbWkTAy?=
 =?us-ascii?Q?YlM4GzVsesXomL5wY/bCeczvXXXyusZVHNy4TqC3YUVON/sHgzKnu3H34RlF?=
 =?us-ascii?Q?vgAXihnvCFvTwzvoKugwza90MXRlDivXljpydHKUtZhFY9XGQQ24rXo3GkQn?=
 =?us-ascii?Q?eGOUBF1uhn3WEGP60c6HxSBMciyc6Ii+as+KpnWTUBVl9gsqyn4hinBpcfBz?=
 =?us-ascii?Q?iOMVEo5vY626+k15qvLvVyfh12WN7YeMsn/CmKpYpfty8fOzDM08kxRfCl6x?=
 =?us-ascii?Q?S/ueo0Ii2I25ym2Xz+nDuKwEKZcBa2OEVHReoTtI42E9+iUqL28ysCcCkE/M?=
 =?us-ascii?Q?gDnc9LFanG5+ZfTXzV7zk0lZ?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3b520b0b-5435-4e57-c9c9-08d8d3fdae53
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Feb 2021 11:09:37.6449 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: xeu9HvJbj0E2zhseEGJU3qFecgqW93ziMUhphtpWrHyR1rONRoz90U2UwucehfIg
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3661
Subject: Re: [lustre-devel] Testing 2.14 on Debian + ZFS
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
Cc: Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============5111587496587109425=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5111587496587109425==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_477F0D07A7E1488A8E06FE6C2E748FE1whamcloudcom_"

--_000_477F0D07A7E1488A8E06FE6C2E748FE1whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Feb 12, 2021, at 16:07, Christian Kuntz <c.kuntz@opendrives.com<mailto:c=
.kuntz@opendrives.com>> wrote:

Hello,

I hope I'm communicating in the right place here, I'm currently working to =
compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If there'=
s anything I can do to help with the testing effort or help Lustre's Debian=
 support be more robust, please let me know! I hope I'm not too late in the=
 release cycle to contribute.

Thanks for the offer of testing.  Unfortunately we are very late in the 2.1=
4.0 release cycle (we are hoping to make the final release in the next week=
 or so, barring any critical defects).  However, even if any changes miss t=
he final 2.14.0 release, having patches available to fix any issues you run=
 into will make it easier for the next person to build on Debian.

Ideally, any required fixes for Debian building should go into the Lustre t=
ree directly rather than into a separate "downstream" package, so that "mak=
e debs" works out-of-the-box.  We do build Ubuntu 18.04 and 20.04 clients r=
egularly, and ZFS 2.0 servers on RHEL7/8, but I don't know if anyone is bui=
lding the server code on Debian/Ubuntu on a regular basis.

On the topic of compiling, I'm currently working to get debian packages mad=
e and running into a compilation issue that didn't seem to present on my pr=
evious endeavors with 2.13 and 0.7. I've got the kernel and zfs locally bui=
lt and their packages made, and lustre's configure step successfully comple=
tes, but when it comes to compiling it appears that the osd-zfs portion has=
 some broken include links:

In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,
                 from /lustre-debian/lustre/osd-zfs/osd_internal.h:51,
                 from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:=
 No such file or directory
 #include <sys/types.h>

For reference, my configure and make looks like:
./configure --with-linux=3D/linux-4.19.171-2/  \
             --with-linux-obj=3Dlinux-4.19.171-2/debian/build/build_amd64_n=
one_amd64 \
             --with-zfs=3D/zfs-linux-2.0.2 \
              --enable-server --enable-modules --disable-ldiskfs
make -j"$(nproc)" debs


From the error and some probing, it looks like zfs_context.h expects some h=
eader files to be in their libc standard `/usr/include/sys` (or somewhere a=
bouts), but lustre's make process is pulling them from the linux sources in=
 `SRC/include/linux/`. Predictably, I found this out the hard way by adding=
 `-I/usr/include` to the Makefile for the zfs osds and getting battered wit=
h errors and warnings about duplicate definitions.

It may be that you are looking at this from the wrong angle.  Rather than t=
rying to include more userspace headers, it might be worthwhile to see why =
<sys/arc.h> is being included by osd_internal.h and maybe there is a more a=
ppropriate header that could be used in the kernel?  Failing that, it isn't=
 clear wh zfs_context.h is including the <sys/type.h> header from userspace=
 when building with __KERNEL__ set?  Kernel code should be using <linux/typ=
es.h>.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_477F0D07A7E1488A8E06FE6C2E748FE1whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <4F5EED4853277747ADF8AAECF367A75E@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Feb 12, 2021, at 16:07, Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@op=
endrives.com" class=3D"">c.kuntz@opendrives.com</a>&gt; wrote:<br class=3D"=
">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hello,<br class=3D"">
<br class=3D"">
I hope I'm communicating in the right place here, I'm currently working to =
compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If there'=
s anything I can do to help with the testing effort or help Lustre's Debian=
 support be more robust, please
 let me know! I hope I'm not too late in the release cycle to contribute.&n=
bsp;<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Thanks for the offer of testing. &nbsp;Unfortunately we are very late in th=
e 2.14.0 release cycle (we are hoping to make the final release in the next=
 week or so, barring any critical defects). &nbsp;However, even if any chan=
ges miss the final 2.14.0 release, having
 patches available to fix any issues you run into will make it easier for t=
he next person to build on Debian.</div>
<div><br class=3D"">
</div>
<div>Ideally, any required fixes for Debian building should go into the Lus=
tre tree directly rather than into a separate &quot;downstream&quot; packag=
e, so that &quot;make debs&quot; works out-of-the-box. &nbsp;We do build Ub=
untu 18.04 and 20.04 clients regularly, and ZFS 2.0 servers
 on RHEL7/8, but I don't know if anyone is building the server code on Debi=
an/Ubuntu on a regular basis. &nbsp;</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D"">On the topic of compiling, I'm currently workin=
g to get debian packages made and running into a compilation issue that did=
n't seem to present on my previous endeavors with 2.13 and 0.7. I've got th=
e kernel and zfs locally built and their
 packages made, and lustre's configure step successfully completes, but whe=
n it comes to compiling it appears that the osd-zfs portion has some broken=
 include links:<br class=3D"">
<br class=3D"">
In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;from /lustre-=
debian/lustre/osd-zfs/osd_internal.h:51,<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;from /lustre-=
debian/lustre/osd-zfs/osd_handler.c:52:<br class=3D"">
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:=
 No such file or directory<br class=3D"">
&nbsp;#include &lt;sys/types.h&gt;<br class=3D"">
<br class=3D"">
For reference, my configure and make looks like:<br class=3D"">
./configure --with-linux=3D/linux-4.19.171-2/&nbsp; \<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;--with-linux-obj=3Dlinux-4.=
19.171-2/debian/build/build_amd64_none_amd64 \<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;--with-zfs=3D/zfs-linux-2.0=
.2 \<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; --enable-server --enable-m=
odules --disable-ldiskfs<br class=3D"">
make -j&quot;$(nproc)&quot; debs<br class=3D"">
<br class=3D"">
<br class=3D"">
From the error and some probing, it looks like zfs_context.h expects some h=
eader files to be in their libc standard `/usr/include/sys` (or somewhere a=
bouts), but lustre's make process is pulling them from the linux sources in=
 `SRC/include/linux/`. Predictably,
 I found this out the hard way by adding `-I/usr/include` to the Makefile f=
or the zfs osds and getting battered with errors and warnings about duplica=
te definitions.&nbsp;<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>It may be that you are looking at this from the wrong angle. &nbsp;Rat=
her than trying to include more userspace headers, it might be worthwhile t=
o see why &lt;sys/arc.h&gt; is being included by osd_internal.h and maybe t=
here is a more appropriate header that could
 be used in the kernel? &nbsp;Failing that, it isn't clear wh zfs_context.h=
 is including the &lt;sys/type.h&gt; header from userspace when building wi=
th __KERNEL__ set? &nbsp;Kernel code should be using &lt;linux/types.h&gt;.=
</div>
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

--_000_477F0D07A7E1488A8E06FE6C2E748FE1whamcloudcom_--

--===============5111587496587109425==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5111587496587109425==--
