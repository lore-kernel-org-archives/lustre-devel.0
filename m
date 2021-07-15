Return-Path: <SRS0=9rKO=MH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_KAM_HTML_FONT_INVALID autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1191CC47E48
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Jul 2021 15:55:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C0E40613BB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Jul 2021 15:55:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E40613BB
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 88EB521F277;
	Thu, 15 Jul 2021 08:54:59 -0700 (PDT)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com
 (mail-bn7nam10on2059.outbound.protection.outlook.com [40.107.92.59])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3E6FE201119;
 Thu, 15 Jul 2021 08:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=KqkMR4SiaCkM5N9ZjmmCZ/ewOZ68mxd4Vr7qCePI2AUMH5jC7wiE2GidZyDeV6GPfwBbKeWNQq4CV+JppmvAziiwYCxAoQ6sNPQW/jaM9i7+I/njF7lIHnow3udJfIViIIbEsPd9o9K+pjLNAEA2MoUvFVNHivOIU7zsPD3/ze3xEMHrFMpR5BAe/nO+kk9+zbNZkxuXH1y2aZW5tpjUdoJ2/FNkMNxP0CM6bkmKH65fuYWheme39MdCwBZ4dLTMIIiuMEXocviPe9PuzR0gQWlurIGboMjuaDk6+3TN9AXYudGm3Q8iuQKJlmyV7+O8sMLmy5fVyaaiL6+Y8SQRew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5sqvLJH5RUITpDVpfbwlMkYSKDLQg3ZuRyx9tBGELvQ=;
 b=PXJCvdU0gDuCWC95SfAa3Y2GZ9hmMlKTvHC3CmjvufU2HHIt9DX1wniuvhORYOvLE/Oa4ccTzfzC9dbPqDDvTBakmvDmDVS4hFoEpg9phahLGkti5WkdWQInWJny1I9EGIOUwtlfO9DirhOl+GeOvdsYeZ9zejgUEjkWh9z7br8SVE5uO4FlIugFK6YnkZpQbOGFRYdgmKsspH2T2h+lFLV3Yw9hmMrU1Wd9ZuG7ggJEMUewAj5FJBRf9ceETVQj7LYoALAuorGWlUQwiyyXW2AbulCXIyx69aQ+vEzdSFbWF9KLyGdclUgG4SAGsd5JNIuol8k5GUldmfGWlyzGDw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5sqvLJH5RUITpDVpfbwlMkYSKDLQg3ZuRyx9tBGELvQ=;
 b=1Y3j4MmA7VjEITLiClG23wKycTFgSwEQhJyvOR8zDbl/5w2JneEi2BDKd2fXvuOlcmNTAZsxcD7R29jU7tRZWmlFJpSKZoR+5pF/zqtZAq6zZYlZMnXNxyVHL5ePe5t5cLCSQGPeZnfSr4X+1BY0Q1fj8sOWHfcRiTEFPTMBcMc=
Received: from MW3PR19MB4220.namprd19.prod.outlook.com (2603:10b6:303:45::24)
 by MWHPR19MB1360.namprd19.prod.outlook.com (2603:10b6:300:c7::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4308.22; Thu, 15 Jul
 2021 15:54:46 +0000
Received: from MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::4911:3d9b:2e20:e0d8]) by MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::4911:3d9b:2e20:e0d8%3]) with mapi id 15.20.4331.023; Thu, 15 Jul 2021
 15:54:45 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.12.7 released
Thread-Index: AQHXd/1Bu+Q8kbvgmkWug3bTqQIPzQ==
Date: Thu, 15 Jul 2021 15:54:45 +0000
Message-ID: <ECD6CD9D-9F4A-47A2-A147-C41A2F3ADEA4@ddn.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.10.1b.201012
authentication-results: lists.lustre.org; dkim=none (message not signed)
 header.d=none;lists.lustre.org; dmarc=none action=none
 header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fe4818af-8c25-4a1d-eb94-08d947a8de51
x-ms-traffictypediagnostic: MWHPR19MB1360:
x-microsoft-antispam-prvs: <MWHPR19MB136063B22CCC2F108B362B05DA129@MWHPR19MB1360.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: cUE9QhRxhUAaaLZ6oq8iTEREyEJ5r7OACr9qJh3lGxwEtjwSL3QDaQBWCAHEj+9+MpTbtRvzPIRHVSgIv2u/9EUMsVO0AS2w3gHzkM3HT013SZC97srKJsPiakYx+nv5nvnPbx4ZYsmegDgck4aPyzRPKv7/6CAswHfG3Ga0LldNmNB55v3FPLW0w+oEhjtBf+LyryPR3GWSMhTobJIkymR9coA8F1p849FxIBmzwfx6d8DyAECtwwwnamNcowRxqQEh7oV96PgQ3pD/Sw8vv7B18H1LHVDhn9Ld4R3uIQkYVekvC6WYQGwUxXk8jYhuABchbntkab2C+6zbjTEzEFYpIcwGemWVqOO/KvYPdGwX2W22f0Y+iwmUQi+w4v3qd8VyLhnR/f6d2NAwXH0p4noD3wD2svcdzt9M6ChmCtA/vkbiSTFDsZ6wJesUOgDr/PWqSFLKOyvGSNIqd2yV0Wnv+GvZFe7jMQ32FtZWDWUgZqVmF18+Q69NlS/HtZhmXJjZJORcb8LVlSCaZMqofEn8J6JaN6Zwcb15X5XsgDbLAPMAIUnK1zGagFCbdwNY9mwajSG6UmA2dDH/gVMMmTnPGuav9TnSo08mwfZgeAQkpVQkaTOplnKUQyPq4haLrObsxj2HiSRkNujBvEWfaXTZW6N1XN3hYhn3JHGwUGpJSdAiOV40SbEQFSsK3KHrW0vzZ78ynBcI3M3N9la2UYHoHO/guL0pb03xcukiScN8oyK07P8hDaZrpIjm8fIRzktnSWmYjRdEATFbUYjm6mmtej3FHmM0tEQPG+VJ+bXLbSu9Q3xsJDcNEtrzsqPsaRt9+lRvS/JQfnU+77bBoiZs88PBNuv4Wy1kmSWUZz0=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR19MB4220.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(39850400004)(396003)(136003)(366004)(376002)(346002)(83380400001)(6506007)(8936002)(5660300002)(9686003)(8676002)(38100700002)(166002)(122000001)(6486002)(36756003)(6512007)(4744005)(7116003)(64756008)(186003)(33656002)(86362001)(66946007)(76116006)(66556008)(66446008)(71200400001)(110136005)(66476007)(316002)(2906002)(478600001)(13693001)(38070700004);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?bXVVZkYyTkhxOVlYcUwzK1Rvd2lYbzNRTnpxSGkxa1M4dGM0OG9mTkZpSFl5?=
 =?utf-8?B?QWRxYzY3dW9uaWZscDJlV21yblJrWjRvYzAzbklEQlRHZytzUTYxa01UU0J2?=
 =?utf-8?B?bGx5eGY3R0craUhrbDB6US9BTVp0dnJURE96NnpVcWMxYm5zYmZiVC8zaEFD?=
 =?utf-8?B?RnNHTmlTTTBLVC9SUkpYVFhyUWkrLytwcGtRdmxYOE5BeEk2WVptSGpub1hy?=
 =?utf-8?B?RmkrMm8zV2lSZWhaMEo5ZWsrblBxaXVsV1pTUTZHSWVROXhISkV6c1lRdVF5?=
 =?utf-8?B?cnlSTm9teERFSkhzL2NUR0dHbU90L1dmZ2JkS2NTcERSRGZiZllXQUdabFpy?=
 =?utf-8?B?bzN1TUdSdkk2aHNlYW4wbk51Q21OOGtBQzZJdU55aXZ0UkRUUUF0TjVjQUlM?=
 =?utf-8?B?eWFSQVNBYzFDek1OWUE2S1Z3M2tUV0ZPRXVkblF1KzZWdGVnMytudDd0cXAv?=
 =?utf-8?B?aG1kcGc5SjJMVDNvLzlPbkI5ZmxOVUo1b0dMb1BxYjRQY25EczlRQ3htMysy?=
 =?utf-8?B?SmtUZEE4MWdMMElBWG9EeVNyQytVWDhVckFDUDI3TnBpRWR6RkZISGhpb2pq?=
 =?utf-8?B?NTNqNUphNlZMdWdjeUdLZ1l2V2pCU3M5VU52RlJMYS96T1NPY25BTTdrdXZo?=
 =?utf-8?B?ZTFDdVdabE52bE5Ubmljb0lOQWV6V08xNE54VzVBTWdQUTdxWEh6QkJtUm8y?=
 =?utf-8?B?MUxWOTNKNnF2RFc4bytqdlB4ZWJnZjYyM01oampmTlJocWhManlxOFhzNkFM?=
 =?utf-8?B?eHFKSVlTTVduZ2ZWQ0ZqT1ZNZ0c5cHRlNEIwcnZmYXFQdHBxdjhoQXB6T2xx?=
 =?utf-8?B?K0szTlpPMUV2cUVwRnBvTjArY3dPR1BXaENIei9HYjNaVHFFYW5STk1qdDJF?=
 =?utf-8?B?VG1CUEJBZjJCN25kWWprOStnVWVoMG0wZDliNG9NaG1ndGlralpLcnFzMDNv?=
 =?utf-8?B?SFpNaXVpd1NKam5YUlkzQ3RQRGMxbms5SHVxQ0FEdWJhOWc0N2FvMFh3MmR3?=
 =?utf-8?B?VVlBS0FVNTA5L3VVVUVDQ1B0aUlxZUJ2NmE2NkFaQXBQQXJCQmdHNXErc1Fx?=
 =?utf-8?B?eEVaOHg5Vk1Lc21oMDFOdHlkSENJSjBoN09MYXhsM05GTGJjV3A0VWgrWWow?=
 =?utf-8?B?OGZOamRRU3VGTHFYMkVlUitNZjZUOEJvUSs1dlFxdjUxNXVTSmdSalFBQTlj?=
 =?utf-8?B?N3c1WlBKRlhnZ2Nic1hPN1VqUWdlTUx2MmxQRUtrcml2Ny9ibkhvSWJwdFpr?=
 =?utf-8?B?T2cwb1FyL2ZSbHRyYlA3NjdqbDcvSHprMUhiV0pHbzc5c2MzT3llMnBhODFl?=
 =?utf-8?B?dkJRUCtEZ1FNcWxCaGM2QnZaK2VoM2Rzd2RwL0V1MGNtcnhMTncrUGR3MGlu?=
 =?utf-8?B?RGtPZWN0NXNJVVl0aHhkVDh0WE05amtNTDVvQzEwSkU5MzhoQnk2OHF1YTNX?=
 =?utf-8?B?ZkFmcWVkUWU1REx3VTZiOUdLdVI4RE16UmNQV3UxSzhZM09BZUVmcFhxcytu?=
 =?utf-8?B?dnZrMDc5WVVwWXZ2T0Vnd2YrQmNXVFhyRlV0MmFHbURjS1R2TE1sRWpTVS8x?=
 =?utf-8?B?UUd1S05SOHFxcytDaENXUTRldkZ6d05vbU1GOUxjVUhRQzVrWW1JYVhyYVB1?=
 =?utf-8?B?RVlhMUFhdlhPSjZjWjMvMDd4VzBkODlyTEYzVi9hb0gyWTVKZ2NUVjZuOGxx?=
 =?utf-8?B?MC9WL1ZWYUdKTVE0cmdGUWs1UFBGOVlPWVJ3bW9Zb053czFWa3ovam5DWU1h?=
 =?utf-8?B?WXV4a2R5QWFETm9WbVV5S2V4NFJNa3YwRVM1MG8yaTdWNGY3Sk1zR0xnZlBa?=
 =?utf-8?B?S3lBS1NtSytmVkM0OHFJRkZHR3RxYVUvZ2hRajlzdmtmbFJwU2NFTFRUYXlF?=
 =?utf-8?Q?b7GhUtVgkKBq2?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR19MB4220.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fe4818af-8c25-4a1d-eb94-08d947a8de51
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Jul 2021 15:54:45.7991 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Z7XWb044Sd9wJsn0ODu1EO9TlP9nlJ2h8/oaS58bx7pp+lPEsgir1uo+xtD7puCj
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR19MB1360
Subject: [lustre-devel] Lustre 2.12.7 released
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
Content-Type: multipart/mixed; boundary="===============3589145087232520495=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3589145087232520495==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_ECD6CD9D9F4A47A2A147C41A2F3ADEA4ddncom_"

--_000_ECD6CD9D9F4A47A2A147C41A2F3ADEA4ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTIuNyBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkLjxodHRw
czovL2Rvd25sb2Fkcy53aGFtY2xvdWQuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIuMTIuNy8+
IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbSBnaXQgLjxodHRwczovL2dpdC53aGFt
Y2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPTYwMzBkMGNmYjE1
YmZhNGNmZDdhYWVlNGUzYzJhMzQ3NDY0MjRkZDI+DQoNCkRldGFpbHMgb2YgY2hhbmdlcyBzaW5j
ZSAyLjEyLjY8aHR0cDovL3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4xMi42X0NoYW5nZWxvZz4g
Y2FuIGJlIGZvdW5kIGluIHRoZSAyLjEyLjcgY2hhbmdlIGxvZy48aHR0cDovL3dpa2kubHVzdHJl
Lm9yZy9MdXN0cmVfMi4xMi43X0NoYW5nZWxvZz4NCg0KVGhlcmUgaXMgdGhlIGZvbGxvd2luZyBu
b3RhYmxlIGVuaGFuY2VtZW50IG92ZXIgMi4xMi42Og0KDQpSSEVMIDguNCBpcyBub3cgc3VwcG9y
dGVkIGZvciBjbGllbnRzICAoTFUtMTQ2OTA8aHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJv
d3NlL0xVLTE0NjkwPikuDQoNClBsZWFzZSBsb2cgYW55IGlzc3VlcyBmb3VuZCBpbiB0aGUgaXNz
dWUgdHJhY2tpbmcgc3lzdGVtPGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tLz4uDQoNClRoYW5r
cyB0byBhbGwgdGhvc2Ugd2hvIGhhdmUgY29udHJpYnV0ZWQgdG8gdGhlIGNyZWF0aW9uIG9mIHRo
aXMgcmVsZWFzZS4NCg0KVGhlIG5leHQgTFRTIHJlbGVhc2Ugd2lsbCBiZSAyLjEyLjgNCg0K

--_000_ECD6CD9D9F4A47A2A147C41A2F3ADEA4ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <F235788F1192634A938EDC7C63EEC159@namprd19.prod.outlook.com>
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
b250LXN0eWxlOm5vcm1hbDt9DQouTXNvQ2hwRGVmYXVsdA0KCXttc28tc3R5bGUtdHlwZTpleHBv
cnQtb25seTsNCglmb250LXNpemU6MTAuMHB0O30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtzaXpl
OjYxMi4wcHQgNzkyLjBwdDsNCgltYXJnaW46NzIuMHB0IDcyLjBwdCA3Mi4wcHQgNzIuMHB0O30N
CmRpdi5Xb3JkU2VjdGlvbjENCgl7cGFnZTpXb3JkU2VjdGlvbjE7fQ0KLS0+PC9zdHlsZT4NCjwv
aGVhZD4NCjxib2R5IGxhbmc9IkVOLUNBIiBsaW5rPSIjMDU2M0MxIiB2bGluaz0iIzk1NEY3MiI+
DQo8ZGl2IGNsYXNzPSJXb3JkU2VjdGlvbjEiPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4g
bGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5XZSBhcmUgcGxlYXNlZCB0byBh
bm5vdW5jZSB0aGF0IHRoZSZuYnNwOzxiPkx1c3RyZSAyLjEyLjc8c3BhbiBjbGFzcz0iYXBwbGUt
Y29udmVydGVkLXNwYWNlIj4mbmJzcDs8L3NwYW4+UmVsZWFzZSZuYnNwOzwvYj5oYXMgYmVlbiBk
ZWNsYXJlZCBHQSBhbmQgaXMgYXZhaWxhYmxlIGZvcg0KPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8v
ZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xMi43LyI+PHNw
YW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5kb3dubG9hZC48L3NwYW4+
PC9hPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+IFlvdSBjYW4g
YWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbQ0KPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vZ2l0Lndo
YW1jbG91ZC5jb20vP3A9ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0O2E9Y29tbWl0O2g9NjAzMGQwY2Zi
MTViZmE0Y2ZkN2FhZWU0ZTNjMmEzNDc0NjQyNGRkMiI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxl
PSJmb250LXNpemU6MTIuMHB0Ij5naXQmbmJzcDsuPC9zcGFuPjwvYT48L3A+DQo8cCBjbGFzcz0i
TXNvTm9ybWFsIiBzdHlsZT0ibWFyZ2luLXJpZ2h0OjM2LjBwdCI+Jm5ic3A7PC9wPg0KPHAgY2xh
c3M9Ik1zb05vcm1hbCIgc3R5bGU9Im1hcmdpbi1yaWdodDozNi4wcHQiPjxzcGFuIGxhbmc9IkVO
LVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+RGV0YWlscyBvZiBjaGFuZ2VzIHNpbmNlJm5i
c3A7PC9zcGFuPjxhIGhyZWY9Imh0dHA6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTIuNl9D
aGFuZ2Vsb2ciPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdDtjb2xv
cjp3aW5kb3d0ZXh0Ij4yLjEyLjY8L3NwYW4+PC9hPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0i
Zm9udC1zaXplOjEyLjBwdCI+DQogY2FuIGJlIGZvdW5kIGluIHRoZSZuYnNwOzwvc3Bhbj48YSBo
cmVmPSJodHRwOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjEyLjdfQ2hhbmdlbG9nIj48c3Bh
biBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7Y29sb3I6d2luZG93dGV4dCI+
Mi4xMi43IGNoYW5nZSBsb2cuPC9zcGFuPjwvYT48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48
c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPiZuYnNwOzwvc3Bhbj48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQt
c2l6ZToxMi4wcHQiPlRoZXJlIGlzIHRoZSBmb2xsb3dpbmcgbm90YWJsZSBlbmhhbmNlbWVudCBv
dmVyIDIuMTIuNjo8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+PHNwYW4gbGFu
Zz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2JhY2tncm91bmQ6d2hpdGUiPiZuYnNw
Ozwvc3Bhbj48L2I+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+PHNwYW4gbGFuZz0iRU4t
VVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2JhY2tncm91bmQ6d2hpdGUiPlJIRUwgOC40Jm5i
c3A7PC9zcGFuPjwvYj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7
YmFja2dyb3VuZDp3aGl0ZSI+aXMgbm93IHN1cHBvcnRlZCBmb3IgY2xpZW50czxzcGFuIGNsYXNz
PSJhcHBsZS1jb252ZXJ0ZWQtc3BhY2UiPiZuYnNwOzwvc3Bhbj48L3NwYW4+PHNwYW4gbGFuZz0i
RU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij4mbmJzcDsoPC9zcGFuPjxhIGhyZWY9Imh0
dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0xNDY5MCI+PHNwYW4gbGFuZz0iRU4t
VVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2NvbG9yOndpbmRvd3RleHQiPkxVLTE0NjkwPC9z
cGFuPjwvYT48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPikuJm5i
c3A7PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJmb250LXNp
emU6MTQuMHB0Ij4mbmJzcDs8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4g
bGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5QbGVhc2UgbG9nIGFueSBpc3N1
ZXMgZm91bmQgaW4gdGhlJm5ic3A7PC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFtY2xv
dWQuY29tLyI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2NvbG9y
OnB1cnBsZSI+aXNzdWUgdHJhY2tpbmcgc3lzdGVtPC9zcGFuPjwvYT48c3BhbiBsYW5nPSJFTi1V
UyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPi48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05v
cm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij4mbmJzcDs8
L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxl
PSJmb250LXNpemU6MTIuMHB0Ij5UaGFua3MgdG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1
dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlzIHJlbGVhc2UuPC9zcGFuPjwvcD4NCjxwIGNsYXNz
PSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+
Jm5ic3A7PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVT
IiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+VGhlIG5leHQgTFRTIHJlbGVhc2Ugd2lsbCBiZSAy
LjEyLjg8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMi
PiZuYnNwOzwvc3Bhbj48L3A+DQo8L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--_000_ECD6CD9D9F4A47A2A147C41A2F3ADEA4ddncom_--

--===============3589145087232520495==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3589145087232520495==--
