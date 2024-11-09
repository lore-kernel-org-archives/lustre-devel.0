Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 975D9D64099
	for <lustre-devel@archiver.kernel.org>; Sat,  9 Nov 2024 01:26:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XldRZ63mRz1xS5;
	Fri, 08 Nov 2024 17:25:46 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XldR36hJCz1wlF; Fri, 08 Nov 2024 17:25:19 -0800 (PST)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com
 (mail-bn7nam10lp2046.outbound.protection.outlook.com [104.47.70.46]) by
 mx-outbound43-103.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sat, 09 Nov 2024 01:25:15 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=bW3nwZe43U6yD8p9LCsB8Epm9rVcy09yhdcQk7VsBbPCPsvMDXbxVSOHtQb+ocZkWR0oxUyP8n6Te2fzE62SHAfqBJy5FiVSua8eg9eGhAXjC4gfg30AGtj8S1Bu3HPJeE2TctJg0Z/RVDr6jdE/ZJYezl/Ba2RRxnP09nzl3r/a8rvhNbeeBCQD2D2H6YZaFvxXP3Hm82YSAEzkuN+NgmhmGuukb4w4AenRE/hKAbXC6KfwBh7CVj/YjUk8fFRG8v6Qjmk2bJV1MO7xvwd/llPVmDWVFzQFElCzTKKeckAkHSerIXdIeaRdcuC0f5Ubi1gF43RloozYEAUaULiTIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=HnxjhDVk1tPsCjzA3ADiHkQRtF9ns0eFSs+c09Jm8NA=;
 b=YAIumpjKSSFuwbLolGZ70wxtY69jn7HB22lAw87Lv5NX0XbsneCI6a+sl30Uycy6rf9ynJqb7AJBq/FT7dNOwEC9TgFARl7E/PfOtMyGLUZxRm7/qAbLXjQ1tr7wtbVEGPkBdoFKTsmpwu0Zp9dBFI6tRfnp674dCByvPZjm/4XFKchb1Yc5v4SlFXBFqh7XpX/37aXXoG3VCpJ02HcDpABrJaxMmNzNmfctsboOFAPkfvhSbGgWm39xa4vQnarg21UJ5A280LM+gK7SfnRo+vSU8n76ccXYo6fpaew1LwwOW14+JI3Rg+/FLAw3p7vmxF1XxJH2d6M4eBk4ROfKDg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HnxjhDVk1tPsCjzA3ADiHkQRtF9ns0eFSs+c09Jm8NA=;
 b=Q0H5Tho8RQlN9u2nEl1vVmHNNqbSanapmQBBO+NEBO+bNwufOn5HeJUDlUYgyGjbxD6DNxzS85TgmmTTrpwZqwouNqMYCq+lO0/LFGNIsrSGI3e/0dNLoYG3M6U5l4rJpmziH+i+rU2eoYJNUYe3Cp1YVPuno5zJtOarOWW6tLg=
Received: from SA1PR19MB7061.namprd19.prod.outlook.com (2603:10b6:806:2be::9)
 by BY5PR19MB3763.namprd19.prod.outlook.com (2603:10b6:a03:22d::20)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8137.22; Sat, 9 Nov
 2024 01:25:12 +0000
Received: from SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6]) by SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6%5]) with mapi id 15.20.8137.021; Sat, 9 Nov 2024
 01:25:11 +0000
From: Peter Jones <pjones@whamcloud.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.16.0 released
Thread-Index: AQHbKZGNVvle1gw120y3otW8IcLdAA==
Date: Sat, 9 Nov 2024 01:25:09 +0000
Message-ID: <29F3CE3E-8210-43E7-BE1A-1A8B81D58BC7@whamcloud.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.90.24101387
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA1PR19MB7061:EE_|BY5PR19MB3763:EE_
x-ms-office365-filtering-correlation-id: c248dd6f-93eb-4e73-39e9-08dd005d5a0a
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|376014|10070799003|1800799024|8096899003|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?UFFoNTFrNGFUVkxmRFd6NWs3RTdubnFGV0FWRDlucGQvRUhHdnJhUXpyU2M1?=
 =?utf-8?B?VUY3a0FHclBpNjdBZjBVcStMMUg1bEVZcUdzaDZrb2RFeTNyTlgvK1JncHZJ?=
 =?utf-8?B?RWVxRkdubWhiSDBaYXNNSUpKNHBtZWlJMlUvUUYvcVBjN1pXeTlKcG1LYlpy?=
 =?utf-8?B?U3RCLytUK1VRMlF5R0U5dUZodVQ5ckRiNFFoeHNYeElWeXE4WDJzTC9TVGZE?=
 =?utf-8?B?Q1dyTXJIRWpUYzlBMlV6eWhBbW9LeEhUUjNVSVB0ZVpoOFJ4dnVKUlBmUDRw?=
 =?utf-8?B?cXUyVTBvQXMxZGxhOW8xS25NUytNekhZbXdyRGFqME1GdFI2cU9TTkduQ2dC?=
 =?utf-8?B?SG1ONElTbEc3a2FRbHc5SFZSNFhkRzRwblVmNkFRZGhxbnVhNVJxRmlUeElt?=
 =?utf-8?B?RldEMTNvcjlEcjJibEtoZzdQSWI5QmcvT3hobWNBR2pId0orYTFhV1lodS94?=
 =?utf-8?B?MkVqMlBKb0tLU0FHa3NmVFdjaFA0ZDdZa3pwT1lxT0tkeld6amc5VENGdHZh?=
 =?utf-8?B?Ni9RQkFuajVjbUE5R0FWWnNydm5ZM3RYb3Rpc0hIaXdBb0twWTUxQTArRmV4?=
 =?utf-8?B?a2N6SXNGbnJGNUpoM3RIZjNGMUpFWDhLejFPdTNUOG5yb3c2eUt3dVM0bi9T?=
 =?utf-8?B?RlhKU20rK0Q5MEZJUm9TZFFoMEtLL0hXTzlZR3IycnQwSG13YlZZbmxFMFIx?=
 =?utf-8?B?VkhNTWZiemFuS1FFQU52V0ZQTHkvaVNuT0NtYWVwMFZDUTdrVHdrbDNDUSt1?=
 =?utf-8?B?Nk1qOWQ0RzI5TjV3OGtiRzJ0YW1YLy9SZ2NiTitpOVUwM3ZvOWxkaWZtV2E0?=
 =?utf-8?B?TFA4Q2RvU1E3c3VwVWZWVlF5b3JkRUt3ZnZXSlV1MG9Bck9pbUlLeStXcnhN?=
 =?utf-8?B?ejhaeU9DMFFTTG1NMFR5RWg1QWdSbUdhRVlLQ05NS0E1QVhxcTkwbUROVW90?=
 =?utf-8?B?RFZnWWwySENVcFRCMHF3cG0wRW03OEgyZ2ZCSkZva0lxaFdIc0h1cEd5bXJF?=
 =?utf-8?B?RmZhQmdQbGR3SEpFcWRaWkhHWEhLUUt1T2tiU0JwVXdRTnJJdEFGc08zNThU?=
 =?utf-8?B?Y1VGelBGaitUVm9EQStOYzhKaUZhRCt4NUZqVytQcnE5VEdSbzA5VjVNdTdT?=
 =?utf-8?B?bG40SjJ3ZCtHalhIUlRiWDlFbHRxS1p5ZC9WQ29KYXdRVEdBcVBvMWpTVGRm?=
 =?utf-8?B?dkNCQUtSVENMM1VFemx1TzJJSTJmVVFvSlcraDVWQlpXSWhKNWdrbFpNRUtW?=
 =?utf-8?B?dStUSXdVdjFMd2xQQkpxdDZQYmljUUFPL3lvcDN4TUNYR200NU9oN0IwaTdS?=
 =?utf-8?B?MWFGbkZJeUZXSmwweDM0OS95em5CSzgvS3M5K3hVMVNLM2NrK2pBdDkrcno4?=
 =?utf-8?B?Vmh4dG9iMGY2UXBHRGVPZjZXbTBtdkxvZWsrcDNhdXNWWjNJUENEdGU4cTBM?=
 =?utf-8?B?WnY5NHRWTlF2MlFORlFlSHY4eUpoempwSnBQSGdjYnJOUUdma3d3bTgrQXNp?=
 =?utf-8?B?WXNzMDEvMzgxLzBPaUp5K3gvYW4rUHpyVVROYklrU1B5VUFTWWluM2FpVENG?=
 =?utf-8?B?OTExK1UrczY4Sk1tYmlkeGxvZExIMVpZNDFoU2NWL3pKMlYvbVFRaU0yaytG?=
 =?utf-8?B?OElkMTJWV0FnMmh3b0h1RVNkMncwMkMxSWRqOERCb1VHZ2tWUjhVSzdkUTVy?=
 =?utf-8?B?QzNycW9pVlN4SjBSVTlsMzA0blBJYmFUTDNaYkcvTlljckQ4UVlpY0JiZjlo?=
 =?utf-8?Q?v+UpN8B8m3dNGKqHE5bvBDKmPG0g2aJZ+/1VjqE?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA1PR19MB7061.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(10070799003)(1800799024)(8096899003)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?ZmVwTXpIdnBiTWw0MVU3WGpBTWZuUmgwak1ScDlvYzNSNk1mcWFGaDBNMEhX?=
 =?utf-8?B?Z1dEZXpTZXhubFI0YXBDQUpBQnZpdWRhbzBwbloyYks2OTc5R2pMOTB0a2pM?=
 =?utf-8?B?NE82WjFETm1Dcmw0OFBXa2N1VkFEOURGNzNuZUJWdFVsN3JlMVFYcGttUkVM?=
 =?utf-8?B?YWZIcnBiTHJzRGFTNitVdnhzRkE5RTNrMDBmODdPUEhlU3RadHpZY3VXZGVL?=
 =?utf-8?B?NVk4NjVKd1dDeVNnZXFJV1l4Z1pPMkhsaERIUGZhckhod1hGcnFieFIyVE1L?=
 =?utf-8?B?YUVtNmV0WVYxS3lLWWw5LzhkQ0R1dGZqbVoxMG9BNGovYmp3SG1weTRidXhp?=
 =?utf-8?B?MC9aVGJkb29oY3hudXR4QTdCZ1gwUnY0bStBYVdtYzh0bVlSSmhzam85TnBa?=
 =?utf-8?B?RkpJdC9laDJ3VzJRdXJiZ2FPbEhEZ2M0anhyQUNnTDdGSGFDTWY3R0dBUVFm?=
 =?utf-8?B?SGxhSGpuMnJ4N1NINU9YZ3V0eUY4ZTlrM1pRRnVYbDU0MWEvbnBkWHFTdnVi?=
 =?utf-8?B?NDI4am02dm9oNEFrbDVSZ1hTWnp4S1doMWVmZWx5QlpwTUhKaG9uNDlNT3Nx?=
 =?utf-8?B?ZzJROUg1NVRsZWMxRkpja0RDY0FoWSt5QjZlYlB2cXVZZkVOT1FxS21McTdj?=
 =?utf-8?B?SVVDcENWcDUxeGpRZGN1SlhzakFVakM5d0JKNEtqb0kxNkU3R3Y2T2Fabmk4?=
 =?utf-8?B?QmFaVDhUbFpXeDNwcUtvdW5XMzlXbU1oZndCTWlEVzNCRmhzTW5SdXM3dW5Z?=
 =?utf-8?B?TnRpWXhkWUYzcloyb3ZibUIva3A2Z0g2YmxmeXNjc0I4K3hjUHk4Uks4dm5Q?=
 =?utf-8?B?aW5DOHdYT3dYL1JQY0pxUVRPY21ZY2YrSkdJRzdWN1Fad1BkclBDanlNelFj?=
 =?utf-8?B?bHFtbERZOFFaT1Rhb1lJbFNMYU5DOHl6cjgrS2V2OHV3MldKZlNQdEdHL2p5?=
 =?utf-8?B?eE93Ri9jazNHZWRrQWFBcGdHNjM3RHB3L01wNWYzS0hFNnNybk1obDRyWHgx?=
 =?utf-8?B?SFROZzNZSGsxNXJKOTdoaCtiQjQ5Nm81QVZSU3B6clN4TDd0K2wwWGthcnpO?=
 =?utf-8?B?UTFkS1NJZ25hdHRrako0Nmd6eFJMNWFtZEhVYWxiVFNXbXN2aXBFbjZHa1Q5?=
 =?utf-8?B?bXU3YzhOL05vYzI3V1pRV0pvRnBhemJQb3ErOEhTSWhRVW5JVS9nT2Q3S2FL?=
 =?utf-8?B?cHM1eURzaDF3aXdvQWlhUzR3RXhjbVo0QWJ0dm9CSWRTVjAvMVNzWUU3M3hH?=
 =?utf-8?B?L2gvSmx2MllIaHUxcUFiUkVWdjE5aGQ3bjZtaGNsaW5JT0grQUR2WlVjRk95?=
 =?utf-8?B?MFlZNFVWV3cwR0lDUGdNTzNSVStiWGJxVzMyVHZNc2RGeVJ2Yjl6WDRIS0Z2?=
 =?utf-8?B?VG5VUlp0a1B5YmQ0TnQyVlBLYmtlaWgzbEx1M1pINGlIU2xTV0hnUEpHd3l4?=
 =?utf-8?B?ek5ONHVWczlaRG1uYU90OHJnakxMWGdDeEhHVXlva0svemxxN0thbHRwT1lM?=
 =?utf-8?B?WGdhSm1ybFllMm94bDk3MmZtcGZGUml0bWpUOU1KWks1RmtSU3BzcElYVEtE?=
 =?utf-8?B?N2JRVlZsODArWjVNbGxVc0pITWVUQmZjaDZ3UmVYUExROW1jNDdhWFRjbmJq?=
 =?utf-8?B?a1RZMzliK0tML2FaanIvVm9RU0dHOUtpTk96UGZjZVFnN2FLS3NPckhnYXBV?=
 =?utf-8?B?NjlGSEY0KzZTV3JyUFJHRVNkNE1PSm5GallMV1BBbk14dmtRODdreDA2T09s?=
 =?utf-8?B?TGJSa0FjNnVwY0RqakFnSWE1RE5hZThJSU00NXJYSGdEelE5RWIwL2N2TW8r?=
 =?utf-8?B?R0ZQSlU2dmtTVGlyNnB5aitObEdzd0V6S1VvT2l3M0dzcTk2RzBkeTBmcEdl?=
 =?utf-8?B?MWZPLzNZL2Z3WDdRUWRpMEI4a3k5V24wZThGdlJTS3lTd3NZL1BFTExxK0xu?=
 =?utf-8?B?SmxHQW1sUzg1eVlHV0Y3bW5LL0dKSkhTcjZtV3R5aEVwQ3lWWVB4K2hTMTA1?=
 =?utf-8?B?NG5rRElQWGhYQzFiSWlOdXNENVZzRWRPUmxKKzNHTEhtMEJmSjNYT1VnUG1V?=
 =?utf-8?B?T1E3d2o0SFJkTmVsY2tNbWxueWFLekRRY1U2Smp0bmhjT09BQ0FzU2xYeTd1?=
 =?utf-8?B?K0NMQWJ3RHBUdVJtT3E4RkFsTnFGWTd0UzRBMnZNS01MaUN6VGQ5cDl0UWNw?=
 =?utf-8?Q?Ft/1kT58bqlJFxBDkB45wX04jIQeHnnrRUFi3GhhdW/z?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: XAIBQhX1HAjsz1Rk7PxGDpuWS+TTLiTeAHVLziu5GHW8xhcQPogUWvhh6SZ7LZydTMF47TqYJRvazvVRrRm3wyjnIBxxxdSB3Svn/ydcaa+mFpmnPn+mIWUSxb6PY+N10JEsYBEdFJC5cg7eGbshVOyzJb6fnlTGLmhfaqReolVlaMnTd9Iheqau4gTQcIS3NqcOqr6vk2+nTAmRjAPVY0K0RovEuQlE4GpqQtiGhWsMjMOiq6bfFE1+HodhJG7vIQ2Etej4cslxcJltWGilU0fBcCiNtGe3Rk5sIsB6YhLZOn/+aFO1/xjW/+xmHrOJw9erm+8ijjazsJj8XwZSropdylKhrrx5dD71pH7BAoCQGMGUnVoSsKP4q7BujoihiiuyDNNquDrSbPnJS8d5KT8hfk0nkBizt5w9bIMpx/TJCPzJfhWV4NblIpNOgK6mO/Hj0lcnEIm+1kRfYYAas1vCd1AoDyPdlfnTqmn7w0L/VZSH2hvttIwRR4GXU5qvczB+PaWdmzC0xPnMcT3lPp2WiYdDrOPl+T01wM/YbVN4QUAAbZg5jhFyKfzGZG8y8RbYGdo42N2JYKtF9/Dh30yAtY1Tplw+huc7ScsdAHUDrmHcVjz04nU56jIYxdqrxQ1/hrkWSuD67zavsTaklvMPUjcphlycZ2md0Dpb2+k=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA1PR19MB7061.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c248dd6f-93eb-4e73-39e9-08dd005d5a0a
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Nov 2024 01:25:09.4201 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: BHwI0zpGB74S4y5rmm0gTx5n2H2VR36YjbTUO5Jw33HbvTo8q0W7ML9rV4+75Cxy
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY5PR19MB3763
X-BESS-ID: 1731115515-111111-13471-26439-1
X-BESS-VER: 2019.1_20241105.1725
X-BESS-Apparent-Source-IP: 104.47.70.46
X-BESS-Parts: H4sIAAAAAAACAzXLMQrDMAyF4btoziDZlqXmKqWDZCtkKRnioVBy93pIl8fPg+
 /5hfgMWGHMXeA4YSVBnbXPUzqai6det3Bmb3ljfag0I47GAdfy9/t4376i4u0tVU0Rhb
 iRpZSl1l6ieGTWYkhwvX6Znu7BgQAAAA==
X-BESS-Outbound-Spam-Score: 0.01
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.260296 [from 
 cloudscan15-234.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.01 BSF_SC7_SG0146_1       META: Custom rule SG0146_1 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.01 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC7_SG0146_1, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Lustre 2.16.0 released
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
Content-Type: multipart/mixed; boundary="===============1140645814345099270=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1140645814345099270==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_29F3CE3E821043E7BE1A1A8B81D58BC7whamcloudcom_"

--_000_29F3CE3E821043E7BE1A1A8B81D58BC7whamcloudcom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTYuMCBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkPGh0dHBz
Oi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xNi4wLz4g
PGh0dHBzOi8vZG93bmxvYWRzLmhwZGQuaW50ZWwuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIu
MTEuMC8+IC4gWW91IGNhbiBhbHNvIGdyYWIgdGhlIHNvdXJjZSBmcm9tIGdpdDxodHRwczovL2dp
dC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPWFjOWVk
ZmJmZDYzMmFmNjY3MGVkYmRmZTg1OTY5NjdkOWQxNWNkZWE+DQoNClRoaXMgbWFqb3IgcmVsZWFz
ZSBpbmNsdWRlcyBuZXcgZmVhdHVyZXM6DQoNClJIRUwgOS40IFNlcnZlciBzdXBwb3J0IFByb3Zp
ZGluZyB0aGUgb3B0aW9uIHRvIHVzZSBsYXJnZSBOSURzIChMVS0xMDM5MTxodHRwczovL2ppcmEu
d2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTAzOTE+KQ0KDQpJUHY2IFN1cHBvcnQgUHJvdmlkaW5n
IHRoZSBvcHRpb24gdG8gdXNlIGxhcmdlIE5JRHMgKExVLTEwMzkxPGh0dHBzOi8vamlyYS53aGFt
Y2xvdWQuY29tL2Jyb3dzZS9MVS0xMDM5MT4pDQoNCk9wdGltaXplZCBEaXJlY3RvcnkgVHJhdmVy
c2FsIEltcHJvdmVkIFNwZWVkL0VmZmljaWVuY3kgZm9yIGxhcmdlIGRpcmVjdG9yaWVzL3RyZWVz
ICAoTFUtMTU5NzU8aHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTE1OTc1PikN
Cg0KRnVsbGVyIGRldGFpbHMgYWJvdXQgdGhpcyByZWxlYXNlIGNhbiBiZSBmb3VuZCBpbiB0aGUg
Mi4xNiB3aWtpIHBhZ2UgPGh0dHA6Ly93aWtpLmx1c3RyZS5vcmcvUmVsZWFzZV8yLjE2LjA+IChp
bmNsdWRpbmcgdGhlIGNoYW5nZSBsb2cgPGh0dHA6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIu
MTYuMF9DaGFuZ2Vsb2c+IGFuZCB0ZXN0IG1hdHJpeDxodHRwczovL3dpa2kubHVzdHJlLm9yZy9S
ZWxlYXNlXzIuMTYuMCNUZXN0X01hdHJpeD4pDQoNCk5vdGU6IEl0IGlzIHJlY29tbWVuZGVkIHRv
IGF2b2lkIHVzaW5nIFNlbGYtRXh0ZW5kaW5nIExheW91dHMgaW4gY29uanVuY3Rpb24gd2l0aCAy
LjE2IHVudGlsIExVLTE4NDE2PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0x
ODQxNj4gaXMgbW9yZSBmdWxseSB1bmRlcnN0b29kLg0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMg
Zm91bmQgaW4gdGhlIGlzc3VlIHRyYWNraW5nIHN5c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3Vk
LmNvbS8+DQoNClRoYW5rcyB0byBhbGwgdGhvc2Ugd2hvIGhhdmUgY29udHJpYnV0ZWQgdG8gdGhl
IGNyZWF0aW9uIG9mIHRoaXMgcmVsZWFzZS4NCg0KVGhpcyByZWxlYXNlIGlzIGRlZGljYXRlZCB0
byB0aGUgbWVtb3J5IG9mIE9sYWYgV2ViZXI8aHR0cHM6Ly93d3cubGlua2VkaW4uY29tL2luL29s
YWYtd2ViZXItNzA2NTZhOWIvPiB3aG8gd2FzIGFuIGFjdGl2ZSBtZW1iZXIgb2YgdGhlIEx1c3Ry
ZSBXb3JraW5nIEdyb3VwIGFuZCBhIGxvbmctdGVybSBjb250cmlidXRvciB0byB0aGUgTHVzdHJl
IHByb2plY3QuIE9sYWYgcGFzc2VkIGF3YXkgc3VkZGVubHkgZWFybGllciB0aGlzIHllYXIgYW5k
IGlzIG11Y2gtbWlzc2VkIGJ5IHRob3NlIG9mIHVzIHdobyBoYWQgdGhlIHBsZWFzdXJlIG9mIHdv
cmtpbmcgd2l0aCBoaW0uDQoNCg==

--_000_29F3CE3E821043E7BE1A1A8B81D58BC7whamcloudcom_
Content-Type: text/html; charset="utf-8"
Content-ID: <9A9181548FD3E6449BE7AC25319861BE@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6bz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6b2ZmaWNlIiB4
bWxuczp3PSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOm9mZmljZTp3b3JkIiB4bWxuczptPSJo
dHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL29mZmljZS8yMDA0LzEyL29tbWwiIHhtbG5zPSJo
dHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwIj4NCjxoZWFkPg0KPG1ldGEgaHR0cC1lcXVp
dj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9dXRmLTgiPg0KPG1l
dGEgbmFtZT0iR2VuZXJhdG9yIiBjb250ZW50PSJNaWNyb3NvZnQgV29yZCAxNSAoZmlsdGVyZWQg
bWVkaXVtKSI+DQo8c3R5bGU+PCEtLQ0KLyogRm9udCBEZWZpbml0aW9ucyAqLw0KQGZvbnQtZmFj
ZQ0KCXtmb250LWZhbWlseToiQ2FtYnJpYSBNYXRoIjsNCglwYW5vc2UtMToyIDQgNSAzIDUgNCA2
IDMgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6Q2FsaWJyaTsNCglwYW5vc2UtMToy
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OkFwdG9zOw0K
CXBhbm9zZS0xOjIgMTEgNiA0IDIgMiAyIDIgMiA0O30NCi8qIFN0eWxlIERlZmluaXRpb25zICov
DQpwLk1zb05vcm1hbCwgbGkuTXNvTm9ybWFsLCBkaXYuTXNvTm9ybWFsDQoJe21hcmdpbjowaW47
DQoJZm9udC1zaXplOjEyLjBwdDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjt9
DQphOmxpbmssIHNwYW4uTXNvSHlwZXJsaW5rDQoJe21zby1zdHlsZS1wcmlvcml0eTo5OTsNCglj
b2xvcjojMDU2M0MxOw0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0Kc3Bhbi5FbWFpbFN0
eWxlMTgNCgl7bXNvLXN0eWxlLXR5cGU6cGVyc29uYWwtcmVwbHk7DQoJZm9udC1mYW1pbHk6IkFw
dG9zIixzYW5zLXNlcmlmOw0KCWNvbG9yOndpbmRvd3RleHQ7fQ0KLk1zb0NocERlZmF1bHQNCgl7
bXNvLXN0eWxlLXR5cGU6ZXhwb3J0LW9ubHk7DQoJZm9udC1zaXplOjEwLjBwdDsNCgltc28tbGln
YXR1cmVzOm5vbmU7fQ0KQHBhZ2UgV29yZFNlY3Rpb24xDQoJe3NpemU6OC41aW4gMTEuMGluOw0K
CW1hcmdpbjoxLjBpbiAxLjBpbiAxLjBpbiAxLjBpbjt9DQpkaXYuV29yZFNlY3Rpb24xDQoJe3Bh
Z2U6V29yZFNlY3Rpb24xO30NCi0tPjwvc3R5bGU+DQo8L2hlYWQ+DQo8Ym9keSBsYW5nPSJFTi1V
UyIgbGluaz0iIzA1NjNDMSIgdmxpbms9IiM5NTRGNzIiIHN0eWxlPSJ3b3JkLXdyYXA6YnJlYWst
d29yZCI+DQo8ZGl2IGNsYXNzPSJXb3JkU2VjdGlvbjEiPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+
PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj5XZSBhcmUgcGxlYXNlZCB0byBhbm5vdW5jZSB0aGF0
IHRoZSBMdXN0cmUgMi4xPC9zcGFuPjY8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPi4wIFJlbGVh
c2UgaGFzIGJlZW4gZGVjbGFyZWQgR0EgYW5kIGlzIGF2YWlsYWJsZSBmb3ImbmJzcDs8L3NwYW4+
PHNwYW4gbGFuZz0iRU4tQ0EiPjxhIGhyZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91ZC5j
b20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xNi4wLyI+PHNwYW4gbGFuZz0iRU4tVVMiPmRvd25s
b2FkPC9zcGFuPjwvYT48YSBocmVmPSJodHRwczovL2Rvd25sb2Fkcy5ocGRkLmludGVsLmNvbS9w
dWJsaWMvbHVzdHJlL2x1c3RyZS0yLjExLjAvIj48c3BhbiBsYW5nPSJFTi1VUyI+Jm5ic3A7PC9z
cGFuPjwvYT48L3NwYW4+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4uDQogWW91IGNhbiBhbHNv
IGdyYWIgdGhlIHNvdXJjZSBmcm9tJm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48YSBo
cmVmPSJodHRwczovL2dpdC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDth
PWNvbW1pdDtoPWFjOWVkZmJmZDYzMmFmNjY3MGVkYmRmZTg1OTY5NjdkOWQxNWNkZWEiPjxzcGFu
IGxhbmc9IkVOLVVTIj5naXQ8L3NwYW4+PC9hPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNs
YXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+Jm5ic3A7PC9zcGFuPjxz
cGFuIGxhbmc9IkVOLUNBIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9y
bWFsIj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlRoaXMgbWFqb3IgcmVsZWFzZSBpbmNsdWRl
cyBuZXcgZmVhdHVyZXM6Jm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPjwvbzpw
Pjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iY29sb3I6Ymxh
Y2siPiZuYnNwOzwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSI+PG86cD48L286cD48L3NwYW4+PC9w
Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+UkhFTCA5LjQgU2VydmVyIHN1cHBvcnQ8L2I+PHNw
YW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+UHJvdmlkaW5nIHRoZSBvcHRpb24g
dG8gdXNlIGxhcmdlIE5JRHMNCjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+KDwvc3Bhbj48c3Bh
biBsYW5nPSJFTi1DQSI+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3Nl
L0xVLTEwMzkxIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImNvbG9yOndpbmRvd3RleHQiPkxV
LTEwMzkxPC9zcGFuPjwvYT48L3NwYW4+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4pPC9zcGFu
PjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iZm9udC1zaXplOjExLjBwdCI+PG86cD48L286cD48
L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+PG86cD4mbmJzcDs8L286cD48L2I+
PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+SVB2NiBTdXBwb3J0PC9iPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+Jm5ic3A7PC9zcGFuPlByb3ZpZGluZyB0aGUgb3B0aW9uIHRvIHVzZSBs
YXJnZSBOSURzDQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPig8L3NwYW4+PHNwYW4gbGFuZz0i
RU4tQ0EiPjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0xMDM5
MSI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJjb2xvcjp3aW5kb3d0ZXh0Ij5MVS0xMDM5MTwv
c3Bhbj48L2E+PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+KTwvc3Bhbj48c3BhbiBs
YW5nPSJFTi1DQSIgc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQiPjxvOnA+PC9vOnA+PC9zcGFuPjwv
cD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iZm9udC1z
aXplOjExLjBwdDtmb250LWZhbWlseTomcXVvdDtBcHRvcyZxdW90OyxzYW5zLXNlcmlmIj48bzpw
PiZuYnNwOzwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48Yj5PcHRpbWl6
ZWQgRGlyZWN0b3J5IFRyYXZlcnNhbDwvYj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiZuYnNw
Ozwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSI+SW1wcm92ZWQgU3BlZWQvRWZmaWNpZW5jeSBmb3Ig
bGFyZ2UgZGlyZWN0b3JpZXMvdHJlZXMgJm5ic3A7PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpi
bGFjayI+KDwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSI+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndo
YW1jbG91ZC5jb20vYnJvd3NlL0xVLTE1OTc1Ij48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImNv
bG9yOndpbmRvd3RleHQiPkxVLTE1OTc1PC9zcGFuPjwvYT48L3NwYW4+PHNwYW4gc3R5bGU9ImNv
bG9yOmJsYWNrIj4pPG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+
Jm5ic3A7PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFuZz0i
RU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IHN0eWxlPSJjb2xvcjpibGFjayI+RnVsbGVyIGRldGFpbHMgYWJvdXQgdGhpcyByZWxlYXNlIGNh
biBiZSBmb3VuZCBpbiZuYnNwO3RoZSZuYnNwOzwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSI+PGEg
aHJlZj0iaHR0cDovL3dpa2kubHVzdHJlLm9yZy9SZWxlYXNlXzIuMTYuMCI+PHNwYW4gbGFuZz0i
RU4tVVMiIHN0eWxlPSJjb2xvcjp3aW5kb3d0ZXh0Ij4yLjE2IHdpa2kgcGFnZSZuYnNwOzwvc3Bh
bj48L2E+PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+KGluY2x1ZGluZyZuYnNwO3Ro
ZSZuYnNwOzwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSI+PGEgaHJlZj0iaHR0cDovL3dpa2kubHVz
dHJlLm9yZy9MdXN0cmVfMi4xNi4wX0NoYW5nZWxvZyI+PHNwYW4gbGFuZz0iRU4tVVMiPmNoYW5n
ZQ0KIGxvZyZuYnNwOzwvc3Bhbj48L2E+PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+
YW5kJm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48YSBocmVmPSJodHRwczovL3dpa2ku
bHVzdHJlLm9yZy9SZWxlYXNlXzIuMTYuMCNUZXN0X01hdHJpeCI+PHNwYW4gbGFuZz0iRU4tVVMi
PnRlc3QgbWF0cml4PC9zcGFuPjwvYT48L3NwYW4+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4p
PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9
ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNv
Tm9ybWFsIj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Zm9udC1m
YW1pbHk6JnF1b3Q7QXB0b3MmcXVvdDssc2Fucy1zZXJpZiI+Tm90ZTogSXQgaXMgcmVjb21tZW5k
ZWQgdG8gYXZvaWQgdXNpbmcgU2VsZi1FeHRlbmRpbmcgTGF5b3V0cyBpbiBjb25qdW5jdGlvbiB3
aXRoIDIuMTYgdW50aWwNCjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dz
ZS9MVS0xODQxNiI+TFUtMTg0MTY8L2E+IGlzIG1vcmUgZnVsbHkgdW5kZXJzdG9vZC48bzpwPjwv
bzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1DQSIg
c3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Zm9udC1mYW1pbHk6JnF1b3Q7QXB0b3MmcXVvdDssc2Fu
cy1zZXJpZiI+PG86cD4mbmJzcDs8L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj5QbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQg
aW4gdGhlJm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48YSBocmVmPSJodHRwczovL2pp
cmEud2hhbWNsb3VkLmNvbS8iPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iY29sb3I6cHVycGxl
Ij5pc3N1ZSB0cmFja2luZyBzeXN0ZW08L3NwYW4+PC9hPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4N
CjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+Jm5ic3A7PC9z
cGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0i
TXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlRoYW5rcyB0byBhbGwgdGhvc2Ug
d2hvIGhhdmUgY29udHJpYnV0ZWQgdG8gdGhlIGNyZWF0aW9uIG9mIHRoaXMgcmVsZWFzZS48L3Nw
YW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48Yj48c3BhbiBsYW5nPSJF
Ti1DQSI+PG86cD4mbmJzcDs8L286cD48L3NwYW4+PC9iPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3Jt
YWwiPjxiPjxzcGFuIGxhbmc9IkVOLUNBIj5UaGlzIHJlbGVhc2UgaXMgZGVkaWNhdGVkIHRvIHRo
ZSBtZW1vcnkgb2YNCjxhIGhyZWY9Imh0dHBzOi8vd3d3LmxpbmtlZGluLmNvbS9pbi9vbGFmLXdl
YmVyLTcwNjU2YTliLyI+T2xhZiBXZWJlcjwvYT4gd2hvIHdhcyBhbiBhY3RpdmUgbWVtYmVyIG9m
IHRoZSBMdXN0cmUgV29ya2luZyBHcm91cCBhbmQgYSBsb25nLXRlcm0gY29udHJpYnV0b3IgdG8g
dGhlIEx1c3RyZSBwcm9qZWN0LiBPbGFmIHBhc3NlZCBhd2F5IHN1ZGRlbmx5IGVhcmxpZXIgdGhp
cyB5ZWFyIGFuZCBpcyBtdWNoLW1pc3NlZCBieSB0aG9zZSBvZiB1cyB3aG8NCiBoYWQgdGhlIHBs
ZWFzdXJlIG9mIHdvcmtpbmcgd2l0aCBoaW0uPG86cD48L286cD48L3NwYW4+PC9iPjwvcD4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxiPiZuYnNwOzwvYj48Yj48c3BhbiBsYW5nPSJFTi1DQSI+PG86
cD48L286cD48L3NwYW4+PC9iPjwvcD4NCjwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1sPg0K

--_000_29F3CE3E821043E7BE1A1A8B81D58BC7whamcloudcom_--

--===============1140645814345099270==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1140645814345099270==--
