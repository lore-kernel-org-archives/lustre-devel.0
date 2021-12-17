Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9B600C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 17 Dec 2021 20:02:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 419EB21FA2F;
	Fri, 17 Dec 2021 12:02:53 -0800 (PST)
Received: from NAM11-CO1-obe.outbound.protection.outlook.com
 (mail-co1nam11on2049.outbound.protection.outlook.com [40.107.220.49])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1C28D21C9CF;
 Fri, 17 Dec 2021 12:02:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=FcQ1RxZ+1jyMV4A0KfEEYxMqLHX4MKmuHN8VTq5o4JlcnbUBhcMz45TOkCHTSXUjPWp6lG3IsgMFLOCMkNRehhBoiaKADrQmgqc2bRvVFh7dyNPh5vJrCNEJeYuaBSmmcf+3aUyyt1F4XP3FJFZlzB55rB1z73bvn53f2VHh8JORWxg8c2DoOVm2Se2Ovl47aD2woeq0+pQku7Or50mpAZzI5xvwwzXwF2ELtOEhzbwdoUqtN6VbXlrVEHvnS6e2j1TRw1NB+thrndFr8u40tuBkoFLGGUtPdLZ0XDhjFgF5l8MsjMEgyIyNyAEDzE//0hNhQP0tR/KyrEL4J8/J7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=fdnqhF4pPMl8Yyo3unqI1MCzItgIPO04Vi5lpj87zkw=;
 b=NJdVwOHDWLJO2U5n7M5iS1TY1PvGh5OQwI3AaMPDLq46GJDsntCZuAP9eXYl6ef+h+uE9kPfpTC3Efb8I7uYGSczybcJUXUkCT/n5Lwitpj0nf+vFijx6Vd40LPATU4Wucvq8kr3C9SJrsN/L2MfF8cTy7DhBMe+rQ548CyxI/Wsvi4UtEcWF4tBTJEbXSiEjpSou85zaZFAXs1p3LGSstirs7XNYK6pz5WHs5YZrpj9ewenzY7srSlEN56CT17ge4/GtFKG2MSfrZ5HIz4fg+uLU7QsQS9gbcareQ8AWAc6hnuqTuMAnQzowG42x2UoPQjRIWnjekI7TTLdARzJ7w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fdnqhF4pPMl8Yyo3unqI1MCzItgIPO04Vi5lpj87zkw=;
 b=Y9cbGXwTlE1rY8oxcVjwxPcn5P4RXjERmTjhrcANdXjlsV7uO3OX0gJTqCLm5J60Z2/vTFCi1HhOoo6HbBIEVSbO9DH6krHE+4naHblMeus9Tncmq7+20GgFOo/SeNdjIHryFvon4p2rz4M1cUmpWN9xlGa5tgR5lyyixR382gI=
Received: from MW3PR19MB4220.namprd19.prod.outlook.com (2603:10b6:303:45::24)
 by MWHPR19MB1071.namprd19.prod.outlook.com (2603:10b6:300:a6::14)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4778.17; Fri, 17 Dec
 2021 20:02:48 +0000
Received: from MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::b576:54a8:5e7b:4dd5]) by MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::b576:54a8:5e7b:4dd5%4]) with mapi id 15.20.4801.017; Fri, 17 Dec 2021
 20:02:48 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.12.8 released
Thread-Index: AQHX829rLhCVEymVbkKqRDE1vliO+g==
Date: Fri, 17 Dec 2021 20:02:47 +0000
Message-ID: <B144C2EC-9143-41E6-BC0E-72CD370A15FB@ddn.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.10.1b.201012
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aae0da4e-b203-4ec3-6732-08d9c19832c7
x-ms-traffictypediagnostic: MWHPR19MB1071:EE_
x-microsoft-antispam-prvs: <MWHPR19MB107183B904263FE626CB8016DA789@MWHPR19MB1071.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: l3XvDD4tWp6opu7XG/n5HU0cZJ7o1JExGi3VS6b2GEMi/SdzKjpxG/kb3rFWvoBUTj6g+0TNG0e5SifRiWdlQ26Dtqr6BkpSGWzanQPkgPcEfb0hwkw8sYCt5RDE/vHmOOzEGPEJNoGeJSvOTgpIlCYTcpvPiHmsqJOj5NRvtMd2Y+DE7Q5OmtO5ee10Vc5t/0zEsQmpYutlqB66c/d0peRwDEzmewSIK0DBeA0oQEW+db3cZeaWtmuOYFUQLKl9sLWxk3PAs6nNUrarMGvle3Vgk2cC2DvTv+5GvfzSOnTbOE7d5h9SJForQD6JU+uhWpdwsTMaDQ1zNB02G9qYz6HcVC2L+olfB0Dyxhxm/WyKFexjHRf5wg1VGLzkH26pZTHs8X2os9TgGTWq6Sx9mdkg0Nag3mqcJjt5SP+ke8rLISjKxlAT4JWj1smEShzLFDSw2XyL3No1uZNHkSNjx5+aabwL+TZzs9tn2h37P/u1XYG3F96xtzj6sNX/mEO2GB6lvdb1yVP0jFC8hGoJ7aljreMTK0jKk/oAewU67Ny6rxE36wTyo/ECmJaPujGdJ0L/fI/m7GbW+kMWkwTDTjJ9GDeqO4No65PiQ0w3U6mMQ70mNocAC3RFvzrcr9q1tCL1+1NH2s4thxh/p72ScU4iAtXhpHqjS2bMN2FMmTWCXEfMQMCHz2gwXkvcH9APH/uz33q7I+DRoUck+jdSwfxbW1hVmPhLqKeAJHf0DKMu2bQ+cDv/uEsGzMQXjsdF1emVmZncM/KfNORLxp5yC3z2HdkDMx58tXCgMew5pwmY/AUHLfEvDxW1OQ15uY1rGOFnpe/37uxdMj/3ZWLKlbeFyEduGeOQEJCWtk+7g4Q=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR19MB4220.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(186003)(6512007)(9686003)(6486002)(5660300002)(38070700005)(122000001)(86362001)(8936002)(8676002)(38100700002)(166002)(83380400001)(4744005)(33656002)(66476007)(66556008)(66446008)(64756008)(110136005)(508600001)(36756003)(66946007)(2906002)(6506007)(7116003)(71200400001)(76116006)(316002)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?L2tIbUNtLzgrc2ptU1dCMWNMM1RWekhnbjM2eldpNlNwdVJUUzdXTEFIeitX?=
 =?utf-8?B?Y2plTkZMdDloQ2pBYWxCT2FBMHJPb3ZEcTdHM28zT05xVmFMY253L2JiTE9W?=
 =?utf-8?B?ZVYwVE0veUMzclRKWXg3RFpQTUNiRTBxT3FzaWV4VGtOajRoWTBuYjNmMkR1?=
 =?utf-8?B?Ykc2YWhaSGpZbkNYN2hsVlBTM0IzcklRUDVqQ1VzbEVWVkt6WU9qUjUxaU4z?=
 =?utf-8?B?WnVmOHBwek1rS0swSGYwRUZwaFgzbVRaUWx1bk9kdEVsU1JHcUhyRnVORC96?=
 =?utf-8?B?bllieUM4bDFIYmxmdG5HUDBTdEVGZXBhYlpmMFZ6NWVaMVlTb0FUVEVaOFBW?=
 =?utf-8?B?TlMvSVVueldTMVV2RHFqQ3p2bXdaYzlhTnJOaE9rRnBNSFJpMXdwL0pSOWhP?=
 =?utf-8?B?ZHlhODh6SDJZbWZLSXVnVFU3WUxVcWZkVE5CQ3ZpcWNNYTNIaFhYTncxemNI?=
 =?utf-8?B?TE13dTVHTFVmSm5iVW1BUTF2VTZpZGM4aVluMDFNWWNNNlNvWmxBdjdTeGla?=
 =?utf-8?B?eWgxUUxFVnJEdUM3aDNLbExXVDFqMFRqS0IyTFV4QWFLVUJzZHlsMVluOU9l?=
 =?utf-8?B?U2duT2V5b2h6T1JmdzdIU3ZLOTlPQ2VTcUQ5dEVsVzJsNmxPRURZOE5rbzBZ?=
 =?utf-8?B?ZVlVbnlsSEhINGliTGtUdGVIK3RkT1NDa2dFZG5aakttZjUzTVJiYVI5bExX?=
 =?utf-8?B?K01iZG9BZkFEcVF5OHFBbnB4K0x6Wml5US9kRFd5N01yeDRkV3llRmJDanhI?=
 =?utf-8?B?bWdaUmlrc2E2TDlPb1V0aVVnTzFYVnJJaFBQUnRSTXkvaG9kTStzRHY5ZFhL?=
 =?utf-8?B?dXkrdWVHZUhlSjhsNVA5VU0vL01nZm90ZU9LR2ZCVVI2K3NsTUdSbUVaOU15?=
 =?utf-8?B?eEFMbk5ldy9QdnJITjlaN2ZrampuSE1VOVRMemdmZWxSa1B0Z3RqZFdJSlBv?=
 =?utf-8?B?SXgrdGwrMGQ1RDl1VFlVK0tTYVI4ZC90QmJHSzR6alpQOFpzK3N3ZTJxMkFi?=
 =?utf-8?B?UnJHY3V4ZVIyalJjbHpCYW9Day9CN29QeFZnK3RJU1VSOGE3SG9YcjlKWUU2?=
 =?utf-8?B?Z0ErN0tmWFVqN00xdld2d3lqNUNJNTg2Sm4xdXFKYUtSUWNYc2QxanBuY0VQ?=
 =?utf-8?B?cnVSRlU3TFY5bW9FQ2FvVG96bU83emN6cGZheE91TGxVSldUa3RoRnNzeXAz?=
 =?utf-8?B?Z1lCcFV3UElpK3RibkRKZVBGTGxMaUFKVFp6TStQOUU2UDRDVVhXYTcvZWxG?=
 =?utf-8?B?Qjl1aGdPM3VOT2pUdUtJRDZWbGNNc3hjelh6SzZaUmVORnBBWE1sM2ZGL2pq?=
 =?utf-8?B?dHlXWjB6eXRSZUg5TDV5UVN3RlQzYytGWmJvbEdwclJldytHRzVjdFhTMDM2?=
 =?utf-8?B?TGwrSlh0emtsMWU3UE1tS05qcG4xOW01Ly9OM2lkNDhCbEhGWW1aYU1oczlH?=
 =?utf-8?B?L1Z4ZDdnWWJkVVgzV2d6NmNYbm10ZFBoMFkxWFkrNW9ZV0VaajZpcjNUaXkr?=
 =?utf-8?B?L0E5OVl4bzUyWEZYNEpHelhuS1RJTHlpU3dRLzZpWUY0RkluZkNvSHdndzVX?=
 =?utf-8?B?bWR4UHdPRWdkSG44enJab3RWaGN4d0FvWGNWbEorYTFOTjU3YkJwVzY3bjRJ?=
 =?utf-8?B?eWF2akV6OTVwaTdKcjArczJ0WXpnL0dsczl4OGt1NndKWis3cDVMN3ZFbGlh?=
 =?utf-8?B?ODlLdnM2UVY1c0o3Yk8rNlVJQi82MjRvNjZnY25ham93RFQ2b2locDY2Wi9x?=
 =?utf-8?B?eEZFb3plQXlvbm03T3BsdUQ3TzNPTlUvN2d4NmVlSVBkbTFTYjZ3dkROenZE?=
 =?utf-8?B?dFVYWk51VU5FcDhxREZBZU5nNGlpWjFNcjFSeVNhQzJDdTduSGgwMDQranNj?=
 =?utf-8?B?ckNLUytEVldrWVdnVmNiN1FnNWZrWUlXMkZKazBsRmZ2c3R6ZDMzOUw4WlVt?=
 =?utf-8?B?aWM4MUhmL2MrYk9leWlWU0ZRQWsrL1FPZURsRHhFWUM3WWpoNThSdUt6c0d4?=
 =?utf-8?B?NXNocUp4WjBlZWdCUmpNaVY4MVRzVG92YWhrR0VWbWhEUXZuMkJKaVA3Ymh3?=
 =?utf-8?B?c1JoQTFMdGdsU3Q1UFA2bUQzZE5WNlZwUytsZDlaSmljRmx2YzkvMXJOVEpo?=
 =?utf-8?B?VVRVS3hCVDkvd0RMZmFKTzNxWlhGVWZ1TjFCRHY2T1hBUVNtTm1NM09hdXAv?=
 =?utf-8?Q?Ek1D89xVUpgtZtxdGwuh3w3PSe0R6X3t3xmDgZDKZdE1?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR19MB4220.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aae0da4e-b203-4ec3-6732-08d9c19832c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Dec 2021 20:02:47.8567 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: eMdiInS7iJdtI20gapgPLL0b0N3uuPsdlyEp33Ktrfg4NbC6+7ZvYbJf881DEgI9
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR19MB1071
Subject: [lustre-devel] Lustre 2.12.8 released
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
Content-Type: multipart/mixed; boundary="===============1078069998697238519=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1078069998697238519==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_B144C2EC914341E6BC0E72CD370A15FBddncom_"

--_000_B144C2EC914341E6BC0E72CD370A15FBddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTIuOCBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkLjxodHRw
czovL2Rvd25sb2Fkcy53aGFtY2xvdWQuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIuMTIuOC8+
IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbSBnaXQgLjxodHRwczovL2dpdC53aGFt
Y2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPTA2N2NiNTUxOGYy
Zjk3NmRkOWQ4MDVjZjQ5YjAxMGY4MWFlODYzOTY+DQoNCkRldGFpbHMgb2YgY2hhbmdlcyBzaW5j
ZSAyLjEyLjc8aHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTIuN19DaGFuZ2Vsb2c+
IGNhbiBiZSBmb3VuZCBpbiB0aGUgMi4xMi44IGNoYW5nZSBsb2cuPGh0dHA6Ly93aWtpLmx1c3Ry
ZS5vcmcvTHVzdHJlXzIuMTIuOF9DaGFuZ2Vsb2c+DQoNClRoZXJlIGlzIHRoZSBmb2xsb3dpbmcg
bm90YWJsZSBlbmhhbmNlbWVudCBvdmVyIDIuMTIuNzoNCg0KUkhFTCA4LjUgaXMgbm93IHN1cHBv
cnRlZCBmb3IgY2xpZW50cyAgKExVLTE1MTI2PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jy
b3dzZS9MVS0xNTEyNj4pLg0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQgaW4gdGhlIGlz
c3VlIHRyYWNraW5nIHN5c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS8+Lg0KDQpUaGFu
a3MgdG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0
aGlzIHJlbGVhc2UuDQoNClRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgbGlrZWx5IGJlIDIuMTIu
OQ0KDQo=

--_000_B144C2EC914341E6BC0E72CD370A15FBddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <9D3B7DAFE3F42D4E862B0E7B0E11D4F4@namprd19.prod.outlook.com>
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
c29Ob3JtYWwNCgl7bWFyZ2luOjBjbTsNCgltYXJnaW4tYm90dG9tOi4wMDAxcHQ7DQoJZm9udC1z
aXplOjExLjBwdDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjt9DQphOmxpbmss
IHNwYW4uTXNvSHlwZXJsaW5rDQoJe21zby1zdHlsZS1wcmlvcml0eTo5OTsNCgljb2xvcjojMDU2
M0MxOw0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0KYTp2aXNpdGVkLCBzcGFuLk1zb0h5
cGVybGlua0ZvbGxvd2VkDQoJe21zby1zdHlsZS1wcmlvcml0eTo5OTsNCgljb2xvcjojOTU0Rjcy
Ow0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0KcC5tc29ub3JtYWwwLCBsaS5tc29ub3Jt
YWwwLCBkaXYubXNvbm9ybWFsMA0KCXttc28tc3R5bGUtbmFtZTptc29ub3JtYWw7DQoJbXNvLW1h
cmdpbi10b3AtYWx0OmF1dG87DQoJbWFyZ2luLXJpZ2h0OjBjbTsNCgltc28tbWFyZ2luLWJvdHRv
bS1hbHQ6YXV0bzsNCgltYXJnaW4tbGVmdDowY207DQoJZm9udC1zaXplOjExLjBwdDsNCglmb250
LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjt9DQpzcGFuLkVtYWlsU3R5bGUxOA0KCXttc28t
c3R5bGUtdHlwZTpwZXJzb25hbDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjsN
Cgljb2xvcjp3aW5kb3d0ZXh0O30NCnNwYW4uYXBwbGUtY29udmVydGVkLXNwYWNlDQoJe21zby1z
dHlsZS1uYW1lOmFwcGxlLWNvbnZlcnRlZC1zcGFjZTt9DQpzcGFuLkVtYWlsU3R5bGUyMA0KCXtt
c28tc3R5bGUtdHlwZTpwZXJzb25hbDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJp
ZjsNCgljb2xvcjp3aW5kb3d0ZXh0Ow0KCWZvbnQtd2VpZ2h0Om5vcm1hbDsNCglmb250LXN0eWxl
Om5vcm1hbDt9DQpzcGFuLkVtYWlsU3R5bGUyMQ0KCXttc28tc3R5bGUtdHlwZTpwZXJzb25hbDsN
Cglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjsNCgljb2xvcjp3aW5kb3d0ZXh0Ow0K
CWZvbnQtd2VpZ2h0Om5vcm1hbDsNCglmb250LXN0eWxlOm5vcm1hbDt9DQpzcGFuLkVtYWlsU3R5
bGUyMg0KCXttc28tc3R5bGUtdHlwZTpwZXJzb25hbDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIs
c2Fucy1zZXJpZjsNCgljb2xvcjp3aW5kb3d0ZXh0Ow0KCWZvbnQtd2VpZ2h0Om5vcm1hbDsNCglm
b250LXN0eWxlOm5vcm1hbDt9DQpzcGFuLkVtYWlsU3R5bGUyMw0KCXttc28tc3R5bGUtdHlwZTpw
ZXJzb25hbC1yZXBseTsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjsNCgljb2xv
cjp3aW5kb3d0ZXh0Ow0KCWZvbnQtd2VpZ2h0Om5vcm1hbDsNCglmb250LXN0eWxlOm5vcm1hbDt9
DQouTXNvQ2hwRGVmYXVsdA0KCXttc28tc3R5bGUtdHlwZTpleHBvcnQtb25seTsNCglmb250LXNp
emU6MTAuMHB0O30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtzaXplOjYxMi4wcHQgNzkyLjBwdDsN
CgltYXJnaW46NzIuMHB0IDcyLjBwdCA3Mi4wcHQgNzIuMHB0O30NCmRpdi5Xb3JkU2VjdGlvbjEN
Cgl7cGFnZTpXb3JkU2VjdGlvbjE7fQ0KLS0+PC9zdHlsZT4NCjwvaGVhZD4NCjxib2R5IGxhbmc9
IkVOLUNBIiBsaW5rPSIjMDU2M0MxIiB2bGluaz0iIzk1NEY3MiI+DQo8ZGl2IGNsYXNzPSJXb3Jk
U2VjdGlvbjEiPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxl
PSJmb250LXNpemU6MTIuMHB0Ij5XZSBhcmUgcGxlYXNlZCB0byBhbm5vdW5jZSB0aGF0IHRoZSZu
YnNwOzxiPkx1c3RyZSAyLjEyLjg8c3BhbiBjbGFzcz0iYXBwbGUtY29udmVydGVkLXNwYWNlIj4m
bmJzcDs8L3NwYW4+UmVsZWFzZSZuYnNwOzwvYj5oYXMgYmVlbiBkZWNsYXJlZCBHQSBhbmQgaXMg
YXZhaWxhYmxlIGZvcg0KPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91
ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xMi44LyI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0
eWxlPSJmb250LXNpemU6MTIuMHB0Ij5kb3dubG9hZC48L3NwYW4+PC9hPjxzcGFuIGxhbmc9IkVO
LVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3Vy
Y2UgZnJvbQ0KPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vZ2l0LndoYW1jbG91ZC5jb20vP3A9ZnMv
bHVzdHJlLXJlbGVhc2UuZ2l0O2E9Y29tbWl0O2g9MDY3Y2I1NTE4ZjJmOTc2ZGQ5ZDgwNWNmNDli
MDEwZjgxYWU4NjM5NiI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0
Ij5naXQmbmJzcDsuPC9zcGFuPjwvYT48bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3Jt
YWwiIHN0eWxlPSJtYXJnaW4tcmlnaHQ6MzYuMHB0Ij4mbmJzcDs8bzpwPjwvbzpwPjwvcD4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJtYXJnaW4tcmlnaHQ6MzYuMHB0Ij48c3BhbiBsYW5n
PSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPkRldGFpbHMgb2YgY2hhbmdlcyBzaW5j
ZSZuYnNwOzxhIGhyZWY9Imh0dHBzOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjEyLjdfQ2hh
bmdlbG9nIj4yLjEyLjc8L2E+IGNhbiBiZSBmb3VuZCBpbiB0aGUmbmJzcDs8L3NwYW4+PGEgaHJl
Zj0iaHR0cDovL3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4xMi44X0NoYW5nZWxvZyI+PHNwYW4g
bGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2NvbG9yOndpbmRvd3RleHQiPjIu
MTIuOA0KIGNoYW5nZSBsb2cuPC9zcGFuPjwvYT48bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJN
c29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+Jm5i
c3A7PC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFu
Zz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5UaGVyZSBpcyB0aGUgZm9sbG93aW5n
IG5vdGFibGUgZW5oYW5jZW1lbnQgb3ZlciAyLjEyLjc6PC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNp
emU6MTIuMHB0O2JhY2tncm91bmQ6d2hpdGUiPiZuYnNwOzwvc3Bhbj48L2I+PG86cD48L286cD48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48Yj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZv
bnQtc2l6ZToxMi4wcHQ7YmFja2dyb3VuZDp3aGl0ZSI+UkhFTCA4LjUmbmJzcDs8L3NwYW4+PC9i
PjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdDtiYWNrZ3JvdW5kOndo
aXRlIj5pcyBub3cgc3VwcG9ydGVkIGZvciBjbGllbnRzPHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZl
cnRlZC1zcGFjZSI+Jm5ic3A7PC9zcGFuPjwvc3Bhbj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9
ImZvbnQtc2l6ZToxMi4wcHQiPiZuYnNwOyg8L3NwYW4+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndo
YW1jbG91ZC5jb20vYnJvd3NlL0xVLTE1MTI2Ij48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZv
bnQtc2l6ZToxMi4wcHQ7Y29sb3I6d2luZG93dGV4dCI+TFUtMTUxMjY8L3NwYW4+PC9hPjxzcGFu
IGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+KS4mbmJzcDs8L3NwYW4+PG86
cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1zaXpl
OjE0LjBwdCI+Jm5ic3A7PC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5QbGVhc2UgbG9n
IGFueSBpc3N1ZXMgZm91bmQgaW4gdGhlJm5ic3A7PC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vamly
YS53aGFtY2xvdWQuY29tLyI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIu
MHB0O2NvbG9yOnB1cnBsZSI+aXNzdWUgdHJhY2tpbmcgc3lzdGVtPC9zcGFuPjwvYT48c3BhbiBs
YW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPi48L3NwYW4+PG86cD48L286cD48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQt
c2l6ZToxMi4wcHQiPiZuYnNwOzwvc3Bhbj48bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29O
b3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+VGhhbmtz
IHRvIGFsbCB0aG9zZSB3aG8gaGF2ZSBjb250cmlidXRlZCB0byB0aGUgY3JlYXRpb24gb2YgdGhp
cyByZWxlYXNlLjwvc3Bhbj48bzpwPjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxz
cGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+Jm5ic3A7PC9zcGFuPjxv
OnA+PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0
eWxlPSJmb250LXNpemU6MTIuMHB0Ij5UaGUgbmV4dCBMVFMgcmVsZWFzZSB3aWxsIGxpa2VseSBi
ZSAyLjEyLjk8L3NwYW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3Bh
biBsYW5nPSJFTi1VUyI+Jm5ic3A7PC9zcGFuPjxvOnA+PC9vOnA+PC9wPg0KPC9kaXY+DQo8L2Jv
ZHk+DQo8L2h0bWw+DQo=

--_000_B144C2EC914341E6BC0E72CD370A15FBddncom_--

--===============1078069998697238519==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1078069998697238519==--
