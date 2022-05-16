Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 00E29C433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 16 May 2022 15:18:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ABC9121CB56;
	Mon, 16 May 2022 08:18:55 -0700 (PDT)
Received: from NAM11-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam11on2055.outbound.protection.outlook.com [40.107.223.55])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A010B2010C2
 for <lustre-devel@lists.lustre.org>; Mon, 16 May 2022 08:18:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=kFzbnq3u4miStQAxrjBjx66LquUEMpI7xZQr7hzfXZ74Afen4fK+hQZIn0itEQDkyGDlwu+r9A6ZZaSWy+cSTBGrsP4tvq4jhkwIBnHklj0Ys+K+CSEMLNOqzz9YpGT79G49i4GwAODBNbgFmRJZ3yXy7Z22XxeEMpywKjJqq1OaJeHGD+RjMcGO2BlJkOlfU47fDESJG1neR7btbGg0OwlZP53fO9FNF0yzSbQL1z9MJxJLcCGVuUvzMMJg/u7sGqEpSIWEba+X1Dt1ig/4TtUvrj1Iq9y1TiGPDEApDzdz+jevur1AySd+gAx1mGxheXHiFLc0F+AvgxF5cYNl/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=OZ0kWYVuNT+CXPd/MLxbA5jepXtR/VfPnxBQg5S3Jfo=;
 b=n88v0lRMaJAF8IfRX6HJripzfO+Psu/8u6QH6PoplH2calYSoDwwFyWJxcJjORwtrbCZULIfUYKPv2MzhXfHk9j3NyW4XVYzkiVm47XqUogtiYJ2qPgM48l63G0/Ads5A3gSWmids50IxVn1Kqi5vYN04cTix7IbFOP2mZ8ZmrQ3E4V+FSkkCUOG1F9mjzRHOMdDz/p8BCNYXoGxARF9+d05kdUFm2jd73KjFL/LsUBLKYh2pLwui6R3WF2vEeFj65ObcfG5LdqQ4hdKcuRzmGlDhaqo4uEmU3d9JtB6xh6l/SGtsmtJ5aN+6NwD6748N5j5RAQ7p9oKdxL08tpwWw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OZ0kWYVuNT+CXPd/MLxbA5jepXtR/VfPnxBQg5S3Jfo=;
 b=PlfRVr3+AAtwe7moM+S4/1dEER9qZPQ4R2WZ50jZXZAAatL/+f2hPaDeFpuDYxanBpcPy4pF/CghxajKanv9OTwT9c1EKDj7QXC85XWcsilascCWcRc/Yhdwp4dci+diOF7IY66hHIYOhysPAr1sZpJN5JQXwf/3tO0EmRkT4TI=
Received: from DM6PR19MB3769.namprd19.prod.outlook.com (2603:10b6:5:229::19)
 by SN6PR1901MB2189.namprd19.prod.outlook.com (2603:10b6:805:e::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5250.18; Mon, 16 May
 2022 15:18:07 +0000
Received: from DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::5d57:a4b1:9e86:7243]) by DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::5d57:a4b1:9e86:7243%5]) with mapi id 15.20.5250.018; Mon, 16 May 2022
 15:18:07 +0000
To: James Simmons <jsimmons@infradead.org>
Thread-Topic: [PATCH v2] fscrypt: allow alternative bounce buffers
Thread-Index: AQHYZ8VXd7J5nz/SokOyBNe7fYmqaq0hoL2A
Date: Mon, 16 May 2022 15:18:07 +0000
Message-ID: <3CF7A24D-7E4F-4C35-88A6-DA660F31705D@ddn.com>
References: <1652555017-16601-1-git-send-email-jsimmons@infradead.org>
In-Reply-To: <1652555017-16601-1-git-send-email-jsimmons@infradead.org>
Accept-Language: fr-FR, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b908389a-c869-469f-1bbb-08da374f47b9
x-ms-traffictypediagnostic: SN6PR1901MB2189:EE_
x-microsoft-antispam-prvs: <SN6PR1901MB218942ABBD625FB0C22176ECD7CF9@SN6PR1901MB2189.namprd19.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: gngv1NnNqVsUoQUR1e472b/gwGzwm+3f+4WMyWg86x4WvyFJb0lvqB3oIBxXZOAIys7ir3gQGX9XABzzhqPX4uKcqSgElRUHqy6USOuj49YyFJCpt19AP+twuJj4c7M0KLhRxU5k4nKxAefjjNZuFxZpO6g3ENxzGJYwnnEKuY/Kt85m5AIODcsPtrebIX19ed3lEF+BwBl37jSPDSLVtoIOyc236eg/5/33gDk3czOPMB2xgV/lc+WXJr/jMmavyblGWDlsWg2wVGOLbWnNMd6+ZoF01lTWkcX61tDnZdN/oh6aibvZvDk5l30Wa+vm1Ap0Op8pFHf+50X7nzJAQJuYDR14RIWN010xTX9BmPEEKcUOryxOBE9KO6bk51UBxvktYUuFj7dwmX2piLqzDk8SIrfnRf6yyKjgs31oj+jHL1aiqdTgjS5bXUvANnBBlz0vfupbISBf9FCEW1YPUlFn7C5p0y1k27efCb+tQALPSEQFsUWjpTHe+LLRurwLQwcShK9IUrh2IQ3gVfCGS033le66+J5hj6jd3AFvryEsSzpPMU7fIrgzi/X64PvwmGQWPZlNR6xDHqW3JIaWY0z9XNjH05wVvgddI3mV5z80sRqCPcRRLIpgDttad4Xygca3Q3pFBrqeQpz4eVVbcx2vr9nZJ22gx8KdbMTN0o5hsVHNOGEyhqUpxwXJOA+K5xD2HCRal87XGPccqPRbjq2dEgyEDS99XsoRleNdtpI=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR19MB3769.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(66946007)(6916009)(66446008)(64756008)(66556008)(66476007)(316002)(54906003)(122000001)(36756003)(33656002)(91956017)(5660300002)(76116006)(4326008)(8676002)(8936002)(6486002)(6512007)(2616005)(186003)(38100700002)(38070700005)(71200400001)(6506007)(26005)(83380400001)(2906002)(508600001)(86362001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?Z0EyR21oV0dGbWlyZ09WZGF1bWI1MXplbWtDUTJKMU5NN0t5OExSeldQR3N1?=
 =?utf-8?B?Wkx3dndQbWN2dEdqQUVxTlNabTN2Z3dQcE5LOEV1cmJ2M2dvRFZnNlNXZjlL?=
 =?utf-8?B?Z1RrYTlhbzU5R2NxZ2ZIZERiODBlODRjMzhoWW9zbGI1cngrRlBJNEVZZ3ZX?=
 =?utf-8?B?REh4Nmw0cVVzSjVJS1g0dThDZWhUK0NVcjFxMlJTM1NOcVpqblY0QnU4M3g4?=
 =?utf-8?B?cUpPZ2MxbEJBSmpjeitCbE9hdHE3Vmo2U2xLdzdOQ251OS9ab3ZodTUxRUpG?=
 =?utf-8?B?MDlJV21IUGZ0UVlkSTVZck43Q2JmblgrMXpnU0FOMEd2ZlQzWE9Hc01KTGg1?=
 =?utf-8?B?V200Qmp1dVVzQ0s0YzNYOVVXSzhCRWZGdGRRcXJ2YlU5bUljKzNzZzZTUWJL?=
 =?utf-8?B?eGIvajVVK0NKRFg1VldvcVpCZm1qWGRLNDZvSnlWSTBPK0IrK3NweUoydVdV?=
 =?utf-8?B?OEc2SlluV3dEM242aDJGUzRlZjlGM3lEbnM5V3FVY1JrZWU5a01odUJNdlho?=
 =?utf-8?B?R1ZvT2dpd3VSdEEvQ1NVeDJLcDFFajV4VGl4SWVBY2VIUGFvend2Mjc0L0RM?=
 =?utf-8?B?QnI4ZVkxODFWeFpzZE41TGVnWXVzM2hJdkFuOVVsb2ZSVnNZRDRma2pFZ3ll?=
 =?utf-8?B?dGg1UUwxZXpGU0gzbTJDbDhNc2N3SHBJM1BXcmJOMlkvWHMzai9JMnp1d3Zi?=
 =?utf-8?B?c0hxQ2lBYk1LVll4Y3JYci9mT21rdkRGNzFqMTZLQmpPVVlNQi8vTnFIeVlY?=
 =?utf-8?B?S1BsMy8xRk0xWHlzSGFlbkE4ZEhvQlRNZUNnVEk1Ujd6VGMzcldpa1R4RHpm?=
 =?utf-8?B?RGJFZ203MFdMYzdDWFVoYi82OXpWazJIUXVVTVltL1lVV3RyZmJ1YWZubjg2?=
 =?utf-8?B?WnoxeDdTNm5TTVd2QzlVZE1sVFpQblJGM3cvcWN6VnZETGVXZ1pZbDl6c1FQ?=
 =?utf-8?B?UHdwdTluSTlqeVlrYzZPWThKVFZYM0xZMGFad1NKQUVUTE1oTVFxV2Y5Wjlp?=
 =?utf-8?B?MDkxUVFFMmhCRVhoQkFEcmw3RUxaWDJQeFRnKzNIMTU0cVUxUHFyMSs3b0N5?=
 =?utf-8?B?UWlqdVZxSCt1ZUpYNUJPTmZyNDdWempmRnJhNlg3M0h4a3p5RWJJNHJiMGZS?=
 =?utf-8?B?VWFsdGRHWXlZdnJ5ZUhGb0ZTMUVMbzVIT1FuQTZIV2lMaDJkZXUvT05qNVVG?=
 =?utf-8?B?OEMrWHRXZ2t6U3A4VFhBVWxwNEVnS2Y5SWNNQ1Y4K2lBN21XZUJWVnBiNm9K?=
 =?utf-8?B?NklGMm02Z1JRNWtRZTQyMUp2UGlnZ1VZbi9VUUt4dGpROUo1VGhqYkNTME1h?=
 =?utf-8?B?TDhkN3Z0OXJhMHQzZDhxWXhld3UwcWlTeWFiNXR3Tkt1VHNwc0h0V0kvMDIw?=
 =?utf-8?B?WVQreHNlRkZkbFhWWE1vQ0dUZC92eE5XWHBCdFRwbjU5UlczaDNJNEdTYnBJ?=
 =?utf-8?B?MHdISDdFM2JsUlYwVnBTWWlHMVU0RmRoaVF5YkY2QnBObXlxcm9Ua3hFb21E?=
 =?utf-8?B?Q0NXZ01aRkl2cDNoOEQwbzgydUg1ck4wVWo3cjR5NFVubDFUUGpZaWxRZi9T?=
 =?utf-8?B?L3BPak0xcm8wWTNjUDBORE5nNW5HKzNBU0NNZFhXYmRxS3hnUjFqaWoyd1RQ?=
 =?utf-8?B?aGp1eUpDTzZRQTgwQzJCVTI5bFpDRE1wcVl6QXhRS2wvNXFRV09ZM25xZEN4?=
 =?utf-8?B?TnN6emVhdWY5NnRuZk5Kc2JIM3hWdWhiRXZIMEpyOW1IRUYyVEpMVGErNkRT?=
 =?utf-8?B?M2ZMT0ZzTENBKzhYRS9BbEZmbnNoZjhXbWJpcitYTElXNXFySWtZblJuUmVP?=
 =?utf-8?B?RmowQ0hDaEVXNjYwdU1FNWNjTThyODduWjNYZWpOOXNxUjFKeUFmbDhKRUdO?=
 =?utf-8?B?TFJVcm9EWWQvYkZoL1hhelVGdXNwVUpVdk93MEFwZTJ6NjVOMEo4M1kwMDkr?=
 =?utf-8?B?Q1hrN2ZqNjVxTi9UVXBKZHdjZ2xUKzkyTGpWcTNlTm1UU2hPM2RJMjZXcG95?=
 =?utf-8?B?M3d1WXozRUplZ1JULzRObGJsdEVwSXdKOGNNMmF5dkNDaDlJWWVmM0EvQ3I2?=
 =?utf-8?B?NkFTaVhYTnFRTkZhdlFZOVhDekVNV1RvanhPY1lNM0owV3JXSzQrVXhlSVIx?=
 =?utf-8?B?c0U4Mi9jU3hrVnNDSkQwbnlQbDJkK2NadnpSYndIdDFZT3hWWmw5VmNJaDhH?=
 =?utf-8?B?bHFsN1cydWRRbnVMQmRkTmxsZURJVEk3TGZIWndMKzJjS3NqSVdVcW84Z2lw?=
 =?utf-8?B?TUhOMmFVSVRXTENTcGlmb2VWUWxEWUo0S3BMMktldjlwY2JmWVlEMGFMRGZU?=
 =?utf-8?B?VXpNM1ZnWjhmZUYvR2pzMU5sZ29KR0hxSTlxNVpWUGtsS1BoeHpyUT09?=
Content-ID: <BCB3431D2EA08D43B081A836531B2D09@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR19MB3769.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b908389a-c869-469f-1bbb-08da374f47b9
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 May 2022 15:18:07.1135 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: dL5d4v5XuamOuJFUcvgloRF03NYCiEEOKgXIu0H4GHb3/rucKPyXRXw2bH57+tXv4Dz7jhf26+7+aZSBiUgO6g==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR1901MB2189
Subject: Re: [lustre-devel] [PATCH v2] fscrypt: allow alternative bounce
 buffers
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
From: Sebastien Buisson via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Sebastien Buisson <sbuisson@ddn.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

DQo+IExlIDE0IG1haSAyMDIyIMOgIDIxOjAzLCBKYW1lcyBTaW1tb25zIDxqc2ltbW9uc0BpbmZy
YWRlYWQub3JnPiBhIMOpY3JpdCA6DQo+IA0KPiBDdXJyZW50bHkgZnNjcnlwdCBvZmZlcnMgdHdv
IG9wdGlvbnMuIE9uZSBvcHRpb24gaXMgdG8gdXNlIHRoZQ0KPiBpbnRlcm5hbCBib3VuY2UgYnVm
ZmVyIGFsbG9jYXRlZCBvciBwZXJmb3JtIGlubGluZSBlbmNycHl0aW9uLg0KPiBBZGQgdGhlIG9w
dGlvbiB0byB1c2UgYW4gZXh0ZXJuYWwgYm91bmNlIGJ1ZmZlci4gVGhpcyBjaGFuZ2UgY2FuDQo+
IGJlIHVzZWQgdXNlZnVsIGZvciBleGFtcGxlIGZvciBhIG5ldHdvcmsgZmlsZSBzeXN0ZW1zIHdo
aWNoIGNhbg0KPiBwYXNzIGluIGEgcGFnZSBmcm9tIHRoZSBwYWdlIGNhY2hlIGFuZCBwbGFjZSB0
aGUgZW5jcnlwdGVkIGRhdGENCj4gaW50byBhIHBhZ2UgZm9yIGEgbmV0d29yayBwYWNrZXQgdG8g
YmUgc2VudC4gQW5vdGhlciBwb3RlbnRpYWwNCj4gdXNlIGlzIHRoZSB1c2Ugb2YgR1BVIHBhZ2Vz
IHdpdGggUkRNQSBiZWluZyB0aGUgZmluYWwgZGVzdGluYXRpb24NCj4gZm9yIHRoZSBlbmNyeXB0
ZWQgZGF0YS4gTGFzdGx5IGluIHBlcmZvcm1hbmNlIG1lYXN1cmVtZW50cyB0aGUNCj4gYWxsb2Nh
dGlvbiBvZiB0aGUgYm91bmNlIHBhZ2UgaW5jdXJlcyBhIGhlYXZ5IGNvc3QuIFVzaW5nIGEgcGFn
ZQ0KPiBmcm9tIGEgcHJlZGVmaW5lZCBtZW1vcnkgcG9vbCBjYW4gbG93ZXIgdGhlIGNhc2UuIFdl
IGNhbiByZXBsYWNlDQo+IHRoZSBvbmUgb2ZmIGNhc2Ugb2YgaW5wbGFjZSBlbmNyeXB0aW9uIHdp
dGggdGhlIG5ldyBnZW5lcmFsDQo+IGZ1bmN0aW9ucy4NCj4gDQo+IFNpZ25lZC1PZmYtQnk6IEph
bWVzIFNpbW1vbnMgPGpzaW1tb25zQGluZnJhZGVhZC5vcmc+DQo+IC0tLQ0KPiBmcy9jcnlwdG8v
Y3J5cHRvLmMgICAgICB8IDM0ICsrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0NCj4g
ZnMvdWJpZnMvY3J5cHRvLmMgICAgICAgfCAxMiArKysrKysrLS0tLS0NCj4gaW5jbHVkZS9saW51
eC9mc2NyeXB0LmggfCAzMSArKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tDQo+IDMgZmls
ZXMgY2hhbmdlZCwgNDIgaW5zZXJ0aW9ucygrKSwgMzUgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZm
IC0tZ2l0IGEvZnMvdWJpZnMvY3J5cHRvLmMgYi9mcy91Ymlmcy9jcnlwdG8uYw0KPiBpbmRleCBj
NTdiNDZhMzUyZDguLjgyMzNkYzJlNDk2OSAxMDA2NDQNCj4gLS0tIGEvZnMvdWJpZnMvY3J5cHRv
LmMNCj4gKysrIGIvZnMvdWJpZnMvY3J5cHRvLmMNCj4gQEAgLTM5LDggKzM5LDkgQEAgaW50IHVi
aWZzX2VuY3J5cHQoY29uc3Qgc3RydWN0IGlub2RlICppbm9kZSwgc3RydWN0IHViaWZzX2RhdGFf
bm9kZSAqZG4sDQo+IAlpZiAocGFkX2xlbiAhPSBpbl9sZW4pDQo+IAkJbWVtc2V0KHAgKyBpbl9s
ZW4sIDAsIHBhZF9sZW4gLSBpbl9sZW4pOw0KPiANCj4gLQllcnIgPSBmc2NyeXB0X2VuY3J5cHRf
YmxvY2tfaW5wbGFjZShpbm9kZSwgdmlydF90b19wYWdlKHApLCBwYWRfbGVuLA0KPiAtCQkJCQkg
ICAgb2Zmc2V0X2luX3BhZ2UocCksIGJsb2NrLCBHRlBfTk9GUyk7DQo+ICsJLyogRW5jcnlwdCBp
bnBsYWNlICovDQo+ICsJZXJyID0gZnNjcnlwdF9lbmNyeXB0X3BhZ2UoaW5vZGUsIHZpcnRfdG9f
cGFnZShwKSwgdmlydF90b19wYWdlKHApLA0KPiArCQkJCSAgIHBhZF9sZW4sIG9mZnNldF9pbl9w
YWdlKHApLCBibG9jaywgR0ZQX05PRlMpOw0KPiAJaWYgKGVycikgew0KPiAJCXViaWZzX2Vycihj
LCAiZnNjcnlwdF9lbmNyeXB0X2Jsb2NrX2lucGxhY2UoKSBmYWlsZWQ6ICVkIiwgZXJyKTsNCg0K
VGhlIGVycm9yIG1lc3NhZ2Ugc2hvdWxkIGJlIGNoYW5nZWQgYXMgd2VsbC4NCg0KPiAJCXJldHVy
biBlcnI7DQo+IEBAIC02NCw5ICs2NSwxMCBAQCBpbnQgdWJpZnNfZGVjcnlwdChjb25zdCBzdHJ1
Y3QgaW5vZGUgKmlub2RlLCBzdHJ1Y3QgdWJpZnNfZGF0YV9ub2RlICpkbiwNCj4gCX0NCj4gDQo+
IAl1Ymlmc19hc3NlcnQoYywgZGxlbiA8PSBVQklGU19CTE9DS19TSVpFKTsNCj4gLQllcnIgPSBm
c2NyeXB0X2RlY3J5cHRfYmxvY2tfaW5wbGFjZShpbm9kZSwgdmlydF90b19wYWdlKCZkbi0+ZGF0
YSksDQo+IC0JCQkJCSAgICBkbGVuLCBvZmZzZXRfaW5fcGFnZSgmZG4tPmRhdGEpLA0KPiAtCQkJ
CQkgICAgYmxvY2spOw0KPiArCS8qIERlY3J5cHQgaW5wbGFjZSAqLw0KPiArCWVyciA9IGZzY3J5
cHRfZGVjcnlwdF9wYWdlKGlub2RlLCB2aXJ0X3RvX3BhZ2UoJmRuLT5kYXRhKSwNCj4gKwkJCQkg
ICB2aXJ0X3RvX3BhZ2UoJmRuLT5kYXRhKSwgZGxlbiwNCj4gKwkJCQkgICBvZmZzZXRfaW5fcGFn
ZSgmZG4tPmRhdGEpLCBibG9jaywgR0ZQX05PRlMpOw0KPiAJaWYgKGVycikgew0KPiAJCXViaWZz
X2VycihjLCAiZnNjcnlwdF9kZWNyeXB0X2Jsb2NrX2lucGxhY2UoKSBmYWlsZWQ6ICVkIiwgZXJy
KTsNCg0KVGhlIGVycm9yIG1lc3NhZ2Ugc2hvdWxkIGJlIGNoYW5nZWQgYXMgd2VsbC4NCg0KPiAJ
CXJldHVybiBlcnI7DQoNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3Ry
ZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1s
dXN0cmUub3JnCg==
