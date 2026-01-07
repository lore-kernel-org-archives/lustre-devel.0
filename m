Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A0610D0D163
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jan 2026 18:28:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4dmbzH1MJrz2378;
	Wed, 07 Jan 2026 10:24:27 -0800 (PST)
Received: from SJ2PR03CU001.outbound.protection.outlook.com
 (mail-westusazon11022091.outbound.protection.outlook.com [52.101.43.91])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4dmbyn2tNVz20g0
 for <lustre-devel@lists.lustre.org>; Wed, 07 Jan 2026 10:24:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=nr4aiUZzvtwJT6SspiL4ILlglar95RMuf2tMCXDVr9HxV55qS0P3VCbrkWfMRIXbMPH9l1SlwnSXVWEKyC18s273flImvHab/RktdTKNk3iILug1UbEDOs3K+cwDd+5LveBeg2M9rL+j5gGvlA052DGm5utUXEEUj2IlmOt6eAbrlIpV73ksQqclUya7c/GymdNlPqw2UNfSRI3thyy5RXdEh+uWq6RpJx7JxO2uRHFR3AwoqI2pgr6C3l1V8i6YSqOEHDSx87yuhm6WUrID+cedrKAHp+cx+wjDyY3x6/sR2L44CXj6KMpf3eNZUu3ct0uzUw3ZKjKD/zI6/Uzxow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=EaOz6WWyO5Qsqk9nwaTmPzTvJ7Dfdl5IjqH72LyVTUo=;
 b=ZJyHpGXBjODiB7l1itkqjD2Nvq1LpA8Y1p23cnljrM892dcaQ0xmvzZq9TiTYt9X1xJc0naLaPxQIZrzppiIypZXDjRIBkMHUSybByIx7LV4fGu3RB47H8hF6Tv9lBPkTVFcjlkT8nI68Q1vnvWJSQ80Vyss6uR5JulbJs7xiHRYm0kRmMr+30IkZl/76j6iEH7mFetrtWyzuCvRqGXSKbqNxusMidv1p8wl95NlunPFSYJpr80w0GT7M5e/gBQjoJOE27RHikH67bT780mIw4ANQxVHKFltyxeSpHF4qTu29oYhBpBBvMHDDXroP/xFCQVz3QBV2YNiSSc0CVGZjw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=thelustrecollective.com; dmarc=pass action=none
 header.from=thelustrecollective.com; dkim=pass
 header.d=thelustrecollective.com; arc=none
Received: from DS4PR04MB9822.namprd04.prod.outlook.com (2603:10b6:8:2e7::21)
 by DM6PR04MB6809.namprd04.prod.outlook.com (2603:10b6:5:22a::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9478.4; Wed, 7 Jan
 2026 18:22:54 +0000
Received: from DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::cafa:6da3:e388:13b]) by DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::cafa:6da3:e388:13b%4]) with mapi id 15.20.9478.005; Wed, 7 Jan 2026
 18:22:54 +0000
To: caifengzhu <caifeng_zhu@163.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] osp_md_index_it_next() may have a bug
Thread-Index: AQHcc076jjC/5Zi1NEC76Jn96eDyjrVHHqrA
Date: Wed, 7 Jan 2026 18:22:54 +0000
Message-ID: <BFFCCFD9-9EC8-4197-9FD7-4BDC8C7AE79E@thelustrecollective.com>
References: <D90D204A-12BA-430C-9731-73BBF95C0E5D@163.com>
In-Reply-To: <D90D204A-12BA-430C-9731-73BBF95C0E5D@163.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=thelustrecollective.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DS4PR04MB9822:EE_|DM6PR04MB6809:EE_
x-ms-office365-filtering-correlation-id: 5d9eab28-5497-419e-b5b3-08de4e19c6ad
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|34096008|376014|1800799024|38070700021|7053199007|8096899003|13003099007;
x-microsoft-antispam-message-info: =?utf-8?B?K3hmVjhqQ3UwKzBBY0VxendITEsxcnAxdE1YbFFDTHJTQUFhb1BuZ0NiZUZv?=
 =?utf-8?B?Q1RZNVVDUSs1UGFwU2poTm4yb0g5TE5FWTJZYnBmL3ZPM283aUNhY08xelJI?=
 =?utf-8?B?Qkg4ZnFxdGFRR2FIM21TOUdtNzJaazlISjVieC9BblA1S3p3Q1FqNHlwdkU3?=
 =?utf-8?B?S1h2TG96dWJRQk1jdjBndmhwdHU3YnlLOWpyRldaNVI1U1BXRE82UGJjdzFx?=
 =?utf-8?B?WUMyZStBZmw1TDZMRExIOHBncjZBTDJ5ZDladWl5bkI3SDlienhMc2UwWnFK?=
 =?utf-8?B?ZEs4NUNhMmo5dUpjZHQrcEJFbWxiRnZGcVVPZlBncC9TYkQyRzh2R3F3UG9Q?=
 =?utf-8?B?a3V2YnI5bW1UVUNmUnBPSkc5K09taXRINFhmV2hsekdoc05HSXhmSmdNRDIr?=
 =?utf-8?B?RkE2SXBYbVdZOVAxblNnZHlSaTNqTlcrdlpwWklxUWxpeEJQb3hYRjRhbHFX?=
 =?utf-8?B?UGhVSEpoRXdVYXZaMEs2TFFmM1dMT2p3aE9lR0NUNjBPUG82aHJtVGg3UDVs?=
 =?utf-8?B?aUl3RE5HWkc1ejZFTC9lTjUzQWkyNGJGS2lZdzBSZzcxVWYzUFZXMVo1WUcr?=
 =?utf-8?B?UlNrTWc4NGE3R240YVRWa21PdDZOWDRvRyszb0xpRGt6bmhYbnJyUnFaaHJW?=
 =?utf-8?B?TXpvK1BNdTBjQTFOWmJLdVJUZkJqRlZFODEwNzdJa1k1aXlIeFZnRTNzam8r?=
 =?utf-8?B?bFpjRmdBaHJQSmhkTGxyWlBqcS85U01hSlpKUklCelU5VnZaQm05VzUwVnlu?=
 =?utf-8?B?ZnBickRyWVVNNmJscDlKQUU3Ym9QSGQyaE1DWmlRaEkwOWJlcDJRVDdXemdv?=
 =?utf-8?B?bXl1SkMyS2NPZjFmYnVQQ3V2RXlZSk0vS01rekp1dktKWVNSNEVaVHVDT1Ex?=
 =?utf-8?B?a3VucldDaUtrYldSSW1JMWpwaUVOV09UZ0VDbklFdnNJZXRrMmdtUHlVMFhU?=
 =?utf-8?B?OTErOFEwbUN0VTJvSlRNVGt4NXkwUWZjZndpM0hnNFZidHY5MHdDMjBpUXkz?=
 =?utf-8?B?T01IaE1kdURBT2ZhMHlxMC9uR0gyTkk1Tkx6MU5NWFRueExDS3lRNWU4QkZn?=
 =?utf-8?B?eS9PeUFRQXBsOEF2M0FpQnl4Y2JtQ2tGWG9jSUZGN1R1dk13UFVjMmVtci9I?=
 =?utf-8?B?Zk1YQXY5Z3EyRytvaVJ6aGVhdkZqYkdpY2xiSmNvWkpiUitIemYzUXJONEVD?=
 =?utf-8?B?dkp0bkZKb25aTTU1SUZOd2taWGRGRG0zV0txQ3M5QXQyb3F3bFc3d2JjM3Za?=
 =?utf-8?B?czVncmNlNHFlUStkNUFUTmVZaVBPNnlnZXhIanp6Yll1Nnc1ZEJZNlYvak9G?=
 =?utf-8?B?QWFETmFFTGZPWUl1YlE2eFZRYnFHUy9vRnpzbWFiNFNQSnpUMFpBMmxhMWNv?=
 =?utf-8?B?SE9lek9tcTA0ZDJDRDdmeVVUOTllVkRDRDhyRHNrd1Bod3RpajhUMGZ4K2JK?=
 =?utf-8?B?VEI2QkZ6RkdFeW5xdit2Tk9Mbm45Sk43Y0JYWUFjSkRTa05INFdIRG14dHZ1?=
 =?utf-8?B?TGp6Z3NTYStuZ0ovc1N1YjlnaVRwUEF0bWh5VUZUMUNVRUg3SFJGa3JadDRi?=
 =?utf-8?B?T3J0WEplTHF3Z3MzV05naW5wa2twSTJ5R1pRUHByQk81V3VTRjRiaDBvakU5?=
 =?utf-8?B?ZGloWjMvdHJOYVE2NmxHREtUL0lCNzkwR1VRTW4xbko0OHMrYUNQanhpQVhy?=
 =?utf-8?B?Q1E1cit3Mk50eW1GQ3lNcFdRUUpJZFRRTnF0WWlaRDlvK0NsTWJBZmhMelNW?=
 =?utf-8?B?cmFpcUx3NXVncWVrTll6ankrQkNwak1FK0JQOXh1NEdsYkVDak12OWVqVy9Y?=
 =?utf-8?B?cjZDUTM2MmJDZHNaamkxd0VhZHJicUNnNzFWSmFGbzRPNmNKQ3VrTFBiQmdE?=
 =?utf-8?B?YjArNGs1SzNCeFhzVk5EZERCbWRGTUNESjljTGVibXJlR01aYXlTdVZ5aEZa?=
 =?utf-8?Q?e4DRggGgV7waDxrAD3L9Ke1CdSbpYbLU?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DS4PR04MB9822.namprd04.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(34096008)(376014)(1800799024)(38070700021)(7053199007)(8096899003)(13003099007);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?WHhiT2VXaHBYblBWYzNwYmhFY1prZFVlVUkySzE0MDZmNnYwLytkQmppNGsw?=
 =?utf-8?B?LzJSTGV2eUJWUzA3N0YwUlRMSVZqUnY2NytXbHdIaHkrOHoyek5sVlVCL2lP?=
 =?utf-8?B?NW9QZHhZRVhKVGJISXZJdUk1ZmRKQVp0VmtnSk40T2JGMUN6VVFmT1A3YWJD?=
 =?utf-8?B?Y05GVndKUGpKUUhyNW1ybzkxdGFpK3Z0N3doMHFsRHdXN1dLTzYyaW5mUUts?=
 =?utf-8?B?OSszcFJjcCsyTExrOG9IeU1wMjh4aWxtTThpOGFnR3JaWmdDK0NZMGYvZ2FY?=
 =?utf-8?B?Z3hJNUNNS2cvbkFmUFBGRUMvVWJjb2poSldMaWJ6clc5bjJIUGdxMXBqL0Q5?=
 =?utf-8?B?SUhNYjViRGwydEVPaXpTT0J1d1V3SU1CTUhUQ2NkUE5WbS9ZdWpzQS9taDFn?=
 =?utf-8?B?YXVvS3l6UUJjVXg3L2JiUlhSUG9Ic2FkVlgzV2VhTWV0Sm9UUXQ1aVVmUXZi?=
 =?utf-8?B?d2JWV0FnUkdKdVRKRzk1UXZmMDNtYURxYUNucGpLZFVQWHdGdGtmTHY2dSt0?=
 =?utf-8?B?KzV4d3VBdzdLK3pyaVNCTjQxZlh4VlZERXh1b0VJdmxPM2pIbmVPYmRrbGhV?=
 =?utf-8?B?d2dIdWlFVVNLQ1hjbG14MVcxMHQyOGtTRzZQbVNzN2p1Mk01OUdJL1dvMVZt?=
 =?utf-8?B?NENLZnJnRTZTNXEvb3dlelcyeHBiZ2RucjhSN0pBNEpaUjUxdjgrdFR3UVlh?=
 =?utf-8?B?WXBYUFcwOGtsRXRHcXBVSENaWTRNbVRWdlo3bTcvWlRvd3pub0VCaUV4eUNw?=
 =?utf-8?B?SWhITWpUK0RKYkF5aE04bDlxUGRaZG1leTJZZ05nNlkrRlNGWndVbGRLTlBz?=
 =?utf-8?B?bnFpRUVmYUdVeHY3eVR3djA2a0RxWkZxcU5IMFlSUThjejNTaGkwMHdTWXNQ?=
 =?utf-8?B?MkJZSmcrRi9qZzFxTFp6SEN3dkM5N0dpdDc5SU1tRk1wOXlCSWlTaER5eEsy?=
 =?utf-8?B?WDJ5T0VzU0R5TlpHKzF5dTZGa25lVDdrci92c1N4SFZOMjNiOEIxYlVhNTJy?=
 =?utf-8?B?aXdCVmdLMDZ4b2hRMWtQclB4K01pZHVHamZCKzV6T0VCZkVPR0JaVnNndkJU?=
 =?utf-8?B?WGQ5QWpaZHRxYlZMSndURDZLc1pDUGhHZklvVDNJVUJIejR1YlRWQXkzU3V1?=
 =?utf-8?B?N0svdjJHRjFVeHl6YjVKT2V5VDJoWUU4QWVhNStuYkZXOEtFL0NJdTdGd1BQ?=
 =?utf-8?B?MVNyOS9STDNVSXlOWEl3RkIxZ2FiNGxuaUNOdzNLU3pzcGJhYkczVHpXWHIv?=
 =?utf-8?B?R0hNZGpZRTJiUS9YQW8yWVFOVEc3TjJ3amZHTXpncjE1citPaGsybzByeVMw?=
 =?utf-8?B?Q0t0d1pnb0Nzek9XUzBCZGRQeEhSNnh6MnhyaDk3WUV2M0J5MzMxYkJ5YkZP?=
 =?utf-8?B?bSt6aVNzNmxkL0JFY3FYak9XODNpdm9wbVVvZVNtRE45MGVJNithMUVzcDhj?=
 =?utf-8?B?YjcxTVk3Zmtvdml4eDM1T0o3eHBKaTdVaER0OGlHRFhPWEY0U25NcWxxdTZR?=
 =?utf-8?B?S1NCQWU0eFJkWjJrZlo0WXhaME0va0RiYTIrbk9KeG4rYlVNbkpkNmdZQm81?=
 =?utf-8?B?c2FTMlI2RTFLYXl3ejBpYWpxU2k2a3FxU3JqTTIrcnFKUUtJckNkR3hRa0Jt?=
 =?utf-8?B?MXd0OVJyU2w0KzY1UUtnVmwwVE1teENmcndlbXFtU0daZWthSmdBUmRoTWFn?=
 =?utf-8?B?Z2JaVGZtSGd4VTBmaUU2aVJPY2NNZlRVK1JuMk5UY20xNXZZYWtKOC91T0hs?=
 =?utf-8?B?cWpaVlc4SHJDTUFlRlhMY1Y4STJicEtTb3RGb1ZTenYwUjRmTnp3VmdHUVls?=
 =?utf-8?B?Y0RMZldrUXI0VUt3Tks3cnFTYzV1NUlXUGZEVk9YWTZPNy9yM2FmMjg0Tm1Q?=
 =?utf-8?B?SDFvWTAyaXEzY1FuZE01ZjkvVlNPTDI5U2x1akdXazR0WExJVzdxd1VWVlV3?=
 =?utf-8?B?WW10VXB5UENVYU83RTF0SksxaU1Fdi9CRWl3b3RHbmxnckxHQ3AvWmRrcUdo?=
 =?utf-8?B?ckZycjZyS2UwZ1d3ZFN1YStCNkdqSUhiMlp3Q05JQ3JLcGd6VUQrbWZuT0k3?=
 =?utf-8?B?MFMrSVZ3TDVtZzJNUFFTWXhDZUtoU0Zmb1JSZDFuNmgydXU0NEtxQWQ0aXRB?=
 =?utf-8?B?by92VXp0NTdreEpneWVsOWhtSjloUzduZEZ0UDYycTg2REZLTXEzd0JZdldQ?=
 =?utf-8?B?N3JnWFVZNTdmSllEU3laWUg2U2piTVloRG1semNtZ21WZmlVYWxLMFBiTEU4?=
 =?utf-8?B?SGxEaEFweXFtc1VqYy9aUXNtdVBCV3B1eUpMc1I4N25TMWJPSUhzem4xZDYr?=
 =?utf-8?B?SWJzL0NTd0RFVE9UbFZzYjJMUlA3VzdQVE5DS1dPejhhVHI2dGNKRnZrSFhp?=
 =?utf-8?Q?fNaF/7DRCLtOh1SU=3D?=
MIME-Version: 1.0
X-OriginatorOrg: thelustrecollective.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DS4PR04MB9822.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5d9eab28-5497-419e-b5b3-08de4e19c6ad
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Jan 2026 18:22:54.7138 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4c9dec06-8f2c-4233-98d5-ca3cb36218fc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Pnr9pSP2R6j3fU0EfgmJxMT+sWfe6ISJ6tGp7URXj1RluBes8reZ9AvurZ1XVAspqa3o9i71/Dm9DEG9bBSudfHNpyCfyenj355NJ/v3wkw=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR04MB6809
Subject: Re: [lustre-devel] osp_md_index_it_next() may have a bug
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
Reply-To: Andreas Dilger <adilger@thelustrecollective.com>
Content-Type: multipart/mixed; boundary="===============6630464998333045091=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6630464998333045091==
Content-Language: en-GB
Content-Type: multipart/alternative;
	boundary="_000_BFFCCFD99EC841979FD74BDC8C7AE79Ethelustrecollectivecom_"

--_000_BFFCCFD99EC841979FD74BDC8C7AE79Ethelustrecollectivecom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

SGkgQ2FpZmVuZywNCkNvdWxkIHlvdSBwbGVhc2UgZmlsZSB0aGlzIGlzc3VlIGluIEppcmEgKGh0
dHBzOi8vamlyYS53aGFtY2xvdWQuY29tLyApIGFuZCBwb3RlbnRpYWxseSBwdXNoIHRoZSBmaXgg
cGF0Y2ggdG8gR2Vycml0IChodHRwczovL3dpa2kubHVzdHJlLm9yZy9TdWJtaXR0aW5nX0NoYW5n
ZXMgKQ0KDQpDaGVlcnMsIEFuZHJlYXMNCg0KT24gRGVjIDIyLCAyMDI1LCBhdCAwNzoyNiwgY2Fp
ZmVuZ3podSB2aWEgbHVzdHJlLWRldmVsIDxsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZz4g
d3JvdGU6DQoNCu+7v0hpLA0KDQpJdCBzZWVtcyBvc3BfbWRfaW5kZXhfaXRfbmV4dCgpIGhhdmUg
YSBidWcuIENvbnNpZGVyIHRoZSBjYXNlIHRoYXQgJ2VudCcgaXMgbm9uDQpudWxsIGFuZCBwb2lu
dHMgdG8gdGhlIGxhc3QgZW50cnkgaW4gdGhlIGN1cnJlbnQgaW5kZXggcGFnZS4gSW4gdGhpcyBj
YXNlLCBhDQpuZXcgaW5kZXggcGFnZSB3aWxsIGJlIGxvYWRlZCB3aXRoIG9zcF9pdF9uZXh0X3Bh
Z2UoKSBhbmQgYWZ0ZXIgdGhlIGxvYWRpbmcsDQonZW50JyByZW1haW5zIGludGFjdC4gVGhlIGVu
dHJ5IHJldHJpZXZpbmcgYmFzZWQgb24gJ2VudCcgaXMgd3JvbmcuICBFdmVuDQp3b3JzZSwgaXQg
bWF5IGNhdXNlIGtlcm5lbCBjcmFzaCBieSBhY2Nlc3NpbmcgYW4gdW5tYXBlZCBwYWdlLg0KDQpB
IHNpbXBsZSBmaXggbWF5IGJlIGxpa2UgYmVsb3cuDQoNCmRpZmYgLS1naXQgYS9sdXN0cmUvb3Nw
L29zcF9tZF9vYmplY3QuYyBiL2x1c3RyZS9vc3Avb3NwX21kX29iamVjdC5jDQppbmRleCA5NzUy
NDlkNDk4Li44OGYzY2IwMDAyIDEwMDY0NA0KLS0tIGEvbHVzdHJlL29zcC9vc3BfbWRfb2JqZWN0
LmMNCisrKyBiL2x1c3RyZS9vc3Avb3NwX21kX29iamVjdC5jDQpAQCAtNjYzLDcgKzY2Myw3IEBA
IHN0YXRpYyBpbnQgb3NwX21kX2luZGV4X2l0X25leHQoY29uc3Qgc3RydWN0IGx1X2VudiAqZW52
LCBzdHJ1Y3QgZHRfaXQgKmRpKQ0Kew0KICAgICAgIHN0cnVjdCBvc3BfaXQgICAgICAgICAgICpp
dCA9IChzdHJ1Y3Qgb3NwX2l0ICopZGk7DQogICAgICAgc3RydWN0IGx1X2lkeHBhZ2UgICAgICAg
KmlkeHBhZ2U7DQotICAgICAgIHN0cnVjdCBsdV9kaXJlbnQgICAgICAgICplbnQgPSAoc3RydWN0
IGx1X2RpcmVudCAqKWl0LT5vb2lfZW50Ow0KKyAgICAgICBzdHJ1Y3QgbHVfZGlyZW50ICAgICAg
ICAqZW50Ow0KICAgICAgIGludCAgICAgICAgICAgICAgICAgICAgIHJjOw0KICAgICAgIEVOVFJZ
Ow0KDQpAQCAtNjc0LDcgKzY3NCw3IEBAIGFnYWluOg0KICAgICAgICAgICAgICAgICAgICAgICBS
RVRVUk4oMSk7DQoNCiAgICAgICAgICAgICAgIGl0LT5vb2lfcG9zX2VudCsrOw0KLSAgICAgICAg
ICAgICAgIGlmIChlbnQgPT0gTlVMTCkgew0KKyAgICAgICAgICAgICAgIGlmICgoZW50ID0gKHN0
cnVjdCBsdV9kaXJlbnQgKilpdC0+b29pX2VudCkgPT0gTlVMTCkgew0KICAgICAgICAgICAgICAg
ICAgICAgICBpdC0+b29pX2VudCA9DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgIChzdHJ1
Y3QgbHVfZGlyZW50ICopaWR4cGFnZS0+bGlwX2VudHJpZXM7DQogICAgICAgICAgICAgICAgICAg
ICAgIFJFVFVSTigwKTsNCg0KQmVzdCBSZWdhcmRzIQ0KX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX18NCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QNCmx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnDQpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5m
by5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcNCg==

--_000_BFFCCFD99EC841979FD74BDC8C7AE79Ethelustrecollectivecom_
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: base64

PGh0bWwgY2xhc3M9ImFwcGxlLW1haWwtc3VwcG9ydHMtZXhwbGljaXQtZGFyay1tb2RlIj4NCjxo
ZWFkPg0KPG1ldGEgaHR0cC1lcXVpdj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7
IGNoYXJzZXQ9dXRmLTgiPg0KPC9oZWFkPg0KPGJvZHkgZGlyPSJhdXRvIj4NCkhpIENhaWZlbmcs
DQo8ZGl2PkNvdWxkIHlvdSBwbGVhc2UgZmlsZSB0aGlzIGlzc3VlIGluIEppcmEgKGh0dHBzOi8v
amlyYS53aGFtY2xvdWQuY29tLyApIGFuZCBwb3RlbnRpYWxseSBwdXNoIHRoZSBmaXggcGF0Y2gg
dG8gR2Vycml0ICg8YSBocmVmPSJodHRwczovL3dpa2kubHVzdHJlLm9yZy9TdWJtaXR0aW5nX0No
YW5nZXMiPmh0dHBzOi8vd2lraS5sdXN0cmUub3JnL1N1Ym1pdHRpbmdfQ2hhbmdlczwvYT4mbmJz
cDspPC9kaXY+DQo8ZGl2PjxiciBpZD0ibGluZUJyZWFrQXRCZWdpbm5pbmdPZlNpZ25hdHVyZSI+
DQo8ZGl2IGRpcj0ibHRyIj5DaGVlcnMsIEFuZHJlYXM8L2Rpdj4NCjxkaXYgZGlyPSJsdHIiPjxi
cj4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiPk9uIERlYyAyMiwgMjAyNSwgYXQgMDc6MjYsIGNh
aWZlbmd6aHUgdmlhIGx1c3RyZS1kZXZlbCAmbHQ7bHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5v
cmcmZ3Q7IHdyb3RlOjxicj4NCjxicj4NCjwvYmxvY2txdW90ZT4NCjwvZGl2Pg0KPGJsb2NrcXVv
dGUgdHlwZT0iY2l0ZSI+DQo8ZGl2IGRpcj0ibHRyIj7vu788c3Bhbj5IaSw8L3NwYW4+PGJyPg0K
PHNwYW4+PC9zcGFuPjxicj4NCjxzcGFuPkl0IHNlZW1zIG9zcF9tZF9pbmRleF9pdF9uZXh0KCkg
aGF2ZSBhIGJ1Zy4gQ29uc2lkZXIgdGhlIGNhc2UgdGhhdCAnZW50JyBpcyBub248L3NwYW4+PGJy
Pg0KPHNwYW4+bnVsbCBhbmQgcG9pbnRzIHRvIHRoZSBsYXN0IGVudHJ5IGluIHRoZSBjdXJyZW50
IGluZGV4IHBhZ2UuIEluIHRoaXMgY2FzZSwgYTwvc3Bhbj48YnI+DQo8c3Bhbj5uZXcgaW5kZXgg
cGFnZSB3aWxsIGJlIGxvYWRlZCB3aXRoIG9zcF9pdF9uZXh0X3BhZ2UoKSBhbmQgYWZ0ZXIgdGhl
IGxvYWRpbmcsPC9zcGFuPjxicj4NCjxzcGFuPidlbnQnIHJlbWFpbnMgaW50YWN0LiBUaGUgZW50
cnkgcmV0cmlldmluZyBiYXNlZCBvbiAnZW50JyBpcyB3cm9uZy4gJm5ic3A7RXZlbjwvc3Bhbj48
YnI+DQo8c3Bhbj53b3JzZSwgaXQgbWF5IGNhdXNlIGtlcm5lbCBjcmFzaCBieSBhY2Nlc3Npbmcg
YW4gdW5tYXBlZCBwYWdlLjwvc3Bhbj48YnI+DQo8c3Bhbj48L3NwYW4+PGJyPg0KPHNwYW4+QSBz
aW1wbGUgZml4IG1heSBiZSBsaWtlIGJlbG93Ljwvc3Bhbj48YnI+DQo8c3Bhbj48L3NwYW4+PGJy
Pg0KPHNwYW4+ZGlmZiAtLWdpdCBhL2x1c3RyZS9vc3Avb3NwX21kX29iamVjdC5jIGIvbHVzdHJl
L29zcC9vc3BfbWRfb2JqZWN0LmM8L3NwYW4+PGJyPg0KPHNwYW4+aW5kZXggOTc1MjQ5ZDQ5OC4u
ODhmM2NiMDAwMiAxMDA2NDQ8L3NwYW4+PGJyPg0KPHNwYW4+LS0tIGEvbHVzdHJlL29zcC9vc3Bf
bWRfb2JqZWN0LmM8L3NwYW4+PGJyPg0KPHNwYW4+KysrIGIvbHVzdHJlL29zcC9vc3BfbWRfb2Jq
ZWN0LmM8L3NwYW4+PGJyPg0KPHNwYW4+QEAgLTY2Myw3ICs2NjMsNyBAQCBzdGF0aWMgaW50IG9z
cF9tZF9pbmRleF9pdF9uZXh0KGNvbnN0IHN0cnVjdCBsdV9lbnYgKmVudiwgc3RydWN0IGR0X2l0
ICpkaSk8L3NwYW4+PGJyPg0KPHNwYW4+ezwvc3Bhbj48YnI+DQo8c3Bhbj4mbmJzcDsmbmJzcDsm
bmJzcDsmbmJzcDsmbmJzcDsmbmJzcDsmbmJzcDtzdHJ1Y3Qgb3NwX2l0ICZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyppdCA9IChzdHJ1
Y3Qgb3NwX2l0ICopZGk7PC9zcGFuPjxicj4NCjxzcGFuPiZuYnNwOyZuYnNwOyZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwO3N0cnVjdCBsdV9pZHhwYWdlICZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyppZHhwYWdlOzwvc3Bhbj48YnI+DQo8c3Bhbj4tICZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwO3N0cnVjdCBsdV9kaXJlbnQgJm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7KmVudCA9IChzdHJ1Y3QgbHVfZGlyZW50ICopaXQt
Jmd0O29vaV9lbnQ7PC9zcGFuPjxicj4NCjxzcGFuPisgJm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7c3RydWN0IGx1X2RpcmVudCAmbmJzcDsmbmJzcDsmbmJzcDsmbmJzcDsmbmJz
cDsmbmJzcDsmbmJzcDsqZW50Ozwvc3Bhbj48YnI+DQo8c3Bhbj4mbmJzcDsmbmJzcDsmbmJzcDsm
bmJzcDsmbmJzcDsmbmJzcDsmbmJzcDtpbnQgJm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7cmM7PC9zcGFuPjxicj4NCjxzcGFuPiZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwO0VOVFJZOzwvc3Bhbj48YnI+
DQo8c3Bhbj48L3NwYW4+PGJyPg0KPHNwYW4+QEAgLTY3NCw3ICs2NzQsNyBAQCBhZ2Fpbjo8L3Nw
YW4+PGJyPg0KPHNwYW4+Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7UkVUVVJOKDEpOzwvc3Bhbj48
YnI+DQo8c3Bhbj48L3NwYW4+PGJyPg0KPHNwYW4+Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7aXQtJmd0O29vaV9wb3NfZW50Kys7PC9zcGFuPjxicj4NCjxzcGFuPi0gJm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7Jm5ic3A7aWYgKGVudCA9PSBOVUxMKSB7PC9zcGFuPjxicj4NCjxzcGFuPisg
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7aWYgKChlbnQgPSAoc3RydWN0IGx1X2RpcmVudCAq
KWl0LSZndDtvb2lfZW50KSA9PSBOVUxMKSB7PC9zcGFuPjxicj4NCjxzcGFuPiZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwO2l0LSZndDtvb2lfZW50ID08L3NwYW4+PGJyPg0KPHNwYW4+Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7KHN0cnVj
dCBsdV9kaXJlbnQgKilpZHhwYWdlLSZndDtsaXBfZW50cmllczs8L3NwYW4+PGJyPg0KPHNwYW4+
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5i
c3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7
Jm5ic3A7Jm5ic3A7Jm5ic3A7Jm5ic3A7UkVUVVJOKDApOzwvc3Bhbj48YnI+DQo8c3Bhbj48L3Nw
YW4+PGJyPg0KPHNwYW4+QmVzdCBSZWdhcmRzITwvc3Bhbj48YnI+DQo8c3Bhbj5fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXzwvc3Bhbj48YnI+DQo8c3Bhbj5s
dXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0PC9zcGFuPjxicj4NCjxzcGFuPmx1c3RyZS1kZXZlbEBs
aXN0cy5sdXN0cmUub3JnPC9zcGFuPjxicj4NCjxzcGFuPmh0dHA6Ly9saXN0cy5sdXN0cmUub3Jn
L2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZzwvc3Bhbj48YnI+DQo8L2Rpdj4N
CjwvYmxvY2txdW90ZT4NCjwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1sPg0K

--_000_BFFCCFD99EC841979FD74BDC8C7AE79Ethelustrecollectivecom_--

--===============6630464998333045091==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6630464998333045091==--
