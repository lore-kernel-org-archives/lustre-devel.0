Return-Path: <SRS0=t8yN=HT=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21D4EC433E0
	for <lustre-devel@archiver.kernel.org>; Wed, 17 Feb 2021 09:00:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8D39C64DF0
	for <lustre-devel@archiver.kernel.org>; Wed, 17 Feb 2021 09:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D39C64DF0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7D0F221F2DF;
	Wed, 17 Feb 2021 01:00:34 -0800 (PST)
Received: from NAM12-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam12on2078.outbound.protection.outlook.com [40.107.243.78])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5258721F2A4
 for <lustre-devel@lists.lustre.org>; Wed, 17 Feb 2021 01:00:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=kRtSfjgMgadKu40WEKCKylYdSuGgdNVcKJq8DbGj2r22BRmn+rbzyxy7ZBz2Mf62/KPTGdes5ew0WSWa86phOy4TvhV7ZnFexWlixrH8DABXWLyyMnzRuL2V5of5EU6snWskMBNE/uVo9121jL1s731FTI9NpcAl1CaCIrvpzFWpCPUCknHlI53D3dHgePHIvgBg3zX9Kmxx6z81BRoISubTn3PXXMESOZuVhRloaOqIQIoPsYj3P+6pc6ZL7MhV7UdBm7tO094aLjqqMqpfUvTH5YzlK4IIdDkF6NbJGlcr/pqlI01t8QxXJNSOh8pS6TVoZzTN58/rAOVsEDXzBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rmsboS8E4FnGQ7oBhrlkuIly+X8AGXmnuFJ5qhIaJWc=;
 b=ntk4ASYtzpl+tbKOtM1qxk5+5Kpp9JmPclGByPqust3K7Qjx5iH+QMMQybGWeQq2rY1yV5YKTLL5ptmVNJcA+uTKByBMAlClcBrugF7x2GUDRDGo0p7FKoEuLBVg3XSc/21iBg33GnqqiblWQCqSjrJ9TKpfgLb0es2zUg6+J3GmdjMyZmrMBGnS7nlamrq5ZoOoE8KFOxV6Z/17de+uJmP8QsQs27UDzAqtFnfa0isC7NrGPbQhEj0eBG5lHpwZMxaihcXTQNLkYQ/DYqyNwoCuACNVomZHStvpkMfbxIiM4T+Q9Djo8GsieXEeViietAq2ZVwbTzpCQJ9DU9POfQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rmsboS8E4FnGQ7oBhrlkuIly+X8AGXmnuFJ5qhIaJWc=;
 b=SBrdtB2veB6vRnEb74bxrRbArvIu44/sWXR7ZE7N/XgE+4fNg1aNDytaDXlUDV7UuMZlUYDrI6JbzPuU6iSP8/5MGmi/XAFC9VPk+RXl4IWb6iNcmGJFbB2YtkVy5svSjvPlEbFNmSIyRZ2p4ZuqHUOovPHlKQiVbqlM1og1CGw=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by BL0PR1901MB4692.namprd19.prod.outlook.com (2603:10b6:207:39::12)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3825.19; Wed, 17 Feb
 2021 09:00:30 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3846.039; Wed, 17 Feb 2021
 09:00:29 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Thread-Topic: [lustre-devel] Rationale behind pre-create objects
Thread-Index: AQHXBKvG/0W7KmSG/0qVfdQMg9X+W6pcDVZ9
Date: Wed, 17 Feb 2021 09:00:29 +0000
Message-ID: <014C0DC0-67B8-4B5C-8D86-79F021FF88D2@whamcloud.com>
References: <CABnqofwzxyZW5DGGn5sXS-=KG6K40MJVTUBrbA6CVOR=K1eT=Q@mail.gmail.com>
In-Reply-To: <CABnqofwzxyZW5DGGn5sXS-=KG6K40MJVTUBrbA6CVOR=K1eT=Q@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-CA
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: lists.lustre.org; dkim=none (message not signed)
 header.d=none;lists.lustre.org; dmarc=none action=none
 header.from=whamcloud.com;
x-originating-ip: [2605:8d80:425:83dc:ad0b:8d21:5063:6efd]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 370eaf08-aa07-4ea9-b372-08d8d32279c5
x-ms-traffictypediagnostic: BL0PR1901MB4692:
x-microsoft-antispam-prvs: <BL0PR1901MB46926926F77D863FC3809883A7869@BL0PR1901MB4692.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: Vmwf1IMIF3D5QYjZ7JLRb+T+6G7NEP5f+NeJNkdTE2n//hT7in23PjuuEHNC8/SFO/+bx9iicY0aqp7BKckE0kTGvcr42l0GDPIuJtdtfodzVM3HkobaunhJUL/EbJFpdxAAbGr0fZvfPaT9A5rCcJ3le+SotpDeCfVRbHDtWqr60VfXvZI4J8AWQM6r7oc9IXrr4MGQxmZqajgr4EJfDV8+YfVUHYCIs8EmmKwzPAMRFqM/Qcc4g/w4RUd3NsDxYOqhmq5aVubR/JJZyKfmImWftnVzGFC0D6w5+OqKI3qgoAixHvMCGULpZO6c+Sz5CTrKpzyqKclk06CUCEHlVD1DOuUDVqzycmSAFiktOOyHzN/sVP/3TmjdyQHUSOYx0Y6zp1Hp9OIW9er7NMMR1ot3WNdKh5QZUNvolbVqtSnoqmRTAkyhIlPQvYeua4ieov1TzGYGUTecgcA0d8Rcip7qOrcp6JjzUXNqqJvqoNj+slElr6z7XYltmE86mEFELEwYx+SMu8yRGXDhHf8kgOYI9PZIU6F2cVuZaDmkZYJH/iY0g+Oe4l+9znZdGPSbPAZJZaN5U+cmQNixfAmo4s6xiUg2+4vM5Ep1XdI/i4jpFMCzbhdA78cX8KCKI3rCi5GJp0bya+b0M0dMctD5KIYgBqvc+6Jg3rlKu/LTzcaYzY+Ns0HutH8xiNcnrtGa
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(376002)(346002)(366004)(396003)(39840400004)(136003)(4326008)(316002)(66476007)(66446008)(71200400001)(53546011)(2906002)(2616005)(66946007)(8676002)(64756008)(36756003)(6506007)(8936002)(5660300002)(478600001)(86362001)(91956017)(186003)(6916009)(6512007)(66556008)(76116006)(33656002)(6486002)(966005)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?utf-8?B?dDR1ZE11NU81Y2ZUSkp6WGRBeWtLdUFrU0ZBVHNJeTJqck5VNkxNTXJNSDFw?=
 =?utf-8?B?MUU3SnRXTkxyRDVFRy84ZVc5V3RYNUtZTERDQ2s4Z1B0YmJDbDRJdWFhU1Uz?=
 =?utf-8?B?UE1wZGZWUHQyK0d4VlVuei9VZ2U0WkpYRjU1bDZEalNxcG9NRGxJVUROb25C?=
 =?utf-8?B?M29uYjhjUDlhMFJzU2xwVE8ycmIrTjBRcTY3aElKK21POFU0b2RLMTR5TEpB?=
 =?utf-8?B?OCtzSm4rYjkwbWM3dGw2M1h1WjlzQkt2WDZvejhYMHg1WmN2QktNemp1MG83?=
 =?utf-8?B?YWtoMmVCUlp1K0FyTTlURGV5TlUzTjl0VElIQkg5a3NTZkZmSGZ2NVNDWlFY?=
 =?utf-8?B?Yk1SZWZ0OHdxV2F6dEpoVXFuVnFjWUNYZUNGeU1KdnNjdUZ0N0t6VjNMa2Jq?=
 =?utf-8?B?UHZwODczaU9BQ2JPZ3VKeVM0cXA1OCtBUVd2YlRLWTIzd09IdTdIeDNoQlN1?=
 =?utf-8?B?Sldrdm05dTZyM3RiVjBZNlpZN0ZoYlFuTjNpOVZhOTh1dTVzMm53N0FiY09q?=
 =?utf-8?B?Wjk3b1dvbW85ZFJ3b1Vkc0x1Tk9YZUgzVEFGVTcxdVZVQ0wxcGdsdFpPdTZr?=
 =?utf-8?B?MXpMcWVtUjUySWpXd2tSSDYvWnhjbTUrS1F4c2Zkem1TeTQ4Q2sycnBNc0dv?=
 =?utf-8?B?d1IvVE1RNUhqUEFuTy92aUZ4WTBWWDVFRU5qYnUvMWllejlyTHdnWnN6cy9Y?=
 =?utf-8?B?bzFDKzh5d29vL3lDZFVRQVcrYWI4YktrWWlPV0RPZlpPUzk1RmQzSjFac1pl?=
 =?utf-8?B?RTN6bVFBTTFRTW9ZSzRBdWIxaU1ZRzg1aU9LSVhLSk1uRnltREFvVXBwMk5R?=
 =?utf-8?B?WTNiOGdSVmtJZHZSOXhVV01qZjFnajNJYXBuSXVTajE1Y2VLYkpFNUNVR0tX?=
 =?utf-8?B?NjlCSHRaOTNPbjFqSTRRY0FmOE1hcm0zaDNtZWtDUmY2SSttUk81RC85c2Qx?=
 =?utf-8?B?OVJRamdWMHFaaDBHZkRqMGx0TThmK0RRVVgrdVNhVFpOZWhPNkltSGZCeGNm?=
 =?utf-8?B?NkhYT2pyM2Ewb3RmQU9sUERPOHdDNnd6RmVsRDFqYlJubHI0TzJuUmE4dzVs?=
 =?utf-8?B?TGt5emt0ZXdxM0FBRXVGYmVmWnNNQkFiV0RQRm53emNjS3hSeXV3VFlrLzVz?=
 =?utf-8?B?UkhuMUlLeHp6YnR3RFQrN2VMMjYwb1BxTHB0cE16TFJqYzNZdkNWVXQ5bWVh?=
 =?utf-8?B?MHpWb2hCYW1qWHRqZ3kzMFEyUjFPTmxla1YyY2lxd0Y2SFg0TkllV0JkOEJN?=
 =?utf-8?B?Y2FHa3NZQzRMbHByOGxHazJRUis2dEFFRzJxS1lLR0s1TnZMLzQzZWw4SmFn?=
 =?utf-8?B?QXViRGlRQzF3dklCbDZ2NnM1SVZFd29pdEljaEtIUzFZcFdPRmhubytDZUZz?=
 =?utf-8?B?MDJDVjVxMEhIUUowOTVCanE0Z0ZUKzFBSFU4bTMwNS9JSk9XSGZ1cm9MdE5Q?=
 =?utf-8?B?Tm5adzlkc2x0Szc1ZlJZcnZNL2ZIU2EvWmZJWGw2VEhaaWZhYnhSUU1wNmFH?=
 =?utf-8?B?cDhSdXpDTXdINU12MlI0Um5RayswbFljTkVEZ0pER2hzY3RwTFNxQkVrSkQ4?=
 =?utf-8?B?RUVRYW03R0hSUlpqNk1kWjgzWUM4NVhTQmRmeGNFcVh0aDJuOGRBRytFMitI?=
 =?utf-8?B?MjNkMW9TcmhITVZqNkxTV2F2a2l3S3ZhNWw0TkJwc0FFK01kTHgxOWp1dW1r?=
 =?utf-8?B?WFhjVk9VT3hxSUJIckkwQldaaVFGYVhrQ3lCMCtLa1h3QlNDYkVldUZCa3hW?=
 =?utf-8?B?WVl2YXlVbHd2by9rSTUwQ0lxbGhPRDROUWxXSjZXZk9UQ05YblNDdU1WOVhz?=
 =?utf-8?B?WnFIeGtwSlkwcFk1UEd4d0g3YmNYVXN1N3ZQeTVtS3NKZjJqdGlDMEdPVHQv?=
 =?utf-8?Q?hfjsd+xbQqG0R?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 370eaf08-aa07-4ea9-b372-08d8d32279c5
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Feb 2021 09:00:29.6524 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: taNL3zExDRIvEI25dDKnHw1NP4u7nLi9USyY3lctSU79AF0c8qppB1KPKLeAttZT
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL0PR1901MB4692
Subject: Re: [lustre-devel] Rationale behind pre-create objects
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

WWVzLCBwcmVjcmVhdGluZyBPU1Qgb2JqZWN0cyBhdm9pZHMgbGF0ZW5jeSwgYnV0IGl0IGlzIGFz
IG11Y2ggZm9yIG5ldHdvcmsgbGF0ZW5jeSBhcyBpdCBpcyBmb3IgZGlzayBsYXRlbmN5LiAgRm9y
IGxkaXNrZnMgdGhlIGlub2RlIGFsbG9jYXRpb24gaXMgaW4gbWVtb3J5IGFuZCBqb3VybmFsZWQs
IHNvIGRvZXMgbm90IGRlcGVuZCBvbiBzZWVrIGxhdGVuY3kgYXQgYWxsLiANCg0KQW5vdGhlciBy
ZWFzb24gdG8gcHJlY3JlYXRlIG9iamVjdHMgaXMgdG8gZW5zdXJlIHRoYXQgdGhlIE9TVCBkb2Vz
IG5vdCBydW4gb3V0IG9mIGlub2RlcyBmb3IgZmlsZXMgdGhhdCB0aGUgTURTIGFscmVhZHkgY3Jl
YXRlZC4gIEZvciBsZGlza2ZzIHRoaXMgaXMgYW4gaXNzdWUgYmVjYXVzZSB0aGUgbnVtYmVyIG9m
IE9TVCBpbm9kZXMgaXMgZml4ZWQgYXQgZm9ybWF0IHRpbWUuIEZvciBaRlMgaXQgaXMgYW4gaXNz
dWUgYmVjYXVzZSByZWd1bGFyIGZpbGUgSU8gY2FuIGNvbnN1bWUgYWxsIHRoZSBzcGFjZSBhbmQg
cHJldmVudCBpbm9kZSBhbGxvY2F0aW9uLiANCg0KRmluYWxseSwgb2JqZWN0IHByZWNyZWF0aW9u
IHNpbXBsaWZpZXMgcmVjb3ZlcnkgYmVjYXVzZSB3ZSBoYXZlIGEgZ29vZCBpZGVhIHdoZXRoZXIv
d2hpY2ggb2JqZWN0cyBzaG91bGQgZXhpc3Qgb3Igbm90IGFmdGVyIGEgc2VydmVyIHJlc3RhcnQu
IA0KDQpDaGVlcnMsIEFuZHJlYXMNCg0KPiBPbiBGZWIgMTYsIDIwMjEsIGF0IDE0OjM2LCBTdWRo
ZWVuZHJhIFNhbXBhdGggPHN1ZGhlZW5kcmEuc2FtcGF0aEBnbWFpbC5jb20+IHdyb3RlOg0KPiAN
Cj4g77u/DQo+IEhpLA0KPiANCj4gSSBhbSBjdXJpb3VzIHRvIGZpbmQgdGhlIHJlYXNvbiBiZWhp
bmQgJ3ByZS1jcmVhdGUgb2JqZWN0JyBmb3IgYSBuZXcgZmlsZS9kaXJlY3RvcnkgY3JlYXRpb24u
DQo+IA0KPiBNeSB3aWxkIGd1ZXNzIGlzIHRoYXQgd2hlbiB5b3UgYXJlIHVzaW5nICdzcGlubmlu
ZyBkaXNrcycgYXMgdGhlIGJhY2tlbmQgc3RvcmFnZSwgcHJlLWNyZWF0aW5nIG9iamVjdHMgYmVm
b3JlIHRoZSBhY3R1YWwgZGF0YSBjb21lcyB3aWxsIG1pbmltaXplIGxhdGVuY3kgb3ZlcmhlYWQg
b2YgZGlzayBzZWVrLiAgDQo+IA0KPiBJZiBteSB3aWxkIGd1ZXNzIGlzIGNvcnJlY3QsIG15IGZv
bGxvdy11cCBxdWVzdGlvbiBpczogIA0KPiANCj4gSWYgSSBhbSB1c2luZyBTU0QgYmFzZWQgZGV2
aWNlcyBhcyBiYWNrZW5kIHN0b3JhZ2UsIGRvIHdlIG5lZWQgdGhpcyBwcmUtY3JlYXRlIGFueW1v
cmUgZ2l2ZW4gdGhhdCBTU0QgYXJlIHN1cGVyLWZhc3QgY29tcGFyZWQgdG8gc3Bpbm5pbmcgbWVk
aWEgPw0KPiANCj4gQXBwcmVjaWF0ZSBpZiBhbnlvbmUgY2FuIHByb3ZpZGUgc29tZSBpbnNpZ2h0
IGludG8gdGhpcy4NCj4gDQo+IFRoYW5rcywNCj4gDQo+IC0tIA0KPiBSZWdhcmRzDQo+IA0KPiBT
dWRoZWVuZHJhIFNhbXBhdGgNCj4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18NCj4gbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdA0KPiBsdXN0cmUtZGV2ZWxA
bGlzdHMubHVzdHJlLm9yZw0KPiBodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kv
bHVzdHJlLWRldmVsLWx1c3RyZS5vcmcNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxp
c3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3Ry
ZS1kZXZlbC1sdXN0cmUub3JnCg==
