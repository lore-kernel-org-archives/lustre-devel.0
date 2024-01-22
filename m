Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 384E0C47DD3
	for <lustre-devel@archiver.kernel.org>; Mon, 22 Jan 2024 20:40:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TJhsl5YcFz1yDr;
	Mon, 22 Jan 2024 12:39:39 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TJhsh5rxcz1yDD
 for <lustre-devel@lists.lustre.org>; Mon, 22 Jan 2024 12:39:36 -0800 (PST)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2169.outbound.protection.outlook.com [104.47.55.169]) by
 mx-outbound47-204.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 22 Jan 2024 20:39:34 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=fPuNXt8YA+iwYOpWa6gFdh6jod7j17dZxMuleCkqoergtRQUmgdRX148P6OdkxaOS+PDVVRaciiLNpfyqUI8fb1/9ERCrXol0DVgASANL3xlZzfg8lxLuoDSNM53sr74p3BWuIjYPW8e+WihcN8vgoMluQ3tEqejo6fvmnSzVivfUppDkixh8myv7OwQ97thx0v/8l0PwqDii1qr8c0lkKpfl+oWwtYtV3r69oLzwkqedIb1BMvh9AyjAt0VIvpGLd4LkiGY0pi2zCSJQMB3sl1rRyCByf21iuHQllupdV08fX4kgU5Y6mjeW2RVuFB5aUr3FVQGHix+fan0qulavA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=zlmzDJm5tuRrQ1Z2QrefmP0xWvz7Hce8a96ubDnF0Tc=;
 b=S9bWjOoqmxy72nTiN9+SHvgZ8owLKBwqOjEgk9C9eS6ioRUT6aIop9LnANgfIihvV6L7UNfPqrsLWD+v9o/KYSJpZZl23A9m3K0Xk89dVNzlIDgQcsOwVDjjoQ+InZFHAt4Zm3yhzayU9NOfqtbC4ZeVvB0VuJRNZlou/3qqfxes0tiNP9dKB7+5EOc9+kDH1FYjIUPwsOl5gRC3TELsL1S1rE28a2waX2CUOwcYHS+Vd7dZEq9FgIT3CBaG51+Xwznf4Oha1Ay9SHFyp3CQL+9MjNM73A2XzbFShIgxsKhr4YUm6wRCjs9c5znKt1L98pw0896VXW44egWGblOhAw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zlmzDJm5tuRrQ1Z2QrefmP0xWvz7Hce8a96ubDnF0Tc=;
 b=YDsJBkVJdlJ9OKs7MyqjejmAdvMbml6pRSfx3wNz1fOxmYVWuYZJC6g+nS1qZcnTCQCH1LtXLxTI5cLqQ+MHvf486k/hT5oPw1MNEhldKvGBMF9/HRM1A891d1enBEYz4Ekkw/BEMWoSDMmM2yYUpbz31F6kUp0SWaSMPe01Po0=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by DS0PR19MB7669.namprd19.prod.outlook.com (2603:10b6:8:f1::11) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7202.31; Mon, 22 Jan
 2024 20:39:31 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::22d5:7dc1:2df8:5fdb]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::22d5:7dc1:2df8:5fdb%4]) with mapi id 15.20.7202.031; Mon, 22 Jan 2024
 20:39:31 +0000
To: Jeff Johnson <jeff.johnson@aeoncomputing.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Cannot find documentation or comment blocks
 specifically defining lnet metrics
Thread-Index: AQHaTWpMHpLMJYUAq0WTpPNr9z5RJbDmS10A
Date: Mon, 22 Jan 2024 20:39:31 +0000
Message-ID: <1817A78F-4EDD-4832-9859-AEA980B32A25@ddn.com>
References: <CAFCYAsfNnaLzKZrOTLLOc0S3077reuEWjs0ytJYNHm4+-5R4Sw@mail.gmail.com>
In-Reply-To: <CAFCYAsfNnaLzKZrOTLLOc0S3077reuEWjs0ytJYNHm4+-5R4Sw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|DS0PR19MB7669:EE_
x-ms-office365-filtering-correlation-id: d149ca3d-43d6-4d5d-b9dd-08dc1b8a3c76
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: hMYOkhwk9ffYp9YKYtc8u/YN25pmWb8AmAuftbCjK+NYxM/IQF45i4tdSI9sUL49Q8Kuw0boBxBExfeDgzlumqgsd8jQWFGY5iHU4DJAkrzoCYcov7D7Matw2/hYAe5bKVYyY+RhrQA3XqIKa29+WMNaH4XOGTYNeLnOk7gC5lYaCbw4otAUAnLVPUfMUXeiBBVrlnG6NUx27jGebZYKmSPcsFekVIo9IftuyMpLMnnjFxdOiHvRvnFdSPvTOlbFl2aIWsP2gQ1KjfYl8flUvmFBydwyXw+eeIkiFlkgbS8yHux6hpxnGBGcMtHB4/HUr5R7lIVeALF+4hkBa5UMyW4zJafVP3yxZwQBPOigNnTqGMDlJ9IklwmKSdcrFUxILrR5TvWjcqQcgqg2NGGfFxV/cVxRDxTKmGhziJ6G5xDZQ6BuuvA0ovPF3c9ENQJ/dnw+ADmCiLBVvkmF8WlrOAABiwII7EupV7akBHW5I7E3h6RIeyGr68GOnIWDLQ7erVwcOV7mKZXzQL5fBd+quwxQAHXjROrY6dXbBoAHNgZadvfhdU0lEbg2495KLZBl9X9AWWRu4fTFAOQk9+rlal98OnFA5SyCjiYDpdcrEL01e7EFQo3EwIJSARSXu5sd
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(346002)(136003)(396003)(39850400004)(366004)(376002)(230922051799003)(186009)(1800799012)(64100799003)(451199024)(26005)(478600001)(83380400001)(9686003)(6512007)(316002)(38100700002)(71200400001)(66446008)(2906002)(64756008)(66476007)(66556008)(86362001)(33656002)(5660300002)(8936002)(966005)(6486002)(36756003)(66946007)(76116006)(8676002)(6916009)(41300700001)(4326008)(53546011)(122000001)(166002)(6506007)(38070700009)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?YpHuN3xhbsb0jYwImUJjx+TLWWAm+UzaFShfQI/+GkaVBlnCTS7mm35FT+VC?=
 =?us-ascii?Q?78FFPjLvRYviq2v5aSfvnA8iCJyV9bnDuO/Q/JSwDTUS2ugggXk2eG19vRdB?=
 =?us-ascii?Q?N2rtcueYQo3KDpoSrTHuj4sZPkxe+wIJjo12auf7jTjLuGk8PwSXLBrVG3OI?=
 =?us-ascii?Q?YKm3aaHoIGTewsPRaCjqgOxEQMvSna/EJtYN0zYLP5fN+w8XbrqU6SnDVS/v?=
 =?us-ascii?Q?/G7l6DU1aD6Ix/y2TzuyLe0rONbfhBOJ9cW4y3jkYEZwC89rSqQoBEWgeHUX?=
 =?us-ascii?Q?pfzWOJhQKV93vBW+6RGu13wtl+PexnWXcaEx/HZD1yYmPQFDOF+Zp4MuwR3w?=
 =?us-ascii?Q?GW6s7tq2/5DPVYICBBvwKhgf98ZVhX4nSsNo2aKrYAbC+kRbgSY1znO4s5rw?=
 =?us-ascii?Q?57l1QCm+kHBXqV6tFUkQZhSHbJ2PrIfk7Sm1x14vmMUQb2eqLt7ypVe/7zpr?=
 =?us-ascii?Q?TjZPJbSIYKgsoXpFp4raVfqoNc/par2Ueyyh6N1NoeimFwgfHWfwj6rq+UIe?=
 =?us-ascii?Q?4T5UteOvwSPbojfZ592Zv7ZrVVqZtfJCypZeAD0Xrsw6MTw/LUKFBctoSW1k?=
 =?us-ascii?Q?nvHsuABpxe2f5cW5oo09MRytQvXEE6sisridtj5RKPGs1/i8eWgdloQR4YHr?=
 =?us-ascii?Q?AHqjoUYnjh/Jps81giGraqgFzE4BBubYmWuWdQ0UaQZUTn3j7jZbphIcPJ0Y?=
 =?us-ascii?Q?5lwP8EctLB9IThEd9NGGoR7/EeNZIrtlmbEE/KhWmiDbG7RcGdDI73ZF6yz2?=
 =?us-ascii?Q?fZciziXS6FcFEx4BAPvgQzDAhYVZ8099vqAzd16D4jroJtEJwqtl/2l+G4xQ?=
 =?us-ascii?Q?RetNs+r63A1DybRt5HdXMlv6MOU4dcG0UZJm2tjphhUt1T71adW9Bb3qpqar?=
 =?us-ascii?Q?ngY9Zmq8IuCajKFHmHR/0uqKVNtG7HTI7C2F2KOORuCyC8//hOqxABgUHemf?=
 =?us-ascii?Q?H7d4VBsWEAQhzRcI30l7oqW8IXWkPRRB+kdOSl5A2bxBOInMJNQE9RdlzxWR?=
 =?us-ascii?Q?fowTkPrMD471Y4Nh5d0AGM7wCIg9B9rapMYNl6ITLvss3KVkQmhEVH6ggK1D?=
 =?us-ascii?Q?/YQpm/MD3Qq0Fo/RbrkUJxViI92Agl1pXceLTkLLRwvnSkkgpQgYUl3wdgyf?=
 =?us-ascii?Q?HMLv235m0LEms5G2/bxAEKPHmSJP9w9jYhGHyM6ohuXNijFvVZct8QDnq49z?=
 =?us-ascii?Q?XN28V32FYaqKJj2uiKP+t8LI5ROtibmQEZU5qObgg61plQtkmNbapm0nK1pR?=
 =?us-ascii?Q?vyB4YDl4RNsPKENh0Yqa/L2XumpcL51sHCiEO+H9i0CebKua93dZgZXSM/85?=
 =?us-ascii?Q?sXcXpuBXjThXNQyUzJR6aggTGoOggxlrWICjfl06nQCUkjUrnFFGfIdRAyjk?=
 =?us-ascii?Q?HuKMXsn1yMpGjbMIoOCCqE6hmwnhd5J0Et297kpzJLKBj+v4jG83GYWPUaMH?=
 =?us-ascii?Q?WpkxX8BHjXF6D+6/Vo4DqqRQOoxD8DOIMtmW97awNoH2z4GLpJtzNkj33GiL?=
 =?us-ascii?Q?8Gz9GeYBS9O0G1J3nN3oV1n0yi+AMkmx2lazDw3Q6343G6NHANngAWO+Fdeu?=
 =?us-ascii?Q?y1Q0O0YlSLK6yUvW1xXb62ThiFa0+G52lGINp53k?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: WgGNHhSR/ZCh2J5aWtISUnH6WVs45qYHPV5fk/agZbJStHfjdUYwbIOlrt+++ZHPT5fuVBRZfDdPDNHtyTHkt+U7MMj4hKutA1yFslBw/PuT56L9lfZQcvEd+UhbnyE7CpRLuWH619jE0DNNkPbkS4k8DeDMu0vprbStQSTmURNplGnVp6RE38wn+jeGP+KL+aT6R8kvgGGjRc9mmEQJoU4QGFSg3cP2EPijpQpsrhBQNi4z9J0F/QVNdQ284VlE1L2MMmPkbFLzCsegseqHByEENK5wIgJHuUTQuKBBstX+gJtLkXmkuresFpG+V9+nwlqtlc+dVwuQOe50sLE+FX8baD9tIN8My9w8F3r+N8bOmxgClZ6z/FPaIR+cQ3djeEjwqDBzyG7ZElqYgVCVKycgScQUKhdv9nhA0adfQrmWbfGEFZyERb6LQhZApBKrX7VDox2DAUMCZIzFWFHY2iKfqpq5V2z6zn0zvrNSZ5rn8nrHTpwQN6cpyWmwfpzCuV46HG3zbb8gDythShU1NfHM0tmKDoxl1y903EhY3ZuM3oHMv44IPvMwSjdzW49YRmD89rDOfkJz55JRurJ57WYlrbJ8Tk41mYK7KnOvXki39HQ7l1rAnuVXH72iIpY9o91KIC5SfyDVqjuytDU9y70xQmilfX0tw0f57rhGPGU=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d149ca3d-43d6-4d5d-b9dd-08dc1b8a3c76
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Jan 2024 20:39:31.3054 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: xtpqZq3iIT6IaAM0rtfRdqCzg9vJCiZmaRIxyobNnVodemQr8Z2ZMm4kRFX3kcMr
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR19MB7669
X-BESS-ID: 1705955974-112236-12886-8903-1
X-BESS-VER: 2019.1_20240103.1634
X-BESS-Apparent-Source-IP: 104.47.55.169
X-BESS-Parts: H4sIAAAAAAACAz3LsQqEQAwE0H9JbbHZXKLxV+QKEzfYHFe4hSD+u1uoUwzDwJ
 sOKHuFEWrrDv4bjMgDt7W2sziSWqIWJdaSZY7Zsg8cIR4OZ/f4tf5uz/h65cS+kClh9B
 Rq1qfQJB/BQlkynN8LDqawSIEAAAA=
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.253686 [from 
 cloudscan19-201.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] Cannot find documentation or comment blocks
 specifically defining lnet metrics
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============5373541958422555255=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5373541958422555255==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_1817A78F4EDD48329859AEA980B32A25ddncom_"

--_000_1817A78F4EDD48329859AEA980B32A25ddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Did you try wiki.whamcloud.com<http://wiki.whamcloud.com>?  Amir used to li=
ke creating pages for LNet there, so there might be something.

Otherwise, I can't really help with the LNet questions.

On Jan 22, 2024, at 12:35, Jeff Johnson <jeff.johnson@aeoncomputing.com<mai=
lto:jeff.johnson@aeoncomputing.com>> wrote:

Greetings all...

I'm modifying a Lustre metrics reporting tool and incorporating lnet metric=
s into the data gathered. I dug through all the documentation I could find =
and looked through source for comment blocks and didn't find anything defin=
itive. I'm hoping someone here could clarify. While some metrics are obviou=
s (*_drop) others I would rather not develop to based on assumptions.

msgs_alloc
msgs_max
rst_alloc
send_count
recv_count
route_count
drop_count
send_length
recv_length
route_length
drop_length

If someone can point me to the document that clearly defines the above I'd =
appreciate it, so far I can't find any. As I said I don't want to develop b=
ased on assumptions.

For example, when sampled over a short period of time does...

((X_length / X_count) / # samples) =3D avg rpc size of X type?

Send, Recv, Route and Drop are fairly clear. Length and Count I am assuming=
 are just that, n bytes and IOs. msgs_alloc, msgs_max, rst_alloc are less o=
bvious.

Thanks!

--Jeff

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_1817A78F4EDD48329859AEA980B32A25ddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <4FB7F8E049AFD44795A6A463FC947C48@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
Did you try <a href=3D"http://wiki.whamcloud.com" class=3D"">wiki.whamcloud=
.com</a>? &nbsp;Amir used to like creating pages for LNet there, so there m=
ight be something.
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Otherwise, I can't really help with the LNet questions.<br =
class=3D"">
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">On Jan 22, 2024, at 12:35, Jeff Johnson &lt;<a href=3D"mail=
to:jeff.johnson@aeoncomputing.com" class=3D"">jeff.johnson@aeoncomputing.co=
m</a>&gt; wrote:</div>
<br class=3D"Apple-interchange-newline">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Greetings all...
<div class=3D""><br class=3D"">
</div>
<div class=3D"">I'm modifying a Lustre metrics reporting tool and incorpora=
ting lnet metrics&nbsp;into the data gathered. I dug through all the docume=
ntation I could find and looked through source for comment blocks and didn'=
t find anything definitive. I'm hoping
 someone here could clarify. While some metrics are obvious (*_drop) others=
 I would rather not develop to based on assumptions.&nbsp;</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">msgs_alloc<br class=3D"">
msgs_max<br class=3D"">
rst_alloc<br class=3D"">
send_count<br class=3D"">
recv_count<br class=3D"">
route_count<br class=3D"">
drop_count<br class=3D"">
send_length<br class=3D"">
recv_length<br class=3D"">
route_length<br class=3D"">
drop_length<br clear=3D"all" class=3D"">
<div class=3D""><br class=3D"">
</div>
<div class=3D"">If someone can point me to the document that clearly define=
s the above I'd appreciate it, so far I can't find any. As I said I don't w=
ant to develop based on assumptions.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">For example, when sampled over a short period of time does.=
..<br class=3D"">
</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">((X_length / X_count) / # samples) =3D avg rpc size of X ty=
pe?</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Send, Recv, Route and Drop are fairly clear. Length and Cou=
nt I am assuming are just that, n bytes and IOs. msgs_alloc, msgs_max, rst_=
alloc are less obvious.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Thanks!</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">--Jeff</div>
<br class=3D"">
</div>
</div>
_______________________________________________<br class=3D"">
lustre-devel mailing list<br class=3D"">
<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@li=
sts.lustre.org</a><br class=3D"">
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org<br class=3D"">
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

--_000_1817A78F4EDD48329859AEA980B32A25ddncom_--

--===============5373541958422555255==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5373541958422555255==--
