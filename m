Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B8A85C369D9
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Apr 2025 00:06:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZmgZv2tv6z1xPM;
	Mon, 28 Apr 2025 17:06:15 -0700 (PDT)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZmgZs5CPsz1xBm; Mon, 28 Apr 2025 17:06:13 -0700 (PDT)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com
 (mail-bn7nam10lp2047.outbound.protection.outlook.com [104.47.70.47]) by
 mx-outbound22-23.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 29 Apr 2025 00:06:11 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=EOFUek3JNEya6QNEl9/JJYKA1k14UBq+AULeSMuCKLQYjMOIDmCIiVQz7XwaUga2P7Cgeo/Q5uMkLTBiidn04b9K/mPSnS9mUTgLrJUGClSIVbXJsI7JRiGwYjhUYVUgJ1likK9mD7nfG5jZ0KHkJ9gGAX5WUqUHI7bpjJLM5NtCSM914uX7i5yBr6LD2uY79WW8YzzB2H9pUNIMTDlKsB/TCqG6v2n3E3A4Zs7VY1/yNAHecwu2gqJ93+nPZM8XTXoKYQFJecjitVzEaz/mtHcTL85nHzSWVyNJCAnEQONCHlyMVSStxDyBSYlrXN3R7nWO6BgFCfAg/hDcxPcIGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=se6wgrhr6swr4fo6nAOqwGI39i2IVehosmX4+TTZQbA=;
 b=Po06yOBt7vOuGerIJNcHnvxvRUWLij5W1eVGHfgEJMjqIAKBW9WbB2/HO4krTW6Mmnxr6fnvo92DkroF9MWJXu5M3OFog73yOszXg2nASgCd5XT+T/O8eOZvnbXHq/TaFoQYaTH1MdDPEZiuAF276fDqpT/gQZSI9DcJzV8OQ55rb2pYGRFJWof0QaIp20pUZkBRofGWA5k3QLWEf27IsXTt5uQz23I+DnQRsrJH/+F189t58AZ7sjJH7GY6kYrGJ3T7SDrp2ipyFPF8atVh06VQz+0wZomWxJYrKw6jpjIuynF2muzwR8l3+ZTO4m6AToAWquCSiaArOOzL6vVY8Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=se6wgrhr6swr4fo6nAOqwGI39i2IVehosmX4+TTZQbA=;
 b=YvnxzBA6H1Fhv29uEqu4fV183JbOcaXDVxt2nI1eOQxt5aaDSH8ufAd5/9hcOfnKSAjg7RrFq1ZYy02Z6pBXPNZYhiUnsj5EuxLVVAJ/dEeC4AS0daaFbtAyRSKZGjuXUn44u9NUMs6vMD93t45p81vnCxbmjXiqNt9UeCg3ZPs=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by SJ4PPFD0BA9640B.namprd19.prod.outlook.com
 (2603:10b6:a0f:fc02::a54) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8678.31; Tue, 29 Apr
 2025 00:06:06 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%5]) with mapi id 15.20.8678.025; Tue, 29 Apr 2025
 00:06:05 +0000
From: Andreas Dilger <adilger@ddn.com>
To: GEORGE ZHAO <georgezhaojobs@gmail.com>
CC: "lustre-discuss@lists.lustre.org" <lustre-discuss@lists.lustre.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-discuss] Beginner: Lustre server compile and deploy
Thread-Index: AQHbuFByhmi0cPH7ZkC9I1GnjlqpebO5s0WA
Date: Tue, 29 Apr 2025 00:06:05 +0000
Message-ID: <66BA42BA-AA8C-4D6D-B268-CEA2D8214938@ddn.com>
References: <CAFhHJgm+7QRV39wR2GB+Q2nASTg8NchXQPpqjFe_KPa0sUPqpw@mail.gmail.com>
In-Reply-To: <CAFhHJgm+7QRV39wR2GB+Q2nASTg8NchXQPpqjFe_KPa0sUPqpw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3826.200.121)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|SJ4PPFD0BA9640B:EE_
x-ms-office365-filtering-correlation-id: f76d18f2-59e1-444b-00ae-08dd86b1a30c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|376014|1800799024|8096899003|13003099007|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?VHEvTzkyc0xxcUpVdXRHOTFYMnlubWdtY2JJOC9iWjNOUnc0NkdzTitsdDVt?=
 =?utf-8?B?UlVBWEp2elpIWDRyUXAra1pMMDU1dUUwRkVxSldyQ1pnMGQ1OFd0UlNhTTFh?=
 =?utf-8?B?cnJ3dFlVaTNqbDFPeGdBNGE5c1pHTE13bHZFRlFZSjFOZXMrQ2NrYTBkL0RS?=
 =?utf-8?B?eGNaS3FJWEs2NFJ0TVVZYWlJa005UGp1ZzI2cTMrMmEzbk1HYlBRU2IxVmYy?=
 =?utf-8?B?T2RjaFFFNy9PV2V6VDZxcmNkc0hqYXE1bFBUUFA3QmpuWTY0c3BSVmwyL3Vw?=
 =?utf-8?B?M0JlL0g4Z1dBL1JxYTVwRFJoaTVGVkJkSTlFamJLcFR0eDJlM210d1k4Tmx6?=
 =?utf-8?B?YzdVSE11dGJ6Sk4vTHd5TEVQUHBNVWtpWExMYnlFN1A5MjZZaTFEUnllbzF4?=
 =?utf-8?B?cjgwRjdyUXV4SWlPeWREVTZoZVh0YUlOeWhjejhKdWY2MEgwSXVLQUZOUG8v?=
 =?utf-8?B?L0JaSjIxWi9OK01TRm50Y3o3RlNRUC84akZJdTRyd285OHlUbHJJWjhRUWwr?=
 =?utf-8?B?a3IzY1AvUDNJK3Z4TFc3WU1XN3Q5dmFHZUZROUJMMGFhMmhsOTJBbXhqTWpC?=
 =?utf-8?B?dytpdHpKTzhvZm8vbkFwQTcrbXFVUGY3WmdmdVlzcFhOUWRMWjdYWkJ5QlFn?=
 =?utf-8?B?dHhYU2l2cFhrY1AvZFBSK3Z0Smc4UXNZNzlBZEZObFoyd2tLMXRuaVlIQ2M5?=
 =?utf-8?B?d0FaN3JzYVNmR3VxTm9tZmY4cTQ2T2JVa3JPV2k2SHB6TTd2QmZBMUNtNHBX?=
 =?utf-8?B?Vkh1aEVJYTZJUFpVWnM5R3R5N1pXMzk0dmlFSUhMZ3VIeU5QWmZtL0drMjMz?=
 =?utf-8?B?Z3MxbzZYaEx2YldsdXVOY3ZIc0JYRjBXQkNheEdUSHpRSVNwZ1RWNEc5VVJE?=
 =?utf-8?B?RWZRdkxtMjR3YjRnQlh5bWlCcVE2WGloOEhQVzZISXo0UTRncDF0WlVNNTh6?=
 =?utf-8?B?NFMwUGxOdU5NUUZGRmhqeUVuamdQWlMvU1JCTFo0NnI2NEJVVlJEbUtPdk1L?=
 =?utf-8?B?Y09lSG1xYjBld2d5cmFmQ1V2d3JwSWF6Z05YYUUrcVlHekJxeUx6WXV1TjZr?=
 =?utf-8?B?ZDhsTHp1aEYwZHQ2d00wTlB0OHd2V21ENWh4WEM1Z1FUVDBSWk5iaGxSRE9B?=
 =?utf-8?B?ek1hN3llSXlNeGRub2pacWRLTG5HTVVHbmR5b0krZHgvS250Ymx6VXh0ZWc1?=
 =?utf-8?B?SkJhN2MrYzVYWWthMDNxZlEva1dRSWVpZmJsZnE2NDVuOE5iNUtITWR6aElv?=
 =?utf-8?B?RTNOZTdXZDRaUmNkcDVvRnR0Sk5BR1VmS21TSk1aUG5IRzM2N0NMOVduQ0ta?=
 =?utf-8?B?cFY0eGVHSitwTXJLVDRReGhHdENMREpsZ0RkYU9ZN1ZBMmovcmV3bk1Nb2s2?=
 =?utf-8?B?WUFSenVvY3NJVVFPZUV3WGFpZmpLcEorbEordHAvM2ZtL2JGNURxNjFyL0Fj?=
 =?utf-8?B?VTh1aFA1RWlaOWJRdkErb1BrekxTb0FiUFFXY25tU01iUDFYRnZtb2JqMVI5?=
 =?utf-8?B?R2RqL2wvSFgvS043RUx6MFhZdlI1Wm8xZnFSYkxOZmtLWXFPcUZkMkZrbUJQ?=
 =?utf-8?B?cG4zdnlLZEQrNGtHc3JvSjFtdUZ0WkVuUzV5aFJpbzFpK2FQNVFkTytYTUk1?=
 =?utf-8?B?WVBGQXVrNWxUU2dZY3RXeTdVczR1KytGMVhwYlhtOUZZS2tlK0tIbWFjRk5U?=
 =?utf-8?B?dy9oWVFCY3dneUVnVWJLMWlkMVl0UFJrSkV2MXBpNDgrVjBvbjNWSXlXQkht?=
 =?utf-8?B?VkNVcGloeDZrdzlhVTZVY0s4YkxXNHlMdDFLcTdVd0hzZUtBaHhLdTVJOE9B?=
 =?utf-8?B?dFhlNG8xRHFwSE1kb0t3OTdzQ080RmtnMFBJKzdwcElrc2V3cmRLVld2TG9K?=
 =?utf-8?B?dGZyblNKZzBOTENmT01jSHdBWjVHMXQ4ZWpPblZnWExRUVJhcmM0Y1Q2cHVR?=
 =?utf-8?Q?WF4o+nE0r64=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(1800799024)(8096899003)(13003099007)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?ZHdSTmhvcm93ZHBJdFNsaVJXbHpnSFlrem1HQjBhRy9lbFgwelppb2dvVkhY?=
 =?utf-8?B?NUs1MXU5aENjSFVnUzN4cjNLODNQVHQzSU9CMEhMeC95SUxadDJvbmJoUk5l?=
 =?utf-8?B?WVJiUzVxeFpISGtWLzNSOGRKaHc4OHlLR0p3K0s4M0c5TjVXNWJyblVONzl1?=
 =?utf-8?B?OTFkaTIrRDhLcG96OUx4aG5mSlliZGkrWjQyS0ZPSzhpLzJWSU5CZ0RRTkh5?=
 =?utf-8?B?bG5jZFh6dkxNMy8vK2pRcytoNUM2dXViZkdLMVpmSDgwbDFPYmlTOFQyUExS?=
 =?utf-8?B?c3B2V1ZvRjlFT21hd0xJazJYMWQrRUk1QUNQL1NSZlRzUFVzemZjS3RrVE80?=
 =?utf-8?B?Z0ZMbFhZcVRQWDJzejV4dzgydmt0UjJzZ0lMbmlNYWhITWkwTTlXMDNRNktN?=
 =?utf-8?B?bHQ3cm11T2I5NCthdkNRaWx2UkE2b3Zha0swTm9OVVBNaU9IUFhkT0tRUHNm?=
 =?utf-8?B?azFZa3pnK0J6NWpaTUxtVGg0Vm1tV2dpK01pVVNIK2VLSkZNOWVlZHdlazF4?=
 =?utf-8?B?dFlyczBudDRzcDEzZlRBVCt6dEluOTN2S1VEdDByQk9CMk4vcXZXMkpOejhL?=
 =?utf-8?B?cDc5VlBwSlc2MEdpMkxmMUkxMDN1RmMrVDRYYnJkVFNiWkpVblNXYkdNY0JY?=
 =?utf-8?B?NmJHbUZYNzYzalU2NVExdHNlMTRISzZGS2ZCVmhjNnRWbWVKQzZUVXhTK043?=
 =?utf-8?B?UXdvNWw4UVJLdUxnZWtia2RVQzdvVU53R3RWY3lOa0lIcHpMeEZwMVQ0NGFF?=
 =?utf-8?B?TkVSRkhoY3RTamZ0OEljQ1JpK1hUR3lnMCtqZXpLUlAwY1Bwb0NGNEsvOUVD?=
 =?utf-8?B?eC9aNVlrWFZrVWplNXAvY3JJLzVzMkd0dGhVeU16UjNJM2xGVDB5YmdGUmM0?=
 =?utf-8?B?cGVzSFY1eElaQjllcjlRc0RlcW8zWTZ6dm5KczFvQVU1NXhWR0xNZDRxQVFO?=
 =?utf-8?B?RjJ1KzE2Y2lsZkxJWERlNFU2dVlSbUxsV0VEZk4zVlVMUUo1MWJ1d25hS3lG?=
 =?utf-8?B?NXgzUXNibmpDSlJXYmF3RWw1SEZETm1YYkdaemtnbkg0QzZSWkdUS0ZQRkx0?=
 =?utf-8?B?RmVPSHNyZ1ozcjd1WEdmVVpmM3oweEpQempud21vUElTQTc0cXJuaDJoVW5v?=
 =?utf-8?B?alpGTWFRWlluUGJYL2JNNGxVU1ljR1k0THBuMUFoanVUamgxdDV6aGJKZGVD?=
 =?utf-8?B?SEZ2RURsY3RHWnpNWlhteXFjdHhmUk44RWdyS3FiN1V5TEluQjRVcGtKTVVn?=
 =?utf-8?B?STRMUGcvVUlsNnYrdURVYlBEeTNpUEt4Tm12RUZlNVhqNFdlYTc5cW9MaDRa?=
 =?utf-8?B?VWNqRmtjUytoU0xGWi9kVHBwL0cxUnJNTjh3ZWlnZVJxVGZEL1ZZOEFrdXd3?=
 =?utf-8?B?aVBWbHR0SU9WbXVKT1lrVlFxc1ptWVNsVytJN05kdXN6ZzM1eXdqMHZ3R2VU?=
 =?utf-8?B?UEsxaUZDZ1p1dGVKUlg5VEhUazhrcm5uN3B5M050Sm5VQlQrenE5QTZLQy93?=
 =?utf-8?B?SGNPWFFQRW9BZis0KzdrNzU4MysyK1Y1bTk4OVBCOUZ3bGxxMjd3eE9IL1Nl?=
 =?utf-8?B?S0UyaGFzbDlvRU1vNWFKZmtSekhYN2REMUZ6RFg4d00zbm5PWDFHQ21wVFRT?=
 =?utf-8?B?RXVNOHBOY1I5Y2VBUnVHTVpGc0hFdWJ4N0FXOU1yMnQ5ZmdydnE1WTVpQWJU?=
 =?utf-8?B?TGtSekpSVmd2cGZudncxdFhKTU8zMDVOQmU2cGE3RnEyR0dmREpSVWlRUkFX?=
 =?utf-8?B?THQweHVzTHY1K2lvRDM4Y0VWZjNUdDZBWkNMTk04R1BNNGo5MU5aSTZjUmhR?=
 =?utf-8?B?Q1E3WElJOGIvcVJUbUQxejJUelEwNHFlREt3NDMwZTVFZEJwUkJpY3VlR3dS?=
 =?utf-8?B?U0lOZUR3TG1kaGFPRnJROWU2UzVJd0NYYi9EQmg3ZG5vekI2aUw4Mmx4YnVk?=
 =?utf-8?B?YTdrYmJZWUY3anVIWTN6ZXViZXprWW40akROSmRDNS9CeWpndXF4OHNscmV0?=
 =?utf-8?B?UlQ4VTdUSExiSW1kL0FqVmZMeTJFSkNYUzUyTTcxd0ExTU5QVTdBWjFnZUNG?=
 =?utf-8?B?OUJNYWNmaEphSVliY0hkd0hjNitXS1haVnEwZ3FOaGZJOGdHUjl5Si9Jdm1t?=
 =?utf-8?Q?A0+LYQ0dI6ZzI7RknWos/AfhD?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 2s0IRNgTAF0mbNGCJW0RwJim/iRc8N/gxzez9glp0ZMOtsGsO0EPGihORfYDdJe5kFHIuLaE/Gt3nPNm6/Gtl0p/aV2fGAdNZj0RW8/t9y5Jxs6OO9Ds52kdT435NymZk0bMM6gFrgXGTCVgVSVvIeGp7w823TPl2S7C9iZjuVvIHeX8oBUx0+wRZ/+SKw4+QAHfFB7e/eXIiiezNZJfCjgmHkF4IUclKofYm07nsZ5myPhRpO75k/mJTd0xfKBHCIFnPN/baokFoUodYIAN+mzRCVo7aKp5xCxpLVoSLZv+ass3GI2AIR33EfqDeXT9XTzEA/vWYWQ2BzI/j2sDIleyfEnpN5YgZGFfEJYHmbjibIr7RoHxWfDfmFk6Yj53wJJFA9eEqM+Dd1JcVstiTYESskS5XMzG+gHucL8bSkwVDTpedux4QWlyZvIY+nQ1ndvyCwSpIrqqrCW0GRiQ7IKr2w87UAluoYMSDPXIWVhs81oa+1a/vkGOJRTGWGyi5r352zgVUfr8w13LVWmX5nQQei2pvK0Jy2sLqbk4vT2bG1Zs475qhZOxEUzdtp8oJKlNqUb5UT4SeiVFA6xlVbC/ZPBL+K+KQWNwHWMq/WM8Dvb5Iitf4ZT+kXpsG7SV4S2FSclE/BbWHBWzjF9tCw==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f76d18f2-59e1-444b-00ae-08dd86b1a30c
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Apr 2025 00:06:05.8935 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: E8esTq2FvT+bsscIcR3NqrgaXAzdBOwNLD78PnRok1FFa64z7Cd/C9KLFC//aKiT
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ4PPFD0BA9640B
X-BESS-ID: 1745885171-105655-26061-16651-1
X-BESS-VER: 2019.1_20250422.2023
X-BESS-Apparent-Source-IP: 104.47.70.47
X-BESS-Parts: H4sIAAAAAAACAzXLOw6EMAwE0Lu4prCdONhcBW2B8xENotgUKyHuvimgGY1m9N
 YL6q/DAn3kBOcXFgpko+1jNHJET6iyIWrm0jzVEtmosWiocE+v3/vxeNZZHl9nCWgam9
 mWkwYmiePm4jmZZIf78weC27GWgQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.264224 [from 
 cloudscan17-0.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [lustre-discuss] Beginner: Lustre server compile
 and deploy
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
Content-Type: multipart/mixed; boundary="===============8341716750852556903=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8341716750852556903==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_66BA42BAAA8C4D6DB268CEA2D8214938ddncom_"

--_000_66BA42BAAA8C4D6DB268CEA2D8214938ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

T24gQXByIDI4LCAyMDI1LCBhdCAwOToxNCwgR0VPUkdFIFpIQU8gdmlhIGx1c3RyZS1kaXNjdXNz
IDxsdXN0cmUtZGlzY3Vzc0BsaXN0cy5sdXN0cmUub3JnPiB3cm90ZToNCg0KSGkgR3V5cywNCg0K
SSdtIGEgYmVnaW5uZXIgb2YgTHVzdHJlIGFuZCBrZXJuZWwgZGV2ZWxvcG1lbnQuIFNwZW5kIHdl
ZWtzIHRvIGZpZ3VyZSBvdXQgaG93IHRvIGJ1aWxkIEx1c3RyZSBzZXJ2ZXIgZnJvbSBzb3VyY2Ug
Y29kZS4gQnV0IHJlYWNoIG5vd2hlcmUuDQoNClRoZSB3aWtpIGlzIGZvciBSSEVMNywgd2hpY2gg
aXMgdG9vIG9sZC4gQWx0aG91Z2gsIFJIRUwgc3Vic2NyaXB0aW9uIGlzIGV4cGVuc2l2ZS4NCg0K
TWF5YmUgVWJ1bnR1IGlzIGEgYmV0dGVyIGNob2ljZSBmb3IgbWU/IFRoZXJlIGlzIGEgY29uZmx1
ZW5jZSBwYWdlIGZvciBidWlsZGluZyB3aXRoIGxkaXNrZnMsIG5vdCB6ZnMuIE1heWJlIHpmcyBp
cyBzaW1wbGVyPyBJJ20gbm90IHN1cmUuDQoNCk15IGdvYWwgaXMgYmVpbmcgYWJsZSB0byBjb250
cmlidXRlIHRvIEx1c3RyZSwgc28gSSBuZWVkIHRvIGJ1aWxkIGZyb20gc291cmNlIGNvZGUuIE9m
ZmljaWFsIFJQTXMgZG9lc24ndCBtYXRjaGVzIEFXUyBBTUkga2VybmVsIHZlcnNpb24sIHRoYXQn
cyBhbiBvdGhlciByZWFzb24uDQoNClRoZSBUTDtEUiB0byBtYWtlIEx1c3RyZSBzZXJ2ZXIgY29k
ZSBpcyB0aGUgc2FtZSBhcyB0aGUgY2xpZW50LCByZWdhcmRsZXNzIG9mIHRoZSBrZXJuZWwgZGlz
dHJvOg0KDQpiYXNoIGF1dG9nZW4NCi4vY29uZmlndXJlDQptYWtlIChvciAibWFrZSBycG1zIikN
Cg0KdGhlIGltcG9ydGFudCBjYXZlYXQgaXMgdGhhdCB5b3UgbmVlZCB0aGUgc291cmNlIGNvZGUg
Zm9yIGZzL2V4dDQvLiAgSWYgeW91IGRvd25sb2FkIGFuZCBpbnN0YWxsIGEgcHJlLWJ1aWx0IGtl
cm5lbCAoaW5jbHVkaW5nIC5zcmMucnBtIGFuZCBrZXJuZWwtZGVidWcpIGZvciB5b3VyIGRpc3Ry
byBmcm9tIGh0dHBzOi8vYnVpbGQud2hhbWNsb3VkLmNvbS88aHR0cDovL2J1aWxkLndoYW1jbG91
ZC5jb20vPiB0aGVuIHlvdSBkb24ndCBuZWVkIHRvIHdvcnJ5IGFib3V0IHRoYXQgc3RlcC4gIFBh
dGNoaW5nIHRoZSBrZXJuZWwgaXMgbm90IHN0cmljdGx5IHJlcXVpcmVkIGZvciBzZXJ2ZXIga2Vy
bmVscyAoZWl0aGVyIGxkaXNrZnMgb3IgWkZTKSwgYnV0IHdpdGggbGRpc2tmcyB5b3UgbmVlZCB0
byBoYXZlIHBhdGNoIHNlcmllcyB0aGF0IG1hdGNoZXMgdGhlIGluLWtlcm5lbCBleHQ0IGNvZGUu
DQoNCkNoZWVycywgQW5kcmVhcw0K4oCUDQpBbmRyZWFzIERpbGdlcg0KTHVzdHJlIFByaW5jaXBh
bCBBcmNoaXRlY3QNCldoYW1jbG91ZC9ERE4NCg0KDQoNCg0K

--_000_66BA42BAAA8C4D6DB268CEA2D8214938ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <E8E929DB4DE327419AECA173A0D1B231@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWw+DQo8aGVhZD4NCjxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIgY29udGVudD0i
dGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04Ij4NCjwvaGVhZD4NCjxib2R5IHN0eWxlPSJvdmVyZmxv
dy13cmFwOiBicmVhay13b3JkOyAtd2Via2l0LW5ic3AtbW9kZTogc3BhY2U7IGxpbmUtYnJlYWs6
IGFmdGVyLXdoaXRlLXNwYWNlOyI+DQpPbiBBcHIgMjgsIDIwMjUsIGF0IDA5OjE0LCBHRU9SR0Ug
WkhBTyB2aWEgbHVzdHJlLWRpc2N1c3MgJmx0O2x1c3RyZS1kaXNjdXNzQGxpc3RzLmx1c3RyZS5v
cmcmZ3Q7IHdyb3RlOjxicj4NCjxkaXY+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIj48YnIgY2xh
c3M9IkFwcGxlLWludGVyY2hhbmdlLW5ld2xpbmUiPg0KPGRpdj4NCjxkaXYgZGlyPSJhdXRvIj5I
aSBHdXlzLA0KPGRpdiBkaXI9ImF1dG8iPjxicj4NCjwvZGl2Pg0KPGRpdiBkaXI9ImF1dG8iPkkn
bSBhIGJlZ2lubmVyIG9mIEx1c3RyZSBhbmQga2VybmVsIGRldmVsb3BtZW50LiBTcGVuZCB3ZWVr
cyB0byBmaWd1cmUgb3V0IGhvdyB0byBidWlsZCBMdXN0cmUgc2VydmVyIGZyb20gc291cmNlIGNv
ZGUuIEJ1dCByZWFjaCBub3doZXJlLjwvZGl2Pg0KPGRpdiBkaXI9ImF1dG8iPjxicj4NCjwvZGl2
Pg0KPGRpdiBkaXI9ImF1dG8iPlRoZSB3aWtpIGlzIGZvciBSSEVMNywgd2hpY2ggaXMgdG9vIG9s
ZC4gQWx0aG91Z2gsIFJIRUwgc3Vic2NyaXB0aW9uIGlzIGV4cGVuc2l2ZS48L2Rpdj4NCjxkaXYg
ZGlyPSJhdXRvIj48YnI+DQo8L2Rpdj4NCjxkaXYgZGlyPSJhdXRvIj5NYXliZSBVYnVudHUgaXMg
YSBiZXR0ZXIgY2hvaWNlIGZvciBtZT8gVGhlcmUgaXMgYSBjb25mbHVlbmNlIHBhZ2UgZm9yIGJ1
aWxkaW5nIHdpdGggbGRpc2tmcywgbm90IHpmcy4gTWF5YmUgemZzIGlzIHNpbXBsZXI/IEknbSBu
b3Qgc3VyZS48L2Rpdj4NCjxkaXYgZGlyPSJhdXRvIj48YnI+DQo8L2Rpdj4NCjxkaXYgZGlyPSJh
dXRvIj5NeSBnb2FsIGlzIGJlaW5nIGFibGUgdG8gY29udHJpYnV0ZSB0byBMdXN0cmUsIHNvIEkg
bmVlZCB0byBidWlsZCBmcm9tIHNvdXJjZSBjb2RlLiBPZmZpY2lhbCBSUE1zIGRvZXNuJ3QgbWF0
Y2hlcyBBV1MgQU1JIGtlcm5lbCB2ZXJzaW9uLCB0aGF0J3MgYW4gb3RoZXIgcmVhc29uLjwvZGl2
Pg0KPC9kaXY+DQo8L2Rpdj4NCjwvYmxvY2txdW90ZT4NCjxicj4NCjwvZGl2Pg0KPGRpdj5UaGUg
VEw7RFIgdG8gbWFrZSBMdXN0cmUgc2VydmVyIGNvZGUgaXMgdGhlIHNhbWUgYXMgdGhlIGNsaWVu
dCwgcmVnYXJkbGVzcyBvZiB0aGUga2VybmVsIGRpc3Rybzo8L2Rpdj4NCjxkaXY+PGJyPg0KPC9k
aXY+DQo8ZGl2PmJhc2ggYXV0b2dlbjwvZGl2Pg0KPGRpdj4uL2NvbmZpZ3VyZTwvZGl2Pg0KPGRp
dj5tYWtlIChvciAmcXVvdDttYWtlIHJwbXMmcXVvdDspPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2
Pg0KPGRpdj50aGUgaW1wb3J0YW50IGNhdmVhdCBpcyB0aGF0IHlvdSBuZWVkIHRoZSBzb3VyY2Ug
Y29kZSBmb3IgZnMvZXh0NC8uICZuYnNwO0lmIHlvdSBkb3dubG9hZCBhbmQgaW5zdGFsbCBhIHBy
ZS1idWlsdCBrZXJuZWwgKGluY2x1ZGluZyAuc3JjLnJwbSBhbmQga2VybmVsLWRlYnVnKSBmb3Ig
eW91ciBkaXN0cm8gZnJvbSZuYnNwOzxhIGhyZWY9Imh0dHA6Ly9idWlsZC53aGFtY2xvdWQuY29t
LyI+aHR0cHM6Ly9idWlsZC53aGFtY2xvdWQuY29tLzwvYT4mbmJzcDt0aGVuIHlvdQ0KIGRvbid0
IG5lZWQgdG8gd29ycnkgYWJvdXQgdGhhdCBzdGVwLiAmbmJzcDtQYXRjaGluZyB0aGUga2VybmVs
IGlzIG5vdCBzdHJpY3RseSByZXF1aXJlZCBmb3Igc2VydmVyIGtlcm5lbHMgKGVpdGhlciBsZGlz
a2ZzIG9yIFpGUyksIGJ1dCB3aXRoIGxkaXNrZnMgeW91IG5lZWQgdG8gaGF2ZSBwYXRjaCBzZXJp
ZXMgdGhhdCBtYXRjaGVzIHRoZSBpbi1rZXJuZWwgZXh0NCBjb2RlLjwvZGl2Pg0KPGRpdj48YnI+
DQo8L2Rpdj4NCjxkaXY+DQo8ZGl2IGRpcj0iYXV0byIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2Io
MCwgMCwgMCk7IGNvbG9yOiByZ2IoMCwgMCwgMCk7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IHRl
eHQtYWxpZ246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9uZTsg
d2hpdGUtc3BhY2U6IG5vcm1hbDsgd29yZC1zcGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4dC1zdHJv
a2Utd2lkdGg6IDBweDsgdGV4dC1kZWNvcmF0aW9uOiBub25lOyBvdmVyZmxvdy13cmFwOiBicmVh
ay13b3JkOyAtd2Via2l0LW5ic3AtbW9kZTogc3BhY2U7IGxpbmUtYnJlYWs6IGFmdGVyLXdoaXRl
LXNwYWNlOyI+DQo8ZGl2IGRpcj0iYXV0byIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwg
MCk7IGNvbG9yOiByZ2IoMCwgMCwgMCk7IGxldHRlci1zcGFjaW5nOiBub3JtYWw7IHRleHQtYWxp
Z246IHN0YXJ0OyB0ZXh0LWluZGVudDogMHB4OyB0ZXh0LXRyYW5zZm9ybTogbm9uZTsgd2hpdGUt
c3BhY2U6IG5vcm1hbDsgd29yZC1zcGFjaW5nOiAwcHg7IC13ZWJraXQtdGV4dC1zdHJva2Utd2lk
dGg6IDBweDsgdGV4dC1kZWNvcmF0aW9uOiBub25lOyBvdmVyZmxvdy13cmFwOiBicmVhay13b3Jk
OyAtd2Via2l0LW5ic3AtbW9kZTogc3BhY2U7IGxpbmUtYnJlYWs6IGFmdGVyLXdoaXRlLXNwYWNl
OyI+DQo8ZGl2PkNoZWVycywgQW5kcmVhczwvZGl2Pg0KPGRpdj7igJQ8L2Rpdj4NCjxkaXY+QW5k
cmVhcyBEaWxnZXI8L2Rpdj4NCjxkaXY+THVzdHJlIFByaW5jaXBhbCBBcmNoaXRlY3Q8L2Rpdj4N
CjxkaXY+V2hhbWNsb3VkL0RETjwvZGl2Pg0KPC9kaXY+DQo8YnIgY2xhc3M9IkFwcGxlLWludGVy
Y2hhbmdlLW5ld2xpbmUiPg0KPC9kaXY+DQo8YnIgY2xhc3M9IkFwcGxlLWludGVyY2hhbmdlLW5l
d2xpbmUiPg0KPGJyIGNsYXNzPSJBcHBsZS1pbnRlcmNoYW5nZS1uZXdsaW5lIj4NCjwvZGl2Pg0K
PGJyPg0KPC9ib2R5Pg0KPC9odG1sPg0K

--_000_66BA42BAAA8C4D6DB268CEA2D8214938ddncom_--

--===============8341716750852556903==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8341716750852556903==--
