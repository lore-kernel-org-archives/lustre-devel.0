Return-Path: <SRS0=ROYJ=G2=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B43CC433DB
	for <lustre-devel@archiver.kernel.org>; Sat, 23 Jan 2021 11:32:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 16AA32370D
	for <lustre-devel@archiver.kernel.org>; Sat, 23 Jan 2021 11:32:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16AA32370D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6E3A921FC47;
	Sat, 23 Jan 2021 03:32:13 -0800 (PST)
Received: from NAM10-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam10on2053.outbound.protection.outlook.com [40.107.93.53])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B387521FBD7
 for <lustre-devel@lists.lustre.org>; Sat, 23 Jan 2021 03:32:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BSLGCgroEHplyHG8giFIDrf0NGKzj9pPtFUGsN6OQsLIVH60yFHBZBmSvdt4JliCRrP+lyDy6sM6qPf3fi7ndicb2zvT3Ss+youU/QjN5D9dGSVqYc1t4507EhYlMNJRCYpAZorGfD28wtQxxa0M3uO1RtGCd9KZRsPf99wSTPDU3+Bn/J7KV2iSOMNyA2pPOn+T1D5abwIoX03n38EbLStikdX2/4O63rRkmSNKzw3DFqdJSD792JbfBo5yK9Sx5JVGdcMbphrDU0dVOc5Kn3CzQ1QRD0/1hTdhDfCQTRCGoCwzeGXSWRJp2RnJRO0HmBk9vJArpvXBq4LtuIdhSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GLosjUG1vB/VHfAzc3jwSeb7rK42+sBN3Ca9s9vQcws=;
 b=CFnUSxGlmO8/gWp4RryWFGZnd9nWu+O8eJNiI/tONO/fvafsb+4JSzNyB9DT8Y4BT7mp6ZzkI9q5m7MR6x/YaOcjo1azNV+yva6gzINPVYIxk83cibb2H4TVERN4lZ9jIPm/rh8VHpQYlY4nVvuDk3aPSNO9fSlOZwwrTc744qpRxTA4OaAqDIj6gg2LE6KXkxrHQGxthHr3OaopF7AjXImtLNza6BUQT8Yorr3YhnjvcjOKuBEdTLfuQwHDPap1YQBgVVFrR0BQiX1jg/LhHvT1+LPwKuQIDz595+oPzZOsrw4KyhIhi04gyuami9li/TIqkdTqVaq+hZyvXgUtKw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GLosjUG1vB/VHfAzc3jwSeb7rK42+sBN3Ca9s9vQcws=;
 b=DpvYqExWQvjrJWBmvPJE+bqVasI7WMd6k1KM4et847Ydnn0+8UnR/n8k39p9gwN9dZozt/Tk1QutbMS2UqJvnHy8BTlVXEGZk/TGSDyl1kZ9SIubpHnicmEQ3mqEr+HkPzGVaVE99VP6FyfYYadzawrNyxNSqrnzO68DFKEv5qo=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by BLAPR19MB4292.namprd19.prod.outlook.com (2603:10b6:208:254::19)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3784.11; Sat, 23 Jan
 2021 11:32:07 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3784.017; Sat, 23 Jan 2021
 11:32:07 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Thread-Topic: [lustre-devel] Getting client UUID from transaction code
 (osd_trans_create) - osd-zfs
Thread-Index: AQHW7psF0FggxqbSDEO/M8mt/qwoV6o1GYsA
Date: Sat, 23 Jan 2021 11:32:07 +0000
Message-ID: <80AB5C3C-C916-4058-8B80-BF4380C3F65D@whamcloud.com>
References: <CABnqofyTN6Cr8JaMgeoke5TWG9j0JL_vMq03YPd8sYuRHXfqcw@mail.gmail.com>
In-Reply-To: <CABnqofyTN6Cr8JaMgeoke5TWG9j0JL_vMq03YPd8sYuRHXfqcw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: gmail.com; dkim=none (message not signed)
 header.d=none;gmail.com; dmarc=none action=none header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0237f04d-2e9c-4c26-e684-08d8bf928432
x-ms-traffictypediagnostic: BLAPR19MB4292:
x-microsoft-antispam-prvs: <BLAPR19MB4292AAE84B5DF51EBE04EA9AA7BF9@BLAPR19MB4292.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: OUolAxSaABTdZUzbytMpPtuxHGKTmn6JfMQPtdKyNS14TkUazKWq1OcSzA3PZugSCjFRIw8QKywhadD/aOMN7OeetSol67QtIXO6DpRjGFjoVX6jlFrDauABlFLH2YZBHPn96yIP7htuw2e4LaMVNWthLk4dIK+2ORsc+Xvt//yS8sD15YI9pFwHHDDWFKon7RyN1a1YD5sWmpuQzIiHXggg1BrPLRVGw4V5lez2I45sAhgcEAJ2ivd/VnUE7hEQq/nD5Klt4sunBZz82C46XnQ+5uXodNLd2IEV1qj17GPfNFbVT1XFp6KyPdZJeEaGkLZLXJERptWpc3007nSCv9d+Jkga0yCBdQ7EwWr6hRdK6miCrNutWiQJEImdOQju2ropsF0y+D5zQOPEnf08TQCPFlUACkOfxj2nbV6AZP2l5iy/8siooJmW3kizjL9KX0Eqk/4oiUuzX3xzD6CkN1TI3CHZcWvNA6/aemSyDBxThEr8Eel4Z6YLhXQ45NS733C1c665kjuffnOp8YrB988RWX4KaFA0y0r2bjURFVr0mhQ2fE7U8a48sBCrio1IYv1AlScgTb8YDH7tOsFq5ru4Iodk2ab6NcjPRNSaiWY=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(376002)(346002)(136003)(366004)(396003)(39850400004)(66476007)(76116006)(91956017)(6916009)(71200400001)(64756008)(66556008)(6486002)(86362001)(5660300002)(316002)(4744005)(4326008)(66946007)(26005)(33656002)(8936002)(66446008)(36756003)(6506007)(478600001)(8676002)(53546011)(2906002)(2616005)(6512007)(186003)(83380400001)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?BtLbc8Ur8/UFKSebM5Gz0MPp0jgOmFMZagOiUhOW0BBGgZIjLapBaI3/8gAo?=
 =?us-ascii?Q?l49WJObp7txgF1DyryW8vq/y8yIBCImtf0vljCNMwyk+uYV2yom+1USDi2R1?=
 =?us-ascii?Q?doDlneovbiA/i2ikUAtx8aoKGG8gn4+Rr0w8fCg8zM2wQBz0IYxWJ1/KGIJr?=
 =?us-ascii?Q?rNUftK8g22re97vsWizxpSKfk4vOkUk8YFhLeq5+mODuHqMMIAI2AklIyke4?=
 =?us-ascii?Q?Z260KJ9AFEhP24S9TcbYDzdVpbXXgCSH8i1gPj0eVD5t3bfDNP87D5knN502?=
 =?us-ascii?Q?a4lfb8+admGO92uADMh3Ss3yvkFYOJXchg8iOD/2QMYPDa0c/TIh94KhFAF3?=
 =?us-ascii?Q?ZEs/ofRhok+oys2kfqQfVwQO81MhOGWh0Zc+xRHJHTfq/bvGajF3iNeXh07n?=
 =?us-ascii?Q?9dcHrCk+HSjSDdYKYa6A/sV7xKtHXDjInaVrUbQCeRp+AYVi6pkm5m1Ugecp?=
 =?us-ascii?Q?d2GqtEmF/RfneVaM85rLukGm8OW3r+EANmspmINcbDEKx0YysjWNmIHBUZIf?=
 =?us-ascii?Q?O29CmJdIU4Ddlp7Rs0PeksigGfjVCaJxRZilQzz16su51zhZlqWxCVK2TWUa?=
 =?us-ascii?Q?WGRe6oK2rgo4tnezHVqfqAnqSg3ibyeX/KEEmm7zf5YIN8Ro8fk+u/i7fl+i?=
 =?us-ascii?Q?oSefZYlcDVJP9VwuB4Uc+VYNbfo4QqB8rn9GyH4UfG0R35UwzEvzhpaKehmY?=
 =?us-ascii?Q?cwo2aPMkRSUfKqy+owcSMJuVHLCB9TPsRitIei6fOs3N0VqL+unwGmMTwylZ?=
 =?us-ascii?Q?wLaCbfGw06wtSuaS6kZn0w0wD76UIeFEOBt4oD29Ul7+yXTWnXu+8IptHfbW?=
 =?us-ascii?Q?cAVFz6BilekN3JT7T6Am1+e+mSBS+H6w5ZqQCZtDlsoMPRfEPgsabGtwxVGY?=
 =?us-ascii?Q?r1wUg8r7cqt8CivDAYfPqBu2nHnsH3gGO58TO5fEvyZSTcZT+pQ7xnpvGmRe?=
 =?us-ascii?Q?83wCKViH3eYvqIIdMppee0C8ovDXLwjDQ4WT9+W1MJRfERh10H0NEx5SnV2V?=
 =?us-ascii?Q?/AQD?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0237f04d-2e9c-4c26-e684-08d8bf928432
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jan 2021 11:32:07.6564 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Pdr3JaG4qF8AQ/MkCbwmabZpjWQF98wjPvyK2tWQuf5KKImjDbsnVREvpioKMCw5
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLAPR19MB4292
Subject: Re: [lustre-devel] Getting client UUID from transaction code
 (osd_trans_create) - osd-zfs
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
Content-Type: multipart/mixed; boundary="===============7871580698707877083=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7871580698707877083==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_80AB5C3CC91640588B80BF4380C3F65Dwhamcloudcom_"

--_000_80AB5C3CC91640588B80BF4380C3F65Dwhamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jan 19, 2021, at 12:40, Sudheendra Sampath <sudheendra.sampath@gmail.com=
<mailto:sudheendra.sampath@gmail.com>> wrote:
When I have multiple 'remote' clients writing data, I am trying to find a w=
ay to recognize which client data I am writing to the underlying storage.

Appreciate if anyone in this list can point me in the right direction to ac=
cess remote client UUID.

Probably the best way to do this is to set the "JobID" on the client, and t=
hen check "lctl get_param {mdt,obdfilte}r.*.job_stats" on the servers.  You=
 can find a detailed description of JobStats in the Lustre Operations Manua=
l.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_80AB5C3CC91640588B80BF4380C3F65Dwhamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <4091EAC578967B42B19867B861EF384D@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jan 19, 2021, at 12:40, Sudheendra Sampath &lt;<a href=3D"mailto:sudheen=
dra.sampath@gmail.com" class=3D"">sudheendra.sampath@gmail.com</a>&gt; wrot=
e:
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D"">
<div class=3D"">When I have multiple 'remote' clients writing data, I am tr=
ying to find a way to recognize which client data I am writing to the under=
lying storage.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">
<div class=3D"">Appreciate if anyone in this list can point&nbsp;me in the =
right direction to access remote client UUID.</div>
</div>
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>Probably the best way to do this is to set the &quot;JobID&quot; on th=
e client, and then check &quot;lctl get_param {mdt,obdfilte}r.*.job_stats&q=
uot; on the servers. &nbsp;You can find a detailed description of JobStats =
in the Lustre Operations Manual.</div>
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

--_000_80AB5C3CC91640588B80BF4380C3F65Dwhamcloudcom_--

--===============7871580698707877083==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7871580698707877083==--
