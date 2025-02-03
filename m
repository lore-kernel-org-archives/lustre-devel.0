Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9212CC02192
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 20:30:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmymH6Wk6z1xPj;
	Mon, 03 Feb 2025 12:30:07 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmymD2YS6z1wTN
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 12:30:04 -0800 (PST)
Received: from NAM04-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam04lp2043.outbound.protection.outlook.com [104.47.74.43]) by
 mx-outbound18-64.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 03 Feb 2025 20:30:00 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=HoAN2NODqyy4Cr7qR3xMKjgXMYUasA4abhBE5gBvZuNMwiMihAt1J5JqdJEMd36jNTbZ4W0vt2jx/eUD16mRfUs3zQXg9N4EpF9+0KRhouyKJNlOn69izTCN4cfoY2vFVWlbZSDu017qogbaLu1tCEOoBG81C5uCiCTeIiCihuHnEtNbgeLQXeAncJEijZ2L0XZORYlgftSltsrqOwcruMTplKMgRQU2LifKK0is3+z4JiewpqywbpDaQPB//MU8AMTnHYDQeoyOqmWSw/45O6p7xWArVbWc4xR8qWaYj9zBRjE9eBPDEgc3YIB9F9KPRvlMwTJuLcu6+hr4xV4l1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=z5J7sFwoaCy05q8FW3lKEWbL8GMwnjDOmJeQzYABdyk=;
 b=xtb1f4qa5lIdiWzD01+XDwwGF/+5hxc0H/BvRfhdsB6TwTQifDL48FKCdlEfnvNhOUb+CW0Sq696vvQxiZTMXcbk1dVQX/hKCGBQ0Cto86w3EeRXRWUyxNSQxUadQHmCJcRt9QyFdDZVgxe2iUlmaMcICzqX68RCTmdNncxaUFDAP4lvWUqxvkqEybqAabrtl3h8xdXD9Zziagt7/VU0BvKcHlk96Rtnp9iLKxTL+gVIyypYePJxjhLCmXN0qnGLPSEeRO20C5q3gN/lSxIyZUf3JDno/dJPURFaYvCSX7SxUJpAGzRLb+1Wc/Tgu23w5TftSekjivqL40rVcwiY9Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=z5J7sFwoaCy05q8FW3lKEWbL8GMwnjDOmJeQzYABdyk=;
 b=IH7GjsZ1dFEx8rJuUE0ForJcJzFXtr9Z2Pk/nncATWMD8+3Ci43FLAblj5qNUsErbf/1ZrTHZ4waEdcRjD4AkQ+H2PmDzIJvqCfO6/ltz0bjS1dwhtWLj0TIEcjclpgUPiiYGW4TfWmnQniDBMwjJ+HHAbWFQeHoSPxM8+hIQ3w=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by DS0PR19MB6549.namprd19.prod.outlook.com (2603:10b6:8:c5::7) with
 Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.8398.24; Mon, 3 Feb 2025 20:29:55 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8398.020; Mon, 3 Feb 2025
 20:29:55 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAAAWoA
Date: Mon, 3 Feb 2025 20:29:54 +0000
Message-ID: <7f1d21950673c3deae1e92839deb61be88d77f22.camel@whamcloud.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
 <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
 <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
 <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
In-Reply-To: <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|DS0PR19MB6549:EE_
x-ms-office365-filtering-correlation-id: e792b182-a59f-4912-6c92-08dd44918514
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|366016|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?cjE3RklyNXk5dXMyLzFXY1FkMnU1Yi9DVGw0Sk5kNjBYVEF6YWg1YlU2RWNi?=
 =?utf-8?B?bDczRUlCVDFBNnNwMUJSNUJzTnYwSGN6cFl4RjBsTGxPL0hIczVCVWpUODlr?=
 =?utf-8?B?ZkRkZWZkL2xJV1E0a05nSFAxdHhXcUVWcW9ZRVJaK2xmTFlUTGxjVStTdTh6?=
 =?utf-8?B?a1ZKWFFOeE5tZ0swdUE2eWUrR24ySndWbUZ4R2ROeGNzNFBsQ2p6bDJrYkVH?=
 =?utf-8?B?MHd0NElhazBoRjJJS20zU2ZCUFo0eDJPMHV0Q0ZPaEF1ck5YUjhBQTVOMnJE?=
 =?utf-8?B?V1IvYUk1aUEzUm56UzZnR1hGdUpYcWhzL24wQ2Zia0lkSVduTWRUQkY4eFpN?=
 =?utf-8?B?L1ZrVzYwZ2s4eVR4Ky9sdWFHeG1nSXA3Z3MvKzliWGg1WDZpTWRoZjI4NjNK?=
 =?utf-8?B?WUpvclA5U0NyS3QxU3Ftd1NPb2N1QTcvSnJtUEFNOHU2RUp5MldteCtOZlh4?=
 =?utf-8?B?elVZQVFtVy9ENVhPQTdkZFZFbGpoTGc1bDBsRldOYm16MXplcHFlTERMWTNX?=
 =?utf-8?B?LzhYVENYRjNiZXp0RUN6a1BscXB4ZjhhT1dFN29HM1krbUtxRU5lVmJEYXZQ?=
 =?utf-8?B?ZjZudm5OSFhSbjlGYWhZRlovTkdYcGhUTWJhM3RrWEMrb2tzU2h2UUN4bGpF?=
 =?utf-8?B?VlJIRE9Ody9ZenlxUDV1aEtOeG4veXM1MDJEbTJ5QU0ySWdpRDhiZzRraVRM?=
 =?utf-8?B?TnFBbFNPTVJhQ2NjRVJYNlBEWkJHSTFwVFRDT2wyemoxSGNCWUxHMmZ5czhv?=
 =?utf-8?B?ZTRzRHBlR0p4VjcwK3BFRE11Zk52SXhaQ09aWEF5ZXo5NTl5S04wbXZWQldo?=
 =?utf-8?B?LzhzQ2RlSTNhOXFiYUFKWktDNERFWW14TFFVc0FCdFNIKzZ4eVBMZTB5ZUk3?=
 =?utf-8?B?YXJ0azFiTmpyWHh6bUt6ZWNublF6T3ZpVFdQR1lUSkhFUlJPMXdhQnVEQXha?=
 =?utf-8?B?TkxTWjVremZYWGsxRlozZzNnK0xwTXNLN0RrMjUwWllUL2w0TkcvOE9tM2xB?=
 =?utf-8?B?akFhTlo2Ym9xSjRNTWprYmdlYkR2cVZLdHZOWUdIOFFLdFRTNFdXT1l2STY0?=
 =?utf-8?B?V2I5S1ZlSHIwZHJMM1dVQ25zbkNaSUxTenBxWXFhZEhKYVJ6TmVCV3NFaldo?=
 =?utf-8?B?MHpsdkNHTDIxZjRCQTBHa0FuQmdnek5iTUpFRFlxblNJNFlNMmNVRE1idmpx?=
 =?utf-8?B?cUVmbkUyU2RoMFBoUkRJWWFPUFNITkNpMis4aG5wUGIzNFhya1d0cnRLaldF?=
 =?utf-8?B?d0ZGOXZzZDhOaGVibzRIUjlsYWg5QTVOWlM5NDZNVk5BdFZlMVBXOGsrdUtj?=
 =?utf-8?B?RnVZc1o3a1d2N3dEVTFUUHZQVVhCZmwrTUNNaVhySWpBTG9UVTRncUR1OXlN?=
 =?utf-8?B?SUNIZXZvS3dETlIrQkUvUU03a3RRb1ppOUNnVDNoUmdWM253WkZyaXUrcFNa?=
 =?utf-8?B?bmFjMmViL1lpNm5ESTdSWUt4cDU4NXpCZi9VeU1ZTFZoWHBsNTRKdkwyemVG?=
 =?utf-8?B?TUN1aWFsa0xYRndiek5DdzlKdkFqNWh2TU14ODl6a3gyLzd3NExNRDZycTF4?=
 =?utf-8?B?bjlzQmIraWhhSFA1UjlONlhqYU1SZUFmeTYzbnBENG16bHlZYzB0cGsyV1Fo?=
 =?utf-8?B?M1BLU1RNaGtBZEc3b052cTY1Q3Vwam5TVTFkZHNWcUR5SVJVVFBucFVkVjA0?=
 =?utf-8?B?OXZtWEcxQlkvWTM3UW5rRGVOZWdXdU4raHNjb1VnOE5ZSFRiNnZHWnZZU1Zu?=
 =?utf-8?B?RjVWVEVrd25PYjE3Qi8zSCs2MWpPdjFBd2t0QWdhTjU3aE5KdEV4enFFU21E?=
 =?utf-8?B?VlVvSW5EMGFKdFMyV0xKbTlyWGt4T3E5MDFMYURQUVp6UXFNWVVNSXhPWE9L?=
 =?utf-8?B?OWU0cGhXeVQwbmFzL2dRbno5dzgxNDlxTWxNZWNUVE9vWXF4ams2cHFVNVA0?=
 =?utf-8?Q?I03ytvpJ0m1FWW7BvjiQhlhwJ1oG/Ut5?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?eUVvWndIOFl4UkFMekdaZ1RTZUdFMEhWQnc5ZWlqbUgycTBkeDc2MTFUbDZD?=
 =?utf-8?B?R2pja2VadVIrb0ZzUU4wSGVhYnVCVm82MjVUTTZac1hrOUJFWVVmN1E3R0h4?=
 =?utf-8?B?U1B4OXNET2hIaXBGaUpyV0JtOGxzZ2FhSElYNDcyTDlncnlhQlJtK2EvY0Fq?=
 =?utf-8?B?b3hERU9GSEVOTWNjTXJZVUZqa0tvbWQ1OEJtWExuTm4wSUlFZk1MY003bE8z?=
 =?utf-8?B?TkQ5M0ZMb0NCaWN6OWJnN210ZDFwTzRXQ3lMZFlzYjE5YmNwUW9Wd0tTN2xV?=
 =?utf-8?B?WUF3ckh5WC9EemFnUmJnN3p5VTJ5VzZZSGNDQS9jYU9IeE5zeDJKVmpNUGNt?=
 =?utf-8?B?dGsvZ3lLa0NUczBnZ2VxK01tcC9YaFZrTmlhc0xXOGFNTUFodHAzOGxJYlRY?=
 =?utf-8?B?ck4wT25wSEZRNEsyZG50MDF4QTBnNENRR0h6TndaUVlLUVk1bkRvZHB2TlZK?=
 =?utf-8?B?L2hrQnpXOFQ1SHZkVjFWWjJUcWlQZ2ZaMWQrTW1peVg0OStEQmRIYTNaV3Zv?=
 =?utf-8?B?Z2lRL1orc0tKTHFkZDg4RDMyNDJRR01JSnovS2xHYUxRL1JVOVpaS29Dbkdu?=
 =?utf-8?B?bUJSaGNFM0JHSXRBbnZxanMrUW1aUmFESDYvUTdKeXR6bTZMNnMyWXZzVFQ3?=
 =?utf-8?B?QlZnSGxYMFZjbTlHdkVTTTR5dTgwRkxhYkN1d0dtS2hzZ2NDeHVYVVEvajZm?=
 =?utf-8?B?d0J4Z09oQTlQQVkwNlAyaUgzOFhiRkhYa2dBdFlCZjRYWFdvWW1rL0Q0Yk90?=
 =?utf-8?B?VWZWbnVWTDdhWDF3TmJOUjFQeTVWWm9IendYVXZKdk45bE5lZGpHQU1oNjhY?=
 =?utf-8?B?WUdpclhGLyt5R092d0FoS1dGbjhlbXRJdEl0NUgvanVhemhaNlVOaGRaN0lh?=
 =?utf-8?B?RnpNK21VQjkrL1B1RjIwSmlXeVEvOVE5V0NOSXBwNDZHQmtzSTc2aUY1MzBB?=
 =?utf-8?B?d2RzUGl3OXVMMkVpMWFRT0pvc1gxYnRXZ0N0NkRyMm1Kb0V0RWN0OFJyZDQy?=
 =?utf-8?B?bDZVZ0JvRmlBZ01iQlhKY1BQeVYzZUE5akNYM2JKc2pMKzJsdXhUV3llWVNh?=
 =?utf-8?B?RFhiYWNEcW0yRmtBamVNVFBSb2Y3eWxmaFpOMzhIbUNBZnE1Zk01c2tQd3JV?=
 =?utf-8?B?Zi9oM1VJUlRZbU9MUzBPZGsxc2h6WWx0ZzRNNWx1RmtoR2tHSGZ0QnZ1VSsx?=
 =?utf-8?B?eXJYUmU1THVEQWRkdHlZSHdYVXp6VkdjWk1FajN0YW9UTWt0ajFFMDFZcHA1?=
 =?utf-8?B?dWFJcndYbitCMWNtZ3ZDZ2FuTE9McElqaGRpdGVkY3QyWmZVUTdDUUpRS1hp?=
 =?utf-8?B?Q0htRFgvRlBUa0UydWppZ2tpS2RhVFNNQXZucDQxaWppc2NWYzB2WFFjTEha?=
 =?utf-8?B?bG90WnZZaXkxbW5xejh0RlUyTC9FN0p1Wm1DN05yUStBaU9ET2RqUHl6UjU4?=
 =?utf-8?B?aVdFbHVrWjRVT0NBbTFYdW5leHZyS3h5UU5WNlBvZjBuSDVGWkpKVkhtTkVa?=
 =?utf-8?B?bU1KQ2VsOXhjZjQ3YXByNndtdzgxcWZxOTlYTWVJSGp6RDIzM1JsY0t5U0M0?=
 =?utf-8?B?VmVRYWMwRytQOERvN3MxS0lyNS8xV2JRZWZESVRWVEJLdkl5ZENZUFBJZDd2?=
 =?utf-8?B?Vnl2b1FHanVncFpZZndLWkYrUU1IR0dCa2R3VlJvS2hPQkU1MCt1ZFA3ZHZm?=
 =?utf-8?B?eG5IcU5IUjN3cHRBUURVMXlTdXV2OFVlRGgzOVIxeGlWTW9oVFBMdm9lTXVt?=
 =?utf-8?B?VW90cnFNVGVFeFdZM1FaR1hJZENNYS8wNjNic29YNXRCNDNzcWFWSnA2bEJX?=
 =?utf-8?B?VGJsTDhXZ1RabDZnbmF6NDhpVFF6WGpQRkV6bnlUUFpQdzd1T1VKYTh5dlh4?=
 =?utf-8?B?NHU5RUtFcWRjQlZGemEyb2l1d1lQWkFJMW1oWG5lTllHSldKd010NnB3Sy9I?=
 =?utf-8?B?UTBEK08zMW9QV09IUitEQ3ZBQlhlZDFIckpUVmdmUWVqdnd3VUdaT0tzQ3FW?=
 =?utf-8?B?TlFDSHYrVnh6cWEwdVpaUFR2NU9RU1B2eTdJcURpVVVnc1ZVYWVEUUpnRklK?=
 =?utf-8?B?YnNRQ3gzNWVhZ29GUFRmbS85ZklMTnpQNmt6T1J5bkxyVXgzd09iL3UyK3ph?=
 =?utf-8?Q?CoErmezNeEmXFwM87OopKiuGC?=
Content-ID: <49882238D6F3D946B88FCBCDFCDAF709@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: xBBEOBcMkaCsTyZ0uliH85cJa3lWERctCkXVFXtVD+OAVQMF6+SqethmGUK0FN0OHXync83PgmPF06+WA0JPXEnjGS7AnoVM/QxiFTLif8Vq/OBslxrOiy/hEvfRGfm93y6CcMNANjNYtsoxTzFvlk/xecU+8PDlrVXMd77T0xjz0oFp/wmEvfm0KcJaidwfOjWUmpnRFTJsx/9WqFz5cLABO92Ku4iXY1+Vs+rVQ5K9A14TiLFspzXRQCR0H84X/kSOrTXs3MNJERIcO3A5cGd3D3L5x/JW+cVMO5ihZA7Roz0pfcydLK5k7iSIKJht5+KNJjHJnJCPXpRbjVzhyFnIoC1z0KmgLq8Oh2GiAC7m/cnt6KV+zsTZ4sPHZL5+lYLkRxQ3KpE/mX4CT/T5HORsIlFK1Z7Q/ERevyjVC3Rb+ICRf2J90m08r3Mkbj1aI2Ac2EbAAxezY7QQbfzWjlYyzv5nY2RP+1iBtBgHFg6iG7qF99NtjtwR085rEG2X65bzkyskmJFQmOD/hDRzh0UF3U+btrv2tY2axgsTWcgP0z8e/MBzGhihPlw+ZGKyq24DyeSi9cknZQsNMYgKTEwxJpqYO772sA+4ynFxa1VsFGQjfgrjbKQtiaYvgQGIw2T1yjaW1Sk7dWWWXMJ3lh3baunryjELbrq9D+ZFK0w=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e792b182-a59f-4912-6c92-08dd44918514
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Feb 2025 20:29:55.0008 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: lY60o8tFGqCJsUS/Qf8JKSE5sZXOX1f460i9OrtV7zejMtq4JDmYf4DyJ1NVQMaC
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR19MB6549
X-BESS-ID: 1738614600-104672-1244-594-1
X-BESS-VER: 2019.1_20250123.1616
X-BESS-Apparent-Source-IP: 104.47.74.43
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKViYGJkBGBlAsKdk0ycDUNNUg2d
 jUODnNPC3ZzCLZ0MI81dw42dzMOEWpNhYAEIyZiEAAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262267 [from 
 cloudscan10-132.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Mon, 2025-02-03 at 20:24 +0000, Oleg Drokin wrote:

> at $11/hour the m7a.metal-48xl would take $264 to run for just one
> day,
> a week is an eye-watering $1848, so running this for every patch is
> not
> super economical I'd say.

x2gd metal at $5.34 per hour makes more sense as it has more RAM (and
64 CPUs is adequate I'd say) but still quite pricey if you want to run
this at any sort of scale.
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
