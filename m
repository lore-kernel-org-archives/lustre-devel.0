Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8A6E9C02182
	for <lustre-devel@archiver.kernel.org>; Sat, 25 Jan 2025 06:41:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yg4nw1sCcz20tg;
	Fri, 24 Jan 2025 22:41:08 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yg4nr6Q2Hz1wYs
 for <lustre-devel@lists.lustre.org>; Fri, 24 Jan 2025 22:41:04 -0800 (PST)
Received: from NAM12-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam12lp2174.outbound.protection.outlook.com [104.47.59.174]) by
 mx-outbound45-109.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sat, 25 Jan 2025 06:41:01 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=yIROyMBiPjyYQaq9ZNRpTRrbmUHgO6CY73t4e4frHaYmH8Py2N47qKm48Ij8OqHCgQg9x7IfMyVHGzzZJr8C+SM5kGej3EL9blH3BnpeE172yip7mu3dZTz8zq91Kkw1IG8MYfvjK1KXKcq0ChNEpGozUFo8Rv0cDS24E5Jukhdl2tnVled6XQkXSUcAphIIbMd/2mDiUc+6etFV35pTCuO71YS4VVGVJqMLJuFxsvFjaJHI1Sqmo5m2Odac4IBDA8OyNFDrpg84CihjB/MByYaXAmq8QMFCuyoCBdImNthS5osAaSpzRW3KL6jDq4zqcYYUw43/Ja/H6IwqHPvHGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=vTc2Z0Gt9ei2JpIiC1sLEd294R7IBaZaXLyWj+42UTc=;
 b=UAPbjTr6KLJLVpkhZyFiy9q+d6KoCpuLjgRE6j6+6QDVL9kUdgKtq/dCHcWsajmzK4DEw96p82vf4dsKIJz85X01MseApkqoBF025TqwdOmEi1ym8Hlq8NrufzlXLP5pN3TwLf9vLCUD8LDws5kueTB6391jq0ZTAsHJhcAfC7rarlG8gLjHGgLgcqZQpPL7yfECEV8CfmycTI+fIlXEgjS5hll7AnLwbPUt8/qmuWEKb4NjNpmGv8+jjEbl+Vb/81brfAQweKdSel6nuT2XLX+LzD5yNugW6ZXyMuoK9gwHTTiB/wLxCtu1Lrz6Fl+Wx1LLE5IVCl7WT8m5fAVRbg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vTc2Z0Gt9ei2JpIiC1sLEd294R7IBaZaXLyWj+42UTc=;
 b=3Nclepcrk3/vyUoKOBu+CYxcu8FS1xbdoXqanOnpvD+V8UiMr49ROWFvKJqNa14FhzDcwhzYGd9uRqpZUVCO35HCGgor2s1L6kigdipWo55PTI556PawMwvZGQtSINMp9Aqzf3+uhj62Jzp++lej1mrilWA1uW7R2UpIJaXRUMk=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by CY8PR19MB6988.namprd19.prod.outlook.com (2603:10b6:930:5b::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8377.18; Sat, 25 Jan
 2025 06:40:58 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8377.009; Sat, 25 Jan 2025
 06:40:58 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "neilb@suse.de" <neilb@suse.de>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAA==
Date: Sat, 25 Jan 2025 06:40:58 +0000
Message-ID: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
References: <>	 ,
 <3fdc18162e44a6acf3e6131c18c6aec6e5779b7c.camel@whamcloud.com>
 <173776032838.22054.6873652938340835566@noble.neil.brown.name>
In-Reply-To: <173776032838.22054.6873652938340835566@noble.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|CY8PR19MB6988:EE_
x-ms-office365-filtering-correlation-id: b3d41e2a-ee93-4b02-3d37-08dd3d0b3a04
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|376014|366016|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?U1lFTmNwNUEzWFhpRnFpK1RDc3M5RVZPaWRMdWtrNVBtdEtuR0d6VWpMbEYv?=
 =?utf-8?B?SHJnY2xham85Yi9xL3JHT1owME4wU0NSNEJOZUNDRFI1bzRqK0tmSDJzcHZK?=
 =?utf-8?B?Zks0alhpYWpORjRRL2prRTRWdmU5V25CSThES0NNTEhUZDUyZTVyNElPay8y?=
 =?utf-8?B?K1ZCRE5zMUpqMkloN2JuYXJRdGVvcnZCNXgwR1NVQUtIVHBYZ3dzUlpEczBH?=
 =?utf-8?B?djcyekZVVVc2L1c3dittTElJSDFiYkt1YzRJa3ZsdjdZRE5OWEY2dEJHY25k?=
 =?utf-8?B?NnJuUnM5aVJDQUNnbThpOUZIVTEyYjQydlZBbVRicFppNms2Y2FlSGI1UWVE?=
 =?utf-8?B?eTBPTExZTENNU0I4SzMwaldGd2x4R2dveGZ3WVZJT2JEb2xPVERrcmFteU9H?=
 =?utf-8?B?Z1dNaFdRRW1Hcm1LeDFiQks2L0tDaWh3ZkFtb3ExTW9LbHArVjlLaUREOFJK?=
 =?utf-8?B?KzhOdmtDeE5EbXNna3pISHlEZDN1dDdvWlA3dHorcyt2aGJJSHdnTzUrMzBM?=
 =?utf-8?B?WFhGc3c0MnhDZFI0amhrVWMvZUlLaXpOSDhhZ0liRXh0TFo2YmUxZ0RRVEtO?=
 =?utf-8?B?UGtGZmlSYlRPQmNMb3lSS1VZaTRVQlZrRFNvaFhnMWpPUy9wRmV4Z0NoclBt?=
 =?utf-8?B?OEsrMVlFTzhOS1VMTENtRXlLUnEvZGFMRGIra1JPcS9BV1dGRXlpb2JOdUp2?=
 =?utf-8?B?S0gzOFVvektPaERtTUlhRDFhNmcxL3Z3SzFNcnlzWjhzTkNMMmhndVNTNE1X?=
 =?utf-8?B?ZlZUdTNaemJHR0hsVlZCTUM4elFicHQ5SDcvSDJYSGM5b2FXOXNaWndISGFV?=
 =?utf-8?B?RXRCVld1YVpwbDZwRDZPR3E3K3NndlFXdjRTQ1dVZ2JZMDM5djZkVkpUdHlH?=
 =?utf-8?B?UXhzckRRVGhJUkQzb3dsNUYwWlAzZkJmMUg1UHVzRVFOTWV3VEJwZnZpZFNv?=
 =?utf-8?B?UDFGS1NtSnI4TW94RDZSWGwzQ3BsNWVOTytjalF0QzNkTENKdERKY2Q3MHVo?=
 =?utf-8?B?V0V1THZ1c2I0UFpZeGhsRHpVZ1orak14dDNGaGVRdFd0U1BMZXNVVFpUOTV5?=
 =?utf-8?B?QlArWUVmWHBBYm9CZTIyRVN6eTd5RzNsaTYyaFdpd1pQRE0xYXpEMmpxVE9w?=
 =?utf-8?B?SnJoVjU5S0pwTVlOSk9WREhQOFB4MnNKbmwxT2JmangyR0toeHVGd1FqS3JK?=
 =?utf-8?B?N2JVcUJyUUNzb2FkQ0NYSVhqMjlCSXZ6K1NzNktsUkVaWk9qS1dnRWpoZjRr?=
 =?utf-8?B?d1BudTdZcEtFeWh6TUhscmNXVE4wc2Z2TUR4U2Q5MElwdWl6TjlLSFloeFlB?=
 =?utf-8?B?N2puTk40WW11K2FXcm1ld09sdmh2Y3J6OXJnZEhBNEYxQ3p1YmYyYTc1T1lh?=
 =?utf-8?B?ZlFPNGNEcTVobFVHVjF1WTk2TnNnNU5sTmdCZklhV3Fva0NQcFMvZXMxMUor?=
 =?utf-8?B?aHNxTUcvcXhVbjM5bk5qUDY4ZkNjUDIzSnNSR0U2RlpkLzVQYzE2SjlJK0Jy?=
 =?utf-8?B?VkdaS0hISHlyVjBNTGw3K2RDMFR1bkNLcUF2WTFiUy9iSWZPQVJteSs4OFhT?=
 =?utf-8?B?dXJQanFOd1pEMWVTZXkxdGtzUmM5TU9SbnZHanZsTTIxN1RzVXViYm5kK0VU?=
 =?utf-8?B?Zjh2YnF5OU4wR0ZFN0VrTkVCdE41UjNBNElUa2hESm9VVDRVc1BMbjZqdEVK?=
 =?utf-8?B?T3JIMHdjVkFsV3ZCa2R6S3hYTEg4dHI0cDFqUGJ5ZHZNVFdQQ0IwUVZ6RS9B?=
 =?utf-8?B?eWhaUzZ1Z0FXbU1vNnJHN0ZRUHA3OW1RZlpSSnk1UG9QaHczb0pEZTQzUEFR?=
 =?utf-8?B?ZVpKUTA4UnczRWNBa01RcHZsNDRnL2ZWbHAxWTRocWp4TmNxVUdzYW0vMi9F?=
 =?utf-8?B?amZWV0lBRGYySWhPUURvSXF3RWp1NnppSVltL1BOZ0NHN0ZPUVBFa2R0RGZv?=
 =?utf-8?Q?+b5DRH6y2q2ryKsan1jMqVyzHp33EzDB?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?YlFleUtyZkphK05GRVNDMzhHcVpGNkM0NllCbVBFZ01CaURGVVA0SWxDVVpm?=
 =?utf-8?B?elcwYjliVm5HV3J3dUhTSmdQa2xJc2tiSEpEbS9UMUFQaFBMa0FkVUlORUo4?=
 =?utf-8?B?ektaQUFNS05TMlQ5SndLSHgyTXdxWFhRNDAvNm1vSzdrR2NsYmlNZzVxSXpu?=
 =?utf-8?B?RGNOaTRHMVpqRC9CbmYxNjJXZWRQankrWmNjMkFNU051QnNoL2JtZnY1YSt6?=
 =?utf-8?B?S2l4TDdDN1VVTW41ZU1zTzhMRTNLekN4SVEzTVpGd05NNWI5bmNmWnYxOFNN?=
 =?utf-8?B?REh6UHVzMTBDRjVUaGo2OWM4UTBuVGdoaGNRRTB5THVaTnFWaGRpQWhPSk9z?=
 =?utf-8?B?ZWR6elpzb1hadlVrdFVSTUplZHN1UzR0NC9WcWR3b0lIMUgybjZUUUU5aW44?=
 =?utf-8?B?L0RVM0xabE1OS2RGUUsrcXM5emplWVRhdjAwb2lCYUVJVEk3cnRiOTQ1NzBE?=
 =?utf-8?B?N2JndVBXMk5rck9MQTZHbEJ0UEJydG9rNUYwdUJLUGoyYTlkTjl0MlFHemdY?=
 =?utf-8?B?c09FOVRVNDNPR2RzOWdkd3J2bGFQNTJCRnQ1OVpvbUhHcTlZenhDdmRBN1JP?=
 =?utf-8?B?M1lMTzg2cmxZUzlHbVdDQ2JDUGRYMFFyUExmblpHdjJIYmRVa25GT2RteklL?=
 =?utf-8?B?RHFXREdtRTRMWjJMbjJYVWJyaVJPKzhXTjBISUtWN3ZhdnZLcWFvbUppQTJH?=
 =?utf-8?B?RDZnTHpTUDQ4Rk1EWDdIUUhQNE1uc2FhMHd3dUVxWkRzUGpBdzFvbzBVOVBa?=
 =?utf-8?B?eXZDT1NUU1d6Y2orTFhoUGhsR0lHT0NaalVXM0UyMzFiM3N6bkZINmVZTUtT?=
 =?utf-8?B?bllLZkF4THoxRjU1eW5uS3hIM1FMK1FFYVpLZDgzUmVheUVVRlJxbXpra2Jl?=
 =?utf-8?B?TUlQSVE1YnNySjBMa3VXYkNlRUN6UzhoUkx5bTgxb0huUFJEMHZXQnB1TWcx?=
 =?utf-8?B?bVNvUG1JaUM3c1pYMEJVTlp2UWxVeEhPWVg4Z3o1SXRhNnZDK0FXME9wZkty?=
 =?utf-8?B?TUtEajdmQlRscHdaSUlGVGg0UEpuR1hWL0R6bXNIR2l0TFQ0dVFsUDVSSFpL?=
 =?utf-8?B?K1d2OE5zMjB0ZlljaHY4VmVUUEFQQ3ZUV0p1ejBacjFOdlYrdXdzRllmaTRV?=
 =?utf-8?B?eXNYZGoyS09qclRjc01VYzNEOTdjdnQ2MFo5TVBTMUpJVkJFZGhTOHI3bU9E?=
 =?utf-8?B?TE42TDM1dTZyMjI0dTlkZ2s1M2JBS1k2OEdoY2ZCRElickZsVWtGeGcwRWpi?=
 =?utf-8?B?WEhsdW9yeXFwNWxxR25LMHQzeWtJc2hQYjBDYThvdFpaU1pKZzR2MG5HOW5u?=
 =?utf-8?B?disxQlROanhwR2lOOVNhcUwxdjBtYWQ5SEsyS2FJNk54OFU5YTd1RFFmQ2Zo?=
 =?utf-8?B?Q2tlUVdIam00eVd6eG85eUJIQjVRUlRSVjlRNUxvUE0vc3NBOGcvZEhaK2w1?=
 =?utf-8?B?UmNLbk1rMjNIbWRtaW9pNTlIb3NldUE4UFAyc2dWZlI0NWJDS3NwNDZXWXFX?=
 =?utf-8?B?TDRPb2JrUEdHenJ0QnFZQTlQQjBJQjR0WWN1M2ZFODkvZGZDRWV1RmI1dHVP?=
 =?utf-8?B?VHc3VzFnVTIwRDNIRUwydlBJRW1NWHQxVHMzZ2Q0WnRyN0JYdWZzZ3ozZGJH?=
 =?utf-8?B?UXIwcEJMVFBHSnhiL1MxRklkdGkzZ3NNcnVXMldIemtYRi9GV3M4TDVEVWtS?=
 =?utf-8?B?b1psM1lkTFFFbWYvNkZ5M0FheGltZ0x5RDhEN3lzdW5RcUJHSzJrNllmNHZ4?=
 =?utf-8?B?TWJRWnFMbEJ0T0hPZXBxQzB3VGxENHdtMmlZMzhBSTRsZ3dHMDhkcDg4czBh?=
 =?utf-8?B?WmNuNTRMRzhxTGF0UEtIUFdYSzhiS202U2hEVXhZQWNTVVhRL2NkNnVMWHpj?=
 =?utf-8?B?MG5zczFPbTRYWE16TFZPQ3RaMVZaa2tVaytGS3pxV1JLY2syeVBKN3d1T2Vy?=
 =?utf-8?B?RWcyOWdkMzlXWjAzUlBOZXJjVVRjbzFHS2IxY3lRV3NlbXdUNWVKOUNBVkZT?=
 =?utf-8?B?LzRmV2sxVWFIdzlqcjg3VVNEUUxhZGE2dlNIOTNLVnhUaWt6cHZEK2syWmtj?=
 =?utf-8?B?OEFsS0VSUXdWMXRiYklxM2h3QlltWlJseFJlWGg2MkxmUXV5OXBEOWpwVlUz?=
 =?utf-8?Q?hIgbuAZsjmcQAZrhrpnvjd0xC?=
Content-ID: <295B0D24BF8E874A9E6ED8D3AC797B31@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: a5LBKkgylBfpYbG48fdMgS3qjlV59y53C+cDutpe25ai+twY9b493UPnrTqO/0NnExJLgUgOY4v7LAUtJKDL54NlA0wlsh4srb7em2paV9XPYYwfcdixmvVRx/08sFx3NpeEMw/10Ro0zrA+aT2LSj1MRsF24mLAo8Rgx63zxZoTkQEt5Y6f52v6mLNXJdmYLY0nwGJM6mswHJBI8g91D/LYs4tnWGjDGPx2Sjigte55yBJ7PjPabuf/TyU76WphlZeZY9fU8M0KdDgjZdoPV3plFd+JxuhSTxrSy5J+spVdO7jySCOiUWWQXY+EiosPOKGt4e8fGLi8AVZq/Tj8895GQwdipfHdcp06HcvKOM5GwDpz7998qYxHclup5+inTrQp1P3FhxvD6ytmy9NtKZyvp1NuA0rNM/MOD/+VZun6jzHQNaypee/7p99bSCpiqEDHML1J9xP7VH1isQGkHc67VjCQiPouq+5htNKN1pL+o0Vlr6Nq8X6CRwNgxsT4jQ4ONd3WaNeNw+UsAKK2NAmVFPZhLuRCviPwELMPAda8Y6VBUda2GhFN/4R69U5cp1+3ATCjxfXJ55oBa29z958waC/iNYPnLtHG9FnSCPTZy0/jfhTjCUgaQvBT7nW/3OXKG+cup1sV/ObhNtrA5ZIck7g/L2aM7luBuGGKKwQ=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b3d41e2a-ee93-4b02-3d37-08dd3d0b3a04
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jan 2025 06:40:58.3698 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 2s8UZMnLIIUjDCHT3NdZo7hKqezdmhFVoP/owPKnSg41GSHnD3pmBl8H+rYqwpLA
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY8PR19MB6988
X-BESS-ID: 1737787260-111629-16339-25873-1
X-BESS-VER: 2019.1_20250123.1616
X-BESS-Apparent-Source-IP: 104.47.59.174
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkYWBhZAVgZQ0Ngy2dwozczAPC
 XRxCTVIMnYwsQiNdHc0tgi2dI81cJIqTYWAHbE5QBBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262041 [from 
 cloudscan16-76.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
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

T24gU2F0LCAyMDI1LTAxLTI1IGF0IDEwOjEyICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IE9u
IE1vbiwgMjAgSmFuIDIwMjUsIE9sZWcgRHJva2luIHdyb3RlOg0KPiA+IE9uIFN1biwgMjAyNS0w
MS0xOSBhdCAwOTo0OCArMTEwMCwgTmVpbEJyb3duIHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBPbmNl
IHRoZSB0cmFuc2l0aW9uIGNvbXBsZXRlcyB0aGVyZSB3aWxsIHN0aWxsIGJlIHByb2Nlc3MNCj4g
PiA+IGRpZmZpY3VsdGllcywNCj4gPiA+IGJ1dCB0aGVyZSBhcmUgcGxlbnR5IG9mIG9mIHByb2Nl
c3MgZGlmZmljdWx0aWVzIG5vdyAoZ2Vycml0OiBob3cNCj4gPiA+IGRvIEkNCj4gPiA+IGhhdGUg
dGhlZSwgbGV0IG1lIGNvdW50IHRoZSB3YXlzLi4uKSBidXQgcGVvcGxlIHNlZW0gdG8gc2ltcGx5
DQo+ID4gPiBpbmNsdWRlDQo+ID4gPiB0aGF0IGluIHRoZSBjb3N0IG9mIGRvaW5nIGJ1c2luZXNz
Lg0KPiA+IA0KPiA+IGl0J3MgYmVlbiBhd2hpbGUgc2luY2UgSSBkaWQgcGF0Y2ggcmV2aWV3cyBi
eSBlbWFpbHMsIGJ1dCBJIHRoaW5rDQo+ID4gZ2Vycml0IGlzIG11Y2ggbW9yZSB1c2VyLWZyaWVu
ZGx5IChpZiB5b3UgaGF2ZSBpbnRlcm5ldCwgYW55d2F5KQ0KPiANCj4gSSBndWVzcyBpdCBpc24n
dCBleGFjdGx5IHRoZSBnZXJyaXQgaW50ZXJmYWNlIGJ1dCBtb3JlIHRoZSB3b3JrZmxvdw0KPiB0
aGF0DQo+IGl0IGVuY291cmFnZXMsIG9yIGF0IGxlYXN0IGVuYWJsZXMuDQo+IFRoZSBjdXJyZW50
IHdvcmtmbG93IHNlZW1zIHRvIGJlICJwYXRjaCBhdCBhIHRpbWUiIHJhdGhlciB0aGFuDQo+ICJw
YXRjaHNldA0KPiBhdCBhIHRpbWUiLg0KPiBUaGUgZmFjdCB0aGF0IHlvdSBjaGVycnktcGljayBw
YXRjaGVzIGludG8gbWFzdGVyIGlzIGNvbXBsZXRlbHkNCj4gZGlmZmVyZW50IHRvIGhvdyBtb3N0
IChhbGw/KSBvZiB0aGUgdXBzdHJlYW0gY29tbXVuaXR5IHdvcmtzLsKgIEl0DQo+IG1lYW5zDQo+
IHRoYXQgd2hvbGUgc2VyaWVzIGlzbid0IHZpc2libGUgaW4gdGhlIGZpbmFsIGdpdCB0cmVlIHNv
IHdlIGxvc2UNCj4gY29udGV4dC7CoCBBbmQgaXQgc2VlbXMgdG8gbWVhbiB0aGF0IGEgbG9uZyBz
ZXJpZXMgdGFrZXMgYSBsb29vb29vbmcNCj4gdGltZQ0KPiB0byBsYW5kIGFzIGl0IGRyaWJibGVz
IGluIHRvIG1hc3Rlci4NCg0KSW4gZmFjdCB0aGUgd2hvbGUgc2VyaWVzIGlzIHZpc2libGUgaW4g
Z2Vycml0IGlmIHlvdSBzdWJtaXQgaXQgYXMgc3VjaC4NCkJ1dCBhcyB5b3Ugbm90ZWQgbGF0ZXIg
dGhlIHRlc3RpbmcgaXMgdW5mb3J0dW5hdGVseSBtdWNoIGxlcyByZWxpYWJsZQ0KdGhhbiB3ZSB3
YW50LCBhbmQgYmVjYXVzZSB3ZSBvbmx5IGxhbmQgdGhpbmdzIGluIG9yZGVyIHRoZXkgYXJlDQpz
dWJtaXR0ZWQgaW4gdGhlIHNlcmllcyAtIGlmIHlvdSBidW5jaCB1bnJlbGF0ZWQgc3R1ZmYgYWxs
IHRvZ2V0aGVyDQpzdWRkZW5seSBpdCBtaWdodCB0YWtlIG11Y2ggbG9uZ2VyIHRvIGxhbmQuDQoN
Cj4gSSB3b3VsZCBNVUNIIHJhdGhlciB0aGF0IGEgd2hvbGUgc2VyaWVzIHdhcyBhY2NlcHRlZCBv
ciByZWplY3RlZCBhcyBhDQo+IHdob2xlIC0gYW5kIHdhcyBtZXJnZWQgcmF0aGVyIHRoYW4gY2hl
cnJ5LXBpY2tlZCB0byBrZWVwIGNvbW1pdCBpZHMNCj4gc3RhYmxlLg0KDQpHZXJyaXQgaGFzIHN1
Y2ggYSBtb2RlLCBidXQgd2UgZGVjaWRlZCBpdCBkb2VzIG5vdCB3b3JrIHdlbGwgZm9yIHVzIGZv
cg0KYSB2YXJpZXR5IG9mIHJlYXNvbnMuDQoNCj4gVGhlcmUgYXJlIHRpbWVzIHdoZW4gSSB3b3Vs
ZCBsaWtlIHRoZSBmaXJzdCBmZXcgcGF0Y2hlcyBvZiBhIHNlcmllcw0KPiB0bw0KPiBsYW5kIGVh
cmxpZXIsIGJ1dCB0aGF0IHNob3VsZCBiZSB1cCB0byB0aGUgc3VibWl0dGVyIHRvIHNwbGl0IHRo
ZQ0KPiBzZXJpZXMuIA0KDQpCdXQgeW91IGNhbm5vdCBpZiB0aGVzZSBsYXRlciBwYXRjaGVzIGRv
IGRlcGVuZCBvbiB0aGUgZWFybGllciBvbmVzPw0KDQo+IEFuZCB0aGUgYXV0b21hdGljIHRlc3Rp
bmcgaXMgYSByZWFsIHBhbmUuwqAgQ2VydGFpbmx5IGl0IGlzIHZhbHVhYmxlDQo+IGJ1dA0KPiBp
dCBoYXMgYSByZWFsIGNvc3QgdG9vLsKgIFRoZSBmYWxzZSBwb3NpdGl2ZXMgYXJlIGEgbWFqb3Ig
cGFuZS7CoCBJDQo+IHdvdWxkDQo+IHJhdGhlciBhbnkgdGVzdCB0aGF0IHdhc24ndCByZWxpYWJs
ZSB3ZXJlIGRpc2FibGVkIChvZiBmaXhlZCkgYXMgYQ0KPiBwcmlvcml0eS7CoCBPciBhdCBsZWFz
dCBtYWRlIG5vbi1mYXRhbC4NCj4gQWxzbywgaXQgd291bGQgYmUgbXVjaCBuaWNlciBpZiB0aGUg
bGFzdCBpbiBhIHNlcmllcyB3ZXJlIHRlc3RlZA0KPiBmaXJzdA0KPiBhbmQgaWYgdGhhdCBmYWls
ZWQgdGhlbiBkb24ndCB3YXN0ZWQgcmVzb3VyY2VzIHRlc3RpbmcgYWxsIHRoZQ0KPiBvdGhlcnMu
DQo+IEJvbnVzIHBvaW50cyBmb3IgYSAiYmlzZWN0IiB0byBmaW5kIHdoZXJlIHRoZSBmYWlsdXJl
IHN0YXJ0cywgYnV0DQo+IHRoYXQNCj4gY2FuIGJlIHVwIHRvIHRoZSBkZXZlbG9wIHRvIGV4cGxp
Y2l0bHkgcmVxdWVzdCB0ZXN0aW5nIGF0IHNvbWUgcG9pbnRzDQo+IGluDQo+IHRoZSBzZXJpZXMu
DQoNClllcywgIEkgYWdyZWUgdGhlcmUncyBtdWNoIHRvIGJlIGltcHJvdmVkIHRlc3Rpbmctd2lz
ZS4gSSBkaWQgbm90IGNvbWUNCnVwIHdpdGggbXkgb3duIHBhcmFsbGVsIHRlc3Rpbmcgc3lzdGVt
IGJlY2F1c2UgSSB3YXMgaGFwcHkgd2l0aCB0aGUNCmRlZmF1bHQgb25lIGFmdGVyIGFsbC4NCkFu
ZCB0aGVuIG15IG93biBzeXN0ZW0gZGV0ZXJpb3JhdGVkIChBdCBsZWFzdCBpdCBkb2VzIG5vdCBz
ZXQgLTFzIGxlZnQNCmFuZCByaWdodCwgdGhvdWdoIHRoYXQgbWVhbnMgcGVvcGxlIHRvdGFsbHkg
aWdub3JlIHRob3NlIHJlc3VsdHMgdG9vKQ0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZl
bEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9s
dXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
