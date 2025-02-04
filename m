Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8C86EC02193
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Feb 2025 18:38:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YnXFF3j0Hz1y5l;
	Tue, 04 Feb 2025 10:38:41 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YnXDs0Bfmz1y4N
 for <lustre-devel@lists.lustre.org>; Tue, 04 Feb 2025 10:38:20 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11lp2177.outbound.protection.outlook.com [104.47.58.177]) by
 mx-outbound40-57.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Feb 2025 18:38:15 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=saLFeHNmPbkPHZRILP3rN+SV0gOZB4YXr8NlHB/P6nctGsINX5ZjvWFG6oqGG/yG14yz+4dMjHzz/iKXdBtbD3Oes2L9Q8YsvDfwoAyrCSzB9az0hBa2Rv0uZoaPSZh/UvIRHraFyjHOdW2TjoC83aD1jRT/y4PmQKvFiN6zAwQt7lRuotn/GIodB1VPgwy6wfOma9DzhE9V6tE9Nn5b8wT4X0HGXQiKVrSVdGMj/v2knHc/AIDyytik3jg/2Tcsiy/LyZ/FwZcxYod7c/pxadgopBciSETxG0xu+szvFA6EzWNAMBc6lBBxtw0/sAie5QCd+ZMnXS+ba9hjalgWrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=yYe+14CANRN+7cqa1ejoVyOfM0XxH6p0q/Ciqajz4VA=;
 b=Vw/7fXHPCdkaMBPGah3DCX31cuHjw1kVs3yVkBesQn1o9CZrxULwZrtKj4iFNIOPW8dyaYcKY0W/Mrz6lZlkDM6IQ0ZVBu4poJ9VYGG+wBPw9Jc0rMybS3aR/UQhE+C9MV/DMt6il/bex0Sndki4lJvL0SAoz7LYKC2JVNuuBEv1GXq0iG/rC59Ynbokgypa2Obcwn6SS0ouL9C6bp3bZCGvSr9n1ayYoAxXM9hOHdJqtCzpaN4A4IHrUKq8n2sAaki5DDMyHmMJKIjMYJ53QBonOTN0GKKMcj9qPfapQGWRN+MpxOQdqeOCbySicYe0gQvpkE6nTexijqZkBagISw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yYe+14CANRN+7cqa1ejoVyOfM0XxH6p0q/Ciqajz4VA=;
 b=CXefKhE7ua/XpHv774m6EBJR0bfaSKPYQNXo/R1LBMvqKeOwBGGV0MvVhs/H0yXdd25+bYZSisQGWcSNwpsRnJXCbm6Ij9jg5ZhgLUrG5UbMkhr4iwG5RVYlitKhJBy5v+mkVRTVJwVTz7Kr4pgR2ozzNkSAtfBx04LBjfFWbh8=
Received: from SJ0PR19MB6583.namprd19.prod.outlook.com (2603:10b6:a03:47e::13)
 by CH3PR19MB8163.namprd19.prod.outlook.com (2603:10b6:610:1a1::7)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8398.23; Tue, 4 Feb
 2025 18:38:12 +0000
Received: from SJ0PR19MB6583.namprd19.prod.outlook.com
 ([fe80::7a1b:db9c:dbf7:e421]) by SJ0PR19MB6583.namprd19.prod.outlook.com
 ([fe80::7a1b:db9c:dbf7:e421%3]) with mapi id 15.20.8398.020; Tue, 4 Feb 2025
 18:38:11 +0000
From: Oleg Drokin <green@whamcloud.com>
To: Andreas Dilger <adilger@ddn.com>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAAAWoAgADH0wCAAKtNgA==
Date: Tue, 4 Feb 2025 18:38:11 +0000
Message-ID: <4243d258f1a38e8539e88a68fb705f05bf18dfb1.camel@whamcloud.com>
References: <7f1d21950673c3deae1e92839deb61be88d77f22.camel@whamcloud.com>
 <A39FEBC6-1140-445A-83A3-7EA27AD5C356@ddn.com>
In-Reply-To: <A39FEBC6-1140-445A-83A3-7EA27AD5C356@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SJ0PR19MB6583:EE_|CH3PR19MB8163:EE_
x-ms-office365-filtering-correlation-id: 86708015-6bb0-4d36-b961-08dd454b140c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?RThLeVRQeFJ6T2Q3RmJlSll6czQ4QWFxOUJoTXJqVWxzcjVUdlpTZ2xtN2xE?=
 =?utf-8?B?RFR1TUl3MjVGeE1Td3ZYTXZLTllFYWFqWnBMRVllaFp4ZWZDbjczY1ZWaWht?=
 =?utf-8?B?dTBQZVB0a3hpL1dxeHlvMWF4OVpWUStxUUhxK1RudFM3Y08wa2NYWnFpY2Zx?=
 =?utf-8?B?d3R1MG5kS0p4VE84K2F1NHB6U0lmaUVZNVYwMEVscDR4b0ZHSy9CWHVqL2NU?=
 =?utf-8?B?OGlMU3hBdWxnVGRrUjFpbGplbWxLUGhJT1QrYmFRY2NzTXd5VWV5UlJubjlm?=
 =?utf-8?B?UFFSeUhPaXdxbXZnL2ZHejZ2UU9BK1N2Y1BhNlROUGMzV0hPaTN3c2VmNEYr?=
 =?utf-8?B?cEJ2RXF6bUFCanlJaFQ1Vnh5UzE0b1FvKzl3aENEbFdvU2RLZ2VxK1FFTHph?=
 =?utf-8?B?RnQ4S01RRnJEQ3RNa0V0NWFnTVMyOWNuL2UwWkpPTHZyRjQwV1MzZjVvNyt4?=
 =?utf-8?B?MTRTZmRQSW82WUtFNVRhS21WT2dGV1JON1g1Mkt0ZDJ1N2JJQ3dPQWF2SW5r?=
 =?utf-8?B?RDlUWVAyYUFpN2NFUWtYWS9RaDNpODNoRDRRNXVqdTJHRUlpbDVQemkxaVBl?=
 =?utf-8?B?eUZ2V0ZPTUkyQ1R4cEp4VkhqaWRoMVcrbWVFODFzMVRlQkJSRndoSk51UGQ0?=
 =?utf-8?B?UzBab0l6Qk5RRytBTmZ0a0FxQ1MwZzM1YzdyTUVLTWZhVXkvMEhMRlM1NEtI?=
 =?utf-8?B?OXIrTDAyTjkwRzE4NUJzQjBnM0RsbkQ2c0xPckhkTnBHMm5RSmhCaVdMZkFP?=
 =?utf-8?B?L0wxc3JJcG0yRUIyTDkxazZ0bVJtRVMvTzFSZkRaQTY0QzNMT0Vkd3Zkb0pF?=
 =?utf-8?B?a2NxWWhRbHoybEZBWVV3d1NUTGIvYzlSNzV2TTR2VzlqeVFNbFJqSis5Mkh4?=
 =?utf-8?B?ZmNFS3Z0UXd3RFVSWnFPREdGbmNFRlZpbXQxRUpOZHUwTXVGQnFNeHhHbGU2?=
 =?utf-8?B?UmI4WHRWYjFZamxiRjBQY0YyVjAyM2M2WGkzUHpxbCtvL0R2Z3E5MnZnb1o2?=
 =?utf-8?B?SGNId2g4OFdsYXlzazBaNUx3SDk3b0dmNWg2NWpGSXliaTdpa2gvUnA1NlFx?=
 =?utf-8?B?OE5kR00zQ1hSTjM2Z3Q4cVhVM2h6ZG9mcGhqalY3TXQ0S1E5a3NoUkpwY2VK?=
 =?utf-8?B?Y2h0ZkxZalZxQjR3a2NSQVl4NmY3RGQ2dGtoUzVMQ3FqVk92WktSWGlseG9F?=
 =?utf-8?B?ZUxJclZqNnJUVS85WE1HSFpaM2xVdkNxaGNzekxqYXJmaXM1OEdZVmtpNVFx?=
 =?utf-8?B?NzdOQUxxZk0wTHIrRlJ6bVV1MHJVNWZ4bEozMVZ3R0RXMmpNR2V6OTE3Mk5C?=
 =?utf-8?B?cCtkRllKa1FoT3hJSk1oYUluUVVrak1vUWladlNnYjc1YU1HZDhDMzBnNkY2?=
 =?utf-8?B?c0NIYUkyU01QWXVISk5TeE51QnhWZDBLUWlXTGJDTXpiSTFaUEUyZmE2OTZ2?=
 =?utf-8?B?QUxwU1h6VU8yM0VDeitFYm1GelBEM1hPMzAvbXZ2b1c3N2UrckI5VmFaYmxl?=
 =?utf-8?B?aTcxUCt1aksxL1hPc1cwTWhZUHpzUk9LR0tMRExjak44NXpGK1gra2dFTy9D?=
 =?utf-8?B?Z1lpWHpDRDNiOTg4N3N2WEtOaUk5ZXk1RHl0RU9oaUVTR1J2K2k2ejlZZFFh?=
 =?utf-8?B?K1A4RXIzcnQwSFFWeU9IdTBrOGpDQk5Galh6Tlh6VCszTEFQU2UzMXN3eDFO?=
 =?utf-8?B?NWsraFZWSDVHZzV2VHVjWFpQMlZYcm5QSVQyQjY4VjhwaXBIbnJjVFJ5Qk5u?=
 =?utf-8?B?WFNOS21ZbGtXZlpMV2dCR3QwK05oSjNGUjRGaWFlRzM5c0VtRHl6TnBlZDdL?=
 =?utf-8?B?NjFWNGpJM0VnQ212Ris4Ry9zWnQwR1JMZFNzOUZyOVVTbGpZa3VybVN0KzVt?=
 =?utf-8?B?TXM4bXBIaCtoL1J5UWxSeUNNL3gyeGtOeXpxL1k0ZS9PR0E9PQ==?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SJ0PR19MB6583.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?amk4TS90dTM2V0tBVkdMQ3pVVzYzUDFwRDU5ckpPYk5GVnFuakRsQ1lGRFpS?=
 =?utf-8?B?UGo1dHFVZjdOTmdQdUVadTMyMDZ4L2JSQ2RXVjR3WFk0ZG1uWlpiU3BKcXJ6?=
 =?utf-8?B?WTZ3amRvbVZiUmVQd0lKemM0RWlPTmlXQmttREFHVVdua3NadVdXSHF3VEw0?=
 =?utf-8?B?NW9hMjh2Wk0yUEVmalBuaE83THhrOFhLMlZweUM0SFZjSkMyc2Y3TW0wa0Yw?=
 =?utf-8?B?TXBYL1l1U0VmK2YreFozRnJ4aUNyNnp6R0d4WCtMckorSE0rVS9zOWZOT0Rn?=
 =?utf-8?B?K2lrbkRQYUtvY3N0MmlDdEJBbmFrVFV6TlppUFliVVZ5blkvL2ZuM0FVUGFr?=
 =?utf-8?B?d0lGZzk2NVRvT0loZThZSVcrV0ZQcmxPL1BkTmFYTnRMYlZmM0p3UHZXNU1P?=
 =?utf-8?B?bFNhQno1S2x3YnhoKy8zUHJXVm9RdVpVOXkraXMwN3BLMS9zdUFBVnJxRE5O?=
 =?utf-8?B?S3lnalhvYzZuajJCMkNTeTZoWEJGV3U4b1gzcW1EOWhaaVEvcHBqak9scXVU?=
 =?utf-8?B?Vk93QVR2b1N2bVVCbW4wckZPSmc2RjJ3VDltNStibnRCWWIrTjNBMUpzT1JF?=
 =?utf-8?B?VUhsdGhpYTZUUjdzSDVuaU82MksvaXhENlNRWTJGVmVYcVVGT3VLUXlkRnR4?=
 =?utf-8?B?akdpalkrMlVSZXpyYUdqRzFiZGpYaWZkVWpSYWR2dDVlYzQrOG5SYWZKQzJa?=
 =?utf-8?B?S3M4dXlnVERWVWRNNTM0VDZ5V3dWYUxpUmVpQURIZHZoaXpsVitLMEtWeFk2?=
 =?utf-8?B?NHM5ZEdvTTZKbVhQU3lxQ05CYVE4cDdBaW55blF0SVQvcjFMcFNzWXpxaU5Y?=
 =?utf-8?B?Uzk4RGRhVFM1aitESks0T1V0Q0Z3azVwWFhLNWg0QWh6MmVRcXBMSXRGam1Z?=
 =?utf-8?B?M2VCaHBuU2FuVVozNWppRDRJV3pwWmMvWDdvczQ5VDA0Tld3WVlwWlJWTll3?=
 =?utf-8?B?T1I3Tkg2TE9QOTM2STJueDlvR1hoNjl3dTF2bC9NeWhFRWcvL3N5dVpwSDhP?=
 =?utf-8?B?aVhDMTNwc09jWjM2TnFKRnVrUlhsSURzdFI3UGxMbUVhblcxWHpJRFlLSlFO?=
 =?utf-8?B?UUhvbS9Td3ZNSTZORStyVG8wQ3QzaHBzTjlZZzQ3aDFGNmZON1lxM2RHb3hP?=
 =?utf-8?B?VUR5dEdQUnpoejBTNzVGWkZROUpoS2h3UlY1QWV5NmtnVVhqVXIrKzdKUVBF?=
 =?utf-8?B?anM1ampQeUxoc2RaYk1NLy9vc2JmS01iTEI5ODZ2eUNUWlNjV2szZC9Ldzhj?=
 =?utf-8?B?Rzh6Q1Y4NGs2aE5ZcWg3citDbXhFSGErT3RXRDJxVk92Rittdmo1Zm9mNnBh?=
 =?utf-8?B?MUJmY0Q3cXh0NlVtckhYY3Y4b3laSW5YSnlVS2VRS3graWFHR09QbjdacHYr?=
 =?utf-8?B?UTdRUC9veEhwcldXV08zVE90dmxYazNMSWN1bFV3R1U0ZmJhME5PakRjamdv?=
 =?utf-8?B?VnpBbCtOSktNbld6ckRhWVdtQ0tpVlZKZTV3eUNRTVJnU0NkVEV4RXFJOHdw?=
 =?utf-8?B?c21Na1NIWXF2VDhYdFgzb1FMbVUxalp2K0hhK0Z0dVpMY2tjQ1ZGeVcwcERq?=
 =?utf-8?B?YitMVHIxYmhBdW9jMXhUU05vY2N6end4WnZENXhLR3pNTEM3allneFhPN2hR?=
 =?utf-8?B?SjloeW9Xbi9uQ0Y1WWlydTVET20vTGpOdXJRTUxwNVM4S2g1YmlnZjdVSzJj?=
 =?utf-8?B?bTlsaEU4a0Z5WTdoME1VaUFXTDArMzQxT085RnBLZXYxVGpnUWlpdTB3dXdi?=
 =?utf-8?B?N0dJOHZiNm4yNllveTZSQmRZYm44ajBtaUFKWTJVejdqbGpVRnFrRzQvTE5o?=
 =?utf-8?B?cmlTcW8rV2x2YTg5SW53M3djVFdnSXdUQlNrY2E1SjdsbzA5NVJpeDFVeHhs?=
 =?utf-8?B?UXJpWWtVUUZyOVNPMUVLeG5tcWFaRkQ1blFLalNjS3Q2VEVvamdzcmZVdnph?=
 =?utf-8?B?MEdsOEZPdEFtQWlLYkhNbXFmM0thVUhvdi9tSXNRUDh0bGlZOURwZ2J3RXFt?=
 =?utf-8?B?Z08yclBVdDQ1TWtVakJQWU1wTU1Remw4c244WnhLVm0rUzlMdjZDS3ZGYUxI?=
 =?utf-8?B?b3dKK1dXcmxDZjE0V1ZaRjFEam5xWnNxUFFnWXVpSm5aVFJqQ0pNeXgvdTlQ?=
 =?utf-8?Q?1LqopnGRYxfixZvj3Iigttxfd?=
Content-ID: <79E2CE06A1D9BC499A5830699058F002@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: C9YCDCg6ZoaT9Ln6FJcIRb+8w8zHwr4oTP7EsUgpxGiogWZKxB3umDXNA3vgg5QWyujkqpAf3I8VSp8ziJQXdicEal0zqoi6GtMGj96Z7QUyTbbP3Nraj7H7ax5Q5LTj/F7hHLm2I4mKztUxS3BjlazGgyRGeVLJvIMn5Tzr7jfMU7ST3oCXaezp+epb+THc1b96n1Zy2joEIY23JNq1ZmpGQjNdyNmGQuk3QJz7ssUGHpPmjmqv8R5Y4hXzJtsbfYDpWzDyBGGIYwHnWaqDwpvXULNUYxgGkbKblx9BzQi4QC6zH6MB/4m3lxr+YWJi5gKDEmecY1SELwTZtBwZDlUIJ8bErSVVW7oyVp0ycFTvFokNea6n2Mlm/ejY5WKrjWPi7U4/ix3/8/TjRX8P+5wJLRWZZ0Z9v4zKaN+TFnDkyXjPmAvQSJFTcphxti4zTGiFsGl7lR0fojsRsWQ8ue0ddk5We79jSFNYwksyxE4lMkoLcbC7JBnzOK+tOI1VRm1N+fllsrL1Si4AizzX2Wy3CtR25z6p32DsKRHcQVTs9dsD53r9D7r9gxJwJa5YImlFZ4xAie+o5miypfXucKhkP1ILIpzCBlMu3FQgEryw4g6cbtexT8Ieb9S9KSnNjpyGkr+8nLhCi3BnJyW7MMI+AYlgrFuFk9iloQ9B3rc=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SJ0PR19MB6583.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 86708015-6bb0-4d36-b961-08dd454b140c
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Feb 2025 18:38:11.7504 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: MeYnJu4oPbuhqslXuO0sEck+B3sRsKzaTg542uZbKzgcXA4zdTdic0CQcXROi5ry
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR19MB8163
X-BESS-ID: 1738694295-110297-23155-7564-1
X-BESS-VER: 2019.1_20250203.2302
X-BESS-Apparent-Source-IP: 104.47.58.177
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkZGloZAVgZQMNEwLTEpxdw8zd
 zQONHIwMjUwsjI2MTU0tQi0dQs1cBMqTYWAE0H3alBAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262287 [from 
 cloudscan16-230.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gVHVlLCAyMDI1LTAyLTA0IGF0IDE3OjMzICswMDAwLCBBbmRyZWFzIERpbGdlciB3cm90ZToN
Cj4gWW91IG92ZXJsb29rIHRoYXQgVGltIHdvcmtzIGZvciBBV1MsIHNvIGhlIHdvdWxkIG5vdCBh
Y3R1YWxseSBwYXkgdG8NCj4gcnVuIHRoZXNlIG5vZGVzLiBIZSBjb3VsZCBydW4gaW4gbWFjaGlu
ZSBpZGxlIHRpbWVzIHdoaWxlIG5vIGV4dGVybmFsDQo+IGN1c3RvbWVyIGlzIHBheWluZyBmb3Ig
dGhlbS4gDQoNCklmIHRoaXMgY291bGQgYmUgYXJyYW5nZWQgdGhhdCB3b3VsZCBiZSBncmVhdCBv
ZiBjb3Vyc2UsIGJ1dCBJIGRvbid0DQp3YW50IHRvIGFzc3VtZSBzb21ldGhpbmcgb2YgdGhpcyBu
YXR1cmUgdW5sZXNzIGV4cGxpY2l0bHkgc3RhdGVkLiBBbmQNCndobyBrbm93cyB3aGF0IHNvcnQg
b2YgaW50ZXJuYWwgYWNjb3VudGluZyB0aGVyZSBtaWdodCBiZSBpbiBwbGFjZSB0bw0Ka2VlcCB0
cmFjayAoYW5kIGFwcHJvdmUpIHVzZXMgbGlrZSB0aGlzIHRvby4NCg0KPiBJIHN1c3BlY3Qgd2l0
aCB0aGUgcmFuZG9tIG5hdHVyZSBvZiB0aGUgYm9pbHBvdCB0aGF0IGl0IGlzIHRoZSB0b3RhbA0K
PiBudW1iZXIgb2YgaG91cnMgcnVudGltZSB0aGF0IG1hdHRlciwgbm90IHdoZXRoZXIgdGhleSBh
cmUgY29udGlndW91cw0KPiBvciBub3QuwqAgU28gcnVubmluZyAyNHggYm9pbHBvdCBub2RlcyBm
b3IgMWggZHVyaW5nIG9mZi1wZWFrIHRpbWVzDQo+IHdvdWxkIGxpa2VseSBwcm9kdWNlIHRoZSBz
YW1lIHJlc3VsdCBhcyAyNGggY29udGludW91cyBvbiBvbmUgbm9kZS4gDQoNCldlbGwsIG5vdCBl
eGFjdGx5IHRydWUuIFRoZXJlIG5lZWQgdG8gYmUgY29udGludW91cyBjaHVua3Mgb2YgYXQgbGVh
c3QNCjF4IHRoZSBsb25nZXN0IHRlc3RydW4gYW5kIHByZWZlcmFibHkgbXVjaCBtb3JlICgyeCBp
cyBiZXR0ZXIgYXMgdGhlDQptaW5pbXVtPykuDQpJZiBjb25mLXNhbml0eSB0YWtlcyA1IGhvdXJz
IGluIHRoaXMgc2V0dXAgKGNwdSBvdmVyY29tbWl0IG1ha2luZw0KdGhpbmdzIHNsb3cgYW5kIHdo
YXRub3QpIGFuZCB5b3UgYWx3YXlzIG9ubHkgcnVuIGZvciBhbiBob3VyIC0gd2UgbmV2ZXINCmdl
dCB0byB0cnkgbW9zdCBvZiBjb25mLXNhbml0eS4NCg0KQWxzbyA1MCBzZXNzaW9ucyBvZiBjb25m
LXNhbml0eSBydW5uaW5nIGluIHBhcmFsbGVsIDF4IHZzDQoxMCBzZXNzaW9ucyBydW5uaW5nIGNv
bmYtc2FuaXR5IGluIHBhcmFsbGVsIDV4IC0gdGhlIGxhdHRlciBwcm9iYWJseQ0Kd2lucyBjb3Zl
cmFnZSB3aXNlIGJlY2F1c2Ugb3ZlciB0aW1lIHRoZSBvdGhlciBjb25mbGljdGluZyBWTXMgd291
bGQNCmRldmlhdGUgbW9yZSBzbyB0aGUgc3RyZXNzIHBvaW50cyBpbiB0aGUgY29kZSB3b3VsZCBm
YWxsIG1vcmUgYW5kIG1vcmUNCmRpZmZlcmVudGx5LCBJIHN1c3BlY3QgKGJ1dCB3ZSBjYW4gcHJv
YmFibHkgdGVzdCB0aGlzIGJ5IHJ1bm5pbmcgYm90aA0Kc2V0dXBzIGZvciBsb25nIGVub3VnaCBp
biBwYXJhbGxlbCBvbiB0aGUgc2FtZSBjb2RlIGFuZCBzZWUgaG93IG11Y2ggb2YNCmEgY3Jhc2gg
cmF0ZSBkaWZmZXJlbmNlIGl0IG1ha2VzKQ0KDQo+IA0KPiBDaGVlcnMsIEFuZHJlYXMNCj4gDQo+
ID4gT24gRmViIDMsIDIwMjUsIGF0IDE1OjMwLCBPbGVnIERyb2tpbiA8Z3JlZW5Ad2hhbWNsb3Vk
LmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4g77u/T24gTW9uLCAyMDI1LTAyLTAzIGF0IDIwOjI0ICsw
MDAwLCBPbGVnIERyb2tpbiB3cm90ZToNCj4gPiANCj4gPiA+IGF0ICQxMS9ob3VyIHRoZSBtN2Eu
bWV0YWwtNDh4bCB3b3VsZCB0YWtlICQyNjQgdG8gcnVuIGZvciBqdXN0DQo+ID4gPiBvbmUNCj4g
PiA+IGRheSwNCj4gPiA+IGEgd2VlayBpcyBhbiBleWUtd2F0ZXJpbmcgJDE4NDgsIHNvIHJ1bm5p
bmcgdGhpcyBmb3IgZXZlcnkgcGF0Y2gNCj4gPiA+IGlzDQo+ID4gPiBub3QNCj4gPiA+IHN1cGVy
IGVjb25vbWljYWwgSSdkIHNheS4NCj4gPiANCj4gPiB4MmdkIG1ldGFsIGF0ICQ1LjM0IHBlciBo
b3VyIG1ha2VzIG1vcmUgc2Vuc2UgYXMgaXQgaGFzIG1vcmUgUkFNDQo+ID4gKGFuZA0KPiA+IDY0
IENQVXMgaXMgYWRlcXVhdGUgSSdkIHNheSkgYnV0IHN0aWxsIHF1aXRlIHByaWNleSBpZiB5b3Ug
d2FudCB0bw0KPiA+IHJ1bg0KPiA+IHRoaXMgYXQgYW55IHNvcnQgb2Ygc2NhbGUuDQo+ID4gX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18NCj4gPiBsdXN0cmUt
ZGV2ZWwgbWFpbGluZyBsaXN0DQo+ID4gbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcNCj4g
PiBodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3Ry
ZS5vcmcNCg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
bHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpo
dHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5v
cmcK
