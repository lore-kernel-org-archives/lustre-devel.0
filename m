Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D75BBC433F5
	for <lustre-devel@archiver.kernel.org>; Wed,  8 Dec 2021 21:09:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3CFCD318373;
	Wed,  8 Dec 2021 13:09:39 -0800 (PST)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com (unknown
 [40.107.92.46])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4F56F21F957
 for <lustre-devel@lists.lustre.org>; Wed,  8 Dec 2021 13:09:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=hB0DYXwJ5H8FKt6ECbCTekABOy2zVvKzLVoC9q4VjEyM+N2AwjNJ9UpYRiMVNt0DLSHQcbUdi2OJbJ58qC4qYNudHkq/obaFUNQiWpdrjWqc92whUQArNO3VnxVZrHItDM8eLG+GC5Y/t6y8sUTLKzSUcln3L9BhbIgdwwj/lgsULWiTnCFvQXZPpNRgqdeQh2T1aKhgem0y3dkfUSQ45QZmq2gi5luyw7CD1aaNMy7Jn2D/XI8FUpJDWF2ktlHyZ2+tgGfAHxa+Ql2ymc6zOPP0faLKy/QUD+HbnFK4A2+J+vzPuAiAOdNzomXsZFzgJuxzRrpE3BGyEtBQIznvZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ZPYtcCc0IzBUC2Qo+u7SmXAdKd1x2ZcbfJKkRvN35mk=;
 b=na51U+KqaY0ypvI1+PHmPMN0o7mA5bmK76Z+dpl+rLVzrSgAGsz+FTpA+t8Hn/NNC/zb9vho7vtdBQa42EH8gCvqp4zRBwOpXqNrQ9163dB3ZBWWMUvRmqLCodB+FsAudGoWVtA3NW9pqpXqVQvtkd8G2duH8mYrUq1A26fI6ycqt7ZJ+3Nwxf9R4a2wZS6R2eeZ3XO3IdNOxpTh6hokYH4Ua6B+2pi99YSiOrnYw0Kc6pYfdJB0/mS1czZRSPMmpdQvyOSsElxVViJkAKfTZVcc/7Ss24FP2GvDgaikLuLbjGmzU9+ppckOchTWOvV0bwLiC/64o9HMKczHyDlrrA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZPYtcCc0IzBUC2Qo+u7SmXAdKd1x2ZcbfJKkRvN35mk=;
 b=SeNqXLzGqAPZZ5N8oQ8My2nJAcVxrI6UwLb8PqFbG21HwRwXPK9TMRUm7WmlzRjh+3TvKtU4vXG0OnLzZu+PyTuDE3CtktRE/O0bAnHxZspIxwP4fhiy8YUHnB5097mqt06HtD2XUPfyPnKqXHXmkzBe4IGyRQyPxmcnUFs0URc=
Received: from CO1PR19MB5208.namprd19.prod.outlook.com (2603:10b6:303:f7::24)
 by MW2PR1901MB4682.namprd19.prod.outlook.com (2603:10b6:302:b::21)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4755.16; Wed, 8 Dec
 2021 21:09:34 +0000
Received: from CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::6cca:719f:e89d:69d1]) by CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::6cca:719f:e89d:69d1%8]) with mapi id 15.20.4755.022; Wed, 8 Dec 2021
 21:09:33 +0000
To: "Degremont, Aurelien" <degremoa@amazon.fr>
Thread-Topic: [lustre-devel] Recommendation for hsm_restore for directories
Thread-Index: AQHX4Vllf3Bwnicwgkmxm9xoW0myMKwpLRcA
Date: Wed, 8 Dec 2021 21:09:33 +0000
Message-ID: <41730927-7BB3-46DA-9251-98E0DAA45A31@ddn.com>
References: <4A74832B-D0A9-435D-AF63-EA0ABF8D626E@amazon.com>
In-Reply-To: <4A74832B-D0A9-435D-AF63-EA0ABF8D626E@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6d00b647-26ee-496f-a2c6-08d9ba8f08af
x-ms-traffictypediagnostic: MW2PR1901MB4682:EE_
x-microsoft-antispam-prvs: <MW2PR1901MB46824A32765DF461DFD5500DA76F9@MW2PR1901MB4682.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: G9eXA0aju7DWPWaHXhNmHOEcXQgBuDfeVOJQ8v4l9LqfLS1TM8cdV7B6yZTYixyZu8wtyspUNc005fRSAmwj2cqLNoyxaGyOVXGJIzBeNWzSDj45zY6+8J8M/B8TQNtoUNex5AtjwHqk7iXpd3Np/ZmQEfbFKLIlbs+UhChNtMQXOIpqVqoccfzQVvKaB2Tx7HsTdSdLUfOoJop3G1L3RDOhsg2YXLa0F7LrNF6bY5kkhdy5b842ebFID1UMn/LTTYM8IjQxiM4BZw1XAx2JO5WeiRuCRI3cavQoTlbMVXgr3ZfLr++DIJ2TXYNjEBc5M4Z3kwHGs57PigEE3ozFNTrXpuSDO1R6wsRbLA/4Jc+QlOoN7yQw+PiyLQwW6xDbKFM3DNbXhgqlI2wyE0HvSIsDcdD6HbokXvaaNAM7RDiZzZrAn2VGu2mBiMARk1xsGVk9GOGAiuGMzA/C5hCbvH7FqttdMSI/qg09a2ywKDQm+L8rYv3fohgnH42X1UPNAXubFqbHVTsPrtXyUBCeXdLhPMnrJSKC1Yd+rYx6HD5apVK0s3mK/N738PNGRTOBy2LTKSaRS+QcaYTrLV++qFpiT+uQaYpHHldIb057jnkBsrRRz+1zuH/3EXcG2Oqc9w8tgBgsPSsmaAnLTLZd3jj/zTfSp7uKI1Onz243CzyJfFg/dfJOckL1TVoewygLmpSufq8k1xCjEf2zLBzvrby1s8r1aHpaKjpJq+PMZSEiNPDFj96nuz5nU0Y61M6mINb7fPHjeSlsiEpBpD+dZahD3VAKhS4g4Hy/zmBQWNlkwTAiyLAggbYPabGBS3Il
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:CO1PR19MB5208.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(166002)(966005)(122000001)(4326008)(83380400001)(6512007)(186003)(36756003)(76116006)(6916009)(53546011)(8676002)(6506007)(9686003)(86362001)(26005)(38100700002)(71200400001)(6486002)(66446008)(5660300002)(38070700005)(508600001)(33656002)(8936002)(64756008)(66556008)(66946007)(66476007)(316002)(2906002)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?+vdONtYeag7bwSZaAKSXnvcLOo2y25/UjLjsvZG+yLjZgxvTqgI/UO71VmBc?=
 =?us-ascii?Q?g/iSZRaDFFbXrlO0p6rFfU/1I9y0C0dd7mhMnaFSXRgSAZEWu8R3TCqaSzX+?=
 =?us-ascii?Q?xtZ3KakCswnSttMBs4uLJDuOK4nwFu/I4DG/slnJhVYL/QAACslh+JgxcCAz?=
 =?us-ascii?Q?X81afOL5g4B3cHb2lGKpLhRYXXcg6sWPY+pnkjG9VbQjqrHKy9Z/SB1REwki?=
 =?us-ascii?Q?0v7i8jIoOYAmCDyGcUnsAjAfVz24RpuviuQDdrxeEhNMjvuwJGJfuC31XOMc?=
 =?us-ascii?Q?pVT+Uatc4UwJGBdW9l7pxInSjZJskk3vONZqJ7xCwEprWxv0T6Pn3FXt4b73?=
 =?us-ascii?Q?cpHY7r2cYTq/vCc9x3UQb+ldMMCdRQfgSSKGm9slz6E32EhU5eA9QdavDqBx?=
 =?us-ascii?Q?dPoDc+cTZtSgLO+zPNo0RQOkAYb9vqxF3JVaFHYomlKmbEKPxbCXFtrNK/c6?=
 =?us-ascii?Q?e/SxiltJ37/fg/P+tYH8jqmiAW05WpXkw0ZeXfdX5MjXSPW1WZjF0EMhOOt8?=
 =?us-ascii?Q?8WnIZc6iO7MY0QE9fCSbHI+Br0l6XBB6dbjfEZBjkdd9XPpQFKPXRvtU9MhE?=
 =?us-ascii?Q?wGUwUE11ykoDnN+a8ml43GnLmP3xPPSjW6QUxqW1zeWw4lWHBDVN9hJh1mOo?=
 =?us-ascii?Q?NlCvpsMV5bGvSN4iEGgCvOkBLZj9j44C/U9VqK3ULvOB2wFuqxe2a7Yw+rta?=
 =?us-ascii?Q?iHccGRlGSPrPaB2bKgzzeME8y8/hZHBBEPrHbVRS4oODV41o2ZBXExM+pk6k?=
 =?us-ascii?Q?qT3kT8+jYEy5nwcIpJwn79hv5B/iA9I3Z1EoeEWlzkWb1u9dJu6nMUYA+ySV?=
 =?us-ascii?Q?UCD3uTI0Bv1plqTBQSR8ndRuUd/QhaZkeB9o55TpwjB8zC0XIzfIpFyOgq0i?=
 =?us-ascii?Q?trlB0g/RNZDdPsbnfkSovpP9m18mOjl3OcjjwHBkXI5YeyH14x6XOVP3XSyc?=
 =?us-ascii?Q?5u18YWF90uvIxnUuoQSM/EBUYx2Wa/pYxxSwNPk5jIZqCxEfXlzcR0kynLka?=
 =?us-ascii?Q?IJqfl5C/HMSxlEKbmKSOzGOdaPefFrvGAnvetvFIJUwZ7On9mlUFTYb7JVVQ?=
 =?us-ascii?Q?nhJ5CavzEgxHLKM0nafFrha6hrqhqopxnkKa9EGXizNEy1chAlxpl4foaQwr?=
 =?us-ascii?Q?yVSLBhf8qvGNCApnAtAQEhWxK2/dPLi2aCowQClReCbNG1NrzgiZHSVBdXnM?=
 =?us-ascii?Q?kKAvuRRaMX9JmY7mFy/RzDdA/NIOBY7WTjBFRqgGxrAu1Oz98drE7btPifC8?=
 =?us-ascii?Q?uoEy9tiLtfYMxdXTFsmXtAPKXxB78oHy+ruBtRjdV5Pl12lqIuTenco7VR2V?=
 =?us-ascii?Q?DyhrYSJ3iZnRms2EBJ6QIUWCVSgYBPJHX6JUvi5tLlMRVAZtNy22gXT6XM60?=
 =?us-ascii?Q?0DTss6zhV2PDaPrwbibLnXYOUpnm/ihcceO1ZHm/xEVPSWvc3601r5C8RAAj?=
 =?us-ascii?Q?chq2+WSsTxA2kzgOR9GTkBzTfOCvA+evExMr6XiFpv2PHuEuDzDWBiawGcfQ?=
 =?us-ascii?Q?WeenHD7PH/KW8/kkDHB38m6MKulOCoSLe6IpzBlTpS5XRG/xwBAUdsS0EVXV?=
 =?us-ascii?Q?qaxCI7hhZwLz0/zIkSs=3D?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: CO1PR19MB5208.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6d00b647-26ee-496f-a2c6-08d9ba8f08af
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Dec 2021 21:09:33.5845 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: NXkC6aeYgD6qzMsMx3njvwXoiWUyRTHDRpuh00+5Xw9hqqIkbaIWyx1FY2sCJZj3
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW2PR1901MB4682
Subject: Re: [lustre-devel] Recommendation for hsm_restore for directories
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
Content-Type: multipart/mixed; boundary="===============5767328563743893862=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5767328563743893862==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_417309277BB346DA925198E0DAA45A31ddncom_"

--_000_417309277BB346DA925198E0DAA45A31ddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Nov 24, 2021, at 10:33, Degremont, Aurelien via lustre-devel <lustre-dev=
el@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hello all

I'm doing some early work toward implementing a directory/namespace support=
 for Lustre/HSM. The idea would be to support something similar to hsm_rest=
ore/hsm_release but for directories.

My first thought was for the MDT to not grant LDLM lock for this directory =
and hold it, while the directory is getting restored by copytool, in a simi=
lar fashion than what is done for files. But the hard part here, is to have=
 a way for copytool to access the directory while its access is actually pr=
evented by the above locking.
Restoring a file is using this smart trick of restoring it in a different t=
emporary file and using layout swap at the end to move data to the actual r=
eal file. It looks difficult to do the same thing here.

Do you have any recommendation on the right way to frame this directory acc=
ess for copytools?

I've thought about this in the past, and IMHO the best way to handle a dire=
ctory or directory tree would be to save the directory and/or whole tree in=
 an ldiskfs image rather than a tarball.  The reasoning for this is that in=
 the future it would allows directly mounting the image for access by the M=
DT and/or client (Client Container Image), unlike a tarball that needs to b=
e extracted each time before use.

There is some discussion about this in https://jira.whamcloud.com/browse/LU=
-13024

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_417309277BB346DA925198E0DAA45A31ddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <D6D6EF378719A242B4E10C0648CF69C6@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Nov 24, 2021, at 10:33, Degremont, Aurelien via lustre-devel &lt;<a href=
=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lus=
tre.org</a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div class=3D"">Hello all<br class=3D"">
<br class=3D"">
I'm doing some early work toward implementing a directory/namespace support=
 for Lustre/HSM. The idea would be to support something similar to hsm_rest=
ore/hsm_release but for directories.<br class=3D"">
<br class=3D"">
My first thought was for the MDT to not grant LDLM lock for this directory =
and hold it, while the directory is getting restored by copytool, in a simi=
lar fashion than what is done for files. But the hard part here, is to have=
 a way for copytool to access the
 directory while its access is actually prevented by the above locking.<br =
class=3D"">
Restoring a file is using this smart trick of restoring it in a different t=
emporary file and using layout swap at the end to move data to the actual r=
eal file. It looks difficult to do the same thing here.<br class=3D"">
<br class=3D"">
Do you have any recommendation on the right way to frame this directory acc=
ess for copytools?<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>I've thought about this in the past, and IMHO the best way to handle a=
 directory or directory tree would be to save the directory and/or whole tr=
ee in an ldiskfs image rather than a tarball. &nbsp;The reasoning for this =
is that in the future it would allows
 directly mounting the image for access by the MDT and/or client (Client Co=
ntainer Image), unlike a tarball that needs to be extracted each time befor=
e use.</div>
<div><br class=3D"">
</div>
<div>There is some discussion about this in <a href=3D"https://jira.whamclo=
ud.com/browse/LU-13024" class=3D"">
https://jira.whamcloud.com/browse/LU-13024</a></div>
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
</body>
</html>

--_000_417309277BB346DA925198E0DAA45A31ddncom_--

--===============5767328563743893862==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5767328563743893862==--
