Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 49F45C27C53
	for <lustre-devel@archiver.kernel.org>; Wed, 12 Jun 2024 22:27:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W00Y12D1lz22SN;
	Wed, 12 Jun 2024 15:27:49 -0700 (PDT)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W00Xv0g3hz21Hy
 for <lustre-devel@lists.lustre.org>; Wed, 12 Jun 2024 15:27:42 -0700 (PDT)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2172.outbound.protection.outlook.com [104.47.55.172]) by
 mx-outbound13-133.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 12 Jun 2024 22:27:41 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=n3BLXyp6dC7jEWPbIJrr4x92+kCYSCs59Omls5DQ1urPiRQMCTBKDA0U6lrKFYo9FnVsa/+aeFMdt+7M2jOPMerIj2EV+XmaHy8RyrsvsCrx+7YwlhlN/61ahQxYwC6sH+vRylS0Il8K+jjQKY2CPMF6kwIrVfEj2r2/JqLNqBX1SDN9hY0Q0ITh828rF9iY85NjpJt8biG2hSwWbBzTLL36vliguGeGtPMxyZm/wnXooMEiwWRQxEXT71fnKhdDklPMnyMUG4uSZ0edo4aijYXVSsrF4CWJtcBdmlA4IRjHsX9niJqbyPX4P6KejUKVnM0xu9DlouNH4ICc2Eo7pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Ej9efq0PfMXCiMXfNFgPhPcKkdXsMa2k0kFe0b84NDg=;
 b=NhpndaeMRfcSmt1udGlgwN+oDUtMmm8OVe06kTWFiT38Ch6kh6mPfwgKgBqGU9+V41QdKgTYODetCcAuigEW5WpDeKaxizVkUuPX6LVktuTniC430ecEcTtF+iV6oq1CqlE48Y9X4zvvGMGrFDMwKHqAOx3rP07obVxh/epK/NaPSBOjTBj/lwF0KS0rlohAN4JjO8/y2S1dPY60wxehND4p1V350yuV6t3DNpbomMqQpC44e0T0jgXTCLg6X+AjLeBUvxqu1apYyTGYcjW18mEYLg7kSSe4Uges5NzDMj85I1DgeZEjHMv9miKVtCWxHcR6JR9cKvnNoAkntG8gJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ej9efq0PfMXCiMXfNFgPhPcKkdXsMa2k0kFe0b84NDg=;
 b=YHtOAT7F6lF2FvaO88NlmeDOzUIy4Rxh9bgXXalYrslx9nr7Wi01SSqKXLvHFHW9TYNxgHoa5A24nKpgvNl+QPgX6Ybm6EJ/SxwqbTc8j/i5UMSwE05ux65kT0B/BI+J/98OKxi9nqg1qAHKQjahwMHk592Bdjh9saviaT+XQns=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by CH2PR19MB4024.namprd19.prod.outlook.com (2603:10b6:610:92::22)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7677.20; Wed, 12 Jun
 2024 22:27:37 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%7]) with mapi id 15.20.7633.036; Wed, 12 Jun 2024
 22:27:37 +0000
To: Saisha Kamat <skamat1@charlotte.edu>
CC: lustre-devel <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Inquiry Regarding Checksum Support for Lustre
 Extended Attributes
Thread-Index: AQHavPd4erDY+MuQ20qhjIELCkzfDLHEtYQA
Date: Wed, 12 Jun 2024 22:27:36 +0000
Message-ID: <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
References: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
In-Reply-To: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|CH2PR19MB4024:EE_
x-ms-office365-filtering-correlation-id: 5fde323a-c0dc-4e1c-8b48-08dc8b2edcd9
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230034|376008|1800799018|366010|3613699006|38070700012; 
x-microsoft-antispam-message-info: =?us-ascii?Q?BR4SeufbItWaMd/wWzyKqQxxODnnRtv5mAFoEqveYGpp3XhM/LxqvR8x25v/?=
 =?us-ascii?Q?ryO4ncsWC1JZ8cTWjl5miXocGIq9wPKCn86Qm36NWbfMLpnWDPjrhxlw+z6o?=
 =?us-ascii?Q?q5JtmjXnEviTapBQfBcGRGkaJbppERBWXlwdDWCNOgajUg0au9fA8EOp6E4O?=
 =?us-ascii?Q?LekSNYThCxBsOUc1YznpC2llTOMq0AdXlswgEQUtfPvuY5msxoXUIjLDV6ee?=
 =?us-ascii?Q?pmdAFp/wtouSDuOIIveJurvlDPM9miB5zRQ+m3+yBF1D1jjb1rWwDiCpTdbB?=
 =?us-ascii?Q?H6QJstXm2fdlQ612bIcz54NEHgI/FcpiNwqWVsPOiqdhOPWeyu0FgIbPDBJz?=
 =?us-ascii?Q?lt/PEAbqG6SVr95dypAWZCPCbrx/mdHFBE5Y+gefx3MB6PKdx9IMVlOSw93a?=
 =?us-ascii?Q?yvuOxkDBD6uYw1w4JzZOspZ7upV3C8xuHLOMhH1qR0tcCJLMZi08u6RNzRg3?=
 =?us-ascii?Q?LjTAuaK0ydzU2/ed5UHSOwvmCjvJOj9/xCJpnHr8UI7Fj2EG35hYxkRYhoK/?=
 =?us-ascii?Q?WC9kXADEkD2EWEfGP5KUiqo7/5DiTJKK1131slW6SREtfDvqw8JUOoRPGWih?=
 =?us-ascii?Q?KxGHBBEleUBi2tDWoY2UQ2vZ+rpxvStWsRPoGiQOI1FXTO5MheyAr6PufbDN?=
 =?us-ascii?Q?9XijNyZh9DPMD9/UOGqMHSXVIjlxRDDf0X8NkmHpPEHrHssA0KnVvI6zy9J4?=
 =?us-ascii?Q?huE669PFfWcyYHR+tUY9OpMDQsKTuASiVqmJISEIZurtNQ/yw7J7BRU4XWZG?=
 =?us-ascii?Q?HqTJGQB4WPr6c2wNQ7Nyn7xpP1g1axhH60Kf7XN/8XlHfoMsaroNz2OKABmz?=
 =?us-ascii?Q?Rw7haom+lt/82i/WG03y3h75BK2emh2BBebC7KYjYDyUSpSdZ/wzSEsFTcDe?=
 =?us-ascii?Q?UN5U7aLGQydMhVZGYkg42w8zCpenhoNgBdkAnjK8SLVNV9M/AF943GVQ26lM?=
 =?us-ascii?Q?NHQIPonKdcfXGt+fpyI7IzMMzleIEBEVgt7Rx06SKGAxF72fe6qMBUVOpTPt?=
 =?us-ascii?Q?YqLB1dnoZc55jhkNAVy/6jjEOONJjv7DigC40jxCzQXjpr1sltugxroFm9T9?=
 =?us-ascii?Q?usIxcMQ6Pp6UOPId52lRn5dDmYTQj3252506SeT5r8IREjfYFGlFCqJKB+gn?=
 =?us-ascii?Q?uziaxLpCHCb7I8mGFMiiEGT3nWY5m0dmEMlaiXrjujOawxUz2WRZcYUSMjUu?=
 =?us-ascii?Q?tzcyGsAkosLyoW+MTjYfa7gvoatbW7oqL78xoPxnyygc9K61GLSgIjYaR/eZ?=
 =?us-ascii?Q?KzdVRpKr1c1hKnejsMqsjA6iSJ76nHCxs1gdpG5ult5vqkfRpiEpyT5Gpdz4?=
 =?us-ascii?Q?yjXGLN9D22DPrMe1/Lh8i7+KKtAAzgaHxZn1/C7IEBjhWw=3D=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230034)(376008)(1800799018)(366010)(3613699006)(38070700012); DIR:OUT;
 SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?k2lGx98VE0IDN2OBXVD4zW8og9W8eY6ImkINRalF9cnra5Zm0eh62jhg2QCi?=
 =?us-ascii?Q?BWF3+8wEtFvFq8GOC+47llo+olpnkYvt76kO9L3Ktf1kubilFGJBrS9ms4xo?=
 =?us-ascii?Q?27q9cRvUtGDzmWtNjQbYnzt6UoZlAfydFYQ/R5aSNls4e8ZRme+7I4oyQ51/?=
 =?us-ascii?Q?RB/HbK9O1+49TDp/R5nYyNgNg6Rm741EPHwfWoPiwWAMYkI9WV16DaGDQef9?=
 =?us-ascii?Q?LTnMsVoGv0fiHrXEE64B2AQ39DubJS7Zg1+mRlgCJSf6hFuvRcIuoANcI1jr?=
 =?us-ascii?Q?z1/xhyvUQhpYjbJ6+I1eYInkhDbk5Dp8O29YDGjfRYbSU5Jvhw2OsL80A1S5?=
 =?us-ascii?Q?Rm0C1EtDUmh8AQ27vQrHphArtkERWq15eBcFtM+X/WGgvUHQjZwKxa31nItt?=
 =?us-ascii?Q?JrxS6slNl3N/Aiaiqs8HGOiyY9FMXL894p85m+52vfLpjdO2FLDLsSgmyeJw?=
 =?us-ascii?Q?dAc3QokWNzd1hEBLZTNtbyVxkThMSZmr/TKQTSDeeoh5SepNrH25iK5Dr54y?=
 =?us-ascii?Q?u7HltMRmFDyVprqZl/toKdxf+LTIDx63gpL3BAN/nEOEHfP2h29hQhJTgp49?=
 =?us-ascii?Q?71TjMO24D5WiN+wku40+TvzsunMPW7Cx0xjbFipuNAJUAC9xxFS0zu2VjkaV?=
 =?us-ascii?Q?PIdT+QiqesDBLyf3Bg2gIrpcs51Y5HUhtVGaBh7KslzSVQLwdKTg7sNAEak4?=
 =?us-ascii?Q?zn29Tzgh/DvGbWKlFUGNuRWRpr+Bueg3mZnjs7jeR5jLxT+Cc743KYxja18y?=
 =?us-ascii?Q?qqhZxRQZrW4qu0PV20H53rE72YDs6aq7atl2wJwsV7qOCFNZBlbVD+QXyZaC?=
 =?us-ascii?Q?YyBIA9DW2kiqcGD5UH0WzhECXDF7Li16BDG2/322fgnPsvi/cm1uRRX4d856?=
 =?us-ascii?Q?rWrd/QdEyPBMquWVAeo/uUqZMs+IoEdutzRgWOd8TYUD9TDLPtqLAn16TQQn?=
 =?us-ascii?Q?UqC3Y2nRSrO2c6xszZ4vLD8CpIJ87mVyt0Duib1Jdw+4mvlTKeCw0UgjXz7j?=
 =?us-ascii?Q?i9MfoxqKNnrG7IpYIlxq7cwhl2tVWSR9rIcVD+CtpzdWXUdTT5tFDuqG/BvS?=
 =?us-ascii?Q?D6xCsyJJm5JOVMRm1v+fG7YdmmKOVsYhMTju4tKBQ4d+wdZT1kDvbL9VKof7?=
 =?us-ascii?Q?YV+VQ19RUpBYToGhjaS84bUTOg5tcrhBVqWTZv1+2BjiG8wuxJ1LfYXImbdC?=
 =?us-ascii?Q?cD4pqFKLYCepeR8OL54N0MQs54ucCqVLbABnU1sYiwcbMifX1qD8+b/a3fzS?=
 =?us-ascii?Q?a+Y0mUpvy0L7u+w14tH7tQtt7pjHn+XN0t0ef9HLchcLAgkErRM/bVYz5AUd?=
 =?us-ascii?Q?5Blk2gix2KtoeE+8dBw0DBVB4ehP9RioDHa+gBv27VfE/B/aQra77/s1yNVn?=
 =?us-ascii?Q?VdvRRreV++5vXi+FJlli+8miSx0HXQyC3TI4bSaK3zG9r7DTuMMBkvA2IF9g?=
 =?us-ascii?Q?hPgVrNMZ+d5WF0gSUXG+TF64dlgU5a7NT/1kk9EfCyvooxbuKzT8zOhYMVdp?=
 =?us-ascii?Q?a8WDhk+iJD4MZ44tDJr29w26euZIwYw9tiRn7thMygb1U0ZvmTOYhEQQlldH?=
 =?us-ascii?Q?dicAhYyb4qfzX0D7Gz2i8+2Z6hv6leqaRcmLOM84?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: CBlbZQJbti1UHvZ+t+oCE9G65sFsBJSDLZJViuedcK2icIi+81gbWEzmapRP0CcvmPHKPbCwpGXbfcfTt4XWwVdxy0OYEixM5gBhsddF8fx8QZFAAbZVkX6e0SyBgVX0O9/WomRBVBfgWKRQVqgpK26rY3bTU+OdEf84JzIY4dG8/1fEiLgg/R6HDmhjTgl6BIGEcRPTfIJTl/Q3/BWkmtw3ReXiyQ6IHeCUZVNGglqxAfiOqj6wx54CfeRMMv4H4epfpXmYK06QIu1eyGJGNhnSBJi55ifskXeZrU1/Ypd/iLE/25XpS6j/D/rHMYSjOkVhSKjJ33hiMjKoin0L2yPkKBQqJ5UnkvTI62/XjbOTzHPhRWLp/4i92mNwDxEpb9ujzxpyXT0HZDMIiO4XcknIOHiMnV79SdDDvdf/rMcZaSF9Osvsr8FidB45TQGT5vL2K3OhP/YpX6E91XRQQyA8kXbLICMxwKMX80X6g8QLhTFaXN/n8+KrjWXKRltHhZU30Gg8f8DpXTTsYHLf+zafd5STHVFpEE+LlfZc6dmFY5XjxiDvjHW5aXLsGoxazN1nZRXD5rpPkX+u4AOvqYaHkMrxjEXeXq8J0i0wj29HZSGqA0sZKVlsXMK3Skj1F306FTSt/3ajl6SnbjSxD+nhPz8JakhxYpx0e4RsrEg=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5fde323a-c0dc-4e1c-8b48-08dc8b2edcd9
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2024 22:27:36.9407 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: d4v54hygTEfNQCu+vhkr35bLrkuTXdeJYTuanUdrbHNWxW5Ld+6/T1WPJAMGYfZM
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH2PR19MB4024
X-BESS-ID: 1718231261-103461-11267-40138-1
X-BESS-VER: 2019.1_20240612.1610
X-BESS-Apparent-Source-IP: 104.47.55.172
X-BESS-Parts: H4sIAAAAAAACAzXMvQqAMAwE4HfJ7JAm/Ul9FXFoTcVFHOwgiO9uBl2O4+C76Y
 Z2dRihWw5wnDASJba22Vh1IRTSVjLxmjxSrog5slPR6gme4fdb3z8fIsvnuUkJS1IXy8
 qVxJDdZS4+JNTg4JlfeLAw0IEAAAA=
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.256911 [from 
 cloudscan9-138.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] Inquiry Regarding Checksum Support for Lustre
 Extended Attributes
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
Content-Type: multipart/mixed; boundary="===============8794817485041377593=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8794817485041377593==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_D862AC2B4FFA4F82992F246E24BF4C72whamcloudcom_"

--_000_D862AC2B4FFA4F82992F246E24BF4C72whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel <lustre-devel@list=
s.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hello,

I hope this email finds you well.

My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.

My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.

Yes, the ext4 (and ZFS) xattr values have checksums.  No, the xattr checksu=
ms are neither managed or verified by Lustre, and only come into effect whe=
n they are passed on to the backing filesystem.  Conceivably, it would be p=
ossible to have a checksum (e.g. crc32c) for the xattr values in the MDS_GE=
TXATTR and MDS_SETXATTR RPCs, if this is something you are interested to co=
ntribute.

This could probably be done by overloading one of the 32-bit fields in the =
mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but there is =
also "opportunistic" xattr prefetching done in the lookup RPC, so that woul=
d need to be covered as well.

Also, the checksum would also need to be kept with the xattrs in cache and =
verified on access, otherwise they could become corrupted in memory after t=
he RPC processing had completed.

Finally, there is no interface to specify or verify the xattr checksum in t=
he syscall interface, so there can be no guarantee that the data supplied i=
n the setxattr is correct, or remains correct after supplied to getxattr, b=
ut the window there is very small.

Cheers, Andreas

I would greatly appreciate it if you could provide some insights or direct =
me to relevant documentation on this matter. Any information or guidance yo=
u can offer would be invaluable to my research.

Thank you very much for your time and assistance.

Thanks and Regards,
Saisha
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_D862AC2B4FFA4F82992F246E24BF4C72whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <C317AF2B4AF9924DB3C2EAF6BEAD800A@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel &lt;<a href=3D"mai=
lto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lustre.org=
</a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hello,<br class=3D"">
<br class=3D"">
I hope this email finds you well.<br class=3D"">
<br class=3D"">
My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.<br class=3D"">
<br class=3D"">
My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Yes, the ext4 (and ZFS) xattr values have checksums. &nbsp;No, the xattr ch=
ecksums are neither managed or verified by Lustre, and only come into effec=
t when they are passed on to the backing filesystem. &nbsp;Conceivably, it =
would be possible to have a checksum (e.g.
 crc32c) for the xattr values in the MDS_GETXATTR and MDS_SETXATTR RPCs, if=
 this is something you are interested to contribute.</div>
<div><br class=3D"">
</div>
<div>This could probably be done by overloading one of the 32-bit fields in=
 the mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but ther=
e is also &quot;opportunistic&quot; xattr prefetching done in the lookup RP=
C, so that would need to be covered as well.</div>
<div><br class=3D"">
</div>
<div>Also, the checksum would also need to be kept with the xattrs in cache=
 and verified on access, otherwise they could become corrupted in memory af=
ter the RPC processing had completed.</div>
<div><br class=3D"">
</div>
<div>Finally, there is no interface to specify or verify the xattr checksum=
 in the syscall interface, so there can be no guarantee that the data suppl=
ied in the setxattr is correct, or remains correct after supplied to getxat=
tr, but the window there is very
 small.</div>
<div><br class=3D"">
</div>
<div>Cheers, Andreas</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D"">I would greatly appreciate it if you could prov=
ide some insights or direct me to relevant documentation on this matter. An=
y information or guidance you can offer would be invaluable to my research.=
<br class=3D"">
<br class=3D"">
Thank you very much for your time and assistance.
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Thanks and Regards,</div>
<div class=3D"">Saisha</div>
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
</body>
</html>

--_000_D862AC2B4FFA4F82992F246E24BF4C72whamcloudcom_--

--===============8794817485041377593==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8794817485041377593==--
