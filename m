Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BFDA0CCFA04
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 16:44:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1DdX5Mzdz1yDJ;
	Tue, 04 Nov 2025 08:37:36 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4d1DdL24gSz1y4F
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 08:37:26 -0800 (PST)
Received: from DM1PR04CU001.outbound.protection.outlook.com
 (mail-centralusazon11020114.outbound.protection.outlook.com [52.101.61.114])
 by mx-outbound15-122.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Nov 2025 16:36:24 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=a+iFeKC7UAMOYiUBej8U0WUZPBsljBUPjpJVg8Heoll4UkW5NLUnoqwr7gAiSyBQXYaq0T7PO+DoAuGcU9aczryUX8BLVi8H1ECqz+9pd37R1iVpccgADPnDshqKXlYyUu5SThMj6s4zqRusR6Q4RjjU8LAetvkeFw86NyCMSAlwx6pGiskvDJmL1cwcxAOPKEDejc5nehSvMwD2I79svsOJHwBVI0f+Qi1L/SIIMr9ngPdkIedQQC2u4hh3yCyCFqpGSXD0vIW2l+G2iwrpZ9dyCdMxbXv85365gdNKDiuknYx/ooOx/jhM0bgwVNZg2+FY9jUeaJEYsJYZkT53yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ic2N88QkrM/CQ3kT0hYnm1hDlcT32vjjgM1to8QRvTc=;
 b=RqcBJvjEsmUmRfmWsChb+88KlSE23iqNYSMHk+mHllnmNs2Qo5aSfTuZiXn9Qyl3SvLvFQJYYms7QxDCA3v8321MAZh4Gn8xv2H4UkloB3wPXoACbTjXlTx5yys4CsHopn45U2BJ3uRAlEhRFyhIOKRVAvcsXbf09lFmhSZwzEYWrHzinrfGjf/CXe68AgUklnzFBESj9IR6jDT2I7/Dt2BS2EkztCSskHGmcSGHlxO6f/ulCerZ0boLzu1BaG0PK+veHUsBYYU1I8HyU/b4+zdX/Mx1gOlUD0qYrbNanxd/z70dmZ2Y1Ng/Foqg/OgeeC1hAEBySP1RaRg1adTLlw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ic2N88QkrM/CQ3kT0hYnm1hDlcT32vjjgM1to8QRvTc=;
 b=IobjRuL5BTgy2JfOsAPbJ9zUxUATuXa3HRwqr7EkyOG8Q2Fw7RbSVteYMx0K0CPWdKX2CJTH32/KLt4Vp9crFbWs5lReHyLA64zoaEukUjlGI3Kh90Mt7gvmvpWVonj3PzMldCi9DSHc60CxZ80D2BX2hCMUJFzYKh/xwNTB90U=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by CH4PR19MB8562.namprd19.prod.outlook.com (2603:10b6:610:231::14)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9298.7; Tue, 4 Nov
 2025 16:36:13 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea%7]) with mapi id 15.20.9298.006; Tue, 4 Nov 2025
 16:36:13 +0000
To: Oleg Drokin <green@whamcloud.com>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTE+oyTsUrj6dQkiChGfZaurnlbThgYYAgAAVJgCAAA3RgIAAAycAgAAFFYCAABfJgIAA9RKA
Date: Tue, 4 Nov 2025 16:36:13 +0000
Message-ID: <54DC145F-B965-4B04-8B03-473A845892F6@ddn.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
In-Reply-To: <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3826.200.121)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|CH4PR19MB8562:EE_
x-ms-office365-filtering-correlation-id: bf94972b-8df3-4e56-9aa0-08de1bc044ba
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|376014|19092799006|1800799024|366016|38070700021|13003099007|8096899003;
x-microsoft-antispam-message-info: =?utf-8?B?YXZ3MWUyTXBaM2ZOSklxQU00c2dva3VqbnJsZTZSZVpLVmtxZ0NSNm8vdGpW?=
 =?utf-8?B?K0loajNYR2orTytzYzJRWVJNbVNpbjFWUFZDVGtnSzhoeDBSa2RoU25sZXpO?=
 =?utf-8?B?c3ZBZGNtRFB1cUU4NnZpeHJ5UjhiSi9qc0FnQ0RJSVAwOXZvTU5vc2dPRmFs?=
 =?utf-8?B?bFduQXhINlRWaWR4dFRVRFA2TkxFYnNVcTZvR1RqdkZHVVhvQ3B3YUxkUDVs?=
 =?utf-8?B?WFZROWZLYmh6SG1iSGkvZXcwU0wyaWU4a3lBS1lmOHAvRkxYOTBlRi96bDA0?=
 =?utf-8?B?aHpoS0pHaFJSZnpoNXFHcmVONzU5UU1UazlxazMrQmp6R3Q0Q0dJWlFtelpC?=
 =?utf-8?B?b01jck1DUVpVeDZTYjRmbEpkSjFoc3pTWjhra0Z6SE90amk4UnBkdnVNSTZX?=
 =?utf-8?B?Z0Z5emhBZkxSaGsxVUpPcWlKbWc2WHFCcG4zUTJDWDllWlUzWUQzTzV0WU80?=
 =?utf-8?B?dWpXZGFKSUtkUVB2UGxpb2lVdU1Uc2wycE9LZHh5aU5weWJWWGVsYitFd3JI?=
 =?utf-8?B?Y2tSK0hqeGxGN2VOUFJpVmJyYXU5L3FJQ3gvS3gwUk91SzVGYWFzRzhjU2F1?=
 =?utf-8?B?Y3lQUmNBdHZNanlxWmQwODM4UC9paW91UklKTDdpMmV5aVcvcGFsTlVJUEtV?=
 =?utf-8?B?ZGN2d2gvMzhXOGxOaWR2U096N0hHK050WEJUdHh6VXNsSjg2NmUxNGZXMFZq?=
 =?utf-8?B?ME9UbkpBOU1HQkJlOEhIMlgwMktlRUxDWS9uaHNBS1pGOHZaQWJjUEtrL2dY?=
 =?utf-8?B?WUpmNDVhYmZlN3dDV2svK2Z4Mlh1VHYwRllZRHJKN1Fxem02YlFCUGV2dUFF?=
 =?utf-8?B?U2Q4QkVNUUJXWlN2RTBOQ3VMU2R3RXVUaC9ZdC9ndy9pdUVLNThLNkdoUmM0?=
 =?utf-8?B?Z2ZZMkFkb1h2R3RrbldGSUJNSkt2TmhuUGJ5amQ0UlM1eCtYWjNNaTVjMHFh?=
 =?utf-8?B?MGpwTzlIbHRSRVU0NDBISkhmc1JjenRuZ1N4bmJmODFoeEYweDlMWFVldFp2?=
 =?utf-8?B?cjN3SExvQ0MxUmdDNXRiZVZYMnZ2UlBXMGZhSnJjd2EvNThQalVBaitSdTFP?=
 =?utf-8?B?bHQ0dlYxZEJ3WUVwRmlMYW53aHZPR1Z5ejY3UXFMd3MwQVM1dFFHc2U4aVJj?=
 =?utf-8?B?VlZFRVdpQ1V6MkI3WXNzNU5WNUVlaFlxVm5lYnJ4QktjNnhCMWtBb1VGSnl0?=
 =?utf-8?B?ZmxJOC8zQ2p1NkEwYmdOclJPUS9SY2g5SUdJb1YydnBHUFZnZlI0d2ZJY1h1?=
 =?utf-8?B?Tzh3VWRycXU4M0NGVzNwalhlUHZza1Fpb3BZWU01V0hxRlRrbk5YL2JDSXZO?=
 =?utf-8?B?RjRrUzhTellPUE9ocnRBOW53S3RvWGorOEsxSEEvQXdmemVGRHNvYnhMMVZ6?=
 =?utf-8?B?Z0F4V3pBTm5ZY0RxMFBIaEgwQ2hBVGhGWkVJemVhd0h0S2F0eWR5RENiOGlT?=
 =?utf-8?B?M3lsbjZGZXV1dEhxSlh0amFNaGJTNTZBK3RzbkxKNWVzUXZhZEpSOW1xNjdM?=
 =?utf-8?B?QnZVdmFWVmwrbEZJVGhPcGxLcVBORVJoaEZENUJVclNZVmRlMlBibnpHSnRS?=
 =?utf-8?B?TUUxOEpOcWpSc1U2YWMzOUlSa3ZibUdndDlmcjA4VWNoSzJFcDQwY1p6RGE2?=
 =?utf-8?B?SXd4aFNKZ0pCV3dDS01aclN1ayt5NENCd1QyaHBTRURSZDBWaVl2OWNmSjdl?=
 =?utf-8?B?ZDhIMTh5eHdLV1dNc2gyenQ2VVUwaFBJemhIemg0b21INGo0Nk5pM0RIVE9U?=
 =?utf-8?B?ZkgyRFVFNWpGSTFieGV6SGxGZXExWS92YmphV3VIT25sck5FOWJzY2ZHTnVV?=
 =?utf-8?B?TUhjYVl2VXlScEFoVm1iTkJJanNhcUNxOXoyMXlRejhjS1VDV2ozNGdyeXk1?=
 =?utf-8?B?bDAwRjFwV0Iwazg5azRCbW10Tis5OEg3L0RhZ3lPYjJVVUE5UlMyOXZ6Mlhy?=
 =?utf-8?B?Q3NSRTZEQWcvNHh2KzVVblZGdGhiUCtSUlB5K3lqSXRZcDNUbTRlRmNXWi9V?=
 =?utf-8?B?TnR0aTZUMzdnPT0=?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(19092799006)(1800799024)(366016)(38070700021)(13003099007)(8096899003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?OXhIeGV1NzYrR2lITHgzaEpZY0ZWQzlHMTFpdzRNZXJ1eUttVithUXlDUnpE?=
 =?utf-8?B?TDlDeDJtNExpbGkvaUFyTUQxYWl5RHlIYUJadm00RWZESTh2SlZVK28xdWVh?=
 =?utf-8?B?OUdjYS8xQU5UdE5pODNabDk2aUJ0R3J4c1VTY2dWRDczcjFDRkNjaFZZUlRv?=
 =?utf-8?B?R2ROazJNUlplSXlEVmN4aHQ1SEtMemdMMnFoU2hvbGNSN2Q1T0g3SjRiUEdU?=
 =?utf-8?B?UklQMnMxcy9aam12NVREY2NoSWF1dHZHR0RiZ2pNcGhRSzZZanMrem0raFdx?=
 =?utf-8?B?OFFEOUxXQkcrYnRmSURLWEdsZS84b3JoMmtJTDdWbnMxUGJ1K1lzdllYTHZh?=
 =?utf-8?B?TjRwekh6NEl5eG1tVWZQVkxHTXhBMG15bzNVSlFDcWdLWlZ5M1B1aDAzRk9w?=
 =?utf-8?B?bmFwN0FsS3lnYkhzazRkNytxcW56OUxCTUtyMXlPNUljWWFrVVY0eUNZa1F6?=
 =?utf-8?B?cUR6bkppeHlwUk9pd2h6aTlYZXNoTWs2b08weFBpKytUVGM3RWxUc3phTzdI?=
 =?utf-8?B?NmxXMzFRMTJDMURzdGVENzJFRjRNYnNQeXdqaEdqQU1iL3BnU1VnSGpVT1FE?=
 =?utf-8?B?QTd1RkdPR2dyM3g2SHl6ZkoxZ1pjT0JBVGduVzVramdMQ3JkeEtUSHFUSk91?=
 =?utf-8?B?NGhvbGVFYzl3cHF4QlpITWhvb1I3cjNLY2ZTN1ZKRkRYdXBiUGxEWDRTcmxO?=
 =?utf-8?B?L3JVOW1GZUFkcTlYdVY1THhHL216cXIwRmhFb3dTOWJCb3Z6NE1vUHhJSWdu?=
 =?utf-8?B?cXVNNDM3a0NBdGF5di95czVTeGFrVEhDajU5S3JrZVFJQ280dTFMTW4yTktR?=
 =?utf-8?B?TUpNMktBUWUxSk1Pdmg0bENYd045VG94cXZLeW03cFNFa3FHOGNyZmR4Y1R6?=
 =?utf-8?B?aTZJaFNZOFZOYTNwQWU2Q3piVHY4TnRCdUd2TUxzZG5ISDlvZklhNjBhWkxh?=
 =?utf-8?B?UStOMUd6bk00Rzl0OXVDQ2VITlJiczdsR3QrL2N5Y0ErYVlKMnpSTnNDQWRZ?=
 =?utf-8?B?OGxnVWkwNmw3aXVET2FVL3FKYVJQR1oxczUza2pjZm1PN3dNaUJZaXdxSFVi?=
 =?utf-8?B?cHNhMHRKUnNBT1VYbGR4NmZaMkx6dTY1REpwMkZMNTdCaU1XZUtEeUFVOTY5?=
 =?utf-8?B?YVU2SkFPTUpYNU1YUUtQSDdwR29CQ3hGRDNTTVh3eVJiNjgveURzZ3ZaQVRv?=
 =?utf-8?B?ZVBJaWdwMkMvSExKMzNjRlpETDkzdUNBOXpRTDNCTE45blR6OUlsKzVTblFl?=
 =?utf-8?B?aVlLeVB6ZTRnOGMxTjVXeS8yU0dFTERWR1c5dXZHVGd2ckdwdHlLQk9leVVT?=
 =?utf-8?B?bnQ0ODErajBBUGRvWHFUV0o4UU5GUmh2MTlFR1NpbndWOUdOQXJCdEMvbkg2?=
 =?utf-8?B?T1hoYTlpelJkTEdVa0pOcE51UUlrWU9FK0xPUUxESWt0OXZlSEFZMHB2aXJj?=
 =?utf-8?B?Z2tNdlhkSllRdFRVVzMydWdEMTN4NXEwS3dnN0FDRytBSEh1Y2VEK0RyeXRT?=
 =?utf-8?B?Wkxvc21PVVNRR01ObGRwZ2VPNjlBTG5OQUdLZDZxY1VNd2JYTFdpK1BsQ2FE?=
 =?utf-8?B?MjFxOVlRQ0RER3RlZ09Vd1c0dCthdkNwRmJQcUdSYkcxZ3Jkc0R0UXRJNCtl?=
 =?utf-8?B?T1NGV2NBL0tuRy9nMHNwN3FUZlhCOXI4cUlFeU5FYXI3M1lpWU4yN0prejEr?=
 =?utf-8?B?Z0o0b3dGbUx4eEF1bGNNdE8xUStIZmd2NVlYNlZldzNUQklrcDVFTjJYZkgr?=
 =?utf-8?B?UnREVitjSFJCZG04QmlVZy81TlYzNEZ2ZElEWGEySjN1N2NtWTgvVzdudWRU?=
 =?utf-8?B?ZHdLa1JkUEVZd1JzbTJNRFkxY3VhZWZUcEZuYkJqRVNPTlFhaHZVOGFNK20z?=
 =?utf-8?B?bSt3eHJOWlp1M0w3M09MY1RYb3B6eHZycDRJdDhMM3o0SUVYYWwva2t6Z096?=
 =?utf-8?B?UThzTnNVSk9IT0R6UU1IdEZRelYvSmJtU1l3ZE50RUN3Ui9PbnA3VzdqVWRY?=
 =?utf-8?B?cTJ5SUQ1T0tmZDQ0QW95NGh4S0ttL0dLUE5EVGJ2anRobGpuWGE0UEN0RXFl?=
 =?utf-8?B?bCtDV2poK2dvYlB1TTFNcVArb2ZMbGdrTDZwSHExL3NsSUNkczRVK09icDhG?=
 =?utf-8?Q?l7d9fsl7ZO/8a23Z4DsrS77z3?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: ncguZDVQpRGnkPesir1gqZT6mAi2igq8c6u1PXA1Ftr8KGfCLAmLkwbj8IpZv8eEVDJa+Uo0itWJvlrT1pyq3e8FsLHfrjwZFIkHdc7c7TeOZkueqe2eDh2kne5kdMjSTBxG/bWP6V2mF07OYBj8UAL+o4FU5knR3P8Sq73PFi1CVommH17DtrjvPvihWG4aXw86KK7c/Q3AX7q6ypnKZzMTzRIU+pT/nscGTY77nMRpfE7wgtjYmY7V0tSrev/rWw7tmImaek5Xy0bbvnCKTJhmeUX+TfI1VZn/xzrPTHqm3uj2r9ok+BANLuZCGczCYe6lwxWrymW5G0Lwn/ZPZbG2qnuYi5GCM/MgG5BM5Ta8PlRi+vx9xLAMCs+t2ZnBWLyTYgmLIDe0UD+xqViLaWodPsTr+Mzgm2ogW9jKIvq5gTjZ/YJlt3r1yZ3q7mbTSYjs/Gt55+LTREVPm9hrwH/Cf0ty60fP3gcXGAL+QgKHDTbXkY8p69kJTc3TE4hXz3IXsmB1FSmcULDNmEMXtyej2eJhfHjd4wVzAk0DTPwqT5gPKKabkPNT1cgEl9BG9wZ3h8PA3lKQMvYKejhZKMNRSNlk2V7TRSoADx2l0x2itzVzpTlfAHfnXfO33C+UdUTm2zyLfckKs+dsLJ9iEQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bf94972b-8df3-4e56-9aa0-08de1bc044ba
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 16:36:13.3056 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: wDWIUt4Or4PCbbUIzJiZrGzPRWaEJZ6Vo43C77m+3Xs+FHSDr63Mz9qpjQv0iMaL
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH4PR19MB8562
X-BESS-ID: 1762274183-103962-7711-6121-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.61.114
X-BESS-Parts: H4sIAAAAAAACAzXLsQ6DMAyE4XfxzHCOceLwKlUHSGKxIIZmqFTx7s0Ay+nXSd
 /rR+3baaE+dqLzQwtDeNQ+Tkd0g7RQBDlYUAG8qiEJrKDSNT1+78ftVSTenlflpFyVZY
 vGnte0zdnKrAGtBqfr/QdH21FAgQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268706 [from 
 cloudscan10-159.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
Reply-To: Andreas Dilger <adilger@ddn.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============5443643566574501244=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5443643566574501244==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_54DC145FB9654B048B03473A845892F6ddncom_"

--_000_54DC145FB9654B048B03473A845892F6ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

T24gTm92IDMsIDIwMjUsIGF0IDE4OjU4LCBPbGVnIERyb2tpbiB2aWEgbHVzdHJlLWRldmVsIDxs
dXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZz4gd3JvdGU6DQoNCk9uIE1vbiwgMjAyNS0xMS0w
MyBhdCAxNjozMyAtMDgwMCwgSmluc2hhbiBYaW9uZyB3cm90ZToNCkkgZ3Vlc3MgdXNlcnMgd29u
J3QgaGF2ZSAxUEIgT1NUcywgd2lsbCB0aGV5Pw0KDQpUaGVyZSBwcm9iYWJseSBhcmUgYWxyZWFk
eT8gTkFTQSBoYXMgYSBrbm93biAwLjVQIE9TVCBjb25maWd1cmF0aW9uOg0KaHR0cHM6Ly93d3cu
bmFzLm5hc2EuZ292L2hlY2Mvc3VwcG9ydC9rYi9sdXN0cmUtcHJvZ3Jlc3NpdmUtZmlsZS1sYXlv
dXQtKHBmbCktd2l0aC1zc2QtYW5kLWhkZC1wb29sc182ODAuaHRtbCM6fjp0ZXh0PVRoZSUyMGF2
YWlsYWJsZSUyMFNTRCUyMHNwYWNlJTIwaW4lMjBlYWNoJTIwZmlsZXN5c3RlbSxkZWNpbWFsJTIw
KGZhciUyMHJpZ2h0KSUyMGxhYmVscyUyMG9mJTIwZWFjaCUyME9TVA0KDQpJbiBvcmRlciB0byBt
YXhpbWl6ZSByZWJ1aWxkIHBlcmZvcm1hbmNlIGZvciBkZWNsdXN0ZXJlZCBwYXJpdHkgUkFJRCwN
CnRoZXJlIGFyZSBPU1RzIGluIHByb2R1Y3Rpb24gd2l0aCA5MHgyMFRCIEhERHMgPSAxLjQgUEIg
dG9kYXksDQphbmQgcmVxdWVzdHMgdG8gaGF2ZSBldmVuIGxhcmdlciBPU1RzLiAgV2UndmUgZG9u
ZSBhIGJ1bmNoIG9mIHdvcmsNCnRvIGltcHJvdmUgaHVnZSBsZGlza2ZzIE9TVCBwZXJmb3JtYW5j
ZSwgaW5jbHVkaW5nIHRoZSBoeWJyaWQgT1NUDQpwYXRjaGVzIGxpa2UgaHR0cHM6Ly9yZXZpZXcu
d2hhbWNsb3VkLmNvbS81MTYyNSAoIkxVLTE2NzUwIGxkaXNrZnM6DQpvcHRpbWl6ZSBtZXRhZGF0
YSBhbGxvY2F0aW9uIGZvciBoeWJyaWQgTFVOcyIpLCBidXQgdGhlcmUgY291bGQgc3RpbGwNCmJl
IGZ1cnRoZXIgaW1wcm92ZW1lbnRzIGluIHN1cHBvcnRpbmcgc3VjaCBsYXJnZSBPU1RzLg0KDQpD
aGVlcnMsIEFuZHJlYXMNCuKAlA0KQW5kcmVhcyBEaWxnZXINCkx1c3RyZSBQcmluY2lwYWwgQXJj
aGl0ZWN0DQpXaGFtY2xvdWQvRERODQoNCg0KDQoNCg==

--_000_54DC145FB9654B048B03473A845892F6ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <83B8152CFAA4B54C8E513D632F18E72C@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWw+DQo8aGVhZD4NCjxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIgY29udGVudD0i
dGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04Ij4NCjwvaGVhZD4NCjxib2R5IHN0eWxlPSJvdmVyZmxv
dy13cmFwOiBicmVhay13b3JkOyAtd2Via2l0LW5ic3AtbW9kZTogc3BhY2U7IGxpbmUtYnJlYWs6
IGFmdGVyLXdoaXRlLXNwYWNlOyI+DQpPbiBOb3YgMywgMjAyNSwgYXQgMTg6NTgsIE9sZWcgRHJv
a2luIHZpYSBsdXN0cmUtZGV2ZWwgJmx0O2x1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnJmd0
OyB3cm90ZTo8YnI+DQo8ZGl2Pg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSI+PGJyIGNsYXNzPSJB
cHBsZS1pbnRlcmNoYW5nZS1uZXdsaW5lIj4NCjxkaXY+PHNwYW4gc3R5bGU9ImNhcmV0LWNvbG9y
OiByZ2IoMCwgMCwgMCk7IGZvbnQtZmFtaWx5OiBIZWx2ZXRpY2E7IGZvbnQtc2l6ZTogMTRweDsg
Zm9udC1zdHlsZTogbm9ybWFsOyBmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsOyBmb250LXdlaWdo
dDogNDAwOyBsZXR0ZXItc3BhY2luZzogbm9ybWFsOyB0ZXh0LWFsaWduOiBzdGFydDsgdGV4dC1p
bmRlbnQ6IDBweDsgdGV4dC10cmFuc2Zvcm06IG5vbmU7IHdoaXRlLXNwYWNlOiBub3JtYWw7IHdv
cmQtc3BhY2luZzogMHB4OyAtd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7IHRleHQtZGVj
b3JhdGlvbjogbm9uZTsgZmxvYXQ6IG5vbmU7IGRpc3BsYXk6IGlubGluZSAhaW1wb3J0YW50OyI+
T24NCiBNb24sIDIwMjUtMTEtMDMgYXQgMTY6MzMgLTA4MDAsIEppbnNoYW4gWGlvbmcgd3JvdGU6
PC9zcGFuPjxiciBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTsgZm9udC1mYW1pbHk6
IEhlbHZldGljYTsgZm9udC1zaXplOiAxNHB4OyBmb250LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFy
aWFudC1jYXBzOiBub3JtYWw7IGZvbnQtd2VpZ2h0OiA0MDA7IGxldHRlci1zcGFjaW5nOiBub3Jt
YWw7IHRleHQtYWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTog
bm9uZTsgd2hpdGUtc3BhY2U6IG5vcm1hbDsgd29yZC1zcGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4
dC1zdHJva2Utd2lkdGg6IDBweDsgdGV4dC1kZWNvcmF0aW9uOiBub25lOyI+DQo8YmxvY2txdW90
ZSB0eXBlPSJjaXRlIiBzdHlsZT0iZm9udC1mYW1pbHk6IEhlbHZldGljYTsgZm9udC1zaXplOiAx
NHB4OyBmb250LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7IGZvbnQt
d2VpZ2h0OiA0MDA7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IG9ycGhhbnM6IGF1dG87IHRleHQt
YWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9uZTsgd2hp
dGUtc3BhY2U6IG5vcm1hbDsgd2lkb3dzOiBhdXRvOyB3b3JkLXNwYWNpbmc6IDBweDsgLXdlYmtp
dC10ZXh0LXN0cm9rZS13aWR0aDogMHB4OyB0ZXh0LWRlY29yYXRpb246IG5vbmU7Ij4NCkkgZ3Vl
c3MgdXNlcnMgd29uJ3QgaGF2ZSAxUEIgT1NUcywgd2lsbCB0aGV5Pzxicj4NCjwvYmxvY2txdW90
ZT4NCjxiciBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTsgZm9udC1mYW1pbHk6IEhl
bHZldGljYTsgZm9udC1zaXplOiAxNHB4OyBmb250LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFyaWFu
dC1jYXBzOiBub3JtYWw7IGZvbnQtd2VpZ2h0OiA0MDA7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7
IHRleHQtYWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9u
ZTsgd2hpdGUtc3BhY2U6IG5vcm1hbDsgd29yZC1zcGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4dC1z
dHJva2Utd2lkdGg6IDBweDsgdGV4dC1kZWNvcmF0aW9uOiBub25lOyI+DQo8c3BhbiBzdHlsZT0i
Y2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTsgZm9udC1mYW1pbHk6IEhlbHZldGljYTsgZm9udC1z
aXplOiAxNHB4OyBmb250LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7
IGZvbnQtd2VpZ2h0OiA0MDA7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IHRleHQtYWxpZ246IHN0
YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9uZTsgd2hpdGUtc3BhY2U6
IG5vcm1hbDsgd29yZC1zcGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBw
eDsgdGV4dC1kZWNvcmF0aW9uOiBub25lOyBmbG9hdDogbm9uZTsgZGlzcGxheTogaW5saW5lICFp
bXBvcnRhbnQ7Ij5UaGVyZQ0KIHByb2JhYmx5IGFyZSBhbHJlYWR5PyBOQVNBIGhhcyBhIGtub3du
IDAuNVAgT1NUIGNvbmZpZ3VyYXRpb246PC9zcGFuPjxiciBzdHlsZT0iY2FyZXQtY29sb3I6IHJn
YigwLCAwLCAwKTsgZm9udC1mYW1pbHk6IEhlbHZldGljYTsgZm9udC1zaXplOiAxNHB4OyBmb250
LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7IGZvbnQtd2VpZ2h0OiA0
MDA7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IHRleHQtYWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVu
dDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9uZTsgd2hpdGUtc3BhY2U6IG5vcm1hbDsgd29yZC1z
cGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDsgdGV4dC1kZWNvcmF0
aW9uOiBub25lOyI+DQo8YSBocmVmPSJodHRwczovL3d3dy5uYXMubmFzYS5nb3YvaGVjYy9zdXBw
b3J0L2tiL2x1c3RyZS1wcm9ncmVzc2l2ZS1maWxlLWxheW91dC0ocGZsKS13aXRoLXNzZC1hbmQt
aGRkLXBvb2xzXzY4MC5odG1sIzp+OnRleHQ9VGhlJTIwYXZhaWxhYmxlJTIwU1NEJTIwc3BhY2Ul
MjBpbiUyMGVhY2glMjBmaWxlc3lzdGVtLGRlY2ltYWwlMjAoZmFyJTIwcmlnaHQpJTIwbGFiZWxz
JTIwb2YlMjBlYWNoJTIwT1NUIiBzdHlsZT0iZm9udC1mYW1pbHk6IEhlbHZldGljYTsgZm9udC1z
aXplOiAxNHB4OyBmb250LXN0eWxlOiBub3JtYWw7IGZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7
IGZvbnQtd2VpZ2h0OiA0MDA7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IG9ycGhhbnM6IGF1dG87
IHRleHQtYWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9u
ZTsgd2hpdGUtc3BhY2U6IG5vcm1hbDsgd2lkb3dzOiBhdXRvOyB3b3JkLXNwYWNpbmc6IDBweDsg
LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4OyI+aHR0cHM6Ly93d3cubmFzLm5hc2EuZ292
L2hlY2Mvc3VwcG9ydC9rYi9sdXN0cmUtcHJvZ3Jlc3NpdmUtZmlsZS1sYXlvdXQtKHBmbCktd2l0
aC1zc2QtYW5kLWhkZC1wb29sc182ODAuaHRtbCM6fjp0ZXh0PVRoZSUyMGF2YWlsYWJsZSUyMFNT
RCUyMHNwYWNlJTIwaW4lMjBlYWNoJTIwZmlsZXN5c3RlbSxkZWNpbWFsJTIwKGZhciUyMHJpZ2h0
KSUyMGxhYmVscyUyMG9mJTIwZWFjaCUyME9TVDwvYT48YnIgc3R5bGU9ImNhcmV0LWNvbG9yOiBy
Z2IoMCwgMCwgMCk7IGZvbnQtZmFtaWx5OiBIZWx2ZXRpY2E7IGZvbnQtc2l6ZTogMTRweDsgZm9u
dC1zdHlsZTogbm9ybWFsOyBmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsOyBmb250LXdlaWdodDog
NDAwOyBsZXR0ZXItc3BhY2luZzogbm9ybWFsOyB0ZXh0LWFsaWduOiBzdGFydDsgdGV4dC1pbmRl
bnQ6IDBweDsgdGV4dC10cmFuc2Zvcm06IG5vbmU7IHdoaXRlLXNwYWNlOiBub3JtYWw7IHdvcmQt
c3BhY2luZzogMHB4OyAtd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7IHRleHQtZGVjb3Jh
dGlvbjogbm9uZTsiPg0KPC9kaXY+DQo8L2Jsb2NrcXVvdGU+DQo8L2Rpdj4NCjxkaXY+PGJyPg0K
PC9kaXY+DQpJbiBvcmRlciB0byBtYXhpbWl6ZSByZWJ1aWxkIHBlcmZvcm1hbmNlIGZvciBkZWNs
dXN0ZXJlZCBwYXJpdHkgUkFJRCwNCjxkaXY+dGhlcmUgYXJlIE9TVHMgaW4gcHJvZHVjdGlvbiB3
aXRoIDkweDIwVEIgSEREcyA9IDEuNCBQQiB0b2RheSw8L2Rpdj4NCjxkaXY+YW5kIHJlcXVlc3Rz
IHRvIGhhdmUgZXZlbiBsYXJnZXIgT1NUcy4gJm5ic3A7V2UndmUgZG9uZSBhIGJ1bmNoIG9mIHdv
cms8L2Rpdj4NCjxkaXY+dG8gaW1wcm92ZSBodWdlIGxkaXNrZnMgT1NUIHBlcmZvcm1hbmNlLCBp
bmNsdWRpbmcgdGhlIGh5YnJpZCBPU1Q8L2Rpdj4NCjxkaXY+cGF0Y2hlcyBsaWtlJm5ic3A7PGEg
aHJlZj0iaHR0cHM6Ly9yZXZpZXcud2hhbWNsb3VkLmNvbS81MTYyNSI+aHR0cHM6Ly9yZXZpZXcu
d2hhbWNsb3VkLmNvbS81MTYyNTwvYT4mbmJzcDsoJnF1b3Q7TFUtMTY3NTAgbGRpc2tmczo8L2Rp
dj4NCjxkaXY+b3B0aW1pemUgbWV0YWRhdGEgYWxsb2NhdGlvbiBmb3IgaHlicmlkIExVTnMmcXVv
dDspLCBidXQgdGhlcmUgY291bGQgc3RpbGw8L2Rpdj4NCjxkaXY+YmUgZnVydGhlciBpbXByb3Zl
bWVudHMgaW4gc3VwcG9ydGluZyBzdWNoIGxhcmdlIE9TVHMuPGJyPg0KPGRpdj48YnI+DQo8ZGl2
Pg0KPGRpdiBkaXI9ImF1dG8iIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApOyBjb2xv
cjogcmdiKDAsIDAsIDApOyBsZXR0ZXItc3BhY2luZzogbm9ybWFsOyB0ZXh0LWFsaWduOiBzdGFy
dDsgdGV4dC1pbmRlbnQ6IDBweDsgdGV4dC10cmFuc2Zvcm06IG5vbmU7IHdoaXRlLXNwYWNlOiBu
b3JtYWw7IHdvcmQtc3BhY2luZzogMHB4OyAtd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7
IHRleHQtZGVjb3JhdGlvbjogbm9uZTsgb3ZlcmZsb3ctd3JhcDogYnJlYWstd29yZDsgLXdlYmtp
dC1uYnNwLW1vZGU6IHNwYWNlOyBsaW5lLWJyZWFrOiBhZnRlci13aGl0ZS1zcGFjZTsiPg0KPGRp
diBkaXI9ImF1dG8iIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApOyBjb2xvcjogcmdi
KDAsIDAsIDApOyBsZXR0ZXItc3BhY2luZzogbm9ybWFsOyB0ZXh0LWFsaWduOiBzdGFydDsgdGV4
dC1pbmRlbnQ6IDBweDsgdGV4dC10cmFuc2Zvcm06IG5vbmU7IHdoaXRlLXNwYWNlOiBub3JtYWw7
IHdvcmQtc3BhY2luZzogMHB4OyAtd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7IHRleHQt
ZGVjb3JhdGlvbjogbm9uZTsgb3ZlcmZsb3ctd3JhcDogYnJlYWstd29yZDsgLXdlYmtpdC1uYnNw
LW1vZGU6IHNwYWNlOyBsaW5lLWJyZWFrOiBhZnRlci13aGl0ZS1zcGFjZTsiPg0KPGRpdj5DaGVl
cnMsIEFuZHJlYXM8L2Rpdj4NCjxkaXY+4oCUPC9kaXY+DQo8ZGl2PkFuZHJlYXMgRGlsZ2VyPC9k
aXY+DQo8ZGl2Pkx1c3RyZSBQcmluY2lwYWwgQXJjaGl0ZWN0PC9kaXY+DQo8ZGl2PldoYW1jbG91
ZC9ERE48L2Rpdj4NCjwvZGl2Pg0KPGJyIGNsYXNzPSJBcHBsZS1pbnRlcmNoYW5nZS1uZXdsaW5l
Ij4NCjwvZGl2Pg0KPGJyIGNsYXNzPSJBcHBsZS1pbnRlcmNoYW5nZS1uZXdsaW5lIj4NCjxiciBj
bGFzcz0iQXBwbGUtaW50ZXJjaGFuZ2UtbmV3bGluZSI+DQo8L2Rpdj4NCjxicj4NCjwvZGl2Pg0K
PC9kaXY+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--_000_54DC145FB9654B048B03473A845892F6ddncom_--

--===============5443643566574501244==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5443643566574501244==--
