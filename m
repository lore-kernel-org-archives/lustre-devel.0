Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A9635D5D688
	for <lustre-devel@archiver.kernel.org>; Thu,  7 Nov 2024 20:06:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XktNp225bz1xP2;
	Thu, 07 Nov 2024 12:05:46 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XktNS4j3Cz1wfJ
 for <lustre-devel@lists.lustre.org>; Thu, 07 Nov 2024 12:05:28 -0800 (PST)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2172.outbound.protection.outlook.com [104.47.55.172]) by
 mx-outbound46-46.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Thu, 07 Nov 2024 20:05:10 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=bxevFS+9lQhviy8cyB2F90ZxSgqDEgV7nUdg7DEEorSas0n7g5+wTlSNhVSNFy7KPEzJBNt+HyHKHxPN03hYxW6fdR+fufQw62unGbicSc7uj/9xk1SS+Lh7A52aML39QeGR+GUXNZ/j5zeSFijErk0LTcz1zoClM8Kjs3NBsodXLF8rmyvFdnPoZzAaQz/Q7FRpy/D0w/wcL14CiGXfb04+YFopv30PBVtq1QKO690+L4zf1Bnpea/CE5Px4i3AFb2gP8mSp79eO1GXQ9kHmF1Urh+2kJ2QUqTEa8EKcxE61fD6KfODzdCWpMpM9ln56LVm2AKCFGK7mpKcYvRt/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=YJjbgxwpn/fOY+/DQzIogy5gr08Cv1gjpAgvmIafCV0=;
 b=BnLaRt6KuG9Yn/VAXWaeb8rQX6ZZTcU/nZ3rwr1LZuyRN7ZL/rv8Fg7XZc0tCcflN5KM4X+J4g27y26pXQo+4ZVkGqfR6lfcxudLuGbvVUHSnb0yKu27yZjZJPSJL2/fv9q9TRNagFCRpjnIMSDrnaITe77UWRMC98tjwQV6EWjbDWxcQ3OYqRVOQGGrJxeK4RW4VmvzvpT0yIkacsmvb+4RlMw+wxzb72rbnqpZKu3C2bmPGQt6dSnq5t6JMXzkI1XBJRSEAPZlkJUMeX2H2OnINZhZHAaVtnkxGyVA/zRTKd9t5siKyG7JqI0hLvH0mptVd+zD8LypMh9oQ/E1TQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YJjbgxwpn/fOY+/DQzIogy5gr08Cv1gjpAgvmIafCV0=;
 b=ycmrMm7OoTruabrxYag4X2aGSg0xksc5qm6KzoqDcjilUtJAjWkmE6tY5UDrAyApwnottizQtw9EvCcsSSQtvHLmCrrGMG/gR6wMDmDKNZaAdDnqyUAySzD7DV+X0UfDBNZmx7AkD1kyVSUF5uKZ1XKK+r1M7pKP8CSMDw9xKRw=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by IA0PR19MB7678.namprd19.prod.outlook.com (2603:10b6:208:402::11)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8137.19; Thu, 7 Nov
 2024 20:05:04 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%3]) with mapi id 15.20.8114.028; Thu, 7 Nov 2024
 20:05:04 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Else Someone <else@someonex.net>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Ldiskfs: kernel version triplet policy
Thread-Index: AQHbMTktxg9PJ1o9xESTCy65tBkX97KsPjeA
Date: Thu, 7 Nov 2024 20:05:04 +0000
Message-ID: <B45BEC04-A37F-466D-B12A-F865B4B5B1C7@whamcloud.com>
References: <7da775ec-4884-4059-ad00-d591166a32ce@someonex.net>
In-Reply-To: <7da775ec-4884-4059-ad00-d591166a32ce@someonex.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|IA0PR19MB7678:EE_
x-ms-office365-filtering-correlation-id: 95b1b17a-5d5d-4755-2f34-08dcff677820
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|376014|1800799024|366016|38070700018|8096899003; 
x-microsoft-antispam-message-info: =?us-ascii?Q?HWsrP1/ZTYgTvVAD673yALI0QAx2+b3TXi5+Z/oSIyofMo5Y6qtpLtBz4m8n?=
 =?us-ascii?Q?qDs+f9Hy9hmFTiDOPnHHodk8UBab648yxteuMs54GKtRguSmFZJgtwWiXtoz?=
 =?us-ascii?Q?l04ogA4bnSqignlb2RM+GWyutvSvC8PB/xRNxwvckVj+ClXJLQyuOdlnDNEl?=
 =?us-ascii?Q?puNysQ9d8aYr47sDLGvfNQe0XGYGlfqE3X/ZmVBTCZDteFNip6QMAovpQw+b?=
 =?us-ascii?Q?XlCqA1DvvEzEKtiC6TJSsug4eUdz9qcdfo2NI2JU6X2LLBSG9Ie4Lpkm1Ajv?=
 =?us-ascii?Q?xPKBWP4kLuuQWyUB1MExXczpYZdNFq23LuB0nj+6UMvRp33DmgmAyB88rS10?=
 =?us-ascii?Q?xZCWAWlgyleJRi05PyjCuf7s4y/rybK3fsVy9fAGpwqIjEvg3l6Ca7pZf5gw?=
 =?us-ascii?Q?5bhoe5qqZxJzAY6AttQz7TTmBeNsYsBpGhSu3WKhMMCxmlSqqzDtJHp4mqkW?=
 =?us-ascii?Q?MpGsrLDHlvsfXe/+hnh/d3K46HssJSHwYhVKe/AMhTPFKN4px/TeFoOJ6KXP?=
 =?us-ascii?Q?IxSgPpdEZyl0sERQU7gNZfMSdW7YdeTdwzD37xzydC4meNDg1UdtuAD9SN/E?=
 =?us-ascii?Q?ioBqcKEoz5vwDFCNF4L+Ag2Z3qgGHxaXfQqh6tn/Wm7+5+O92FdRai4BOBta?=
 =?us-ascii?Q?hdEC1gqg9MiV/jOtyDvd8655UBfZ0FxwG+mc2hyJBfneHQOTilmccuhnciZ/?=
 =?us-ascii?Q?VPCEl+cHdzh1jztQ45pvM5IwbH6DyRQ+9xwWsqSsIh+yDRMt3521Mfl+cDNt?=
 =?us-ascii?Q?AzfvcQEZtVRoB5C6x/1YRV9aIp7rmx/kGbKU156WfjRZhyj3Yn+UKVOIMugu?=
 =?us-ascii?Q?Sr8Pkc/u1znZ9AWpXSOM/v0t9+vQE0ua4bUQGVheilqKtSocF+/+WxSN0oef?=
 =?us-ascii?Q?lNu4H0fev/T4dRk+KSyEWUN7n5qPa92W9x8pcCBFstGCvJziQHyFpLN0IpiT?=
 =?us-ascii?Q?gr2lgWQHw9ec/4d0KNKlWvbK4/qghv2yE0OJP878b6I9uhDR8PUfgxnuniVy?=
 =?us-ascii?Q?tRpT9noFqPrQW95PINC96ib8L1t/KZ/CTK7ZFWDaaL3y6l3sGefNYpI/vsR2?=
 =?us-ascii?Q?xTG/WdMwtWzrghtk8UVzvSXMuh19otfMz80huNXElXpihf3gDwZMQum6kwPb?=
 =?us-ascii?Q?C7slOQQLLC+X9kD9cLeumUGfobwbWom+YWRR3SfpubZeuUcYxo5mg6BYORM7?=
 =?us-ascii?Q?75mhZxeV3Veo3kffofxff994AXdO7bTZ5+ZqCt/En8JCh4OAYjLKJFWMeYF/?=
 =?us-ascii?Q?kVEtJXZqnzw0uHP885KseRoFLsZVEORVAeONsvfFyHgOum55zC9dqmCeyfQX?=
 =?us-ascii?Q?LKwgoswE0NRsIn7JVbeGaUs+?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(38070700018)(8096899003); DIR:OUT;
 SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?oWLADS/PUB12mxN1fQJqwsifE7GY0QE/9HDrIsYfN4O2q6WHVT93Iy1PxJC7?=
 =?us-ascii?Q?Acnt/M/GSeBrlAJxtLeTpRoCqp2MzKeNywk/y4Kq41j0S7l+6rE4NKP8CmsL?=
 =?us-ascii?Q?VdsstM9NDQDlMKeeED1ygus5wjiA7glWepVwCIfxq9vQirLTWqIxU6G7CRDC?=
 =?us-ascii?Q?vGMOPOWtmqIzxv+7OJ/6OjsdDJ8LcA3JyfnEOTZxa3nGj8Zo1E7ShV0RM0PW?=
 =?us-ascii?Q?WO8S/R5u2mxtC5WlbcOS6pZVHyv64wuPpcNaQI88G6BvmXc3qyJJam6A+Q+J?=
 =?us-ascii?Q?RHry0WqinV/iywk1pmmjkfUfYi1b9/WCz3sp/peg7lJQIfGk8Ao0NdZyco/B?=
 =?us-ascii?Q?gQNZw+xSOS4iPyUz3TKGGOK/SBwN/vvE3ByyPQhGufCKivGU81l/eUQoUZQX?=
 =?us-ascii?Q?n+gDllgfoF+VLK7XsC3uiL9a1Z4w9QTupn5i71T0SpLB9gg/Ifg+/XQsrOoC?=
 =?us-ascii?Q?ZYU2wTQ7JjczyGHLl8lhseU1XQ6wp+o8SMh31B/MnO68sYqQcpomV42AO2tl?=
 =?us-ascii?Q?oYqDbE6iJtLHo7usGhP5Ul/+IUS4CjluRK4/40wTb7z6XocuOBaQaGtRpj/A?=
 =?us-ascii?Q?MtUmBhil6z0HyLIFU9LrNgIaG+VX+lwPTvYEdg1ZXX8gCqa0bsPMSfrBlAuw?=
 =?us-ascii?Q?OLgZ9/WVEGJ6WuQc0yajU1AdsZarqIFlVkKIf3/2zC33YNAUp1vSeIkVTvkL?=
 =?us-ascii?Q?w4P3vpGpY2OFer8OU3ArMGRM/51kg9F3i0tUYondbAX7xdknCO5txjBqxM00?=
 =?us-ascii?Q?9jUA17E4LPtrdU1ImWxdlbIOFh3U2yirRqdHY0uCPQCbhTz5HBAtR7hyX5X2?=
 =?us-ascii?Q?e7oa0NsqpIsUHaGxbvkFf9klP0zKnH3gVSmzzcsF+xGQ1yrpV+B1pIoc1pWg?=
 =?us-ascii?Q?IvgY6NsucagRloB/2XnT8q1iuUbCVzMvIOEAVPjk/207OWMs0/jErhhMlKjU?=
 =?us-ascii?Q?XM2EKyFedmgjtiajo8ZmtfQm/fhrwrof9ljwrEjziIOEMt7ek9YtoA8+ZY0P?=
 =?us-ascii?Q?ZHVZXrCJ+m6bdcqN7LuFM5TYtCkBRQIfIYSR0nJ9Nd6X4c0zXMdmxf/MLKa4?=
 =?us-ascii?Q?QMxsd4KOhFhmKuA+L2sdnJ6v7yaxh2cGSWiVPi/2g7mRAiPIy6o1w0hdrKAj?=
 =?us-ascii?Q?i8LRo6vyGsmAFmSKzAtY4OhFS9RyaMsPoyCQQpo1JDLcy6Oq8ep0Pw0aBaBw?=
 =?us-ascii?Q?j6p6zjhJMGciDhF7ls1ImwSn2Vlkc1dOyEzi0iUdRmzzvUc/31y1peKlYIy5?=
 =?us-ascii?Q?Pky9tEghehRpi5swUtL2+DnR/Scl6fMCRjWLEi/ts0Cj2WeBSf2yR9ELNja+?=
 =?us-ascii?Q?gTgczHvOFFZAuMrS41gRJAwa+KoMHg7DMQEmT55gVbRY1w1pVMnswnrS8Jtc?=
 =?us-ascii?Q?SYb0Vd9Skm6nljkAlHqhqlqPUEsoukYdpctuuCGEctkRfgoHTd6zSWW9zwv7?=
 =?us-ascii?Q?58kTg41rljElMOQKUZR8ki18i5UrgEk3OOKXI1NQPJ2KVAxj64sl6pBKKBQE?=
 =?us-ascii?Q?xbi72PHHQTqtF9sEMrGDsy8L+MAp2RlGojbjCixnZHtgzW1A+sQRJom4WJvC?=
 =?us-ascii?Q?vUuFmRCCeoOoQ6wkX50uwg8gpKtahrvHIjOmTN6u?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: O2zUhNmNXQtAVBodcxER5BR6yz+RwPmYKjd6X1LG5AbzCgW64TVbSBNIyCA/v/xKz8tXA7tfGubAcusTeRXLzFd7PBv0OzrxkYCP7Ud1LrW8UO8sMWWy+FtODS6989obY5oS3k81h6+KMvMCN8i7qUwcjWvIg5bCOx8YxGUJa4ACOKosYIUrvq00CUUeADvZxuOJ4qM3Td5gcfDvGFLBPDZ/etgCSPszLohLM0QVGRBwU9xYHTiNbjdpwYa4bpI/cAdy6xhCUnHZB5CSDC9LnP9hCF8Om8hq2ZzGxOtwTCc9KC9Xh4IKQas5bZDitV14OX2GX4wtPkSEuwWP2nskKRvtsVOh+SyZKuueMhiVjlHTY50ARYtqHe8a+xbhnMS4URLdLIKWnCPTMaqaAWeGzGElbc7bLmVBxyMvq8EGRXibUBNuoLFB5mxrUa7TkvjlaZTjmsbTj/5o1X2kTYYVUHB6YDGA/J+tTQjYFppF70XtVahVs2WT5vDXoR30sctj2/5RF0MCJTb7fUUBeDbmYGMuvaIv8i3U/KnMCt2O0ta5y59/MGmvnapYA8oWqkgiO+WTEsLcdsDV2TXdICeprzC+FbnJKDAbxIqizFBY7F247Sp3PMbF1MFdD45hLIkMjDTbCm+RSHQQ1u+ASJvAJA/s7wSpTgNG8CWwmu7+lAE=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 95b1b17a-5d5d-4755-2f34-08dcff677820
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Nov 2024 20:05:04.1553 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DhitJCZcQKpvpQv8BFAqwjCY8SOL/ugLRDwOTBhTk8EWTgdpluMrhQ2VdTbSB+be
X-MS-Exchange-Transport-CrossTenantHeadersStamped: IA0PR19MB7678
X-BESS-ID: 1731009910-111822-7342-719-1
X-BESS-VER: 2019.1_20241105.1725
X-BESS-Apparent-Source-IP: 104.47.55.172
X-BESS-Parts: H4sIAAAAAAACAzXLsQrDMAyE4XfRnMGy5PiaVykdZMkhS+lQD4WSd6+HdDl+Dr
 77l/pn0EZj7kKvN20silnHPDnQU0J4X038BtHG1mqyPVUBhM7l74/xvLxqqZfPysgie2
 Yp7lmsFSAiMkN9NaPz8QNIhM/sgQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.260271 [from 
 cloudscan22-41.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] Ldiskfs: kernel version triplet policy
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
Content-Type: multipart/mixed; boundary="===============6640372030994295620=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6640372030994295620==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_B45BEC04A37F466DB12AF865B4B5B1C7whamcloudcom_"

--_000_B45BEC04A37F466DB12AF865B4B5B1C7whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Nov 7, 2024, at 10:18, Else Someone <else@someonex.net<mailto:else@someo=
nex.net>> wrote:

Hi! I've been looking into building Lustre using Nix and
[Nixpkgs](https://github.com/NixOS/nixpkgs), and I plan to upstream
Lustre support into the distribution in a foreseeable future. One of the
struggles so far has been with patch-sets for the ldiskfs module: in my
case[^1][^2] the configuration script selects the `ldiskfs-6.6-ml.series
` for the kernel version `6.6.57`, which would not apply cleanly. The
way I went about this is I reapplied the failing patches manually,
copying them into the same `patches/linux-6.6` directory, and editing
`series/ldiskfs-6.6-ml.series` in-place. The same patchset I've prepared
for `6.6.57` does not apply, for example, to `6.6.53`.


Seeing as patch series are named after major versions (minor semvers), I
wonder if the convention is to keep patches in sync with the latest
patch version in the release? If not, what is the rule? Would consider
accepting these updated patches if I were to submit them, or do you
prefer to maintain these by yourselves? Thanks!

Typically it makes sense to follow the latest upstream kernel version to
follow the point releases (assuming these are upstream kernels and
not Nix-specific kernels).

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_B45BEC04A37F466DB12AF865B4B5B1C7whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <AAD64005C61C8D4BA61E921947DD62B3@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Nov 7, 2024, at 10:18, Else Someone &lt;<a href=3D"mailto:else@someonex.=
net" class=3D"">else@someonex.net</a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div class=3D"">Hi! I've been looking into building Lustre using Nix and<br=
 class=3D"">
[Nixpkgs](<a href=3D"https://github.com/NixOS/nixpkgs" class=3D"">https://g=
ithub.com/NixOS/nixpkgs</a>), and I plan to upstream<br class=3D"">
Lustre support into the distribution in a foreseeable future. One of the<br=
 class=3D"">
struggles so far has been with patch-sets for the ldiskfs module: in my<br =
class=3D"">
case[^1][^2] the configuration script selects the `ldiskfs-6.6-ml.series<br=
 class=3D"">
` for the kernel version `6.6.57`, which would not apply cleanly. The<br cl=
ass=3D"">
way I went about this is I reapplied the failing patches manually,<br class=
=3D"">
copying them into the same `patches/linux-6.6` directory, and editing<br cl=
ass=3D"">
`series/ldiskfs-6.6-ml.series` in-place. The same patchset I've prepared<br=
 class=3D"">
for `6.6.57` does not apply, for example, to `6.6.53`.<br class=3D"">
<br class=3D"">
<br class=3D"">
Seeing as patch series are named after major versions (minor semvers), I<br=
 class=3D"">
wonder if the convention is to keep patches in sync with the latest<br clas=
s=3D"">
patch version in the release? If not, what is the rule? Would consider<br c=
lass=3D"">
accepting these updated patches if I were to submit them, or do you<br clas=
s=3D"">
prefer to maintain these by yourselves? Thanks!<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>Typically it makes sense to follow the latest upstream kernel version =
to</div>
<div>follow the point releases (assuming these are upstream kernels and</di=
v>
<div>not Nix-specific kernels).</div>
<div><br class=3D"">
</div>
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

--_000_B45BEC04A37F466DB12AF865B4B5B1C7whamcloudcom_--

--===============6640372030994295620==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6640372030994295620==--
