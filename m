Return-Path: <SRS0=WgwA=P4=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E132AC433EF
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Nov 2021 03:56:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 78D6F611ED
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Nov 2021 03:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 78D6F611ED
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 17CA921C960;
	Mon,  8 Nov 2021 19:56:02 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11on2085.outbound.protection.outlook.com [40.107.236.85])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C5C4C200F27
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 19:55:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=C+GLGl0N0+5fJw8hkyVopScs+XCT6ee/oLkWfIy0f5ehdVQAkj38PrST/Lraj4vEwh760/ZeM0sbC7s5KoWqYWnOgxWVf0vnuphQFWm10zFl6EejkpZ2HKKAcGgFOGC0FuMNMvX8O6DLwexGBz4ZtmJjoxRDXOpJqFtwke+BVmRto0DpdFFtecJEfajmGiGnxizs0pyH77uyoII7Z+HOWCvyrYkoCbdGnHTUaD2+BADmKWNFJPuRJM5Vr32cANLx6TQQ4PGVy3dOqJbmU/7ggzt9WXqqvr3A8em7IsDw6teKWYaAwpBED7GTpznSpv6tX6UEmtdE4o8xwGedvfc7ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=X9rfok/1wPDYmx9kUvpuqygWs6D6pzOYwaZIL10+2Jo=;
 b=gl0WL8i0ti1Ey9vvTkodMz9V/qFrj/IH5WKt41gMKKofXqmEwebOUWgGARht/ZrLygAHu4WpF5rX9vc+yPalT56St8RigdFQLLk4RNu8laH4TuhEGM+68UaTAHsgkv669PdLsKeBIIbnYY528gvdA4ODOnRmALiHJwOtOkckxZ5sLWnGDG9e61EG7tD7WvKhrCfyqE1fN16oOAzDLI53+St5ERnj0a+6lY/a4pOotCJVjpSj/+6RQoVjQUqrEX9HHHxESRoITZGEPRHxCVJ9DPTSibr1E8v/XvAvKRGG/5rsqXq+66AxeGEeH86hQd36k797W6Q4YcFscJ639o/Msg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=X9rfok/1wPDYmx9kUvpuqygWs6D6pzOYwaZIL10+2Jo=;
 b=yqPNhptLGFAmW5c4UFgaEwOtdjElc9pLmomnB252B0tkCiLgItYl6JmLgzpQM4aQLPr/40GyqvUFeJ45IZRMi15kAEOUPjHAF4/CspHtKQbXv+5eYI8YGvuPW/RH8W021ZCuY+MRpAxQJUlYBHlw678yVUYL4Hrs0wMeakj/bfg=
Received: from MW3PR19MB4220.namprd19.prod.outlook.com (2603:10b6:303:45::24)
 by MW2PR1901MB2187.namprd19.prod.outlook.com (2603:10b6:302:6::24)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4669.15; Tue, 9 Nov
 2021 03:55:56 +0000
Received: from MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::f52f:eade:b1e8:51ef]) by MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::f52f:eade:b1e8:51ef%6]) with mapi id 15.20.4669.016; Tue, 9 Nov 2021
 03:55:56 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Whamcloud lab move
Thread-Index: AQHX1R2yzqkujAHZaU+Mkb7ZAdSJZA==
Date: Tue, 9 Nov 2021 03:55:55 +0000
Message-ID: <4855B19D-D32F-4BDF-9A6C-A2BFC924C49B@ddn.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.10.1b.201012
authentication-results: lists.lustre.org; dkim=none (message not signed)
 header.d=none;lists.lustre.org; dmarc=none action=none
 header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: af4ae365-9643-46d7-5b0c-08d9a334d544
x-ms-traffictypediagnostic: MW2PR1901MB2187:
x-microsoft-antispam-prvs: <MW2PR1901MB2187C54E8E8324EC1E5AFD93DA929@MW2PR1901MB2187.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: Xb6D6w7qfgnfnufQQjlXWOcWSRKfuuzgCvV4yXhc8IVsDYw1hp5x1TVZY8S9/pVuoHcBFrGNIChMsQuuFOf2uVm/u7gqIUvlkGJaRpRmJn1aB/CL/1hTna6AM1qFsd7gqQ/HAIzI0+cstSBNTYzopFgPBwKaK+I3MW1xNcU0XqJHWDfl7Hgg7xWeXhcR81I5WKZQkBfTz7G7OgW3OTFMVzkamXlgw3sawCpGXF3f79Vpb/azjtrxANR/0zmaiszkjck1GjBSujHcwYfabM67Og48r54cmBb+xya4+QogvSqc7llZyRq50+DGROmw01D+juapqqH6dLLHl9INISL4avq4wd8rhkvpOZ4diQBaU0//VJgb7Kbh9ni47dpTSSzhUGK1lH2LEWJpGhciQw6xGMWGa23G6TCRbm4rtw/j/kSAq4EQx/1rK7dflxlf4rkW9bb6licIn+rAYL5fE/9Q30fKLFPr+dTPnJPT3pU1Di084x6ObMlHb/EdNppFlyD4tlYrMe/l40ermlKp3USB4ZD+YDfunb4Oobgj+Biyzvd8C68PNvCVPPQEnvz5W2v9j2qOs8W/oq936Q8J/3YCfTGwkJmY9Xo0Qbkv6eXaVQ81kbrBwyzH3U81eiKa5UwPT/GK/Mic1ErLA/4NV6HsfSUn+ic7bdCerBGya40eNQiiYxkRdu4v2nxZsL5qRmFRYazmdfOSnT5zcGWrNLFOww==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR19MB4220.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(4744005)(9686003)(6916009)(36756003)(66446008)(64756008)(66556008)(66476007)(2906002)(66946007)(5660300002)(8676002)(6512007)(316002)(38100700002)(38070700005)(6486002)(33656002)(122000001)(508600001)(7116003)(8936002)(86362001)(71200400001)(3480700007)(186003)(76116006)(6506007);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?bnJvQm5oTS9QYnJSU21CT2R6c2ZpZFVmeVhqMGlXZHpwSWVSOFlwQmRoSW9K?=
 =?utf-8?B?SENpVWxkbGRzTE9SQXZucUdIcEJlMXh2bHo2N0xaV093allDRFBOTXVHMTVy?=
 =?utf-8?B?dGpzZWdTbnlsZzlBbXZJbTBnZDdwdnJjcXluRkRYUGdob1NMRnZHZHJKNVNt?=
 =?utf-8?B?TGUxTDdEbUR1ZVdUYjVzc1g1YkJ1QzdES0lBTU9zd3JFOU9rMHBYbEpaQlNE?=
 =?utf-8?B?blZBbTIxNElNVnJ4QUt2UmJUaE96QzVFc1czdHlCcVZNa3M1dEQ3ZnFBUHRS?=
 =?utf-8?B?M3F0aWFaaHJvYk43ZVdOTldXSDJaY0lRazFRSW5qZ3RVV1ptS1Z5eUhsSWZa?=
 =?utf-8?B?d0FoOUJlYjE5NTkwc2tzQUJTSXJxczVRVmFEMm1LZXBpd1lvMlNnVmdqSk1Z?=
 =?utf-8?B?OVVkb2RQcVRZSUN2WVVMb1IzNlBxbitadENLUWMyK0tCSnFGS0ZpdXVwRGFm?=
 =?utf-8?B?TWw1eEUxeGhzamFBb2s5MFBWM0N2dGVpcUIvMmtNeERGNlVxWmMzK2d4c0RT?=
 =?utf-8?B?dnJNQlV0OExEek1jeGVwVjRkTmFmS1huNmF3dzJsTTA3bzFKa3lsN3kyWWlv?=
 =?utf-8?B?OTN0bUg4dCtwa0VjNEw5Y3VRQ2hkdnlMamdRZFJ6RzRpUjdiS1VvMGtkZmNt?=
 =?utf-8?B?WjFFTVc3bnZrVmdyMU53akp3K1lBdTNXZ0piYmlZK3FlbUV3dHIwc1lMWmpI?=
 =?utf-8?B?UHVLa2cyR2VpNnRaOHZDeURwRkpiVzlnUkZXUGJ2WUYyb2lyRFQ2RWFyajJW?=
 =?utf-8?B?Y3NFVFJVRkc5b3h4dTRCNEh6aEVlMVRUeEt0amV4em1FRlBmWXpEOERtYlZ5?=
 =?utf-8?B?U2pxSHFTTTE5WlZiZ1pYMXh0MldhR0I5Z0orclljNC9yanVsSVBjcUxCUjJm?=
 =?utf-8?B?OTNXR3FhcWZYVTZ6QjY2L1E4UHB3SWd1eS9lZVRmWlpVNEFmT1BaUWhsOXpY?=
 =?utf-8?B?WXl1QWhCMTA1UDZ5cXlKSVZldVVDaFE2QU10T0F1WFJuYnZmcytMSVlnNWpU?=
 =?utf-8?B?WTFDc3Nuc1prSTQxdkhxVU0zVFJmZGNUSnhWc0Z5aFVpUDBIcWZqaUdlZXZK?=
 =?utf-8?B?ZGRSRkFzVkJ2TU40SllzaERWdk85MzVQaWJ1VVhtcURqY3pqSmZ5Z1licFZT?=
 =?utf-8?B?VnlkY2NhdTBBK3JKbXJMZFk1OEZuNDEwRjZyQTJ0SXcrQVhUWU9LVFd4b1Nr?=
 =?utf-8?B?WlVZK3haSzFSMGlhL3RJOEhQV1RSK3hRQmxGT0Rab05KSXRzMklWRVNXR2Qr?=
 =?utf-8?B?M1pwd1JmanBRZjY4ajZ6TDZoVVZLc3l6Z09GN1Z5TDNFWmlJYmc2MFdjQzNF?=
 =?utf-8?B?NWR0Tys3ZkVNSmxPUjFvQzk5NXgrbk9ER3MrbUZVa1FGd29mVFByQnBjWUJX?=
 =?utf-8?B?VE1kZmhUdmU5eklja3daRkFlNjRLNzFwQlBFSEFnam9lbHZBd0pBOUt5VVd3?=
 =?utf-8?B?ZFJvOFFnRlpKYmFSSjBVUmZzMVZUTjhneXhVVzNuYjVScWFSUjdNckdEeG9u?=
 =?utf-8?B?OE1XR3BSUThENFczQk1NTlBydWpDZFRwaWlnOGgydHJxMlJSV25SMlhCNE43?=
 =?utf-8?B?NjE4dG1nZVFwSVB3OWVBaVdwWmF6cVYwUmQrLyszTGtYeDdDNUZGKzlsZUNQ?=
 =?utf-8?B?VHB3aktGdXNORUwyOGxNQ0xPbk14NzJ0RnBsckY1UU4vSlVhRnBhMDFlTjhq?=
 =?utf-8?B?VkNqUzF0QVlraXNuOXcwS1NYbjVpcG5malFqQ0J5RDJqa0gyOHhVQUJNZGlW?=
 =?utf-8?B?aEYwSkk1WDNoRnJVVVVYamlVQWNwMkVIUDNudGFNaEk5aDN4cGVvU0RmNnR0?=
 =?utf-8?B?elkveURWS0dMS084aHhaTFdHNjJTRGpzQ0xaVXo2Wlo1Ym9HdUdCeUdTa3hX?=
 =?utf-8?B?VHV4Z0hVYVAwcFN2NVZrL09ybzRLMm9QelllRjBrTnFzclVKK2FwVWQ0Z0Qv?=
 =?utf-8?B?R09DdUYwazBqZm5CNTVkTXkvWmFkZDNhcnhhRWlUblFvNnJqazFtU25nQXJB?=
 =?utf-8?B?amFOWDlGT0M3ZjhoVTJ2STNHRndObWdrdDF3YnJwTVl0a0gwbFNkTkxvVkNQ?=
 =?utf-8?B?OENBa1NUY0lwcTNldXVPbkdpZ3ErNzlndFZpQ0xRK0ZaZ2YxRXNBSkh0cjRz?=
 =?utf-8?B?bWVnQXJkUy9jZUU3OG9WTWMzWDZlQ0VGbHYzYTJBWFNJWGhOWC9SWkNRTnQv?=
 =?utf-8?Q?4fhy/JhxT68q6X5we4bhD0i9+jkobW8zQLZMdTXmf4Ch?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR19MB4220.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: af4ae365-9643-46d7-5b0c-08d9a334d544
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Nov 2021 03:55:55.9447 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: mYbuTFTMkoCuCt2ci/3h1D3Sa2WB4Scq/DYm++QaEVGwZUh5+lfRC8ervVT+PcRJ
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW2PR1901MB2187
Subject: [lustre-devel] Whamcloud lab move
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
From: Peter Jones via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Peter Jones <pjones@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============1492845406775863678=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1492845406775863678==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_4855B19DD32F4BDF9A6CA2BFC924C49Bddncom_"

--_000_4855B19DD32F4BDF9A6CA2BFC924C49Bddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

SGkgdGhlcmUNCg0KVGhlIGNvbW11bml0eSBidWlsZC90ZXN0IGluZnJhc3RydWN0dXJlIHdpbGwg
YmUgbW92aW5nIGJldHdlZW4gZGF0YSBjZW50ZXJzLg0KDQpXZSB3aWxsIG1ha2UgZXZlcnkgZWZm
b3J0IHRvIG1pbmltaXplIHRoZSBkaXNydXB0aW9uIGR1cmluZyB0aGlzIHRyYW5zaXRpb24gYnV0
IHRoZXJlIHdpbGwgbmVlZCB0byBiZSBhIGJyaWVmIG91dGFnZSAob2Ygc29tZSBob3Vycykgb24g
Tm92IDEwdGggYXMgd2UgYnJpbmcgc2VydmljZXMgdXAgaW4gdGhlIG5ldyBsb2NhdGlvbi4NCg0K
VGhlcmUgbWF5IGJlIGxvbmdlciB0aGFuIG5vcm1hbCB0dXJuYXJvdW5kIGZvciBidWlsZHMvdGVz
dGluZyB0byBydW4gaW4gdGhlIGZvbGxvd2luZyB3ZWVrcyB1bnRpbCBhcyB3ZSB3aWxsIGJlIHJ1
bm5pbmcgd2l0aCBzaWduaWZpY2FudGx5IHJlZHVjZWQgY2FwYWNpdHkgd2hpbGUgZXF1aXBtZW50
IGlzIHJlbG9jYXRpbmcuDQoNClBsZWFzZSBiZSBwYXRpZW50IGR1cmluZyB0aGlzIHRpbWUgYW5k
IGRlZmVyIGFueSB3b3JrIHRoYXQgaXMgbm90IHRpbWUtc2Vuc2l0aXZlIHVudGlsIGFmdGVyIHRo
ZSB0cmFuc2l0aW9uIGlzIGNvbXBsZXRlLg0KDQpKSVJBLCBnZXJyaXQgYW5kIHRoZSB3aWtpIHdp
bGwgbm90IGJlIGltcGFjdGVkIGJ5IHRoaXMgY2hhbmdlLg0KDQpUaGFua3MNCg0KV2hhbWNsb3Vk
IFRlYW0NCg0K

--_000_4855B19DD32F4BDF9A6CA2BFC924C49Bddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <68E2807DE4C685448A8E4173F4553DD2@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6dj0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTp2bWwiIHhtbG5zOm89InVy
bjpzY2hlbWFzLW1pY3Jvc29mdC1jb206b2ZmaWNlOm9mZmljZSIgeG1sbnM6dz0idXJuOnNjaGVt
YXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6d29yZCIgeG1sbnM6bT0iaHR0cDovL3NjaGVtYXMubWlj
cm9zb2Z0LmNvbS9vZmZpY2UvMjAwNC8xMi9vbW1sIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcv
VFIvUkVDLWh0bWw0MCI+DQo8aGVhZD4NCjxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIg
Y29udGVudD0idGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04Ij4NCjxtZXRhIG5hbWU9IkdlbmVyYXRv
ciIgY29udGVudD0iTWljcm9zb2Z0IFdvcmQgMTUgKGZpbHRlcmVkIG1lZGl1bSkiPg0KPHN0eWxl
PjwhLS0NCi8qIEZvbnQgRGVmaW5pdGlvbnMgKi8NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6
IkNhbWJyaWEgTWF0aCI7DQoJcGFub3NlLTE6MiA0IDUgMyA1IDQgNiAzIDIgNDt9DQpAZm9udC1m
YWNlDQoJe2ZvbnQtZmFtaWx5OkNhbGlicmk7DQoJcGFub3NlLTE6MiAxNSA1IDIgMiAyIDQgMyAy
IDQ7fQ0KQGZvbnQtZmFjZQ0KCXtmb250LWZhbWlseToiVGltZXMgTmV3IFJvbWFuIFwoQm9keSBD
U1wpIjsNCglwYW5vc2UtMToyIDIgNiAzIDUgNCA1IDIgMyA0O30NCi8qIFN0eWxlIERlZmluaXRp
b25zICovDQpwLk1zb05vcm1hbCwgbGkuTXNvTm9ybWFsLCBkaXYuTXNvTm9ybWFsDQoJe21hcmdp
bjowY207DQoJbWFyZ2luLWJvdHRvbTouMDAwMXB0Ow0KCWZvbnQtc2l6ZToxMi4wcHQ7DQoJZm9u
dC1mYW1pbHk6IkNhbGlicmkiLHNhbnMtc2VyaWY7fQ0KYTpsaW5rLCBzcGFuLk1zb0h5cGVybGlu
aw0KCXttc28tc3R5bGUtcHJpb3JpdHk6OTk7DQoJY29sb3I6IzA1NjNDMTsNCgl0ZXh0LWRlY29y
YXRpb246dW5kZXJsaW5lO30NCmE6dmlzaXRlZCwgc3Bhbi5Nc29IeXBlcmxpbmtGb2xsb3dlZA0K
CXttc28tc3R5bGUtcHJpb3JpdHk6OTk7DQoJY29sb3I6Izk1NEY3MjsNCgl0ZXh0LWRlY29yYXRp
b246dW5kZXJsaW5lO30NCnNwYW4uRW1haWxTdHlsZTE3DQoJe21zby1zdHlsZS10eXBlOnBlcnNv
bmFsLWNvbXBvc2U7DQoJZm9udC1mYW1pbHk6IkNhbGlicmkiLHNhbnMtc2VyaWY7DQoJY29sb3I6
d2luZG93dGV4dDsNCglmb250LXdlaWdodDpub3JtYWw7DQoJZm9udC1zdHlsZTpub3JtYWw7fQ0K
c3Bhbi5hcHBsZS1jb252ZXJ0ZWQtc3BhY2UNCgl7bXNvLXN0eWxlLW5hbWU6YXBwbGUtY29udmVy
dGVkLXNwYWNlO30NCi5Nc29DaHBEZWZhdWx0DQoJe21zby1zdHlsZS10eXBlOmV4cG9ydC1vbmx5
Ow0KCWZvbnQtZmFtaWx5OiJDYWxpYnJpIixzYW5zLXNlcmlmO30NCkBwYWdlIFdvcmRTZWN0aW9u
MQ0KCXtzaXplOjYxMi4wcHQgNzkyLjBwdDsNCgltYXJnaW46NzIuMHB0IDcyLjBwdCA3Mi4wcHQg
NzIuMHB0O30NCmRpdi5Xb3JkU2VjdGlvbjENCgl7cGFnZTpXb3JkU2VjdGlvbjE7fQ0KLS0+PC9z
dHlsZT48IS0tW2lmIGd0ZSBtc28gOV0+PHhtbD4NCjxvOnNoYXBlZGVmYXVsdHMgdjpleHQ9ImVk
aXQiIHNwaWRtYXg9IjEwMjYiIC8+DQo8L3htbD48IVtlbmRpZl0tLT48IS0tW2lmIGd0ZSBtc28g
OV0+PHhtbD4NCjxvOnNoYXBlbGF5b3V0IHY6ZXh0PSJlZGl0Ij4NCjxvOmlkbWFwIHY6ZXh0PSJl
ZGl0IiBkYXRhPSIxIiAvPg0KPC9vOnNoYXBlbGF5b3V0PjwveG1sPjwhW2VuZGlmXS0tPg0KPC9o
ZWFkPg0KPGJvZHkgbGFuZz0iRU4tQ0EiIGxpbms9IiMwNTYzQzEiIHZsaW5rPSIjOTU0RjcyIj4N
CjxkaXYgY2xhc3M9IldvcmRTZWN0aW9uMSI+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBs
YW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxNC4wcHQ7Y29sb3I6YmxhY2siPkhpIHRoZXJl
PC9zcGFuPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwv
bzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIg
c3R5bGU9ImZvbnQtc2l6ZToxNC4wcHQ7Y29sb3I6YmxhY2siPiZuYnNwOzwvc3Bhbj48c3BhbiBz
dHlsZT0iZm9udC1zaXplOjExLjBwdDtjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9w
Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNp
emU6MTQuMHB0O2NvbG9yOmJsYWNrIj5UaGUgY29tbXVuaXR5IGJ1aWxkL3Rlc3QgaW5mcmFzdHJ1
Y3R1cmUgd2lsbCBiZSBtb3ZpbmcgYmV0d2VlbiBkYXRhIGNlbnRlcnMuJm5ic3A7PC9zcGFuPjxz
cGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwvc3Bh
bj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZv
bnQtc2l6ZToxNC4wcHQ7Y29sb3I6YmxhY2siPiZuYnNwOzwvc3Bhbj48c3BhbiBzdHlsZT0iZm9u
dC1zaXplOjExLjBwdDtjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xh
c3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTQuMHB0
O2NvbG9yOmJsYWNrIj5XZSB3aWxsIG1ha2UgZXZlcnkgZWZmb3J0IHRvIG1pbmltaXplIHRoZSBk
aXNydXB0aW9uIGR1cmluZyB0aGlzIHRyYW5zaXRpb24gYnV0IHRoZXJlIHdpbGwgbmVlZCB0byBi
ZSBhIGJyaWVmIG91dGFnZSAob2Ygc29tZSBob3Vycykgb24gTm92IDEwPHN1cD50aDwvc3VwPiZu
YnNwO2FzIHdlIGJyaW5nIHNlcnZpY2VzIHVwJm5ic3A7aW4NCiB0aGUgbmV3IGxvY2F0aW9uLjwv
c3Bhbj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBwdDtjb2xvcjpibGFjayI+PG86cD48L286
cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0
eWxlPSJmb250LXNpemU6MTQuMHB0O2NvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gc3R5
bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4N
CjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXpl
OjE0LjBwdDtjb2xvcjpibGFjayI+VGhlcmUgbWF5IGJlIGxvbmdlciB0aGFuIG5vcm1hbCB0dXJu
YXJvdW5kIGZvciBidWlsZHMvdGVzdGluZyB0byBydW4gaW4gdGhlIGZvbGxvd2luZyB3ZWVrcyB1
bnRpbCBhcyB3ZSB3aWxsIGJlIHJ1bm5pbmcgd2l0aCBzaWduaWZpY2FudGx5IHJlZHVjZWQgY2Fw
YWNpdHkgd2hpbGUgZXF1aXBtZW50IGlzIHJlbG9jYXRpbmcuPC9zcGFuPjxzcGFuIHN0eWxlPSJm
b250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBj
bGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxNC4w
cHQ7Y29sb3I6YmxhY2siPiZuYnNwOzwvc3Bhbj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBw
dDtjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTQuMHB0O2NvbG9yOmJsYWNr
Ij5QbGVhc2UgYmUgcGF0aWVudCBkdXJpbmcgdGhpcyB0aW1lIGFuZCBkZWZlciBhbnkgd29yayB0
aGF0IGlzIG5vdCB0aW1lLXNlbnNpdGl2ZSB1bnRpbCBhZnRlciB0aGUgdHJhbnNpdGlvbiBpcyBj
b21wbGV0ZS4mbmJzcDs8L3NwYW4+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6
YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjE0LjBwdDtjb2xvcjpibGFjayI+Jm5ic3A7
PC9zcGFuPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwv
bzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIg
c3R5bGU9ImZvbnQtc2l6ZToxNC4wcHQ7Y29sb3I6YmxhY2siPkpJUkEsIGdlcnJpdCBhbmQgdGhl
IHdpa2kgd2lsbCBub3QgYmUgaW1wYWN0ZWQgYnkgdGhpcyBjaGFuZ2UuPC9zcGFuPjxzcGFuIHN0
eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+
DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6
ZToxNC4wcHQ7Y29sb3I6YmxhY2siPiZuYnNwOzwvc3Bhbj48c3BhbiBzdHlsZT0iZm9udC1zaXpl
OjExLjBwdDtjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1z
b05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTQuMHB0O2NvbG9y
OmJsYWNrIj5UaGFua3M8L3NwYW4+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6
YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjE0LjBwdDtjb2xvcjpibGFjayI+Jm5ic3A7
PC9zcGFuPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwv
bzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIg
c3R5bGU9ImZvbnQtc2l6ZToxNC4wcHQ7Y29sb3I6YmxhY2siPldoYW1jbG91ZCBUZWFtPC9zcGFu
PjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0O2NvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwv
c3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9
ImZvbnQtc2l6ZToxNC4wcHQiPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4NCjwvZGl2Pg0K
PC9ib2R5Pg0KPC9odG1sPg0K

--_000_4855B19DD32F4BDF9A6CA2BFC924C49Bddncom_--

--===============1492845406775863678==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1492845406775863678==--
