Return-Path: <SRS0=9sss=FO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_KAM_HTML_FONT_INVALID,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 705C2C4361B
	for <lustre-devel@archiver.kernel.org>; Thu, 10 Dec 2020 00:47:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2B7F322D5B
	for <lustre-devel@archiver.kernel.org>; Thu, 10 Dec 2020 00:47:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B7F322D5B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4C01E21FDAB;
	Wed,  9 Dec 2020 16:47:17 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11on2055.outbound.protection.outlook.com [40.107.236.55])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 643DC21FD32;
 Wed,  9 Dec 2020 16:47:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ILu7kZwD6OctaIWzoZ5jnDAbrXEplMdDU46bfDvBp5GqllE+1XVgUqEE0obHqJzUmnx5dkozQUgfc5YYWLbBvWWStvS8XPC3SeEiiyzOq/YeLkZxUz99AVltcr0iB5QpslnWc/h52t0/RwNK/KaFLpsXywzC086r30ob75gxNPCL5WfZIDdit0QXx2T5Bej0Kf3ICz3xgaJcSjtKDLV3kLVAdCkeF07wG87KV0VmbfAXSSqqE6pSif/cQiWuDAjsrARB3l7eZL4XxIbEM9OqO5+5GNg5tW+rBfSWS8PWJky4INj80xWizeJxNUgRYtPEkbcZCMtZdXRtHg2nJ1iitA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qvUTUbMaJRp1hjHRrZIiGgKpKsSS4UEkBzIlO2ohs10=;
 b=gmXb+q1S5gE5DqDDeJ++J4zoROqS1cnONlMmDjRk9jVFCYmalc2VSewQ+OaeRDBsWeo4hY9SKGE1ZTcd6JqjdkcS+7g7/EkDMq0C04oQgLoZr3Jtb8lQs31IT6jw4rzjo+geY06ZS106E+XVVUf9goFMHRkE1wvLtRvm6sUE08QHsqIQNSB9hy7Lfj/QMow+GJWAZjasxk2kyoZSLfEfdl+B1ob+xspE6cIaDZ3HmmUuQ99l63gbpBEaZELONH7/LH8uI96SiwFCMDcIxOUoMdi0QHSLGZ2fOunALnmSKeNGTLJfS7VORm1302vkZGBTD4qGG0kZ/OT89qZ1D9xzUA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qvUTUbMaJRp1hjHRrZIiGgKpKsSS4UEkBzIlO2ohs10=;
 b=qsS1/9eZ83TOz33jaH59S6aoE9ZBKABjpJbOjcqdlD9IjJQMYPghcEODm6ij3dE80PZf8QznAFhmlys1v5gZf8mLzlFpF+qlA9wWXx88JlkVsku6hn3aYSyRUcWg51cQ1wofrf321Zy21pZOQuIOFgJyWGDMRlfLq9fHaOEqvMM=
Received: from MW3PR19MB4220.namprd19.prod.outlook.com (2603:10b6:303:45::24)
 by MW2PR1901MB2169.namprd19.prod.outlook.com (2603:10b6:302:f::29)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3632.21; Thu, 10 Dec
 2020 00:47:09 +0000
Received: from MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::e4f2:853f:42c1:ae4a]) by MW3PR19MB4220.namprd19.prod.outlook.com
 ([fe80::e4f2:853f:42c1:ae4a%4]) with mapi id 15.20.3632.021; Thu, 10 Dec 2020
 00:47:09 +0000
From: Peter Jones <pjones@whamcloud.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.12.6 released
Thread-Index: AQHWzo39MxhlQeeqJ02FbtCynqmwBQ==
Date: Thu, 10 Dec 2020 00:47:09 +0000
Message-ID: <3C33ED36-B55C-4A01-88F6-E5B28D1C2F3A@ddn.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.10.1b.201012
authentication-results: lists.lustre.org; dkim=none (message not signed)
 header.d=none;lists.lustre.org; dmarc=none action=none
 header.from=whamcloud.com;
x-originating-ip: [2001:569:bc54:b000:4049:65c9:4969:2e1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aa30d495-fb34-4915-1af5-08d89ca52033
x-ms-traffictypediagnostic: MW2PR1901MB2169:
x-microsoft-antispam-prvs: <MW2PR1901MB216953813123EB518D3B6933DACB0@MW2PR1901MB2169.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: NmsiazZR/5YqWOg4k/BsrtWYyEL0msBEgvSrdKhRtMcJOqvaW+LH2OAASvhv1ZxXnE2Q26rzd55jVapsaW1fT4FpihuIGE9ld9ac0BuezIrdz2OGMH2Z23l9ZARXBGogyWkyoH5sMInfbpfzlDBLpeHS2QtfwUoXtbkWFOitCDhwJHIStRv1fWPjKn8A+V4G5JkvIPnSO2sVjNapQt23rDv9biKTaP61TIZ36wEMt/Z068HyHDT8A5MERZxvFlEysItlLflHzJdf+S3fTpQOmd/bgv1ndEdnQtYC7Ue3ViORwTAfpmdb1n7wXOaC/84kz+imMZg+5vm7wpxt1hg8RZY62iGPFebgFcCifyxIXBVyx1EWlQWv/rf8GhGVwY5VQQLG5EB0nEuwsNzpwHnS9K2/FXLt7cyiynrABmljxHNYTZy90y318Grydww9rOBJnWeFltRqFxVXkl1FBZu96Q==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR19MB4220.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(346002)(136003)(376002)(366004)(71200400001)(9686003)(110136005)(7116003)(66446008)(86362001)(186003)(66946007)(76116006)(6512007)(6506007)(66476007)(36756003)(508600001)(6486002)(64756008)(5660300002)(8936002)(8676002)(4744005)(166002)(66556008)(2906002)(83380400001)(33656002)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?utf-8?B?WWxxVVJmK01pa2xBdEtlOUpwOExzdVFlRlYyNzNwNm0xc005U1h2aGpaZDQ5?=
 =?utf-8?B?ZGRXdkl5d0Q1TnVuOEJHaWc3SWsyTlNuM3VNQnpadExsZlI2Nzd3R2FSQlhr?=
 =?utf-8?B?NEhYam9PQjViY3BGT284UlhtZWtTKzhSNFdEbkN6UGZXRys0eWQvSlAvWEYy?=
 =?utf-8?B?aWNMckt0MXhTa3lxdkFud3Z5QmpXRWZXdGovSlJia0xDVEc0WVdZcUN5Vjh4?=
 =?utf-8?B?cHlsckhabDFYQ2ZCVXdkM0NNNElNeFVzajFrS1Z5WEZDWmM0YU5VdmwzRFJJ?=
 =?utf-8?B?SHhid2FyME15MVlwcHN4ajF5OWY5aHM5WmwxWEJSWGNwclc0eEdSRWxkZDVw?=
 =?utf-8?B?SjNiTDB0d29ScHlZUDhiOWl0Q1VZOGRzL21NdWZQTVNOVDlTaW01S2JaUnJ3?=
 =?utf-8?B?UzhKTlIzRFVBbVRpVEFxY0RoU2pjVkJkcFd3dmVQV21iZkVibXdKcmM3M005?=
 =?utf-8?B?cUxZa0paakF1aVZvY1ZLcmFvaWFFekdCNC9hUFY0T0VXR0F6amI0Qk5iSGVJ?=
 =?utf-8?B?Z1BhWlphMlBxaGt1WG5ETTJwVGZCTWpmVFBOd1AvQmZVSmdnbytPeUI0OEJE?=
 =?utf-8?B?WFFyZ2thZFRLcmpFbUx2d2dobzNUbElrL2Q4RC84U2hYSklYQSs2QnpGVzdN?=
 =?utf-8?B?L3ZpN3d0b0RrbUNYd1lpQnNpanNxYlRJak40Z0lCTHdnTEQwR0JZbGtEQlFF?=
 =?utf-8?B?cUFDRk5Gd0dNQ2pJWVc0NjhRSW51RHBQN29GQTlXbU9DYlg4V1RYNUxkQWxQ?=
 =?utf-8?B?MitQai9GdWd4WjF3S3N5MlZFcWJLSHhnTXJ2elUvcmUzNkRkYWIxNlQyNXhY?=
 =?utf-8?B?bHk4eVdUMm5WMTFRdkhHTXhBQlpMRkloV3NRRm83QlQ1YzNBbGNSNkRtMGRi?=
 =?utf-8?B?NURXOUhMbC9jTngvQ05SUW5xcDllSjRwbXZ4SSsrSUpPQnNlTzgrZUw2dDI0?=
 =?utf-8?B?QUhnTnFZem5qajFyQ3pCWUNXUzVkT0c3VkI2TXZKcnIxVWVBSUJvdEttM1p4?=
 =?utf-8?B?aEFRL0Nscm0zb0hxM1BMMEU5L3hsQThxQWkyejBVV1daSzZIUXR1amM5bHlR?=
 =?utf-8?B?LytNblFBNU94U1p4a3pwalhXQnc2NGZ5WHArNWpMZ0E4OWlUQ2RjQjY3dmZO?=
 =?utf-8?B?Q1VOOXBIRkZrMTJ4MElMbGlqRUxXNVlYLzdvTmNvUXhsejd6RnpiU2F3NE1q?=
 =?utf-8?B?Rjk2RXd2dTZaRVVOZUsyRytDY2Z6Wjd2K212SFRGTUFCdEEvdjNrUUNWNjZY?=
 =?utf-8?B?SDM0UjUwcWE4d0xxRzNmOGU5YjgwSjB3dU8vMFJ3TlNvd0VKRVd1VlZlUjFQ?=
 =?utf-8?B?NnlGWUk2VDUzNmFINHR0YzgyanlJVXdxQmxqTG4yRzJFZHkxeGJ1NWFoOE1O?=
 =?utf-8?B?S3BQN1RPajhPQmxBaVFzMWlQVGp6K21BdnpvZlZzeEdNbFRWTWJNRUdidWRa?=
 =?utf-8?Q?KRWeBqbE?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR19MB4220.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aa30d495-fb34-4915-1af5-08d89ca52033
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Dec 2020 00:47:09.5945 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: qaRCFXFF31UC1YmarUzvPe3j6xm5uJyuhYDtcJbrz5ZykOMCUXgj88DnNVH0AeXf
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW2PR1901MB2169
Subject: [lustre-devel] Lustre 2.12.6 released
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
Content-Type: multipart/mixed; boundary="===============6336409726608563911=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6336409726608563911==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_3C33ED36B55C4A0188F6E5B28D1C2F3Addncom_"

--_000_3C33ED36B55C4A0188F6E5B28D1C2F3Addncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTIuNiBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkLjxodHRw
czovL2Rvd25sb2Fkcy53aGFtY2xvdWQuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIuMTIuNi8+
IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbSBnaXQgLjxodHRwczovL2dpdC53aGFt
Y2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPWVjMzZhYmQyZjky
MmVhZjM1YmE0MTJhZmQzMzY4NzY3YjBmYjJmMjY+DQoNCkRldGFpbHMgb2YgY2hhbmdlcyBzaW5j
ZSAyLjEyLjU8aHR0cDovL3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4xMi41X0NoYW5nZWxvZz4g
Y2FuIGJlIGZvdW5kIGluIHRoZSAyLjEyLjYgY2hhbmdlIGxvZy48aHR0cDovL3dpa2kubHVzdHJl
Lm9yZy9MdXN0cmVfMi4xMi42X0NoYW5nZWxvZz4NCg0KVGhlcmUgYXJlIHRoZSBmb2xsb3dpbmcg
bm90YWJsZSBlbmhhbmNlbWVudHMgb3ZlciAyLjEyLjU6DQoNClJIRUwgNy45IGlzIG5vdyBzdXBw
b3J0ZWQgZm9yIHNlcnZlcnMgYW5kIGNsaWVudHMgIChMVS0xMzU5MCA8aHR0cHM6Ly9qaXJhLndo
YW1jbG91ZC5jb20vYnJvd3NlL0xVLTEzNTkwPiApLg0KUkhFTCA4LjMgaXMgbm93IHN1cHBvcnRl
ZCBmb3IgY2xpZW50cyAgKExVLTEzODM5PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dz
ZS9MVS0xMzgzOT4pLg0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQgaW4gdGhlIGlzc3Vl
IHRyYWNraW5nIHN5c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS8+Lg0KDQpUaGFua3Mg
dG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlz
IHJlbGVhc2UuDQoNClRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgYmUgMi4xMi43DQoNCg==

--_000_3C33ED36B55C4A0188F6E5B28D1C2F3Addncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <4542B35F6AAE3349B0320D5012391D89@namprd19.prod.outlook.com>
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
CWZvbnQtd2VpZ2h0Om5vcm1hbDsNCglmb250LXN0eWxlOm5vcm1hbDt9DQouTXNvQ2hwRGVmYXVs
dA0KCXttc28tc3R5bGUtdHlwZTpleHBvcnQtb25seTsNCglmb250LXNpemU6MTAuMHB0O30NCkBw
YWdlIFdvcmRTZWN0aW9uMQ0KCXtzaXplOjYxMi4wcHQgNzkyLjBwdDsNCgltYXJnaW46NzIuMHB0
IDcyLjBwdCA3Mi4wcHQgNzIuMHB0O30NCmRpdi5Xb3JkU2VjdGlvbjENCgl7cGFnZTpXb3JkU2Vj
dGlvbjE7fQ0KLS0+PC9zdHlsZT4NCjwvaGVhZD4NCjxib2R5IGxhbmc9IkVOLUNBIiBsaW5rPSIj
MDU2M0MxIiB2bGluaz0iIzk1NEY3MiI+DQo8ZGl2IGNsYXNzPSJXb3JkU2VjdGlvbjEiPg0KPHAg
Y2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIu
MHB0Ij5XZSBhcmUgcGxlYXNlZCB0byBhbm5vdW5jZSB0aGF0IHRoZSZuYnNwOzxiPkx1c3RyZSAy
LjEyLjY8c3BhbiBjbGFzcz0iYXBwbGUtY29udmVydGVkLXNwYWNlIj4mbmJzcDs8L3NwYW4+UmVs
ZWFzZSZuYnNwOzwvYj5oYXMgYmVlbiBkZWNsYXJlZCBHQSBhbmQgaXMgYXZhaWxhYmxlIGZvcg0K
PGEgaHJlZj0iaHR0cHM6Ly9kb3dubG9hZHMud2hhbWNsb3VkLmNvbS9wdWJsaWMvbHVzdHJlL2x1
c3RyZS0yLjEyLjYvIj5kb3dubG9hZC48L2E+IFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2Ug
ZnJvbQ0KPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vZ2l0LndoYW1jbG91ZC5jb20vP3A9ZnMvbHVz
dHJlLXJlbGVhc2UuZ2l0O2E9Y29tbWl0O2g9ZWMzNmFiZDJmOTIyZWFmMzViYTQxMmFmZDMzNjg3
NjdiMGZiMmYyNiI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5n
aXQmbmJzcDsuPC9zcGFuPjwvYT48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHlsZT0ibWFy
Z2luLXJpZ2h0OjM2LjBwdCI+Jm5ic3A7PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9
Im1hcmdpbi1yaWdodDozNi4wcHQiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXpl
OjEyLjBwdCI+RGV0YWlscyBvZiBjaGFuZ2VzIHNpbmNlJm5ic3A7PC9zcGFuPjxhIGhyZWY9Imh0
dHA6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTIuNV9DaGFuZ2Vsb2ciPjxzcGFuIGxhbmc9
IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdDtjb2xvcjp3aW5kb3d0ZXh0Ij4yLjEyLjU8
L3NwYW4+PC9hPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+DQog
Y2FuIGJlIGZvdW5kIGluIHRoZSZuYnNwOzwvc3Bhbj48YSBocmVmPSJodHRwOi8vd2lraS5sdXN0
cmUub3JnL0x1c3RyZV8yLjEyLjZfQ2hhbmdlbG9nIj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9
ImZvbnQtc2l6ZToxMi4wcHQiPjIuMTIuNiBjaGFuZ2UgbG9nLjwvc3Bhbj48L2E+PC9wPg0KPHAg
Y2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIu
MHB0Ij4mbmJzcDs8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0i
RU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5UaGVyZSBhcmUgdGhlIGZvbGxvd2luZyBu
b3RhYmxlIGVuaGFuY2VtZW50cyBvdmVyIDIuMTIuNTo8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1z
b05vcm1hbCI+PGI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2Jh
Y2tncm91bmQ6d2hpdGUiPiZuYnNwOzwvc3Bhbj48L2I+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PGI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2JhY2tncm91
bmQ6d2hpdGUiPlJIRUwgNy45Jm5ic3A7PC9zcGFuPjwvYj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5
bGU9ImZvbnQtc2l6ZToxMi4wcHQ7YmFja2dyb3VuZDp3aGl0ZSI+aXMgbm93IHN1cHBvcnRlZCBm
b3Igc2VydmVycyBhbmQgY2xpZW50czxzcGFuIGNsYXNzPSJhcHBsZS1jb252ZXJ0ZWQtc3BhY2Ui
PiZuYnNwOzwvc3Bhbj48L3NwYW4+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6
MTIuMHB0Ij4mbmJzcDsoPC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29t
L2Jyb3dzZS9MVS0xMzU5MCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIu
MHB0Ij5MVS0xMzU5MCZuYnNwOzwvc3Bhbj48L2E+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJm
b250LXNpemU6MTIuMHB0Ij4pLiZuYnNwOzwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFs
Ij48Yj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQ7YmFja2dyb3Vu
ZDp3aGl0ZSI+UkhFTCA4LjMmbmJzcDs8L3NwYW4+PC9iPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHls
ZT0iZm9udC1zaXplOjEyLjBwdDtiYWNrZ3JvdW5kOndoaXRlIj5pcyBub3cgc3VwcG9ydGVkIGZv
ciBjbGllbnRzPHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZlcnRlZC1zcGFjZSI+Jm5ic3A7PC9zcGFu
Pjwvc3Bhbj48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPiZuYnNw
Oyg8L3NwYW4+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTEz
ODM5Ij48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPkxVLTEzODM5
PC9zcGFuPjwvYT48c3BhbiBsYW5nPSJFTi1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPiku
Jm5ic3A7PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJmb250
LXNpemU6MTQuMHB0Ij4mbmJzcDs8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNw
YW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij5QbGVhc2UgbG9nIGFueSBp
c3N1ZXMgZm91bmQgaW4gdGhlJm5ic3A7PC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFt
Y2xvdWQuY29tLyI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0O2Nv
bG9yOnB1cnBsZSI+aXNzdWUgdHJhY2tpbmcgc3lzdGVtPC9zcGFuPjwvYT48c3BhbiBsYW5nPSJF
Ti1VUyIgc3R5bGU9ImZvbnQtc2l6ZToxMi4wcHQiPi48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1z
b05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0eWxlPSJmb250LXNpemU6MTIuMHB0Ij4mbmJz
cDs8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4tVVMiIHN0
eWxlPSJmb250LXNpemU6MTIuMHB0Ij5UaGFua3MgdG8gYWxsIHRob3NlIHdobyBoYXZlIGNvbnRy
aWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlzIHJlbGVhc2UuPC9zcGFuPjwvcD4NCjxwIGNs
YXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVOLVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBw
dCI+Jm5ic3A7PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIGxhbmc9IkVO
LVVTIiBzdHlsZT0iZm9udC1zaXplOjEyLjBwdCI+VGhlIG5leHQgTFRTIHJlbGVhc2Ugd2lsbCBi
ZSAyLjEyLjc8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gbGFuZz0iRU4t
VVMiPiZuYnNwOzwvc3Bhbj48L3A+DQo8L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--_000_3C33ED36B55C4A0188F6E5B28D1C2F3Addncom_--

--===============6336409726608563911==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6336409726608563911==--
