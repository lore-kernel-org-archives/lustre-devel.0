Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 74469C43334
	for <lustre-devel@archiver.kernel.org>; Fri, 17 Jun 2022 20:49:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LPrkV5hKkz2349;
	Fri, 17 Jun 2022 13:49:22 -0700 (PDT)
Received: from NAM12-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam12on2073.outbound.protection.outlook.com [40.107.243.73])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4LPrkS2p4gz1wS8; Fri, 17 Jun 2022 13:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=OgKBKycep9FV7tT4lNTSkxLFUAqWIJzoMRe1BIxHAM4X0/s8vnE4fQSB26GHuEW2ZtA/xWPIZKcQpeEgQwdJGQCF+B/tM3WP9CMXjZ2Q+rkmd1nrsn1QykfLQFTIrmxzzZOUkgGCK5fst0Qf3qDAytPkNWV6rAGyJUiE/lxhaRrUYAgoalXAFHr5Dya0qH94o3CYyF/BeLWyElqRjIWjT8eOixminaZOZXenY9A506b0UDZ8MYeeFwwb0qOAIlrzTFRlylyfby/KDSezmrYmASROnUG4Y323Eb/WceHPuz7GI3hp3WH8SwhS45xAfv617Z6LTNWvigWbRvJD6qRSUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=dbHBbec+uH0x5Tq4OjK1w+HgeVwkTYl800Zt7bwqYrY=;
 b=m65oYmFkdFPScmsEw22pO/0VMq/244CIhlOiAE8z+V/TTqqLpnqZjWmgFuVe4ESnFHwaplm2ZgifK02tpiFN88IbOpsJ9hyqu9wDiwoD8MUdTcq9vQFdnhlrl1/c/DxIOfSxu5l89VhVt2BeluxSH98hBs7twWPgE2t4VIG8fFcb0a3YjH7vc+nzxWhF8L7xhUQQ7AMmLeJBiPCh4qM0gpqqYIGDsjLfW7kDvEKv5/22KrWcO9Vfvv1UTRXfcb3YYugVIggD5X4RmIz5d12Q8p/XICYi1keHAIO6Xng/rC/g37VvdQkLLL13ihJ2BHPEcyq8LgbBmHNBBHYct1ehmg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dbHBbec+uH0x5Tq4OjK1w+HgeVwkTYl800Zt7bwqYrY=;
 b=f2tK25Opgy1nxZu2Kk7ilJdkfnNHgVIoA9F2mexCSgY5PM17lMv+baTzhzJ1E7NNoeQkPmkYxSyqOBE5z9oONmgrfQh7x+DFAPIoc9HebOGfEX+4lnFa/cDg0e0xnkIh0m2fZJFXAqVHtFMvz1ZQC1QeirsF3gw1tipsRmzaD0c=
Received: from BL1PR19MB6034.namprd19.prod.outlook.com (2603:10b6:208:39d::12)
 by SN7PR19MB4765.namprd19.prod.outlook.com (2603:10b6:806:100::7)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5353.18; Fri, 17 Jun
 2022 20:49:16 +0000
Received: from BL1PR19MB6034.namprd19.prod.outlook.com
 ([fe80::f010:da3c:d122:b7b1]) by BL1PR19MB6034.namprd19.prod.outlook.com
 ([fe80::f010:da3c:d122:b7b1%6]) with mapi id 15.20.5353.014; Fri, 17 Jun 2022
 20:49:15 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.12.9 released
Thread-Index: AQHYgou0rs1PI2ZRLki4WIXiuDvglg==
Date: Fri, 17 Jun 2022 20:49:15 +0000
Message-ID: <531CA8A8-EDE7-491E-A7A3-854C16936A09@ddn.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.61.22050700
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c0dd0c26-f372-4779-223c-08da50a2d72c
x-ms-traffictypediagnostic: SN7PR19MB4765:EE_
x-microsoft-antispam-prvs: <SN7PR19MB476546182D754AA054FE473ADAAF9@SN7PR19MB4765.namprd19.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: rUEI7f09t5N6H0Bh/q2zmkrUUZy71TuMM3MyEXi12jM7R6UhluS9SQudUjzq3tayhn1zHT8e9gFeeGH5PWzDvKXAtRMb/j7pp28uVEc3sEvnZNprkeZAv5JYLovkD5xpjLUVXkFd1cI23Boh3UtFYGMnHbCwPe551QCaMhoObQsq7TxhIaIF7oqD6UjPdlvBY7/BYN2V3uEXVk2EhKfa3P7mIYZwxmRwcGSe7M804+6FHMKvWboMyDZEU2b8tdo1cO1oXd/T2iXtTyNbH7deHBbMrg9++xSok+ItUqek1yvhzC9gbZO5E14s4toJ3/kxBQiPKKMvueZPSvEK3PcCBoIQkN7PKMXHRqVe7zkYUSh4fRneYbtbPvx2X1cKjuEgvCkrEMdPDN8bP1xr9G8hOvfpnv91j1rjUA4qlWAuM5ZTn7/vWsRf9kq+JC7YWEhDZrMF7GgRu9hrX6dEQE2XdW1eQL//x2Nh0lD9s/9wjsD5EfeXQa/uX4V1jtAYW6wWkys4ckFL4ylD5STbPU80YjydnkMVtOqC8BsqufPTBE4vy2hBvs1JsDkcYDKk27N/MPpuXxf2UyhzOHgp7gufy/Yp2vMD7WJ2FzcxR7TxE2FiOMlYaDWdWiMxcXFwL06+qndXkmP6XEzDH1lMUf6jCtkK6oHZ9STYBb+wtEdr41I0cQ2TuB6GEppyUoZFYXS6XQEBjKggMMWWlVF6lV1UD3jbcktYhYY3BHeTwEXhxhwYpPFg3VB6wStF5h0WUXUEzOuIaq1G/zXmaUxrSCkn0ic1yGT73LfP6fAIPJl6q58alB/c35M2bbjWItyBSQ3QyeayzRO5gIro1jwvfYxhw0TvPtdEgegfw9HXicgo18I=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:BL1PR19MB6034.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230016)(4636009)(366004)(8676002)(83380400001)(7116003)(86362001)(64756008)(6486002)(66476007)(6506007)(66556008)(71200400001)(5660300002)(76116006)(122000001)(186003)(498600001)(110136005)(38070700005)(66446008)(66946007)(166002)(316002)(91956017)(9686003)(4744005)(33656002)(36756003)(6512007)(38100700002)(2906002)(8936002)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 2
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?SFN2TURLOGs1SWwyVE1aZ24vQmtyaWdqZ0hFN25VNVllcW1UeWNoSUVkeDVP?=
 =?utf-8?B?YTVUT3BHbUZaSmJXbjFLWnhOVXA3SW8vTE5LVzh5dVpKa3oxRjY3SXVyc2FE?=
 =?utf-8?B?N1E4dE9rZ0cxQXYwaFI4Q2NWTi9nbzRZaW1IU29BTmdaY2h0Vy9SYndneWdk?=
 =?utf-8?B?VTJtZEREZWZSYktZQW5KdjNHcDlEQ3ZzaGk0bUpNeGZ4cHRzWUc2SlZlcm0y?=
 =?utf-8?B?bjBYZmtIQ2JaUkV4VXhCVE5weHZWMW1NZDQyaXlQekRrejhQbUFOeDI2Y3pJ?=
 =?utf-8?B?WlZZSHJROFBIRUVKQ0NjNUdNOVQ1bU1DUHhiSjhhdFBDOGRRbU5XMFd3TjNl?=
 =?utf-8?B?VzRsc0g1MTJQZlFsQVh0cGM0TUlzVDZpOUNEUTRHdmVNa3F6S1dDOWU1SWlN?=
 =?utf-8?B?YkdaMjR6eHFCbCswSkpxNllkNDZwazhPVHpTaEVwbW9HTGlRRFlrN0o3K3oy?=
 =?utf-8?B?eGw4Z0NWNWZrSVJJVUpqVHNMVEgvQk9lWUNzZHBNRXNKNThxeDFIa0ZTeFgr?=
 =?utf-8?B?V09XOEtld0hGdkhaY1lUTEdGYzNCTkFvbjArQ2RmMjVVZnJwTHBRVjU5N1NS?=
 =?utf-8?B?TzNtMWg1ZE9sbzB1am9jM0RpaEd4WWRXdkc5YTVCUkl0YUlhT1pRclI5cm51?=
 =?utf-8?B?SkxoMlJOMlk5Qzl5cm5GeVZHNnlubklQNll5MTNuZDRRdmxWTUZteTN4MHEw?=
 =?utf-8?B?R2RzYmNRdjRWK3NYd2l3NlA1ZjgxTXI1eHQxYWV2eHBDRFBPNGxiVUw4MjB2?=
 =?utf-8?B?RzFkSGsrekQ5NWNnQXdpS1VSa1RWL2NCRXVmVE9XY2lLcGNka0JzdjRwU1Ey?=
 =?utf-8?B?TzA5NFNtWWI1OWl6RXRxcTduSDlycDdUcmFUalFGRzdXY1hGWFVIZllMQzNj?=
 =?utf-8?B?cnF2VVgzWjVwbUlpeG52YmlnU2xVdWFBOGJFRG52VzFYMyswY2tmOE5udFpt?=
 =?utf-8?B?a2RRWVc0eitNNWI5MmJOL1FDSGt4azF3Z0JHQXRWZTdwazQyaFh5ci9XaWow?=
 =?utf-8?B?aCtFOU9rVVVyWXQrNmx4RHhUa21ZK3BnM1ZKRmFqT3pxV285YmdvRU9YOFJD?=
 =?utf-8?B?cWlRQnpJcTFDNW5GS0duZ3FLOHp5Q1ZxV0lmQStOcm1mYVRzalpCWTJ0VFE3?=
 =?utf-8?B?N2p2MGNRVmJlUGQ1THJ0VSsydWlrY1RGZEgrN1RQWnVyaGE4U21FRTVTem85?=
 =?utf-8?B?eTFNRlRVbW91ZmlqMDlQNlhySC9ucitycEZiUXpaamdsN3JYeDJqODQ1MmR3?=
 =?utf-8?B?bjgzUlhoTEwvMnUwa1JMcnVndW9UaTBRUzRsR0ptY3NWWFNFZlh3b0FaL250?=
 =?utf-8?B?NWR2cEFBd1VFSEpyZFQxM1N1aE1CRE1CUVV5dGFmVlp2c3hXRU8rRUtrQUZ2?=
 =?utf-8?B?S054ZEhVa29XeUl5ZXNuckRsb0FYY2kzMlI5aDZ4ZHFrckhvbWtBWE5pYXp1?=
 =?utf-8?B?TzFLT1lMV284SGUrd3JlUTN1dkYxUHlFZDBHWnliR011bW5NU1dXTmY5RHVG?=
 =?utf-8?B?eDZNWHlLZzFpeXUyYzlJZUpBMDhscXo2cm9iSkdrWklpbWpyRHBlam9LcDYv?=
 =?utf-8?B?Qk5pTmtHQjFCZVJydU1xbEZqZ1hkWmk0QmVCS3hoNGYveUVTMjVwNU1LQzky?=
 =?utf-8?B?OHlDZ2RZSUhWRFFLWTg1V1I4ZDdxY1o0aXlucEI0NmQvT0RFdHNvLy9FdTFn?=
 =?utf-8?B?dHcxY09CeWExNGVJQXBqeHVEOUw3R1M1RFoydEU4eW9icndVNkpQRzBINHRC?=
 =?utf-8?B?NmJxbmU1UnZTQ2diYlJEOVQ5aU02SnN2TStwUjcycWhJZ0VCK2hEUEI2dGhu?=
 =?utf-8?B?K2NzbjYyUkVrZlhGU2ovV21CZXAvc0JmbnZvSHFhQVdsS3ljdGUwTzNZd1R5?=
 =?utf-8?B?bkQzQVRCaHN6U1c1T2NMWjMxdVZSWi9TbTlqMUhCMEdqZC9zUVhGNHY4TDBy?=
 =?utf-8?B?ZS9OVHhwNW9odlZjU1NwN05LVWdsOWppZElubDNGZDlhTnhjVTRnMUJISFor?=
 =?utf-8?B?eVBFbEZSM2MrWGlsN2Q5b2VjblRycjNOUFZtMW96UFYzNHlEZkgycEVPVDlo?=
 =?utf-8?B?OUMrOTlURm9oVzF5bzhGbjc5RkRFbVhaYnovajVIMjJtR2NPcDdyYzExY3RN?=
 =?utf-8?B?UHlTVjFVRVNHa1ZEbWFuVjhKM3BQL3hjTU9tV201QXRFWGVEZkhEeXFRQjNQ?=
 =?utf-8?B?VjVqOEV6K2dZenlSZmp5NDU1Z29vY0xhUGpLVFpjcXpXK0IvWG0rdzNmYm0v?=
 =?utf-8?B?WDBsUkd0djRpbDhhakVOakVyUkhpRFBLKzEzMzJqdlQzdkRFUi85b1dXOGVj?=
 =?utf-8?B?SjJTK0VPV1Y2SzJlUC95YklvU2xDWkFEVTB3dWxxcFdJODZNRXFVY2F4SnhH?=
 =?utf-8?Q?cRkDZBbv8RgtJ6ACZolkTr7ynekxsBhejT3D+f9av4+fQ?=
x-ms-exchange-antispam-messagedata-1: AI9mqIkPhulZOA==
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: BL1PR19MB6034.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c0dd0c26-f372-4779-223c-08da50a2d72c
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2022 20:49:15.0639 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: zPQ/Gd4eMDGpkH1vcqqS2ymtS3WiSdCl757J1+ggWlWP+ecpWxImiPwkXKxg3rBm
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN7PR19MB4765
Subject: [lustre-devel] Lustre 2.12.9 released
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
From: Peter Jones via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Peter Jones <pjones@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============1560775115363898835=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1560775115363898835==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_531CA8A8EDE7491EA7A3854C16936A09ddncom_"

--_000_531CA8A8EDE7491EA7A3854C16936A09ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTIuOSBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkLjxodHRw
czovL2Rvd25sb2Fkcy53aGFtY2xvdWQuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIuMTIuOS8+
IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbSBnaXQgLjxodHRwczovL2dpdC53aGFt
Y2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPTUwMGMzMTI1ZTkz
MWUxOThlZGVjYTJmOTU1NzVjMWYyZmI4YjM3OGE+DQoNCkRldGFpbHMgb2YgY2hhbmdlcyBzaW5j
ZSAyLjEyLjg8aHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTIuOF9DaGFuZ2Vsb2c+
IGNhbiBiZSBmb3VuZCBpbiB0aGUgMi4xMi45IGNoYW5nZSBsb2cuPGh0dHA6Ly93aWtpLmx1c3Ry
ZS5vcmcvTHVzdHJlXzIuMTIuOV9DaGFuZ2Vsb2c+DQoNClRoZXJlIGlzIHRoZSBmb2xsb3dpbmcg
bm90YWJsZSBlbmhhbmNlbWVudCBvdmVyIDIuMTIuODoNCg0KUkhFTCA4LjYgaXMgbm93IHN1cHBv
cnRlZCBmb3IgY2xpZW50cyAgKExVLTE1Nzk1PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jy
b3dzZS9MVS0xNTc5NT4pLg0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQgaW4gdGhlIGlz
c3VlIHRyYWNraW5nIHN5c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS8+Lg0KDQpUaGFu
a3MgdG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0
aGlzIHJlbGVhc2UuDQoNClRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgbGlrZWx5IGJlIDIuMTUu
MTsgdGhlcmUgbWF5IGJlIGEgMi4xMi4xMCByZWxlYXNlIGluIHRoZSBjb21pbmcgbW9udGhzDQoN
Cg==

--_000_531CA8A8EDE7491EA7A3854C16936A09ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <4CA567BA0846DD4EA9736FB1295EBEAF@namprd19.prod.outlook.com>
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
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OiJUaW1lcyBO
ZXcgUm9tYW4gXChCb2R5IENTXCkiOw0KCXBhbm9zZS0xOjIgMiA2IDMgNSA0IDUgMiAzIDQ7fQ0K
LyogU3R5bGUgRGVmaW5pdGlvbnMgKi8NCnAuTXNvTm9ybWFsLCBsaS5Nc29Ob3JtYWwsIGRpdi5N
c29Ob3JtYWwNCgl7bWFyZ2luOjBjbTsNCglmb250LXNpemU6MTEuMHB0Ow0KCWZvbnQtZmFtaWx5
OiJDYWxpYnJpIixzYW5zLXNlcmlmO30NCmE6bGluaywgc3Bhbi5Nc29IeXBlcmxpbmsNCgl7bXNv
LXN0eWxlLXByaW9yaXR5Ojk5Ow0KCWNvbG9yOiMwNTYzQzE7DQoJdGV4dC1kZWNvcmF0aW9uOnVu
ZGVybGluZTt9DQpzcGFuLmFwcGxlLWNvbnZlcnRlZC1zcGFjZQ0KCXttc28tc3R5bGUtbmFtZTph
cHBsZS1jb252ZXJ0ZWQtc3BhY2U7fQ0Kc3Bhbi5FbWFpbFN0eWxlMjQNCgl7bXNvLXN0eWxlLXR5
cGU6cGVyc29uYWwtcmVwbHk7DQoJZm9udC1mYW1pbHk6IkNhbGlicmkiLHNhbnMtc2VyaWY7DQoJ
Y29sb3I6d2luZG93dGV4dDsNCglmb250LXdlaWdodDpub3JtYWw7DQoJZm9udC1zdHlsZTpub3Jt
YWw7fQ0KLk1zb0NocERlZmF1bHQNCgl7bXNvLXN0eWxlLXR5cGU6ZXhwb3J0LW9ubHk7DQoJZm9u
dC1zaXplOjEwLjBwdDt9DQpAcGFnZSBXb3JkU2VjdGlvbjENCgl7c2l6ZTo2MTIuMHB0IDc5Mi4w
cHQ7DQoJbWFyZ2luOjcyLjBwdCA3Mi4wcHQgNzIuMHB0IDcyLjBwdDt9DQpkaXYuV29yZFNlY3Rp
b24xDQoJe3BhZ2U6V29yZFNlY3Rpb24xO30NCi0tPjwvc3R5bGU+DQo8L2hlYWQ+DQo8Ym9keSBs
YW5nPSJFTi1DQSIgbGluaz0iIzA1NjNDMSIgdmxpbms9IiM5NTRGNzIiIHN0eWxlPSJ3b3JkLXdy
YXA6YnJlYWstd29yZCI+DQo8ZGl2IGNsYXNzPSJXb3JkU2VjdGlvbjEiPg0KPHAgY2xhc3M9Ik1z
b05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5XZSBh
cmUgcGxlYXNlZCB0byBhbm5vdW5jZSB0aGF0IHRoZSZuYnNwOzxiPkx1c3RyZSAyLjEyLjk8c3Bh
biBjbGFzcz0iYXBwbGUtY29udmVydGVkLXNwYWNlIj4mbmJzcDs8L3NwYW4+UmVsZWFzZSZuYnNw
OzwvYj5oYXMgYmVlbiBkZWNsYXJlZCBHQSBhbmQgaXMgYXZhaWxhYmxlIGZvcg0KPC9zcGFuPjxh
IGhyZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0
cmUtMi4xMi45LyI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5k
b3dubG9hZC48L3NwYW4+PC9hPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEy
LjBwdCI+IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbQ0KPC9zcGFuPjxhIGhyZWY9
Imh0dHBzOi8vZ2l0LndoYW1jbG91ZC5jb20vP3A9ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0O2E9Y29t
bWl0O2g9NTAwYzMxMjVlOTMxZTE5OGVkZWNhMmY5NTU3NWMxZjJmYjhiMzc4YSI+PHNwYW4gbGFu
Zz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5naXQmbmJzcDsuPC9zcGFuPjwvYT48
bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJtYXJnaW4tcmlnaHQ6
MzYuMHB0Ij4mbmJzcDs8bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxl
PSJtYXJnaW4tcmlnaHQ6MzYuMHB0Ij48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6
ZToxMi4wcHQiPkRldGFpbHMgb2YgY2hhbmdlcyBzaW5jZSZuYnNwOzxhIGhyZWY9Imh0dHBzOi8v
d2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjEyLjhfQ2hhbmdlbG9nIj48c3BhbiBzdHlsZT0iY29s
b3I6d2luZG93dGV4dCI+Mi4xMi44PC9zcGFuPjwvYT4gY2FuIGJlIGZvdW5kIGluIHRoZSZuYnNw
Ozwvc3Bhbj48YSBocmVmPSJodHRwOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjEyLjlfQ2hh
bmdlbG9nIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7Y29sb3I6
d2luZG93dGV4dCI+Mi4xMi45DQogY2hhbmdlIGxvZy48L3NwYW4+PC9hPjxvOnA+PC9vOnA+PC9w
Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNp
emU6MTIuMHB0Ij4mbmJzcDs8L3NwYW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9y
bWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPlRoZXJlIGlz
IHRoZSBmb2xsb3dpbmcgbm90YWJsZSBlbmhhbmNlbWVudCBvdmVyIDIuMTIuODo8L3NwYW4+PG86
cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48Yj48c3BhbiBsYW5nPSJFTi1VUyIg
c3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7Y29sb3I6YmxhY2s7YmFja2dyb3VuZDp3aGl0ZSI+Jm5i
c3A7PC9zcGFuPjwvYj48bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxiPjxz
cGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdDtjb2xvcjpibGFjaztiYWNr
Z3JvdW5kOndoaXRlIj5SSEVMIDguNiZuYnNwOzwvc3Bhbj48L2I+PHNwYW4gbGFuZz0iRU4tVVMi
IHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2NvbG9yOmJsYWNrO2JhY2tncm91bmQ6d2hpdGUiPmlz
IG5vdyBzdXBwb3J0ZWQgZm9yIGNsaWVudHM8c3BhbiBjbGFzcz0iYXBwbGUtY29udmVydGVkLXNw
YWNlIj4mbmJzcDs8L3NwYW4+PC9zcGFuPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1z
aXplOjEyLjBwdCI+Jm5ic3A7KDwvc3Bhbj48YSBocmVmPSJodHRwczovL2ppcmEud2hhbWNsb3Vk
LmNvbS9icm93c2UvTFUtMTU3OTUiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXpl
OjEyLjBwdDtjb2xvcjp3aW5kb3d0ZXh0Ij5MVS0xNTc5NTwvc3Bhbj48L2E+PHNwYW4gbGFuZz0i
RU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij4pLiZuYnNwOzwvc3Bhbj48bzpwPjwvbzpw
PjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTQuMHB0
Ij4mbmJzcDs8L3NwYW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3Bh
biBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPlBsZWFzZSBsb2cgYW55IGlz
c3VlcyBmb3VuZCBpbiB0aGUmbmJzcDs8L3NwYW4+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndoYW1j
bG91ZC5jb20vIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7Y29s
b3I6cHVycGxlIj5pc3N1ZSB0cmFja2luZyBzeXN0ZW08L3NwYW4+PC9hPjxzcGFuIGxhbmc9IkVO
LVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+Ljwvc3Bhbj48bzpwPjwvbzpwPjwvcD4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEy
LjBwdCI+Jm5ic3A7PC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+
PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5UaGFua3MgdG8gYWxs
IHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlzIHJlbGVh
c2UuPC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFu
Zz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij4mbmJzcDs8L3NwYW4+PG86cD48L286
cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZv
bnQtc2l6ZToxMi4wcHQiPlRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgbGlrZWx5IGJlIDIuMTUu
MTsgdGhlcmUgbWF5IGJlIGEgMi4xMi4xMCByZWxlYXNlIGluIHRoZSBjb21pbmcgbW9udGhzPC9z
cGFuPjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4t
VVMiPiZuYnNwOzwvc3Bhbj48bzpwPjwvbzpwPjwvcD4NCjwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1s
Pg0K

--_000_531CA8A8EDE7491EA7A3854C16936A09ddncom_--

--===============1560775115363898835==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1560775115363898835==--
