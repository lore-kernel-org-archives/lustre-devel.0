Return-Path: <SRS0=oOak=PD=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAEC5C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 15 Oct 2021 06:18:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6C00661181
	for <lustre-devel@archiver.kernel.org>; Fri, 15 Oct 2021 06:18:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 6C00661181
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DC7FE21F345;
	Thu, 14 Oct 2021 23:18:53 -0700 (PDT)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12on2082.outbound.protection.outlook.com [40.107.244.82])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3D7B721F32D
 for <lustre-devel@lists.lustre.org>; Thu, 14 Oct 2021 23:18:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=TWx3Bq//ckQsip2utq6Vttp+/k34nWBJaX1QtrEV1gv1Pnf+gDP/MgXgsWLNvM5Q2aM2wBeW1Eeeuxji1h75dzwtdQsv8PUcYE2zjzmDDiD96VRqIZcc+E2bfTJVTJ1mGaWHGn5lJ/7h7OjYiQrROz4QJQIhxY80kw0hQZQfkk6z1rPtYBuD2uQbyeuD65Wn6pNNYDyC6HinQfgqc4TqEPulDhDurC3HU1Zn6w6UC1EcDTS0mbV/51n/cXTOwMqlWIt8CncH7O1yTyWEkVrQj7wAmivq5o7pNIJV9EMVBIqBbl05rUVQEVeigFnx2fs9gH1B/50FEHB7YxY9swEb+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=DggrmogI3tZkXKgtJfix1DrlmMrmVqYSNziIXFOPqtA=;
 b=KLT7TOyJ0VRcRLkl9+LGma9if4cAS3gl7EM6lkvvfMXCyEUtYUMNJoMHLEca3aeKQsQS6+Zbb+c+8ao8jiw/tP6tEVHL89lvYJtOceRqZVAiBpG4a1U06VZIGKh7x4AdKuo3BtWEY6GqG6WUrvpuY2ToUtzoHczFiDAvKNjCgRMYTbCXIr+GDVKpqXyo0Hv8NVB6+qabndZSelUBN54tJyXre5qf/d+xInEUd3IN4GQb9cY1dk+ugctatF8HB12zRPm7VcmEb7TJUDBZRizsbCLE+HoHhqNad4nWRq2aAuPoJ8s87X4a3kWjCU7uWEMEPnvpLNOdWDrcRVi1y1wHYA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DggrmogI3tZkXKgtJfix1DrlmMrmVqYSNziIXFOPqtA=;
 b=tltZV29vJ7lg/o+Pfsw8GmeG7y7SPBoFrGtGK+fu9cqYI4Um8Ct8rMYwqE11hNcXfyAXDi5mcXkMKMzIlkQXKLJ2SZ3vfhbBmStgYrrsPcSFpHFG+FfrTKPEI198dYDx25E0YbPc9T8ZhwAjpbsPgAmRcF01LMYwkldsi5b67jM=
Received: from CO1PR19MB5208.namprd19.prod.outlook.com (2603:10b6:303:f7::24)
 by CO1PR19MB5158.namprd19.prod.outlook.com (2603:10b6:303:db::20)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4608.16; Fri, 15 Oct
 2021 06:18:47 +0000
Received: from CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::44ca:6f5c:be9e:7863]) by CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::44ca:6f5c:be9e:7863%2]) with mapi id 15.20.4608.017; Fri, 15 Oct 2021
 06:18:47 +0000
To: Ellis Wilson <elliswilson@microsoft.com>
Thread-Topic: [lustre-devel] xattr stat mismatch in sanityn test 73
Thread-Index: Ade8QbQkpHtTbKGQS1SFXsTjFYA+vgFSs5gA
Date: Fri, 15 Oct 2021 06:18:47 +0000
Message-ID: <7947C4DF-8BEF-4AA9-8EFE-C3679EAFE252@ddn.com>
References: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
In-Reply-To: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: microsoft.com; dkim=none (message not signed)
 header.d=none;microsoft.com; dmarc=none action=none
 header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ad58e08f-06ba-47cb-1448-08d98fa3a5bb
x-ms-traffictypediagnostic: CO1PR19MB5158:
x-microsoft-antispam-prvs: <CO1PR19MB51585C3F38C87DE9AC6EDD93A7B99@CO1PR19MB5158.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: vv70kEPwfW0znbFvVOjOfLcWcX90gFR5CPfz57m8bOpirfGb1RVhflqEndK6W3WpEB6AXsUA3vPOK8SSIowr+jgIBKsFvY3aqNesXe8y4YTFmh5RXUtEgXqoAP4nP/kTUgQtQywYtxEQbj0tu1uv9PvyGqmqO0Y9Fo7DBS/DWRDCSIh0kXHl181OMFXh4l0JahKnCcBOvRUv0bL0ojeF4aN8/qs98YoNyHNDuIUMbsN8qAofyxSYDdcvUQiFn+gLMQXGUZs452DFTHfW5SAqCrhhAPLghbjmVlffTkr1L6lwhcn73JgpM9vQY+zegzPq670WHcwzv9l1Bq10eFWWfQLtnQ2zWwVabFF7gcZC1+/unj864KfmCnMsf0qqKrSmu1AZwNJMtV5MQKExwdaCWbhwZzUVNs5BCUcnOaa7PLpnCZAamUWC7gTSj6WFkmSUFDI5AR9VSRKAwr23i4qU8/c6ghGXi9YA9HnayYEkQYTayoqYVyK90jlj/nMU9i/v1wV/F/YkJCWf3J4iaOiyKmS0bCWrBzX7r6DSnXK3QBaS9HsOX7IKI5ptTz9o2+DESZhptHkLH3aG/62g5NMXy6EYvuciChd3siVADAa8uQRvjavaQZnk2fX9Ivinsmn7gCcqHpmQb+VseIaSRMO1yzgZhqWfmq2ZpoxJNC41gDZbnFz3jAdse7xZC3cIRub38HfYB8oi4m4Wtrm/iID/nMMMmgU8nsftpn8ZdwfwM7E=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:CO1PR19MB5208.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(6512007)(8936002)(9686003)(4326008)(38100700002)(122000001)(2906002)(86362001)(38070700005)(36756003)(66446008)(83380400001)(6486002)(508600001)(316002)(6916009)(26005)(6506007)(76116006)(53546011)(71200400001)(33656002)(8676002)(64756008)(66946007)(5660300002)(66476007)(66556008)(186003)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?B03Ci7/FsRJ0PCd1jzp7/DWfgk20e1KVinhQ86AVLeUwVbkNj/3vIs7S1Mxp?=
 =?us-ascii?Q?M2xJDxW37UtiUQBsNPtfVMh3tq/QPweYfxadYR7f1t/IeWRH626SOjgWv4Gl?=
 =?us-ascii?Q?GZntLzdM1LHqN1iRMJypnGGF+/iFTOjheSFuD4lBUXZ3BDtK4vCpWyoHKS/p?=
 =?us-ascii?Q?SXND8herEqTPpeX0e4YxKNMLTCngfAvx7yBJ8itS315aOeJ+ACxGcK9FbSrK?=
 =?us-ascii?Q?LenQn9Owjfh5MetEokzDW0uNBRZPtp19xDwCW9Pexi4KFyfcyOFe26bWepyu?=
 =?us-ascii?Q?ltkurMS2JcUhKuSVecrHR/0nC83wYy0tceGhaTqUhJqnQebQY36ROpp5LPh2?=
 =?us-ascii?Q?/DAn51XKkgpSQc1BwSwidR9JpIc424lEwifpKrUr7RvZ2Hc3n+qEniBoMhQO?=
 =?us-ascii?Q?M24TFgvaubDZ8CKvG1wbR2y3L6PcvIwa+cyCt9sUjkDPnEJmrNnSQ9/NK/Mu?=
 =?us-ascii?Q?5Mz8zcRf9iWCEMW/UgSOnWHDD3Ut6YhdI8sTpb7M3IHR6UkbgcEWaaOQxziR?=
 =?us-ascii?Q?Vh84JssJWlgnxHPJJGIuLf+fUsxYmU8L69psiaF/K2J0Q6iJLHrrn07KWQco?=
 =?us-ascii?Q?gd5Ckz/0NvZJX7Ko4mvYkaU4y0dFEmXzf2F5LVVCWxyfX6XmSuV0w4s4baec?=
 =?us-ascii?Q?/qxDRx01smZ+gG9Ng8gg+/zrTtnVF+MXPpyL90Uw8uYSDIY1GoCp5Pu7ym/c?=
 =?us-ascii?Q?dLfpWck3nQf88iRlYB7TeL4X/cboO6LQe3JS4AlhdRzzas4E4v8sPPDNVY68?=
 =?us-ascii?Q?+FzwiInXzWN/bceifqlaI6xl1eZzepNB80UH86ZVheX1pphPk3cJrDUKMTja?=
 =?us-ascii?Q?5ixXlCo2NhjXSeKt1GQiIbdZoGBZ5dzGrSkuSqXBhhDcRsUHxhpYPCC577YX?=
 =?us-ascii?Q?ORNcL84s147VwiLux5DWzuyNrXDpHMsk7B24RMsHFN3CsrszV6RVI94FD8h3?=
 =?us-ascii?Q?a7qYQCJzGjbaDXCMqk6ON2aYRy5qbg201T/i86bKMcsjsermHA0h87kQx8wg?=
 =?us-ascii?Q?/dyruh7T01ETXAJdrSgoGri+v0y9Xbb6tSauO3faKtV+NB7S7vYtZxWGcSny?=
 =?us-ascii?Q?KlOL1UgGcczT/MnaG0Bx1RRdWEvuc5CQQc7GG0MNIhegT9iD2HoKHs4VyGYq?=
 =?us-ascii?Q?X6Gf6z2oeXeDlpvm2qhcdXnw9fB06KhQEeqyZiH5L/0EJNbMO932UavsjAXN?=
 =?us-ascii?Q?sSAQMLc/1VhZmhEKB62h2Dw3K1ZCibYxixA+tHvUWyyVmibfNyUYmmY0t2NN?=
 =?us-ascii?Q?NFar3hSdlgkM15vswNSMTn8DhQHEluADR3P6G3m7aDMwmVsvbXKT/zCnaAnd?=
 =?us-ascii?Q?EWp/Rbsd38lAO0zonsKFjxqH?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: CO1PR19MB5208.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ad58e08f-06ba-47cb-1448-08d98fa3a5bb
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Oct 2021 06:18:47.0556 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: HrwyLSjFpl3ApQZOUQHKrfrmrDwBQETp+RT0N5cTK1/1eO+Hd39dpU2zqUTslCnX
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO1PR19MB5158
Subject: Re: [lustre-devel] xattr stat mismatch in sanityn test 73
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
Content-Type: multipart/mixed; boundary="===============0516423320011678690=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0516423320011678690==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_7947C4DF8BEF4AA98EFEC3679EAFE252ddncom_"

--_000_7947C4DF8BEF4AA98EFEC3679EAFE252ddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Ellis, the getfattr code has a poor "optimization", in that it first calls =
getxattr(buf=3DNULL, size=3D0) to have the kernel report the xattr size to =
allocate a buffer of exactly the right size.  However, IMHO while this avoi=
ds a "too large" allocation (maybe a few bytes vs. 64KB), it is inefficient=
 by doubling the number of syscalls into the filesystem.

The other getxattr cache hit during lstat() is likely because of the kernel=
 accessing an selinux/security xattr.

On Oct 8, 2021, at 07:04, Ellis Wilson via lustre-devel <lustre-devel@lists=
.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hi all,

I'm trying to get to the bottom of a failure I'm seeing while running the l=
ustre unit tests, specifically here for this test in the sanityn suite:
=3D sanityn test 73: getxattr should not cause xattr lock cancellation =3D

I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0.  I=
 have six nodes total for the test: two clients, two mds, two oss.  The tes=
t is running from one of the clients.

The error I get is:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
getfattr: Removing leading '/' from absolute path names
# file: mnt/lustre/f73.sanityn
user.attr1=3D"value1"

ELLIS: expected 2, but got 5
sanityn test_73: @@@@@@ FAIL: not cached in /mnt/lustre
 Trace dump:
 =3D /usr/lib/lustre/tests/test-framework.sh:6273:error()
 =3D /usr/lib/lustre/tests/sanityn.sh:3557:test_73()
 =3D /usr/lib/lustre/tests/test-framework.sh:6581:run_one()
 =3D /usr/lib/lustre/tests/test-framework.sh:6628:run_one_logged()
 =3D /usr/lib/lustre/tests/test-framework.sh:6455:run_test()
 =3D /usr/lib/lustre/tests/sanityn.sh:3567:main()
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

I've instrumented the code to spit out the expected vs. discovered stat val=
ues.  The failure indicates the file in question wasn't cached, but in fact=
 the inverse is occurring -- it's both cached and hit more often than expec=
ted.

The unadulterated test code follows:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
3549     touch $DIR1/$tfile
3550     setfattr -n user.attr1 -v value1 $DIR1/$tfile ||
3551         error "setfattr1 failed"
3552     getfattr -n user.attr1 $DIR2/$tfile || error "getfattr1 failed"
3553     getfattr -n user.attr1 $DIR1/$tfile || error "getfattr2 failed"
3554     clear_stats llite.*.stats
3555     # PR lock should be cached by now on both clients
3556     getfattr -n user.attr1 $DIR1/$tfile || error "getfattr3 failed"
3557     # 2 hits for getfattr(0)+getfattr(size)
3558     [ $(calc_stats llite.*.stats getxattr_hits) -eq 2 ] ||
3559         error "not cached in $DIR1"
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

The failure occurs on line 3558.

Manually performing these actions validates that indeed the jump is by 5, n=
ot 2:
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             85 samples [reqs]
getxattr_hits             4 samples [reqs]
~# getfattr -n user.attr1 /mnt/lustre/f73.sanityn
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/=
f73.sanityn user.attr1=3D"value1"
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             90 samples [reqs]
getxattr_hits             4 samples [reqs]

I straced getfattr as run in the test and found it issues the following:
23262 lstat("/mnt/lustre/f73.sanityn", {st_mode=3DS_IFREG|0644, st_size=3D0=
, ...}) =3D 0
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", NULL, 0) =3D 6
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", "value1", 256) =3D =
6

I built a small C program to replicate just the above without all of the ot=
her fluff in getfattr, and I see 1 xattr cache hit occurring for the lstat,=
 and two xattr cache hits occurring for each call of getxattr.  So it repli=
cates the 5 xattr cache hits.  It is notable that if one does NOT specify "=
user.attr1" and instead just uses an empty string you only get a single hit=
 on each getxattr.

I have a patch that revises the expected stat values from 2 to 5 and from 4=
 to 10, and while that works in my system I wanted to know:
1. Are these changes expected?  I don't know much about the xattr cache or =
when it's expected to be hit, but hitting twice for a single getxattr seeme=
d high.
2. Is there any location online where I can look at release testing results=
 for these unit tests?  I wanted to see if I was alone in hitting this many=
 times, but couldn't locate such a repository of historical test results.

Thanks for any and all help!

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_7947C4DF8BEF4AA98EFEC3679EAFE252ddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <44B9AAE8E05483428D0B8C32C374A15B@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
Ellis, the getfattr code has a poor &quot;optimization&quot;, in that it fi=
rst calls getxattr(buf=3DNULL, size=3D0) to have the kernel report the xatt=
r size to allocate a buffer of exactly the right size. &nbsp;However, IMHO =
while this avoids a &quot;too large&quot; allocation (maybe a
 few bytes vs. 64KB), it is inefficient by doubling the number of syscalls =
into the filesystem.&nbsp;
<div class=3D""><br class=3D"">
</div>
<div class=3D"">The other getxattr cache hit during lstat() is likely becau=
se of the kernel accessing an selinux/security xattr.<br class=3D"">
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">On Oct 8, 2021, at 07:04, Ellis Wilson via lustre-devel &lt=
;<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@l=
ists.lustre.org</a>&gt; wrote:</div>
<br class=3D"Apple-interchange-newline">
<div class=3D"">
<div class=3D"">Hi all,<br class=3D"">
<br class=3D"">
I'm trying to get to the bottom of a failure I'm seeing while running the l=
ustre unit tests, specifically here for this test in the sanityn suite:<br =
class=3D"">
=3D sanityn test 73: getxattr should not cause xattr lock cancellation =3D<=
br class=3D"">
<br class=3D"">
I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0. &n=
bsp;I have six nodes total for the test: two clients, two mds, two oss. &nb=
sp;The test is running from one of the clients.<br class=3D"">
<br class=3D"">
The error I get is:<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
getfattr: Removing leading '/' from absolute path names<br class=3D"">
# file: mnt/lustre/f73.sanityn<br class=3D"">
user.attr1=3D&quot;value1&quot;<br class=3D"">
<br class=3D"">
ELLIS: expected 2, but got 5<br class=3D"">
sanityn test_73: @@@@@@ FAIL: not cached in /mnt/lustre <br class=3D"">
&nbsp;Trace dump:<br class=3D"">
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6273:error()<br class=3D"=
">
&nbsp;=3D /usr/lib/lustre/tests/sanityn.sh:3557:test_73()<br class=3D"">
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6581:run_one()<br class=
=3D"">
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6628:run_one_logged()<br =
class=3D"">
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6455:run_test()<br class=
=3D"">
&nbsp;=3D /usr/lib/lustre/tests/sanityn.sh:3567:main()<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
<br class=3D"">
I've instrumented the code to spit out the expected vs. discovered stat val=
ues. &nbsp;The failure indicates the file in question wasn't cached, but in=
 fact the inverse is occurring -- it's both cached and hit more often than =
expected.<br class=3D"">
<br class=3D"">
The unadulterated test code follows:<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
3549 &nbsp;&nbsp;&nbsp;&nbsp;touch $DIR1/$tfile<br class=3D"">
3550 &nbsp;&nbsp;&nbsp;&nbsp;setfattr -n user.attr1 -v value1 $DIR1/$tfile =
||<br class=3D"">
3551 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;error &quot;setfattr1 =
failed&quot;<br class=3D"">
3552 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR2/$tfile || error &=
quot;getfattr1 failed&quot;<br class=3D"">
3553 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR1/$tfile || error &=
quot;getfattr2 failed&quot;<br class=3D"">
3554 &nbsp;&nbsp;&nbsp;&nbsp;clear_stats llite.*.stats<br class=3D"">
3555 &nbsp;&nbsp;&nbsp;&nbsp;# PR lock should be cached by now on both clie=
nts<br class=3D"">
3556 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR1/$tfile || error &=
quot;getfattr3 failed&quot;<br class=3D"">
3557 &nbsp;&nbsp;&nbsp;&nbsp;# 2 hits for getfattr(0)+getfattr(size)<br cla=
ss=3D"">
3558 &nbsp;&nbsp;&nbsp;&nbsp;[ $(calc_stats llite.*.stats getxattr_hits) -e=
q 2 ] ||<br class=3D"">
3559 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;error &quot;not cached=
 in $DIR1&quot;<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
<br class=3D"">
The failure occurs on line 3558.<br class=3D"">
<br class=3D"">
Manually performing these actions validates that indeed the jump is by 5, n=
ot 2:<br class=3D"">
~# lctl get_param llite.*.stats | grep hits<br class=3D"">
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;85 samples [reqs]<br class=3D"">
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;4 samples [reqs]<br class=3D"">
~# getfattr -n user.attr1 /mnt/lustre/f73.sanityn<br class=3D"">
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/=
f73.sanityn user.attr1=3D&quot;value1&quot;<br class=3D"">
~# lctl get_param llite.*.stats | grep hits<br class=3D"">
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;90 samples [reqs]<br class=3D"">
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;4 samples [reqs]<br class=3D"">
<br class=3D"">
I straced getfattr as run in the test and found it issues the following:<br=
 class=3D"">
23262 lstat(&quot;/mnt/lustre/f73.sanityn&quot;, {st_mode=3DS_IFREG|0644, s=
t_size=3D0, ...}) =3D 0<br class=3D"">
23262 getxattr(&quot;/mnt/lustre/f73.sanityn&quot;, &quot;user.attr1&quot;,=
 NULL, 0) =3D 6<br class=3D"">
23262 getxattr(&quot;/mnt/lustre/f73.sanityn&quot;, &quot;user.attr1&quot;,=
 &quot;value1&quot;, 256) =3D 6<br class=3D"">
<br class=3D"">
I built a small C program to replicate just the above without all of the ot=
her fluff in getfattr, and I see 1 xattr cache hit occurring for the lstat,=
 and two xattr cache hits occurring for each call of getxattr. &nbsp;So it =
replicates the 5 xattr cache hits. &nbsp;It
 is notable that if one does NOT specify &quot;user.attr1&quot; and instead=
 just uses an empty string you only get a single hit on each getxattr.<br c=
lass=3D"">
<br class=3D"">
I have a patch that revises the expected stat values from 2 to 5 and from 4=
 to 10, and while that works in my system I wanted to know:<br class=3D"">
1. Are these changes expected? &nbsp;I don't know much about the xattr cach=
e or when it's expected to be hit, but hitting twice for a single getxattr =
seemed high.<br class=3D"">
2. Is there any location online where I can look at release testing results=
 for these unit tests? &nbsp;I wanted to see if I was alone in hitting this=
 many times, but couldn't locate such a repository of historical test resul=
ts.<br class=3D"">
<br class=3D"">
Thanks for any and all help!<br class=3D"">
</div>
</div>
</blockquote>
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
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre&nbsp;Principal Architect</div>
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
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</div>
</body>
</html>

--_000_7947C4DF8BEF4AA98EFEC3679EAFE252ddncom_--

--===============0516423320011678690==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0516423320011678690==--
