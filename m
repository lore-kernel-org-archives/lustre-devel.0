Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EDE4CC2BD09
	for <lustre-devel@archiver.kernel.org>; Fri, 28 Jun 2024 23:22:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W9rvr2n1fz22Sf;
	Fri, 28 Jun 2024 16:18:16 -0700 (PDT)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W9rvM0zwRz22VK; Fri, 28 Jun 2024 16:17:51 -0700 (PDT)
Received: from NAM04-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam04lp2041.outbound.protection.outlook.com [104.47.73.41]) by
 mx-outbound12-122.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Fri, 28 Jun 2024 23:17:21 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=FQncPsMFZHYYRvtPbTDSKgZn4ZFFcj/L8qPjfFvHdwxLvg9tJdnUy4rlqUgPvWmRkuPMneOZ1wDPOc9ptdog+Dr7qqHKNiiKnL+N407SZhCbHkEG8qkz6NWiRLvbgOE85Qb1TJkf96nm9gEsTWiFSI0Wxbr2/ZnxviLOqh0gdm8CgyiUD3Q/dOhqPsqjgpIMySiQMEMv/E7OA3YpV2bs3e9kXWIrhq2kK3pD0AxvLAVLu/8JqJg1gMhsHBTUET9vYEDtJC5BTekul+BklnUuSmdXCEQaDnPnLZk0zy/xEGJ56NH21d2PmxUKgn8sTU/VBFOxKSd+inR0iu8n+cR+Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=2hN/IQSfvyzEnmE9fs2PjE6SkGTIkIq3uOGCE0unCBQ=;
 b=VEEpNfLt/JTvGwJIECUVTvOtHo4wIgdXy0auNPrvipyyzz1j9M/vMQNxotNPTQBdyDiIr1bHm8rJJWohivq3M6r0gRMbUZbATzZp6j5uCn64qhcOJ/mw+Op8kLz233lqPFWwnuZ6LqEq9jp66Q2plUwV0F2s3TVwmHiNEYSf2n7DDspCyQ2z4VuoTU4w+rqY5RrbFLLYUNJsUzrFhBWp6GCbTGr2L+y1BJoz70zYNTVb6zswVj6IESVtKKu6WVXulbGx2pWuETYjPyD4XBuSCmZsmvwIfoJuv2kpwDvQeb6jnGZlYOf1pEa4yDIZXK0wMQ+Fme+yO/Qzh0FmV1rvQg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2hN/IQSfvyzEnmE9fs2PjE6SkGTIkIq3uOGCE0unCBQ=;
 b=htumZpbQ3UJBfFnfZmQjPg/aqPe/Z1EIMj8hF8hnlnC5p/wu5bIIQl/erDUn5SShuW7KpPwqiKnhL/HMpznm2wEQjyLxw4RdnW4mC1tJOIyLeH1SHVBrQp03DvJgcuZ+lD8D+K3dVHTjuZMHgpvF8xACi7iCseGDm33JtTfldEU=
Received: from SA1PR19MB7061.namprd19.prod.outlook.com (2603:10b6:806:2be::9)
 by CH4PR19MB8563.namprd19.prod.outlook.com (2603:10b6:610:22d::18)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7719.26; Fri, 28 Jun
 2024 23:17:17 +0000
Received: from SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6]) by SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6%5]) with mapi id 15.20.7698.025; Fri, 28 Jun 2024
 23:17:17 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.15.5 released
Thread-Index: AQHaybFRnVb7batfo0aEIjuz/beQJg==
Date: Fri, 28 Jun 2024 23:17:17 +0000
Message-ID: <4399F0EA-461B-4411-9100-A230877006F5@whamcloud.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.86.24061443
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA1PR19MB7061:EE_|CH4PR19MB8563:EE_
x-ms-office365-filtering-correlation-id: 56c5b23a-e978-4249-2146-08dc97c873db
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|1800799024|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?M1gzTjgwOEIvVWgycENFVlh6VERLSEVJRThYVE1OUFdPYk11VzQ4NzhLWFY1?=
 =?utf-8?B?V3JBQnFMRTdaeSt4Y3d6KzdDVCt5VXFzL0tlTmFKamN0NXBpOUhXMzNXVHlK?=
 =?utf-8?B?UjlIdXVPUlBtQml3WlpTeHd5Z0kxYTVKQURudmdKME45Qi9SM0hqOXRzZVRX?=
 =?utf-8?B?VXRrQ1ZoM1cwM3o4ZDlWMWtGQ2QwbEQwLzc5U3dXM2RuODE2ZFE0OFNhdGIx?=
 =?utf-8?B?dzhMWkxKZWkyNlEyTTUxNmN5VFU1WDFEeUhMVEt3UTlIZk1yZmpyNnFTMmlx?=
 =?utf-8?B?cW5ZU1luRlVSYVdLdXFqNVZobEZ2d0JtVlZBTk9rN3FtcHA5TWVSWGJ0dkxH?=
 =?utf-8?B?aE1LVEtKSmlXalVCVTJrV3FLem5lYUtVT1BWSVdIUjdneFJjUUFZcHVQQXZo?=
 =?utf-8?B?UWtBNXppMTY4ajRlYlRiT1E4ZWszbVpveW84Sk1oc3pPcTlSWUFoaTFIZFk0?=
 =?utf-8?B?cEQrMXNkTDRoQTQzbE9YZmpld3pySWRWL3RablE3N0JQTmpTV0FRU1FDR2R4?=
 =?utf-8?B?RGQ3eDROQUhWcTRRMDVDZDdaNDZxa2VWcVlrT3BjZWFKRGIzaFdtSE9rUWxh?=
 =?utf-8?B?Mk1OZ2Ira3FjK0tLSkF5TWx2Mi9pcndaR0pVZ00yODdmalhWM01jcVFIcmx6?=
 =?utf-8?B?cGtrNldhclU4K0JTWU01ZXV2ZkJPb3BuN0llU01KdjRqdGdvTG9rWExvMkhu?=
 =?utf-8?B?TUZsTmwrc0o3RERuYlJJOGJHdWdPMCtLZnVoVXVjYW5HdXNBZWZoTjNHMUV4?=
 =?utf-8?B?bkl3MC9hZlJ5L0xFaGpXbWpCTWE3TFY3VzJ2dlUxUGFxMmZiazkzb2xHalBk?=
 =?utf-8?B?WlZlQVRXTTRYMEZOdWRXRTdEL25hTHNXbC9ER24rLzVqRFBZUkx4djJ0UWJO?=
 =?utf-8?B?TFFydmxRS2lKQThqOFRCQ3FFbnUxYk5jVXExZ1lOcjNjY3lNMmVEeUU0Rmtq?=
 =?utf-8?B?enhDa2dNS0xrU0t3YURBNnhadnRleU50ZVhHMW9CYlpvRG9PbWlHTlUyODRy?=
 =?utf-8?B?TWUzMnFib083b3FoY1FLVW0vRGllaW8xZHFhd1k1ZTZaaml2d2dqd0JLV0ll?=
 =?utf-8?B?MUlIWU5DWHZoTTBibzNlemR5RmF6WjdWMDA0cTFldm5FQ29nRHlzK1JZOXl5?=
 =?utf-8?B?M2FGZllNbU1YcnBtWTBzSkptV2ZKdWhnTUsvNjRjRWJoOTZUek5YbTBNTXlX?=
 =?utf-8?B?VVVFS002TnFPNytPdG9QSU9oems3bjJpck5UdFQ4eUlwQnNkMEtkYXEvbExr?=
 =?utf-8?B?Uy9KWmI3bGtBbnBIUjhnU0lLanR5TlJHam5SV1BTd0VqakY4a3lKNzBFNnhY?=
 =?utf-8?B?UUVlT1MvTVkwMHV4WGs4ZXJ6UzJNY0ZUZ3pIYXJqbzR3bVgyNGRFdnVCZkpD?=
 =?utf-8?B?eERHMUZmanU5NVp5cFpRdnhzTWFwZW8vMk0vR3hqekY1Z216WmNSUjNpczBj?=
 =?utf-8?B?SFdCcjRkWi9ONnkvQTB3Tk83YWJpZXNlS0Nwdk14QTFKY0RvSWwzMmk5UzV0?=
 =?utf-8?B?YWIzREswbzJXQXZtQ2tjRmRDWlppbWplQU93VXAzdHNsL2xwcHFBQzRMNTQ4?=
 =?utf-8?B?OU83UlQra0dYOTZaVlM2ZzB3UEp3WWxpekJQandib0pZdW80K1pnTm5aODY5?=
 =?utf-8?B?emZOYTdQS1pianNsOXhwMHpsNytVekVEYVYvZ1pGblNsR3dJOEtITHhWTlhT?=
 =?utf-8?B?N0wxNzN1ZHRyMldFcit0aC9QaVdXME1PUzNhMFhrako0SmprQ0p2Wkt0TGZR?=
 =?utf-8?B?akJNY1FVWG56V1E0OXM1R3V0VEVKMzRhblUxbmo0aldpL0lXMkRzazh4bzFU?=
 =?utf-8?Q?TBTzEIbvLTKhIU8cG3SoEAkG0bCSvPwbInqDk=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA1PR19MB7061.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?WGlzZUhWTTlyMWkvZGVYaGg4U2ROUnJSZVJkSlhmVmV6S3JYb0s2WGttNWJC?=
 =?utf-8?B?Um9ucFdwR04rVVY4TWFkeldnQjhCSWxnSDdGQkdxREtyc3dHRGo4amRRV1d6?=
 =?utf-8?B?Rnd2WGZCSFhhMGFrb1NVYURETmZ6NXlQa1laQUpyQkgyLzhLaTZObHVEakZp?=
 =?utf-8?B?ZHhhTG1kU09VYWp4RDZ1b0U2NDY0ZU44Sk15ZGdra2M4c21ybFhZYmRxR0FL?=
 =?utf-8?B?RUFhY1dhYTNxK2h6VjluRDJ6a053YTVZMTU2LzVFYzJuSXoxNVp2aEdmWUhR?=
 =?utf-8?B?Q0p2SllqRVNqb3RYblg1dFo2c2ZHRXltYXA4QlJBcGswYVhwUVBFN3Vob0tD?=
 =?utf-8?B?V0cyNW1aOEtQWkE3dUhFMUg4OU13bFVDelQwTXI4SW9JWlJiVjhpdzNaVEgv?=
 =?utf-8?B?MGJldFhwOFJEWmZBSlc2WVJhVkRHZ3VwOXhIN0ZCWHhnenlNSWN6TWpWKzRu?=
 =?utf-8?B?QUt3R2Q3Yit2VVdsZVFtZlFxc2dXR2dQRi9xZkFVeVA4dFlhSEJMYzBUZHBN?=
 =?utf-8?B?TXJ4d1VDeDlaMnhFcXVHSWx3aGZBaTQyOEJBVG5kMDNYZzE3UmlMQkZYdFBV?=
 =?utf-8?B?Y2NoS0kzZncxOWdHTGdqUGdlblhRaUxDNi9SaHBzY3pSWFAxQ2JVSE8vNC9C?=
 =?utf-8?B?eTFvbVhPTDlCZHJMK3M4QnhveG1ZQU9Ib2Z0Y2Y2RWVyejZBM3NYeWVwTWdS?=
 =?utf-8?B?cktIelVOZGN0a1o2bWxCTS8yNkRZbmE2d09TK09KZXJsK0orL0VDek02Sm5u?=
 =?utf-8?B?UWJvd2tXU2RsaHowelBneFNoREdJL3E0cVNmdVAwbzJVZG9BU1A3S2pVbHhl?=
 =?utf-8?B?WCtDQzNRU3dZM0dsSTRoN1dBYWN3c1E4QVZ1Q0xPQStUby9aRmpmcFBmRmpR?=
 =?utf-8?B?aUtsV0NqVk9hZWpNZWpkaWYzMmJJYnZpeXZZR1Fvb3lpK3FwdzZBS2pQbkpH?=
 =?utf-8?B?MWZnUWdzVjhBZy9hbEpWYjcvd2U5NWhkSU83SUNIcnJEUUYrWnN1ZDVPck9m?=
 =?utf-8?B?eVVlYVJFWEovK05BeSs5OTB6R1E4N3BUbmo5dWd1MHpwbE9EazFFbU5FaWZj?=
 =?utf-8?B?WlBlTVF5TnlKMkQ3L2VHVUFrTnM1ZVhIVHhRbDBsOXZqRmo5ZG1SR2w5NHdP?=
 =?utf-8?B?NGhQK1hSMk84aFpMa3ZveVpuc0FWdWY5THd0NzVYSnhyK0JSVW5OeGcvS3Q0?=
 =?utf-8?B?Qy82akhHWXVucisrYmNrUnlxMDFMMVNJRGZIdTVRbmFnZXBqLzFwZ3NNcDBQ?=
 =?utf-8?B?L0ljcXlYbGUwT1NON3VBSmpINzNIem5jTlVoNEhuVDN1bm1xbEU0YjdxQkJD?=
 =?utf-8?B?WUVBZy9pNEw5dzJWVUg0ZEJYSlAvY1BDSTNRNTJiV1BhV3RCeXhNVmluZWJT?=
 =?utf-8?B?ZmhYVGtKN2xMd0I3N1dHT1JCWXRoYkw4bk80Y2ZqT0YvTTBsdTV4M2trRlkw?=
 =?utf-8?B?SFQ2V0pucHY1d3BJblVHZ01pR1NJdlhjQ2ZNMU1EOUdzVUZyREMvY2l3dElQ?=
 =?utf-8?B?ZVJSVUpkejZQRC9BbGpGN3pHclJzYkNERWtOclAzc254bnRvV295VTBLM3pX?=
 =?utf-8?B?Ti95ZTBvQVgvZlVwWFgxLzZYaXZ6RWJYTU1wem9qUXhpNmJQWm9jVUJjWUtT?=
 =?utf-8?B?dDhkRVIyRUVTKzc0V1V1bHg3YlFyeit1UDZuZGVoKzA1c1dZVUJ2b0NQeHRZ?=
 =?utf-8?B?ZVBueThiMmJVL3NrY3RTSWV1ck5WTXJGb05SK1A5VmU1MThpRk1IREc4cG4z?=
 =?utf-8?B?ekJQdG95R0U1T2lwK2tueHAxMTY5UlR3ZVlCZW1pN255R0tqYXlveGRJYmY3?=
 =?utf-8?B?dlIzMnUvWlBjNkpiOTVUWitxQ1hFcHk5SHEyankxTzhGekl4RTNWbHo3Nmxa?=
 =?utf-8?B?aHZpa3g3Unp4RStWSnBjakU2YVpFN2pQYUhCOU90c3hzcFdwdSsveW41NDVR?=
 =?utf-8?B?em1JV3FUallxMUNvQ2x2RkdVN1NZaWtIQ2FyVGZtTEVpQm1qei9VRUxOaDEz?=
 =?utf-8?B?dVo1TkI5TlZ6aEdRc2FVYjlHeUlzUUJNMVdweEhVQzFFVGtwQlkzTDNVYXNq?=
 =?utf-8?B?VFA3ODlOVjZrUnNLNkl6aWg3eFdMUlIvbTk5QU0zdFlMOVllY2ZzK3dkNTJi?=
 =?utf-8?B?ZmN6MDNpZ2U1bXZ1STdYRXJxamVERFloQUcyK21rMnIvWUpHWGU1cHZzRVJ3?=
 =?utf-8?Q?ktNPeC0oraIRFg+lHABcv1vHxXwL7g+vVpBa+nyXWLK/?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: CsAgqt1bH3XXAYp4sF2EtMoOAGJf8RwelXr99kGoa2nCr9AzgmcAs+EowVZdxNkGffSMYd3g2Vmz5lE8EDAaOSmufech3t9NQOkOaz953w+8NLVV4Tuutk0VXcaNbhf1UnVkLIPLOS+ZdOXpdpTLLPIXx1aOlZeryutMp06fLnLC/mrErjtlYaiUTLh6+DBt8QrUeAcmpRBwLv/ECLXY6HxsSxahWLTv8rps6t3Q8eyvGZPcAs7lHnVSoRGB7t2jUQcKubiCxE0+02xazp7PfSApeOlljY/iOPfeQHCufzkH0MeArNITxQwgBLcIb6POxZCNjES3c76F0VgXkEo3vQmTo/05rQtfKRqroduqkdFuvbpeb/DXqdAlfbFy36rq0uNa6kbMX9GHYMei1tP7gG/YCoFvkHFH7Zb3z7drv7/xnY7a3lUYa5uoUjscEmVuGH5VCZ2qBmx8VeS7SSHsioJGnx3h4n0HkbZaIv+Mi7bGcG32zcMYXV+ykt4NInWW8v+GVw0kcYEK5FnqdDowbie081CkWwuWp5VylwJwr0DdrEEwKB4CwAk3+QuqyBPXKx0fpZzWmj/94xJCakGnqcmxXlBjoJ2mT1YIbCNWNNzCLJ7gYPHf9MDvNsRLrgKQrey2OEwEO7u3T9+fEUCZgjGo2f0BFYl3IQGhi7KraLE=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA1PR19MB7061.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 56c5b23a-e978-4249-2146-08dc97c873db
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jun 2024 23:17:17.2626 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: wiW3Hu1+rSvXfX7PXPYymlDuRxgbi95xfe3Ep9db1PxfKJ+CXJS/M42gMy8PFJSS
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH4PR19MB8563
X-BESS-ID: 1719616641-103194-12639-19526-1
X-BESS-VER: 2019.1_20240620.2317
X-BESS-Apparent-Source-IP: 104.47.73.41
X-BESS-Parts: H4sIAAAAAAACAzXLuwrDMAyF4XfRnEGyrYvzKqWDnUhkKR3qoVDy7vWQLIefA9
 /jB/4dsMKYu8D7AyshlVnHPLEya9GwvjcJLZyMxbx15hxYDc7l9sd4XV6q6eW7uPdqSN
 py2qk0zVUi+SaCW6aA8/kHQ2t8loEAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.257266 [from 
 cloudscan20-76.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Lustre 2.15.5 released
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
Content-Type: multipart/mixed; boundary="===============3657850854534505137=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3657850854534505137==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_4399F0EA461B44119100A230877006F5whamcloudcom_"

--_000_4399F0EA461B44119100A230877006F5whamcloudcom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTUuNSBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkPGh0dHBz
Oi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xNS41Lz4g
PGh0dHBzOi8vZG93bmxvYWRzLmhwZGQuaW50ZWwuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIu
MTEuMC8+IC4gWW91IGNhbiBhbHNvIGdyYWIgdGhlIHNvdXJjZSBmcm9tIGdpdDxodHRwczovL2dp
dC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPTIxOTIx
ZmIxMTFiMjgyMjM4MjhkNmJlZDMzNzc4MzE0MjlkMGQ3ZGU+DQoNCkRldGFpbHMgb2YgY2hhbmdl
cyBzaW5jZSAyLjE1LjQ8aHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTUuNF9DaGFu
Z2Vsb2c+IGNhbiBiZSBmb3VuZCBpbiB0aGUgMi4xNS41IGNoYW5nZSBsb2cuPGh0dHBzOi8vd2lr
aS5sdXN0cmUub3JnL0x1c3RyZV8yLjE1LjVfQ2hhbmdlbG9nPg0KDQpUaGVyZSBhcmUgdGhlIGZv
bGxvd2luZyBub3RhYmxlIGVuaGFuY2VtZW50cyBvdmVyIDIuMTUuNDoNCg0KUkhFTCA4LjEwIGlz
IG5vdyBzdXBwb3J0ZWQgZm9yIHNlcnZlcnMgYW5kIGNsaWVudHMgIChMVS0xNzQwMjxodHRwczov
L2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTc0MDI+KS4NCg0KUkhFTCA5LjQgaXMgbm93
IHN1cHBvcnRlZCBmb3IgY2xpZW50cyAgIChMVS0xNzQwNDxodHRwczovL2ppcmEud2hhbWNsb3Vk
LmNvbS9icm93c2UvTFUtMTcyNzQ+KQ0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQgaW4g
dGhlIGlzc3VlIHRyYWNraW5nIHN5c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS8+Lg0K
DQpUaGFua3MgdG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlv
biBvZiB0aGlzIHJlbGVhc2UuDQoNClRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgYmUgMi4xNS42
DQoNCg==

--_000_4399F0EA461B44119100A230877006F5whamcloudcom_
Content-Type: text/html; charset="utf-8"
Content-ID: <A492593E879BCE468730DC351F5A7502@namprd19.prod.outlook.com>
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
b2xvcjojMDU2M0MxOw0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0Kc3Bhbi5hcHBsZS1j
b252ZXJ0ZWQtc3BhY2UNCgl7bXNvLXN0eWxlLW5hbWU6YXBwbGUtY29udmVydGVkLXNwYWNlO30N
Ci5Nc29DaHBEZWZhdWx0DQoJe21zby1zdHlsZS10eXBlOmV4cG9ydC1vbmx5Ow0KCWZvbnQtc2l6
ZToxMC4wcHQ7DQoJbXNvLWxpZ2F0dXJlczpub25lO30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtz
aXplOjguNWluIDExLjBpbjsNCgltYXJnaW46MS4waW4gMS4waW4gMS4waW4gMS4waW47fQ0KZGl2
LldvcmRTZWN0aW9uMQ0KCXtwYWdlOldvcmRTZWN0aW9uMTt9DQotLT48L3N0eWxlPg0KPC9oZWFk
Pg0KPGJvZHkgbGFuZz0iRU4tVVMiIGxpbms9IiMwNTYzQzEiIHZsaW5rPSIjOTU0RjcyIiBzdHls
ZT0id29yZC13cmFwOmJyZWFrLXdvcmQiPg0KPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24xIj4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+V2UgYXJlIHBsZWFz
ZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTwvc3Bhbj41PHNwYW4gc3R5bGU9ImNv
bG9yOmJsYWNrIj4uPC9zcGFuPjU8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiBSZWxlYXNlIGhh
cyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yJm5ic3A7PC9zcGFuPjxhIGhy
ZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUt
Mi4xNS41LyI+ZG93bmxvYWQ8L2E+PGEgaHJlZj0iaHR0cHM6Ly9kb3dubG9hZHMuaHBkZC5pbnRl
bC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xMS4wLyI+Jm5ic3A7PC9hPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+Lg0KIFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbTwvc3Bh
bj48YSBocmVmPSJodHRwczovL2dpdC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNl
LmdpdDthPWNvbW1pdDtoPTIxOTIxZmIxMTFiMjgyMjM4MjhkNmJlZDMzNzc4MzE0MjlkMGQ3ZGUi
PiZuYnNwO2dpdDwvYT48c3BhbiBsYW5nPSJFTi1DQSI+PG86cD48L286cD48L3NwYW4+PC9wPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3Nw
YW4+PHNwYW4gbGFuZz0iRU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJN
c29Ob3JtYWwiIHN0eWxlPSJtYXJnaW4tcmlnaHQ6LjVpbiI+PHNwYW4gc3R5bGU9ImNvbG9yOmJs
YWNrIj5EZXRhaWxzIG9mIGNoYW5nZXMgc2luY2UmbmJzcDs8L3NwYW4+PGEgaHJlZj0iaHR0cHM6
Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTUuNF9DaGFuZ2Vsb2ciIHRpdGxlPSJodHRwczov
L3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4xMi44X0NoYW5nZWxvZyI+PHNwYW4gc3R5bGU9ImNv
bG9yOndpbmRvd3RleHQiPjIuMTUuNDwvc3Bhbj48L2E+PHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZl
cnRlZC1zcGFjZSI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PC9zcGFu
PjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+Y2FuDQogYmUgZm91bmQgaW4gdGhlJm5ic3A7PC9z
cGFuPjxhIGhyZWY9Imh0dHBzOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjE1LjVfQ2hhbmdl
bG9nIj48c3BhbiBzdHlsZT0iY29sb3I6d2luZG93dGV4dCI+Mi4xNS41IGNoYW5nZSBsb2cuPC9z
cGFuPjwvYT48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6
YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxl
PSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3Jw
aGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6
ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2lu
ZzowcHgiPg0KPHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFu
Zz0iRU4tQ0EiIHN0eWxlPSJjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAg
Y2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12
YXJpYW50LWNhcHM6IG5vcm1hbDtvcnBoYW5zOiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dz
OiBhdXRvOy13ZWJraXQtdGV4dC1zaXplLWFkanVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tl
LXdpZHRoOiAwcHg7d29yZC1zcGFjaW5nOjBweCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2si
PlRoZXJlIDwvc3Bhbj5hcmU8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiB0aGUgZm9sbG93aW5n
IG5vdGFibGUgZW5oYW5jZW1lbnRzIG92ZXIgMi4xNS48L3NwYW4+NDxzcGFuIHN0eWxlPSJjb2xv
cjpibGFjayI+Ojwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImNvbG9yOmJsYWNrIj48
bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHlsZT0iY2FyZXQt
Y29sb3I6IHJnYigwLCAwLCAwKTtmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsO29ycGhhbnM6IGF1
dG87dGV4dC1hbGlnbjpzdGFydDt3aWRvd3M6IGF1dG87LXdlYmtpdC10ZXh0LXNpemUtYWRqdXN0
OiBhdXRvOy13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDt3b3JkLXNwYWNpbmc6MHB4Ij4N
CjxiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjaztiYWNrZ3JvdW5kOndoaXRlIj4mbmJzcDs8L3Nw
YW4+PC9iPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+
PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdi
KDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFs
aWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdl
YmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPGI+PHNwYW4g
c3R5bGU9ImNvbG9yOmJsYWNrO2JhY2tncm91bmQ6d2hpdGUiPlJIRUwgOC4xMCZuYnNwOzwvc3Bh
bj48L2I+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrO2JhY2tncm91bmQ6d2hpdGUiPmlzIG5vdyBz
dXBwb3J0ZWQgZm9yIHNlcnZlcnMgYW5kIGNsaWVudHM8c3BhbiBjbGFzcz0iYXBwbGUtY29udmVy
dGVkLXNwYWNlIj4mbmJzcDs8L3NwYW4+PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+
Jm5ic3A7KDwvc3Bhbj48YSBocmVmPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2Uv
TFUtMTc0MDIiIHRpdGxlPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTU3
OTUiPjxzcGFuIHN0eWxlPSJjb2xvcjp3aW5kb3d0ZXh0Ij5MVS0xNzQwMjwvc3Bhbj48L2E+PHNw
YW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4pLiZuYnNwOzwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIg
c3R5bGU9ImNvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNv
Tm9ybWFsIiBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTtmb250LXZhcmlhbnQtY2Fw
czogbm9ybWFsO29ycGhhbnM6IGF1dG87dGV4dC1hbGlnbjpzdGFydDt3aWRvd3M6IGF1dG87LXdl
YmtpdC10ZXh0LXNpemUtYWRqdXN0OiBhdXRvOy13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBw
eDt3b3JkLXNwYWNpbmc6MHB4Ij4NCjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iZm9udC1zaXpl
OjE0LjBwdDtjb2xvcjpibGFjayI+Jm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHls
ZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3Jt
YWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBu
b3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0
LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dv
cmQtc3BhY2luZzowcHgiPg0KPGI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj5SSEVMIDkuPC9z
cGFuPjQ8L2I+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4gPHNwYW4gc3R5bGU9ImJhY2tncm91
bmQ6d2hpdGUiPg0KaXMgbm93IHN1cHBvcnRlZCBmb3IgY2xpZW50czxzcGFuIGNsYXNzPSJhcHBs
ZS1jb252ZXJ0ZWQtc3BhY2UiPiZuYnNwOzwvc3Bhbj48L3NwYW4+Jm5ic3A7ICg8L3NwYW4+PGEg
aHJlZj0iaHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTE3Mjc0Ij48c3BhbiBz
dHlsZT0iY29sb3I6d2luZG93dGV4dCI+TFUtMTc0MDQ8L3NwYW4+PC9hPjxzcGFuIHN0eWxlPSJj
b2xvcjpibGFjayI+KTwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5n
PSJFTi1DQSIgc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQiPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFu
PjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+UGxl
YXNlIGxvZyBhbnkgaXNzdWVzIGZvdW5kIGluIHRoZSZuYnNwOzwvc3Bhbj48YSBocmVmPSJodHRw
czovL2ppcmEud2hhbWNsb3VkLmNvbS8iPjxzcGFuIHN0eWxlPSJjb2xvcjpwdXJwbGUiPmlzc3Vl
IHRyYWNraW5nIHN5c3RlbTwvc3Bhbj48L2E+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4uPC9z
cGFuPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9z
cGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAs
IDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWdu
OnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtp
dC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPHNwYW4gc3R5bGU9
ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0eWxlPSJjb2xv
cjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIgc3R5
bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12YXJpYW50LWNhcHM6IG5vcm1hbDtv
cnBoYW5zOiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dzOiBhdXRvOy13ZWJraXQtdGV4dC1z
aXplLWFkanVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7d29yZC1zcGFj
aW5nOjBweCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlRoYW5rcyB0byBhbGwgdGhvc2Ug
d2hvIGhhdmUgY29udHJpYnV0ZWQgdG8gdGhlIGNyZWF0aW9uIG9mIHRoaXMgcmVsZWFzZS48L3Nw
YW4+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0eWxlPSJjb2xvcjpibGFjayI+PG86cD48L286cD48L3Nw
YW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwg
MCwgMCk7Zm9udC12YXJpYW50LWNhcHM6IG5vcm1hbDtvcnBoYW5zOiBhdXRvO3RleHQtYWxpZ246
c3RhcnQ7d2lkb3dzOiBhdXRvOy13ZWJraXQtdGV4dC1zaXplLWFkanVzdDogYXV0bzstd2Via2l0
LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7d29yZC1zcGFjaW5nOjBweCI+DQo8c3BhbiBzdHlsZT0i
Y29sb3I6YmxhY2siPiZuYnNwOzwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImNvbG9y
OmJsYWNrIj48bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHls
ZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTtmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsO29y
cGhhbnM6IGF1dG87dGV4dC1hbGlnbjpzdGFydDt3aWRvd3M6IGF1dG87LXdlYmtpdC10ZXh0LXNp
emUtYWRqdXN0OiBhdXRvOy13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDt3b3JkLXNwYWNp
bmc6MHB4Ij4NCjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+VGhlIG5leHQgTFRTIHJlbGVhc2Ug
d2lsbCBiZSAyLjE1Ljwvc3Bhbj42PHNwYW4gbGFuZz0iRU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFu
PjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPiZuYnNw
OzwvbzpwPjwvc3Bhbj48L3A+DQo8L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--_000_4399F0EA461B44119100A230877006F5whamcloudcom_--

--===============3657850854534505137==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3657850854534505137==--
